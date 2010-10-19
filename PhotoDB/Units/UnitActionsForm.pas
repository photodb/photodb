unit UnitActionsForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, WebLink, ImgList, Dolphin_DB, ImageHistoryUnit,
  UnitDBDeclare, UnitDBFileDialogs, uDBForm;

type
  TActionsForm = class(TDBForm)
    ActionList: TListBox;
    TopPanel: TPanel;
    SaveToFileLink: TWebLink;
    LoadFromFileLink: TWebLink;
    CloseLink: TWebLink;
    ActionsImageList: TImageList;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure CloseLinkClick(Sender: TObject);
    procedure ActionListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure SaveToFileLinkClick(Sender: TObject);
    procedure LoadFromFileLinkClick(Sender: TObject);
  private
    { Private declarations }
  protected
    function GetFormID : string; override;
  public
    FParent: TForm;
    Actions: TArStrings;
    ActionImages: TArInteger;
    Cursor: Integer;
    procedure LoadLanguage;
    procedure AddAction(Action: string; Atype: THistoryAction);
    procedure SetParent(Parent: TForm);
    procedure LoadIcons;
    procedure Reset;
    { Public declarations }
  end;

var
  ActionsForm: TActionsForm;

implementation

 uses UnitDBKernel, ImEditor, EffectsToolUnit;

{$R *.dfm}

procedure TActionsForm.FormCreate(Sender: TObject);
begin
  ActionList.DoubleBuffered := True;
  LoadLanguage;
  SaveToFileLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_SAVETOFILE + 1]);
  LoadFromFileLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_LOADFROMFILE + 1]);
  CloseLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_EXIT + 1]);
  ActionsImageList.BkColor := ClWindow;
  Cursor := 0;
  SetLength(Actions, 0);
  SetLength(ActionImages, 0);
end;

procedure TActionsForm.CloseLinkClick(Sender: TObject);
begin
  Close;
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
begin
  if (Atype = [THA_Undo]) then
  begin
    Dec(Cursor);
    ActionList.Repaint;
  end;
  if (Atype = [THA_Redo]) then
  begin
    Inc(Cursor);
    ActionList.Repaint;
  end;

  if (Atype = [THA_Add]) then
  begin
    if Cursor <> Length(Actions) then
    begin
      for I := 1 to Length(Actions) - Cursor do
        ActionList.Items.Delete(Cursor);

      Setlength(Actions, Cursor);
      Setlength(ActionImages, Cursor);
    end;

    Inc(Cursor);
    ID := Copy(Action, 2, 38);
    Filter_ID := Copy(Action, 42, 38);
    Ico := 0;
    if ID = '{59168903-29EE-48D0-9E2E-7F34C913B94A}' then
    begin
      Ico := 0;
      StrAction := L('Open');
    end;
    if ID = '{5AA5CA33-220E-4D1D-82C2-9195CE6DF8E4}' then
    begin
      Ico := 1;
      StrAction := L('Crop');
    end;
    if ID = '{747B3EAF-6219-4A96-B974-ABEB1405914B}' then
    begin
      Ico := 2;
      StrAction := L('Rotate');
    end;
    if ID = '{29C59707-04DA-4194-9B53-6E39185CC71E}' then
    begin
      Ico := 3;
      StrAction := L('Resize');
    end;
    if ID = '{2AA20ABA-9205-4655-9BCE-DF3534C4DD79}' then
    begin
      EM := TEffectsManager.Create;
      EM.InitializeBaseEffects;
      Filter_Name := EM.GetEffectNameByID(Filter_ID);
      EM.Free;
      Ico := 4;
      StrAction := L('Effects') + ' [' + Filter_Name + ']';
    end;
    if ID = '{E20DDD6C-0E5F-4A69-A689-978763DE8A0A}' then
    begin
      Ico := 5;
      StrAction := L('Colors');
    end;
    // red
    if ID = '{3D2B384F-F4EB-457C-A11C-BDCE1C20FFFF}' then
    begin
      Ico := 6;
      StrAction := L('Red eye');
    end;
    // text
    if ID = '{E52516CC-8235-4A1D-A135-6D84A2E298E9}' then
    begin
      Ico := 7;
      StrAction := L('Text');
    end;
    // brush
    if ID = '{542FC0AD-A013-4973-90D4-E6D6E9F65D2C}' then
    begin
      Ico := 8;
      StrAction := L('Brush');
    end;
    // insert
    if ID = '{CA9E5AFD-E92D-4105-8F7B-978A6EBA9D74}' then
    begin
      Ico := 9;
      StrAction := L('Insert image');
    end;

    ActionList.Items.Add(StrAction);
    SetLength(Actions, Length(Actions) + 1);
    Actions[Length(Actions) - 1] := Action;
    SetLength(ActionImages, Length(ActionImages) + 1);
    ActionImages[Length(ActionImages) - 1] := Ico;
  end;
