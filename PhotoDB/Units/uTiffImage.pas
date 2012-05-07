unit uTiffImage;

interface

uses
  Classes,
  SysUtils,
  Graphics,
  FreeImage,
  FreeBitmap,
  GraphicsBaseTypes,
  uMemory;

type
  TTiffImage = class(TBitmap)
  private
    { Private declarations }
    FPage: Word;
    FPages: Word;
    FImage: PFIMULTIBITMAP;
    procedure ClearImage;
    procedure LoadFromFreeImage(Bitmap: PFIBITMAP);
  public
    { Public declarations }
    procedure LoadFromStreamEx(Stream: TStream; Page: Integer);
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    function GetPagesCount(Stream: TStream): Integer;
    constructor Create; override;
    destructor Destroy; override;
  published
    property Page: Word read FPage write FPage;
    property Pages: Word read FPages;
  end;

implementation

function StreamFI_ReadProc(buffer: Pointer; size, count: Cardinal;
  handle: fi_handle): Cardinal; stdcall;
begin
  Result := Cardinal(TStream(handle).Read(buffer^, size * count));
end;

function StreamFI_WriteProc(buffer: Pointer; size, count: Cardinal;
  handle: fi_handle): Cardinal; stdcall;
begin
  Result := TStream(handle).Write(buffer^, size * count);
end;

function StreamFI_SeekProc(handle: fi_handle; offset: LongInt;
  origin: Integer): Integer; stdcall;
begin
  Result := TStream(handle).Seek(offset, origin);
end;

function StreamFI_TellProc(handle: fi_handle): LongInt; stdcall;
begin
  Result := TStream(handle).Position;
end;

{ TTiffImage }

procedure TTiffImage.ClearImage;
begin
  if FImage <> nil then
    FreeImage_CloseMultiBitmap(FImage);
end;

constructor TTiffImage.Create;
begin
  inherited;
  FreeImageInit;
  FPages := 1;
  FPage := 0;
  FImage := nil;
  ClearImage;
end;

destructor TTiffImage.Destroy;
begin
  ClearImage;
  inherited;
end;

function TTiffImage.GetPagesCount(Stream: TStream): Integer;
begin
  LoadFromStreamEx(Stream, -1);
  Result := Pages;
end;

procedure TTiffImage.LoadFromFreeImage(Bitmap: PFIBITMAP);
var
  I, J: Integer;
  PS, PD: PARGB;
  W, H: Integer;
begin
  PixelFormat := pf24Bit;
  W := FreeImage_GetWidth(Bitmap);
  H := FreeImage_GetHeight(Bitmap);
  Width := W;
  Height := H;

  for I := 0 to H - 1 do
  begin
    PS := PARGB(FreeImage_GetScanLine(Bitmap, H - I - 1));
    PD := ScanLine[I];
    for J := 0 to W - 1 do
      PD[J] := PS[J];
  end;
end;

procedure TTiffImage.LoadFromStream(Stream: TStream);
begin
  LoadFromStreamEx(Stream, Page);
end;

procedure TTiffImage.LoadFromStreamEx(Stream: TStream; Page: Integer);
var
  IO: FreeImageIO;
  Bitmap, Bitmap24: PFIBITMAP;
  Fif: FREE_IMAGE_FORMAT;
  M: TMemoryStream;
  FHMem: PFIMEMORY;
begin

  if Page > -1 then
    ClearImage;

  IO.read_proc := StreamFI_ReadProc;
  IO.write_proc := StreamFI_WriteProc;
  IO.seek_proc := StreamFI_SeekProc;
  IO.tell_proc := StreamFI_TellProc;

  FPage := Page;

  FIF := FreeImage_GetFileTypeFromHandle(@IO, Stream);

  M := TMemoryStream.Create;
  try
    M.CopyFrom(Stream, Stream.Size);
    M.Seek(0, soFromBeginning);

    FHMem := FreeImage_OpenMemory(M.Memory, M.Size);
    try
      FImage := FreeImage_LoadMultiBitmapFromMemory(FIF, FHMem, 0);

      FPages := FreeImage_GetPageCount(FImage);

      if Page > -1 then
      begin
        Bitmap := FreeImage_LockPage(FImage, FPage);

        if Bitmap = nil then
          raise Exception.Create('Can''t load tiff image!');

        try
          Bitmap24 := FreeImage_ConvertTo24Bits(Bitmap);

          if Bitmap24 = nil then
            raise Exception.Create('Can''t convert image to 24 bit!');

          try
            LoadFromFreeImage(Bitmap24);
          finally
            FreeImage_Unload(Bitmap24);
          end;

        finally
          FreeImage_UnlockPage(FImage, Bitmap, False);
        end;
      end;
    finally
      FreeImage_CloseMemory(FHMem);
    end;
  finally
    F(M);
  end;

end;

procedure TTiffImage.SaveToStream(Stream: TStream);
var
  Bitmap, Bitmap24: PFIBITMAP;
  M: TMemoryStream;
  MemIO: TFreeMemoryIO;
  Data: PByte;
  Size: Cardinal;
  FHMem: PFIMEMORY;

  procedure SaveFreeImageDib(B: PFIBITMAP);
  begin
    Bitmap24 := FreeImage_ConvertTo24Bits(B);
    try
      try
        if MemIO.Write(FIF_TIFF, Bitmap24, TIFF_LZW) then
        begin
          MemIO.Acquire(Data, Size);
          Stream.WriteBuffer(Data^, Size);
        end;
      finally
        F(M);
      end;
    finally
      FreeImage_Unload(Bitmap24);
    end;
  end;

begin
  MemIO := TFreeMemoryIO.Create;
  try
    if FImage = nil then
    begin
      //if FreeImage is null we save image from bitmap
      M := TMemoryStream.Create;
      try
        inherited SaveToStream(M);
        M.Seek(0, soFromBeginning);

        FHMem := FreeImage_OpenMemory(M.Memory, M.Size);
        try
          Bitmap := FreeImage_LoadFromMemory(FIF_BMP, FHMem);
          try
            SaveFreeImageDib(Bitmap);
          finally
            FreeImage_Unload(Bitmap);
          end;
        finally
          FreeImage_CloseMemory(FHMem);
        end;

        Exit;
      finally
        F(M);
      end;
    end;
    Bitmap := FreeImage_LockPage(FImage, FPage);
    try
      SaveFreeImageDib(Bitmap);
    finally
      FreeImage_UnlockPage(FImage, Bitmap, False);
    end;
  finally
    F(MemIO);
  end;
end;

end.
