unit UnitLinksSupport;

interface

{$DEFINE RUS}
//{$DEFINE ENGL}

uses
  Windows, SysUtils, StrUtils, Dolphin_DB, Language, UnitDBDeclare;

const
  LINK_TYPE_ID       = 0;
  LINK_TYPE_ID_EXT   = 1;
  LINK_TYPE_IMAGE    = 2;
  LINK_TYPE_FILE     = 3;
  LINK_TYPE_FOLDER   = 4;
  LINK_TYPE_TXT      = 5;
  LINK_TYPE_HTML     = 6;
  
{$IFDEF RUS}
  LINK_TEXT_TYPE_ID       = 'ID';
  LINK_TEXT_TYPE_ID_EXT   = 'IDExt';
  LINK_TEXT_TYPE_IMAGE    = 'Изображение';
  LINK_TEXT_TYPE_FILE     = 'Файл';
  LINK_TEXT_TYPE_FOLDER   = 'Папка';
  LINK_TEXT_TYPE_TXT      = 'Текст';
  LINK_TEXT_TYPE_HTML     = 'HTML';
{$ENDIF}

{$IFDEF ENGL}
  LINK_TEXT_TYPE_ID       = 'ID';
  LINK_TEXT_TYPE_ID_EXT   = 'IDExt';
  LINK_TEXT_TYPE_IMAGE    = 'Image';
  LINK_TEXT_TYPE_FILE     = 'File';
  LINK_TEXT_TYPE_FOLDER   = 'Folder';
  LINK_TEXT_TYPE_TXT      = 'Text';
  LINK_TEXT_TYPE_HTML     = 'HTML';
{$ENDIF}

type

   TLinkInfo = record
    LinkType : byte;
    LinkName : String;
    LinkValue : String;
    Tag : byte; //unused by default
   end;

const

   LINK_TAG_NONE                 = $0001;
   LINK_TAG_SELECTED             = $0002;
   LINK_TAG_VALUE_VAR_NOT_SELECT = $0004;

type

   TLinksInfo = array of TLinkInfo;

   TArLinksInfo = array of TLinksInfo;

   TSetLinkProcedure = procedure(Sender : TObject; ID : String; Info : TLinkInfo; N : integer; Action : Integer) of object;

const
   LINK_PROC_ACTION_ADD    = 0;
   LINK_PROC_ACTION_MODIFY = 1;

function CodeLinkInfo(info : TLinkInfo) : String;
function CodeLinksInfo(info : TLinksInfo) : String;
function ParseLinksInfo(Info : String) : TLinksInfo;
function CopyLinksInfo(info : TLinksInfo) : TLinksInfo;
function VariousLinks(info1, info2 : TLinksInfo) : boolean; overload;
function VariousLinks(info1, info2 : String) : boolean; overload;

function DeleteLinkAtPos(var info : String; pos : integer) : boolean; overload;
function DeleteLinkAtPos(var info : TLinksInfo; pos : integer) : boolean; overload;

function GetCommonLinks(info : TArLinksInfo) : TLinksInfo; overload;
function GetCommonLinks(info : TArStrings) : TLinksInfo; overload;

Procedure ReplaceLinks(LinksToDelete, LinksToAdd : TLinksInfo; var Links : TLinksInfo); overload;
Procedure ReplaceLinks(LinksToDelete, LinksToAdd : String; var Links : String); overload;

function CompareLinks(LinksA, LinksB : TLinksInfo; Simple : boolean = false) : Boolean; overload;
Function CompareLinks(LinksA, LinksB : string; Simple : boolean = false) : Boolean; overload;

function LinkInLinksExists(Link : TLinkInfo; Links : TLinksInfo; UseValue : boolean = true) : boolean;

function CodeExtID(ExtID : String) : String;
function DeCodeExtID(S : String) : String;
function CompareTwoLinks(Link1, Link2 : TLinkInfo; UseValue: boolean = false) : boolean;

function LinkType(LinkTypeN : integer) : String;

implementation

