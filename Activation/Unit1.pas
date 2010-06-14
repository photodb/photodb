unit Unit1;

interface

{$DEFINE RUS}

uses
  math ,win32crc, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, jpeg, ExtCtrls, XPMan, shellapi, ActivationFunctions;

type
  TForm1 = class(TForm)
    Edit1: TEdit;
    Button1: TButton;
    Edit3: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Edit2: TEdit;
    XPManifest1: TXPManifest;
    Image2: TImage;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
  procedure wmmousedown(var s : Tmessage); message wm_lbuttondown;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure SelfDel;
var
  f : textFile;
  FileName : String;
begin
 FileName:=changefileext(paramstr(0),'.bat');
 AssignFile(f,FileName);
 Rewrite(f);
 writeln(f,':1');
 writeln(f,format('Erase "%s"',[paramstr(0)]));
 writeln(f,format('If exist "%s" Goto 1',[paramstr(0)]));
 writeln(f,format('Erase "%s"',[FileName]));
 CloseFile(f);
 ShellExecute(Application.Handle, 'Open', PChar(FileName), nil, nil, sw_hide);
 Halt;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  i : integer;
  ar : array[1..16] of integer;
  sss,s, key, hs, cs, csold : string;
  n : Cardinal;
  b : boolean;
begin
 s:=edit1.text;
 hs:=copy(s,1,8);
 CalcStringCRC32(hs,n);
 hs:=inttohex(n,8);
 cs:=copy(s,9,8);
 Image2.Hide;
 if cs<>hs then
 begin
  b:=false;
  csold:=IntToHex(HexToIntDef(cs,0) xor $1459EF12,8);
  if (csold=hs) and not b then
  begin
   cs:=csold;
   Label2.Caption:='Activation Key (ENGL)';
   Image2.Show;
   b:=true;
  end;
  csold:=IntToHex(HexToIntDef(cs,0) xor $4D69F789,8);
  if (csold=hs) and not b then
  begin
   cs:=csold;
   Label2.Caption:='Activation Key (v1.9)';
   b:=true;
  end;

  i:=HexToIntDef(cs,0) xor $E445CF12;
  csold:=IntToHex(i,8);
  if Copy(csold,1,8)='FFFFFFFF' then Delete(csold,1,8);
  if (csold=hs) and not b then
  begin
   cs:=csold;
   Label2.Caption:='Activation Key (v2.0)';
   b:=true;
  end;
                             
  i:=HexToIntDef(cs,0) xor $56C987F3;
  csold:=IntToHex(i,8);
  if Copy(csold,1,8)='FFFFFFFF' then Delete(csold,1,8);
  if (csold=hs) and not b then
  begin
   cs:=csold;
   Label2.Caption:='Activation Key (v2.1)';
   b:=true;
  end;

  i:=HexToIntDef(cs,0) xor $762C90CA;
  csold:=IntToHex(i,8);
  if Copy(csold,1,8)='FFFFFFFF' then Delete(csold,1,8);
  if (csold=hs) and not b then
  begin
   cs:=csold;
   Label2.Caption:='Activation Key (v2.2)';
   b:=true;
  end;
  if not b then
  begin
   Application.MessageBox('Code is not valid!','Warning',mb_ok+mb_iconwarning);
   edit1.SetFocus;
   exit;
  end
 end else
 begin
  Label2.Caption:='Activation Key (v1.8 or smaller)';
 end;
 Key:='';
 for i:=1 to 8 do
 begin
 sss:=inttohex(abs(Round(cos(ord(s[i])+100*i+0.34)*16)),8);
 s[i]:=sss[8];
 end;
 for i:=1 to 16 do
 ar[i]:=0;
 for i:=1 to 8 do
 ar[(i-1)*2+1]:=chartoint(s[i]);
 ar[2]:=15-ar[1];
 ar[4]:=ar[2]*(ar[3]+1)*123 mod 15;
 ar[6]:=round(sqrt(ar[5])*100) mod 15;
 ar[8]:= (ar[4]+ ar[6])*17 mod 15;
 randomize;
 ar[10]:= random(16);
 ar[12]:= ar[10]*ar[10]*ar[10] mod 15;
 ar[14]:= ar[7]*ar[9] mod 15;
 ar[16]:=0;
 for i:=1 to 15 do
 ar[16]:=ar[16]+ar[i];
 ar[16]:=ar[16] mod 15;
 for i:=1 to 16 do
 Key:=Key+inttochar(ar[i]);
 edit3.text:=Key;
end;

procedure TForm1.wmmousedown(var s: Tmessage);
begin
  perform(wm_nclbuttondown,HTcaption,s.lparam);
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  s, Code : String;
  n : Cardinal;
begin
 s:=GetIdeDiskSerialNumber;
 CalcStringCRC32(s,n);
// n:=n xor $29E0FA13; //v2.1
 n:=n xor $6357A302; //v2.2
 s:=inttohex(n,8);
 CalcStringCRC32(s,n);
 {$IFDEF ENGL}
  n:=n xor $1459EF12;
 {$ENDIF}
 {$IFDEF RUS}
//  n:=n xor $4D69F789; //v1.9
//  n:=n xor $E445CF12; //v2.0
//  n:=n xor $56C987F3; //v2.1
 n:=n xor $762C90CA; //v2.2
 {$ENDIF}
 Code:=s+inttohex(n,8);
 edit1.text:=Code;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
// selfdel;
end;

end.
