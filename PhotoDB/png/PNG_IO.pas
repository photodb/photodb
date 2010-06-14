unit PNG_IO;

interface

uses
  Windows, SysUtils, Graphics, PngImage, PngDef;

function LoadBmpFromPngFile (bmp: TBitmap;  const Filename: string;
                             const ForceColor: boolean): boolean;

function SaveBmpAsPngFile
   (const bmp: TBitmap;  const Filename: string;
    const Author, Description, Software, Title: string;
    const OnProgress: TProgressEvent = nil): boolean;


implementation

function SaveBmpAsPngFile
   (const bmp: TBitmap;  const filename: string;
    const Author, Description, Software, Title: string;
    const OnProgress: TProgressEvent = nil): boolean;
var
  png: TPngImage;
begin
  png := TPngImage.Create;
  try
    Result := False;
    png.CopyFromBmp (bmp);
    png.CompressionLevel := 4;
    png.Filters := PNG_FILTER_NONE or PNG_FILTER_SUB or PNG_FILTER_PAETH;
    png.Author := Author;
    png.Description := Description;
    png.Software := Software;
    png.Title := Title;
    png.OnProgress := OnProgress;
    png.SaveToFile (Filename);
    Result := True;
  finally
    png.Free;
  end;
end;


function LoadBmpFromPngFile (bmp: TBitmap;  const Filename: string;
                             const ForceColor: boolean): boolean;
var
  png: TPngImage;
begin
  png := TPngImage.Create;
  try
    Result := False;
    png.ForceColor := ForceColor;
    png.LoadFromFile (Filename);
    bmp.Height := 0;
    bmp.Width := 0;
    png.CopyToBmp (bmp);
    Result := True;
  finally
    png.Free;
  end;
end;


end.


