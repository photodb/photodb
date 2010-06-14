unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, strutils, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Memo1: TMemo;
    Memo2: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  i, j : integer;
  t : tstrings;
  s, s1, s2 : string;
  aname, avalue : string;
  ns : tstrings;
  n, n1 : integer;
  nnn, nf : integer;
begin
 t := tstringlist.create;
 ns := tstringlist.create;
 nf:=0;
 t.LoadFromFile('D:\Documents and Settings\Administrator.SERVER1\My Documents\Photo DataBase\Units\Language.pas');
 ns.Add('unit ReplaseLanguageInScript;');
 ns.Add('');
 ns.Add('interface');
 ns.Add('');
 ns.Add('uses SysUtils;');
 ns.Add('');
 ns.Add('function AddLanguage(script : string) : string;');
 ns.Add('');
 ns.Add('implementation');
 ns.Add('');
 ns.Add('function AddLanguage(script : string) : string;');
 ns.Add('begin');
 nnn:=0;

 for i:=t.Count-1 downto 1 do
 begin
  s:=t[i];
  if Copy(s,1,Length(' TEXT_MES_'))=' TEXT_MES_' then
  begin
   n:= Pos('=',s);
   aname:=Copy(s,2,n-3);
   n1:=Pos(''';',s);
   avalue:=Copy(s,n+3,n1-n-3);
   if (n1<>0) and (n<>0) then
   if Pos('+#13+',avalue)=0 then
   if Pos('''+''',avalue)=0 then
   if Pos('TEXT_MES_',avalue)=0 then
   continue;
  end;
  t.Delete(i);
 end;

 for j:=0 to t.Count-1 do
 for i:=0 to t.Count-2 do
 begin
  s:=t[i];
  if Copy(s,1,Length(' TEXT_MES_'))=' TEXT_MES_' then
  begin
   n:= Pos('=',s);
   aname:=Copy(s,2,n-3);
   n1:=Pos(''';',s);
   avalue:=Copy(s,n+3,n1-n-3);
   if (n1<>0) and (n<>0) then
   if Pos('+#13+',avalue)=0 then
   if Pos('''+''',avalue)=0 then
   if Pos('TEXT_MES_',avalue)=0 then
   begin
    s1:=aname;
    s:=t[i+1];
    if Copy(s,1,Length(' TEXT_MES_'))=' TEXT_MES_' then
    begin
     n:= Pos('=',s);
     aname:=Copy(s,2,n-3);
     n1:=Pos(''';',s);
     avalue:=Copy(s,n+3,n1-n-3);
     if (n1<>0) and (n<>0) then
     if Pos('+#13+',avalue)=0 then
     if Pos('''+''',avalue)=0 then
     if Pos('TEXT_MES_',avalue)=0 then
     begin
      s2:=aname;
      if Length(s1)<Length(s2) then
      begin
       s:=t[i];
       t[i]:=t[i+1];
       t[i+1]:=s;
      end;
     end;
    end;
   end;
  end;
 end;

 for i:=0 to t.Count-1 do
 begin
  s:=t[i];
  if Copy(s,1,Length(' TEXT_MES_'))=' TEXT_MES_' then
  begin
   n:= Pos('=',s);
   aname:=Copy(s,2,n-3);
   n1:=Pos(''';',s);
   avalue:=Copy(s,n+3,n1-n-3);
   if (n1<>0) and (n<>0) then
   if Pos('+#13+',avalue)=0 then
   if Pos('''+''',avalue)=0 then
   if Pos('TEXT_MES_',avalue)=0 then
   begin
    ns.Add('script:=StringReplace(script,'''+aname+''','''+avalue+''',[rfReplaceAll]);');
    inc(nnn);
    if nnn>50 then
    begin
     inc(nf);
     ns.Add('Result:=AddLanguageX'+inttostr(nf)+'(script);');
     ns.Add('end;');
     s:='function AddLanguageX'+inttostr(nf)+'(script : string) : string;';
     ns.Insert(6,s);
     ns.Add(s);
     ns.Add('begin');
     nnn:=0;

    end;
   end;
  end;
 end;
 ns.Add('Result:=script;');
 ns.Add('end;');
 ns.Add('end.');
 ns.SaveToFile('D:\Documents and Settings\Administrator.SERVER1\My Documents\Photo DataBase\Units\ReplaseLanguageInScript.pas');
end;


procedure TForm1.Button2Click(Sender: TObject);
var
  i, j : integer;
  t : tstrings;
  s, s1, s2 : string;
  aname, avalue : string;
  ns : tstrings;
  n, n1 : integer;
  nnn, nf : integer;
begin
 t := tstringlist.create;
 ns := tstringlist.create;
 nf:=0;
 t.assign(memo1.lines);
 ns.Add('unit ReplaseIconsInScript;');
 ns.Add('');
 ns.Add('interface');
 ns.Add('');
 ns.Add('uses SysUtils;');
 ns.Add('');
 ns.Add('function AddIcons(script : string) : string;');
 ns.Add('');
 ns.Add('implementation');
 ns.Add('');
 ns.Add('function AddIcons(script : string) : string;');
 ns.Add('begin');
 nnn:=0;


 for j:=0 to t.Count-1 do
 for i:=0 to t.Count-2 do
 begin
  s:=t[i];
  if Copy(s,1,Length('DB_IC_'))='DB_IC_' then
  begin
   n:= Pos('=',s);
   aname:=Trim(Copy(s,1,n-2));
   n1:=Pos(';',s);
   avalue:=Trim(Copy(s,n+1,n1-n-1));
   if (n1<>0) and (n<>0) then
   if Pos('+#13+',avalue)=0 then
   if Pos('''+''',avalue)=0 then
   begin
    s1:=aname;
    s:=t[i+1];
    if Copy(s,1,Length('DB_IC_'))='DB_IC_' then
    begin
     n:= Pos('=',s);
     aname:=Trim(Copy(s,1,n-2));
     n1:=Pos(';',s);
     avalue:=Trim(Copy(s,n+1,n1-n-1));
     if (n1<>0) and (n<>0) then
     if Pos('+#13+',avalue)=0 then
     if Pos('''+''',avalue)=0 then
     begin
      s2:=aname;
      if Length(s1)<Length(s2) then
      begin
       s:=t[i];
       t[i]:=t[i+1];
       t[i+1]:=s;
      end;
     end;
    end;
   end;
  end;
 end;



 for i:=0 to t.Count-1 do
 begin
  s:=t[i];
  if Copy(s,1,Length('DB_IC_'))='DB_IC_' then
  begin
   n:= Pos('=',s);
   aname:=Trim(Copy(s,1,n-1)+' ');
   n1:=Pos(';',s);
   avalue:=Trim(Copy(s,n+1,n1-n-1));
   if (n1<>0) and (n<>0) then
   if Pos('+#13+',avalue)=0 then
   if Pos('''+''',avalue)=0 then
   if Pos('DB_IC_',avalue)=0 then
   begin
    ns.Add('script:=StringReplace(script,'''+aname+''','''+avalue+''',[rfReplaceAll]);');
    inc(nnn);
    if nnn>50 then
    begin
     inc(nf);
     ns.Add('Result:=AddIconsX'+inttostr(nf)+'(script);');
     ns.Add('end;');
     s:='function AddIconsX'+inttostr(nf)+'(script : string) : string;';
     ns.Insert(6,s);
     ns.Add(s);
     ns.Add('begin');
     nnn:=0;

    end;
   end;
  end;
 end;
 ns.Add('Result:=script;');
 ns.Add('end;');
 ns.Add('end.');
 memo2.Lines.Assign(ns);
 ns.SaveToFile('D:\Dmitry\Delphi exe\db\Photo DataBase\Units\ReplaseIconsInScript.pas');
end;

end.
