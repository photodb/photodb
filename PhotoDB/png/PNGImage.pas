unit PngImage;
{
2000 Nov 10  Minor change to make writing work,                      [djt]
             and to make 8-bit greyscale images save correctly       [djt]
2000 Nov 18  Make CompressionLevel work correctly on save            [djt]
             Make the three text fields save properly                [djt]
             Add new FilterChoice property                           [djt]
             Add new ForceColor property for input, default True     [djt]
             For 8-bit images, save palettes correctly               [djt]
             For 8-bit images, use palette loaded from PNG           [djt]
2000 Nov 19  Add Software property                                   [djt]
             Unify text saving code                                  [djt]
2000 Nov 21  Add standard OnProgress functions, only tested write.   [djt]
             In this code, moved some up PngImage routines which had
             slipped into the PngGraphic routines.                   [djt]

[djt] => davidtaylor@writeme.com => www.satsignal.net
}

{
  Change Made By : Dominique Louis ( Dominique@SavageSoftware.com.au )
  Change Made On : 30/05/2000
  Change Description :
    General Code Clean up to make it more readable with consistant naming
    conventions. Sorry Umberto, but I typically freak out when my begin...end or
    try..finally do not stand out on their own.
    This library implements 8 bit png, gamma and callback to show loading progress.
    Added Transparency Code
    Added Background Color Code
    Added Gamma Code
    Fixed various display bugs ( and probably introduced a few )
    Added Read and write Progress functionality
    Added preliminary Interlace code

  I can be reached at :
  Dominique Louis ( Dominique@SavageSoftware.com.au )
  
  ------------------------------------------------------------------------------

  Uberto Barbini (uberto@usa.net)
  23 Jan 2000

  Added Text support ( Title, Author, Description ).
  Added Time support.
  Fixed some bugs.


  14 Dec 1999.

  Disclaimer: I made some quick changes to support both bmp and png images.
  Internally, it works with 24bit DIBs only. If you need some improvements
  just do them and then let me know ;-))

  I used the new Cardinal type with Delphi 4 to avoid warnings.
  If you have D3 or earlier, you have to remove the Default parameters 
  from CopyToBmp. 

  This file is based largely on a similar file produced by Edmund H. Hand.
  This has been modified to work with the newest version of the PNG DLL,
  and many other changes have been made. Do NOT attempt to use this file
  with older versions of the DLL! It requires 1.0.5 (and may work with
  newer versions when they come out).

    
  COPYRIGHT NOTICE:

  The unit is supplied "AS IS".  The Author disclaims all warranties,
  expressed or implied, including, without limitation, the warranties of
  merchantability and of fitness for any purpose.  The Author assumes no
  liability for direct, indirect, incidental, special, exemplary, or
  consequential damages, which may result from the use of this unit, even
  if advised of the possibility of such damage.

  Permission is hereby granted to use, copy, modify, and distribute this
  source code, or portions hereof, for any purpose, without fee, subject
  to the following restrictions:
  1. The origin of this source code must not be misrepresented.
  2. Altered versions must be plainly marked as such and must not be
     misrepresented as being the original source.
  3. This Copyright notice may not be removed or altered from any source or
     altered source distribution.

  I can be reached at:
  Uberto Barbini (uberto@usa.net)
}

interface

uses Windows, SysUtils, Classes, Graphics, PngDef;

type TPngImage = class
  private
    FBitDepth:      integer;
    FBytesPerPixel: Cardinal; // [djt] why not alter this as well, then?
    FColorType:     integer;
    FHeight:        Cardinal; //ub used Cardinal instead of integer
    FWidth:         Cardinal; //ub used Cardinal instead of integer
    FInterlaceType: integer;
    FCompression:   integer;
    FFilter:        integer;
    FFilters:       integer;  // [djt] choice of filters
    FBgColor :  TColor; // DL Background color Added 30/05/2000
    FTransparent : Boolean; // DL Is this Image Transparent   Added 30/05/2000
    FRowBytes : Cardinal;   //DL Added 30/05/2000
    FGamma :  double; //DL Added 07/06/2000
    FScreenGamma : double; //DL Added 07/06/2000
    FNumberOfPasses : integer; //DL Added 08/06/2000
    FCompressionLevel : integer; //DL Added 08/06/2000
    FPngStruct: png_structp;
    FPngInfo: png_infop;

    FData:           PByte; // DL Changed for consistancy 30/05/2000
    FRowPtrs:        PByte; // DL Changed for consistancy 30/05/2000
    FRefCount:       Integer; // DL Changed for consistancy 30/05/2000
    FAuthor: string;
    FDescription: string;
    FSoftware: string;
    FTitle: string;
    FTextChk: TStringList;
    FLastMod: TdateTime;
    FReadProgressCallback: Pointer;  //DL Added 08/06/2000
    FWriteProgressCallback: Pointer;
    FOnProgress: TProgressEvent;   // [djt]

    FForceColor: boolean;  // [djt], makes paletted and 8-bit greyscale
                           // images load as 24-bit colour
    FPngPalette: array [0..255] of TPngColor;  // [djt]
    FNumPalette: integer;                      // [djt]
    procedure SetAuthor(const Value: string);
    procedure SetDescription(const Value: string);
    procedure SetSoftware(const Value: string);                      // [djt]
    procedure SetTitle(const Value: string);
  protected
    procedure InitializeDemData;
    function GetTextChk: TStrings;
    procedure Progress (Sender: TObject;  Stage: TProgressStage;    // [djt]
                        PercentDone: Byte;  RedrawNow: Boolean;
                        const R: TRect; const Msg: string); dynamic;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure CopyToBmp(var aBmp: TBitmap; originX: integer = 0; originY: Integer = 0);
    procedure CopyFromBmp(const aBmp: TBitmap);

    procedure Draw(ACanvas: TCanvas; const Rect: TRect);
    function  GetReference: TPngImage;
    procedure LoadFromFile(const Filename: string);
    procedure Release;
    procedure SaveToFile(const Filename: string);
    procedure LoadFromStream( Stream: TStream );
    procedure SaveToStream( Stream: TStream );
    procedure SetReadProgressCallback( FunctionName : Pointer ); //DL Added 08/06/2000
    procedure SetWriteProgressCallback( FunctionName : Pointer ); //DL Added 08/06/2000
  published
    property Title: string read FTitle write SetTitle;
    property Author: string read FAuthor write SetAuthor;
    property Description: string read FDescription write SetDescription;
    property Software: string read FSoftware write SetSoftware;
    property BitDepth:      integer read FBitDepth;
    property BytesPerPixel: Cardinal read FBytesPerPixel;  // [djt - to cardinal]
    property ColorType:     integer read FColorType;
    property Height:        Cardinal read FHeight;
    property Width:         Cardinal read FWidth;
    property Interlace:     integer read FInterlaceType;
    property Compression:   integer read FCompression;
