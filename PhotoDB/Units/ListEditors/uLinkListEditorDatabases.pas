unit uLinkListEditorDatabases;

interface

uses
  Generics.Collections,
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Forms,

  Dmitry.Utils.System,
  Dmitry.Utils.Files,
  Dmitry.Controls.WatermarkedEdit,
  Dmitry.Controls.WebLink,

  UnitDBDeclare,
  UnitDBFileDialogs,
  UnitDBKernel,
  CommonDBSupport,

  uConstants,
  uMemory,
  uRuntime,
  uStringUtils,
  uDBForm,
  uDBScheme,
  uDBUtils,
  uVclHelpers,
  uIconUtils,
  uTranslate,
  uShellIntegration,
  uFormInterfaces,
  uDatabaseDirectoriesUpdater,
  uLinkListEditorUpdateDirectories;

type
  TLinkListEditorDatabases = class(TInterfacedObject, ILinkEditor)
  private
    FOwner: TDBForm;
    FDeletedCollections: TStrings;
    FForm: ILinkItemSelectForm;
    procedure LoadIconForLink(Link: TWebLink; Path, Icon: string);
    procedure OnPlaceIconClick(Sender: TObject);
    procedure OnChangePlaceClick(Sender: TObject);
    procedure OnPreviewOptionsClick(Sender: TObject);
    procedure OnUpdateOptionsClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  public
    constructor Create(Owner: TDBForm);
    destructor Destroy; override;
    procedure SetForm(Form: ILinkItemSelectForm);
    procedure CreateNewItem(Sender: ILinkItemSelectForm; var Data: TDataObject; Verb: string; Elements: TListElements);
    procedure CreateEditorForItem(Sender: ILinkItemSelectForm; Data: TDataObject; Editor: TPanel);
    procedure UpdateItemFromEditor(Sender: ILinkItemSelectForm; Data: TDataObject; Editor: TPanel);
    procedure FillActions(Sender: ILinkItemSelectForm; AddActionProc: TAddActionProcedure);
    function OnDelete(Sender: ILinkItemSelectForm; Data: TDataObject; Editor: TPanel): Boolean;
    function OnApply(Sender: ILinkItemSelectForm): Boolean;
  end;

procedure UpdateCurrentCollectionDirectories(CollectionFile: string);

implementation

const
  CHANGE_DB_ICON            = 1;
  CHANGE_DB_CAPTION_EDIT    = 2;
  CHANGE_DB_CHANGE_PATH     = 3;
  CHANGE_DB_PATH            = 4;
  CHANGE_DB_DESC_EDIT       = 5;
  CHANGE_DB_DESC_LABEL      = 6;
  CHANGE_DB_UPDATE_OPTIONS  = 7;
  CHANGE_DB_PREVIEW_OPTIONS = 7;

procedure UpdateCurrentCollectionDirectories(CollectionFile: string);
var
  Data: TList<TDataObject>;
  Editor: ILinkEditor;
begin
  Editor := TLinkListEditorUpdateDirectories.Create();
  try
    Data := TList<TDataObject>.Create;
    try
      ReadDatabaseDirectories(TList<TDatabaseDirectory>(Data), CollectionFile, True);

      if LinkItemSelectForm.Execute(480, TA('Directories synchronization with collection', 'CollectionSettings'), Data, Editor) then
        SaveDatabaseDirectories(TList<TDatabaseDirectory>(Data), CollectionFile);

    finally
      FreeList(Data);
    end;
  finally
    Editor := nil;
  end;
end;

{ TLinkListEditorDatabases }

constructor TLinkListEditorDatabases.Create(Owner: TDBForm);
begin
  FOwner := Owner;
  FDeletedCollections := TStringList.Create;
end;

procedure TLinkListEditorDatabases.CreateEditorForItem(
  Sender: ILinkItemSelectForm; Data: TDataObject; Editor: TPanel);
var
  DI: TDatabaseInfo;
  WlIcon: TWebLink;
  WlChangeLocation,
  WLUpdateOptions, WlPreviewOptions: TWebLink;
  WedCaption,
  WedDescription: TWatermarkedEdit;
  LbInfo,
  LbDescription: TLabel;
  Icon: HICON;
