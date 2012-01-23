unit uStringUtils;

interface

uses
  Windows, Classes, SysUtils, StrUtils;

type
  TStringsHelper = class helper for TStrings
    function Join(JoinString: string): string;
  end;

type
  TStringFindOptions = array[0..1] of Integer;

procedure SplitString(Str: string; SplitChar: Char; List: TStrings);
function JoinList(List: TStrings; JoinString: string): string;
function ConvertUniversalFloatToLocal(s: string): string;
function PosExS(SubStr: string; const Str: string; index: integer = 1): Integer;
function PosExW(const SubStr, S: string; Offset, MaxPos: Integer): Integer; overload;
function Right(Str: string; P: Integer): string;
function Mid(Str: string; S, E: Integer): string;
function Left(Str: string; P: Integer): string;


implementation

function Left(Str: string; P: Integer): string;
begin
  if P > Length(Str) then
    Result := Str
  else
    Result := Copy(Str, 1, P);
end;

function Right(Str: string; P: Integer): string;
begin
  if P > Length(Str) then
    Result := ''
  else
    Result := Copy(Str, P, Length(Str) - P + 1);
end;

function Mid(Str: string; S, E: Integer): string;
begin
  if (S > E) then
  begin
    Result := '';
    Exit;
  end;
  if (S < 1) then
    S := 1;
  if E > Length(Str) then
    E := Length(Str);
  Result := Copy(Str, S, E - S + 1);
end;

procedure SplitString(Str: string; SplitChar: Char; List: TStrings);
var
  I, P: Integer;
  StrTemp: string;
begin
  P := 1;
  List.Clear;
  for I := 1 to Length(Str) do
    if (Str[I] = SplitChar) or (I = Length(Str)) then
    begin
      if I = Length(Str) then
        StrTemp := Copy(Str, P, I - P + 1)
      else
        StrTemp := Copy(Str, P, I - P);

      List.Add(StrTemp);
      P := I + 1;
    end;
end;

function ConvertUniversalFloatToLocal(S: string): string;
var
  I: Integer;
begin
  Result := s;
  for I := 1 to Length(Result) do
    if Result[I] = '.' then
      Result[I] := FormatSettings.DecimalSeparator;

end;

function PosExWX(const SubStr, S: string; Options: TStringFindOptions): Integer;
{$IFDEF CPUX86}
asm
       test  eax, eax
       jz    @Nil
       test  edx, edx
       jz    @Nil
       //ecx is pointer to options array, this check was moved to PosExW function
       //dec   ecx
       //jl    @Nil

       push  esi
       push  ebx
       push  0
       push  0
       mov   esi,ecx
       cmp   word ptr [eax-10],2
       je    @substrisunicode

       push  edx
       mov   edx, eax
       lea   eax, [esp+4]
       call  System.@UStrFromLStr
       pop   edx
       mov   eax, [esp]

@substrisunicode:
       cmp   word ptr [edx-10],2
       je    @strisunicode

       push  eax
       lea   eax,[esp+8]
       call  System.@UStrFromLStr
       pop   eax
       mov   edx, [esp+4]

@strisunicode:
       mov   ecx, [esi]    //Offset
       mov   esi, [esi+4]  //MaxPos
       mov   ebx, [eax-4]  //Length(Substr)
       sub   esi, ecx      //effective length of Str
       shl   ecx, 1        //double count of offset due to being wide char
       add   edx, ecx      //addr of the first char at starting position
       cmp   esi, ebx
       jl    @Past         //jump if EffectiveLength(Str)<Length(Substr)
       test  ebx, ebx
       jle   @Past         //jump if Length(Substr)<=0

       add   esp, -12
       add   ebx, -1       //Length(Substr)-1
       shl   esi,1         //double it due to being wide char
       add   esi, edx      //addr of the terminator
       shl   ebx,1         //double it due to being wide char
       add   edx, ebx      //addr of the last char at starting position
       mov   [esp+8], esi  //save addr of the terminator
       add   eax, ebx      //addr of the last char of Substr
       sub   ecx, edx      //-@Str[Length(Substr)]
       neg   ebx           //-(Length(Substr)-1)
       mov   [esp+4], ecx  //save -@Str[Length(Substr)]
       mov   [esp], ebx    //save -(Length(Substr)-1)
       movzx ecx, word ptr [eax] //the last char of Substr

@Loop:
       cmp   cx, [edx]
       jz    @Test0
@AfterTest0:
       cmp   cx, [edx+2]
       jz    @TestT
@AfterTestT:
       add   edx, 8
       cmp   edx, [esp+8]
       jb   @Continue
@EndLoop:
       add   edx, -4
       cmp   edx, [esp+8]
       jb    @Loop
@Exit:
       add   esp, 12
@Past:
       mov   eax, [esp]
       or    eax, [esp+4]
       jz    @PastNoClear
       mov   eax, esp
       mov   edx, 2
       call  System.@UStrArrayClr