//    property Filter:        integer read FFilter;
// [djt] the Filter property can only ever be one value, is it worth exposing?
    property Filters: integer read FFilters write FFilters;
    property TextChk: TStrings read GetTextChk;
    property LastModified: TdateTime read FLastMod;
    property Transparent : Boolean read FTransparent;
    property NumberOfPasses : integer read FNumberOfPasses;
    property CompressionLevel: integer read FCompressionLevel write FCompressionLevel;
    property ForceColor: boolean read FForceColor write FForceColor;  // [djt]
    property OnProgress: TProgressEvent read FOnProgress write FOnProgress; // [djt]
  end;

const
  Z_NO_COMPRESSION = 0;
  Z_BEST_SPEED = 1;
  Z_BEST_COMPRESSION = 9;

type TPngGraphic = class(TGraphic)
  private
    procedure SetOnProgress (const Value: TProgressEvent);  // [djt]
    function GetOnProgress: TProgressEvent;  // [djt]
  protected
    procedure Draw(ACanvas: TCanvas; const Rect: TRect); override;
    function  GetEmpty: Boolean; override;
    function  GetHeight: Integer; override;
    function  GetWidth: Integer; override;
    procedure SetHeight(Value: Integer); override;
    procedure SetWidth(Value: Integer); override;
  public
    Image: TPngImage;

    constructor Create; override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    procedure LoadFromFile(const Filename: string); override;
    procedure SaveToFile(const Filename: string); override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure LoadFromClipboardFormat(AFormat: Word; AData: THandle;
              APalette: HPALETTE); override;
    procedure SaveToClipboardFormat(var AFormat: Word; var AData: THandle;
              var APalette: HPALETTE); override;
    property OnProgress: TProgressEvent read GetOnProgress write SetOnProgress;
  published
end;

procedure SaveBmpAsPng( aBitmap: TBitmap; FileName: string );
procedure LoadBmpAsPng( aBitmap: TBitmap; FileName: string );


implementation

uses Dialogs;

procedure SaveBmpAsPng( aBitmap: TBitmap; FileName: string );
var
  png: TPngImage;
begin
  png := TPngImage.Create;
  try
    png.CopyFromBmp( aBitmap );
    png.SaveToFile( FileName );
  finally
    png.Free;
  end;
end;

procedure LoadBmpAsPng( aBitmap: TBitmap; FileName: string );
var
  png: TPngImage;
begin
  png := TPngImage.Create;
  try
    png.LoadFromFile( FileName );
    png.CopyToBmp( aBitmap );
  finally
    png.Free;
  end;
end;


//
// TPngImage
//
constructor TPngImage.Create;
begin
  inherited;
  FData     := nil;
  FRowPtrs  := nil;
  FHeight  := 0;
  FWidth   := 0;
  FRefCount := 1;
  // ub default values
  FColorType := PNG_COLOR_TYPE_RGB;
  FInterlaceType := PNG_INTERLACE_NONE;
  FCompression := PNG_COMPRESSION_TYPE_DEFAULT;
  FCompressionLevel := 3;  // [djt] a good compromise, but can override this...
  FFilter := PNG_FILTER_TYPE_DEFAULT;
  // fast and good filtering
  FFilters := PNG_FILTER_NONE or PNG_FILTER_SUB or PNG_FILTER_UP;
  FForceColor := True;
  FTextChk := TStringList.Create;
end;  // TPngImage.Create

destructor  TPngImage.Destroy;
begin
  FTextChk.Free;
  if FData <> nil then
    FreeMem(FData);
  if FRowPtrs <> nil then
    FreeMem(FRowPtrs);
  //png_destroy_read_struct(@FPngStruct, @FPngInfo, nil);
  inherited;
end;  // TPngImage.Destroy

procedure TPngImage.Draw(ACanvas: TCanvas; const Rect: TRect);
var
  bmp: TBitmap;
