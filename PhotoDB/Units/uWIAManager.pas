unit uWIAManager;

interface

uses
  Classes, Graphics, ComObj, WIA2_TLB, uMemory;

type
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
    property Cameras[Index: Integer]: TWIACamera read GetCameraByIndex; default;
    property Count: Integer read GetCount;
  end;

  TWIACamera = class(TObject)
  private
    FDeviceInfo: IDeviceInfo;
    FDevice: IDevice;
    FProp: IProperty;
    FItem: IItem;
    FCameraName: string;
    FImages: TList;
    procedure InitImages;
    function GetImageByIndex(Index: Integer): TWIACameraImage;
    function GetCount: Integer;
  public
    constructor Create(DeviceInfo: IDeviceInfo);
    destructor Destroy; override;
    property CameraName: string read FCameraName;
    property Images[Index: Integer]: TWIACameraImage read GetImageByIndex; default;
    property Count: Integer read GetCount;
  end;

  TBinaryArray = array of Byte;

  TWIACameraImage = class(TObject)
  private
    FItem: IItem;
    Preivew: IVector;
    ImagePreview: IImageFile;
    W, H, ImageWidth, ImageHeight, ItemFlags: Integer;
    PreviewWidth, PreviewHeight: Integer;
    BinaryPreview: TBinaryArray;
    MS: TMemoryStream;
    BitmapPreview, FinePreview: TBitmap;
    ItemName, FileNameExtension: string;
    function GetFileName: string;
    function GetItemID: string;
    function GetPreview: TBitmap;
  public
    constructor Create(Item: IItem);
    property FileName: string read GetFileName;
    property Preview: TBitmap read GetPreview;
    property ItemID: string read GetItemID;
  end;

implementation

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

function TWIAManager.GetCount: Integer;
begin
  Result := FList.Count;
end;

{ TWIACamera }

constructor TWIACamera.Create(DeviceInfo: IDeviceInfo);
var
  I: Integer;
  Index: OleVariant;
  Prop: IProperty;
begin
  FImages := TList.Create;
  FDeviceInfo := DeviceInfo;
  FCameraName := FDeviceInfo.DeviceID;
  for I := 1 to FDeviceInfo.Properties.Count do
  begin
    Index := I;

    Prop := FDeviceInfo.Properties[Index];
    if Prop.Name = 'Name' then
      FCameraName := Prop.Get_Value();
  end;
end;

destructor TWIACamera.Destroy;
begin
  FreeList(FImages);
  inherited;
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
    Result := TWIACameraImage.Create(FDevice.Items[Index + 1]);
    FImages[Index] := Result;
  end;
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

constructor TWIACameraImage.Create(Item: IItem);
begin
  FItem := Item;
  Preivew := nil;
  ItemFlags := 0;
  PreviewWidth := 0;
  PreviewHeight := 0;
  ImageWidth := 0;
  ImageHeight := 0;
  FileNameExtension := '';
  (*
    L(CItem.ItemID, 2);

    for K := 1 to CItem.Properties.Count do
    begin
      Index := K;
      Prop := CItem.Properties[Index];

      if Prop.Name = 'Filename extension' then
        FileNameExtension := string(Prop.Get_Value())
      else if Prop.Name = 'Item Flags' then
        ItemFlags := Integer(Prop.Get_Value())
      else if Prop.Name = 'Pixels Per Line' then
        ImageWidth := Integer(Prop.Get_Value())
      else if Prop.Name = 'Number of Lines' then
        ImageHeight := Integer(Prop.Get_Value())
      else if Prop.Name = 'Item Name' then
        ItemName := string(Prop.Get_Value())
      else if Prop.Name = 'Thumbnail Data' then
        Preivew := IUnknown(Prop.Get_Value()) as IVector
      else if Prop.Name = 'Thumbnail Width' then
        PreviewWidth := Integer(Prop.Get_Value())
      else if Prop.Name = 'Thumbnail Height' then
        PreviewHeight := Integer(Prop.Get_Value());

    end;
    L('------', 2);

    if ItemFlags and (ImageItemFlag or FileItemFlag) > 0 then
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
                FinePreview.SetSize(W, H);

                DrawImageEx(FinePreview, BitmapPreview, PreviewWidth div 2 - W div 2, PreviewHeight div 2 - H div 2);
                //FinePreview.Canvas.CopyRect(Rect(0, 0, W, H), BitmapPreview.Canvas, Rect(PreviewWidth div 2 - W div 2,
                //  PreviewHeight div 2 - H div 2, PreviewWidth div 2 + W div 2, PreviewHeight div 2 + H div 2));

                //FinePreview.SaveToFile('c:\' + ItemName + '.' + FileNameExtension + '.bmp');

              finally
                FinePreview.Free;
              end;
            end else
            begin
              Result := TCameraImageItem.CreateFromPath(cCamerasPath + '\' + CameraName + '\' + ItemName + '.' + FileNameExtension);
              Result.UpdateImageInfo(CItem.ItemID, BitmapPreview);
            end;

          finally
            BitmapPreview.Free;
          end;
        finally
          MS.Free;
        end;
      end;
      //Image := IUnknown(Item.Transfer('{00000000-0000-0000-0000-000000000000}')) as IImageFile;
      //Image.SaveFile('c:\' + ItemName + '.' + FileNameExtension);
    end;
  end; *)
end;

function TWIACameraImage.GetFileName: string;
begin

end;

function TWIACameraImage.GetItemID: string;
begin

end;

function TWIACameraImage.GetPreview: TBitmap;
begin

end;

end.
