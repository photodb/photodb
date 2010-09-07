unit ImageConverting;

interface

uses SysUtils, Classes, Graphics, UnitDBCommon,
     JPEG, RAWImage, PngImage, GraphicEx, GIFImage, PNGDef, TiffImageUnit,
     uFileUtils;

type
  TArGraphicClass = array of TGraphicClass;

function GetConvertableImageClasses: TArGraphicClass;
function GetConvertedFileName(FileName, NewEXT: string): string;
function ConvertableImageClass(Graphic: TGraphicClass): Boolean;
function GetConvertedFileNameWithDir(FileName, Dir, NewEXT: string): string;
function GetGraphicClass(EXT: String; ToSave: Boolean): TGraphicClass;

implementation


function GetGraphicClass(EXT: String; ToSave: Boolean): TGraphicClass;
begin

  Result := nil;

  if EXT = '' then
    Exit;

  EXT := StringReplace(EXT, '.', '', [rfReplaceAll]);
  EXT := AnsiLowerCase(EXT);
  if EXT = 'bmp' then
    result := TBitmap
  else if EXT = 'jpg' then
    result := TJpegImage
  else if EXT = 'thm' then
    result := TJpegImage
  else if EXT = 'jpeg' then
    result := TJpegImage
  else if EXT = 'ico' then
    result := TIcon
  else if EXT = 'wmf' then
    result := TMetaFile
  else if EXT = 'emf' then
    result := TMetaFile
  else if EXT = 'jfif' then
    result := TJpegImage
  else if EXT = 'jpe' then
    result := TJpegImage
  else if EXT = 'rle' then
    result := TBitmap
  else if EXT = 'dib' then
    result := TBitmap
{$IFNDEF EXT}
  else if EXT = 'win' then
    result := TTargaGraphic
  else if EXT = 'vst' then
    result := TTargaGraphic
  else if EXT = 'vda' then
    result := TTargaGraphic
  else if EXT = 'tga' then
    result := TTargaGraphic
  else if EXT = 'icb' then
    result := TTargaGraphic
  else if EXT = 'tiff' then
    result := TiffImageUnit.TTIFFGraphic
  else if EXT = 'tif' then
    result := TiffImageUnit.TTIFFGraphic
  else if EXT = 'fax' then
    result := TiffImageUnit.TTIFFGraphic
  else if EXT = 'eps' then
    result := TEPSGraphic
  else if EXT = 'pcx' then
    result := TPCXGraphic
  else if EXT = 'pcc' then
    result := TPCXGraphic
  else if EXT = 'scr' then
    result := TPCXGraphic
  else if EXT = 'rpf' then
    result := TRLAGraphic
  else if EXT = 'rla' then
    result := TRLAGraphic
  else if EXT = 'sgi' then
    result := TSGIGraphic
  else if EXT = 'rgba' then
    result := TSGIGraphic
  else if EXT = 'rgb' then
    result := TSGIGraphic
  else if EXT = 'bw' then
    result := TSGIGraphic
  else if EXT = 'psd' then
    result := TPSDGraphic
  else if EXT = 'pdd' then
    result := TPSDGraphic
  else if EXT = 'ppm' then
    result := TPPMGraphic
  else if EXT = 'pgm' then
    result := TPPMGraphic
  else if EXT = 'pbm' then
    result := TPPMGraphic
  else if EXT = 'cel' then
    result := TAutodeskGraphic
  else if EXT = 'pic' then
    result := TAutodeskGraphic
  else if EXT = 'pcd' then
    result := TPCDGraphic
  else if EXT = 'gif' then
    result := TGIFImage
  else if EXT = 'cut' then
    result := TCUTGraphic
  else if EXT = 'psp' then
    result := TPSPGraphic

  else if Pos('|' + AnsiUpperCase(EXT) + '|', RAWImages) > -1 then
    result := TRAWImage

  else if EXT = 'png' then
  begin
    if ToSave then
      result := PngImage.TPNGGraphic
    else
      result := GraphicEx.TPNGGraphic;
  end;
  // PNG_CAN_SAVE MANUALLY processing
  // else if Ext = 'png' then begin if PNG_CAN_SAVE then Result := PngImage.TPNGGraphic else  Result := GraphicEx.TPNGGraphic;  end;
{$ENDIF}
end;

function ConvertableImageClass(Graphic : TGraphicClass) : Boolean;
 var
   I: Integer;
   Gpaphics: TArGraphicClass;
 begin
   Result := False;
   Gpaphics := GetConvertableImageClasses;
   for I := 0 to Length(Gpaphics) - 1 do
     if Gpaphics[I] = Graphic then
     begin
       Result := True;
       Exit;
     end;
 end;

function GetConvertableImageClasses : TArGraphicClass;

  procedure AddClass(AClass : TGraphicClass);
  begin
    SetLength(Result, Length(Result) + 1);
    Result[Length(Result) - 1] := AClass;
  end;

begin
  InitPNG;

  AddClass(TJPEGImage);
  if PNG_CAN_SAVE then
    AddClass(TPngGraphic);
  AddClass(TiffImageUnit.TTIFFGraphic);
  AddClass(TGIFImage);
  AddClass(TBitmap);
  AddClass(TTargaGraphic);
end;

function GetConvertedFileName(FileName, NewEXT  : string) : string;
var
  S, Dir: string;
  I: Integer;
begin
  Result := FileName;
  Dir := ExtractFileDir(Result);
  ChangeFileExt(Result, NewEXT);
  Result := Dir + GetFileNameWithoutExt(Result) + '.' + AnsiLowerCase(NewEXT);
  if not FileExists(Result) then
    Exit;
  S := Dir + ExtractFileName(Result);
  I := 1;
  while (FileExists(S)) do
  begin
    S := Dir + GetFileNameWithoutExt(Result) + ' (' + IntToStr(I) + ').' + NewEXT;
    Inc(I);
  end;
  Result := S;
end;

function GetConvertedFileNameWithDir(FileName, Dir, NewEXT  : string) : string;
var
  S: string;
  I: Integer;
begin
  Result := FileName;
  FormatDir(Dir);
  ChangeFileExt(Result, NewEXT);
  Result := Dir + GetFileNameWithoutExt(Result) + '.' + AnsiLowerCase(NewEXT);
  if not FileExists(Result) then
    Exit;
  S := Dir + ExtractFileName(Result);
  I := 1;
  while (FileExists(S)) do
  begin
    S := Dir + GetFileNameWithoutExt(Result) + ' (' + IntToStr(I) + ').' + NewEXT;
    Inc(I);
  end;
  Result := S;
end;

end.
