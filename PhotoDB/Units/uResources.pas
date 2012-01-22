unit uResources;

interface

uses
  Windows,
  Generics.Collections,
  SysUtils,
  Classes,
  Graphics,
  JPEG,
  pngImage,
  uMemory;

type
  TResourceUtils = class
    class function LoadGraphicFromRES<T: TGraphic, constructor>(ResName: string): T;
  end;

function GetFolderPicture: TPNGImage;
function GetLogoPicture: TPNGImage;
function GetSlideShowLoadPicture: TPNGImage;
function GetExplorerBackground: TPNGImage;
function GetSearchBackground: TPNGImage;
function GetDateRangeImage: TPNGImage;
function GetImagePanelImage: TPNGImage;
function GetLoadingImage: TPNGImage;
function GetActivationImage: TPNGImage;
function GetPrinterPatternImage: TJpegImage;
function GetBigPatternImage: TJpegImage;
function GetFilmStripImage: TPNGImage;
function GetPathSeparatorImage: TBitmap;

{$R MAIN.res}
{$R Logo.res}
{$R Slideshow_Load.res}
{$R Directory_Large.res}
{$R ExplorerBackground.res}
{$R SearchBackground.res}
{$R DateRange.res}
{$R Manifest.res}
{$R ImagePanelBackground.res}
{$R Loading.res}
{$R Activation.res}
{$R PrinterPattern.res}
{$R BigPattern.res}
{$R Film_Strip.res}
{$R PathSeparator.res}

//Icons
{$R icons.res}
{$R db_icons.res}
{$R ZoomRc.res}
{$R editor.res}
{$R explorer.res}
{$R search.res}
{$R panel.res}
{$R cmd_icons.res}
{$R updater.res}

//for mobile test
{$IFDEF MOBILE_TEST}
{$R MOBILE_FS.res}
{$ENDIF}

{$R explorer_search.res}

function GetRCDATAResourceStream(ResName: string): TMemoryStream;

implementation

function GetRCDATAResourceStream(ResName: string): TMemoryStream;
var
  MyRes: Integer;
  MyResP: Pointer;
  MyResS: Integer;
begin
  Result := nil;
  MyRes := FindResource(HInstance, PWideChar(ResName), RT_RCDATA);
  if MyRes <> 0 then begin
    MyResS := SizeOfResource(HInstance,MyRes);
    MyRes := LoadResource(HInstance,MyRes);
    if MyRes <> 0 then begin
      MyResP := LockResource(MyRes);
      if MyResP <> nil then begin
        Result := TMemoryStream.Create;
        with Result do begin
          Write(MyResP^, MyResS);
          Seek(0, soFromBeginning);
        end;
        UnLockResource(MyRes);
      end;
      FreeResource(MyRes);
    end
  end;
end;

{ TResourceUtils }

class function TResourceUtils.LoadGraphicFromRES<T>(ResName: string): T;
var
  RCDataStream: TMemoryStream;
begin
  Result := nil;
  RCDataStream := GetRCDATAResourceStream(ResName);
  if RCDataStream <> nil then
  begin

    Result := T.Create;
    Result.LoadFromStream(RCDataStream);
    F(RCDataStream);
  end;
end;

function GetFolderPicture: TPNGImage;
begin
  Result := TResourceUtils.LoadGraphicFromRES<TPngImage>('DIRECTORY_LARGE');
end;

function GetSlideShowLoadPicture: TPNGImage;
begin
  Result := TResourceUtils.LoadGraphicFromRES<TPngImage>('SLIDESHOW_LOAD');
end;

function GetExplorerBackground: TPNGImage;
begin
  Result := TResourceUtils.LoadGraphicFromRES<TPngImage>('EXPLORERBACKGROUND');
end;

function GetSearchBackground: TPNGImage;
begin
  Result := TResourceUtils.LoadGraphicFromRES<TPngImage>('SEARCHBACKGROUND');
end;

function GetDateRangeImage: TPNGImage;
begin
  Result := TResourceUtils.LoadGraphicFromRES<TPngImage>('DATERANGE');
end;

function GetImagePanelImage: TPNGImage;
begin
  Result := TResourceUtils.LoadGraphicFromRES<TPngImage>('IMAGEPANELBACKGROUND');
end;

function GetLoadingImage: TPNGImage;
begin
  Result := TResourceUtils.LoadGraphicFromRES<TPngImage>('LOADING');
end;

function GetLogoPicture: TPNGImage;
begin
  Result := TResourceUtils.LoadGraphicFromRES<TPngImage>('LOGO');
end;

function GetActivationImage: TPNGImage;
begin
  Result := TResourceUtils.LoadGraphicFromRES<TPngImage>('ACTIVATION');
end;

function GetPrinterPatternImage: TJpegImage;
begin
  Result := TResourceUtils.LoadGraphicFromRES<TJpegImage>('PRINTERPATTERN');
end;

function GetBigPatternImage: TJpegImage;
begin
  Result := TResourceUtils.LoadGraphicFromRES<TJpegImage>('BIGPATTERN');
end;

function GetFilmStripImage: TPNGImage;
begin
  Result := TResourceUtils.LoadGraphicFromRES<TPngImage>('FILM_STRIP');
end;

function GetPathSeparatorImage: TBitmap;
begin
  Result := TResourceUtils.LoadGraphicFromRES<TBitmap>('PATH_SEPARATOR');
end;

end.
