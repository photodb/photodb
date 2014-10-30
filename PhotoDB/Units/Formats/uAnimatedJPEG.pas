unit uAnimatedJPEG;

interface

uses
  Generics.Collections,
  System.SysUtils,
  System.Classes,
  System.Math,
  Winapi.Windows,
  Vcl.Graphics,
  Vcl.Imaging.jpeg,

  Dmitry.Utils.System,

  CCR.Exif,
  CCR.Exif.StreamHelper,

  uMemory,
  uBitmapUtils,
  uJpegUtils,
  Dmitry.Graphics.Types;

type
  TAnimatedJPEG = class(TBitmap)
  private
    FImages: TList<TBitmap>;
    FIsRedCyan: Boolean;
    function GetCount: Integer;
    function GetImageByIndex(Index: Integer): TBitmap;
  protected
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure ResizeTo(Width, Height: Integer);
    procedure LoadRedCyanImage;
    property Count: Integer read GetCount;        
    property Images[Index: Integer]: TBitmap read GetImageByIndex;
    property IsRedCyan: Boolean read FIsRedCyan write FIsRedCyan;
  end;

const
  MPOHeader: array[0..3] of Byte = (Ord('M'), Ord('P'), Ord('F'), $00);
  LittleIndianHeader: array[0..3] of Byte = ($49, $49, $2A, $00);
  BigIndianHeader: array[0..3] of Byte = ($4D, $4D, $00, $2A);

const
  Tag_MPFVersion      = $B000;
  Tag_NumberOfImages  = $B001;
  Tag_MPEntry         = $B002;
  Tag_ImageUIDList    = $B003;
  Tag_TotalFrames     = $B004;

type
  TMPEntry = record
    IndividualImageAttributes: DWORD;
    IndividualImageSize: DWORD;
    IndividualImageDataOffset: DWORD;
    DependentImage1EntryNumber: WORD;
    DependentImage2EntryNumber: WORD;
    function IsDependentParentImage: Boolean;
    function IsDependentChildImage: Boolean;
    function IsRepresentativeImage: Boolean;
    function MPTypeCode: Integer;
  end;

type
  TMPOData = class
  private
    FIsvalid: Boolean;
    FEndianness: TEndianness;
    MMEntries: array of TMPEntry;
  public
    procedure ReadFromStream(S: TCustomMemoryStream; HeaderOffset: Int64);
    constructor Create;

    property Isvalid: Boolean read FIsvalid;
  end;

implementation

{ TAnimatedJPEG }

constructor TAnimatedJPEG.Create;
begin
  FImages := TList<TBitmap>.Create;
  FIsRedCyan := False;
end;

destructor TAnimatedJPEG.Destroy;
begin
  FreeList(FImages);
  inherited;
end;

function TAnimatedJPEG.GetCount: Integer;
begin
  Result := FImages.Count;
end;

function TAnimatedJPEG.GetImageByIndex(Index: Integer): TBitmap;
begin
  Result := FImages[Index];
end;

procedure TAnimatedJPEG.LoadFromStream(Stream: TStream);
var
  I: Integer;
  Pos: Int64;
  J: TJpegImage;
  B, BHalf: TBitmap;
  Exif: TExifData;
  M: TMPOData;

  procedure LoadImageFromImages;
  begin
    if FImages.Count > 0 then
    begin
      if not FIsRedCyan or (FImages.Count = 1) then
        Assign(FImages[0])
      else
        LoadRedCyanImage;
    end;
  end;

  procedure LoadJpegFromStream;
  begin
    J := TJpegImage.Create;
    try
      try
        J.LoadFromStream(Stream);

        B := TBitmap.Create;
        try
          AssignJpeg(B, J);
          FImages.Add(B);
          B := nil;
        finally
          F(B);
        end;
      except
        //failed to load image
        //don't throw any exceptions if this is not first image
        if FImages.Count = 0 then
          raise;
      end;
    finally
      F(J);
    end;
  end;

