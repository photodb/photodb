unit UnitDBOptions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Dolphin_DB, StdCtrls, CommonDBSupport, WebLink,
  UnitDBDeclare, UnitDBFileDialogs, uConstants, ExtCtrls, UnitDBCommonGraphics,
  UnitDBKernel, uShellIntegration, uDBForm, uMemory, uFileUtils;

type
  TFormDBOptions = class(TDBForm)
    EdName: TEdit;
    LbCollectionName: TLabel;
    LbDescription: TLabel;
    EdDescriotion: TEdit;
    Label3: TLabel;
    ComboBox1: TComboBox;
    BtnOk: TButton;
    BtnCancel: TButton;
    Label4: TLabel;
    ComboBox2: TComboBox;
    Label5: TLabel;
    Edit3: TEdit;
    Label6: TLabel;
    Edit4: TEdit;
    WlChangeImageQuality: TWebLink;
    Label7: TLabel;
    EdPath: TEdit;
    BtnOpenFileLocation: TButton;
    BtnChangeFileLocation: TButton;
    GroupBoxIcon: TGroupBox;
    BtnChangeIcon: TButton;
    ImageIconPreview: TImage;
    Label8: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure WlChangeImageQualityClick(Sender: TObject);
    procedure BtnOpenFileLocationClick(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure BtnChangeFileLocationClick(Sender: TObject);
    procedure BtnChangeIconClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    ImageOptions: TImageDBOptions;
    DBFile: TPhotoDBFile;
    FName: string;
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    procedure LoadLanguage;
    procedure Execute(Options: TPhotoDBFile);
    procedure ReadSettingsFromDB;
    procedure SetDefaultIcon(Path: string = '');
  end;

procedure ChangeDBOptions(Name, FileName : string);  overload;
procedure ChangeDBOptions(Options : TPhotoDBFile);  overload;

implementation

uses UnitConvertDBForm, ExplorerUnit;

{$R *.dfm}

procedure ChangeDBOptions(Name, FileName : string);
var
  FormDBOptions: TFormDBOptions;
  Options : TPhotoDBFile;
begin
  Application.CreateForm(TFormDBOptions, FormDBOptions);
  try
    Options := TPhotoDBFile.Create;
    try
      Options.Name := Name;
      Options.Icon := '';
      Options.FileName := FileName;
      Options.FileType := 0;
      FormDBOptions.Execute(Options);
    finally
      F(Options);
    end;
  finally
    R(FormDBOptions);
  end;
end;

procedure ChangeDBOptions(Options : TPhotoDBFile);  overload;
var
  FormDBOptions: TFormDBOptions;
begin
  Application.CreateForm(TFormDBOptions, FormDBOptions);
  try
    FormDBOptions.Execute(Options);
  finally
    R(FormDBOptions);
  end;
end;

procedure TFormDBOptions.Execute(Options : TPhotoDBFile);
begin
  FName := Options.name;
  DBFile.FileName := Options.FileName;
  ReadSettingsFromDB;
  SetDefaultIcon(Options.Icon);
  GroupBoxIcon.Visible := True;
  ShowModal;
end;

procedure TFormDBOptions.FormCreate(Sender: TObject);
begin
  DBFile := TPhotoDBFile.Create;
  LoadLanguage;
end;

procedure TFormDBOptions.FormDestroy(Sender: TObject);
begin
  F(DBFile);
end;

function TFormDBOptions.GetFormID: string;
begin
  Result := 'DBOptions';
end;

procedure TFormDBOptions.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Change Collection Settings');
    LbCollectionName.Caption := L('Collection Name') + ':';
    LbDescription.Caption := L('Description') + ':';
    Label7.Caption := L('Path to file') + ':';
    BtnOpenFileLocation.Caption := L('Open file location');
    BtnChangeFileLocation.Caption := L('Change file location');
    Label3.Caption := L('Size of the images in the panel by default');
    Label4.Caption := L('Image preview size');
    Label5.Caption := L('DB Image size');
    Label6.Caption := L('JPEG quality');
    WlChangeImageQuality.Text := L('Press this link to change the size and quality of previews using convertation wizard');
    BtnCancel.Caption := L('Cancel');
    BtnOk.Caption := L('Ok');
    GroupBoxIcon.Caption := L('Icon options');
    Label8.Caption := L('Icon preview') + ':';
    BtnChangeIcon.Caption := L('Choose icon');
  finally
    EndTranslate;
  end;
end;

procedure TFormDBOptions.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormDBOptions.WlChangeImageQualityClick(Sender: TObject);
begin
  ConvertDB(DBFile.FileName);
end;

procedure TFormDBOptions.BtnOpenFileLocationClick(Sender: TObject);
begin
  with ExplorerManager.NewExplorer(False) do
  begin
    SetOldPath(DBFile.FileName);
    SetPath(ExtractFileDir(DBFile.FileName));
    Show;
  end;
end;

procedure TFormDBOptions.BtnOkClick(Sender: TObject);
var
  Options: TImageDBOptions;
  Value: TEventValues;

  procedure DisableControls;
  begin
    BtnOk.Enabled := False;
    BtnCancel.Enabled := False;
    BtnOpenFileLocation.Enabled := False;
    BtnChangeFileLocation.Enabled := False;
    BtnChangeIcon.Enabled := False;
    EdName.Enabled := False;
    EdDescriotion.Enabled := False;
    ComboBox1.Enabled := False;
    ComboBox2.Enabled := False;
    WlChangeImageQuality.Enabled := False;
  end;

begin
  DisableControls;
  Options := CommonDBSupport.GetImageSettingsFromTable(DBFile.FileName);
  Options.Name := NormalizeDBString(EdName.Text);
  Options.Description := NormalizeDBString(EdDescriotion.Text);
  Options.ThSizePanelPreview := SysUtils.StrToIntDef(ComboBox1.Text,
    Options.ThSizePanelPreview);
  Options.ThHintSize := SysUtils.StrToIntDef(ComboBox2.Text,
    Options.ThHintSize);
  if Options.ThSizePanelPreview < 50 then
    Options.ThSizePanelPreview := 50;
  if Options.ThSizePanelPreview > Options.ThSize then
    Options.ThSizePanelPreview := Options.ThSize;

  if Options.ThHintSize < Options.ThSize then
    Options.ThHintSize := Options.ThSize;
  if Options.ThHintSize > Screen.Width then
    Options.ThHintSize := Screen.Width;

  CommonDBSupport.UpdateImageSettings(DBFile.FileName, Options);
  if FName <> '' then
    DBkernel.AddDB(FName, DBFile.FileName, DBFile.Icon, True);

  if AnsiLowerCase(DBName) = AnsiLowerCase(DBFile.FileName) then
  begin
    DBkernel.ReadDBOptions;
    DBkernel.DoIDEvent(Self, 0, [EventID_Param_DB_Changed], Value);
  end;
  Close;
end;

procedure TFormDBOptions.BtnChangeFileLocationClick(Sender: TObject);
var
  DBVersion: Integer;
  DialogResult: Integer;
  FA: Integer;
  OpenDialog: DBOpenDialog;
  FileName: string;
begin
  OpenDialog := DBOpenDialog.Create;
  try
    OpenDialog.Filter := L('PhotoDB Files (*.photodb)|*.photodb');

    if FileExistsSafe(DBName) then
      OpenDialog.SetFileName(DBName);

    if OpenDialog.Execute then
    begin
      FileName := OpenDialog.FileName;
      FA := FileGetAttr(FileName);
      if (FA and SysUtils.faReadOnly) <> 0 then
      begin
        MessageBoxDB(Handle, L('Database file marked as "Read only"! Please, reset this attribute and try again!'),
          L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
        Exit;
      end;

      DBVersion := DBkernel.TestDBEx(FileName);
      if DBVersion > 0 then
      begin
        if not DBkernel.ValidDBVersion(FileName, DBVersion) then
        begin
          DialogResult := MessageBoxDB(Handle,
            L('This database may not be used without conversion, ie It is designed to work with older versions of the program. Run the wizard to convert the database?'), L('Warning'), '', TD_BUTTON_YESNO, TD_ICON_WARNING);
          if ID_YES = DialogResult then
            ConvertDB(FileName);

          Exit;
        end;
      end;
      EdPath.Text := FileName;
      BtnOk.Enabled := True;
      DBFile.FileName := FileName;
      if FName <> '' then
        DBkernel.AddDB(FName, DBFile.FileName, DBFile.Icon);
    end;
  finally
    F(OpenDialog);
  end;
end;

procedure TFormDBOptions.ReadSettingsFromDB;
var
  ValidDB: boolean;
begin
  ValidDB := DBkernel.TestDB(DBFile.FileName);
  if ValidDB then
  begin
    ImageOptions := CommonDBSupport.GetImageSettingsFromTable(DBFile.FileName);
    BtnChangeFileLocation.Visible := False;
    BtnOpenFileLocation.Visible := True;
  end else
  begin
    ImageOptions := CommonDBSupport.GetDefaultImageDBOptions;
    BtnChangeFileLocation.Visible := True;
    BtnOpenFileLocation.Visible := False;
    BtnOk.Enabled := False;
  end;
  Edit3.Text := IntToStr(ImageOptions.ThSize);
  Edit4.Text := IntToStr(ImageOptions.DBJpegCompressionQuality);
  ComboBox2.Text := IntToStr(ImageOptions.ThHintSize);
  ComboBox1.Text := IntToStr(ImageOptions.ThSizePanelPreview);

  DBFile.Icon := Application.ExeName + ',0';
  if FName = '' then
    DBFile.Name := L('New collection')
  else
    DBFile.Name := FName;

  EdName.Text := Trim(ImageOptions.Name);
  EdDescriotion.Text := Trim(ImageOptions.Description);
  EdPath.Text := DBFile.FileName;
end;

procedure TFormDBOptions.BtnChangeIconClick(Sender: TObject);
var
  FileName: string;
  IconIndex: Integer;
  S, Icon: string;
  I: integer;
begin
  if not BtnChangeIcon.Enabled then
    Exit;
  S := DBFile.Icon;
  I := Pos(',', S);
  FileName := Copy(S, 1, I - 1);
  Icon := Copy(S, I + 1, Length(S) - I);
  IconIndex := StrToIntDef(Icon, 0);
  ChangeIconDialog(Handle, FileName, IconIndex);
  if FileName <> '' then
    Icon := FileName + ',' + IntToStr(IconIndex);
  DBFile.Icon := Icon;

  SetIconToPictureFromPath(ImageIconPreview.Picture, Icon);
end;

procedure TFormDBOptions.SetDefaultIcon(Path: string = '');
begin
  if Path = '' then
    Path := ExtractFilePath(Application.ExeName) + 'Icons.dll,121';
  DBFile.Icon := Path;
  SetIconToPictureFromPath(ImageIconPreview.Picture, Path);
end;

end.
