unit uPortableDeviceManager;

interface

uses
  Classes, Graphics, ComObj, uMemory, uBitmapUtils, SysUtils,
  uConstants, SyncObjs, uPortableClasses, uWIAClasses, uWPDClasses;

{type
  TWIACamera = class;
  TWIACameraImage = class;

  TWIAManager = class(TObject)
  private
    FList: TList;
    FDevMgr: IDeviceManager;
    function GetCount: Integer;
    function GetCameraByIndex(Index: Integer): TWIACamera;
  public
    constructor Create;
    destructor Destroy; override;
    function GetCameraPathByID(UniqueDeviceID: string): string;
    function GetImagePreview(CameraName, ItemName: string; Bitmap: TBitmap): Boolean;
    property Cameras[Index: Integer]: TWIACamera read GetCameraByIndex; default;
    property Count: Integer read GetCount;
  end;

  TWIACamera = class(TObject)
  private
    FDeviceInfo: IDeviceInfo;
    FDevice: IDevice;
    FCameraName: string;
    FUniqueDeviceID: string;
    FImages: TList;
    procedure InitImages;
    function GetImageByIndex(Index: Integer): TWIACameraImage;
    function GetCount: Integer;
    function GetUniqueDeviceID: string;
    function GetCameraPath: string;
  public
    constructor Create(DeviceInfo: IDeviceInfo);
    destructor Destroy; override;
    property CameraName: string read FCameraName;
    property Images[Index: Integer]: TWIACameraImage read GetImageByIndex; default;
    property Count: Integer read GetCount;
    property UniqueDeviceID: string read GetUniqueDeviceID;
    property CameraPath: string read GetCameraPath;
  end;

  TBinaryArray = array of Byte;

  TWIACameraImage = class(TObject)
  private
    FCamera: TWIACamera;
    FItem: IItem;
    FFileName: string;
    FPreview: TBitmap;
    FIsInitialized: Boolean;
    FDateTime: TDateTime;
    FItemIndex: Integer;
    procedure InitItem;
    function GetPropByName(Name: string): IProperty;
    function GetFileName: string;
    function GetPreview: TBitmap;
    function GetCameraName: string;
    function GetCameraID: string;
    function GetDateTime: TDateTime;
  public
    constructor Create(Camera: TWIACamera; Item: IItem; AItemIndex: Integer);
    destructor Destroy; override;
    function Delete: Boolean;
    function SaveToFile(FileName: string): Boolean;
    function SaveToStream(Stream: TStream): Boolean;
    function ExtractPreview: TBitmap;
    property FileName: string read GetFileName;
    property Preview: TBitmap read GetPreview;
    property CameraName: string read GetCameraName;
    property CameraID: string read GetCameraID;
    property DateTime: TDateTime read GetDateTime;
    property ItemIndex: Integer read FItemIndex;
  end;

  TWIACacheItem = class(TObject)
  private
    FPreviewBitmap: TBitmap;
    FFullName: string;
    FCameraName: string;
    FCameraID: string;
    FDateTime: TDateTime;
    FItemIndex: Integer;
  public
    constructor Create(Image: TWIACameraImage);
    destructor Destroy; override;
    procedure UpdateFrom(Image: TWIACameraImage);
    property FullName: string read FFullName;
    property CameraName: string read FCameraName;
    property CameraID: string read FCameraID;
    property DateTime: TDateTime read FDateTime;
    property PreviewBitmap: TBitmap read FPreviewBitmap;
    property ItemIndex: Integer read FItemIndex;
  end;

  TWIACache = class(TObject)
  private
    FList: TList;
    FSync: TCriticalSection;
    function GetCacheItem(CameraName, ItemName: string): TWIACacheItem;
    function GetCacheItemByIndex(CameraName: string;
      ItemIndex: Integer): TWIACacheItem;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function AddItemToCache(Item: TWIACameraImage): TWIACacheItem;
    function GetIndexByName(CameraName, ItemName : string): Integer;
    property ItemsByName[CameraName: string; ItemName: string]: TWIACacheItem read GetCacheItem;
    property ItemsByIndex[CameraName: string; ItemIndex: Integer]: TWIACacheItem read GetCacheItemByIndex;
  end;    }

function CreateDeviceManagerInstance: IPManager;

implementation

function CreateDeviceManagerInstance: IPManager;
begin
  if False then
    Result := TWPDDeviceManager.Create
  else
    Result := TWIADeviceManager.Create;
