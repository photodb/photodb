unit uResources;

interface

uses
  Winapi.Windows,
  Generics.Collections,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Imaging.JPEG,
  Vcl.Imaging.pngImage,

  Dmitry.Imaging.JngImage,

  uMemory;

type
  TResourceUtils = class
    class function LoadGraphicFromRES<T: TGraphic, constructor>(ResName: string): T;
  end;

function GetFolderPicture: TPNGImage;
function GetLogoPicture: TJngImage;
function GetExplorerBackground: TPNGImage;
function GetLoadingImage: TJngImage;
function GetActivationImage: TPNGImage;
function GetPrinterPatternImage: TJpegImage;
function GetBigPatternImage: TJpegImage;
function GetFilmStripImage: TPNGImage;
function GetPathSeparatorImage: TBitmap;
function GetNoHistogramImage: TPNGImage;
function GetCollectionSyncImage: TPngImage;
function GetNavigateDownImage: TPngImage;
function GetFaceMaskImage: TPngImage;

{$R MAIN.res}
{$R Logo.res}
{$R Directory_Large.res}
{$R ExplorerBackground.res}
{$R Manifest.res}
{$R Loading.res}
{$R Activation.res}
{$R PrinterPattern.res}
{$R BigPattern.res}
{$R Film_Strip.res}
{$R PathSeparator.res}
{$R NoHistogram.res}
{$R SampleDB.res}
{$R Import.res}
{$R CollectionSync.res}
{$R ExplorerItems.res}
{$R FaceMask.res}

//Icons
{$R db_icons.res}
{$R ZoomRc.res}
{$R editor.res}
{$R explorer.res}
{$R cmd_icons.res}

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

function GetExplorerBackground: TPNGImage;
begin
  Result := TResourceUtils.LoadGraphicFromRES<TPngImage>('EXPLORERBACKGROUND');
end;

function GetLoadingImage: TJngImage;
begin
  Result := TResourceUtils.LoadGraphicFromRES<TJngImage>('LOADING');
end;

function GetLogoPicture: TJngImage;
begin
  Result := TResourceUtils.LoadGraphicFromRES<TJngImage>('LOGO');
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

function GetNoHistogramImage: TPNGImage;
begin
  Result := TResourceUtils.LoadGraphicFromRES<TPngImage>('NO_HISTOGRAM');
end;

function GetCollectionSyncImage: TPngImage;
begin
  Result := TResourceUtils.LoadGraphicFromRES<TPngImage>('COLLECTION_SYNC');
end;

function GetNavigateDownImage: TPngImage;
begin
  Result := TResourceUtils.LoadGraphicFromRES<TPngImage>('NAVIGATEDOWN');
end;

function GetFaceMaskImage: TPngImage;
begin
  Result := TResourceUtils.LoadGraphicFromRES<TPngImage>('FACEMASK');
end;

end.