begin
  DI := TDatabaseInfo(Data);

  WlIcon := Editor.FindChildByTag<TWebLink>(CHANGE_DB_ICON);
  WedCaption :=  Editor.FindChildByTag<TWatermarkedEdit>(CHANGE_DB_CAPTION_EDIT);
  WlChangeLocation := Editor.FindChildByTag<TWebLink>(CHANGE_DB_CHANGE_PATH);
  LbInfo := Editor.FindChildByTag<TLabel>(CHANGE_DB_PATH);

  WedDescription :=  Editor.FindChildByTag<TWatermarkedEdit>(CHANGE_DB_DESC_EDIT);
  LbDescription :=  Editor.FindChildByTag<TLabel>(CHANGE_DB_DESC_LABEL);

  WLUpdateOptions := Editor.FindChildByTag<TWebLink>(CHANGE_DB_UPDATE_OPTIONS);
  WlPreviewOptions := Editor.FindChildByTag<TWebLink>(CHANGE_DB_PREVIEW_OPTIONS);

  if WlIcon = nil then
  begin
    WlIcon := TWebLink.Create(Editor);
    WlIcon.Parent := Editor;
    WlIcon.Tag := CHANGE_DB_ICON;
    WlIcon.Width := 16;
    WlIcon.Height := 16;
    WlIcon.Left := 8;
    WlIcon.Top := 8;
    WlIcon.OnClick := OnPlaceIconClick;
  end;

  if LbInfo = nil then
  begin
    LbInfo := TLabel.Create(Editor);
    LbInfo.Parent := Editor;
    LbInfo.Tag := CHANGE_DB_PATH;
    LbInfo.Left := 35;
    LbInfo.Top := 8;
    LbInfo.Width := 350;
    LbInfo.AutoSize := False;
    LbInfo.EllipsisPosition := epPathEllipsis;
  end;

  if WedCaption = nil then
  begin
    WedCaption := TWatermarkedEdit.Create(Editor);
    WedCaption.Parent := Editor;
    WedCaption.Tag := CHANGE_DB_CAPTION_EDIT;
    WedCaption.Top := LbInfo.Top + LbInfo.Height + 5;
    WedCaption.Left := 35;
    WedCaption.Width := 200;
    WedCaption.OnKeyDown := FormKeyDown;
  end;

  if WlChangeLocation = nil then
  begin
    WlChangeLocation := TWebLink.Create(Editor);
    WlChangeLocation.Parent := Editor;
    WlChangeLocation.Tag := CHANGE_DB_CHANGE_PATH;
    WlChangeLocation.Height := 26;
    WlChangeLocation.Text := FOwner.L('Change file');
    WlChangeLocation.RefreshBuffer(True);
    WlChangeLocation.Top := WedCaption.Top + WedCaption.Height div 2 - WlChangeLocation.Height div 2;
    WlChangeLocation.Left := 240;
    WlChangeLocation.LoadFromResource('NAVIGATE');
    WlChangeLocation.OnClick := OnChangePlaceClick;
  end;

  if WedDescription = nil then
  begin
    WedDescription := TWatermarkedEdit.Create(Editor);
    WedDescription.Parent := Editor;
    WedDescription.Tag := CHANGE_DB_DESC_EDIT;
    WedDescription.Top := WedCaption.Top + WedCaption.Height + 5;;
    WedDescription.Left := 35;
    WedDescription.Width := 200;
    WedDescription.OnKeyDown := FormKeyDown;
  end;

  if LbDescription = nil then
  begin
    LbDescription := TLabel.Create(Editor);
    LbDescription.Parent := Editor;
    LbDescription.Tag := CHANGE_DB_DESC_LABEL;
    LbDescription.Caption := FOwner.L('Description');
    LbDescription.Left := WedDescription.AfterRight(5);
    LbDescription.Top := WedDescription.Top + WedDescription.Height div 2 - LbDescription.Height div 2;
  end;

  if WLUpdateOptions = nil then
  begin
    WLUpdateOptions := TWebLink.Create(Editor);
    WLUpdateOptions.Parent := Editor;
    WLUpdateOptions.Tag := CHANGE_DB_UPDATE_OPTIONS;
    WLUpdateOptions.Height := 26;
    WLUpdateOptions.Text := FOwner.L('Change synchronization settings');
    WLUpdateOptions.Top := WedDescription.Top + WedDescription.Height + 8;
    WLUpdateOptions.Left := 35;
    WLUpdateOptions.IconWidth := 16;
    WLUpdateOptions.IconHeight := 16;
    WLUpdateOptions.LoadFromResource('SYNC');
    WLUpdateOptions.RefreshBuffer(True);
    WLUpdateOptions.OnClick := OnUpdateOptionsClick;
  end;

  if WlPreviewOptions = nil then
  begin
    WlPreviewOptions := TWebLink.Create(Editor);
    WlPreviewOptions.Parent := Editor;
    WlPreviewOptions.Tag := CHANGE_DB_UPDATE_OPTIONS;
    WlPreviewOptions.Height := 26;
    WlPreviewOptions.Text := FOwner.L('Change preview options');
    WlPreviewOptions.Top := WLUpdateOptions.Top + WLUpdateOptions.Height + 8;
    WlPreviewOptions.Left := 35;
    WlPreviewOptions.IconWidth := 16;
    WlPreviewOptions.IconHeight := 16;
    WlPreviewOptions.LoadFromResource('PICTURE');
    WlPreviewOptions.RefreshBuffer(True);
    WlPreviewOptions.OnClick := OnPreviewOptionsClick;
  end;

  Icon := ExtractSmallIconByPath(DI.Icon);
  try
    WlIcon.LoadFromHIcon(Icon);
  finally
    DestroyIcon(Icon);
  end;
  WedCaption.Text := DI.Title;
  LbInfo.Caption := DI.Path;
  WedDescription.Text := DI.Description;
