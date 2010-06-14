unit TiffImageUnit;

interface

  uses Windows, SysUtils, LibTiffDelphi, Graphics, Classes;

type
 TTiffGraphic = class(TBitmap)
  private
    fPage: Word;
    FPages: Word;
    procedure SetPage(const Value: Word);
    procedure SetPages(const Value: Word);
    { Private declarations }
  public                                                 
    procedure LoadFromStreamEx(Stream: TStream; Page : Word);
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure SaveToStream24(Stream: TStream);
    function GetPagesCount(Stream: TStream) : Word;
    constructor Create; override;
    { Public declarations }
  published
    property Page : Word read fPage write SetPage;
    property Pages : Word read FPages write SetPages;
  end;

 const

  gesTIFF = 'Изображения формата TIFF';
  gesMacTIFF =  'Изображения TIFF для Macintosh';
  gesPCTIF = 'PC TIF изображения';
  gesGFIFax = 'GFI fax images';

implementation

procedure TIFFReadRGBAImageSwapRB(Width,Height: Cardinal; Memory: Pointer);
{$IFDEF DELPHI_5}
type
  PCardinal = ^Cardinal;
{$ENDIF}
var
  m: PCardinal;
  n: Cardinal;
  o: Cardinal;
begin
  m:=Memory;
  for n:=0 to Width*Height-1 do
  begin
    o:=m^;
    m^:= (o and $FF00FF00) or                {G and A}
        ((o and $00FF0000) shr 16) or        {B}
        ((o and $000000FF) shl 16);          {R}
    Inc(m);
  end;
end;

{ TTiffGraphic }

constructor TTiffGraphic.Create;
begin
  inherited;
 Pages:=1;
 Page:=0;
end;

function TTiffGraphic.GetPagesCount(Stream: TStream): Word;
var
  OpenTiff: PTIFF;
begin
  OpenTiff:=TIFFOpenStream(Stream,'r');
  if OpenTiff=nil then raise Exception.Create(
           'Unable to open stream!');
  Pages:=TIFFNumberOfDirectories(OpenTiff);
  Result:=Pages;
  TIFFClose(OpenTiff);
end;

procedure TTiffGraphic.LoadFromStream(Stream: TStream);
var
  OpenTiff: PTIFF;
  FirstPageWidth,FirstPageHeight: Cardinal;
  FirstPageBitmap: TBitmap;
begin
  OpenTiff:=TIFFOpenStream(Stream,'r');
  if OpenTiff=nil then raise Exception.Create(
           'Unable to open stream!');

  Pages:=TIFFNumberOfDirectories(OpenTiff);
  if Page<Pages then
  TIFFSetDirectory(OpenTiff,Page);
   
  TIFFGetField(OpenTiff,TIFFTAG_IMAGEWIDTH,@FirstPageWidth);
  TIFFGetField(OpenTiff,TIFFTAG_IMAGELENGTH,@FirstPageHeight);
  FirstPageBitmap:=nil;
  try
    FirstPageBitmap:=TBitmap.Create;
    FirstPageBitmap.PixelFormat:=pf32bit;
    FirstPageBitmap.Width:=FirstPageWidth;
    FirstPageBitmap.Height:=FirstPageHeight;
  except
    if FirstPageBitmap<>nil then FirstPageBitmap.Destroy;
    TIFFClose(OpenTiff);
    raise Exception.Create('Unable to create TBitmap buffer');
  end;
  TIFFReadRGBAImage(OpenTiff,FirstPageWidth,FirstPageHeight,
               FirstPageBitmap.Scanline[FirstPageHeight-1],0);
  TIFFClose(OpenTiff);
  TIFFReadRGBAImageSwapRB(FirstPageWidth,FirstPageheight,
               FirstPageBitmap.Scanline[FirstPageHeight-1]);
  Assign(FirstPageBitmap);
  FirstPageBitmap.Free;
end;

procedure TTiffGraphic.LoadFromStreamEx(Stream: TStream; Page: Word);
begin
 fPage:=Page;
 SaveToStream(Stream);
end;

procedure TTiffGraphic.SaveToStream(Stream: TStream);
var
  OpenTiff: PTIFF;
  RowSize: Longword;
  RowsPerStrip: Longword;
  StripMemory: Pointer;
  StripIndex: Longword;
  StripRowOffset: Longword;
  StripRowCount: Longword;
  mb: PByte;
  ny: Longword;
begin
  if (PixelFormat<>pf1bit) then
  begin
   SaveToStream24(Stream);
   exit;
  end;
  RowSize:=((Width+7) div 8);
  RowsPerStrip:=((256*1024) div RowSize);
  if RowsPerStrip>Height then
    RowsPerStrip:=Height
  else if RowsPerStrip=0 then
    RowsPerStrip:=1;
  StripMemory:=GetMemory(RowsPerStrip*RowSize);
  OpenTiff:=TIFFOpenStream(Stream,'w');
  if OpenTiff=nil then
  begin
    FreeMemory(StripMemory);
    raise Exception.Create('Unable to create stream!');
  end;
  TIFFSetField(OpenTiff,TIFFTAG_IMAGEWIDTH,Width);
  TIFFSetField(OpenTiff,TIFFTAG_IMAGELENGTH,Height);
  TIFFSetField(OpenTiff,TIFFTAG_PHOTOMETRIC,PHOTOMETRIC_MINISWHITE);
  TIFFSetField(OpenTiff,TIFFTAG_SAMPLESPERPIXEL,1);
  TIFFSetField(OpenTiff,TIFFTAG_BITSPERSAMPLE,1);
  TIFFSetField(OpenTiff,TIFFTAG_PLANARCONFIG,PLANARCONFIG_CONTIG);
  TIFFSetField(OpenTiff,TIFFTAG_COMPRESSION,COMPRESSION_CCITTFAX4);
  TIFFSetField(OpenTiff,TIFFTAG_ROWSPERSTRIP,RowsPerStrip);
  StripIndex:=0;
  StripRowOffset:=0;
  while StripRowOffset<Height do
  begin
    StripRowCount:=RowsPerStrip;
    if StripRowCount>Height-StripRowOffset then
      StripRowCount:=Height-StripRowOffset;
    mb:=StripMemory;
    for ny:=StripRowOffset to StripRowOffset+StripRowCount-1 do
    begin
      CopyMemory(mb,ScanLine[ny],RowSize);
      Inc(mb,RowSize);
    end;
    if TIFFWriteEncodedStrip(OpenTiff,StripIndex,
        StripMemory,StripRowCount*RowSize)=-1 then
    begin
      TIFFClose(OpenTiff);
      FreeMemory(StripMemory);
      raise Exception.Create('Failed to write stream!');
    end;
    Inc(StripIndex);
    Inc(StripRowOffset,StripRowCount);
  end;
  TIFFClose(OpenTiff);
  FreeMem(StripMemory);