begin
  Pos := Stream.Position;

  FreeList(FImages, False);

  Exif := TExifData.Create;
  try
    Exif.LoadFromGraphic(Stream);


    if Exif.HasMPOExtension then
    begin
      M := TMPOData.Create;
      try
        M.ReadFromStream(Exif.MPOData.Data, Exif.MPOBlockOffset + 8);

        for I := 0 to Length(M.MMEntries) - 1 do
        begin
          //single representative image
          if M.MMEntries[I].IsRepresentativeImage and not M.MMEntries[I].IsDependentChildImage then
          begin
            Stream.Seek(M.MMEntries[I].IndividualImageDataOffset, TSeekOrigin.soBeginning);
            LoadJpegFromStream;
            LoadImageFromImages;

            Exit;
          end;
        end;

        //no representative image, load as animated
        for I := 0 to Length(M.MMEntries) - 1 do
        begin
          if not M.MMEntries[I].IsDependentChildImage then
          begin
            Stream.Seek(M.MMEntries[I].IndividualImageDataOffset, TSeekOrigin.soBeginning);
            LoadJpegFromStream;

            if FImages.Count = 2 then
              Break;
          end;
        end;
        LoadImageFromImages;

      finally
       F(M);
      end;
    end;
  finally
    F(Exif);
  end;

  Stream.Seek(Pos, TSeekOrigin.soBeginning);
  LoadJpegFromStream;
  if FImages.Count = 1 then
  begin
    B := FImages[0];
    BHalf := TBitmap.Create;
    try
      if B.Width > 2 then
      begin
        BHalf.PixelFormat := pf24Bit;
        BHalf.SetSize(B.Width div 2, B.Height);
        DrawImageExRect(BHalf, B, 0, 0, B.Width div 2, B.Height, 0, 0);
        FImages.Add(BHalf);
        
        BHalf := nil;
        BHalf := TBitmap.Create;
        
        BHalf.PixelFormat := pf24Bit;
        BHalf.SetSize(B.Width div 2, B.Height);
        DrawImageExRect(BHalf, B, B.Width div 2, 0, B.Width div 2, B.Height, 0, 0);
        FImages.Add(BHalf);

        FImages[0].Free;
        FImages.Delete(0);
        BHalf := nil;
      end;
    finally
      F(BHalf);
    end;
  end;
  LoadImageFromImages;
end;

procedure TAnimatedJPEG.LoadRedCyanImage;
var
  I, J, W, H: Integer;
  PS1, PS2, PD: PARGB;
  B: TBitmap;
begin
  if FImages.Count < 2 then
  begin
    Assign(FImages[0]);
    Exit;
  end;
  B := TBitmap.Create;
  try
    B.PixelFormat := pf24Bit;
    FImages[0].PixelFormat := pf24Bit;
    FImages[1].PixelFormat := pf24Bit;
    W := Min(FImages[0].Width, FImages[1].Width);
    H := Min(FImages[0].Height, FImages[1].Height);
    B.SetSize(W, H);

    for I := 0 to H - 1 do
    begin
      PS1 := FImages[0].ScanLine[I];
      PS2 := FImages[1].ScanLine[I];
      PD := B.ScanLine[I];
      for J := 0 to W - 1 do
      begin
        PD[J].R := PS1[J].R;
        PD[J].G := PS2[J].G;
        PD[J].B := PS2[J].B;
      end;
    end;
    Assign(B);
  finally
    F(B);
  end;
end;

procedure TAnimatedJPEG.ResizeTo(Width, Height: Integer);
var
  B, BI: TBitmap;
  I: Integer;
begin
  B := TBitmap.Create;
  try
    for I := 0 to Count - 1 do
    begin
      BI := FImages[I];
      uBitmapUtils.KeepProportions(B, 500, 500);
      FImages[I] := BI;
    end;
    if FIsRedCyan then
      LoadRedCyanImage
    else
    begin
      B.Assign(Self);
      uBitmapUtils.KeepProportions(B, 500, 500);
      Assign(B);
    end;
  finally
    F(B);
  end;
end;

{ TMPOData }

constructor TMPOData.Create;
begin
  FIsvalid := False;
  FEndianness := SmallEndian;
end;