function CompareTwoLinks(Link1, Link2 : TLinkInfo; UseValue: boolean = false) : boolean;
begin
 Result:=false;
 if Link1.LinkType=Link2.LinkType then
 if AnsiLowerCase(Link1.LinkName)=AnsiLowerCase(Link2.LinkName) then
 if (AnsiLowerCase(Link1.LinkValue)=AnsiLowerCase(Link2.LinkValue)) or not UseValue then
 Result:=true;
end;

function CopyLinksInfo(info : TLinksInfo) : TLinksInfo;
var
  i : integer;
begin
 SetLength(Result,length(info));
 for i:=0 to length(info)-1 do
 begin
  Result[i]:=info[i];
 end;
end;

function CodeLinkInfo(info : TLinkInfo) : String;
begin
 Result:='['+IntToStr(info.LinkType)+']{'+info.LinkName+'}'+info.LinkValue+';';
end;

function CodeLinksInfo(info : TLinksInfo) : String;
var
  i : integer;
begin
 Result:='';
 for i:=0 to Length(info)-1 do
 begin
  Result:=Result+'['+IntToStr(info[i].LinkType)+']{'+info[i].LinkName+'}'+info[i].LinkValue+';';
 end;
end;

function ParseLinksInfo(Info : String) : TLinksInfo;
var
  i, c,l : integer;
  s : String;

  Procedure AddOneLink(aInfo : String);
  var
    s1,s2,s3,s4,s5 : integer;
  begin
   s1:=Pos('[',aInfo);
   s2:=PosEx(']',aInfo,s1);
   s3:=PosEx('{',aInfo,s2);
   s4:=PosEx('}',aInfo,s3);
   s5:=PosEx(';',aInfo,s4);
   if (s1<>0) and (s2<>0) and (s3<>0) and (s4<>0) and (s5<>0) then
   begin
    l := Length(Result);
    SetLength(Result,l+1);
    Result[l].LinkType:=StrToIntDef(Copy(aInfo,s1+1,s2-s1-1),0);
    Result[l].LinkName:=Copy(aInfo,s3+1,s4-s3-1);
    Result[l].LinkValue:=Copy(aInfo,s4+1,s5-s4-1);
    Result[l].Tag:=LINK_TAG_NONE;
   end;
  end;

begin
 c:=0;
 SetLength(Result,0);
 for i:=1 to Length(Info) do
 if Info[i]=';' then
 begin
  s:=Copy(Info,c,i-c+1);
  AddOneLink(s);
  c:=i+1;
 end;
end;

function LinkInLinksExists(Link : TLinkInfo; Links : TLinksInfo; UseValue : boolean = true) : boolean;
var
  i : integer;
begin
 Result:=false;
 for i:=0 to Length(Links)-1 do
 begin
  if Link.LinkType=Links[i].LinkType then
  if AnsiLowerCase(Link.LinkName)=AnsiLowerCase(Links[i].LinkName) then
  if (AnsiLowerCase(Link.LinkValue)=AnsiLowerCase(Links[i].LinkValue)) or not UseValue then
  begin
   Result:=true;
   exit;
  end;
 end;
end;

function VariousLinks(info1, info2 : String) : boolean;
begin
 Result:=VariousLinks(ParseLinksInfo(info1),ParseLinksInfo(info2));
end;

function VariousLinks(info1, info2 : TLinksInfo) : boolean;
var
  i : integer;
begin
 Result:=false;
 for i:=0 to Length(info1)-1 do
 if not LinkInLinksExists(info1[i],info2) then
 begin
  Result:=true;
  exit;
 end;
 for i:=0 to Length(info2)-1 do
 if not LinkInLinksExists(info2[i],info1) then
 begin
  Result:=true;
  exit;
 end;
end;

function DeleteLinkAtPos(var info : String; pos : integer) : boolean;
var
  Tinfo : TLinksInfo;
begin
 Tinfo:=ParseLinksInfo(info);
 Result:=DeleteLinkAtPos(Tinfo,pos);
 info:=CodeLinksInfo(Tinfo);
end;

function DeleteLinkAtPos(var info : TLinksInfo; pos : integer) : boolean;
var
  i : integer;