end;

procedure TLinkListEditorDatabases.CreateNewItem(Sender: ILinkItemSelectForm;
  var Data: TDataObject; Verb: string; Elements: TListElements);
var
  Link: TWebLink;
  Info: TLabel;
  DI: TDatabaseInfo;

  function L(Text: string): string;
  begin
    Result := Text;
  end;

  procedure CreateSampleDB;
  var
    SaveDialog: DBSaveDialog;
    FileName: string;
  begin
    // Sample DB
    SaveDialog := DBSaveDialog.Create;
    try
      SaveDialog.Filter := L('PhotoDB Files (*.photodb)|*.photodb');
      if SaveDialog.Execute then
      begin
        FileName := SaveDialog.FileName;

        if GetExt(FileName) <> 'PHOTODB' then
          FileName := FileName + '.photodb';

        DBKernel.CreateExampleDB(FileName);

        Data := TDatabaseInfo.Create(GetFileNameWithoutExt(FileName), FileName, Application.ExeName + ',0', '');
      end;
    finally
      F(SaveDialog);
    end;
  end;

  procedure OpenDB;
  var
    DialogResult: Integer;
    OpenDialog: DBOpenDialog;
    FileName: string;
    Settings: TImageDBOptions;
  begin
    OpenDialog := DBOpenDialog.Create;
    try
      OpenDialog.Filter := L('PhotoDB Files (*.photodb)|*.photodb');

      if FileExistsSafe(dbname) then
        OpenDialog.SetFileName(dbname);

      if OpenDialog.Execute then
      begin
        FileName := OpenDialog.FileName;

        if TDBScheme.IsOldColectionFile(FileName) then
        begin
          DialogResult := MessageBoxDB(FOwner.Handle,
            L('This database may not be used without conversion, ie it is designed to work with older versions of the program. Run the wizard to convert database?'), L('Warning'), '', TD_BUTTON_YESNO, TD_ICON_WARNING);
          if ID_YES = DialogResult then
            //TODO: ConvertDB(FileName);
        end;

        if TDBScheme.IsValidCollectionFile(FileName) then
        begin
          Settings := CommonDBSupport.GetImageSettingsFromTable(FileName);
          try
            Data := TDatabaseInfo.Create(IIF(Length(Trim(Settings.Name)) > 0, Trim(Settings.Name), GetFileNameWithoutExt(OpenDialog.FileName)), OpenDialog.FileName, Application.ExeName + ',0', Trim(Settings.Description));
          finally
            F(Settings);
          end;
        end;
      end;
    finally
      F(OpenDialog);
    end;
  end;

begin
  if Data = nil then
  begin

    if Verb = 'Create' then
      CreateSampleDB;
    if Verb = 'Open' then
      OpenDB;

    Exit;
  end;
  DI := TDatabaseInfo(Data);

  Link := TWebLink(Elements[leWebLink]);
  Info := TLabel(Elements[leInfoLabel]);

  Link.Text := DI.Title;
  if AnsiLowerCase(DI.Path) = AnsiLowerCase(dbname) then
    Link.Font.Style := [fsBold];

  Info.Caption := DI.Path;
  Info.EllipsisPosition := epPathEllipsis;

  LoadIconForLink(Link, DI.Path, DI.Icon);
end;

destructor TLinkListEditorDatabases.Destroy;
begin
  FForm := nil;
  F(FDeletedCollections);
  inherited;
end;

procedure TLinkListEditorDatabases.FillActions(Sender: ILinkItemSelectForm;
  AddActionProc: TAddActionProcedure);
begin
  AddActionProc(['Create', 'Open'],
    procedure(Action: string; WebLink: TWebLink)
    begin
      if Action = 'Create' then
      begin
        WebLink.Text := FOwner.L('Create new');
        WebLink.LoadFromResource('NEW');
      end;

      if Action = 'Open' then
      begin
        WebLink.Text := FOwner.L('Open existing');
        WebLink.LoadFromResource('EXPLORER');
      end;
    end
  );
end;

procedure TLinkListEditorDatabases.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    FForm.ApplyChanges;
end;

procedure TLinkListEditorDatabases.LoadIconForLink(Link: TWebLink; Path, Icon: string);
var
  Ico: HIcon;
