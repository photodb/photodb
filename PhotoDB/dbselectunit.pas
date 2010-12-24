unit dbselectunit;

interface

uses
  Dolphin_DB, Searching, UnitDBKernel, Windows, Messages, SysUtils, Variants,
  Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, DB,
  ExtCtrls, uVistaFuncs, UnitConvertDBForm, ComCtrls, ComboBoxExDB, ImgList,
  UnitDBFileDialogs, UnitDBDeclare, UnitDBCommonGraphics, uShellIntegration,
  uRuntime, uDBForm, uFileUtils;

type
  TDBSelect = class(TDBForm)
    Edit1: TEdit;
    Button1: TButton;
    Button3: TButton;
    Button2: TButton;
    Button4: TButton;
    CheckBox1: TCheckBox;
    Edit2: TEdit;
    Image1: TImage;
    ComboBoxExDB1: TComboBoxExDB;
    DBImageList: TImageList;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure SelectDB;
    procedure SelectDBNeeded;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure SetDefaultIcon(path : string = '');
    procedure ComboBoxExDB1Select(Sender: TObject);
  private
    DBFile : TPhotoDBFile;
    Procedure DoControlsReallign;
    procedure RefreshDBList;
    { Private declarations }
  public
    AddDB : boolean;
    EditDB : boolean;
    EditOldDBName : string;
  Procedure LoadLanguage;
    { Public declarations }
  end;

{var
  DBSelect: TDBSelect;
  DBTestOK : boolean = false;
  dbneed_ : boolean = true;   }

implementation

uses Language, CommonDBSupport;

{$R *.dfm}

procedure TDBSelect.Button1Click(Sender: TObject);
var
  DBVersion : integer;
  DialogResult : integer;
  FA : integer;
  OpenDialog : DBOpenDialog;
  FileName : string;
