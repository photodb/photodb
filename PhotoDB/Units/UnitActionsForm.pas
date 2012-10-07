unit UnitActionsForm;

interface

uses
  System.SysUtils,
  System.Variants,
  System.Classes,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.ImgList,

  Dmitry.Utils.Files,
  Dmitry.Controls.Base,
  Dmitry.Controls.WebLink,

  ImageHistoryUnit,
  UnitDBDeclare,
  UnitDBFileDialogs,

  uDBForm,
  uMemory,
  uDBFileTypes,
  uThemesUtils,
  uConstants;

type
  TActionObject = class(TObject)
  public
    Action: string;
    ImageIndex: Integer;
    constructor Create(AAction : string; AImageIndex : Integer);
  end;

  TActionsForm = class(TDBForm)
    ActionList: TListBox;
    TopPanel: TPanel;
    SaveToFileLink: TWebLink;
    LoadFromFileLink: TWebLink;
    CloseLink: TWebLink;
    ActionsImageList: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure CloseLinkClick(Sender: TObject);
    procedure ActionListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure SaveToFileLinkClick(Sender: TObject);
    procedure LoadFromFileLinkClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FParent: TDBForm;
    Actions: TList;
    Cursor: Integer;
  protected
    { Protected declarations }
    function GetFormID: string; override;
    procedure CustomFormAfterDisplay; override;
  public
    { Public declarations }
    procedure LoadLanguage;
    procedure AddAction(Action: string; Atype: THistoryAction);
    procedure SetParentForm(Parent: TDBForm);
    procedure LoadIcons;
    procedure Reset;
  end;

var
  ActionsForm: TActionsForm;

implementation

uses
  UnitDBKernel,
  ImEditor,
  EffectsToolUnit;

{$R *.dfm}

procedure TActionsForm.FormCreate(Sender: TObject);
begin
  LoadLanguage;
  SaveToFileLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_SAVETOFILE + 1]);
  LoadFromFileLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_LOADFROMFILE + 1]);
  CloseLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_EXIT + 1]);

  Cursor := 0;
  Actions := TList.Create;
end;

procedure TActionsForm.FormDestroy(Sender: TObject);
begin
  FreeList(Actions);
end;

procedure TActionsForm.CloseLinkClick(Sender: TObject);
begin
  Close;
end;

procedure TActionsForm.CustomFormAfterDisplay;
begin
  inherited;
  if ActionList <> nil then
    ActionList.Refresh;
end;

procedure TActionsForm.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Actions');
    SaveToFileLink.Text := L('Save to file');
    LoadFromFileLink.Text := L('Load from file');
    CloseLink.Text := L('Close');
  finally
    EndTranslate;
  end;
end;

procedure TActionsForm.AddAction(Action: string; Atype: THistoryAction);
var
  ID, Filter_ID, Filter_Name, StrAction: string;
  Ico, I: Integer;
  EM: TEffectsManager;
  ActionObject : TActionObject;
begin
  if (Atype = [THA_Undo]) then
    Dec(Cursor);

  if (Atype = [THA_Redo]) then
    Inc(Cursor);

  if (Atype = [THA_Add]) then
  begin
    if Cursor <> Actions.Count then
    begin
      for I := 1 to Actions.Count - Cursor do
      begin
        ActionList.Items.Delete(Cursor);
        TObject(Actions[Cursor]).Free;
        Actions.Delete(Cursor);
      end;
    end;

    Inc(Cursor);
    ID := Copy(Action, 2, 38);
    Filter_ID := Copy(Action, 42, 38);
    Ico := 0;
    if ID = '{59168903-29EE-48D0-9E2E-7F34C913B94A}' then
    begin
      Ico := 0;
      StrAction := L('Open', 'Editor');
    end;
    if ID = '{5AA5CA33-220E-4D1D-82C2-9195CE6DF8E4}' then
    begin
      Ico := 1;
      StrAction := L('Crop', 'Editor');
    end;
    if ID = '{747B3EAF-6219-4A96-B974-ABEB1405914B}' then
    begin
      Ico := 2;
      StrAction := L('Rotate', 'Editor');
    end;
    if ID = '{29C59707-04DA-4194-9B53-6E39185CC71E}' then
    begin
      Ico := 3;
      StrAction := L('Resize', 'Editor');
    end;
    if ID = '{2AA20ABA-9205-4655-9BCE-DF3534C4DD79}' then
    begin
      EM := TEffectsManager.Create;
      try
        EM.InitializeBaseEffects;
        Filter_Name := EM.GetEffectNameByID(Filter_ID);
      finally
        F(EM);
      end;
      Ico := 4;
      StrAction := L('Effects', 'Editor') + ' [' + Filter_Name + ']';
    end;
    if ID = '{E20DDD6C-0E5F-4A69-A689-978763DE8A0A}' then
    begin
      Ico := 5;
      StrAction := L('Colors', 'Editor');
    end;
    // red
    if ID = '{3D2B384F-F4EB-457C-A11C-BDCE1C20FFFF}' then
    begin
      Ico := 6;
      StrAction := L('Red eye', 'Editor');
    end;
    // text
    if ID = '{E52516CC-8235-4A1D-A135-6D84A2E298E9}' then
    begin
      Ico := 7;
      StrAction := L('Text', 'Editor');
    end;
    // brush
    if ID = '{542FC0AD-A013-4973-90D4-E6D6E9F65D2C}' then
    begin
      Ico := 8;
      StrAction := L('Brush', 'Editor');
    end;
    // insert
    if ID = '{CA9E5AFD-E92D-4105-8F7B-978A6EBA9D74}' then
    begin
      Ico := 9;
      StrAction := L('Insert image', 'Editor');
    end;

    ActionObject := TActionObject.Create(Action, Ico);
    Actions.Add(ActionObject);
    ActionList.Items.Add(StrAction);
  end;
  ActionList.Refresh;
