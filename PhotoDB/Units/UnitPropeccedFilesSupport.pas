unit UnitPropeccedFilesSupport;

interface

uses Windows, Classes, win32crc, SysUtils;

type
 TCollectionItem = record
  FileName : string[255];
  CRC : Cardinal;
  RefCount : integer;
 end;
 PCollectionItem = ^TCollectionItem;

type
  TProcessedFilesCollection = class
  private
   Data : TList;
  public
  procedure AddFile(FileName : String);
  procedure RemoveFile(FileName : String);
  function ExistsFile(FileName : String) : Pointer;
  constructor Create;
  destructor Destroy; override;
  end;

  var
    ProcessedFilesCollection : TProcessedFilesCollection;

implementation

{ TProcessedFilesCollection }

procedure TProcessedFilesCollection.AddFile(FileName: String);
var
  aRecord : PCollectionItem;
  crc : Cardinal;
  p : Pointer;
begin
 p:=ExistsFile(FileName);
 if p=nil then
 begin
  GetMem(aRecord,SizeOf(TCollectionItem));
  aRecord^.FileName:=AnsiLowerCase(ExtractFileName(FileName));
  crc:=0;
  CalcStringCRC32(aRecord^.FileName,crc);
  aRecord^.CRC := crc;
  aRecord^.RefCount:=1;
  Data.Add(aRecord)
 end else
 begin
  TCollectionItem(p^).RefCount:=TCollectionItem(p^).RefCount+1;
 end;
end;

constructor TProcessedFilesCollection.Create;
begin
 Data:=TList.Create;
end;

destructor TProcessedFilesCollection.Destroy;
begin
 Data.Free;
end;

function TProcessedFilesCollection.ExistsFile(FileName: String): Pointer;
var
  i, dc : integer;
  crc : Cardinal;
  aFileName : string; 
  p : Pointer;
begin
 dc:=Data.Count;
 if dc=0 then begin Result:=nil; exit; end;
 aFileName:=AnsiLowerCase(ExtractFileName(FileName));
 crc:=0;
 CalcStringCRC32(aFileName,crc);
 for i:=0 to dc-1 do
 begin
  p:=Data.Items[i];
  if TCollectionItem(p^).CRC=crc then
  begin
   if TCollectionItem(p^).FileName=aFileName then
   begin
    Result:=p;
    exit;
   end;
  end;
 end;
 Result:=nil;
end;

procedure TProcessedFilesCollection.RemoveFile(FileName: String);
var
  i, dc : integer;
  crc : Cardinal;
  aFileName : string;
  p : Pointer;
begin       
 dc:=Data.Count;
 if dc=0 then begin exit; end;
 aFileName:=AnsiLowerCase(ExtractFileName(FileName));
 crc:=0;
 CalcStringCRC32(aFileName,crc);
 for i:=0 to dc-1 do
 begin
  p:=Data.Items[i];
  if TCollectionItem(p^).CRC=crc then
  begin
   if TCollectionItem(p^).FileName=aFileName then
   begin
    TCollectionItem(p^).RefCount:=TCollectionItem(p^).RefCount-1;
    if TCollectionItem(p^).RefCount=0 then
    begin
     Data.Remove(p);
     FreeMem(p);
    end;
    exit;
   end;
  end;
 end;
end;

initialization
  ProcessedFilesCollection := TProcessedFilesCollection.Create;

finalization
  ProcessedFilesCollection.Free;

end.