end;

  (*
var
  FWIACache: TWIACache = nil;

function WIACache: TWIACache;
begin
  if FWIACache = nil then
    FWIACache := TWIACache.Create;

  Result := FWIACache;
end;

{ TWIAManager }

constructor TWIAManager.Create;
var
  Index: OleVariant;
  I: Integer;
  Camera: TWIACamera;
  DeviceInfo: IDeviceInfo;
begin
  FDevMgr := CreateOleObject('WIA.DeviceManager') as IDeviceManager;
  FList := TList.Create;
  for I := 1 to FDevMgr.DeviceInfos.Count do
  begin
    Index := I;
    DeviceInfo := FDevMgr.DeviceInfos.Item[Index];
    if DeviceInfo.type_ = CameraDeviceType then
    begin
      Camera := TWIACamera.Create(DeviceInfo);
      FList.Add(Camera);
    end;
  end;
end;

destructor TWIAManager.Destroy;
begin
  FreeList(FList);
  inherited;
end;

function TWIAManager.GetCameraByIndex(Index: Integer): TWIACamera;
begin
  Result := FList[Index];
end;

function TWIAManager.GetCameraPathByID(UniqueDeviceID: string): string;
var
  I: Integer;
  C: TWIACamera;
begin
  Result := '';

  for I := 0 to Count - 1 do
  begin
    C := Self[I];
    if AnsiLowerCase(C.UniqueDeviceID) = AnsiLowerCase(UniqueDeviceID) then
    begin
      Result := C.CameraPath;
      Break;
    end;
  end;

end;

function TWIAManager.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TWIAManager.GetImagePreview(CameraName, ItemName: string;
  Bitmap: TBitmap): Boolean;
var
  I, J, Index: Integer;
  C: TWIACamera;
begin
  Result := False;

  for I := 0 to Count - 1 do
  begin
    C := Self[I];
    if AnsiLowerCase(C.CameraName) = AnsiLowerCase(CameraName) then
    begin
      Index := WIACache.GetIndexByName(C.CameraName, ItemName);
      if Index = 0 then
        for J := 0 to C.Count - 1 do
        begin
          if C[J].FileName = ItemName then
          begin
            Index := J + 1;
            Break;
          end;
        end;

       if Index > 0 then
       begin
         Result := True;
         Bitmap.Assign(C[Index - 1].Preview);
       end;

    end;
  end;
end;

{ TWIACamera }

constructor TWIACamera.Create(DeviceInfo: IDeviceInfo);
var
  Index: OleVariant;
  Prop: IProperty;
begin
  FImages := TList.Create;
  FDeviceInfo := DeviceInfo;
  FCameraName := FDeviceInfo.DeviceID;
  FUniqueDeviceID := FDeviceInfo.DeviceID;

  Index := 'Name';
  Prop := FDeviceInfo.Properties[Index];
  if Prop <> nil then
    FCameraName := Prop.Get_Value();
end;

destructor TWIACamera.Destroy;
begin
  FreeList(FImages);
  inherited;
end;

function TWIACamera.GetCameraPath: string;
begin
  Result := cCamerasPath + '\' + CameraName;
end;

function TWIACamera.GetCount: Integer;
begin
  InitImages;
  Result := FImages.Count;
end;

function TWIACamera.GetImageByIndex(Index: Integer): TWIACameraImage;
begin
  InitImages;
  Result := FImages[Index];
  if Result = nil then
  begin
    Result := TWIACameraImage.Create(Self, FDevice.Items[Index + 1], Index + 1);
    FImages[Index] := Result;
  end;
end;

function TWIACamera.GetUniqueDeviceID: string;
begin
  Result := FUniqueDeviceID;
end;

procedure TWIACamera.InitImages;
var
  I: Integer;
begin
  if FDevice = nil then
  begin
    FDevice := FDeviceInfo.Connect;
    for I := 0 to FDevice.Items.Count - 1 do
      FImages.Add(nil);
  end
end;

{ TWIACameraImage }

constructor TWIACameraImage.Create(Camera: TWIACamera; Item: IItem; AItemIndex: Integer);
begin
  FCamera := Camera;
  FItem := Item;
  FItemIndex := AItemIndex;
  FPreview := nil;
  FIsInitialized := False;
end;

function TWIACameraImage.Delete: Boolean;
var
  WI: IWiaItem;
begin
  Result := False;
  WI := FItem.WiaItem as IWiaItem;
  if WI <> nil then
    Result := Succeeded(WI.DeleteItem(0))
end;

destructor TWIACameraImage.Destroy;
begin
  F(FPreview);
  inherited;
end;

function TWIACameraImage.ExtractPreview: TBitmap;
begin
  InitItem;
  Result := Preview;
  FPreview := nil;
  FIsInitialized := False;
end;

function TWIACameraImage.GetCameraID: string;
begin
  Result := FCamera.UniqueDeviceID;
end;

function TWIACameraImage.GetCameraName: string;
begin
  Result := FCamera.CameraName;
end;

function TWIACameraImage.GetDateTime: TDateTime;
begin
  InitItem;
  Result := FDateTime;
end;

function TWIACameraImage.GetFileName: string;
begin
  InitItem;
  Result := FFileName;
end;

function TWIACameraImage.GetPropByName(Name: string): IProperty;
var
  Index: OleVariant;
begin
  Index := Name;
  try
    Result := FItem.Properties[Index];
  except
    Result := nil;
  end;
end;

function TWIACameraImage.GetPreview: TBitmap;
var
  Prop: IProperty;
  Preivew: IVector;
  ImagePreview: IImageFile;
  W, H, ImageWidth, ImageHeight, ItemFlags: Integer;
  PreviewWidth, PreviewHeight: Integer;
  BinaryPreview: TBinaryArray;
  MS: TMemoryStream;
  BitmapPreview, FinePreview: TBitmap;
  CI: TWIACacheItem;
begin
  if FPreview <> nil then
  begin
    Result := FPreview;
    Exit;
  end;

  InitItem;

  CI := WIACache.GetCacheItem(FCamera.CameraName, FileName);
  if (CI <> nil) and (CI.PreviewBitmap <> nil) then
  begin
    FPreview := TBitmap.Create;
    FPreview.Assign(CI.PreviewBitmap);
    Result := FPreview;
    Exit;
  end;

  Preivew := nil;
  ItemFlags := 0;
  PreviewWidth := 0;
  PreviewHeight := 0;
  ImageWidth := 0;
  ImageHeight := 0;

  Prop := GetPropByName('Item Flags');
  if Prop <> nil then
    ItemFlags := Integer(Prop.Get_Value());

  Prop := GetPropByName('Pixels Per Line');
  if Prop <> nil then
    ImageWidth := Integer(Prop.Get_Value());

  Prop := GetPropByName('Number of Lines');
  if Prop <> nil then
    ImageHeight := Integer(Prop.Get_Value());

  Prop := GetPropByName('Thumbnail Data');
  if Prop <> nil then
    Preivew := IUnknown(Prop.Get_Value()) as IVector;

  Prop := GetPropByName('Thumbnail Width');
  if Prop <> nil then
    PreviewWidth := Integer(Prop.Get_Value());

  Prop := GetPropByName('Thumbnail Height');
  if Prop <> nil then
    PreviewHeight := Integer(Prop.Get_Value());

  if ItemFlags and (ImageItemFlag or FileItemFlag or VideoItemFlag) > 0 then
  begin
    if (Preivew <> nil) then
    begin
      ImagePreview := Preivew.ImageFile[PreviewWidth, PreviewHeight];
      BinaryPreview := TBinaryArray(ImagePreview.FileData.Get_BinaryData());
      MS := TMemoryStream.Create;
      try
        MS.WriteBuffer(Pointer(BinaryPreview)^, Length(BinaryPreview));
        MS.Seek(0, soFromBeginning);
        BitmapPreview := TBitmap.Create;
        try
          BitmapPreview.LoadFromStream(MS);
          BitmapPreview.PixelFormat := pf24Bit;
          W := ImageWidth;
          H := ImageHeight;
          ProportionalSize(PreviewWidth, PreviewHeight, W, H);
          if (W <> PreviewWidth) or (H <> PreviewHeight) then
          begin
            FinePreview := TBitmap.Create;
            try
              FinePreview.PixelFormat := pf24bit;
              FinePreview.SetSize(W, H);

              DrawImageExRect(FinePreview, BitmapPreview, PreviewWidth div 2 - W div 2, PreviewHeight div 2 - H div 2, W, H, 0, 0);

              FPreview := FinePreview;
              FinePreview := nil;
            finally
              F(FinePreview);
            end;
          end else
          begin
            FPreview := BitmapPreview;
            BitmapPreview := nil;
          end;

        finally
          F(BitmapPreview);
        end;
      finally
        F(MS);
      end;
    end;
  end;

  Result := FPreview;

  WIACache.AddItemToCache(Self);
end;

procedure TWIACameraImage.InitItem;
var
  Prop: IProperty;
  DateStamp: IVector;
  ItemName, FileNameExtension: string;
  CI: TWIACacheItem;
begin
  if FIsInitialized then
    Exit;

  FIsInitialized := True;

  CI := WIACache.GetCacheItemByIndex(FCamera.CameraName, FItemIndex);
  if (CI <> nil) and (CI.PreviewBitmap <> nil) then
  begin
    FFileName := CI.FullName;
    FDateTime := CI.DateTime;
    Exit;
  end;

  DateStamp := nil;
  FDateTime := 0;
  FileNameExtension := '';

  Prop := GetPropByName('Item Name');
  if Prop <> nil then
    ItemName := string(Prop.Get_Value());

  Prop := GetPropByName('Filename extension');
  if Prop <> nil then
    FileNameExtension := string(Prop.Get_Value());

  Prop := GetPropByName('Item Time Stamp');
  if Prop <> nil then
  begin
    DateStamp := IUnknown(Prop.Get_Value()) as IVector;
    if DateStamp <> nil then
      FDateTime := DateStamp.Date;
    end;

  FFileName := ItemName + '.' + FileNameExtension;

  WIACache.AddItemToCache(Self);
end;

function TWIACameraImage.SaveToFile(FileName: string): Boolean;
var
  Image: IImageFile;
begin
  Image := IUnknown(FItem.Transfer('{00000000-0000-0000-0000-000000000000}')) as IImageFile;

  Result := Image <> nil;

  if Result then
    Image.SaveFile(FileName);
end;

function TWIACameraImage.SaveToStream(Stream: TStream): Boolean;
var
  Image: IImageFile;
  ImageData: TBinaryArray;
begin
  Image := IUnknown(FItem.Transfer('{00000000-0000-0000-0000-000000000000}')) as IImageFile;

  Result := Image <> nil;

  ImageData := TBinaryArray(Image.FileData.Get_BinaryData());
  Stream.WriteBuffer(Pointer(ImageData)^, Length(ImageData));
end;

{ TWIACache }

function TWIACache.AddItemToCache(Item: TWIACameraImage): TWIACacheItem;
begin
  FSync.Enter;
  try
    Result := GetCacheItem(Item.CameraName, Item.FileName);
    if Result = nil then
    begin
      Result := TWIACacheItem.Create(Item);
      FList.Add(Result);
    end else
      Result.UpdateFrom(Item);
  finally
    FSync.Leave;
  end;
end;

procedure TWIACache.Clear;
begin
  FreeList(FList, False);
  inherited;
end;

constructor TWIACache.Create;
begin
  FList := TList.Create;
  FSync := TCriticalSection.Create;
end;

destructor TWIACache.Destroy;
begin
  F(FSync);
  FreeList(FList);
end;

function TWIACache.GetCacheItem(CameraName, ItemName: string): TWIACacheItem;
var
  I: Integer;
  CI: TWIACacheItem;
begin
  Result := nil;
  FSync.Enter;
  try
    for I := 0 to FList.Count - 1 do
    begin
      CI := TWIACacheItem(FList[I]);
      if (CI.CameraName = CameraName) and (CI.FullName = ItemName) then
      begin
        Result := CI;
        Break;
      end;
    end;
  finally
    FSync.Leave;
  end;
end;

function TWIACache.GetCacheItemByIndex(CameraName: string;
  ItemIndex: Integer): TWIACacheItem;
var
  I: Integer;
  CI: TWIACacheItem;
begin
  Result := nil;
  FSync.Enter;
  try
    for I := 0 to FList.Count - 1 do
    begin
      CI := TWIACacheItem(FList[I]);
      if (CI.CameraName = CameraName) and (CI.ItemIndex = ItemIndex) then
      begin
        Result := CI;
        Break;
      end;
    end;
  finally
    FSync.Leave;
  end;
end;

function TWIACache.GetIndexByName(CameraName, ItemName: string): Integer;
var
  I: Integer;
  CI: TWIACacheItem;
begin
  Result := 0;
  FSync.Enter;
  try
    for I := 0 to FList.Count - 1 do
    begin
      CI := TWIACacheItem(FList[I]);
      if (CI.CameraName = CameraName) and (CI.FullName = ItemName) then
      begin
        Result := CI.FItemIndex;
        Break;
      end;
    end;
  finally
    FSync.Leave;
  end;
end;

{ TWIACacheItem }

constructor TWIACacheItem.Create(Image: TWIACameraImage);
begin
  FPreviewBitmap := nil;
  UpdateFrom(Image);
end;

destructor TWIACacheItem.Destroy;
begin
  F(FPreviewBitmap);
  inherited;
end;

procedure TWIACacheItem.UpdateFrom(Image: TWIACameraImage);
begin
  if Image.FPreview <> nil then
  begin
    F(FPreviewBitmap);
    FPreviewBitmap := TBitmap.Create;
    FPreviewBitmap.Assign(Image.FPreview);
  end;

  FFullName := Image.FileName;
  FCameraName := Image.CameraName;
  FCameraID := Image.CameraID;
  FDateTime := Image.DateTime;
  FItemIndex := Image.ItemIndex;
end;
    *)
{initialization

finalization
  F(FWIACache);   }

end.
