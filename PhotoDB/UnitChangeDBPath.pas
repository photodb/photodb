unit UnitChangeDBPath;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Language, Dolphin_DB, StdCtrls, DmProgress, DB, win32crc,
  UnitDBFileDialogs, UnitOpenQueryThread, CommonDBSupport, uVistaFuncs,
  UnitDBkernel, UnitDBDeclare;

type
  TFormChangeDBPath = class(TForm)
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Label2: TLabel;
    ComboBox1: TComboBox;
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Label3: TLabel;
    DmProgress1: TDmProgress;
    Button3: TButton;
    Button4: TButton;
    CloseTimer: TTimer;
    Button5: TButton;
    CheckBox1: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button4Click(Sender: TObject);
    procedure CloseTimerTimer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure DBOpened(Sender : TObject; DS : TDataSet);
    procedure Button3Click(Sender: TObject);
  private
   DBInOpening : boolean;
   Working : boolean;
   ClosingWork : boolean;
    { Private declarations }
  public
   procedure LoadLanguage;
    { Public declarations }
  end;

var
  FormChangeDBPath: TFormChangeDBPath;

procedure DoChangeDBPath;

implementation

{$R *.dfm}

procedure DoChangeDBPath;
begin
 if FormChangeDBPath=nil then
 begin
  Application.CreateForm(TFormChangeDBPath, FormChangeDBPath);
 end;
 FormChangeDBPath.Show;
end;

{ TFormChangeDBPath }

procedure TFormChangeDBPath.LoadLanguage;
begin
 Caption:=TEXT_MES_CHANGE_DB_PATH_CAPTION;
 Label2.Caption:=TEXT_MES_CHANGE_DB_PATH_FROM;
 Label3.Caption:=TEXT_MES_CHANGE_DB_PATH_TO;
 Button1.Caption:=TEXT_MES_SCAN_IN_DB;
 Button5.Caption:=TEXT_MES_CHOOSE_PATH;
 Button2.Caption:=TEXT_MES_CHOOSE_PATH;
 Label1.Caption:=TEXT_MES_CHANGE_DB_PATH_INFO;
 Button4.Caption:=TEXT_MES_CANCEL;               
 Button3.Caption:=TEXT_MES_OK;
 CheckBox1.Caption:=TEXT_MES_CHANGE_ONLY_IF_END_PATH_EXISTS;
 DmProgress1.Text:=TEXT_MES_DEFAULT_PROGRESS_TEXT;
end;

procedure TFormChangeDBPath.FormCreate(Sender: TObject);
begin
 ClosingWork:=false;
 DBInOpening:=false;
 Working:=false;
 LoadLanguage;
 DBKernel.RegisterForm(Self);
 DBkernel.RecreateThemeToForm(Self);
end;

procedure TFormChangeDBPath.FormDestroy(Sender: TObject);
begin
 DBKernel.UnRegisterForm(Self);
 FormChangeDBPath:=nil;
end;

procedure TFormChangeDBPath.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 CloseTimer.Enabled:=true;
end;

procedure TFormChangeDBPath.Button4Click(Sender: TObject);
begin
 if not Working then
 begin
  Close;
 end else
 begin
  ClosingWork:=true;
 end;
end;

procedure TFormChangeDBPath.CloseTimerTimer(Sender: TObject);
begin
 CloseTimer.Enabled:=false;
 Release;
 Free;
end;

procedure TFormChangeDBPath.Button2Click(Sender: TObject);
var
  Dir : string;
begin
 Dir:=DBSelectDir(Handle,TEXT_MES_CHOOSE_FOLDER,false);
 if DirectoryExists(Dir) then
 Edit1.Text:=Dir;
end;

procedure TFormChangeDBPath.Button5Click(Sender: TObject);
var
  Dir : string;
begin
 Dir:=DBSelectDir(Handle,TEXT_MES_CHOOSE_FOLDER,false);
 if DirectoryExists(Dir) then
 ComboBox1.Text:=Dir;
end;

procedure TFormChangeDBPath.Button1Click(Sender: TObject);
var
  WorkQuery : TDataSet;
  i : integer;
  _sqlexectext : string;
  FileName : string;
  PathList : TStrings;

  function PathExists(Path : string) : boolean;
  var
    j : integer;
  begin
   PathExists:=false;
   for j:=0 to PathList.Count-1 do
   if PathList[j]=Path then
   begin
    PathExists := true;
    break;
   end;
  end;

  procedure AddPathEntry(FileName : string);
  var
    Directory, UpDirectory : string;
  begin
   Directory:=GetDirectory(FileName);
   if not PathExists(Directory) then PathList.Add(Directory);
   UnformatDir(Directory);
   UpDirectory:=GetDirectory(Directory);
   if Length(UpDirectory)>3 then
   AddPathEntry(Directory) else
   if Length(UpDirectory)=3 then
   begin
    if not PathExists(UpDirectory) then PathList.Add(UpDirectory);
   end;
  end;

begin          
 WorkQuery:=GetQuery;
 _sqlexectext:='Select FFileName from '+GetDefDBName+' order by FFileName';
 SetSQL(WorkQuery,_sqlexectext);
 DBInOpening:=true;
 TOpenQueryThread.Create(false,WorkQuery,DBOpened);
 i:=0;
 DmProgress1.MaxValue:=100;
 DmProgress1.Inverse:=true;
 Repeat
  inc(i);
  DmProgress1.Position:=i;
  if i=100 then
  begin
   i:=0;
  end;
  Delay(5);
 Until not DBInOpening;
 DmProgress1.Position:=0;
 DmProgress1.Inverse:=false;
 PathList:=TStringList.Create;

 for i:=1 to WorkQuery.RecordCount do
 begin
  FileName:=AnsiLowerCase(WorkQuery.FieldByName('FFileName').AsString);
  AddPathEntry(FileName);
  WorkQuery.Next;
 end;

 FreeDS(WorkQuery);

 for i:=0 to PathList.Count-1 do
 ComboBox1.Items.Add(PathList[i]);

 PathList.Free;