end;

procedure TActionsForm.SetParent(Parent: TForm);
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

procedure TActionsForm.ActionListDrawItem(Control: TWinControl; index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  if Cursor = index + 1 then
  begin
    ActionList.Canvas.Brush.Color := clHighlight;
    ActionList.Canvas.Pen.Color := clHighlight;
  end
  else
  begin
    ActionList.Canvas.Brush.Color := ClWindow;
    ActionList.Canvas.Pen.Color := ClWindow;
  end;
  ActionList.Canvas.Rectangle(Rect);
  ActionList.Canvas.Pen.Color := clWindowText;

  // if Cursor=index+1 then
  begin
    ActionList.Canvas.Pen.Color := clWindowText;
    if Cursor = index + 1 then
      ActionList.Canvas.Brush.Color := clHighlight
    else
      ActionList.Canvas.Brush.Color := ClWindow;
    ActionList.Canvas.Rectangle(Rect.Left, Rect.Top, Rect.Left + 20, Rect.Top + 20);
  end;
  ActionsImageList.Draw(ActionList.Canvas, Rect.Left + 2, Rect.Top + 2, ActionImages[index]);
  ActionList.Canvas.Font.Color := clWindowText;
  ActionList.Canvas.TextOut(Rect.Left + 25, Rect.Top + 2, ActionList.Items[index]);
end;

procedure TActionsForm.SaveToFileLinkClick(Sender: TObject);
var
  SaveDialog: DBSaveDialog;
  FileName: string;
begin
  SaveDialog := DBSaveDialog.Create;
  try
    SaveDialog.Filter := 'PhotoDB Actions (*.dbact)|*.dbact';
    SaveDialog.FilterIndex := 1;
    if SaveDialog.Execute then
    begin
      FileName := SaveDialog.FileName;
      if GetEXT(FileName) <> 'DBACT' then
        FileName := FileName + '.dbact';
      SaveActionsTofile(FileName, Actions);
    end;
  finally
    SaveDialog.Free;
  end;
end;

procedure TActionsForm.LoadFromFileLinkClick(Sender: TObject);
var
  AActions: TArStrings;
  OpenDialog: DBOpenDialog;
begin

  OpenDialog := DBOpenDialog.Create;
  OpenDialog.Filter := 'PhotoDB Actions (*.dbact)|*.dbact';
  OpenDialog.FilterIndex := 1;
  // TODO: load file list from directory actions!
  SetLength(AActions, 0);
  if OpenDialog.Execute then
  begin
    AActions := LoadActionsFromfileA(OpenDialog.FileName);
    TImageEditor(FParent).ReadActions(AActions);
  end;
  OpenDialog.Free;
end;

procedure TActionsForm.Reset;
begin
  ActionList.Items.Clear;
  Cursor := 0;
  Setlength(Actions, 0);
  Setlength(ActionImages, 0);
end;

function TActionsForm.GetFormID: string;
begin
  Result := 'ActionsList';
end;

end.
