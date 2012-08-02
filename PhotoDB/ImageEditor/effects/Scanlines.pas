
(*

       Scanlines.pas, Sep 2003    (Delphi 7)

       Copyright Chris Willig 2003, All Rights Reserved.
       May be used freely for non-commercial purposes.

       chris@5thElephant.com

       ******   RotateBmp() uses code copyrighted by Earl F. Glynn   ******

                SmoothResize() and GrayScale() use code adapted from a
                newsgroup example posted by Charles Hacker


           Uses pointers to access TBitmap.Scanline[], roughly 3 times faster
           than accessing Scanline[] directly in a typical looping routine.


*)

unit Scanlines;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics;

type
  TRGBArray = ARRAY[0..32767] OF TRGBTriple; //pf24bit
  pRGBArray = ^TRGBArray;

  //  TScanlines is a wrapper for accessing scanlines with pointers.
  //    see BitmapsEqual() and RotateBmp() for examples.
  TScanlines = class
  private
    FScanLine0 : PByte;
    FScanLineIncrement : integer;
    FMaxRow : integer;
    function GetRowPtr(Index: integer): PByte;
  public
    constructor Create(Bitmap: TBitmap);
    destructor Destroy; override;

    property RowPtr[Index: Integer]: PByte read GetRowPtr; default;
  end;

  TrgbaProc = procedure(pRGBA: pRGBArray; const Width: integer; var Dun: boolean) stdcall;
  TpbaProc = procedure(pB: PByteArray; const Width: integer; var Dun: boolean) stdcall;

implementation

// TScanlines...

constructor TScanlines.Create(Bitmap: TBitmap);
begin
  inherited Create;

  FScanLine0 := nil;
  FScanLineIncrement := 0;
  FMaxRow := 0;

  if Bitmap <> nil then begin
    FScanLine0 := Bitmap.ScanLine[0];
    FScanLineIncrement := 0;
    if Bitmap.Height > 0 then
      FScanLineIncrement := NativeInt(Bitmap.Scanline[1]) - NativeInt(FScanLine0);
    FMaxRow := Bitmap.Height;
  end;
end;

destructor TScanlines.Destroy;
begin
  inherited;
end;

function TScanlines.GetRowPtr(Index: integer): PByte;
begin
  if (Index >= 0) and (Index < FMaxRow) then begin
    result := FScanLine0;
    Inc(result, FScanLineIncrement *Index);
  end else
    result := nil;
end;

// ...TScanlines

end.