@PastNoClear:
       add   esp, 8
       pop   ebx
       pop   esi
@Nil:
       xor   eax, eax
       ret
@Continue:
       cmp   cx, [edx-4]
       jz    @Test2
       cmp   cx, [edx-2]
       jnz   @Loop
@Test1:
       add   edx,  2
@Test2:
       add   edx, -4
@Test0:
       add   edx, -2
@TestT:
       mov   esi, [esp]
       test  esi, esi
       jz    @Found
@String:
       mov   ebx, [esi+eax]
       cmp   ebx, [esi+edx+2]
       jnz   @AfterTestT
       cmp   esi, -4
       jge   @Found
       mov   ebx, [esi+eax+4]
       cmp   ebx, [esi+edx+6]
       jnz   @AfterTestT
       add   esi, 8
       jl    @String
@Found:
       mov   eax, [esp+4]
       add   edx, 4

       cmp   edx, [esp+8]
       ja    @Exit

       add   esp, 12
       mov   ecx, [esp]
       or    ecx, [esp+4]
       jz    @NoClear

       mov   ebx, eax
       mov   esi, edx
       mov   eax, esp
       mov   edx, 2
       call  System.@UStrArrayClr
       mov   eax, ebx
       mov   edx, esi

@NoClear:
       add   eax, edx
       shr   eax, 1  // divide by 2 to make an index
       add   esp, 8
       pop   ebx
       pop   esi
{$ENDIF CPUX86}
{$IFDEF CPUX64}
begin
  Result := PosEx(SubStr, Copy(S, 1, Options[1]), Options[0]);
{$ENDIF CPUX64}
end;

function PosExW(const SubStr, S: string; Offset, MaxPos: Integer): Integer;
var
  Option: TStringFindOptions;
begin
  if Offset < 1 then
    Exit(0);
  Option[0] := Offset - 1;
  Option[1] := MaxPos;
  Result := PosExWX(SubStr, S, Option);
end;

function PosExS(SubStr: string; const Str: string; Index: Integer = 1): Integer;
var
  I, N, NS, LS: Integer;
  Q: Boolean;
  C, FS: Char;
  OneChar: Boolean;
  PS, PSup: PChar;

  function IsSubStr: Boolean;
  var
    K: Integer;
    APS: PChar;
    APSub: PChar;
  begin
    NativeUInt(APS) := NativeUInt(PS);
    NativeUInt(APSub) := NativeUInt(PSup);
    for K := 1 to LS do
    begin
      if APS^ <> APSub^ then
      begin
        Result := False;
        Exit;
      end;
      Inc(APS, 1);
      Inc(APSub, 1);
    end;
    Result := True;
  end;

begin
  if (Index < 1) or (Length(Str) = 0) then
  begin
    Result := 0;
    Exit;
  end;
  if Length(SubStr) = 0 then
  begin
    Result := Index;
    Exit;
  end;

  n := 0;
  ns := 0;
  FS := #0;
  q := False;
  Result := 0;
  LS := Length(SubStr);
  OneChar := LS = 1;
  if OneChar then
    FS := SubStr[1]
  else
    PSup := PChar(Addr(SubStr[1]));

  PS := PChar(Addr(Str[1]));
  Inc(PS, Index - 2);
  for I := Index to Length(Str) + 1 - LS do
  begin
    Inc(PS, 1);

    if OneChar then
    begin
      C := PS^;
      if (C = FS) and (n = 0) and (ns = 0) and (not q) then
      begin
        Result := I;
        exit;
      end;
    end else
    begin
      if IsSubStr and (n = 0) and (ns = 0) and (not q) then
      begin
        Result := I;
        exit;
      end;
      C := PS^;
    end;

    if (C = '"')  then
    begin
      q := not q;
      Continue;
    end;
    if I = index then
      continue;

    if (not q) then
    begin
      if (C = '{') then
      begin
        Inc(n);
      end else if (C = '}') and (n > 0)  then
      begin
        Dec(n);
        if n = 0 then
          Continue;
      end else if (C = '(') then
      begin
        Inc(ns);
      end else if (C = ')') and (ns > 0) then
      begin
        Dec(ns);
        if ns = 0 then
          Continue;
      end;

      if (n = 0) and (ns = 0) then
      begin
        if OneChar then
        begin
          if (C = FS) then
          begin
            Result := I;
            exit;
          end;
        end else
        begin
          if IsSubStr then
          begin
            Result := I;
            exit;
          end;
        end;
      end;
    end;
  end;
end;

function JoinList(List: TStrings; JoinString: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to List.Count - 1 do
  begin
    if I <> 0 then
      Result := Result + JoinString;

    Result := Result + List[I];
  end;
end;

{ TStringsHelper }

function TStringsHelper.Join(JoinString: string): string;
begin
  Result := JoinList(Self, JoinString);
end;

end.
