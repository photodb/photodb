unit uPortableDeviceUtils;

interface

uses
  StrUtils,
  Graphics,
  Classes,
  uPortableClasses,
  uPortableDEVIceManager,
  uConstants,
  RAWImage,
  uMemory;

type
  TPortableGraphicHelper = class helper for TGraphic
  public
    function LoadFromDevice(Path: string): Boolean;
  end;

function IsDevicePath(Path: string): Boolean;
function ExtractDeviceName(Path: string): string;
function ExtractDeviceItemPath(Path: string): string;

implementation

function IsDevicePath(Path: string): Boolean;
begin
  Result := StartsText(cDevicesPath + '\', Path);
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

end.
