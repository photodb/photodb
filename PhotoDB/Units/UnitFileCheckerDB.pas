unit UnitFileCheckerDB;

interface

uses Windows, SysUtils, Dolphin_DB, UnitINI;

type

  FileCheckedDB = class(TObject)
   class function CheckFile(FileName : string) : integer;
   class procedure SaveCheckFile(FileName : string);
   class procedure RemoveCheckFile(FileName : string);
  end;

const
 CHECK_RESULT_UNDEFINED       = -1;
 CHECK_RESULT_FILE_NOE_EXISTS = -2;
 CHECK_RESULT_OK              = 0;
 CHECK_RESULT_FAILED          = -3;

implementation

{ TFileCheckedDB }

class function FileCheckedDB.CheckFile(FileName: string): integer;
var
  DateModifyOfFile, RegistryDate : double;
  Reg : TBDRegistry;
begin
 Result:=CHECK_RESULT_UNDEFINED;
 
 if not FileExists(FileName) then
 begin
  Result:=CHECK_RESULT_FILE_NOE_EXISTS;
  exit;
 end;

 DateModifyOfFile:=DateModify(FileName);
 FileName:=ExtractFileName(FileName);
 Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
 Reg.OpenKey(GetRegRootKey+'FileChecker',true);
 if Reg.ValueExists(FileName) then
 begin
  RegistryDate:=Reg.ReadDateTime(FileName);
  if Abs(RegistryDate-DateModifyOfFile)<0.00001 then
  begin
   Result:=CHECK_RESULT_OK;
   exit;
  end;
 end;
 Reg.WriteDateTime(FileName,DateModifyOfFile);
 Result:=CHECK_RESULT_FAILED;
 Reg.Free;
end;

class procedure FileCheckedDB.SaveCheckFile(FileName: string);
var
  DateModifyOfFile : double;
  Reg : TBDRegistry;
begin
 if not FileExists(FileName) then
 begin
  exit;
 end;
 Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);  
 DateModifyOfFile:=DateModify(FileName); 
 FileName:=ExtractFileName(FileName);
 Reg.OpenKey(GetRegRootKey+'FileChecker',true);
 Reg.WriteDateTime(FileName,DateModifyOfFile);
 Reg.Free;
end;

class procedure FileCheckedDB.RemoveCheckFile(FileName: string);
var
  DateModifyOfFile : double;
  Reg : TBDRegistry;
begin
 Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
 FileName:=ExtractFileName(FileName);
 Reg.OpenKey(GetRegRootKey+'FileChecker',true);
 Reg.DeleteValue(FileName);
 Reg.Free;
end;

end.
