unit uDBFileTypes;

interface

uses
  Windows, Classes, SysUtils, UnitDBDeclare, uMemory, uDBBaseTypes;

function SaveIDsTofile(FileName: string; IDs: TArInteger): Boolean;
function LoadIDsFromfile(FileName: string): string;
function LoadIDsFromfileA(FileName: string): TArInteger;
function LoadImThsFromfileA(FileName: string): TArAnsiStrings;
function SaveImThsTofile(FileName: string; ImThs: TArAnsiStrings): Boolean;
procedure LoadDblFromfile(FileName: string; var IDs: TArInteger; var Files: TArStrings);
function SaveListTofile(FileName: string; IDs: TArInteger; Files: TArStrings): Boolean;
function LoadActionsFromfileA(FileName: string; Info : TStrings) : Boolean;
function SaveActionsToFile(FileName: string; Actions: TStrings): Boolean;

implementation


function SaveListTofile(FileName: string; IDs: TArInteger; Files: TArStrings): Boolean;
var
  I: Integer;
  X: array of Byte;
  Fs: TFileStream;
  LenIDS, LenFiles, L: Integer;
begin
  Result := False;
  if Length(IDs) + Length(Files) = 0 then
    Exit;
  try
    FS := TFileStream.Create(Filename, FmOpenWrite or FmCreate);
  except
    Exit;
  end;
  try
    SetLength(X, 14);
    X[0] := Ord(' ');
    X[1] := Ord('F');
    X[2] := Ord('I');
    X[3] := Ord('L');
    X[4] := Ord('E');
    X[5] := Ord('-');
    X[6] := Ord('D');
    X[7] := Ord('B');
    X[8] := Ord('L');
    X[9] := Ord('S');
    X[10] := Ord('T');
    X[11] := Ord('-');
    X[12] := Ord('V');
    X[13] := Ord('1');
    FS.Write(Pointer(X)^, 14);
    LenIDS := Length(IDs);
    FS.Write(LenIDS, Sizeof(LenIDS));
    LenFiles := Length(Files);
    FS.Write(LenFiles, Sizeof(LenFiles));
    for I := 0 to LenIDS - 1 do
      FS.Write(IDs[I], Sizeof(IDs[I]));
    for I := 0 to LenFiles - 1 do
    begin
      L := Length(Files[I]);
      FS.Write(L, Sizeof(L));
      FS.Write(Files[I][1], L + 1);
    end;
  except
    F(FS);
    Exit;
  end;
  F(FS);
  Result := True;
end;

procedure LoadDblFromfile(FileName: string; var IDs: TArInteger; var Files: TArStrings);
var
  Int, I: Integer;
  X: array of Byte;
  Fs: Tfilestream;
  V1: Boolean;
  LenIDS, LenFiles, L: Integer;
  Str: string;
begin
  SetLength(IDs, 0);
  SetLength(Files, 0);
  if not FileExists(FileName) then
    Exit;
  try
    FS := TFileStream.Create(FileName, FmOpenRead);
  except
    Exit;
  end;
  try
    SetLength(X, 14);
    FS.Read(Pointer(X)^, 14);
    V1 := (X[1] = Ord('F')) and (X[2] = Ord('I')) and (X[3] = Ord('L')) and (X[4] = Ord('E')) and (X[5] = Ord('-')) and
      (X[6] = Ord('D')) and (X[7] = Ord('B')) and (X[8] = Ord('L')) and (X[9] = Ord('S')) and (X[10] = Ord('T')) and
      (X[11] = Ord('-')) and (X[12] = Ord('V')) and (X[13] = Ord('1'));

    if V1 then
    begin
      FS.Read(LenIDS, SizeOf(LenIDS));
      FS.Read(LenFiles, SizeOf(LenFiles));
      SetLength(IDs, LenIDS);
      SetLength(Files, LenFiles);
      for I := 1 to LenIDS do
      begin
        FS.Read(Int, Sizeof(Integer));
        IDs[I - 1] := Int;
      end;
      for I := 1 to LenFiles do
      begin
        FS.Read(L, Sizeof(L));
        SetLength(Str, L);
        FS.Read(Str[1], L + 1);
        Files[I - 1] := Str;
      end;
    end;
  finally
    F(FS);
  end;
end;

function SaveIDsTofile(FileName: string; IDs: TArInteger): Boolean;
var
  I: Integer;
  X: array of Byte;
  FS: Tfilestream;
