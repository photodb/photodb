unit uFormLinkItemSelector;

interface

uses
  Generics.Defaults,
  Generics.Collections,
  System.DateUtils,
  System.Math,
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.ImgList,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.AppEvnts,

  Dmitry.Controls.Base,
  Dmitry.Controls.WebLink,
  Dmitry.Controls.WatermarkedEdit,

  UnitDBDeclare,

  uMemory,
  uDBForm,
  uFormInterfaces,
  uGraphicUtils,
  uVCLHelpers;

type
  TAniDirection = (adVert, adHor);
  TAniOption = (aoRemove);
  TAniOptions = set of TAniOption;

  TAnimationInfo = record
    Control: TControl;
    EndPosition: Integer;
    StartPosition: Integer;
    TillTime: TDateTime;
    Direction: TAniDirection;
    Options: TAniOptions;
  end;

  TFormLinkItemSelector = class(TDBForm, ILinkItemSelectForm, IFormLinkItemEditorData)
    AeMain: TApplicationEvents;
    TmrAnimation: TTimer;
    PnEditorPanel: TPanel;
    PnMain: TPanel;
    BtnClose: TButton;
    BtnSave: TButton;
    WlApplyChanges: TWebLink;
    WlCancelChanges: TWebLink;
    WlRemove: TWebLink;
    BvActionSeparator: TBevel;
    PnTop: TPanel;
    BvEditSeparator: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure AeMainMessage(var Msg: tagMSG; var Handled: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure TmrAnimationTimer(Sender: TObject);
    procedure WlAddElementsClick(Sender: TObject);
    procedure WebLinkMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure WebLinkMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure WlApplyChangesClick(Sender: TObject);
    procedure WlCancelChangesClick(Sender: TObject);
    procedure WlRemoveClick(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FLinks: TList<TWebLink>;
    FLabels: TList<Tlabel>;
    FData: TList<TDataObject>;
    FEditData: TDataObject;

    FEditor: ILinkEditor;
    FActions: TList<string>;
    FActionLinks: TList<TWebLink>;

    FListWidth: Integer;
    FLinkPositions: TDictionary<TWebLink, Integer>;
    FAnimations: TList<TAnimationInfo>;
    FDragLink: TWebLink;
    FDragLabel: Tlabel;
    FStartMousePos: TPoint;
    FStartLinkPos: TPoint;
    FStartInfoPos: TPoint;
    FIsEditMode: Boolean;
    FDragMode: Boolean;
    FEditIndex: Integer;
    procedure CreateNewLine(var DataObject: TDataObject; Elements: TListElements);
    procedure CreateListElements(Elements: TListElements);
    procedure CheckLinksOrder;
    procedure LoadLinkList;
    procedure LoadActionsList;
    procedure AddLinkFromObject(DataObject: TDataObject);
    procedure MoveControlTo(Control: TControl; Position: Integer; Direction: TAniDirection; Options: TAniOptions = []);
    procedure MoveControlToIndex(Control: TControl; Index: Integer);
    procedure SwitchToEditMode;
    procedure SwitchToListMode;
    function GetFormHeight: Integer;
    property FormHeight: Integer read GetFormHeight;
  protected
    function GetFormID: string; override;
    procedure InterfaceDestroyed; override;
  public
    { Public declarations }
    function Execute(ListWidth: Integer; Title: string; Data: TList<TDataObject>; Editor: ILinkEditor): Boolean;
    function GetDataList: TList<TDataObject>;
    function GetEditorData: TDataObject;
    function GetTopPanel: TPanel;
    function GetEditorPanel: TPanel;
    procedure ApplyChanges;
  end;

var
  FormLinkItemSelector: TFormLinkItemSelector;

implementation

const
  LinksLimit = 20;
  PaddingTop = 8;
  LinkHeight = 18;
  LinksDy = 6;
  AnimationDuration = 1 / (24 * 60 * 60 * 2); //0.5s
  AnimationDurationMs = 500;

function Circ(Progress: Extended): Extended;
begin
  Result := 1 - Sin(ArcCos(Progress))
end;

function MakeEaseInOut(Progress: Extended): Extended;
begin
  if (progress < 0.5) then
    Result := Circ(2 * progress) / 2
  else
    Result := (2 - Circ(2 * (1 - progress))) / 2
end;

function makeEaseOut(Progress: Extended): Extended;
begin
    Result := 1 - Circ(1 - progress)
end;

{$R *.dfm}

procedure TFormLinkItemSelector.AeMainMessage(var Msg: tagMSG; var Handled: Boolean);
const
  TopDy = 8;
var
  P: TPoint;
  Diff,
  NewTop: Integer;

  function MouseYToTop(MouseY: Integer): Integer;
  var
    Progress: Double;
    Top: Integer;
  begin
    if MouseY < PaddingTop then
    begin
      Progress := (PaddingTop - MouseY) / 100;
      Progress := Min(1, Max(0, Progress));

      Result := Round(PaddingTop - PaddingTop * makeEaseOut(Progress));
      Exit;
    end;

    Top := PaddingTop + (FLinks.Count - 1) * (LinkHeight + LinksDy);
    if MouseY > Top then
    begin
      Progress := (MouseY - Top) / 100;
      Progress := Min(1, Max(0, Progress));

      Result := Round(Top + PaddingTop * makeEaseOut(Progress));
      Exit;
    end;

    Result := MouseY;
  end;

begin
  if Active then
  begin
    if Msg.message = WM_MOUSEMOVE then
    begin
      if FDragLink <> nil then
      begin
        GetCursorPos(P);
        Diff := P.Y - FStartMousePos.Y;

        NewTop := FStartLinkPos.Y + Diff;
        FDragLink.Top := MouseYToTop(NewTop);

        NewTop := FStartInfoPos.Y + Diff;
        FDragLabel.Top := MouseYToTop(NewTop);

        CheckLinksOrder;
      end;
    end;
    if Msg.message = WM_LBUTTONUP then
    begin
      if FDragLink <> nil then
      begin
        MoveControlToIndex(FDragLink, FDragLink.Tag);
        MoveControlToIndex(FDragLabel, FDragLabel.Tag);
        FDragLink := nil;
      end;
    end;
  end;
end;

procedure TFormLinkItemSelector.ApplyChanges;
var
  Data: TDataObject;
  Elements: TListElements;
begin
  Data := FData[FEditIndex];
  FEditor.UpdateItemFromEditor(Self, Data, Self);
  Elements := TListElements.Create;
  try
    Elements.Add(leWebLink, FLinks[FEditIndex]);
    Elements.Add(leInfoLabel, FLabels[FEditIndex]);
    FEditor.CreateNewItem(Self, Data, '', Elements);
  finally
    F(Elements);
  end;
  SwitchToListMode;
end;

procedure TFormLinkItemSelector.BtnCloseClick(Sender: TObject);
begin
  Close;
  ModalResult := mrCancel;
end;

procedure TFormLinkItemSelector.BtnSaveClick(Sender: TObject);
begin
  if FIsEditMode then
    ApplyChanges;

  if FEditor.OnApply(Self) then
  begin
    Close;
    ModalResult := mrOk;
  end;
end;

procedure TFormLinkItemSelector.CheckLinksOrder;
var
  I,
  LinkReplacePosStart,
  LinkReplacePosEnd,
  TmpTag: Integer;
  Link: TWebLink;
  Info: Tlabel;
begin
  if FDragLink = nil then
    Exit;

  for I := 0 to FLinks.Count - 1 do
  begin
    Link := FLinks[I];
    Info := FLabels[I];
    if Link <> FDragLink then
    begin
      LinkReplacePosStart := PaddingTop + I * (LinkHeight + LinksDy) - LinksDy + (LinksDy div 2 - LinkHeight div 2);
      LinkReplacePosEnd := LinkReplacePosStart + LinkHeight + LinksDy;

      if (LinkReplacePosStart < FDragLink.Top) and (FDragLink.Top < LinkReplacePosEnd) then
      begin
        FDragMode := True;

        FData.Exchange(Link.Tag, FDragLink.Tag);

        TmpTag := Link.Tag;
        Link.Tag := FDragLink.Tag;
        FDragLink.Tag := TmpTag;

        TmpTag := Info.Tag;
        Info.Tag := FDragLabel.Tag;
        FDragLabel.Tag := TmpTag;

        MoveControlToIndex(Link, Link.Tag);
        MoveControlToIndex(Info, Info.Tag);

        FLinks.Sort(TComparer<TWebLink>.Construct(
           function (const L, R: TWebLink): Integer
           begin
             Result := L.Tag - R.Tag;
           end
        ));
        FLabels.Sort(TComparer<Tlabel>.Construct(
           function (const L, R: Tlabel): Integer
           begin
             Result := L.Tag - R.Tag;
           end
        ));

        Break;
      end;
    end;
  end;
end;

function TFormLinkItemSelector.Execute(ListWidth: Integer; Title: string;
  Data: TList<TDataObject>; Editor: ILinkEditor): Boolean;
begin
  FEditor := Editor;
  FListWidth := ListWidth;

  Caption := Title;

  FData := Data;

  FEditor.SetForm(Self);
  if PnTop.ControlCount = 0 then
  begin
    PnTop.Height := 0;
    PnTop.Hide;
  end;

  WlApplyChanges.RefreshBuffer(True);
  WlCancelChanges.RefreshBuffer(True);
  WlRemove.RefreshBuffer(True);

  WlCancelChanges.Left := WlApplyChanges.AfterRight(PaddingTop);
  WlRemove.Left := WlCancelChanges.AfterRight(PaddingTop);

  LoadActionsList;
  LoadLinkList;
  SwitchToListMode;

  ShowModal;
  Result := ModalResult = mrOk;
end;

procedure TFormLinkItemSelector.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FEditor.SetForm(nil);
  Action := caHide;
end;

procedure TFormLinkItemSelector.FormCreate(Sender: TObject);
begin
  FEditIndex := -1;
  FDragLink := nil;
  FDragLabel := nil;
  FEditData := nil;
  FEditor := nil;
  FIsEditMode := False;
  FDragMode := False;
  FLinks := TList<TWebLink>.Create;
  FLabels := TList<Tlabel>.Create;
  FLinkPositions := TDictionary<TWebLink, Integer>.Create;
  FAnimations := TList<TAnimationInfo>.Create;

  FActions := TList<string>.Create;
  FActionLinks := TList<TWebLink>.Create;

  BtnClose.Caption := L('Cancel', '');
  BtnSave.Caption := L('Save', '');

  WlApplyChanges.Text := L('Apply');
  WlCancelChanges.Text := L('Cancel');
  WlRemove.Text := L('Remove');

  WlApplyChanges.LoadFromResource('DOIT');
  WlCancelChanges.LoadFromResource('CANCELACTION');
  WlRemove.LoadFromResource('DELETE_FILE');
end;

procedure TFormLinkItemSelector.FormDestroy(Sender: TObject);
begin
  F(FLinkPositions);
  F(FLinks);
  F(FLabels);
  F(FAnimations);
  F(FEditData);
  F(FActions);
  F(FActionLinks);
end;

procedure TFormLinkItemSelector.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    if FIsEditMode then
      WlCancelChangesClick(Sender)
    else
      Close;
  end;
end;

function TFormLinkItemSelector.GetDataList: TList<TDataObject>;
begin
  Result := FData;
end;

function TFormLinkItemSelector.GetEditorData: TDataObject;
begin
  Result := FEditData;
end;

function TFormLinkItemSelector.GetEditorPanel: TPanel;
begin
  Result := PnEditorPanel;
end;

function TFormLinkItemSelector.GetFormHeight: Integer;
begin
  Result := PaddingTop * 2 + FLinks.Count * (LinkHeight + LinksDy) + 60;
end;

function TFormLinkItemSelector.GetFormID: string;
begin
  Result := 'LinkListEditor';
end;

function TFormLinkItemSelector.GetTopPanel: TPanel;
begin
  Result := PnTop;
end;

procedure TFormLinkItemSelector.InterfaceDestroyed;
begin
  inherited;
  Release;
end;

procedure TFormLinkItemSelector.CreateListElements(Elements: TListElements);
var
  WL: TWebLink;
  IL: Tlabel;
begin
  WL := TWebLink.Create(Self);
  WL.Parent := PnMain;
  WL.Tag := FLinks.Count;
  WL.Height := LinkHeight;
  WL.Width := ClientWidth;
  WL.Left := PaddingTop;
  WL.Font.Assign(Font);
  WL.OnMouseDown := WebLinkMouseDown;
  WL.OnMouseUp := WebLinkMouseUp;
  FLinks.Add(WL);
  Elements.Add(leWebLink, WL);

  IL := Tlabel.Create(Self);
  IL.Parent := PnMain;
  IL.Tag := FLabels.Count;
  IL.AutoSize := False;
  IL.Anchors := [akLeft, akTop, akRight];
  IL.Alignment := taRightJustify;
  IL.Enabled := False;

  FLabels.Add(IL);
  Elements.Add(leInfoLabel, IL);
end;

procedure TFormLinkItemSelector.CreateNewLine(var DataObject: TDataObject; Elements: TListElements);
var
  WL: TWebLink;
  IL: Tlabel;
begin
  CreateListElements(Elements);

  FEditor.CreateNewItem(Self, DataObject, '', Elements);

  WL := TWebLink(Elements[leWebLink]);
  IL := Tlabel(Elements[leInfoLabel]);

  WL.RefreshBuffer(True);
  IL.Left := WL.Left + WL.Width + PaddingTop;
  IL.Width := ClientWidth - IL.Left - IL.Width - PaddingTop;

  MoveControlToIndex(WL, WL.Tag);
  MoveControlToIndex(IL, IL.Tag);

  MoveControlTo(Self, FormHeight, adVert);

  if FLinks.Count = LinksLimit then
    for WL in FActionLinks do
      WL.Enabled := False;
end;

procedure TFormLinkItemSelector.AddLinkFromObject(DataObject: TDataObject);
var
  Elements: TListElements;

  procedure AddLink(Link: TWebLink);
  begin
    FLinks.Add(Link);
    FLinkPositions.Remove(Link);
    FLinkPositions.Add(Link, Link.Top);
  end;

begin
  Elements := TListElements.Create;
  try
    CreateNewLine(DataObject, Elements);
  finally
    F(Elements);
  end;
end;

procedure TFormLinkItemSelector.LoadActionsList;
begin
  FEditor.FillActions(Self,
    procedure(Actions: array of string; ProcessActionLink: TProcessActionLinkProcedure)
    var
      LinkLeft: Integer;
      Action: string;
      WL: TWebLink;
    begin
      LinkLeft := PaddingTop;
      for Action in Actions do
      begin
        WL := TWebLink.Create(Self);
        WL.Parent := PnMain;
        WL.Left := LinkLeft;
        WL.Top := BvActionSeparator.Top + PaddingTop;
        WL.Anchors := [akLeft, akBottom];
        WL.Text := 'Add new';
        WL.OnClick := WlAddElementsClick;
        WL.RefreshBuffer(True);
        WL.Tag := FActions.Count;
        ProcessActionLink(Action, WL);

        FActions.Add(Action);
        FActionLinks.Add(WL);

        LinkLeft := LinkLeft + WL.Width + PaddingTop;
      end;
    end
  );
end;

procedure TFormLinkItemSelector.LoadLinkList;
var
  DataItem: TDataObject;
begin
  for DataItem in FData do
    AddLinkFromObject(DataItem);
end;

procedure TFormLinkItemSelector.MoveControlTo(Control: TControl; Position: Integer; Direction: TAniDirection; Options: TAniOptions = []);
var
  AnimationInfo: TAnimationInfo;
  I: Integer;
begin

  for I := 0 to FAnimations.Count - 1 do
    if (FAnimations[I].Control = Control) and (FAnimations[I].Direction = Direction) then
    begin
      FAnimations.Delete(I);
      Break;
    end;

  if Visible then
  begin

    AnimationInfo.Control := Control;
    AnimationInfo.Direction := Direction;
    AnimationInfo.Options := Options;

    AnimationInfo.EndPosition := Position;
    if Control is TForm then
    begin
      if AnimationInfo.Direction = adVert then
      begin
        AnimationInfo.EndPosition := Position + PnTop.Height;
        AnimationInfo.StartPosition := Control.ClientHeight;
      end;
      if AnimationInfo.Direction = adHor then
        AnimationInfo.StartPosition := Control.ClientWidth;
    end else
    begin
      if AnimationInfo.Direction = adVert then
        AnimationInfo.StartPosition := Control.Top;
      if AnimationInfo.Direction = adHor then
        AnimationInfo.StartPosition := Control.Left;
    end;
    AnimationInfo.TillTime := IncMilliSecond(Now, AnimationDurationMs);
    FAnimations.Add(AnimationInfo);

    TmrAnimation.Enabled := True;
  end else
  begin
    if Control is TForm then
    begin
      if Direction = adVert then
        Control.ClientHeight := Position + PnTop.Height;
      if Direction = adHor then
        Control.ClientWidth := Position;
    end else
    begin
      if Direction = adVert then
        Control.Top := Position;
      if Direction = adHor then
        Control.Left := Position;
    end;
  end;

end;

procedure TFormLinkItemSelector.MoveControlToIndex(Control: TControl; Index: Integer);
var
  NewPos: Integer;
  Link: TWebLink;
begin
  NewPos := PaddingTop + Index * (LinkHeight + LinksDy);

  if Control is TWebLink then
  begin
    Link := TWebLink(Control);
    FLinkPositions.Remove(Link);
    FLinkPositions.Add(Link, NewPos);
  end;

  MoveControlTo(Control, NewPos, adVert);
end;

procedure TFormLinkItemSelector.TmrAnimationTimer(Sender: TObject);
var
  I, NewPos: Integer;
  Animation: TAnimationInfo;
  Progress: Double;
  Control: TControl;
  CStart, CEnd: Cardinal;
begin
  CStart := GetTickCount;
  TmrAnimation.Enabled := False;
  Self.DisableAlign;
  BeginScreenUpdate(Handle);
  try
    for I := FAnimations.Count - 1 downto 0 do
    begin
      Animation := FAnimations[I];
      Progress := 1 - (Animation.TillTime - Now) / AnimationDuration;

      Progress := Min(1, Max(0, Progress));

      NewPos := Animation.StartPosition + Round(makeEaseOut(Progress) * (Animation.EndPosition - Animation.StartPosition));

      Control := Animation.Control;
      if Control is TForm then
      begin
        if Animation.Direction = adVert then
          Control.ClientHeight := NewPos;
        if Animation.Direction = adHor then
          Control.ClientWidth := NewPos;
      end else
      begin
        if Animation.Direction = adVert then
          Control.Top := NewPos;
        if Animation.Direction = adHor then
          Control.Left := NewPos;
      end;

      if Progress = 1 then
      begin
        if aoRemove in Animation.Options then
          Control.Free;
        FAnimations.Delete(I);
        Continue;
      end;
    end;
  finally
    EnableAlign;
    SendMessage(Handle, WM_SETREDRAW, 1, 0);
    RedrawWindow(Handle, nil, 0, RDW_INVALIDATE + RDW_ALLCHILDREN + RDW_INTERNALPAINT);
  end;
  if FAnimations.Count = 0 then
    Exit;
  CEnd := GetTickCount;
  TmrAnimation.Interval := Max(1, 10 - Max(10, (CEnd - CStart)));
  TmrAnimation.Enabled := True;
end;

procedure TFormLinkItemSelector.WlAddElementsClick(Sender: TObject);
var
  Data: TDataObject;
  Elements: TListElements;
  WL: TWebLink;
begin
  if FIsEditMode then
    Exit;

  WL := TWebLink(Sender);

  Data := nil;
  FEditor.CreateNewItem(Self, Data, FActions[WL.Tag], nil);
  if Data <> nil then
  begin
    Elements := TListElements.Create;
    try
      CreateNewLine(Data, Elements);

      FData.Add(Data);
    finally
      F(Elements);
    end;
  end;
end;

procedure TFormLinkItemSelector.WebLinkMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  P: TPoint;
begin
  if FIsEditMode or FDragMode then
    Exit;

  GetCursorPos(P);
  if (Abs(P.X - FStartMousePos.X) <= 3) and (Abs(P.Y - FStartMousePos.Y) <= 3) then
  begin
    FIsEditMode := True;
    FEditIndex := TWebLink(Sender).Tag;
    SwitchToEditMode;
  end;
end;

procedure TFormLinkItemSelector.SwitchToEditMode;
var
  I: Integer;
  ToWidth, ToHeight: Integer;
  WL: TWebLink;
begin
  FLinks[FEditIndex].Enabled := False;
  F(FEditData);
  FEditData := FData[FEditIndex].Clone;

  BtnClose.BringToFront;
  BtnSave.BringToFront;

  PnEditorPanel.Tag := NativeInt(FEditData);
  PnEditorPanel.HandleNeeded;
  PnEditorPanel.AutoSize := True;
  FEditor.CreateEditorForItem(Self, FData[FEditIndex], Self);
  PnEditorPanel.Left := 8;
  PnEditorPanel.Top := PaddingTop + LinkHeight + LinksDy;

  if PnTop.Visible then
    ToWidth := ClientWidth
  else
    ToWidth := PnEditorPanel.Left + PnEditorPanel.Width + PaddingTop * 2;

  ToHeight := PnEditorPanel.Top + PnEditorPanel.Height + PaddingTop + WlApplyChanges.Height + PaddingTop + BtnClose.Height + PaddingTop;
  MoveControlTo(Self, ToWidth, adHor);
  MoveControlTo(Self, ToHeight, adVert);

  MoveControlTo(FLinks[FEditIndex], PaddingTop, adVert);
  for I := 0 to FLinks.Count - 1 do
    if I <> FEditIndex then
      MoveControlTo(FLinks[I], ToWidth, adHor);

  for I := 0 to FLabels.Count - 1 do
    MoveControlTo(FLabels[I], ToWidth, adHor);

  MoveControlTo(BvActionSeparator, ToWidth, adHor);

  for WL in FActionLinks do
    MoveControlTo(WL, ToHeight, adVert);

  MoveControlTo(BvEditSeparator, PnEditorPanel.Height - BvEditSeparator.Height, adVert);
  MoveControlTo(WlApplyChanges,  ToHeight + PnTop.Height - BtnSave.Height - WlApplyChanges.Height  - PaddingTop * 2, adVert);
  MoveControlTo(WlCancelChanges, ToHeight + PnTop.Height - BtnSave.Height - WlCancelChanges.Height - PaddingTop * 2, adVert);
  MoveControlTo(WlRemove,        ToHeight + PnTop.Height - BtnSave.Height - WlRemove.Height        - PaddingTop * 2, adVert);

  PnEditorPanel.Show;
end;

procedure TFormLinkItemSelector.SwitchToListMode;
var
  I, ActionsTop: Integer;
  ToWidth, ToHeight, Left: Integer;
  WL: TWebLink;
begin
  FIsEditMode := False;
  if FEditIndex > -1 then
    FLinks[FEditIndex].Enabled := True;
  PnEditorPanel.Hide;
  ToWidth := FListWidth;
  ToHeight := FormHeight;

  MoveControlTo(Self, ToWidth, adHor);
  MoveControlTo(Self, ToHeight, adVert);

  for I := 0 to FLinks.Count - 1 do
  begin
    MoveControlToIndex(FLinks[I], FLinks[I].Tag);
    MoveControlTo(FLinks[I], PaddingTop, adHor);

    Left := PaddingTop + FLinks[I].Width + PaddingTop;
    FLabels[I].Width := ClientWidth - PaddingTop - FLinks[I].Width - PaddingTop * 2;

    MoveControlToIndex(FLabels[I], FLabels[I].Tag);
    MoveControlTo(FLabels[I], Left, adHor);
  end;

  ActionsTop := (ToHeight - ClientHeight) + BtnClose.Top - FActionLinks[0].Height - PaddingTop + 2;

  MoveControlTo(BvActionSeparator, PaddingTop, adHor);
  MoveControlTo(BvActionSeparator, ActionsTop - 3, adVert);

  Left := PaddingTop;
  for WL in FActionLinks do
  begin
    WL.RefreshBuffer(True);
    MoveControlTo(WL, Left, adHor);
    Left := Left + WL.Width + PaddingTop;
  end;

  for WL in FActionLinks do
    MoveControlTo(WL, ActionsTop, adVert);

  MoveControlTo(BvEditSeparator, ToHeight, adVert);
  MoveControlTo(WlApplyChanges, ToHeight, adVert);
  MoveControlTo(WlCancelChanges, ToHeight, adVert);
  MoveControlTo(WlRemove, ToHeight, adVert);
end;

procedure TFormLinkItemSelector.WlApplyChangesClick(Sender: TObject);
begin
  ApplyChanges;
end;

procedure TFormLinkItemSelector.WlCancelChangesClick(Sender: TObject);
begin
  SwitchToListMode;
end;

procedure TFormLinkItemSelector.WlRemoveClick(Sender: TObject);
var
  I: Integer;
  LinkToDelete: TWebLink;
  LabelToDelete: TLabel;
  Data: TDataObject;
  WL: TWebLink;
begin
  Data := FData[FEditIndex];

  if FEditor.OnDelete(Self, Data, PnEditorPanel) then
  begin

    LinkToDelete := FLinks[FEditIndex];
    LinkToDelete.BringToFront;
    MoveControlTo(LinkToDelete, FormHeight, adVert, [aoRemove]);
    FLinks.Remove(LinkToDelete);

    LabelToDelete := FLabels[FEditIndex];
    LabelToDelete.BringToFront;
    MoveControlTo(LabelToDelete, FormHeight, adVert, [aoRemove]);
    FLabels.Remove(LabelToDelete);


    Data.Free;
    FData.Delete(FEditIndex);

    for I := 0 to FLinks.Count - 1 do
      FLinks[I].Tag := I;
    for I := 0 to FLabels.Count - 1 do
      FLabels[I].Tag := I;

    for WL in FActionLinks do
      WL.Enabled := True;

    FEditIndex := -1;
    SwitchToListMode;
  end;
end;

procedure TFormLinkItemSelector.WebLinkMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FDragMode := False;
    FDragLink := TWebLink(Sender);
    FDragLink.BringToFront;
    FDragLabel := FLabels[FDragLink.Tag];
    FDragLabel.BringToFront;

    FStartMousePos.X := X;
    FStartMousePos.Y := Y;
    FStartMousePos := FDragLink.ClientToScreen(FStartMousePos);
    FStartLinkPos := FDragLink.BoundsRect.TopLeft;
    FStartInfoPos := FDragLabel.BoundsRect.TopLeft;
  end;
end;

initialization
  FormInterfaces.RegisterFormInterface(ILinkItemSelectForm, TFormLinkItemSelector);

end.

