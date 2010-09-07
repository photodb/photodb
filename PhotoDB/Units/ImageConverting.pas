unit ImageConverting;

interface

uses SysUtils, Classes, Graphics, Dolphin_DB,
  JPEG, GraphicEx, GIFImage, PNGDef, TiffImageUnit,
  UFileUtils;

type
  TArGraphicClass = array of TGraphicClass;

function GetConvertableImageClasses: TArGraphicClass;
function GetConvertedFileName(FileName, NewEXT: string): string;
function ConvertableImageClass(Graphic: TGraphicClass): Boolean;
function GetConvertedFileNameWithDir(FileName, Dir, NewEXT: string): string;

implementation

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

 procedure AddClass(Class_ : TGraphicClass);
 begin
  SetLength(Result,Length(Result)+1);
  Result[Length(Result)-1]:=Class_;
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
  Dir := GetDirectory(Result);
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