begin
  Result := False;
  if Length(IDs) = 0 then
    Exit;
  try
    FS := TFileStream.Create(Filename, FmOpenWrite or FmCreate);
  except
    Exit;
  end;
  try
    SetLength(X, 14);
    X[0] := Ord(' ');
    X[1] := Ord('F');
    X[2] := Ord('I');
    X[3] := Ord('L');
    X[4] := Ord('E');
    X[5] := Ord('-');
    X[6] := Ord('D');
    X[7] := Ord('B');
    X[8] := Ord('I');
    X[9] := Ord('D');
    X[10] := Ord('S');
    X[11] := Ord('-');
    X[12] := Ord('V');
    X[13] := Ord('1');
    FS.write(Pointer(X)^, 14);
    for I := 0 to Length(IDs) - 1 do
      FS.write(IDs[I], Sizeof(IDs[I]));
  except
    FS.Free;
    Exit;
  end;
  FS.Free;
  Result := True;
end;

function LoadIDsFromfile(FileName: string): string;
var
  I: Integer;
  X: array of Byte;
  Fs: TFileStream;
  Int: Integer;
  V1: Boolean;
begin
  SetLength(Result, 0);
  if not FileExists(FileName) then
    Exit;
  try
    Fs := TFileStream.Create(Filename, FmOpenRead);
  except
    Exit;
  end;
  try
    SetLength(X, 14);
    FS.Read(Pointer(X)^, 14);
    V1 := (X[1] = Ord('F')) and (X[2] = Ord('I')) and (X[3] = Ord('L')) and (X[4] = Ord('E')) and (X[5] = Ord('-')) and
      (X[6] = Ord('D')) and (X[7] = Ord('B')) and (X[8] = Ord('I')) and (X[9] = Ord('D')) and (X[10] = Ord('S')) and
      (X[11] = Ord('-')) and (X[12] = Ord('V')) and (X[13] = Ord('1'));

    if V1 then
    begin
      for I := 1 to (Fs.Size - 14) div Sizeof(Integer) do
      begin
        Fs.read(Int, Sizeof(Integer));
        Result := Result + Inttostr(Int) + '$';
      end;
    end;
  finally
    F(FS);
  end;
end;

function LoadIDsFromfileA(FileName: string): TArInteger;
var
  Int, I: Integer;
  X: array of Byte;
  Fs: Tfilestream;
  V1: Boolean;
begin
  SetLength(Result, 0);
  if not FileExists(FileName) then
    Exit;
  try
    Fs := TFileStream.Create(Filename, FmOpenRead);
  except
    Exit;
  end;
  try
    SetLength(X, 14);
    Fs.Read(Pointer(X)^, 14);
    V1 := (X[1] = Ord('F')) and (X[2] = Ord('I')) and (X[3] = Ord('L')) and (X[4] = Ord('E')) and (X[5] = Ord('-')) and
      (X[6] = Ord('D')) and (X[7] = Ord('B')) and (X[8] = Ord('I')) and (X[9] = Ord('D')) and (X[10] = Ord('S')) and
      (X[11] = Ord('-')) and (X[12] = Ord('V')) and (X[13] = Ord('1'));

    if V1 then
    begin
      for I := 1 to (Fs.Size - 14) div SizeOf(Integer) do
      begin
        Fs.Read(Int, Sizeof(Integer));
        SetLength(Result, Length(Result) + 1);
        Result[Length(Result) - 1] := Int;
      end;
    end;
  finally
    F(FS);
  end;
end;

function SaveImThsTofile(FileName: string; ImThs: TArAnsiStrings): Boolean;
var
  I: Integer;
  X: array of Byte;
  Fs: Tfilestream;
  S: AnsiString;
begin
  Result := False;
  if Length(ImThs) = 0 then
    Exit;
  try
    Fs := TFileStream.Create(Filename, FmOpenWrite or FmCreate);
  except
    Exit;
  end;
  try
    SetLength(X, 14);
    X[0] := Ord(' ');
    X[1] := Ord('F');
    X[2] := Ord('I');
    X[3] := Ord('L');
    X[4] := Ord('E');
    X[5] := Ord('-');
    X[6] := Ord('I');
    X[7] := Ord('M');
    X[8] := Ord('T');
    X[9] := Ord('H');
    X[10] := Ord('S');
    X[11] := Ord('-');
    X[12] := Ord('V');
    X[13] := Ord('1');
    Fs.write(Pointer(X)^, 14);
    for I := 0 to Length(ImThs) - 1 do
    begin
      S := AnsiString(ImThs[I]);
      FS.Write(S[1], Length(S));
    end;
  except
    F(FS);
    Exit;
  end;
  F(FS);
  Result := True;