begin
  bmp := TBitmap.Create;
  try
    CopyToBmp( bmp );
    ACanvas.Draw( 0, 0, bmp );
  finally
    bmp.free;
  end;
end;

procedure TPngImage.CopyToBmp( var aBmp: TBitmap; originX: integer = 0; originY: Integer = 0 ); //ub
var
  valuep:  PByte;
  h, w, x, y:    Integer;
  ndx:     Integer;
  sl:      PByteArray;  // Scanline of bitmap
  slbpp:   Integer;     // Scanline bytes per pixel
  a, r, g, b: Byte;
  // Palette stuff
  log_pal: TMaxLogPalette;
  pal: HPalette;
begin
  if Height > Cardinal( MaxInt ) then
    raise Exception.Create( 'Image too high' );

  if Width > Cardinal( MaxInt ) then
    raise Exception.Create( 'Image too wide' );

  h := FHeight;

  w := FWidth;

  if aBmp.Height < h + originy then
    aBmp.Height := h + originy;

  if aBmp.Width < w + originx then
    aBmp.Width  := w + originx;

  case FBytesPerPixel of
    1:
    begin
      aBmp.PixelFormat := pf8Bit;
      slbpp := 1;
      // pal := aBmp.Palette;  // would point to existing palette
      // Perhaps we should delete the existing palette?

      // [djt] What we do here depends on the type of image we have.  It may
      // already be paletted, in which case we should preserve the palette,
      // or it may be greyscale, in which case we should build a suitable
      // palette for the BMP image.  For the moment, we keep the palette
      // indices correct, the correct palette colours can come later.

      // Check if this image has a palette.  If so, then tell the destination
      // bitmap about it.....

      if (FNumPalette <> 0) then
        begin
        log_pal.palVersion := $0300;          // fill Windows palette structure
        log_pal.palNumEntries := FNumPalette; // actual number of pal. entries
        for ndx := 0 to FNumPalette - 1 do    // loop over active entries
          begin
          with log_pal.palPalEntry [ndx], FPngPalette [ndx] do
            begin
            peBlue := blue;                   // copy the RGB byte values
            peGreen := green;
            peRed := red;
            peFlags := 0;                     // makr as absolute colour
            end;
          end;
        pal := CreatePalette (PLogPalette(@log_pal)^);
        aBmp.Palette := pal;
        end;
    end;
    2:
    begin
      aBmp.PixelFormat := pf16Bit;
      slbpp := 2;
    end;
    else
    begin
      aBmp.PixelFormat := pf24Bit;
      slbpp := 3;
    end;
  end;

  aBmp.Transparent := Transparent;

  // point to data
  valuep := FData;
  for y := 0 to FHeight - 1 do
  begin
    sl := aBmp.Scanline[ y + originy ];  // current scanline
    for x := 0 to FWidth - 1 do
    begin
      ndx := ( x + originx ) * slbpp;    // index into current scanline
      if FBytesPerPixel = 1 then
      begin
        // handle 8 bit greyscale images, assumed not paletted
        sl[ndx]     := valuep^;
        Inc (valuep);
      end
      else if FBytesPerPixel = 2 then
      begin
        // handle 16bit grayscale images, this will display them
        // as a 16bit color image, kinda hokie but fits my needs
        // without altering the data.
        sl[ndx]     := valuep^;
        Inc(valuep);
        sl[ndx + 1] := valuep^;
        Inc(valuep);
      end
      else if FBytesPerPixel = 3 then
      begin
        // RGB - swap blue and red for windows format
        sl[ndx + 2] := valuep^;
        Inc(valuep);
        sl[ndx + 1] := valuep^;
        Inc(valuep);
        sl[ndx]     := valuep^;
        Inc(valuep);
      end
      else  // 4 bytes per pixel of image data
      begin
        // Alpha chanel present and RGB
        // this is what PNG is all about
        r := valuep^;
        Inc(valuep);
        g := valuep^;
        Inc(valuep);
        b := valuep^;
        Inc(valuep);
        a := valuep^;
        Inc(valuep);
        if a = 0 then
        begin
          // alpha is zero so no blending, just image data
          sl[ndx]     := b;
          sl[ndx + 1] := g;
          sl[ndx + 2] := r;
        end
        else if a < 255 then
        begin
          // blend with data from ACanvas as background
          {sl[ndx]     := png_composite_integer( sl[ndx], a, GetBValue( FBgColor ) ); // DL Added to centralise AlphaCompositiing
          sl[ndx + 1] := png_composite_integer( sl[ndx + 1], a, GetGValue( FBgColor ) ); // DL Added to centralise AlphaCompositiing
          sl[ndx + 2] := png_composite_integer( sl[ndx + 2], a, GetRValue( FBgColor ) ); // DL Added to centralise AlphaCompositiing}
          sl[ndx]     := ((sl[ndx] * a) + ((255 - a) * b)) div 255;
          sl[ndx + 1] := ((sl[ndx + 1] * a) + ((255 - a) * g)) div 255;
          sl[ndx + 2] := ((sl[ndx + 2] * a) + ((255 - a) * r)) div 255;
        end
        else
        begin
          // if a = 0 then do not place any color from the image at this
          // pixel, but let the background color show through instead.
          sl[ndx] := GetBValue( FBgColor );  // DL Added 08/06/2000
          sl[ndx + 1] := GetGValue( FBgColor ); // DL Added 08/06/2000
          sl[ndx + 2] := GetRValue( FBgColor ); // DL Added 08/06/2000
        end;
      end;
    end;
  end;
end;  // TPngImage.CopyToBmp

procedure TPngImage.CopyFromBmp( const aBmp: TBitmap);
var
  valuep:  PByte;
  x, y:    Integer;
  ndx:     Integer;
  sl:      PByteArray;  // Scanline of bitmap
  png:     png_structp; // PPng_Struct;
  FPngInfo:  png_infop; //  PPng_Info;
  tmp:      array[0..32] of char;
  bmp_colours: array [0..255] of TPaletteEntry;
  r, g, b: byte;
  greyscale: boolean;
begin
  FNumPalette := 0;
  if aBmp.PixelFormat<>pf32Bit then
  aBmp.PixelFormat:=pf24Bit;
  case aBmp.PixelFormat of
    pf32Bit:
      begin
      FColorType := PNG_COLOR_TYPE_RGB_ALPHA;
      FBytesPerPixel := 4;
      end;
   pf24Bit:
      begin
      FColorType := PNG_COLOR_TYPE_RGB;
      FBytesPerPixel := 3;
      end;
    pf8Bit:
      begin
      FColorType := PNG_COLOR_TYPE_GRAY;
      FBytesPerPixel := 1;
      // Copy the bitmap palette into standard PNG format
      if aBmp.Palette <> 0 then
        begin
        greyscale := True;
        FNumPalette := GetPaletteEntries (aBmp.Palette, 0, 256, bmp_colours);
        for ndx := 0 to FNumPalette - 1 do
          begin
          r := bmp_colours [ndx].peRed;
          FPngPalette [ndx].red := r;
          g := bmp_colours [ndx].peGreen;
          FPngPalette [ndx].green := g;
          b := bmp_colours [ndx].peBlue;
          FPngPalette [ndx].blue := b;
          greyscale := (ndx = r) and (ndx = g) and (ndx = b);
          end;
        // An optimisation.  A greyscale image will compress better than
        // a paletted image, so only say the image is paletted if it isn't
        // a true greyscale image.
        if not greyscale then FColorType := PNG_COLOR_TYPE_PALETTE;
        end;
      end;
  else
    raise EInvalidGraphicOperation.Create('Unsupported bitmap format');
  end;

  FWidth := aBmp.Width;
  FHeight := aBmp.Height;
  FBitDepth := 8; // Single channel
  FRowBytes := FWidth * FBytesPerPixel;

  InitializeDemData;
  tmp := PNG_LIBPNG_VER_STRING;
  png :=  png_create_write_struct(tmp, nil, nil, nil);
  FPngInfo := png_create_info_struct( png );
  png_set_IHDR(png, FPngInfo, FWidth, FHeight, FBitDepth, FColorType,
               PNG_INTERLACE_NONE, PNG_COMPRESSION_TYPE_DEFAULT,
               PNG_FILTER_TYPE_DEFAULT);

  // Read the BMP image into the PNG image
  if ( FData <> nil ) and ( FRowPtrs <> nil ) then // Read the image
  begin
    valuep := FData;
    for y := 0 to FHeight - 1 do
    begin
      sl := aBmp.Scanline[ y  ];  // current scanline
      case FBytesPerPixel of
        1:
          begin
          for x := 0 to FWidth - 1 do
            begin
            valuep^ := sl [x];
            Inc (valuep);
            end;
          end;
        3:
          begin
          for x := 0 to FWidth - 1 do
            begin
            ndx := x * 3;    // index into current scanline

            // RGB - swap blue and red for windows format
            valuep^ := sl[ndx + 2];
            Inc (valuep);
            valuep^ := sl[ndx + 1];
            Inc (valuep);
            valuep^ := sl[ ndx ];
            Inc (valuep);
            end;
          end;    
        4:
          begin
          for x := 0 to FWidth - 1 do
            begin
            ndx := x * 4;    // index into current scanline

            // RGB - swap blue and red for windows format
            valuep^ := sl[ndx + 2];
            Inc (valuep);
            valuep^ := sl[ndx + 1];
            Inc (valuep);
            valuep^ := sl[ ndx ];
            Inc (valuep);   
            valuep^ := sl[ndx + 3]; //transparent chanel
            Inc (valuep);
            end;
          end;
      end;
    end;
  end;
end;  // TPngImage.CopyFromBmp

function  TPngImage.GetReference: TPngImage;
begin
  Inc(FRefCount);
  Result := Self;
end;  // TPngImage.GetReference

procedure TPngImage.InitializeDemData;
var
  cvaluep:  ^Cardinal; //ub
  y:        Cardinal;
begin
  // Initialize Data and RowPtrs
  if FData <> nil then
    FreeMem(FData);
  FData := nil;
  if FRowPtrs <> nil then
    FreeMem(FRowPtrs);
  FRowPtrs := nil;

  //GetMem(Data, FHeight * FWidth * Cardinal( FBytesPerPixel ) ); DL Changed 30/05/2000
  GetMem( FData, FHeight * FRowBytes ); // DL Added 30/5/2000
  GetMem( FRowPtrs, sizeof( Pointer ) * FHeight );

  if ( FData <> nil ) and ( FRowPtrs <> nil ) then
  begin
    cvaluep := Pointer( FRowPtrs );
    for y := 0 to FHeight - 1 do
    begin
      cvaluep^ := Cardinal( FData ) + ( y * FRowBytes ); //DL Added 08/07/2000
      //cvaluep^ := Cardinal(FData) + (FWidth * Cardinal( FBytesPerPixel ) * y); //DL Changed 08/07/2000
      Inc(cvaluep);
    end;
  end;  // if (Data <> nil) and (RowPtrs <> nil) then
end;  // TPngImage.InitializeDemData

var
  CurrStream : TStream;
  CurrInstance: TPngImage;       // [djt] points to current instance
  LastProgressUpdate: DWORD;     // [djt] time of last upadte
  ioBuffer: array [ 0 .. 8192 ] of byte; //??

procedure PngReadData(png_ptr: Pointer;var data: Pointer;length: png_size_t); stdcall;
begin // Callback to read from stream
  if length <= sizeof( ioBuffer ) then
    CurrStream.ReadBuffer( data, length )
  else
    raise Exception.Create( 'Buffer override: needed ' + inttostr( length ) + 'bytes for buffer !' );
end;

procedure PngWriteData(png_ptr: Pointer;var data: Pointer;length: png_size_t); stdcall;
begin // Callback to read from stream
  // Note that you can write also if data = nil (write 0)
  if length <= sizeof( ioBuffer ) then
    CurrStream.WriteBuffer( data, length )
  else
    raise Exception.Create( 'Buffer override: needed ' + inttostr( length ) );
end;

procedure FlushData(png_ptr: Pointer); stdcall;
begin // Callback to flush the stream
end;

// [djt]  This callback does two things.  First, it checks how long it is
// since it was last called.  If less than 100msec it does nothing.
// Secondly, it handles the transition between non_delphi space where
// the libpng library lives, and Delphi classes so that a method of a
// class can be called from the libpng callback.  We do this by storing
// a pointer to the current instance ("Self") of the PngImage, and then
// calling that instance's Progress function.  As this function is shared
// between reading and writing, the simple message "Running" is used, and
// the percent progress is returned to the caller.
procedure IOCallback (png_ptr: png_structp;  row_number: png_uint_32;
                      pass: int); stdcall;
begin
  if (png_ptr = nil) or
     (row_number > PNG_MAX_UINT) or
     (not Assigned (CurrInstance)) then Exit;
  if (GetTickCount - LastProgressUpdate) > 100 then
    begin
    CurrInstance.Progress (CurrInstance, psRunning,
                           100 * row_number div CurrInstance.FHeight,
                           False, Rect (0, 0, 0, 0), 'Running');
    LastProgressUpdate := GetTickCount;
    end;
end;


// [djt]
procedure TPngImage.Progress (Sender: TObject; Stage: TProgressStage;
  PercentDone: Byte; RedrawNow: Boolean; const R: TRect;
  const Msg: string);
begin
  if Assigned (FOnProgress)
    then FOnProgress (Sender, Stage, PercentDone, RedrawNow, R, Msg);
end;


procedure TPngImage.LoadFromStream( Stream: TStream );
type
  PPngPalette = ^TPngPalette;
  TPngPalette = array [0..255] of TPngColor;
var
  tmp:      array[0..31] of char;
  sig:      array[0..3] of byte;
  Txt : png_textp;
  i, nTxt: integer;
  s: string;
  Time: png_timep;
  pBackground : png_color_16p;
  RGBValue : Byte;
  ppalette_entry: png_colorp;
begin
  Stream.ReadBuffer( sig, sizeof( sig ) );
  CurrStream := Stream;
  CurrInstance := Self;  // [djt] Leave a pointer to Self for the callback
  if png_sig_cmp( @sig, 0, sizeof( sig )) <> 0 then
   raise Exception.Create( 'Is not a valid PNG !' );

  tmp := PNG_LIBPNG_VER_STRING;
  FPngStruct := png_create_read_struct(tmp, nil, nil, nil);
  if assigned( FPngStruct ) then
  begin
    Progress (Self, psStarting, 0, False, Rect (0, 0, 0, 0), 'Start PNG read');
    FPngInfo := png_create_info_struct( FPngStruct );
    try
      if not assigned( FPngInfo ) then
        raise Exception.Create( 'Failed to Create info struct' );

      png_set_sig_bytes( FPngStruct, sizeof( sig ) );

      png_set_read_fn( FPngStruct, @ioBuffer, PngReadData);

      //Setup Read Callback function if one is assigned
      if assigned( FReadProgressCallBack ) then // DL Added 08/07/2000
        png_set_read_status_fn( FPngStruct, FReadProgressCallBack );

      //Setup Write Callback function if one is assigned
      if assigned( FWriteProgressCallBack ) then // DL Added 08/07/2000
        png_set_write_status_fn( FPngStruct, FWriteProgressCallBack );

      png_read_info( FPngStruct, FPngInfo );

      nTxt := 0;
      png_get_text( FPngStruct, FPngInfo, Txt, nTxt );

      FTextChk.Clear;
      for i := 0 to nTxt - 1 do
        begin // load all text in FTextChk
        s := txt^.key;
        s := s + '=' + Txt^.text; // better use no more than a pchar at time
        FTextChk.Add( s );
        if compareText( Txt^.key, 'Title' ) = 0 then
          FTitle := Txt^.text // load Title if present
        else if compareText( Txt^.key, 'Author' ) = 0 then
          FAuthor := Txt^.text// load Author if present
        else if compareText( Txt^.key, 'Description' ) = 0 then
          FDescription := Txt^.text; // load Description if present
        inc( Txt );
        end;

      png_get_IHDR(FPngStruct, FPngInfo, FWidth, FHeight,FBitDepth, FColorType, FInterlaceType, Fcompression, Ffilter );

      // it is not obvious from the libpng documentation, but this function
      // takes a pointer to a pointer, and it always returns valid red, green
      // and blue values, regardless of color_type: */
      png_get_bKGD(FPngStruct, FPngInfo, pBackground);
      // however, it always returns the raw bKGD data, regardless of any
      // bit-depth transformations, so check depth and adjust if necessary
      if (FBitDepth = 16) then
        FBgColor := RGB ( ( pBackground.red shr 8 ), ( pBackground.green shr 8 ), ( pBackground.blue shr 8 ) )
      else if (FColorType = PNG_COLOR_TYPE_GRAY) and ( FBitDepth < 8 ) then
      begin
          if ( FBitDepth = 1 ) then
          begin
            if pBackground.gray <> 0 then
              RGBValue := 255
            else
              RGBValue := 0;
            FBgColor := RGB ( RGBValue, RGBValue, RGBValue )
          end
          else if ( FBitDepth = 2 ) then
          begin
            RGBValue := ( 255 div 3 ) * pBackground.gray;
            FBgColor := RGB ( RGBValue, RGBValue, RGBValue )
          end
          else // FBitDepth = 4
          begin
            RGBValue := ( 255 div 15 ) * pBackground.gray;
            FBgColor := RGB ( RGBValue, RGBValue, RGBValue )
          end;
      end
      else
       begin
        if pBackground<>nil then
        FBgColor := RGB ( ( pBackground.red ), ( pBackground.green ), ( pBackground.blue ) ) else
        FBgColor := $FFFFFF;

        end;
      if ( png_get_valid( FPngStruct, FPngInfo, PNG_INFO_bKGD) = PNG_INFO_bKGD) then
        // Has No background color
        // Ideally this should be the color of the canvas
        FTransparent := true
      else
        FTransparent := false;

      FNumPalette := 0;

      // [djt] - make conversion to 24-bit RGB optional
      if FForceColor
      then
        begin
        // if bit depth is less than or equal 8 then expand...
        if ( FColorType = PNG_COLOR_TYPE_PALETTE ) and ( FBitDepth <= 8 ) then
          png_set_palette_to_rgb( FPngStruct ); // DL Changed to be more readable
        end
      else
        // Check if have an 8-bit paletted image.  If so, save the palette
        // for later use when writing to a Windows bitmap.
        if (FColorType = PNG_COLOR_TYPE_PALETTE) and (FBitDepth = 8) then
          begin
          // First, get a pointer to the palette read from file
          png_get_PLTE (FPngStruct, FPngInfo, ppalette_entry, FNumPalette);
          // Now, copy the palette into our own static buffer, as the palette
          // entries pointed to by the pointer are overwritten later by the DLL
          for i := 0 to FNumPalette - 1 do
            begin
            FPngPalette [i] := ppalette_entry^;   // Copy one palette entry
            Inc (ppalette_entry);                 // and point to the next
            end;
          end;

      if ( FColorType = PNG_COLOR_TYPE_GRAY ) and ( FBitDepth < 8 ) then
        png_set_gray_1_2_4_to_8( FPngStruct );  // DL Changed to be more readable

      // Add alpha channel if pressent
      if png_get_valid( FPngStruct, FPngInfo, PNG_INFO_tRNS ) = PNG_INFO_tRNS then
        png_set_tRNS_to_alpha( FPngStruct ); // DL Changed to be more readable

      // [djt] - make this optional
      if FForceColor then
        if ( FColorType = PNG_COLOR_TYPE_GRAY ) or ( FColorType = PNG_COLOR_TYPE_GRAY_ALPHA ) then
          png_set_gray_to_rgb( FPngStruct );

      FGamma := 0;
      FScreenGamma := 2.2;
      if ( png_get_gAMA( FPngStruct, FPngInfo, FGamma ) <> 0 ) then
        png_set_gamma( FPngStruct, FScreenGamma, FGamma )
      else
        png_set_gamma( FPngStruct, FScreenGamma, 0.45455 );

      // Change to level of transparency
      png_set_invert_alpha( FPngStruct ); // Moved 30/5/2000

      // expand images to 1 pixel per byte
      if FBitDepth < 8 then
        png_set_packing( FPngStruct );

      // Swap 16 bit images to PC Format
      if FBitDepth = 16 then
      begin
        png_set_swap( FPngStruct );
        //png_set_strip_16( png );
      end;

      // Interlacing anyone?
      if FInterlaceType = PNG_INTERLACE_ADAM7 then
        FNumberOfPasses := png_set_interlace_handling( FPngStruct );

      // update the info structure
      png_read_update_info( FPngStruct, FPngInfo );
      // png_get_IHDR(png, FPngInfo, FWidth, FHeight, FBitDepth, FColorType, Finterlace, Fcompression, Ffilter );

      FRowBytes := png_get_rowbytes( FPngStruct, FPngInfo );

      FBytesPerPixel := png_get_channels( FPngStruct, FPngInfo );  // DL Added 30/08/2000
      // FBytesPerPixel := rowbytes div FWidth; DL Changed 30/08/2000 in favor of above

      InitializeDemData;
      if (FData <> nil) and (FRowPtrs <> nil) then
      begin
        // [djt] Tell the library where our callback routine is located.
        if Assigned (FOnProgress)
          then png_set_write_status_fn (FPngStruct, @IOCallback);
        if FNumberOfPasses > 1 then
          // TODO : interlacing Code to go here...
          // for the time being read Image as normal.
          png_read_image( FPngStruct, png_bytepp( FRowPtrs ) )
        else
          // Read the whole image
          png_read_image( FPngStruct, png_bytepp( FRowPtrs ) );
      end;
      png_read_end( FPngStruct, FPngInfo ); // read last information chunks

      if png_get_time( FPngStruct, FPngInfo, Time ) > 0 then
      begin // get time if possible
        FLastMod := EncodeDate( time.year, time.month, time.Day );
        FLastMod := FLastMod + EncodeTime( time.hour, time.minute, time.second, 0 );
      end;
      Progress (Self, psEnding, 100, False, Rect (0, 0, 0, 0), 'Ended PNG read');
    finally
      png_destroy_read_struct(@FPngStruct, @FPngInfo, nil);
    end;  // try FPngInfo create
  end;
end;

procedure TPngImage.LoadFromFile(const Filename: string);
var
  pngf: TFileStream;
begin
  pngf := TFileStream.Create( FileName, fmOpenRead );
  try
    pngf.Position := 0;
    LoadFromStream( pngf );
  finally
    pngf.free;
  end;
end;

procedure TPngImage.Release;
begin
  Dec(FRefCount);
  if FRefCount <= 0 then
    Destroy;
end;  // TPngImage.Release


procedure TPngImage.SaveToStream( Stream: TStream );
var
  png:      png_structp; // PPng_Struct;
  FPngInfo:  png_infop;  // PPng_Info;

  procedure save_text (const keyword, value: string);
  // Write one keyword value pair to the PNG image
  var
    txt: png_text;
  begin
    if Trim (value) <> '' then   // Only if not blank, although blanks allowed
      begin
      FillChar (txt, SizeOf (txt), 0);         // Ensure no spurious values
      with txt do
        begin
        key := PChar (keyword);              // Point to keyword
        text := PChar (value);               // Point to value
        text_length := length (value);       // Store the length
        compression := PNG_TEXT_COMPRESSION_NONE;
        end;
      png_set_text (png, FPngInfo, @txt, 1);   // Store the text chunk
      end;
  end;

var
  tmp:      array[0..32] of char;
  //  costs, weights: array[ 0..4] of double;
  Time: png_time;
  yy, mm, dd, hh, mi, ss, ms: word;
begin
  CurrStream := Stream;
  CurrInstance := Self;  // [djt] Leave a pointer to Self for the callback
  tmp := PNG_LIBPNG_VER_STRING;
  png := png_create_write_struct( tmp, nil, nil, nil );
  Progress (Self, psStarting, 0, False, Rect (0, 0, 0, 0), 'Starting PNG write');
  if Assigned( png ) then
  begin
    // create info struct and init io functions
    FPngInfo := png_create_info_struct( png );
    try
      // set image attributes, compression, etc...
      png_set_write_fn( png, @ioBuffer, Pngwritedata, flushdata );
      png_set_compression_level (png, FCompressionLevel);

      png_set_IHDR( png, FPngInfo, FWidth, FHeight, FBitDepth, FColorType, FInterlaceType, FCompression, FFilter );

      // If we have paletted colour, write the palette now
      if FColorType = PNG_COLOR_TYPE_PALETTE then
        png_set_PLTE (png, FPngInfo, @FPngPalette [0], FNumPalette);

      save_text ('Author', FAuthor);
      save_text ('Description', FDescription);
      save_text ('Software', FSoftware);
      save_text ('Title', FTitle);

      png_write_info(png, FPngInfo);

{      // this'd force the DLL to calculate best filter for each row
       // but it doen't worth of. I'm not sure why.
      weights[ 0 ] := 1.0;
      weights[ 1 ] := 1.0;
      weights[ 2 ] := 1.0;
      weights[ 3 ] := 1.0;
      weights[ 4 ] := 1.0;
      costs[ 0 ] := 1.0;
      costs[ 1 ] := 1.0;
      costs[ 2 ] := 1.0;
      costs[ 3 ] := 1.0;
      costs[ 4 ] := 1.0;
      png_set_filter_heuristics( png, PNG_FILTER_HEURISTIC_WEIGHTED, 5, @weights, @costs );
}
      // Set filter types defined by caller or default
      png_set_filter (png, PNG_FILTER_TYPE_BASE, FFilters);

      if (FData <> nil) and (FRowPtrs <> nil) then
      begin
        // Swap 16 bit images from PC Format
        if FBitDepth = 16 then
          png_set_swap(png);

        // [djt] Tell the library where our callback routine is located.
        if Assigned (FOnProgress)
          then png_set_write_status_fn (png, @IOCallback);

        // Write the image
        png_write_image(png, png_bytepp(FRowPtrs));

        // Now you can add text or time chunks to FPngInfo if you want them save after image
        // I added time chunk for example but you'd use it only if you have changed the image.
        DecodeDate( Now, yy, mm, dd );
        DecodeTime( Now, hh, mi, ss, ms );
        time.year := yy;
        Time.month := mm;
        Time.day := dd;
        Time.hour := hh;
        Time.minute := mi;
        Time.second := ss;
        png_set_tIME( png, FPngInfo, @time );

        png_write_end(png, FPngInfo );
        Progress (Self, psEnding, 100, False, Rect (0, 0, 0, 0), 'Ended PNG write');
      end;  // if buf <> nil
    finally
      png_destroy_write_struct(@png, @FPngInfo);
    end;  // try FPngInfo create
  end;
end;

procedure TPngImage.SaveToFile(const Filename: string);
var
  pngf: TFileStream;
begin
  pngf := TFileStream.Create( FileName, fmCreate );
  try
    pngf.Position := 0;
    SaveToStream( pngf );
  finally
    pngf.free;
  end;
end;
  // TPngImage.SaveToFile


procedure TPngImage.SetAuthor(const Value: string);
begin
  FAuthor := Value;
end;

procedure TPngImage.SetDescription(const Value: string);
begin
  FDescription := Value;
end;

procedure TPngImage.SetTitle(const Value: string);
begin
  FTitle := Value;
end;

function TPngImage.GetTextChk: TStrings;
begin
  result := FTextChk;
end;

procedure TPngImage.SetReadProgressCallback(FunctionName: Pointer);
begin
  FReadProgressCallback := FunctionName;
end;

procedure TPngImage.SetWriteProgressCallback(FunctionName: Pointer);
begin
  FWriteProgressCallback := FunctionName;
end;

procedure TPngImage.SetSoftware(const Value: string);    // [djt]
begin
  FSoftware := Value;
end;

//
// TPngGraphic
//
constructor TPngGraphic.Create;
begin
inherited;
  SetTransparent(True);
  Image := TPngImage.Create;
end;  // TPngGraphic.Create

destructor TPngGraphic.Destroy;
begin
  Image.Release;
inherited;
end;  // TPngGraphic.Destroy

procedure TPngGraphic.Assign(Source: TPersistent);
begin
  if Source is TPngGraphic then
  begin
    if Assigned(Image) then
      Image.Release;

    if Assigned(Source) then
    begin
      Image := TPngGraphic(Source).Image;
    end
    else
    begin
      Image := TPngImage.Create;
    end;
    Changed(Self);
    Image := TPngGraphic(Source).Image.GetReference;
  end
  else
  begin
   if Source is TBitmap then
   begin
    image.CopyFromBmp(Source as TBitmap);
    image.CompressionLevel := 4;
    image.Filters := PNG_FILTER_NONE or PNG_FILTER_SUB or PNG_FILTER_PAETH;
   end else
    inherited Assign(Source);
  end;
end;  // TPngGraphic.Assign

procedure TPngGraphic.Draw(ACanvas: TCanvas; const Rect: TRect);
begin
  if Assigned(Image) then
    Image.Draw(ACanvas, Rect);
end;  // TPngGraphic.Draw

function  TPngGraphic.GetEmpty: Boolean;
begin
  if Assigned(Image) then
    Result := False
  else
    Result := True;
end;  // TPngGraphic.GetEmpty

function TPngGraphic.GetHeight: Integer;
begin
  Result := Image.Height;
end;  // TPngGraphic.GetHeight

function TPngGraphic.GetWidth: Integer;
begin
  Result := Image.Width;
end;  // TPngGraphic.GetWidth

procedure TPngGraphic.LoadFromClipboardFormat(AFormat: Word; AData: THandle;
          APalette: HPALETTE);
begin
  raise Exception.Create('Cannot load a TPngGraphic from the Clipboard');
end;  // TPngGraphic.LoadFromClipboardFormat

procedure TPngGraphic.LoadFromFile(const Filename: string);
begin
  if not Assigned(Image) then
    Image := TPngImage.Create;
  Image.LoadFromFile(Filename);
end;  // TPngGraphic.LoadFromFile

procedure TPngGraphic.LoadFromStream(Stream: TStream);
begin
  if Assigned(Image) then
    Image.LoadFromStream( Stream );
end;  // TPngGraphic.LoadFromStream

procedure TPngGraphic.SaveToClipboardFormat(var AFormat: Word;
          var AData: THandle; var APalette: HPALETTE);
begin
  raise Exception.Create('Cannot save a TPngGraphic to the Clipboard');
end;  // TPngGraphic.SaveToClipboardFormat

procedure TPngGraphic.SaveToFile(const Filename: string);
begin
  if Assigned(Image) then
    Image.SaveToFile(Filename);
end;  // TPngGraphic.SaveToFile

procedure TPngGraphic.SaveToStream(Stream: TStream);
begin
  if Assigned(Image) then
    Image.SaveToStream( Stream );
end;  // TPngGraphic.SaveToStream

procedure TPngGraphic.SetHeight(Value: Integer);
begin
  raise Exception.Create('Cannot set height on a TPngGraphic');
end;  // TPngGraphic.SetHeight

procedure TPngGraphic.SetOnProgress (const Value: TProgressEvent);
begin
  // [djt] Tell the PngImage about the event
  Image.FOnProgress := Value;
end;

procedure TPngGraphic.SetWidth(Value: Integer);
begin
  raise Exception.Create('Cannot set width on a TPngGraphic');
end;  // TPngGraphic.SetWidth

function TPngGraphic.GetOnProgress: TProgressEvent;
begin
  Result := Image.FOnProgress;
end;


initialization
//  TPicture.RegisterFileFormat('PNG', 'Portable Network Graphics', TPngGraphic);
finalization
//  TPicture.UnRegisterGraphicClass(TPngGraphic);
end.