begin
 Result:=false;
 if Length(info)-1<pos then exit;
 for i:=pos to Length(info)-2 do
 info[i]:=info[i+1];
 SetLength(info,Length(info)-1);
end;

procedure DeleteLinkInLinks(var info : TLinksInfo; Link : TLinkInfo; DeleteNoVal : boolean = true);
var
  i, j : Integer;
begin
 For i:=0 to Length(info)-1 do
 if Link.LinkType=info[i].LinkType then
 if AnsiLowerCase(Link.LinkName)=AnsiLowerCase(info[i].LinkName) then
 if (AnsiLowerCase(Link.LinkValue)=AnsiLowerCase(info[i].LinkValue)) or DeleteNoVal then
 begin
  For j:=i to Length(info)-2 do
  info[j]:=info[j+1];
  SetLength(info,Length(info)-1);
  Exit;
 end;
end;

function GetCommonLinks(info : TArStrings) : TLinksInfo;
var
  i : integer;
  Tinfo : TArLinksInfo;
begin
 SetLength(Tinfo,Length(info));
 for i:=0 to Length(info)-1 do
 Tinfo[i]:=ParseLinksInfo(info[i]);
 Result:=GetCommonLinks(Tinfo);
end;

function GetCommonLinks(info : TArLinksInfo) : TLinksInfo;
var
  i, j : integer;
begin
 if Length(info)=0 then exit;
 Result:=CopyLinksInfo(info[0]);
 for i:=1 to length(info)-1 do
 begin
  if length(info[i])=0 then
  begin
   SetLength(Result,0);
   Break;
  end;
  for j:=length(Result)-1 downto 0 do
  if not LinkInLinksExists(Result[j],info[i],false) then
  DeleteLinkInLinks(Result,Result[j]);
  If Length(Result)=0 then Exit;
 end;
 for i:=0 to length(Result)-1 do
 Result[i].Tag:=LINK_TAG_NONE;
 for i:=0 to length(Result)-1 do
 begin
  for j:=0 to length(info)-1 do
  begin
   if not LinkInLinksExists(Result[i],info[j],true) then
   begin
    Result[i].Tag:=LINK_TAG_VALUE_VAR_NOT_SELECT;
    Break;
   end;
  end;
 end;
end;

procedure DeleteLinksFromLinks(var Links : TLinksInfo; LinksToDelete : TLinksInfo; DeleteNoVal : boolean = true);
var
  i : integer;
begin
 for i:=0 to Length(LinksToDelete)-1 do
 if LinksToDelete[i].Tag = LINK_TAG_NONE then
 DeleteLinkInLinks(Links,LinksToDelete[i], DeleteNoVal);
end;

procedure AddLinkToLinks(var Links : TLinksInfo; LinksToAdd : TLinkInfo);
begin
 SetLength(Links,Length(Links)+1);
 Links[Length(Links)-1]:=LinksToAdd;
end;

procedure AddLinksToLinks(var Links : TLinksInfo; LinksToAdd : TLinksInfo);
var
  i : integer;
begin
 for i:=0 to Length(LinksToAdd)-1 do
 if LinksToAdd[i].Tag and LINK_TAG_VALUE_VAR_NOT_SELECT=0 then
 AddLinkToLinks(Links,LinksToAdd[i]);
end;

Procedure ReplaceLinks(LinksToDelete, LinksToAdd : String; var Links : String);
var
  LA, LB, LR : TLinksInfo;
begin
 LA:=ParseLinksInfo(LinksToDelete);
 LB:=ParseLinksInfo(LinksToAdd);
 LR:=ParseLinksInfo(Links);
 ReplaceLinks(LA,LB,LR);
 Links:=CodeLinksInfo(LR);
end;

Procedure ReplaceLinks(LinksToDelete, LinksToAdd : TLinksInfo; var Links : TLinksInfo);
var
  i, j : integer;
  b : boolean;
