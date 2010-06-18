unit UnitActionsForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, WebLink, ImgList, Dolphin_DB, ImageHistoryUnit,
  UnitDBDeclare, UnitDBFileDialogs;

type
  TActionsForm = class(TForm)
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
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
   fParent : TForm;
   Actions : TArStrings;
   ActionImages : TArInteger;
   Cursor : integer;
   procedure LoadLanguage;
   procedure AddAction(Action : String; atype : THistoryAction);
   procedure SetParent(Parent : TForm);
   procedure LoadIcons;
   procedure Reset;
    { Public declarations }
  end;

var
  ActionsForm: TActionsForm;

//function LoadActionsFromfileA(FileName : string) : TArStrings;
//function SaveActionsTofile(FileName : string; Actions : TArstrings) : boolean;

implementation

 uses UnitDBKernel, Language, ImEditor, EffectsToolUnit;

{$R *.dfm}

procedure TActionsForm.FormCreate(Sender: TObject);
begin
 ActionList.DoubleBuffered:=true;
 LoadLanguage;
 DBKernel.RecreateThemeToForm(self);
 SaveToFileLink.LoadFromHIcon(UnitDBKernel.icons[DB_IC_SAVETOFILE+1]);
 LoadFromFileLink.LoadFromHIcon(UnitDBKernel.icons[DB_IC_LOADFROMFILE+1]);
 CloseLink.LoadFromHIcon(UnitDBKernel.icons[DB_IC_EXIT+1]);
 SaveToFileLink.SetDefault;
 LoadFromFileLink.SetDefault;
 CloseLink.SetDefault;
 ActionsImageList.BkColor:=Theme_ListColor;
 Cursor:=0;
 DBKernel.RegisterForm(self);
 SetLength(Actions,0);
 SetLength(ActionImages,0);
end;

procedure TActionsForm.CloseLinkClick(Sender: TObject);
begin
 Close;
end;

procedure TActionsForm.LoadLanguage;
begin
 Caption:=TEXT_MES_ACTIONS_FORM;
 SaveToFileLink.Text:=TEXT_MES_SAVE_TO_FILE;
 LoadFromFileLink.Text:=TEXT_MES_LOAD_FROM_FILE;
 CloseLink.Text:=TEXT_MES_CLOSE;
end;

procedure TActionsForm.AddAction(Action: String; atype : THistoryAction);
var
  ID, Filter_ID, Filter_Name, StrAction : string;
  ico, i : integer;
  EM : TEffectsManager;
begin
 if (atype=[THA_Undo]) then
 begin
  dec(Cursor);
  ActionList.Repaint;
 end;
 if (atype=[THA_Redo]) then
 begin
  inc(Cursor);
  ActionList.Repaint;
 end;

 if (atype=[THA_Add]) then
 begin
  if Cursor<>Length(Actions) then
  begin
   for i:=1 to Length(Actions)-Cursor do
   begin
    ActionList.Items.Delete(Cursor);
   end;
   Setlength(Actions,Cursor);
   Setlength(ActionImages,Cursor);
  end;

  inc(Cursor);
  ID:=Copy(Action,2,38);
  Filter_ID:=Copy(Action,42,38);
  ico:=0;
  if ID='{59168903-29EE-48D0-9E2E-7F34C913B94A}' then begin ico:=0; StrAction:=TEXT_MES_OPEN; end;
  if ID='{5AA5CA33-220E-4D1D-82C2-9195CE6DF8E4}' then begin ico:=1; StrAction:=TEXT_MES_CROP; end;
  if ID='{747B3EAF-6219-4A96-B974-ABEB1405914B}' then begin ico:=2; StrAction:=TEXT_MES_ROTATE; end;
  if ID='{29C59707-04DA-4194-9B53-6E39185CC71E}' then begin ico:=3; StrAction:=TEXT_MES_IM_RESIZE; end;
  if ID='{2AA20ABA-9205-4655-9BCE-DF3534C4DD79}' then
  begin
   EM := TEffectsManager.Create;
   EM.InitializeBaseEffects;
   Filter_Name:=EM.GetEffectNameByID(Filter_ID);
   EM.Free;
   ico:=4;
   StrAction:=TEXT_MES_EFFECTS+' ['+Filter_Name+']';
  end;
  if ID='{E20DDD6C-0E5F-4A69-A689-978763DE8A0A}' then begin ico:=5; StrAction:=TEXT_MES_COLORS; end;
  //red
  if ID='{3D2B384F-F4EB-457C-A11C-BDCE1C20FFFF}' then begin ico:=6; StrAction:=TEXT_MES_RED_EYE; end;
  //text
  if ID='{E52516CC-8235-4A1D-A135-6D84A2E298E9}' then begin ico:=7; StrAction:=TEXT_MES_TEXT; end;
  //brush
  if ID='{542FC0AD-A013-4973-90D4-E6D6E9F65D2C}' then begin ico:=8; StrAction:=TEXT_MES_BRUSH; end;
  //insert
  if ID='{CA9E5AFD-E92D-4105-8F7B-978A6EBA9D74}' then begin ico:=9; StrAction:=TEXT_MES_INSERT_IMAGE; end;

  ActionList.Items.Add(StrAction);
  SetLength(Actions,Length(Actions)+1);
  Actions[Length(Actions)-1]:=Action;
  SetLength(ActionImages,Length(ActionImages)+1);
  ActionImages[Length(ActionImages)-1]:=ico;
 end;
