unit uPortableDeviceUtils;

interface

uses
  StrUtils,
  Graphics,
  Classes,
  uPortableClasses,
  uPortableDeviceManager,
  uConstants,
  RAWImage,
  uMemory;

type
  TPortableGraphicHelper = class helper for TGraphic
  public
    function LoadFromDevice(Path: string): Boolean;
  end;

function PhotoDBPathToDevicePath(Path: string): string;
function IsDevicePath(Path: string): Boolean;
function IsDeviceItemPath(Path: string): Boolean;
function ExtractDeviceName(Path: string): string;
function ExtractDeviceItemPath(Path: string): string;
function GetDeviceItemSize(Path: string): Int64;
function ReadStreamFromDevice(Path: string; Stream: TStream): Boolean;

implementation

function PhotoDBPathToDevicePath(Path: string): string;
begin
  Result := Path;
  if Length(Result) > Length(cDevicesPath) then
    Delete(Result, 1, Length(cDevicesPath) + 1);
end;

function IsDevicePath(Path: string): Boolean;
begin
  Result := StartsText(cDevicesPath + '\', Path);
end;

function IsDeviceItemPath(Path: string): Boolean;
begin
  Result := False;
  if StartsText(cDevicesPath + '\', Path) then
  begin
    Delete(Path, 1, Length(cDevicesPath + '\'));
    Result := Pos('\', Path) > 0;
  end;
end;

function ExtractDeviceName(Path: string): string;
var
  P: Integer;
begin
  Result := '';
  if StartsText(cDevicesPath + '\', Path) then
  begin
    Delete(Path, 1, Length(cDevicesPath + '\'));
    P := Pos('\', Path);
    if P = 0 then
      P := Length(Path) + 1;

    Result := Copy(Path, 1, P - 1);
  end;
end;

function ExtractDeviceItemPath(Path: string): string;
var
  P: Integer;
begin
  Result := '';
  if StartsText(cDevicesPath + '\', Path) then
  begin
    Delete(Path, 1, Length(cDevicesPath + '\'));
    P := Pos('\', Path);
    if P > 1 then
      Delete(Path, 1, P - 1);

    Result := Path;
  end;
end;

function ReadStreamFromDevice(Path: string; Stream: TStream): Boolean;
var
  DeviceName, DevicePath: string;
  Device: IPDevice;
  Item: IPDItem;
begin
  Result := False;
  DeviceName := ExtractDeviceName(Path);
  DevicePath := ExtractDeviceItemPath(Path);
  Device := CreateDeviceManagerInstance.GetDeviceByName(DeviceName);
  if Device = nil then
    Exit;

  Item := Device.GetItemByPath(DevicePath);
  if Item = nil then
    Exit;

  Result := Item.SaveToStream(Stream);
end;

{ TPortableGraphicHelper }

function TPortableGraphicHelper.LoadFromDevice(Path: string): Boolean;
var
  DeviceName, DevicePath: string;
  Device: IPDevice;
  Item: IPDItem;
  MS: TMemoryStream;
begin
  Result := False;
  DeviceName := ExtractDeviceName(Path);
  DevicePath := ExtractDeviceItemPath(Path);
  Device := CreateDeviceManagerInstance.GetDeviceByName(DeviceName);
  if Device = nil then
    Exit;

  Item := Device.GetItemByPath(DevicePath);
  if Item = nil then
    Exit;

  if Self is TRAWImage then
    TRAWImage(Self).IsPreview := True;

  MS := TMemoryStream.Create;
  try
    Item.SaveToStream(MS);
    if MS.Size > 0 then
    begin
      MS.Seek(0, soFromBeginning);
      Self.LoadFromStream(MS);
    end;
  finally
    F(MS);
  end;
end;

function GetDeviceItemSize(Path: string): Int64;
var
  DeviceName, DevicePath: string;
  Device: IPDevice;
  Item: IPDItem;
begin
  Result := -1;
  DeviceName := ExtractDeviceName(Path);
  DevicePath := ExtractDeviceItemPath(Path);
  Device := CreateDeviceManagerInstance.GetDeviceByName(DeviceName);
  if Device <> nil then
  begin
    Item := Device.GetItemByPath(DevicePath);
    if Item <> nil then
      Result := Item.FullSize;
  end;
end;

end.