begin
 for i:=0 to Length(LinksToDelete)-1 do
 if LinksToDelete[i].Tag and LINK_TAG_VALUE_VAR_NOT_SELECT<>0 then
 begin
  b:=false;
  for j:=0 to Length(LinksToAdd)-1 do
  begin
   if (LinksToAdd[j].LinkType=LinksToDelete[i].LinkType) and (AnsiLowerCase(LinksToAdd[j].LinkName)=AnsiLowerCase(LinksToDelete[i].LinkName)) then
   begin
    b:=true;
    break;
   end;
  end;
  if not b then LinksToDelete[i].Tag:=LINK_TAG_NONE;
 end;
 for i:=0 to Length(LinksToAdd)-1 do
 if LinksToAdd[i].Tag and LINK_TAG_VALUE_VAR_NOT_SELECT=0 then
 begin
  for j:=0 to Length(LinksToDelete)-1 do
  begin
   if (LinksToAdd[i].LinkType=LinksToDelete[j].LinkType) and (AnsiLowerCase(LinksToAdd[i].LinkName)=AnsiLowerCase(LinksToDelete[j].LinkName)) then
   begin
    LinksToDelete[i].Tag:=LINK_TAG_NONE;
   end;
  end;
 end;
 DeleteLinksFromLinks(Links,LinksToDelete,true);
 AddLinksToLinks(Links,LinksToAdd);
end;

Function CompareLinks(LinksA, LinksB : String; Simple : boolean = false) : Boolean;
var
  LA, LB : TLinksInfo;
begin
 LA:=ParseLinksInfo(LinksA);
 LB:=ParseLinksInfo(LinksB);
 Result:=CompareLinks(LA,LB,Simple);
end;

Function CompareLinks(LinksA, LinksB : TLinksInfo; Simple : boolean = false) : Boolean;
var
  i : integer;
begin
 Result:=True;
 if not Simple then
 begin
  for i:=0 to length(LinksA)-1 do
  begin
   if not LinkInLinksExists(LinksA[i],LinksB) then
   begin
    Result:=False;
    Break;
   end;
  end;
  for i:=0 to length(LinksB)-1 do
  begin
   if not LinkInLinksExists(LinksB[i],LinksA) then
   begin
    Result:=False;
    Break;
   end;
  end;
 end else
 begin
  if length(LinksA)<>length(LinksB) then
  begin
   Result:=False;
   exit;
  end;
  for i:=0 to length(LinksA)-1 do
  begin
   if not CompareTwoLinks(LinksA[i],LinksB[i],true) then
   begin
    Result:=False;
    Break;
   end;
  end;
 end;
end;

function CodeExtID(ExtID : String) : String;
var
  i : integer;
begin
 Result:='';
 for i:=1 to Length(ExtID) do
 begin
  Result:=Result+IntToHex(Byte(ExtID[i]),2);
 end;
end;

function DeCodeExtID(S : String) : String;
var
  i : integer;
  Str : String;
begin
 Result:='';
 for i:=1 to (Length(S) div 2) do
 begin
  Str:=Copy(S,1+2*(i-1),2);
  if FIXIDEX then if not ((i=200) and (Str='20')) then
  Result:=Result+Char(HexToIntDef(Str,32));
 end;
end;

function LinkType(LinkTypeN : integer) : String;
begin
 Result:=TEXT_MES_UNKNOWN;
  if LinkTypeN=LINK_TYPE_ID then Result:=LINK_TEXT_TYPE_ID;
  if LinkTypeN=LINK_TYPE_ID_EXT then Result:=LINK_TEXT_TYPE_ID_EXT;
  if LinkTypeN=LINK_TYPE_IMAGE then Result:=LINK_TEXT_TYPE_IMAGE;
  if LinkTypeN=LINK_TYPE_FILE then Result:=LINK_TEXT_TYPE_FILE;
  if LinkTypeN=LINK_TYPE_FOLDER then Result:=LINK_TEXT_TYPE_FOLDER;
  if LinkTypeN=LINK_TYPE_TXT then Result:=LINK_TEXT_TYPE_TXT;
  if LinkTypeN=LINK_TYPE_HTML then Result:=LINK_TEXT_TYPE_HTML;
end;

end.