begin
 OpenDialog := DBOpenDialog.Create;
 OpenDialog.Filter:='PhotoDB Files (*.photodb)|*.photodb';

 if FileExists(dbname) then
 OpenDialog.SetFileName(dbname);

 if OpenDialog.Execute then
 begin
  FileName:=OpenDialog.FileName;
  FA:=FileGetAttr(FileName);
  if (fa and SysUtils.faReadOnly)<>0 then
  begin
   MessageBoxDB(Handle,TEXT_MES_DB_READ_ONLY_CHANGE_ATTR_NEEDED,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
   OpenDialog.Free;
   exit;
  end;

  DBVersion:=DBKernel.TestDBEx(FileName);
  if DBVersion>0 then
  if not DBKernel.ValidDBVersion(FileName,DBVersion) then
  begin
   DialogResult:=MessageBoxDB(Handle,'This database may not be used without conversion, ie It is designed to work with older versions of the program. Run the wizard to convert database?',TEXT_MES_WARNING,'',TD_BUTTON_YESNO,TD_ICON_WARNING);
   if ID_YES=DialogResult then
   begin
    ConvertDB(FileName);
   end;
  end;
  //?DBTestOK:=DBKernel.TestDB(FileName);
  //?Button3.Enabled:=DBTestOK;
  //?CheckBox1.Enabled:=DBTestOK;
  //?if DBTestOK then
  //?Edit1.Text:= FileName else
  Edit1.Text:=TEXT_MES_NO_DB_FILE;
 end;
 OpenDialog.Free;
end;

procedure TDBSelect.Button3Click(Sender: TObject);
var
  EventInfo : TEventValues;
begin
 //?if DBTestOK then
 begin
  if not AddDB then
  begin
   LastInseredID:=0;
   dbname:=Edit1.Text;
   if Checkbox1.Checked then
   begin
    DBKernel.SetDataBase(dbname);
    if ComboBoxExDB1.ItemIndex=0 then
    DBKernel.AddDB(Edit2.Text,Edit1.Text,DBFile.Icon);
   end;
   //?dbneed_:=false;
   EventInfo.Name:=dbname;
   DBKernel.DoIDEvent(Self,0,[EventID_Param_DB_Changed],EventInfo);
   Close;
  end else
  begin
   if EditDB then DBKernel.RenameDB(EditOldDBName,Edit2.Text);
   DBKernel.AddDB(Edit2.Text,Edit1.Text,DBFile.Icon);
   Close;
  end;
 end;
end;

procedure TDBSelect.Button4Click(Sender: TObject);
var
  SaveDialog : DBSaveDialog;
  FileName : string;
begin
 SaveDialog:=DBSaveDialog.Create;
 SaveDialog.Filter:='PhotoDB Files (*.photodb)|*.photodb|Access Files (*.mdb)|*.mdb';

 if SaveDialog.Execute then
 begin
  ComboBoxExDB1.ItemIndex:=0;
  FileName:=SaveDialog.FileName;

  if SaveDialog.GetFilterIndex=2 then
  if GetExt(FileName)<>'DB' then FileName:=FileName+'.db';
  if SaveDialog.GetFilterIndex=1 then
  if GetExt(FileName)<>'PHOTODB' then FileName:=FileName+'.photodb';

  if FileExists(FileName) and (ID_OK<>MessageBoxDB(Handle,Format(TEXT_MES_FILE_EXISTS_1,[FileName]),TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING)) then exit;
  begin
   DbKernel.CreateDBbyName(FileName);
   //?DBTestOK:=DBKernel.TestDB(FileName);
   Edit1.Text:=FileName;
   Button3.Enabled:=true;
  end;
 end;
 SaveDialog.Free;
end;

procedure TDBSelect.SelectDB;
begin
 //?dbneed_:=false;
 if not AddDB then
 if DBKernel.TestDB(dbname) then
 begin
  Edit1.Text:=DBName;
 end;
 if EditDB then
 if DBKernel.TestDB(Edit1.Text) then
 begin
  Button3.Enabled:=true;
 end;

 ShowModal;
end;

procedure TDBSelect.SelectDBNeeded;
begin
 //?dbneed_:=true;
 ShowModal;
end;

procedure TDBSelect.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 //?if dbneed_ then
 begin
   //TODO: close application
   //Application.Terminate;
 end;
end;

procedure TDBSelect.FormCreate(Sender: TObject);
begin
 AddDB:=false;
 DBFile := TPhotoDBFile.Create;
 DBFile.Name:=TEXT_MES_DB_BY_DEFAULT;
 DBFile.Icon:='';
 DBFile.FileName:='';
 DBFile.FileType:=0;
 LoadLanguage;
 SetDefaultIcon;
 DoControlsReallign;
 RefreshDBList;
end;

procedure TDBSelect.LoadLanguage;
begin
 Edit1.Text:= TEXT_MES_NO_DB_FILE;
 Edit2.Text:= TEXT_MES_DB_NAME_PATTERN;
 Button1.Caption:= TEXT_MES_OPEN;
 Button2.Caption:= TEXT_MES_EXIT;
 Button3.Caption:= TEXT_MES_OK;
 Button4.Caption:= TEXT_MES_CREATE_NEW;
 CheckBox1.Caption:=TEXT_MES_USE_AS_DEFAULT_DB;
 Caption:=TEXT_MES_SELECT_DATABASE;
 Label1.Caption:=TEXT_MES_USE_ANOTHER_DB_FILE;
end;

procedure TDBSelect.Image1Click(Sender: TObject);
var
  FileName: string;
  IconIndex: Integer;
  S, Icon: string;
  I: Integer;
begin
  S := DBFile.Icon;
  I := Pos(',', S);
  FileName := Copy(S, 1, I - 1);
  Icon := Copy(S, I + 1, Length(S) - I);
  IconIndex := StrToIntDef(Icon, 0);
  ChangeIconDialog(Handle, FileName, IconIndex);
  if FileName <> '' then
    Icon := FileName + ',' + IntToStr(IconIndex);
  DBFile.Icon := Icon;
  SetIconToPictureFromPath(Image1.Picture, Icon);
end;

procedure TDBSelect.SetDefaultIcon(path : string = '');
var
  Ico: TIcon;
begin
  if Path = '' then
    Path := Application.ExeName + ',0';
  DBFile.Icon := Path;
  Ico := TIcon.Create;
  try
    Ico.Handle := ExtractSmallIconByPath(Path);
    Image1.Picture.Graphic := Ico;
    Image1.Refresh;
  finally
    Ico.Free;
  end;
end;

procedure TDBSelect.DoControlsReallign;
begin
 //
 Button4.Top:=Edit1.Top+Edit1.Height+3;
 Image1.Top:=Edit1.Top+Edit1.Height+3+Button4.Height div 2 - Image1.Height div 2;
 Edit2.Top:=Edit1.Top+Edit1.Height+3;

 CheckBox1.Top:=Edit2.Top+Edit2.Height+3;
 Label1.Top:=CheckBox1.Top+CheckBox1.Height+3;
 ComboBoxExDB1.Top:=Label1.Top+Label1.Height+3;

 Button2.Top:=ComboBoxExDB1.Top+ComboBoxExDB1.Height+5;
 Button3.Top:=ComboBoxExDB1.Top+ComboBoxExDB1.Height+5;

 ClientHeight:=Button2.Top+Button2.Height+3;
end;

procedure TDBSelect.RefreshDBList;
var
  I: Integer;
  Ico: TIcon;
begin
  ComboBoxExDB1.Clear;
  DBImageList.Clear;
  DBImageList.BkColor := ClWindow;

  with ComboBoxExDB1.ItemsEx.Add do
  begin
    Caption := TEXT_MES_NEW_DB_FILE;
    ImageIndex := 0;
  end;

  Ico := TIcon.Create;
  try
    Ico.Handle := ExtractSmallIconByPath(Application.ExeName + ',0');
    DBImageList.AddIcon(Ico);
  finally
    Ico.Free;
  end;

  for I := 0 to DBKernel.DBs.Count - 1 do
  begin
    with ComboBoxExDB1.ItemsEx.Add do
    begin
      Caption := DBKernel.DBs[I].name;
      ImageIndex := I + 1;
    end;

    Ico := TIcon.Create;
    try
      Ico.Handle := ExtractSmallIconByPath(DBKernel.DBs[I].Icon);
      if Ico.Empty then
        Ico.Handle := ExtractSmallIconByPath(Application.ExeName + ',0');
      DBImageList.AddIcon(Ico);
    finally
      Ico.Free;
    end;
  end;

  ComboBoxExDB1.ItemIndex := 0;
end;

procedure TDBSelect.ComboBoxExDB1Select(Sender: TObject);
var
  DB : TPhotoDBFile;
  DBVersion, DialogResult : integer;
  Ico : TIcon;
begin
 if ComboBoxExDB1.ItemIndex>0 then
 begin
  Edit1.Enabled:=false;
  Button1.Enabled:=false;
  Edit2.Enabled:=false;
  Image1.Enabled:=false;

  DB:= DBKernel.DBs[ComboBoxExDB1.ItemIndex-1];

  DBVersion:=DBKernel.TestDBEx(DB.FileName);
  if DBVersion>0 then
  if not DBKernel.ValidDBVersion(DB.FileName,DBVersion) then
  begin
   DialogResult:=MessageBoxDB(Handle,'This database may not be used without conversion, ie It is designed to work with older versions of the program. Run the wizard to convert database?',TEXT_MES_WARNING,'',TD_BUTTON_YESNO,TD_ICON_WARNING);
   if ID_YES=DialogResult then
   begin
    ConvertDB(DB.FileName);
   end;
  end;
  //?DBTestOK:=DBKernel.TestDB(DB.FileName);
  //?Button3.Enabled:=DBTestOK;
  //?CheckBox1.Enabled:=DBTestOK;
  //?if DBTestOK then
  //?begin
   Edit1.Text:= DB.FileName;
   Edit2.Text:= DB.Name;
   Ico := TIcon.Create;
   try
     Ico.Handle := ExtractSmallIconByPath(DB.Icon);
     Image1.Picture.Icon := Ico;
   finally
     Ico.Free;
   end;
  //?end else
  Edit1.Text:=TEXT_MES_NO_DB_FILE;

 end else
 begin
  Edit1.Enabled:=true;
  Button1.Enabled:=true;
  Edit2.Enabled:=true;
  Image1.Enabled:=true;
 end;
end;

end.






