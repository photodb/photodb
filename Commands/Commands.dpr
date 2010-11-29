program Commands;

uses
  Windows,
  SysUtils,
  uAppUtils in '..\PhotoDB\Units\uAppUtils.pas',
  uMemory in '..\PhotoDB\Units\uMemory.pas';

var
  Action : string;
  FileName : string;

  procedure DoWait;
  var
    WaitMillisec : Integer;
    WaitPid,
    WaitHandle : Integer;
  begin
    if GetParamStrDBBool('/wait') then
    begin
      WaitMillisec := StrToIntDef(GetParamStrDBValue('/wait'), 0);
      WaitPid := StrToIntDef(GetParamStrDBValue('/pid'), 0);
      WaitHandle := OpenProcess(SYNCHRONIZE, False, WaitPid);
      if WaitHandle > 0 then
        WaitForSingleObject(WaitHandle, WaitMillisec);
      Sleep(1000);
    end;
  end;

begin

  Action := ParamStr(1);
  if Action = '/delete' then
  begin
    FileName := GetParamStrDBValue('/delete');
    if FileExists(FileName) then
    begin
      DoWait;
      DeleteFile(FileName);

      if GetParamStrDBBool('/withdirectory') then
        RemoveDir(ExtractFileDir(FileName));
    end;
  end;

end.
