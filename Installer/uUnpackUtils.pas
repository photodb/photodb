unit uUnpackUtils;

interface

uses
  Windows,
  SysUtils,
  Classes,
  Math,
  uUserUtils;

type
  TProgressProc = reference to procedure(BytesTotal, BytesComplete: Int64; var Break: Boolean);

function GetTempDirectory: string;
function GetTempFileName: TFileName;
function GetRCDATAResourceStream(ResName: string; MS: TMemoryStream; Progress: TProgressProc): Boolean;

implementation

function GetRCDATAResourceStream(ResName: string; MS: TMemoryStream; Progress: TProgressProc): Boolean;
const
  BufferSize = 340 * 1024; //340k
var
  MyRes  : Integer;
  MyResP : Pointer;
  MyResS, ResourceSize, ReadSize : Integer;
  Cancel: Boolean;
begin
  Result := False;
  MyRes := FindResource(HInstance, PWideChar(ResName), RT_RCDATA);
  if MyRes <> 0 then
  begin
    ResourceSize := SizeOfResource(HInstance, MyRes);
    MyRes := LoadResource(HInstance, MyRes);
    if MyRes <> 0 then
    begin
      MyResP := LockResource(MyRes);
      if MyResP <> nil then
      begin
        with MS do
        begin
          MyResS := ResourceSize;
          while MyResS > 0 do
          begin
            ReadSize := Min(BufferSize, MyResS);
            Write(MyResP^, ReadSize);
            Inc(NativeInt(MyResP), ReadSize);
            Dec(MyResS, BufferSize);

            Progress(ResourceSize, MS.Size, Cancel);
            if Cancel then
              Break;
          end;

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
