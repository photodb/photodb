unit uResources;

interface

uses Windows, SysUtils, Classes, JPEG, GraphicEx;

function GetFolderPicture : TPNGGraphic;
function GetLogoPicture : TJpegImage; 
function GetSlideShowLoadPicture : TPNGGraphic;

implementation

function GetRCDATAResourceStream(ResName : string) : TMemoryStream;
var
  MyRes  : Integer;
  MyResP : Pointer;
  MyResS : Integer;
begin
  Result:=nil;
  MyRes := FindResource(HInstance,PChar(ResName),RT_RCDATA);
  if MyRes <> 0 then begin
    MyResS := SizeOfResource(HInstance,MyRes);
    MyRes := LoadResource(HInstance,MyRes);
    if MyRes <> 0 then begin
      MyResP := LockResource(MyRes);
      if MyResP <> nil then begin
        Result := TMemoryStream.Create;
        with Result do begin
          Write(MyResP^,MyResS);
          Seek(0,soFromBeginning);
        end;
        UnLockResource(MyRes);
      end;
      FreeResource(MyRes);
    end
  end;
end;

function LoadPNGFromRES(ResName : string) : TPNGGraphic;
var
  RCDataStream : TMemoryStream;
begin
  Result := nil;
  RCDataStream := GetRCDATAResourceStream(ResName);
  if RCDataStream <> nil then
  begin
    Result := TPNGGraphic.Create;
    Result.LoadFromStream(RCDataStream);
    RCDataStream.Free;
  end;
end;

function GetFolderPicture : TPNGGraphic;
begin
  Result := LoadPNGFromRES('DIRECTORY_LARGE');
end;

function GetSlideShowLoadPicture : TPNGGraphic;
begin
  Result := LoadPNGFromRES('SLIDESHOW_LOAD');
end;

function GetLogoPicture : TJpegImage;
var
  RCDataStream : TMemoryStream;
begin
  RCDataStream := GetRCDATAResourceStream('LOGO');
  if RCDataStream <> nil then
  begin
    Result := TJpegImage.Create;
    Result.LoadFromStream(RCDataStream);
    RCDataStream.Free;
  end;
end;

end.