end;

function LoadImThsFromfileA(FileName: string): TArAnsiStrings;
var
  I: Integer;
  S: AnsiString;
  X: array of Byte;
  Fs: Tfilestream;
  V1: Boolean;
begin
  SetLength(Result, 0);
  if not FileExists(FileName) then
    Exit;
  try
    Fs := TFileStream.Create(Filename, FmOpenRead);
  except
    Exit;
  end;
  try
    SetLength(X, 14);
    FS.Read(Pointer(X)^, 14);
    V1 := (X[1] = Ord('F')) and (X[2] = Ord('I')) and (X[3] = Ord('L')) and (X[4] = Ord('E')) and (X[5] = Ord('-')) and
      (X[6] = Ord('I')) and (X[7] = Ord('M')) and (X[8] = Ord('T')) and (X[9] = Ord('H')) and (X[10] = Ord('S')) and
      (X[11] = Ord('-')) and (X[12] = Ord('V')) and (X[13] = Ord('1'));

    if V1 then
    begin
      for I := 1 to (Fs.Size - 14) div 200 do
      begin
        SetLength(S, 200);
        FS.read(S[1], 200);
        SetLength(Result, Length(Result) + 1);
        Result[Length(Result) - 1] := string(S);
      end;
    end;
  finally
    F(FS);
  end;
end;

function SaveActionsTofile(FileName: string; Actions: TStrings): Boolean;
var
  I, L: Integer;
  X: array of Byte;
  Fs: TFileStream;
  Action : AnsiString;
begin
  Result := False;
  if Actions.Count = 0 then
    Exit;

  try
    Fs := TFileStream.Create(FileName, FmOpenWrite or FmCreate);
  except
    Exit;
  end;
  try
    SetLength(X, 14);
    X[0] := Ord(' ');
    X[1] := Ord('D');
    X[2] := Ord('B');
    X[3] := Ord('A');
    X[4] := Ord('C');
    X[5] := Ord('T');
    X[6] := Ord('I');
    X[7] := Ord('O');
    X[8] := Ord('N');
    X[9] := Ord('S');
    X[10] := Ord('-');
    X[11] := Ord('-');
    X[12] := Ord('V');
    X[13] := Ord('1');
    Fs.write(Pointer(X)^, 14);
    L := Actions.Count;
    Fs.Write(L, SizeOf(L));
    for I := 0 to Actions.Count - 1 do
    begin
      Action := AnsiString(Actions[I]);
      L := Length(Action);
      Fs.Write(L, SizeOf(L));
      Fs.Write(Action[1], Length(Action));
    end;
  except
    F(FS);
    Exit;
  end;
  F(FS);
  Result := True;
end;

function LoadActionsFromfileA(FileName: string; Info : TStrings) : Boolean;
var
  I, Length: Integer;
  S: AnsiString;
  X: array of Byte;
  FS: TFileStream;
begin
  Result := False;
  try
    FS := TFileStream.Create(Filename, FmOpenRead);
  except
    Exit;
  end;
  Info.Clear;
  try
    SetLength(X, 14);
    Fs.Read(Pointer(X)^, 14);
    if (X[1] = Ord('D')) and (X[2] = Ord('B')) and (X[3] = Ord('A')) and (X[4] = Ord('C')) and (X[5] = Ord('T')) and
      (X[6] = Ord('I')) and (X[7] = Ord('O')) and (X[8] = Ord('N')) and (X[9] = Ord('S')) and (X[10] = Ord('-')) and
      (X[11] = Ord('-')) and (X[12] = Ord('V')) and (X[13] = Ord('1')) then
      //V1 := True
    else
      Exit;

    FS.Read(Length, SizeOf(Length));
    for I := 1 to Length do
    begin
      FS.Read(Length, SizeOf(Length));
      SetLength(S, Length);
      FS.Read(S[1], Length);
      Info.Add(string(S));
    end;
    Result := True;
  finally
    F(FS);
  end;
end;

end.
