unit uExplorerWIAProvider;

interface

uses
  uPathProviders, Graphics, uMemory, uExplorerPathProvider, Classes,
  uExplorerMyComputerProvider, uConstants, uShellIcons, uTranslate,
  StrUtils, SysUtils, uBitmapUtils, uWIAManager;

type
  TCameraItem = class(TPathItem)
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
  public
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
  end;

  TCameraImageItem = class(TPathItem)
  private
    FImageName: string;
    FItemID: string;
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
  public
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
    procedure Assign(Item: TPathItem); override;
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    procedure ReadFromCameraImage(CI: TWIACameraImage);
    property ImageName: string read FImageName;
    property ItemID: string read FItemID;
  end;

type
  TCameraProvider = class(TExplorerPathProvider)
  protected
    function InternalFillChildList(Sender: TObject; Item: TPathItem; List: TPathItemCollection; Options, ImageSize: Integer; PacketSize: Integer; CallBack: TLoadListCallBack): Boolean; override;
    function GetTranslateID: string; override;
  public
    function ExtractPreview(Item: TPathItem; MaxWidth, MaxHeight: Integer; var Bitmap: TBitmap; var Data: TObject): Boolean; override;
    function Supports(Item: TPathItem): Boolean; override;
    function Supports(Path: string): Boolean; override;
    function SupportsFeature(Feature: string): Boolean; override;
    function ExecuteFeature(Sender: TObject; Item: TPathItem; Feature: string; Options: TPathFeatureOptions): Boolean; override;
    function CreateFromPath(Path: string): TPathItem; override;
  end;

implementation

function IsCameraPath(Path: string): Boolean;
begin
  Result := False;
  if StrUtils.StartsText(cCamerasPath + '\', Path) then
  begin
    Delete(Path, 1, Length(cCamerasPath + '\'));
    Result := Pos('\', Path) = 0;
  end;
end;

function IsCameraImagePath(Path: string): Boolean;
begin
  Result := False;
  if StrUtils.StartsText(cCamerasPath + '\', Path) then
  begin
    Delete(Path, 1, Length(cCamerasPath + '\'));
    Result := Pos('\', Path) > 0;
  end;
end;

function ExtractCameraName(Path: string): string;
var
  P: Integer;
begin
  Result := '';
  if StrUtils.StartsText(cCamerasPath + '\', Path) then
  begin
    Delete(Path, 1, Length(cCamerasPath + '\'));
    P := Pos('\', Path);
    if P = 0 then
      P := Length(Path);

    Result := Copy(Path, 1, P);
  end;
end;

{ TCameraProvider }

function TCameraProvider.CreateFromPath(Path: string): TPathItem;
begin
  Result := nil;
  if IsCameraImagePath(Path) then
    Result := TCameraImageItem.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0);
  if IsCameraPath(Path) then
    Result := TCameraItem.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0);
end;

function TCameraProvider.ExecuteFeature(Sender: TObject; Item: TPathItem;
  Feature: string; Options: TPathFeatureOptions): Boolean;
begin
  Result := inherited ExecuteFeature(Sender, Item, Feature, Options);
end;

function TCameraProvider.ExtractPreview(Item: TPathItem; MaxWidth,
  MaxHeight: Integer; var Bitmap: TBitmap; var Data: TObject): Boolean;
begin
  Result := False;
end;

function TCameraProvider.GetTranslateID: string;
begin
  Result := 'WIAProvider';
end;

function TCameraProvider.InternalFillChildList(Sender: TObject; Item: TPathItem;
  List: TPathItemCollection; Options, ImageSize, PacketSize: Integer;
  CallBack: TLoadListCallBack): Boolean;
var
  I, J: Integer;
  Cancel: Boolean;
  CI: TCameraItem;
  Manager: TWIAManager;
  C: TWIACamera;
  WCI: TWIACameraImage;
  CII: TCameraImageItem;
begin
  Result := True;
  Cancel := False;
  if Item is THomeItem then
  begin

    Manager := TWIAManager.Create;
    try
      for I := 0 to Manager.Count - 1 do
      begin
        CI := TCameraItem.CreateFromPath(cCamerasPath + '\' + Manager[I].CameraName, Options, ImageSize);
        List.Add(CI);

        if Assigned(CallBack) then
          CallBack(Sender, Item, List, Cancel);
        if Cancel then
          Break;
      end;
    finally
      F(Manager);
    end;
  end;
  if Item is TCameraItem then
  begin
    CI := TCameraItem(Item);

    Manager := TWIAManager.Create;
    try
      for I := 0 to Manager.Count - 1 do
        if Manager[I].CameraName = CI.DisplayName then
        begin
          C := Manager[I];
          for J := 0 to C.Count - 1 do
          begin
            WCI := C[J];
            CII := TCameraImageItem.CreateFromPath(cCamerasPath + '\' + Manager[I].CameraName + '\' + WCI.FileName, Options, ImageSize);
            CII.ReadFromCameraImage(WCI);
            List.Add(CII);
            if Assigned(CallBack) then
              CallBack(Sender, Item, List, Cancel);
          end;
        end;
    finally
      F(Manager);
    end;

  end;
end;

function TCameraProvider.Supports(Item: TPathItem): Boolean;
begin
  Result := Item is TCameraItem;
  Result := Result or Supports(Item.Path);
end;

function TCameraProvider.Supports(Path: string): Boolean;
begin
  Result := StrUtils.StartsText(cCamerasPath, Path);
end;

function TCameraProvider.SupportsFeature(Feature: string): Boolean;
begin
  Result := False;
end;

{ TCameraItem }

constructor TCameraItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
begin
  FPath := cCamerasPath;
  FDisplayName := TA('Camera', 'Path');
  if Length(APath) > Length(cCamerasPath) then
  begin
    Delete(APath, 1, Length(cCamerasPath) + 1);
    FDisplayName := APath;
    FPath := cCamerasPath + '\' + FDisplayName;
  end;
  if Options and PATH_LOAD_NO_IMAGE = 0 then
    LoadImage(Options, ImageSize);
end;

function TCameraItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TCameraItem.Create;
end;

function TCameraItem.InternalGetParent: TPathItem;
begin
  Result := THomeItem.Create;
end;

function TCameraItem.LoadImage(Options, ImageSize: Integer): Boolean;
var
  Icon: TIcon;
begin
  F(FImage);
  FindIcon(HInstance, 'CAMERA', ImageSize, 32, Icon);
  FImage := TPathImage.Create(Icon);
  Result := True;
end;

{ TCameraImageItem }

procedure TCameraImageItem.Assign(Item: TPathItem);
begin
  inherited;

end;

constructor TCameraImageItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
begin
  inherited CreateFromPath(APath, Options, ImageSize);
  FDisplayName := ExtractFileName(APath)
end;

function TCameraImageItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TCameraImageItem.Create;
end;

function TCameraImageItem.InternalGetParent: TPathItem;
begin
  Result := TCameraItem.CreateFromPath(ExtractCameraName(FPath), PATH_LOAD_NO_IMAGE, 0);
end;

function TCameraImageItem.LoadImage(Options, ImageSize: Integer): Boolean;
begin
  Result := False;
end;

procedure TCameraImageItem.ReadFromCameraImage(CI: TWIACameraImage);
begin
  F(FImage);
  FImage := TPathImage.Create(CI.ExtractPreview);
end;

initialization
  PathProviderManager.RegisterProvider(TCameraProvider.Create);
  PathProviderManager.RegisterSubProvider(TMyComputerProvider, TCameraProvider);

end.
