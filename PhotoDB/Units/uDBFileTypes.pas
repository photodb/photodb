unit uDBFileTypes;

interface

uses
  System.Classes,
  System.SysUtils,
  Winapi.Windows,

  UnitDBDeclare,

  uMemory,
  uDBBaseTypes;

function LoadActionsFromfileA(FileName: string; Info : TStrings) : Boolean;
function SaveActionsToFile(FileName: string; Actions: TStrings): Boolean;

implementation

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
    FS := TFileStream.Create(FileName, FmOpenWrite or FmCreate);
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
    Fs.Write(Pointer(X)^, 14);
    L := Actions.Count;
    FS.Write(L, SizeOf(L));
    for I := 0 to Actions.Count - 1 do
    begin
      Action := AnsiString(Actions[I]);
      L := Length(Action);
      FS.Write(L, SizeOf(L));
      FS.Write(Action[1], Length(Action));
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
    FS := TFileStream.Create(Filename, fmOpenRead or fmShareDenyWrite);
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