end;

procedure TActionsForm.SetParent(Parent: TForm);
begin
 fParent:=Parent;
end;

procedure TActionsForm.LoadIcons;
var
  Ico : TIcon;

  procedure aAddIcon(Icon : TIcon);
  begin
   Ico:=TIcon.Create;
   Ico.Assign(Icon);
   ActionsImageList.AddIcon(Ico);
   Ico.Free;
  end;

begin

 aAddIcon(TImageEditor(fParent).OpenFileLink.Icon);
 aAddIcon(TImageEditor(fParent).CropLink.Icon);
 aAddIcon(TImageEditor(fParent).RotateLink.Icon);
 aAddIcon(TImageEditor(fParent).ResizeLink.Icon);
 aAddIcon(TImageEditor(fParent).EffectsLink.Icon);
 aAddIcon(TImageEditor(fParent).ColorsLink.Icon);
 aAddIcon(TImageEditor(fParent).RedEyeLink.Icon);
 aAddIcon(TImageEditor(fParent).TextLink.Icon);
 aAddIcon(TImageEditor(fParent).BrushLink.Icon);
 aAddIcon(TImageEditor(fParent).InsertImageLink.Icon);
end;

procedure TActionsForm.ActionListDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
 if Cursor=index+1 then
 begin
  ActionList.Canvas.Brush.Color:=Theme_ListSelectColor;
  ActionList.Canvas.Pen.Color:=Theme_ListSelectColor;
 end else
 begin
  ActionList.Canvas.Brush.Color:=Theme_ListColor;
  ActionList.Canvas.Pen.Color:=Theme_ListColor;
 end;
 ActionList.Canvas.Rectangle(Rect);
 ActionList.Canvas.Pen.Color:=Theme_ListFontColor;

// if Cursor=index+1 then
 begin
  ActionList.Canvas.Pen.Color:=Theme_ListFontColor;
  if Cursor=index+1 then ActionList.Canvas.Brush.Color:=Theme_ListSelectColor else
  ActionList.Canvas.Brush.Color:=Theme_ListColor;
  ActionList.Canvas.Rectangle(Rect.Left,Rect.Top,Rect.Left+20,Rect.Top+20);
 end;
 ActionsImageList.Draw(ActionList.Canvas,Rect.Left+2,Rect.Top+2,ActionImages[Index]);
 ActionList.Canvas.Font.Color:=Theme_ListFontColor;
 ActionList.Canvas.TextOut(Rect.Left+25,Rect.Top+2,ActionList.Items[Index]);
end;



procedure TActionsForm.SaveToFileLinkClick(Sender: TObject);
var
  SaveDialog : DBSaveDialog;
  FileName : string;
begin
 SaveDialog:=DBSaveDialog.Create;
 SaveDialog.Filter:='PhotoDB Actions (*.dbact)|*.dbact';
 SaveDialog.FilterIndex:=1;
 if SaveDialog.Execute then
 begin
  FileName:=SaveDialog.FileName;
  if GetEXT(FileName)<>'DBACT' then
  FileName:=FileName+'.dbact';
  SaveActionsTofile(FileName,Actions);
 end;
 SaveDialog.Free;
end;

procedure TActionsForm.LoadFromFileLinkClick(Sender: TObject);
var
  aActions : TArStrings;
  OpenDialog : DBOpenDialog;
begin

 OpenDialog:=DBOpenDialog.Create;
 OpenDialog.Filter:='PhotoDB Actions (*.dbact)|*.dbact';
 OpenDialog.FilterIndex:=1;
 //TODO: load file list from directory actions!
 SetLength(aActions,0);
 if OpenDialog.Execute then
 begin
  aActions:=LoadActionsFromfileA(OpenDialog.FileName);
  TImageEditor(fParent).ReadActions(aActions);
 end;
 OpenDialog.Free;
end;

procedure TActionsForm.Reset;
begin
 ActionList.Items.Clear;
 Cursor:=0;
 Setlength(Actions,0);
 Setlength(ActionImages,0);
end;

procedure TActionsForm.FormDestroy(Sender: TObject);
begin
 DBKernel.UnRegisterForm(self);
end;

end.
