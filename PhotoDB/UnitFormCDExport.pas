unit UnitFormCDExport;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  Winapi.ShellApi,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.Menus,
  Vcl.ImgList,
  Vcl.Buttons,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnPopup,
  Vcl.AppEvnts,
  Vcl.Imaging.pngimage,

  DragDrop,
  DropTarget,

  Dmitry.Controls.Base,
  Dmitry.Controls.ComboBoxExDB,
  Dmitry.Controls.WatermarkedEdit,
  Dmitry.Controls.LoadingSign,

  DragDropFile,
  UnitCDMappingSupport,
  UnitDBFileDialogs,

  uAssociatedIcons,
  uDBIcons,
  uMemory,
  uCDMappingTypes,
  uDBForm,
  uDBContext,
  uDBManager,
  uShellIntegration,
  uRuntime,
  uConstants,
  uTranslateUtils,
  uProgramStatInfo,
  uFormInterfaces;

type
  TFormCDExport = class(TDBForm, ICDExportForm)
    CDListView: TListView;
    PanelBottom: TPanel;
    PanelTop: TPanel;
    ComboBoxPathList: TComboBoxExDB;
    ButtonAddItems: TButton;
    ButtonRemoveItems: TButton;
    ButtonCreateDirectory: TButton;
    LabelInfo: TLabel;
    Image1: TImage;
    LabelCDLabel: TLabel;
    EditLabel: TWatermarkedEdit;
    LabelPath: TLabel;
    ButtonExport: TButton;
    CheckBoxDeleteFiles: TCheckBox;
    CheckBoxModifyDB: TCheckBox;
    PopupMenuListView: TPopupActionBar;
    Copy1: TMenuItem;
    Cut1: TMenuItem;
    Paste1: TMenuItem;
    N1: TMenuItem;
    Delete1: TMenuItem;
    N2: TMenuItem;
    Open1: TMenuItem;
    ImageListIcons: TImageList;
    LabelExportDirectory: TLabel;
    LabelExportSize: TLabel;
    EditCDSize: TEdit;
    EditExportDirectory: TEdit;
    ButtonChooseDirectory: TButton;
    DestroyTimer: TTimer;
    DropFileTarget1: TDropFileTarget;
    N3: TMenuItem;
    Rename1: TMenuItem;
    N4: TMenuItem;
    AddItems1: TMenuItem;
    ApplicationEvents1: TApplicationEvents;
    CheckBoxCreatePortableDB: TCheckBox;
    LsMain: TLoadingSign;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DestroyTimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CDListViewDblClick(Sender: TObject);
    procedure ButtonRemoveItemsClick(Sender: TObject);
    procedure DropFileTarget1Drop(Sender: TObject; ShiftState: TShiftState;
      APoint: TPoint; var Effect: Integer);
    procedure ButtonCreateDirectoryClick(Sender: TObject);
    procedure ButtonChooseDirectoryClick(Sender: TObject);
    procedure ButtonAddItemsClick(Sender: TObject);
    procedure ComboBoxPathListSelect(Sender: TObject);
    procedure ButtonExportClick(Sender: TObject);
    procedure Rename1Click(Sender: TObject);
    procedure CDListViewEditing(Sender: TObject; Item: TListItem; var AllowEdit: Boolean);
    procedure CDListViewEdited(Sender: TObject; Item: TListItem; var S: String);
    procedure PopupMenuListViewPopup(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Cut1Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
    procedure Open1Click(Sender: TObject);
  private
    { Private declarations }
    FContext: IDBContext;
    Mapping: TCDIndexMapping;
    procedure LoadLanguage;
  protected
    { Protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
    function GetFormID: string;override;
  public
    { Public declarations }
    procedure Execute;
    procedure DrawCurrentDirectory(ListView: TListView);
    procedure OnThreadEnd(Sender: TObject);
    procedure EnableControls(Value: Boolean);
  end;

procedure DoCDExport;

implementation

uses
  FormManegerUnit,
  UnitCDExportThread,
  uManagerExplorer;

{$R *.dfm}

procedure DoCDExport;
var
  FormCDExport: TFormCDExport;
begin
  Application.CreateForm(TFormCDExport, FormCDExport);
  FormCDExport.Execute;
end;

{ TFormCDExport }

procedure TFormCDExport.Execute;
begin
  Show;
end;

procedure TFormCDExport.FormCreate(Sender: TObject);
begin
  FContext := DBManager.DBContext;

  CDListView.DoubleBuffered := True;

  Mapping := TCDIndexMapping.Create(FContext);
  EditCDSize.Text := SizeInText(Mapping.GetCDSize);

  DropFileTarget1.Register(CDListView);
  PopupMenuListView.Images := Icons.ImageList;
  RegisterMainForm(Self);
  ComboBoxPathList.ItemIndex := 0;
  LoadLanguage;
  Open1.ImageIndex := DB_IC_SHELL;
  Copy1.ImageIndex := DB_IC_COPY;
  Cut1.ImageIndex := DB_IC_CUT;
  Paste1.ImageIndex := DB_IC_PASTE;
  Delete1.ImageIndex := DB_IC_DELETE_INFO;
  Rename1.ImageIndex := DB_IC_RENAME;
  AddItems1.ImageIndex := DB_IC_NEW;
end;

procedure TFormCDExport.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Export photos to a removable disk');
    LabelInfo.Caption := L('This dialog will help you to transfer a portion of photos stored on your hard drive - on CD \ DVD drive.$nl$' + 'Thus the information about the photographs will remain in the database, and if you want to see photos of the program will ask you to insert the appropriate disc.$nl$' + 'Program does not record data on the disc, but only generates a folder designed to write to the disk. $nl$To write to disk data files using special software!');
    LabelCDLabel.Caption := L('Create CD\DVD image with name') + ':';
    EditLabel.WatermarkText := L('Name of drive');
    LabelPath.Caption := L('Location') + ':';
    ButtonAddItems.Caption := L('Add');
    ButtonRemoveItems.Caption := L('Delete');
    ButtonCreateDirectory.Caption := L('Create directory');
    CDListView.Columns[0].Caption := L('File name');
    CDListView.Columns[1].Caption := L('File size');
    CDListView.Columns[2].Caption := L('Collection ID');
    ButtonExport.Caption := L('Start export');
    LabelExportDirectory.Caption := L('Directory for export') + ':';
    ButtonChooseDirectory.Caption := L('Choose directory');
    Open1.Caption := L('Open');
    Copy1.Caption := L('Copy');
    Cut1.Caption := L('Cut');
    Paste1.Caption := L('Paste');
    Delete1.Caption := L('Delete');
    LabelExportSize.Caption := L('The size of files for export') + ':';
    Rename1.Caption := L('Rename');
    AddItems1.Caption := L('Add');
    CheckBoxDeleteFiles.Caption := L('Delete original files after a successful export');
    CheckBoxModifyDB.Caption := L('Adjust the information in the database after a successful export');
    CheckBoxCreatePortableDB.Caption := L('Create portable database on disk');
  finally
    EndTranslate;
  end;
end;

procedure TFormCDExport.FormDestroy(Sender: TObject);
begin
  UnRegisterMainForm(Self);
  F(Mapping);
  FContext := nil;
end;

function TFormCDExport.GetFormID: string;
begin
  Result := 'CDExport';
end;

procedure TFormCDExport.DestroyTimerTimer(Sender: TObject);
begin
  DestroyTimer.Enabled := False;
  Release;
end;

procedure TFormCDExport.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DestroyTimer.Enabled := True;
end;

procedure TFormCDExport.DrawCurrentDirectory(ListView: TListView);
var
  Level: TCDIndexMappingDirectory;
  I, ID: Integer;
  Item: TListItem;
  Size: Int64;
  PathList: TStrings;
  Icon: TIcon;
begin
  ListView.Items.BeginUpdate;
  try
    ListView.Items.Clear;
    ImageListIcons.Clear;
    Level := Mapping.CurrentLevel;
    if Level.Parent <> nil then
    begin
      Item := ListView.Items.Add;
      Item.Caption := '[..]';
      Item.Data := nil;
      Icon := TAIcons.Instance.GetIconByExt('', True, 16, True);
      try
        Item.ImageIndex := ImageListIcons.AddIcon(Icon);
      finally
        F(Icon);
      end;
    end;
    for I := 0 to Level.Count - 1 do
    begin
      Item := ListView.Items.Add;
      Item.Caption := Level[I].Name;
      Item.Data := Level[I];
      Size := Mapping.GetCDSizeWithDirectory(Level[I]);
      if Size > 0 then
        Item.SubItems.Add(SizeInText(Size))
      else
        Item.SubItems.Add('');
      ID := Level[I].DB_ID;
      if ID > 0 then
        Item.SubItems.Add(IntToStr(ID))
      else
      begin
        if Mapping.DirectoryHasDBFiles(Item.Data) then
          Item.SubItems.Add('+')
        else
          Item.SubItems.Add('');
      end;

      if Level[I].IsFile then
        Icon := TAIcons.Instance.GetIconByExt(Level[I].RealFileName, False, 16, False)
      else
        Icon := TAIcons.Instance.GetIconByExt('', True, 16, True);
      try
        Item.ImageIndex := ImageListIcons.AddIcon(Icon);
      finally
        F(Icon);
      end;
    end;
  finally
    ListView.Items.EndUpdate;
  end;
  EditCDSize.Text := SizeInText(Mapping.GetCDSize);
  ComboBoxPathList.Items.Clear;
  PathList := Mapping.GetCurrentUpperDirectories;
  try
    for I := PathList.Count - 1 downto 0 do
      ComboBoxPathList.Items.Add(PathList[I]);
    ComboBoxPathList.ItemIndex := 0;
  finally
    F(PathList);
  end;
end;

procedure TFormCDExport.CDListViewDblClick(Sender: TObject);
var
  Item: TListItem;
begin
  Item := CDListView.Selected;
  if Item = nil then
    Exit;

  if Item.Data = nil then
  begin
    Mapping.GoUp;
    DrawCurrentDirectory(CDListView);
    Exit;
  end;

  if Item.Data <> nil then
    if not TCDIndexMappingDirectory(Item.Data).IsFile then
    begin
      Mapping.SelectDirectory(TCDIndexMappingDirectory(Item.Data).Name);
      DrawCurrentDirectory(CDListView);
    end else
      Open1Click(Sender);
end;

procedure TFormCDExport.ButtonRemoveItemsClick(Sender: TObject);
var
  I: Integer;
  Item: TCDIndexMappingDirectory;
begin
  for I := CDListView.Items.Count - 1 downto 0 do
    if CDListView.Items[I].Selected then
    begin
      Item := CDListView.Items[I].Data;
      if Item <> nil then
      begin
        if Item.IsFile then
          Mapping.DeleteFile(Item.name)
        else
          Mapping.DeleteDirectory(Item.name);
      end;
      Mapping.ClearClipBoard;
    end;
  DrawCurrentDirectory(CDListView);
end;

procedure TFormCDExport.DropFileTarget1Drop(Sender: TObject;
  ShiftState: TShiftState; APoint: TPoint; var Effect: Integer);
var
  FileList: TStrings;
begin
  FileList := TStringList.Create;
  try
    DropFileTarget1.Files.AssignTo(FileList);
    Mapping.AddRealItemsToCurrentDirectory(FileList);
    DrawCurrentDirectory(CDListView);
  finally
    F(FileList);
  end;
end;

procedure TFormCDExport.ButtonCreateDirectoryClick(Sender: TObject);
var
  DirectoryName: string;
begin
  DirectoryName := L('New folder');
  if StringPromtForm.Query(L('Create directory'), L('Enter a name for the new directory'), DirectoryName) then
  begin
    Mapping.CreateDirectory(DirectoryName);
    DrawCurrentDirectory(CDListView);
  end;
end;

procedure TFormCDExport.ButtonChooseDirectoryClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := DBSelectDir(Handle, L('Select a folder to export files'));
  if DirectoryExists(Dir) then
    EditExportDirectory.Text := Dir;
end;

procedure TFormCDExport.ButtonAddItemsClick(Sender: TObject);
var
  Dialog: DBOpenDialog;
begin
  Dialog := DBOpenDialog.Create;
  try
    Dialog.EnableMultyFileChooseWithDirectory;
    if Dialog.Execute then
    begin
      Mapping.AddRealItemsToCurrentDirectory(Dialog.GetFiles);
      DrawCurrentDirectory(CDListView);
    end;
  finally
    F(Dialog);
  end;
end;

procedure TFormCDExport.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WndParent := GetDesktopWindow;
  with Params do
    ExStyle := ExStyle or WS_EX_APPWINDOW;
end;

procedure TFormCDExport.ComboBoxPathListSelect(Sender: TObject);
begin
  Mapping.SelectPath(ComboBoxPathList.Items[ComboBoxPathList.ItemIndex]);
  DrawCurrentDirectory(CDListView);
end;

procedure TFormCDExport.EnableControls(Value : boolean);
begin
  LsMain.Visible := not Value;
  EditLabel.Enabled := Value;
  EditCDSize.Enabled := Value;
  PanelTop.Enabled := Value;
  ButtonAddItems.Enabled := Value;
  ButtonRemoveItems.Enabled := Value;
  ButtonCreateDirectory.Enabled := Value;
  CDListView.Enabled := Value;
  ButtonChooseDirectory.Enabled := Value;
  CheckBoxDeleteFiles.Enabled := Value;
  CheckBoxModifyDB.Enabled := Value;
  ButtonExport.Enabled := Value;
  CheckBoxCreatePortableDB.Enabled := Value;
end;

procedure TFormCDExport.ButtonExportClick(Sender: TObject);
var
  DriveFreeSize: Int64;
  Options: TCDExportOptions;
begin
  if (Pos(':', EditLabel.Text) > 0) or (Pos('\', EditLabel.Text) > 0) or (Pos('?', EditLabel.Text) > 0) or
    (EditLabel.Text = '') then
  begin
    MessageBoxDB(Handle, L('Please enter a disk label that uniquely identify a disk! The title character is not allowed ":", "\" and "?"'), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
    EditLabel.SetFocus;
    EditLabel.SelectAll;
    Exit;
  end;
  Mapping.CDLabel := EditLabel.Text;
  DriveFreeSize := DiskFree(Ord(AnsiLowerCase(EditExportDirectory.Text)[1]) - Ord('a') + 1);
  if Mapping.GetCDSize > DriveFreeSize then
  begin
    MessageBoxDB(Handle, Format(L('Can not copy files: detected insufficient disk space! Need %s, and free only %s!'), [SizeInText(Mapping.GetCDSize),
        SizeInText(DriveFreeSize)]), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
    Exit;
  end;

  if not Mapping.DirectoryHasDBFiles(Mapping.GetRoot) then
  begin
    if ID_YES <> MessageBoxDB(Handle, L('The exported data can not have files associated with the current database! You may not have selected the correct database! Continue to export?'), L('Warning'), TD_BUTTON_YESNO,
      TD_ICON_WARNING) then
      Exit;
  end;

  EnableControls(False);
  // in thread!

  ProgramStatistics.CDExportUsed;

  Options.ToDirectory := EditExportDirectory.Text;
  Options.DeleteFiles := CheckBoxDeleteFiles.Checked;
  Options.ModifyDB := CheckBoxModifyDB.Checked;
  Options.CreatePortableDB := CheckBoxCreatePortableDB.Checked;
  Options.OnEnd := OnThreadEnd;

  TCDExportThread.Create(Self, FContext, Mapping, Options);
end;

procedure TFormCDExport.Rename1Click(Sender: TObject);
var
  Item : TListItem;
begin
  Item := CDListView.Selected;
  if Item <> nil then
    Item.EditCaption;
end;

procedure TFormCDExport.CDListViewEditing(Sender: TObject; Item: TListItem;
  var AllowEdit: Boolean);
begin
  if Item <> nil then
    if Item.Data = nil then
      AllowEdit := False;
end;

procedure TFormCDExport.CDListViewEdited(Sender: TObject; Item: TListItem;
  var S: String);
var
  Data: TCDIndexMappingDirectory;
begin
  Data := TCDIndexMappingDirectory(Item.Data);
  if Data.IsFile then
    if Mapping.FileExists(S) then
    begin
      S := Item.Caption;
      Exit;
    end;
  if not Data.IsFile then
    if Mapping.DirectoryExists(S) then
    begin
      S := Item.Caption;
      Exit;
    end;
  Data.name := S;
end;

procedure TFormCDExport.PopupMenuListViewPopup(Sender: TObject);
begin
  Open1.Visible := (CDListView.SelCount = 1) and (TCDIndexMappingDirectory(CDListView.Selected.Data).RealFileName <> '');
  Copy1.Visible := CDListView.SelCount > 0;
  Cut1.Visible := CDListView.SelCount > 0;
  Paste1.Visible := CDListView.SelCount = 0;
  Rename1.Visible := CDListView.SelCount = 1;
  Delete1.Visible := CDListView.SelCount > 0;
end;

procedure TFormCDExport.Copy1Click(Sender: TObject);
var
  I: Integer;
  Item: TCDIndexMappingDirectory;
  List: TList;
begin
  List := TList.Create;
  try
    for I := CDListView.Items.Count - 1 downto 0 do
      if CDListView.Items[I].Selected then
      begin
        Item := CDListView.Items[I].Data;
        List.Add(Item);
      end;
    Mapping.Copy(List);
  finally
    F(List);
  end;
  DrawCurrentDirectory(CDListView);
end;

procedure TFormCDExport.Cut1Click(Sender: TObject);
var
  I: Integer;
  Item: TCDIndexMappingDirectory;
  List: TList;
begin
  List := TList.Create;
  try
    for I := CDListView.Items.Count - 1 downto 0 do
      if CDListView.Items[I].Selected then
      begin
        Item := CDListView.Items[I].Data;
        List.Add(Item);
      end;
    Mapping.Cut(List);
  finally
    F(List);
  end;
  DrawCurrentDirectory(CDListView);
end;

procedure TFormCDExport.Paste1Click(Sender: TObject);
begin
  Mapping.Paste;
  DrawCurrentDirectory(CDListView);
end;

procedure TFormCDExport.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
  if Msg.Hwnd = CDListView.Handle then
  begin
    if Msg.message = WM_KEYDOWN then
    begin
      if (Msg.WParam = VK_DELETE) then
        ButtonRemoveItemsClick(ButtonRemoveItems);
      if (Msg.WParam = VK_RETURN) then
        CDListViewDblClick(CDListView);
      if (Msg.WParam = VK_F2) then
        Rename1Click(Rename1);
    end;
  end;
end;

procedure TFormCDExport.OnThreadEnd(Sender: TObject);
var
  Directory: string;
begin
  EnableControls(True);

  Directory := ExtractFilePath(EditExportDirectory.Text);
  Directory := Directory + Mapping.CDLabel;
  Directory := IncludeTrailingBackslash(Directory);

  MessageBoxDB(Handle, Format(L('Files written to disk successfully exported to the folder "%s"!'), [Directory]), L('Information'), TD_BUTTON_OK,
    TD_ICON_INFORMATION);

  with ExplorerManager.NewExplorer(False) do
  begin
    SetPath(Directory);
    Show;
    SetFocus;
  end;

  Close;
end;

procedure TFormCDExport.Open1Click(Sender: TObject);
var
  I: Integer;
  Item: TCDIndexMappingDirectory;
  List: TList;
  FileName: string;
begin
  List := TList.Create;
  try
    for I := CDListView.Items.Count - 1 downto 0 do
      if CDListView.Items[I].Selected then
      begin
        Item := CDListView.Items[I].Data;
        FileName := ProcessPath(Item.RealFileName);
        if FileName <> '' then
        begin
          ShellExecute(Handle, 'open', PChar(FileName), nil, PChar(ExtractFileDir(FileName)), SW_NORMAL);
          Exit;
        end;
      end;
  finally
    F(List);
  end;
end;

initialization
  FormInterfaces.RegisterFormInterface(ICDExportForm, TFormCDExport);

end.
