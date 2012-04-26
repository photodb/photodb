unit UnitFileCheckerDB;

interface

uses
  Windows, SysUtils, UFIleUtils, UnitINI, uMemory;

type
  FileCheckedDB = class(TObject)
    class function CheckFile(FileName: string): Integer;
    class procedure SaveCheckFile(FileName: string);
    class procedure RemoveCheckFile(FileName: string);
  end;

const
  CHECK_RESULT_UNDEFINED       = -1;
  CHECK_RESULT_FILE_NOE_EXISTS = -2;
  CHECK_RESULT_OK              = 0;
  CHECK_RESULT_FAILED          = -3;

implementation

{ TFileCheckedDB }

class function FileCheckedDB.CheckFile(FileName: string): Integer;
var
  DateModifyOfFile, RegistryDate: Double;
  Reg: TBDRegistry;
begin

  if not FileExists(FileName) then
  begin
    Result := CHECK_RESULT_FILE_NOE_EXISTS;
    Exit;
  end;

  DateModifyOfFile := DateModify(FileName);
  FileName := ExtractFileName(FileName);
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(GetRegRootKey + 'FileChecker', True);
    if Reg.ValueExists(FileName) then
    begin
      RegistryDate := Reg.ReadDateTime(FileName);
      if Abs(RegistryDate - DateModifyOfFile) < 0.00001 then
      begin
        Result := CHECK_RESULT_OK;
        Exit;
      end;
    end;
    Reg.WriteDateTime(FileName, DateModifyOfFile);
    Result := CHECK_RESULT_FAILED;
  finally
    F(Reg);
  end;
end;

class procedure FileCheckedDB.SaveCheckFile(FileName: string);
var
  DateModifyOfFile: Double;
  Reg: TBDRegistry;
begin
  if not FileExistsSafe(FileName) then
  begin
    Exit;
  end;
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    DateModifyOfFile := DateModify(FileName);
    FileName := ExtractFileName(FileName);
    Reg.OpenKey(GetRegRootKey + 'FileChecker', True);
    Reg.WriteDateTime(FileName, DateModifyOfFile);
  finally
    F(Reg);
  end;
end;

class procedure FileCheckedDB.RemoveCheckFile(FileName: string);
var
  Reg: TBDRegistry;
begin
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    FileName := ExtractFileName(FileName);
    Reg.OpenKey(GetRegRootKey + 'FileChecker', True);
    Reg.DeleteValue(FileName);
  finally
    Reg.Free;
  end;
end;

end.