end;

procedure TActionsForm.SetParentForm(Parent: TDBForm);
begin
  FParent := Parent;
end;

procedure TActionsForm.LoadIcons;

  procedure AAddIcon(Icon: TIcon);
  begin
    ActionsImageList.AddIcon(Icon);
  end;

begin

  AAddIcon(TImageEditor(FParent).OpenFileLink.Icon);
  AAddIcon(TImageEditor(FParent).CropLink.Icon);
  AAddIcon(TImageEditor(FParent).RotateLink.Icon);
  AAddIcon(TImageEditor(FParent).ResizeLink.Icon);
  AAddIcon(TImageEditor(FParent).EffectsLink.Icon);
  AAddIcon(TImageEditor(FParent).ColorsLink.Icon);
  AAddIcon(TImageEditor(FParent).RedEyeLink.Icon);
  AAddIcon(TImageEditor(FParent).TextLink.Icon);
  AAddIcon(TImageEditor(FParent).BrushLink.Icon);
  AAddIcon(TImageEditor(FParent).InsertImageLink.Icon);
end;

procedure TActionsForm.ActionListDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  if Cursor = Index + 1 then
  begin
    //current item
    ActionList.Canvas.Brush.Color := Theme.ListSelectedColor;
    ActionList.Canvas.Pen.Color := Theme.ListSelectedColor;
  end else
  begin
    ActionList.Canvas.Brush.Color := Theme.ListColor;
    ActionList.Canvas.Pen.Color := Theme.ListColor;
  end;
  ActionList.Canvas.Rectangle(Rect);
  ActionList.Canvas.Pen.Color := Theme.WindowColor;

  if Cursor = Index + 1 then
    ActionList.Canvas.Font.Color := Theme.ListFontSelectedColor
  else
    ActionList.Canvas.Font.Color := Theme.ListFontColor;

  ActionsImageList.Draw(ActionList.Canvas, Rect.Left + 2, Rect.Top + 2, TActionObject(Actions[index]).ImageIndex);
  ActionList.Canvas.TextOut(Rect.Left + 25, Rect.Top + 2, ActionList.Items[index]);
end;

procedure TActionsForm.SaveToFileLinkClick(Sender: TObject);
var
  SaveDialog: DBSaveDialog;
  FileName: string;
  StringActions: TStrings;
  I: Integer;
begin
  SaveDialog := DBSaveDialog.Create;
  try
    SaveDialog.Filter := L('PhotoDB actions file (*.dbact)|*.dbact');
    SaveDialog.FilterIndex := 1;
    if SaveDialog.Execute then
    begin
      FileName := SaveDialog.FileName;
      if GetEXT(FileName) <> 'DBACT' then
        FileName := FileName + '.dbact';

      StringActions := TStringList.Create;
      try
        for I := 0 to Actions.Count - 1 do
          StringActions.Add(TActionObject(Actions[I]).Action);
        SaveActionsTofile(FileName, StringActions);
      finally
        F(StringActions);
      end;
    end;
  finally
    F(SaveDialog);
  end;
end;

procedure TActionsForm.LoadFromFileLinkClick(Sender: TObject);
var
  AActions: TStrings;
  OpenDialog: DBOpenDialog;
begin
  OpenDialog := DBOpenDialog.Create;
  try
    OpenDialog.Filter := L('PhotoDB actions file (*.dbact)|*.dbact');
    OpenDialog.FilterIndex := 1;
    if OpenDialog.Execute then
    begin
      AActions := TStringList.Create;
      try
        LoadActionsFromfileA(OpenDialog.FileName, AActions);
        TImageEditor(FParent).ReadActions(AActions);
      finally
        F(AActions);
      end;
    end;
  finally
    F(OpenDialog);
  end;
end;

procedure TActionsForm.Reset;
var
  I: Integer;
begin
  ActionList.Items.Clear;
  Cursor := 0;
  for I := 0 to Actions.Count - 1 do
    TObject(Actions[I]).Free;
  Actions.Clear;
end;

function TActionsForm.GetFormID: string;
begin
  Result := 'ActionsList';
end;

{ TActionObject }

constructor TActionObject.Create(AAction: string; AImageIndex: Integer);
begin
  Action := AAction;
  ImageIndex := AImageIndex;
end;

end.
