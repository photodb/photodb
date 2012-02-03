unit uImportSeriesPreview;

interface

uses
  Generics.Collections,
  uThreadEx,
  uMemory,
  SysUtils,
  Graphics,
  uThreadForm,
  UnitBitmapImageList,
  uPathProviders,
  uIconUtils,
  uShellIcons,
  uDBImageUtils,
  uPortableDeviceUtils,
  System.Classes;

type
  TImportSeriesPreview = class(TThreadEx)
  private
    { Private declarations }
    FData: TList<TPathItem>;
    FImageSize: Integer;
    FPacketImages: TBitmapImageList;
    FPacketInfos: TList<TPathItem>;
    FBitmap: TBitmap;
    FItemParam: TPathItem;
  protected
    procedure Execute; override;
    procedure SendPacketOfPreviews;
    procedure UpdatePreview;
  public
    constructor Create(OwnerForm: TThreadForm; Items: TList<TPathItem>; ImageSize: Integer);
    destructor Destroy; override;
  end;

implementation

uses
  uFormImportImages;

{ TImportSeriesPreview }

constructor TImportSeriesPreview.Create(OwnerForm: TThreadForm;
  Items: TList<TPathItem>; ImageSize: Integer);
begin
  inherited Create(OwnerForm, OwnerForm.StateID);
  FData := Items;
  FImageSize := ImageSize;
end;

destructor TImportSeriesPreview.Destroy;
begin
  FreeList(FData);
  inherited;
end;

procedure TImportSeriesPreview.Execute;
var
  I: Integer;
  Data: TObject;
  PI: TPathItem;
  FIcon: TIcon;
begin
  FreeOnTerminate := True;

  FPacketImages := TBitmapImageList.Create;
  FPacketInfos := TList<TPathItem>.Create;
  try
    //loading list with icons
    for I := 0 to FData.Count - 1 do
    begin
      PI := FData[I];

      FIcon := TIcon.Create;
      FIcon.Handle := ExtractDefaultAssociatedIcon('*' + ExtractFileExt(PI.Path), ImageSizeToIconSize16_32_48(FImageSize));
      FPacketImages.AddIcon(FIcon, True);
      FPacketInfos.Add(PI);

      if I mod 10 = 0 then
        SynchronizeEx(SendPacketOfPreviews);

    end;
    if FPacketInfos.Count > 0 then
      SynchronizeEx(SendPacketOfPreviews);

    for I := 0 to FData.Count - 1 do
    begin
      if IsTerminated then
        Break;
      FItemParam := FData[I];
      FBitmap := TBitmap.Create;
      try
        Data := nil;
        if IsDevicePath(FData[I].Path) then
        begin
          if FData[I].Provider.ExtractPreview(FData[I], FImageSize, FImageSize, FBitmap, Data) then
          begin
            if SynchronizeEx(UpdatePreview) then
              FBitmap := nil;
          end;
        end else
        begin
          if ExtractFilePreview(FData[I].Path, FImageSize, FImageSize, FBitmap) then
          begin
            if SynchronizeEx(UpdatePreview) then
              FBitmap := nil;
          end;
        end;
      finally
        F(FBitmap);
      end;
    end;

  finally
    F(FPacketImages);
    F(FPacketInfos);
  end;
end;

procedure TImportSeriesPreview.SendPacketOfPreviews;
begin
  TFormImportImages(OwnerForm).AddPreviews(FPacketInfos, FPacketImages);
  FPacketInfos.Clear;
  FPacketImages.ClearItems;
end;

procedure TImportSeriesPreview.UpdatePreview;
begin
  TFormImportImages(OwnerForm).UpdatePreview(FItemParam, FBitmap);
end;

end.