end;

procedure TFormChangeDBPath.DBOpened(Sender : TObject; DS : TDataSet);
begin
 DBInOpening:=false;
end;

procedure TFormChangeDBPath.Button3Click(Sender: TObject);
var
  WorkQuery : TDataSet;   
  TempQuery : TDataSet;
  i, Len, IntCRC, Count : integer;
  CRC : Cardinal;
  _sqlexectext, Dir, NewDir : string;
  FileName, FromPath, NewPath,ToPath : string;
  EventInfo : TEventValues;

  procedure SetEnabledControls;
  begin
   ComboBox1.Enabled:=true;
   Edit1.Enabled:=true;
   CheckBox1.Enabled:=true;
   Button5.Enabled:=true;
   Button1.Enabled:=true;
   Button2.Enabled:=true;
   Button3.Enabled:=true;
  end;

begin
 if not DirectoryExists(Edit1.Text) then exit;
 ComboBox1.Enabled:=false;
 Edit1.Enabled:=false;     
 CheckBox1.Enabled:=false;
 Button5.Enabled:=false;
 Button1.Enabled:=false;   
 Button2.Enabled:=false;   
 Button3.Enabled:=false;
 try
  Working:=true;
  FromPath:=ComboBox1.Text;
  FormatDir(FromPath);
  ToPath:=Edit1.Text;
  FormatDir(ToPath);
  WorkQuery:=GetQuery;
  _sqlexectext:='Select ID,FFileName from '+GetDefDBName;
  SetSQL(WorkQuery,_sqlexectext);
  DBInOpening:=true;
  TOpenQueryThread.Create(false,WorkQuery,DBOpened);
  i:=0;
  Count:=0;
  DmProgress1.MaxValue:=100;
  DmProgress1.Inverse:=true;
  Repeat
   inc(i);
   DmProgress1.Position:=i;
   if i=100 then
   begin
    i:=0;
   end;
   Delay(5);
  Until not DBInOpening;
  DmProgress1.Position:=0;
  DmProgress1.Inverse:=false;
  Len:=Length(FromPath);
  TempQuery:=GetQuery;
  DmProgress1.MaxValue:=WorkQuery.RecordCount;
  for i:=1 to WorkQuery.RecordCount do
  begin
   if ClosingWork then break;
   DmProgress1.Position:=i;
   Application.ProcessMessages;
   FileName:=AnsiLowerCase(WorkQuery.FieldByName('FFileName').AsString);
   if Copy(FileName,1,Len)=FromPath then
   begin
    Dir:=GetDirectory(FileName);
    if Dir<>FromPath then
    begin
     UnFormatDir(Dir);
     //CalcStringCRC32(AnsiLowerCase(Dir),CRC);
     //IntCRC:=integer(CRC);

     NewPath:=FileName;
     Delete(NewPath,1,Len);
     NewPath:=ToPath+NewPath;
     NewDir:=AnsiLowerCase(GetDirectory(NewPath));
     UnFormatDir(NewDir);

     CRC:=0;
     CalcStringCRC32(AnsiLowerCase(NewDir),CRC);
     if not CheckBox1.Checked or FileExists(NewPath)  then
     begin
      _sqlexectext:='UPDATE '+GetDefDBname+' SET FFileName="'+AnsiLowerCase(NormalizeDBString(NewPath))+'" , FolderCRC = '+Format('%d',[crc])+' where ID = '+IntToStr(WorkQuery.FieldByName('ID').AsInteger);
      SetSQL(TempQuery,_sqlexectext);
      try
       ExecSQL(TempQuery);
       Inc(Count);
      except
       on e : Exception do
       begin
        Working:=false;
        MessageBoxDB(Handle,Format(TEXT_MES_CHANGING_PATH_FAILED,[e.Message]),TEXT_MES_INFORMATION,TD_BUTTON_OK,TD_ICON_INFORMATION);
        SetEnabledControls;
        exit;
       end;
      end;
     end;
    end;
   end;
   WorkQuery.Next;
  end;

  FreeDS(TempQuery);
  FreeDS(WorkQuery);
 except
  on e : Exception do
  begin
   Working:=false;  
   MessageBoxDB(Handle,Format(TEXT_MES_CHANGING_PATH_FAILED,[e.Message]),TEXT_MES_INFORMATION,TD_BUTTON_OK,TD_ICON_INFORMATION);
   SetEnabledControls;
   exit;
  end;
 end;
 Working:=false;
 MessageBoxDB(Handle,Format(TEXT_MES_CHANGING_PATH_OK,[Count]),TEXT_MES_INFORMATION,TD_BUTTON_OK,TD_ICON_INFORMATION);  
 SetEnabledControls;
 if MessageBoxDB(Handle,TEXT_MES_RELOAD_DATA,TEXT_MES_INFORMATION,TD_BUTTON_OKCANCEL,TD_ICON_QUESTION)=ID_OK then
 begin
  DBKernel.DoIDEvent(nil,0,[EventID_Param_Refresh_Window],EventInfo);
 end;
 Close;
end;

initialization

FormChangeDBPath := nil;

end.
