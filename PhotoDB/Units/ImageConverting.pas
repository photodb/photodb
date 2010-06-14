unit ImageConverting;

interface

 uses SysUtils, Classes, Graphics, Dolphin_DB,
     JPEG, GraphicEx, GIFImage, PNGDef, TiffImageUnit;

 type TArGraphicClass = array of TGraphicClass;

function GetConvertableImageClasses : TArGraphicClass;
function GetConvertedFileName(FileName, NewEXT  : string) : string;
function ConvertableImageClass(Graphic : TGraphicClass) : Boolean;
function GetConvertedFileNameWithDir(FileName, Dir, NewEXT  : string) : string;

implementation

function ConvertableImageClass(Graphic : TGraphicClass) : Boolean;
var
  i : integer;
  Gpaphics : TArGraphicClass;
begin
 Result:=false;
 Gpaphics:=GetConvertableImageClasses;
 for i:=0 to Length(Gpaphics)-1 do
 if Gpaphics[i]=Graphic then
 begin
  Result:=true;
  exit;
 end;
end;

function GetConvertableImageClasses : TArGraphicClass;

 procedure AddClass(Class_ : TGraphicClass);
 begin
  SetLength(Result,Length(Result)+1);
  Result[Length(Result)-1]:=Class_;
 end;

begin
 AddClass(TBitmap);
 AddClass(TJPEGImage);
 AddClass(TGIFImage);
// AddClass(TPSDGraphic);
// AddClass(TPNGGraphic);
// AddClass(TIcon);
// AddClass(TMetaFile);
 AddClass(TTargaGraphic);
 if PNG_CAN_SAVE then
 AddClass(TPngGraphic);
 AddClass(TiffImageUnit.TTIFFGraphic);
// AddClass(TEPSGraphic);
// AddClass(TPCXGraphic);
// AddClass(TRLAGraphic);
// AddClass(TSGIGraphic);
// AddClass(TPCDGraphic);
// AddClass(TPPMGraphic);
// AddClass(TAutodeskGraphic);
// AddClass(TCUTGraphic);
// AddClass(TPSPGraphic);
end;

function GetConvertedFileName(FileName, NewEXT  : string) : string;
var
  s, dir : string;
  i : integer;
begin
 Result:=FileName;
 dir:=GetDirectory(Result);
 ChangeFileExt(Result,NewEXT);
 Result:=dir+GetFileNameWithoutExt(Result)+'.'+AnsiLowerCase(NewEXT);
 if not FileExists(Result) then exit;
 s:=dir+ExtractFileName(Result);
 i:=1;
 While (FileExists(s)) do
 begin
  s:=dir+GetFileNameWithoutExt(Result)+' ('+IntToStr(i)+').'+NewEXT;
  inc(i);
 end;
 Result:=s;
end;

function GetConvertedFileNameWithDir(FileName, Dir, NewEXT  : string) : string;
var
  s : string;
  i : integer;
begin
 Result:=FileName;
 FormatDir(Dir);
 ChangeFileExt(Result,NewEXT);
 Result:=dir+GetFileNameWithoutExt(Result)+'.'+AnsiLowerCase(NewEXT);
 if not FileExists(Result) then exit;
 s:=dir+ExtractFileName(Result);
 i:=1;
 While (FileExists(s)) do
 begin
  s:=dir+GetFileNameWithoutExt(Result)+' ('+IntToStr(i)+').'+NewEXT;
  inc(i);
 end;
 Result:=s;
end;

end.
