unit UnitSplitExportForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, DropSource, DropTarget, Dolphin_DB,
  Language, acDlgSelect, ImgList, Menus, DB, UnitGroupsWork, win32crc, uFileUtils,
  DragDrop, DragDropFile, uVistaFuncs, UnitDBDeclare, UnitDBFileDialogs, uLogger,
  UnitDBCommon, uConstants, uDBForm, uShellIntegration, uMemory, WatermarkedEdit;

type
  TSplitExportForm = class(TDBForm)
    Panel1: TPanel;
    ListView1: TListView;
    Image1: TImage;
    Label1: TLabel;
    DropFileTarget1: TDropFileTarget;
    Label2: TLabel;
    Panel2: TPanel;
    Panel3: TPanel;
    BtnOk: TButton;
    BtnCancel: TButton;
    ImageList1: TImageList;
    MethodImageList: TImageList;
    PopupMenu1: TPopupMenu;
    Copy1: TMenuItem;
    Cut1: TMenuItem;
    Delete1: TMenuItem;
    N1: TMenuItem;
    DestroyTimer: TTimer;
    Panel4: TPanel;
    Label3: TLabel;
    Panel5: TPanel;
    CheckBox1: TCheckBox;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Edit1: TWatermarkedEdit;
    Button1: TButton;
    BtnNew: TButton;
    procedure FormCreate(Sender: TObject);
    procedure DropFileTarget1Drop(Sender: TObject; ShiftState: TShiftState;
      Point: TPoint; var Effect: Integer);
    procedure Button1Click(Sender: TObject);
    procedure ListView1AdvancedCustomDrawSubItem(Sender: TCustomListView;
      Item: TListItem; SubItem: Integer; State: TCustomDrawState;
      Stage: TCustomDrawStage; var DefaultDraw: Boolean);
    procedure ListView1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Copy1Click(Sender: TObject);
    procedure ListView1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Delete1Click(Sender: TObject);
    procedure DestroyTimerTimer(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOkClick(Sender: TObject);
    procedure BtnNewClick(Sender: TObject);
    procedure ListView1Resize(Sender: TObject);
    procedure ListView1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    Items: TStrings;
    FRegGroups: TGroups;
    FGroupsFounded: TGroups;
    procedure LoadLanguage;
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    procedure CopyRecordsW(OutTable, InTable: TDataSet);
  end;

procedure SplitDB;

var
  Split_Opened: Boolean = False;
  SplitExportForm: TSplitExportForm;

implementation

uses UnitDBKernel, CommCtrl, CommonDBSupport, ProgressActionUnit;

{$R *.dfm}

procedure SplitDB;
begin
  if Split_Opened then
  begin
    SplitExportForm.Show;
    Exit;
  end;
  Split_Opened := True;
  Application.CreateForm(TSplitExportForm, SplitExportForm);
  SplitExportForm.Show;
  Split_Opened := True;
end;

procedure TSplitExportForm.FormCreate(Sender: TObject);
begin
  Items := TStringList.Create;

  DropFileTarget1.register(ListView1);
  LoadLanguage;
  MethodImageList.BkColor := ClWindow;
  ImageList1.BkColor := ClWindow;

  ImageList_ReplaceIcon(MethodImageList.Handle, -1, Icons[DB_IC_COPY + 1]);
  ImageList_ReplaceIcon(MethodImageList.Handle, -1, Icons[DB_IC_CUT + 1]);

  PopupMenu1.Images := DBKernel.ImageList;
  Copy1.ImageIndex := DB_IC_COPY;
  Cut1.ImageIndex := DB_IC_CUT;
  Delete1.ImageIndex := DB_IC_DELETE_INFO;
end;

procedure TSplitExportForm.FormDestroy(Sender: TObject);
begin
  F(Items);
end;

function TSplitExportForm.GetFormID: string;
begin
  Result := 'SplitDatabase';
end;

procedure TSplitExportForm.DropFileTarget1Drop(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
var
  I, J: Integer;
  Ico: TIcon;
begin

  if DropFileTarget1.Files.Count > 0 then
    for I := DropFileTarget1.Files.Count - 1 downto 0 do
      for J := 0 to Items.Count - 1 do
        if AnsiLowerCase(Items[J]) = AnsiLowerCase(DropFileTarget1.Files[I]) then
        begin
          DropFileTarget1.Files.Delete(I);
          Break;
        end;

  if DropFileTarget1.Files.Count > 0 then
    for I := 0 to DropFileTarget1.Files.Count - 1 do
    begin
      if DirectoryExists(DropFileTarget1.Files[I]) then
      begin
        Ico := TIcon.Create;
        try
          Ico.Handle := ExtractAssociatedIconSafe(DropFileTarget1.Files[I], 0);
          with ListView1.Items.Add do
          begin
            Caption := '';
            ImageIndex := Byte(CheckBox1.Checked);
            Data := Pointer(ImageList1.Count);
          end;
          Items.Add(DropFileTarget1.Files[I]);
          ImageList1.AddIcon(Ico);
        finally
          F(Ico);
        end;
      end;
      if FileExists(DropFileTarget1.Files[I]) then
        if ExtInMask(SupportedExt, GetExt(DropFileTarget1.Files[I])) then
        begin
          Ico := TIcon.Create;
          try
            Ico.Handle := ExtractAssociatedIconSafe(DropFileTarget1.Files[I], 0);
            with ListView1.Items.Add do
            begin
              Caption := ''; // IntToStr(Index+1);
              ImageIndex := Byte(CheckBox1.Checked);
              Data := Pointer(ImageList1.Count);
            end;
            Items.Add(DropFileTarget1.Files[I]);
            ImageList1.AddIcon(Ico);
          finally
            F(Ico);
          end;
        end;
    end;
end;

procedure TSplitExportForm.Button1Click(Sender: TObject);
var
  OpenDialog: DBOpenDialog;
begin
  OpenDialog := DBOpenDialog.Create;
  try
    OpenDialog.Filter := 'PhotoDB files (*.photodb)|*.photodb|All Files|*.*';

    if OpenDialog.Execute then
      if DBKernel.TestDB(OpenDialog.FileName) then
        Edit1.Text := OpenDialog.FileName;

  finally
    F(OpenDialog);
  end;
end;

procedure TSplitExportForm.LoadLanguage;
begin
  BeginTranslate;
  try
    BtnNew.Caption := TEXT_MES_NEW_W;
    Caption := TEXT_MES_SPLIT_DB_CAPTION;
    BtnOk.Caption := L('Ok');
    BtnCancel.Caption := L('Cancel');
    CheckBox1.Caption := TEXT_MES_DELETE_RECORDS_AFTER_FINISH;
    Label2.Caption := TEXT_MES_PATH;
    Label3.Caption := TEXT_MES_FILES_AND_FOLDERS;
    Copy1.Caption := L('Copy');
    Cut1.Caption := L('Cut');
    ListView1.Columns[0].Caption := TEXT_MES_METHOD;
    ListView1.Columns[1].Caption := TEXT_MES_PATH;
    Label1.Caption := TEXT_MES_SPLIT_DB_INFO;
    Delete1.Caption := L('Delete');
    Edit1.WatermarkText := L('Select a file to split the database');
  finally
    EndTranslate;
  end;
end;

procedure TSplitExportForm.ListView1AdvancedCustomDrawSubItem(
  Sender: TCustomListView; Item: TListItem; SubItem: Integer;
  State: TCustomDrawState; Stage: TCustomDrawStage;
  var DefaultDraw: Boolean);
var
  aRect : TRect;
begin
 ListView_GetSubItemRect(ListView1.Handle,Item.Index,SubItem,0,@aRect);
 ImageList1.Draw(Sender.Canvas,aRect.Left,Item.Top,Integer(Item.data));
 Sender.Canvas.TextOut(aRect.Left+20, Item.Top,Items[Item.Index]);

end;

procedure TSplitExportForm.ListView1ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  item : TListItem;
begin
 item:=ListView1.GetItemAt(10,MousePos.y);
 if item<>nil then
 begin
  PopupMenu1.Tag:=item.Index;
  item.Selected:=true;
  if item.ImageIndex=0 then Copy1.Default:=true else Cut1.Default:=true;
  PopupMenu1.Popup(ListView1.ClientToScreen(MousePos).X,ListView1.ClientToScreen(MousePos).Y);
 end;
end;

procedure TSplitExportForm.Copy1Click(Sender: TObject);
begin                //
 ListView1.Items[PopupMenu1.Tag].ImageIndex:=Integer((Sender as TMenuItem).Tag);
end;

procedure TSplitExportForm.ListView1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  item : TListItem;
begin
 item:=ListView1.GetItemAt(10,y);
 if item<>nil then
 begin
  item.Selected:=true;
 end;
end;

procedure TSplitExportForm.Delete1Click(Sender: TObject);
var
  Index: Integer;
begin
  index := PopupMenu1.Tag;
  ListView1.Items.Delete(index);
  Items.Delete(index);
end;

procedure TSplitExportForm.DestroyTimerTimer(Sender: TObject);
begin
  DestroyTimer.Enabled := False;
  Release;
  Split_Opened := False;
end;

procedure TSplitExportForm.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TSplitExportForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DestroyTimer.Enabled := True;
end;

procedure TSplitExportForm.BtnOkClick(Sender: TObject);
var
  S, D : TDataSet;
  i, j : integer;
  ProgressWindow : TProgressActionForm;
  fn : string;
  ID_Delete : array of integer;

  function RecordOk: Boolean;
  var
    I: Integer;
  begin
    Result := False;
    Fn := S.FieldByName('FFileName').AsString;
    for I := 0 to Items.Count - 1 do
    begin
      if AnsiUpperCase(Copy(Fn, 1, Length(Items[I]))) = AnsiUpperCase(Items[I]) then
      begin
        if ListView1.Items[I].ImageIndex = 1 then
        begin
          SetLength(ID_Delete, Length(ID_Delete) + 1);
          ID_Delete[Length(ID_Delete) - 1] := S.FieldByName('ID').AsInteger;
        end;
        Result := True;
        Exit;
      end;
    end;
  end;

  function RecordDelOk: Boolean;
  var
    I, Id: Integer;
  begin
    Result := False;
    Id := S.FieldByName('ID').AsInteger;
    for I := 0 to Length(ID_Delete) - 1 do
      if ID_Delete[I] = Id then
      begin
        Result := True;
        Exit;
      end;
  end;

begin
 if not DBKernel.TestDB(Edit1.Text) then
 begin
  MessageBoxDB(Handle,TEXT_MES_SELECT_DB_PLEASE,L('Error'),TD_BUTTON_OK,TD_ICON_ERROR);
  Edit1.SelectAll;
  Edit1.SetFocus;
  exit;
 end else
 if ID_OK=MessageBoxDB(Handle,Format(TEXT_MES_REALLY_SPLIT_IN_DB_F,[Edit1.Text]),L('Warning'),TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then
 begin
  SetLength(ID_Delete,0);
  ProgressWindow := GetProgressWindow;
  ProgressWindow.OneOperation:=false;
  ProgressWindow.OperationCount:=3;
  ProgressWindow.OperationPosition:=1;
  ProgressWindow.DoubleBuffered:=true;
  S:=GetTable;
  S.Open;
  ProgressWindow.xPosition:=0;
  ProgressWindow.MaxPosCurrentOperation:=S.RecordCount;

  ProgressWindow.Show;
  ProgressWindow.Repaint;
  Setlength(FGroupsFounded,0);
  D:=GetTable(Edit1.Text,DB_TABLE_IMAGES);
  D.Open;
  for i:=1 to S.RecordCount do
  begin
   if RecordOk then
   begin
    D.Append;
    CopyRecordsW(S,D);
    D.Post;
   end;
   S.Next;
   if i mod 10=0 then
   ProgressWindow.Repaint;
   ProgressWindow.xPosition:=i;
   if not ProgressWindow.Visible then Break;
  end;

  ProgressWindow.OperationPosition:=2;
  ProgressWindow.xPosition:=0;
  ProgressWindow.MaxPosCurrentOperation:=length(FGroupsFounded);
  FRegGroups:=GetRegisterGroupList(True);
  CreateGroupsTableW(Edit1.Text);
   for i:=0 to length(FGroupsFounded)-1 do
   begin
    ProgressWindow.xPosition:=i;
    for j:=0 to length(FRegGroups)-1 do
    if FRegGroups[j].GroupCode=FGroupsFounded[i].GroupCode then
    begin
     AddGroupW(FRegGroups[j],Edit1.Text);
     Break;
    end;
   end;

  ProgressWindow.OperationPosition:=3;
  ProgressWindow.xPosition:=0;
  ProgressWindow.MaxPosCurrentOperation:=S.RecordCount;
  S.Last;
  for i:=S.RecordCount downto 1 do
  begin
   if RecordDelOk then
   begin
    S.Delete;
   end;
   S.Prior;
   if S.Bof then break;
   if i mod 10=0 then
   ProgressWindow.Repaint;
   ProgressWindow.xPosition:=S.RecordCount-i;
   if not ProgressWindow.Visible then Break;
  end;

  ProgressWindow.Release;

  Close;
 end;

end;

procedure TSplitExportForm.BtnNewClick(Sender: TObject);
var
  SaveDialog : DBSaveDialog;
  FileName : string;
begin
  SaveDialog:=DBSaveDialog.Create;
  SaveDialog.Filter:='PhotoDB files (*.photodb)|*.photodb';
  SaveDialog.FilterIndex:=1;

 if SaveDialog.Execute then
 begin
  FileName:=SaveDialog.FileName;

  if SaveDialog.GetFilterIndex=2 then
  if GetExt(FileName)<>'DB' then FileName:=FileName+'.db';
  if SaveDialog.GetFilterIndex=1 then
  if GetExt(FileName)<>'PHOTODB' then FileName:=FileName+'.photodb';

  if FileExists(FileName) and (ID_OK<>MessageBoxDB(Handle,Format(TEXT_MES_FILE_EXISTS_1,[FileName]),L('Warning'),TD_BUTTON_OKCANCEL,TD_ICON_WARNING)) then exit;
  begin
   DBKernel.CreateDBbyName(FileName);
   Edit1.Text:=FileName;
  end;
 end;
 SaveDialog.Free;
end;

procedure TSplitExportForm.CopyRecordsW(OutTable, InTable: TDataSet);
var
  S, folder : String;
  crc : Cardinal;
begin
try
 InTable.FieldByName('Name').AsString:=OutTable.FieldByName('Name').AsString;
 InTable.FieldByName('FFileName').AsString:=OutTable.FieldByName('FFileName').AsString;
 InTable.FieldByName('Comment').AsString:=OutTable.FieldByName('Comment').AsString;
 InTable.FieldByName('DateToAdd').AsDateTime:=OutTable.FieldByName('DateToAdd').AsDateTime;
 InTable.FieldByName('Owner').AsString:=OutTable.FieldByName('Owner').AsString;
 InTable.FieldByName('Rating').AsInteger:=OutTable.FieldByName('Rating').AsInteger;
 InTable.FieldByName('Thum').AsVariant:=OutTable.FieldByName('Thum').AsVariant;
 InTable.FieldByName('FileSize').AsInteger:=OutTable.FieldByName('FileSize').AsInteger;
 InTable.FieldByName('KeyWords').AsString:=OutTable.FieldByName('KeyWords').AsString;
 InTable.FieldByName('StrTh').AsString:=OutTable.FieldByName('StrTh').AsString;
 If fileexists(InTable.FieldByName('FFileName').AsString) then
 InTable.FieldByName('Attr').AsInteger:=db_attr_norm else
 InTable.FieldByName('Attr').AsInteger:=db_attr_not_exists;
 InTable.FieldByName('Attr').AsInteger:=OutTable.FieldByName('Attr').AsInteger;
 InTable.FieldByName('Collection').AsString:=OutTable.FieldByName('Collection').AsString;
 if OutTable.FindField('Groups')<>nil then
 begin
  S:=OutTable.FieldByName('Groups').AsString;
  AddGroupsToGroups(FGroupsFounded,EnCodeGroups(S));
  InTable.FieldByName('Groups').AsString:=S;
 end;
 InTable.FieldByName('Groups').AsString:=OutTable.FieldByName('Groups').AsString;
 InTable.FieldByName('Access').AsInteger:=OutTable.FieldByName('Access').AsInteger;
 InTable.FieldByName('Width').AsInteger:=OutTable.FieldByName('Width').AsInteger;
 InTable.FieldByName('Height').AsInteger:=OutTable.FieldByName('Height').AsInteger;
 InTable.FieldByName('Colors').AsInteger:=OutTable.FieldByName('Colors').AsInteger;
 InTable.FieldByName('Rotated').AsInteger:=OutTable.FieldByName('Rotated').AsInteger;
 InTable.FieldByName('IsDate').AsBoolean:=OutTable.FieldByName('IsDate').AsBoolean;
 if OutTable.FindField('Include')<>nil then
 InTable.FieldByName('Include').AsBoolean:=OutTable.FieldByName('Include').AsBoolean;
 if OutTable.FindField('Links')<>nil then
 InTable.FieldByName('Links').AsString:=OutTable.FieldByName('Links').AsString;
 if OutTable.FindField('aTime')<>nil then
 InTable.FieldByName('aTime').AsDateTime:=OutTable.FieldByName('aTime').AsDateTime;
 if OutTable.FindField('IsTime')<>nil then
 InTable.FieldByName('IsTime').AsBoolean:=OutTable.FieldByName('IsTime').AsBoolean;
 if InTable.Fields.FindField('FolderCRC')<>nil then
 begin

      if OutTable.Fields.FindField('FolderCRC') <> nil then
        InTable.FieldByName('FolderCRC').AsInteger := OutTable.FieldByName('FolderCRC').AsInteger
      else
      begin
        Folder := ExtractFilePath(OutTable.FieldByName('FFileName').AsString);
        AnsiLowerCase(Folder);
        CalcStringCRC32(AnsiLowerCase(Folder), Crc);
        InTable.FieldByName('FolderCRC').AsInteger := Crc;
      end;
    end;

  except
    on E: Exception do
      EventLog(':CopyRecordsW() throw exception: ' + E.message);
  end;
end;

procedure TSplitExportForm.ListView1Resize(Sender: TObject);
begin
  ListView1.Columns[1].Width := ListView1.Width - ListView1.Columns[0].Width - 5;
end;

procedure TSplitExportForm.ListView1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Index: Integer;
begin
  if ListView1.Selected <> nil then
  begin
    Index := ListView1.Selected.Index;
    ListView1.Items.Delete(Index);
    Items.Delete(Index);
  end;
end;

end.