end;

procedure TTiffGraphic.SaveToStream24(Stream: TStream);
var
  OpenTiff: PTIFF;
  RowsPerStrip: Longword;
  StripMemory: Pointer;
  StripIndex: Longword;
  StripRowOffset: Longword;
  StripRowCount: Longword;
  ma,mb: PByte;
  nx,ny: Longword;
begin
  if (PixelFormat<>pf24bit) and
     (PixelFormat<>pf32bit) then PixelFormat:=pf24bit;

  if (PixelFormat<>pf24bit) and
     (PixelFormat<>pf32bit) then
    raise Exception.Create('WriteBitmapToTiff is designed for 24bit and 32bit bitmaps only');
  RowsPerStrip:=((256*1024) div (Width*3));
  if RowsPerStrip>Height then
    RowsPerStrip:=Height
  else if RowsPerStrip=0 then
    RowsPerStrip:=1;
  StripMemory:=GetMemory(RowsPerStrip*Width*3);
  OpenTiff:=TIFFOpenStream(Stream,'w');

  if OpenTiff=nil then
  begin
    FreeMemory(StripMemory);
    raise Exception.Create('Unable to create stream');
  end;
  TIFFSetField(OpenTiff,TIFFTAG_IMAGEWIDTH,Width);
  TIFFSetField(OpenTiff,TIFFTAG_IMAGELENGTH,Height);
  TIFFSetField(OpenTiff,TIFFTAG_PHOTOMETRIC,PHOTOMETRIC_RGB);
  TIFFSetField(OpenTiff,TIFFTAG_SAMPLESPERPIXEL,3);
  TIFFSetField(OpenTiff,TIFFTAG_BITSPERSAMPLE,8);
  TIFFSetField(OpenTiff,TIFFTAG_PLANARCONFIG,PLANARCONFIG_CONTIG);//
  TIFFSetField(OpenTiff,TIFFTAG_COMPRESSION,COMPRESSION_LZW);
  TIFFSetField(OpenTiff,TIFFTAG_PREDICTOR,2);
  TIFFSetField(OpenTiff,TIFFTAG_ROWSPERSTRIP,RowsPerStrip);
  StripIndex:=0;
  StripRowOffset:=0;
  while StripRowOffset<Height do
  begin
    StripRowCount:=RowsPerStrip;
    if StripRowCount>Height-StripRowOffset then
      StripRowCount:=Height-StripRowOffset;
    if PixelFormat=pf24bit then
    begin
      mb:=StripMemory;
      for ny:=StripRowOffset to StripRowOffset+StripRowCount-1 do
      begin
        ma:=ScanLine[ny];
        for nx:=0 to Width-1 do
        begin
          mb^:=PByte(Cardinal(ma)+2)^;
          Inc(mb);
          mb^:=PByte(Cardinal(ma)+1)^;
          Inc(mb);
          mb^:=PByte(Cardinal(ma)+0)^;
          Inc(mb);
          Inc(ma,3);
        end;
      end;
    end
    else
    begin
      mb:=StripMemory;
      for ny:=StripRowOffset to StripRowOffset+StripRowCount-1 do
      begin
        ma:=ScanLine[ny];
        for nx:=0 to Width-1 do
        begin
          mb^:=PByte(Cardinal(ma)+2)^;
          Inc(mb);
          mb^:=PByte(Cardinal(ma)+1)^;
          Inc(mb);
          mb^:=PByte(Cardinal(ma)+0)^;
          Inc(mb);
          Inc(ma,4);
        end;
      end;
    end;
    if TIFFWriteEncodedStrip(OpenTiff,StripIndex,
        StripMemory,StripRowCount*Width*3)=0 then
    begin
      TIFFClose(OpenTiff);
      FreeMemory(StripMemory);
      raise Exception.Create('Failed to write to stream!');
    end;
    Inc(StripIndex);
    Inc(StripRowOffset,StripRowCount);
  end;
  TIFFClose(OpenTiff);
  FreeMem(StripMemory);
end;

procedure TTiffGraphic.SetPage(const Value: Word);
begin
  fPage := Value;
end;

procedure TTiffGraphic.SetPages(const Value: Word);
begin
  FPages := Value;
end;

initialization


  TPicture.RegisterFileFormat('tiff', gesMacTIFF, TTIFFGraphic);
  TPicture.RegisterFileFormat('tif', gesPCTIF, TTIFFGraphic);
  TPicture.RegisterFileFormat('fax', gesGFIFax, TTIFFGraphic);

finalization
   TPicture.UnregisterGraphicClass(TTIFFGraphic);

end.