begin
  if Icon <> '' then
    Ico := ExtractSmallIconByPath(Icon)
  else
    Ico := ExtractAssociatedIconSafe(Path);
  try
    Link.LoadFromHIcon(Ico);
  finally
    DestroyIcon(Ico);
  end;
end;

procedure TLinkListEditorDatabases.OnUpdateOptionsClick(Sender: TObject);
var
  DI: TDatabaseInfo;
  Editor: TPanel;
begin
  Editor := TPanel(TControl(Sender).Parent);
  DI := TDatabaseInfo(Editor.Tag);

  UpdateCurrentCollectionDirectories(DI.Path);
end;

procedure TLinkListEditorDatabases.OnPreviewOptionsClick(Sender: TObject);
//var
  //DI: TDatabaseInfo;
  //Editor: TPanel;
begin
  //Editor := TPanel(TControl(Sender).Parent);
  //DI := TDatabaseInfo(Editor.Tag);

  //TODO: ConvertDB(DI.Path);
end;

function TLinkListEditorDatabases.OnApply(Sender: ILinkItemSelectForm): Boolean;
var
  DialogResult: Integer;
  Text: string;
  FileName: string;
begin
  if FDeletedCollections.Count = 0 then
    Exit(True);

  Text := FOwner.L('Do you want to delete files below for deleted collections?') + sLineBreak + FDeletedCollections.Join(sLineBreak);
  DialogResult := MessageBoxDB(FOwner.Handle, Text, FOwner.L('Warning'), '', TD_BUTTON_YESNOCANCEL, TD_ICON_WARNING);
  if ID_CANCEL = DialogResult then
    Exit(False);

  if ID_YES = DialogResult then
    for FileName in FDeletedCollections do
      SilentDeleteFile(Screen.ActiveFormHandle, FileName, True);

  Exit(True);
end;

procedure TLinkListEditorDatabases.OnChangePlaceClick(Sender: TObject);
var
  DI: TDatabaseInfo;
  LbInfo: TLabel;
  Editor: TPanel;
  OpenDialog: DBOpenDialog;
begin
  Editor := TPanel(TControl(Sender).Parent);
  DI := TDatabaseInfo(Editor.Tag);

  OpenDialog := DBOpenDialog.Create;
  try
    OpenDialog.Filter := FOwner.L('PhotoDB Files (*.photodb)|*.photodb');
    OpenDialog.FilterIndex := 0;
    if OpenDialog.Execute and TDBScheme.IsValidCollectionFile(OpenDialog.FileName) then
    begin
      LbInfo := Editor.FindChildByTag<TLabel>(CHANGE_DB_PATH);
      LbInfo.Caption := OpenDialog.FileName;
      DI.Path := OpenDialog.FileName;
    end;

  finally
    F(OpenDialog);
  end;
end;

function TLinkListEditorDatabases.OnDelete(Sender: ILinkItemSelectForm;
  Data: TDataObject; Editor: TPanel): Boolean;
var
  DI: TDatabaseInfo;
begin
  DI := TDatabaseInfo(Editor.Tag);
  if FileExistsSafe(DI.Path) then
  begin
    TryRemoveConnection(DI.Path, True);
    FDeletedCollections.Add(DI.Path);
  end;

  Result := True;
end;

procedure TLinkListEditorDatabases.OnPlaceIconClick(Sender: TObject);
var
  DI: TDatabaseInfo;
  Icon: string;
  Editor: TPanel;
  WlIcon: TWebLink;
begin
  Editor := TPanel(TControl(Sender).Parent);
  DI := TDatabaseInfo(Editor.Tag);

  Icon := DI.Icon;
  if ChangeIconDialog(0, Icon) then
  begin
    DI.Icon := Icon;
    WlIcon := Editor.FindChildByTag<TWebLink>(CHANGE_DB_ICON);
    LoadIconForLink(WlIcon, DI.Path, DI.Icon);
  end;
end;

procedure TLinkListEditorDatabases.SetForm(Form: ILinkItemSelectForm);
begin
  FForm := Form;
end;

procedure TLinkListEditorDatabases.UpdateItemFromEditor(
  Sender: ILinkItemSelectForm; Data: TDataObject; Editor: TPanel);
var
  DI: TDatabaseInfo;
  WedCaption,
  WedDesctiption: TWatermarkedEdit;
begin
  DI := TDatabaseInfo(Data);

  WedCaption := Editor.FindChildByTag<TWatermarkedEdit>(CHANGE_DB_CAPTION_EDIT);
  WedDesctiption :=  Editor.FindChildByTag<TWatermarkedEdit>(CHANGE_DB_DESC_EDIT);

  DI.Assign(Sender.EditorData);
  DI.Title := WedCaption.Text;
  DI.Description := WedDesctiption.Text;
end;

end.
