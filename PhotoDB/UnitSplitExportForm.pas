unit UnitSplitExportForm;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  Winapi.CommCtrl,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.ImgList,
  Vcl.Menus,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnPopup,
  DB,

  DropSource,
  DropTarget,
  DragDrop,
  DragDropFile,

  Dmitry.Utils.Files,
  Dmitry.Utils.Dialogs,
  Dmitry.Controls.WatermarkedEdit,

  CommonDBSupport,
  UnitDBKernel,
  UnitGroupsWork,
  UnitDBDeclare,
  UnitDBFileDialogs,
  UnitDBCommon,

  uFormInterfaces,
  uGroupTypes,
  uVistaFuncs,
  uLogger,
  uConstants,
  uDBForm,
  uShellIntegration,
  uMemory,
  uAssociations,
  uThemesUtils,
  uVCLHelpers,
  uProgramStatInfo,
  uDBUtils;

type
  TSplitExportForm = class(TDBForm, ISplitCollectionForm)
    LvMain: TListView;
    DropFileTarget1: TDropFileTarget;
    ImlListView: TImageList;
    MethodImageList: TImageList;
    PmMethod: TPopupActionBar;
    Copy1: TMenuItem;
    Cut1: TMenuItem;
    Delete1: TMenuItem;
    N1: TMenuItem;
    BtnCancel: TButton;
    BtnOk: TButton;
    BtnNew: TButton;
    PmInsertMethod: TPopupActionBar;
    Copy2: TMenuItem;
    Cut2: TMenuItem;
    PnTop: TPanel;
    BtnChooseFile: TButton;
    EdDBName: TWatermarkedEdit;
    Image1: TImage;
    lbFileName: TLabel;
    LbFoldersAndFiles: TLabel;
    LbInfo: TLabel;
    TmrStart: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure DropFileTarget1Drop(Sender: TObject; ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
    procedure BtnChooseFileClick(Sender: TObject);
    procedure LvMainAdvancedCustomDrawSubItem(Sender: TCustomListView;
      Item: TListItem; SubItem: Integer; State: TCustomDrawState;
      Stage: TCustomDrawStage; var DefaultDraw: Boolean);
    procedure LvMainContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure Copy1Click(Sender: TObject);
    procedure LvMainMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Delete1Click(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOkClick(Sender: TObject);
    procedure BtnNewClick(Sender: TObject);
    procedure LvMainResize(Sender: TObject);
    procedure LvMainKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure Cut2Click(Sender: TObject);
    procedure TmrStartTimer(Sender: TObject);
  private
    { Private declarations }
    Items: TStrings;
    FRegGroups: TGroups;
    FGroupsFounded: TGroups;
    FFiles: TStrings;
    procedure LoadLanguage;
  protected
    function GetFormID: string; override;
  public
    { Public declarations }
    procedure Execute;
  end;

implementation

uses
  ProgressActionUnit;

const
  MethodColumnWidth = 60;

{$R *.dfm}

procedure TSplitExportForm.FormCreate(Sender: TObject);
begin
  Items := TStringList.Create;
  FFiles := TStringList.Create;

  DropFileTarget1.Register(LvMain);
  LoadLanguage;

  ImageList_ReplaceIcon(MethodImageList.Handle, -1, Icons[DB_IC_COPY + 1]);
  ImageList_ReplaceIcon(MethodImageList.Handle, -1, Icons[DB_IC_CUT + 1]);
  LvMain.Columns[0].Width := MethodColumnWidth;

  PmMethod.Images := DBKernel.ImageList;
  PmInsertMethod.Images := DBKernel.ImageList;
  Copy1.ImageIndex := DB_IC_COPY;
  Cut1.ImageIndex := DB_IC_CUT;
  Copy2.ImageIndex := DB_IC_COPY;
  Cut2.ImageIndex := DB_IC_CUT;
  Delete1.ImageIndex := DB_IC_DELETE_INFO;
end;

procedure TSplitExportForm.FormDestroy(Sender: TObject);
begin
  F(Items);
  F(FFiles);
end;

function TSplitExportForm.GetFormID: string;
begin
  Result := 'SplitDatabase';
end;

procedure TSplitExportForm.Cut2Click(Sender: TObject);
var
  I, J: Integer;
  Ico: TIcon;
  MoveFiles: Boolean;
begin
  MoveFiles := Sender = Cut2;

  if FFiles.Count > 0 then
    for I := FFiles.Count - 1 downto 0 do
      for J := 0 to Items.Count - 1 do
        if AnsiLowerCase(Items[J]) = AnsiLowerCase(FFiles[I]) then
        begin
          DropFileTarget1.Files.Delete(I);
          Break;
        end;

  if FFiles.Count > 0 then
    for I := 0 to FFiles.Count - 1 do
    begin
      if DirectoryExistsSafe(FFiles[I]) then
      begin
        Ico := TIcon.Create;
        try
          Ico.Handle := ExtractAssociatedIconSafe(FFiles[I], 0);
          with LvMain.Items.Add do
          begin
            Caption := '';
            ImageIndex := Byte(MoveFiles);
            Data := Pointer(ImlListView.Count);
          end;
          Items.Add(FFiles[I]);
          ImlListView.AddIcon(Ico);
        finally
          F(Ico);
        end;
      end;
      if FileExistsSafe(FFiles[I]) then
        if IsGraphicFile(FFiles[I]) then
        begin
          Ico := TIcon.Create;
          try
            Ico.Handle := ExtractAssociatedIconSafe(FFiles[I], 0);
            with LvMain.Items.Add do
            begin
              Caption := '';
              ImageIndex := Byte(MoveFiles);
              Data := Pointer(ImlListView.Count);
            end;
            Items.Add(FFiles[I]);
            ImlListView.AddIcon(Ico);
          finally
            F(Ico);
          end;
        end;
    end;
end;

procedure TSplitExportForm.DropFileTarget1Drop(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
begin
  FFiles.Assign(DropFileTarget1.Files);
  Point := LvMain.ClientToScreen(Point);
  PmInsertMethod.Popup(Point.X, Point.Y);
end;

procedure TSplitExportForm.Execute;
begin
  Show;
end;

procedure TSplitExportForm.BtnChooseFileClick(Sender: TObject);
var
  OpenDialog: DBOpenDialog;
begin
  OpenDialog := DBOpenDialog.Create;
  try
    OpenDialog.Filter := L('PhotoDB files (*.photodb)|*.photodb|All Files|*.*');

    if OpenDialog.Execute then
      if DBKernel.TestDB(OpenDialog.FileName) then
        EdDBName.Text := OpenDialog.FileName;

  finally
    F(OpenDialog);
  end;
end;

procedure TSplitExportForm.LoadLanguage;
begin
  BeginTranslate;
  try
    BtnNew.Caption := L('New');
    Caption := L('Split Collection');
    BtnOk.Caption := L('Ok');
    BtnCancel.Caption := L('Cancel');
    lbFileName.Caption := L('Path');
    LbFoldersAndFiles.Caption := L('Files and folders') + ':';
    Copy1.Caption := L('Copy');
    Cut1.Caption := L('Cut');
    Copy2.Caption := L('Copy');
    Cut2.Caption := L('Cut');
    LvMain.Columns[0].Caption := L('Method');
    LvMain.Columns[1].Caption := L('Path');
    LbInfo.Caption := L(
      'Drag into the list files or folders with images. You can move all these images to separeted collection');
    Delete1.Caption := L('Delete');
    EdDBName.WatermarkText := L('Select a file to split the database');
  finally
    EndTranslate;
  end;
end;

procedure TSplitExportForm.LvMainAdvancedCustomDrawSubItem
  (Sender: TCustomListView; Item: TListItem; SubItem: Integer;
  State: TCustomDrawState; Stage: TCustomDrawStage; var DefaultDraw: Boolean);
var
  aRect: TRect;
begin
  ListView_GetSubItemRect(LvMain.Handle, Item.Index, SubItem, 0, @aRect);
  ImlListView.Draw(Sender.Canvas, aRect.Left, Item.Top, Integer(Item.Data));
  Sender.Canvas.TextOut(aRect.Left + 20, Item.Top, Items[Item.Index]);
end;

procedure TSplitExportForm.LvMainContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  Item: TListItem;
begin
  Item := LvMain.GetItemAt(10, MousePos.Y);
  if Item <> nil then
  begin
    PmMethod.Tag := Item.Index;
    Item.Selected := True;
    if Item.ImageIndex = 0 then
      Copy1.ExSetDefault(True)
    else
      Cut1.ExSetDefault(True);
    PmMethod.Popup(LvMain.ClientToScreen(MousePos).X,
      LvMain.ClientToScreen(MousePos).Y);
  end;
end;

procedure TSplitExportForm.Copy1Click(Sender: TObject);
begin
  LvMain.Items[PmMethod.Tag].ImageIndex := Integer((Sender as TMenuItem).Tag);
end;

procedure TSplitExportForm.LvMainMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Item: TListItem;
begin
  Item := LvMain.GetItemAt(10, Y);
  if Item <> nil then
    Item.Selected := True;
end;

procedure TSplitExportForm.Delete1Click(Sender: TObject);
var
  Index: Integer;
begin
  Index := PmMethod.Tag;
  LvMain.Items.Delete(Index);
  Items.Delete(Index);
end;

procedure TSplitExportForm.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TSplitExportForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TSplitExportForm.BtnOkClick(Sender: TObject);
var
  S, D: TDataSet;
  I, J: Integer;
  ProgressWindow: TProgressActionForm;
  fn: string;
  ItemIDsToDelete: TList;
  Groups: TGroups;

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
        if LvMain.Items[I].ImageIndex = 1 then
          ItemIDsToDelete.Add(Pointer(S.FieldByName('ID').AsInteger));
        Result := True;
        Exit;
      end;
    end;
  end;

  procedure DeleteDBItem(ID: Integer);
  var
    EventInfo: TEventValues;
    FQuery: TDataSet;
    SQL: string;
  begin
    FQuery := GetQuery;
    try
      SQL := 'DELETE FROM $DB$ WHERE ID = ' + IntToStr(ID);
      SetSQL(FQuery, SQL);
      ExecSQL(FQuery);
    finally
      FreeDS(FQuery);
    end;
    EventInfo.ID := ID;
    DBKernel.DoIDEvent(Self, ID, [EventID_Param_Delete], EventInfo);
  end;

begin
  if not DBKernel.TestDB(EdDBName.Text) then
  begin
    MessageBoxDB(Handle, L('Please select any database'), L('Error'),
      TD_BUTTON_OK, TD_ICON_ERROR);
    EdDBName.SelectAll;
    EdDBName.SetFocus;
    Exit;
  end
  else if ID_OK = MessageBoxDB(Handle, Format(L(
        'Do you really want to split the database and use this file: $nl$"%s"?$nl$WARNING: $nl$During the process all other windows will not be available!'), [EdDBName.Text]), L('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
  begin
    ProgramStatistics.DBSplitUsed;

    ItemIDsToDelete := TList.Create;
    try
      ProgressWindow := GetProgressWindow;
      try
        ProgressWindow.OneOperation := False;
        ProgressWindow.OperationCount := 3;
        ProgressWindow.OperationPosition := 1;
        ProgressWindow.DoubleBuffered := True;
        S := GetTable;
        try
          S.Open;
          ProgressWindow.xPosition := 0;
          ProgressWindow.MaxPosCurrentOperation := S.RecordCount;

          ProgressWindow.Show;
          ProgressWindow.Repaint;
          SetLength(FGroupsFounded, 0);
          D := GetTable(EdDBName.Text, DB_TABLE_IMAGES);
          try
            D.Open;
            for I := 1 to S.RecordCount do
            begin
              if RecordOk then
              begin
                D.Append;
                CopyRecordsW(S, D, False, False, '', Groups);
                D.Post;
              end;
              S.Next;
              if I mod 10 = 0 then
                ProgressWindow.Repaint;
              ProgressWindow.xPosition := I;
              if not ProgressWindow.Visible then
                Break;
            end;

            ProgressWindow.OperationPosition := 2;
            ProgressWindow.xPosition := 0;
            ProgressWindow.MaxPosCurrentOperation := Length(FGroupsFounded);
            FRegGroups := GetRegisterGroupList(True);
            try
              CreateGroupsTableW(EdDBName.Text);
              for I := 0 to Length(FGroupsFounded) - 1 do
              begin
                ProgressWindow.xPosition := I;
                for J := 0 to Length(FRegGroups) - 1 do
                  if FRegGroups[J].GroupCode = FGroupsFounded[I].GroupCode then
                  begin
                    AddGroupW(FRegGroups[J], EdDBName.Text);
                    Break;
                  end;
              end;
            finally
              FreeGroups(FRegGroups);
            end;

            ProgressWindow.OperationPosition := 3;
            ProgressWindow.xPosition := 0;
            ProgressWindow.MaxPosCurrentOperation := ItemIDsToDelete.Count;

            for I := 0 to ItemIDsToDelete.Count - 1 do
            begin
              DeleteDBItem(Integer(ItemIDsToDelete[I]));
              ProgressWindow.xPosition := I;
              if not ProgressWindow.Visible then
                Break;
            end;

          finally
            FreeDS(D);
          end;
        finally
          FreeDS(S);
        end;
      finally
        ProgressWindow.Release;
      end;

      Close;
    finally
      F(ItemIDsToDelete);
    end;
  end;
end;

procedure TSplitExportForm.BtnNewClick(Sender: TObject);
var
  SaveDialog: DBSaveDialog;
  FileName: string;
begin
  SaveDialog := DBSaveDialog.Create;
  try
    SaveDialog.Filter := L('PhotoDB files (*.photodb)|*.photodb');
    SaveDialog.FilterIndex := 1;

    if SaveDialog.Execute then
    begin
      FileName := SaveDialog.FileName;

      if SaveDialog.GetFilterIndex = 2 then
        if GetExt(FileName) <> 'DB' then
          FileName := FileName + '.db';
      if SaveDialog.GetFilterIndex = 1 then
        if GetExt(FileName) <> 'PHOTODB' then
          FileName := FileName + '.photodb';

      if FileExistsSafe(FileName) and (ID_OK <> MessageBoxDB(Handle,
          Format(L('File "%s" already exists! $nl$Replace?'),
            [FileName]), L('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING))
        then
        Exit;
      begin
        DBKernel.CreateDBbyName(FileName);
        EdDBName.Text := FileName;
      end;
    end;
  finally
    F(SaveDialog);
  end;
end;

procedure TSplitExportForm.LvMainResize(Sender: TObject);
begin
  LvMain.Columns[0].Width := MethodColumnWidth;
  LvMain.Columns[1].Width := LvMain.Width - MethodColumnWidth - 5;
end;

procedure TSplitExportForm.TmrStartTimer(Sender: TObject);
begin
  TmrStart.Enabled := False;
  EdDBName.Refresh;
end;

procedure TSplitExportForm.LvMainKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Index: Integer;
begin
  if LvMain.Selected <> nil then
  begin
    Index := LvMain.Selected.Index;
    LvMain.Items.Delete(Index);
    Items.Delete(Index);
  end;
end;

initialization
  FormInterfaces.RegisterFormInterface(ISplitCollectionForm, TSplitExportForm);

end.
