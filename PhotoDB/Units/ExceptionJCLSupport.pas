unit ExceptionJCLSupport;

interface

implementation

uses
  SysUtils, Classes, JclDebug;

function GetExceptionStackInfoJCL(P: PExceptionRecord): Pointer;
const
  cDelphiException = $0EEDFADE;
var
  Stack: TJclStackInfoList;
  Str: TStringList;
  Trace: String;
  Sz: Integer;
begin
  if P^.ExceptionCode = cDelphiException then
    Stack := JclCreateStackList(False, 3, P^.ExceptAddr)
  else
    Stack := JclCreateStackList(False, 3, P^.ExceptionAddress);
  try
    Str := TStringList.Create;
    try
      Stack.AddToStrings(Str, True, True, True, True);
      Trace := Str.Text;
    finally
      FreeAndNil(Str);
    end;
  finally
    FreeAndNil(Stack);
  end;

  if Trace <> '' then
  begin
    Sz := (Length(Trace) + 1) * SizeOf(Char);
    GetMem(Result, Sz);
    Move(Pointer(Trace)^, Result^, Sz);
  end
  else
    Result := nil;
end;

function GetStackInfoStringJCL(Info: Pointer): string;
begin
  Result := PChar(Info);
end;

procedure CleanUpStackInfoJCL(Info: Pointer);
begin
  FreeMem(Info);
end;

initialization
  Exception.GetExceptionStackInfoProc := GetExceptionStackInfoJCL;
  Exception.GetStackInfoStringProc := GetStackInfoStringJCL;
  Exception.CleanUpStackInfoProc := CleanUpStackInfoJCL;

end.
