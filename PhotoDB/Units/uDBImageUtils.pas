unit uDBImageUtils;

interface

uses
  System.SysUtils,
  Vcl.Graphics,

  GraphicCrypt,
  RAWImage,

  uMemory,
  uSessionPasswords,
  uAssociations,
  uJpegUtils,
  uPortableDeviceUtils,
  uExifUtils,
  uBitmapUtils,
  uGraphicUtils;

//TODO: remove this function
function LoadGraphic(FileName: string; var G: TGraphic; var IsEnCrypted: Boolean; var Password: string): Boolean;
function ExtractFilePreview(FileName: string; Width, Height: Integer; var Bitmap: TBitmap): Boolean;

implementation

function LoadGraphic(FileName: string; var G: TGraphic; var IsEnCrypted: Boolean; var Password: string): Boolean;
var
  GC: TGraphicClass;
begin
  Result := False;
  F(G);
  IsEnCrypted := not IsDevicePath(FileName) and ValidCryptGraphicFile(FileName);
  if IsEnCrypted then
  begin
    Password := SessionPasswords.FindForFile(FileName);
    if PassWord = '' then
      Exit;

    G := DeCryptGraphicFile(FileName, PassWord);
  end  else
  begin
    GC := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(FileName));
    if GC = nil then
      Exit;

    G := GC.Create;
    if G is TRawImage then
      TRawImage(G).IsPreview := True;

    if not IsDevicePath(FileName) then
      G.LoadFromFile(FileName)
    else
      G.LoadFromDevice(FileName);
  end;

  Result := not G.Empty;
end;

function ExtractFilePreview(FileName: string; Width, Height: Integer; var Bitmap: TBitmap): Boolean;
var
  G: TGraphic;
  IsEncrypted: Boolean;
  Password: string;
  Rotation: Integer;
begin
  Result := False;
  G := nil;
  try
    if not LoadGraphic(FileName, G, IsEncrypted, Password) then
      Exit;

    JPEGScale(G, Width, Height);

    AssignGraphic(Bitmap, G);
    F(G);

    KeepProportions(Bitmap, Width, Height);

    if not IsDevicePath(FileName) then
    begin
      Rotation := GetExifRotate(FileName);
      ApplyRotate(Bitmap, Rotation);
    end;

    Result := not Bitmap.Empty;
  finally
    F(G);
  end;
end;

end.
