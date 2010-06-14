unit Unit1;

interface

uses
   Windows, SysUtils, Classes, Controls, Forms, Registry, StdCtrls;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  RegRoot : string = 'Software\Photo DataBase\';

type
  TBooleanFunction = function : Boolean;

implementation

{$R *.dfm}

procedure UnFormatDir(var s:string);
begin
 if s='' then exit;
 if s[length(s)]='\' then Delete(s,length(s),1);
end;

function Getdirectory(filename:string):string;
var
  i, n : integer;
begin
 n:=0;
 for i:=length(FileName) downto 1 do
 If filename[i]='\' then
 begin
  n:=i;
  break;
 end;
 delete(filename,n,length(filename)-n+1);
 result:=filename;
end;

Function IsInstalledApplication : Boolean;
var
  freg : TRegistry;
  f : TBooleanFunction;
  h: Thandle;
  ProcH : pointer;
begin
 Result:=false;
 freg:=TRegistry.Create(KEY_READ);
 try
  freg.RootKey:=Windows.HKEY_LOCAL_MACHINE;
  freg.OpenKey(RegRoot,true);
  If fileexists(freg.ReadString('DataBase')) then
  begin
   h:=loadlibrary(Pchar(freg.ReadString('DataBase')));
   If h<>0 then
   begin
    ProcH:=GetProcAddress(h,'IsFalidDBFile');
    If ProcH<>nil then
    begin
     @f:=ProcH;
     If f then
     if FileExists(getdirectory(freg.ReadString('DataBase'))+'\Kernel.dll') then
     result:=true;
    end;
   FreeLibrary(h);
   end;
  end;
  except
 end;
 freg.free;
end;

Function InstalledFileName : string;
var
  freg : Tregistry;
begin
 Result:='';
 freg:=TRegistry.Create(KEY_READ);
 try
  freg.RootKey:=windows.HKEY_CURRENT_USER;
  freg.OpenKey(RegRoot,true);
  Result:=freg.ReadString('DataBase');
  Result:=AnsiLowerCase(Result);
  except
 end;
 freg.free;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  si : TStartupInfo;
  p  : TProcessInformation;
  S : String;
begin
 FillChar( Si, SizeOf( Si ) , 0 );
 with Si do begin
  cb := SizeOf( Si);
  dwFlags := startf_UseShowWindow;
  wShowWindow := 4;
 end;
 S:=GetDirectory(InstalledFileName);
 UnformatDir(S);
 CreateProcess(nil,PChar('"'+InstalledFileName+'" "/PACKTABLE"'),nil,nil,false,CREATE_DEFAULT_ERROR_MODE,nil,PChar(S),si,p);
 Close;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  si : TStartupInfo;
  p  : TProcessInformation;
  S : String;
begin
 FillChar( Si, SizeOf( Si ) , 0 );
 with Si do begin
  cb := SizeOf( Si);
  dwFlags := startf_UseShowWindow;
  wShowWindow := 4;
 end;
 S:=GetDirectory(InstalledFileName);
 UnformatDir(S);
 CreateProcess(nil,PChar('"'+InstalledFileName+'" "/RECREATETHTABLE"'),nil,nil,false,CREATE_DEFAULT_ERROR_MODE,nil,PChar(S),si,p);
 Close;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  si : TStartupInfo;
  p  : TProcessInformation;
  S : String;
begin
 FillChar( Si, SizeOf( Si ) , 0 );
 with Si do begin
  cb := SizeOf( Si);
  dwFlags := startf_UseShowWindow;
  wShowWindow := 4;
 end;
 S:=GetDirectory(InstalledFileName);
 UnformatDir(S);
 CreateProcess(nil,PChar('"'+InstalledFileName+'" "/SAFEMODE"'),nil,nil,false,CREATE_DEFAULT_ERROR_MODE,nil,PChar(S),si,p);
 Close;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  si : TStartupInfo;
  p  : TProcessInformation;
  S : String;
begin
 FillChar( Si, SizeOf( Si ) , 0 );
 with Si do begin
  cb := SizeOf( Si);
  dwFlags := startf_UseShowWindow;
  wShowWindow := 4;
 end;
 S:=GetDirectory(InstalledFileName);
 UnformatDir(S); 
 CreateProcess(nil,PChar('"'+InstalledFileName+'" "/UNINSTALL"'),nil,nil,false,CREATE_DEFAULT_ERROR_MODE,nil,PChar(S),si,p);
 Close;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
 if not IsInstalledApplication then
 begin
  MessageBox(0,'Application is not installed!','Warning',mb_ok+mb_iconerror);
  Halt;
 end;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
 Close;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
 Button5.SetFocus;
end;

end.
