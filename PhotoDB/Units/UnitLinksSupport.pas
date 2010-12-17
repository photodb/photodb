unit UnitLinksSupport;

interface

uses
  Windows, SysUtils, Classes, StrUtils, uTranslate, UnitDBDeclare, UnitDBCommon,
  uConstants;

const
  LINK_TYPE_ID       = 0;
  LINK_TYPE_ID_EXT   = 1;
  LINK_TYPE_IMAGE    = 2;
  LINK_TYPE_FILE     = 3;
  LINK_TYPE_FOLDER   = 4;
  LINK_TYPE_TXT      = 5;
  LINK_TYPE_HTML     = 6;

  LINK_TEXT_TYPE_ID       = 'ID';
  LINK_TEXT_TYPE_ID_EXT   = 'IDExt';
  LINK_TEXT_TYPE_IMAGE    = 'Image';
  LINK_TEXT_TYPE_FILE     = 'File';
  LINK_TEXT_TYPE_FOLDER   = 'Folder';
  LINK_TEXT_TYPE_TXT      = 'Text';
  LINK_TEXT_TYPE_HTML     = 'HTML';
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

function GetCommonLinks(LinksList : TStringList) : TLinksInfo; overload;
function GetCommonLinks(info : TArLinksInfo) : TLinksInfo; overload;

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

 function CompareTwoLinks(Link1, Link2: TLinkInfo; UseValue: Boolean = False): Boolean;
 begin
   Result := False;
   if Link1.LinkType = Link2.LinkType then
     if AnsiLowerCase(Link1.LinkName) = AnsiLowerCase(Link2.LinkName) then
       if (AnsiLowerCase(Link1.LinkValue) = AnsiLowerCase(Link2.LinkValue)) or not UseValue then
         Result := True;
 end;

function CopyLinksInfo(Info: TLinksInfo): TLinksInfo;
var
  I: Integer;
begin
  SetLength(Result, Length(Info));
  for I := 0 to Length(Info) - 1 do
    Result[I] := Info[I];
end;

function CodeLinkInfo(Info: TLinkInfo): string;
begin
  Result := '[' + IntToStr(Info.LinkType) + ']{' + Info.LinkName + '}' + Info.LinkValue + ';';
end;

function CodeLinksInfo(Info: TLinksInfo): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Length(Info) - 1 do
    Result := Result + '[' + IntToStr(Info[I].LinkType) + ']{' + Info[I].LinkName + '}' + Info[I].LinkValue + ';';
end;

function ParseLinksInfo(Info : String) : TLinksInfo;
var
  I, C, L: Integer;
  S: string;

  procedure AddOneLink(AInfo: string);
  var
    S1, S2, S3, S4, S5: Integer;
  begin
    S1 := Pos('[', AInfo);
    S2 := PosEx(']', AInfo, S1);
    S3 := PosEx('{', AInfo, S2);
    S4 := PosEx('}', AInfo, S3);
    S5 := PosEx(';', AInfo, S4);
    if (S1 <> 0) and (S2 <> 0) and (S3 <> 0) and (S4 <> 0) and (S5 <> 0) then
    begin
      L := Length(Result);
      SetLength(Result, L + 1);
      Result[L].LinkType := StrToIntDef(Copy(AInfo, S1 + 1, S2 - S1 - 1), 0);
      Result[L].LinkName := Copy(AInfo, S3 + 1, S4 - S3 - 1);
      Result[L].LinkValue := Copy(AInfo, S4 + 1, S5 - S4 - 1);
      Result[L].Tag := LINK_TAG_NONE;
    end;
  end;

begin
  C := 0;
  SetLength(Result, 0);
  for I := 1 to Length(Info) do
    if Info[I] = ';' then
    begin
      S := Copy(Info, C, I - C + 1);
      AddOneLink(S);
      C := I + 1;
    end;
end;

function LinkInLinksExists(Link: TLinkInfo; Links: TLinksInfo; UseValue: Boolean = True): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Length(Links) - 1 do
  begin
    if Link.LinkType = Links[I].LinkType then
      if AnsiLowerCase(Link.LinkName) = AnsiLowerCase(Links[I].LinkName) then
        if (AnsiLowerCase(Link.LinkValue) = AnsiLowerCase(Links[I].LinkValue)) or not UseValue then
        begin
          Result := True;
          Exit;
        end;
  end;
end;

function VariousLinks(Info1, Info2: string): Boolean;
begin
  Result := VariousLinks(ParseLinksInfo(Info1), ParseLinksInfo(Info2));