//http://www.cipa.jp/english/hyoujunka/kikaku/pdf/DC-007_E.pdf
procedure TMPOData.ReadFromStream(S: TCustomMemoryStream; HeaderOffset: Int64);
var
  SourceHeader: array[0..3] of Byte;
  SourceByteOrder: array[0..3] of Byte;
  OffsetToFirstIFD: DWORD;
  Version: AnsiString;
  NumberOfImages: DWORD;
  OffsetOfNextIFD: DWORD;
  MPEntryDataSize: DWORD;
  MPEntryOffset: DWORD;
  TotalNumberOfcapturedImages: DWORD;

  I, J: Integer;
  TagId: WORD;
  TagCount: WORD;
  TagSize: WORD;
  DataSize: DWORD;
begin
  FIsvalid := False;

  Version := '';
  NumberOfImages := 0;
  SetLength(MMEntries, 0);
  if (S <> nil) then
  begin
    S.Seek(0, soFromBeginning);

    S.ReadBuffer(SourceHeader, SizeOf(SourceHeader));

    if CompareMem(@SourceHeader, @MPOHeader, SizeOf(MPOHeader)) then
      FIsvalid := True;

    if FIsvalid then
    begin
      S.ReadBuffer(SourceByteOrder, SizeOf(SourceByteOrder));

      if CompareMem(@SourceByteOrder, @BigIndianHeader, SizeOf(BigIndianHeader)) then
        FEndianness := BigEndian;

      S.ReadLongWord(FEndianness, OffsetToFirstIFD);
      OffsetOfNextIFD := S.Seek(OffsetToFirstIFD - 8, TSeekOrigin.soCurrent);

      if (OffsetOfNextIFD > 0) and (OffsetOfNextIFD < S.Size) then
      begin
        S.Seek(OffsetOfNextIFD, TSeekOrigin.soBeginning);
        S.ReadWord(FEndianness, TagCount);

        MPEntryDataSize := 0;
        MPEntryOffset := 0;

        for I := 1 to TagCount do
        begin
          S.ReadWord(FEndianness, TagId);
          S.ReadWord(FEndianness, TagSize);
          S.ReadLongWord(FEndianness, DataSize);

          if TagId = Tag_MPFVersion then
          begin
            SetLength(Version, 4);
            S.Read(Version[1], 4);
          end;

          if TagId = Tag_NumberOfImages then
            S.ReadLongWord(FEndianness, NumberOfImages);

          if TagId = Tag_TotalFrames then
            S.ReadLongWord(FEndianness, TotalNumberOfcapturedImages);

          if TagId = Tag_MPEntry then
          begin
            if DataSize / 16 = NumberOfImages then
            begin
              MPEntryDataSize := DataSize;
              S.ReadLongWord(FEndianness, MPEntryOffset);
              MPEntryOffset := MPEntryOffset + 4;
            end;
          end;
        end;

        S.ReadLongWord(FEndianness, OffsetOfNextIFD);
        if MPEntryDataSize > 0 then
        begin
          S.Seek(MPEntryOffset, TSeekOrigin.soBeginning);
          Setlength(MMEntries, NumberOfImages);
          for J := 0 to NumberOfImages - 1 do
          begin
            S.ReadLongWord(FEndianness, DWORD(MMEntries[J].IndividualImageAttributes));
            S.ReadLongWord(FEndianness, MMEntries[J].IndividualImageSize);
            S.ReadLongWord(FEndianness, MMEntries[J].IndividualImageDataOffset);
            if MMEntries[J].IndividualImageDataOffset > 0 then
              MMEntries[J].IndividualImageDataOffset := MMEntries[J].IndividualImageDataOffset + HeaderOffset;
            S.ReadWord(FEndianness, MMEntries[J].DependentImage1EntryNumber);
            S.ReadWord(FEndianness, MMEntries[J].DependentImage2EntryNumber);
          end;
        end;
      end;
    end;
  end;
end;


{ TMPEntry }

function TMPEntry.IsDependentChildImage: Boolean;
begin
  Result := (Self.IndividualImageAttributes and $40000000) > 0;
end;

function TMPEntry.IsDependentParentImage: Boolean;
begin
  Result := (Self.IndividualImageAttributes and $80000000) > 0;
end;

function TMPEntry.IsRepresentativeImage: Boolean;
begin
  Result := (Self.IndividualImageAttributes and $20000000) > 0;
end;

function TMPEntry.MPTypeCode: Integer;
begin
  Result := Self.IndividualImageAttributes and $FFFFFF;
end;

end.
