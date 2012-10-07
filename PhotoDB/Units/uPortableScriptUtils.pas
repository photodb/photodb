unit uPortableScriptUtils;

interface

uses
  Generics.Collections,
  Vcl.Controls,

  Dmitry.PathProviders,

  uMemory,
  uConstants,
  uScript,
  uPortableClasses,
  uPortableDeviceManager,
  uExplorerPortableDeviceProvider;

function GetPortableDevices: TArrayOfString;
function GetPortableDeviceIcon(DeviceName: string; ImageList: TImageList; var IconsCount: Integer): Integer;

implementation

function GetPortableDevices: TArrayOfString;
var
  I: Integer;
  Manager: IPManager;
  Devices: TList<IPDevice>;
begin
  SetLength(Result, 0);
  Manager := CreateDeviceManagerInstance;
  try
    Devices := TList<IPDevice>.Create;
    try
      Manager.FillDevices(Devices);

      for I := 0 to Devices.Count - 1 do
      begin
        SetLength(Result, Length(Result) + 1);
        Result[Length(Result)-1] := Devices[I].Name;
      end;
    finally
      F(Devices);
    end;
  finally
    Manager := nil;
  end;
end;

function GetPortableDeviceIcon(DeviceName: string; ImageList: TImageList; var IconsCount: Integer): Integer;
var
  Manager: IPManager;
  Device: IPDevice;
  Item: TPortableDeviceItem;
begin
  Result := -1;
  Manager := CreateDeviceManagerInstance;
  try
    Device := Manager.GetDeviceByName(DeviceName);
    if Device <> nil then
    begin
      Item := TPortableDeviceItem.CreateFromPath(cDevicesPath + '\' + Device.Name, PATH_LOAD_FOR_IMAGE_LIST, 16);
      try
        Item.LoadDevice(Device);
        if Item.Image <> nil then
        begin
          Item.Image.AddToImageList(ImageList);
          Inc(IconsCount);
          Result := ImageList.Count - 1;
        end;
      finally
        F(Item);
      end;
    end;
  finally
    Manager := nil;
  end;
end;

end.