end;

function VariousLinks(Info1, Info2: TLinksInfo): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Length(Info1) - 1 do
    if not LinkInLinksExists(Info1[I], Info2) then
    begin
      Result := True;
      Exit;
    end;
  for I := 0 to Length(Info2) - 1 do
    if not LinkInLinksExists(Info2[I], Info1) then
    begin
      Result := True;
      Exit;
    end;
end;

function DeleteLinkAtPos(var Info: string; Pos: Integer): Boolean;
var
  Tinfo: TLinksInfo;
begin
  Tinfo := ParseLinksInfo(Info);
  Result := DeleteLinkAtPos(Tinfo, Pos);
  Info := CodeLinksInfo(Tinfo);
end;

function DeleteLinkAtPos(var Info: TLinksInfo; Pos: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  if Length(Info) - 1 < Pos then
    Exit;
  for I := Pos to Length(Info) - 2 do
    Info[I] := Info[I + 1];
  SetLength(Info, Length(Info) - 1);
end;

procedure DeleteLinkInLinks(var Info: TLinksInfo; Link: TLinkInfo; DeleteNoVal: Boolean = True);
var
  I, J: Integer;
begin
  for I := 0 to Length(Info) - 1 do
    if Link.LinkType = Info[I].LinkType then
      if AnsiLowerCase(Link.LinkName) = AnsiLowerCase(Info[I].LinkName) then
        if (AnsiLowerCase(Link.LinkValue) = AnsiLowerCase(Info[I].LinkValue)) or DeleteNoVal then
        begin
          for J := I to Length(Info) - 2 do
            Info[J] := Info[J + 1];
          SetLength(Info, Length(Info) - 1);
          Exit;
        end;
end;

function GetCommonLinks(LinksList: TStringList): TLinksInfo;
var
  I: Integer;
  Tinfo: TArLinksInfo;
begin
  SetLength(Tinfo, LinksList.Count);
  for I := 0 to LinksList.Count - 1 do
    Tinfo[I] := ParseLinksInfo(LinksList[I]);
  Result := GetCommonLinks(Tinfo);
end;

function GetCommonLinks(Info: TArLinksInfo): TLinksInfo;
var
  I, J: Integer;
begin
  if Length(Info) = 0 then
    Exit;
  Result := CopyLinksInfo(Info[0]);
  for I := 1 to Length(Info) - 1 do
  begin
    if Length(Info[I]) = 0 then
    begin
      SetLength(Result, 0);
      Break;
    end;
    for J := Length(Result) - 1 downto 0 do
      if not LinkInLinksExists(Result[J], Info[I], False) then
        DeleteLinkInLinks(Result, Result[J]);
    if Length(Result) = 0 then
      Exit;
  end;
  for I := 0 to Length(Result) - 1 do
    Result[I].Tag := LINK_TAG_NONE;
  for I := 0 to Length(Result) - 1 do
  begin
    for J := 0 to Length(Info) - 1 do
    begin
      if not LinkInLinksExists(Result[I], Info[J], True) then
      begin
        Result[I].Tag := LINK_TAG_VALUE_VAR_NOT_SELECT;
        Break;
      end;
    end;
  end;
end;

procedure DeleteLinksFromLinks(var Links: TLinksInfo; LinksToDelete: TLinksInfo; DeleteNoVal: Boolean = True);
var
  I: Integer;
begin
  for I := 0 to Length(LinksToDelete) - 1 do
    if LinksToDelete[I].Tag = LINK_TAG_NONE then
      DeleteLinkInLinks(Links, LinksToDelete[I], DeleteNoVal);
end;

procedure AddLinkToLinks(var Links: TLinksInfo; LinksToAdd: TLinkInfo);
begin
  SetLength(Links, Length(Links) + 1);
  Links[Length(Links) - 1] := LinksToAdd;
end;

procedure AddLinksToLinks(var Links: TLinksInfo; LinksToAdd: TLinksInfo);
var
  I: Integer;
begin
  for I := 0 to Length(LinksToAdd) - 1 do
    if LinksToAdd[I].Tag and LINK_TAG_VALUE_VAR_NOT_SELECT = 0 then
      AddLinkToLinks(Links, LinksToAdd[I]);
end;

procedure ReplaceLinks(LinksToDelete, LinksToAdd: string; var Links: string);
var
  LA, LB, LR: TLinksInfo;
begin
  LA := ParseLinksInfo(LinksToDelete);
  LB := ParseLinksInfo(LinksToAdd);
  LR := ParseLinksInfo(Links);
  ReplaceLinks(LA, LB, LR);
  Links := CodeLinksInfo(LR);
end;

procedure ReplaceLinks(LinksToDelete, LinksToAdd: TLinksInfo; var Links: TLinksInfo);
var
  I, J: Integer;
  B: Boolean;
begin
  for I := 0 to Length(LinksToDelete) - 1 do
    if LinksToDelete[I].Tag and LINK_TAG_VALUE_VAR_NOT_SELECT <> 0 then
    begin
      B := False;
      for J := 0 to Length(LinksToAdd) - 1 do
      begin
        if (LinksToAdd[J].LinkType = LinksToDelete[I].LinkType) and
          (AnsiLowerCase(LinksToAdd[J].LinkName) = AnsiLowerCase(LinksToDelete[I].LinkName)) then
        begin
          B := True;
          Break;
        end;
      end;
      if not B then
        LinksToDelete[I].Tag := LINK_TAG_NONE;
    end;
  for I := 0 to Length(LinksToAdd) - 1 do
    if LinksToAdd[I].Tag and LINK_TAG_VALUE_VAR_NOT_SELECT = 0 then
    begin
      for J := 0 to Length(LinksToDelete) - 1 do
      begin
        if (LinksToAdd[I].LinkType = LinksToDelete[J].LinkType) and
          (AnsiLowerCase(LinksToAdd[I].LinkName) = AnsiLowerCase(LinksToDelete[J].LinkName)) then
        begin
          LinksToDelete[I].Tag := LINK_TAG_NONE;
        end;
      end;
    end;
  DeleteLinksFromLinks(Links, LinksToDelete, True);
  AddLinksToLinks(Links, LinksToAdd);
end;

function CompareLinks(LinksA, LinksB: string; Simple: Boolean = False): Boolean;
var
  LA, LB: TLinksInfo;
begin
  LA := ParseLinksInfo(LinksA);
  LB := ParseLinksInfo(LinksB);
  Result := CompareLinks(LA, LB, Simple);
end;

function CompareLinks(LinksA, LinksB: TLinksInfo; Simple: Boolean = False): Boolean;
var
  I: Integer;
begin
  Result := True;
  if not Simple then
  begin
    for I := 0 to Length(LinksA) - 1 do
    begin
      if not LinkInLinksExists(LinksA[I], LinksB) then
      begin
        Result := False;
        Break;
      end;
    end;
    for I := 0 to Length(LinksB) - 1 do
    begin
      if not LinkInLinksExists(LinksB[I], LinksA) then
      begin
        Result := False;
        Break;
      end;
    end;
  end
  else
  begin
    if Length(LinksA) <> Length(LinksB) then
    begin
      Result := False;
      Exit;
    end;
    for I := 0 to Length(LinksA) - 1 do
    begin
      if not CompareTwoLinks(LinksA[I], LinksB[I], True) then
      begin
        Result := False;
        Break;
      end;
    end;
  end;
end;

function CodeExtID(ExtID: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(ExtID) do
    Result := Result + IntToHex(Byte(ExtID[I]), 2);
end;

function DeCodeExtID(S: string): string;
var
  I: Integer;
  Str: string;
begin
  Result := '';
  for I := 1 to (Length(S) div 2) do
  begin
    Str := Copy(S, 1 + 2 * (I - 1), 2);
    if FIXIDEX then
      if not((I = 200) and (Str = '20')) then
        Result := Result + Char(HexToIntDef(Str, 32));
  end;
end;

function LinkType(LinkTypeN : integer) : String;
begin
  Result := TA('Unknown');
  if LinkTypeN = LINK_TYPE_ID then
    Result := LINK_TEXT_TYPE_ID;
  if LinkTypeN = LINK_TYPE_ID_EXT then
    Result := LINK_TEXT_TYPE_ID_EXT;
  if LinkTypeN = LINK_TYPE_IMAGE then
    Result := LINK_TEXT_TYPE_IMAGE;
  if LinkTypeN = LINK_TYPE_FILE then
    Result := LINK_TEXT_TYPE_FILE;
  if LinkTypeN = LINK_TYPE_FOLDER then
    Result := LINK_TEXT_TYPE_FOLDER;
  if LinkTypeN = LINK_TYPE_TXT then
    Result := LINK_TEXT_TYPE_TXT;
  if LinkTypeN = LINK_TYPE_HTML then
    Result := LINK_TEXT_TYPE_HTML;
end;

end.
