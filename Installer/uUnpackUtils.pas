unit uUnpackUtils;

interface

uses
  Windows, SysUtils, Classes, uUserUtils;

function GetTempDirectory: string;
function GetTempFileName: TFileName;
function GetRCDATAResourceStream(ResName : string; MS: TMemoryStream) : Boolean;

implementation

function GetRCDATAResourceStream(ResName : string; MS : TMemoryStream) : Boolean;
var
  MyRes  : Integer;
  MyResP : Pointer;
  MyResS : Integer;
begin
  Result := False;
  MyRes := FindResource(HInstance, PWideChar(ResName), RT_RCDATA);
  if MyRes <> 0 then begin
    MyResS := SizeOfResource(HInstance,MyRes);
    MyRes := LoadResource(HInstance,MyRes);
    if MyRes <> 0 then begin
      MyResP := LockResource(MyRes);
      if MyResP <> nil then begin
        with MS do begin
          Write(MyResP^, MyResS);
          Seek(0, soFromBeginning);
        end;
        Result := True;
        UnLockResource(MyRes);
      end;
      FreeResource(MyRes);
    end
  end;
end;

function GetTempDirectory: string;
var
  TempFolder: array[0..MAX_PATH] of Char;
begin
  GetTempPath(MAX_PATH, @tempFolder);
  Result := StrPas(TempFolder);
end;

function GetTempFileName: TFileName;
var
  TempFileName: array [0..MAX_PATH-1] of char;
begin
  if Windows.GetTempFileName(PChar(GetTempDirectory), '~', 0, TempFileName) = 0 then
    raise Exception.Create(SysErrorMessage(GetLastError));
  Result := TempFileName;
end;

end.
