unit uStenography;

interface

uses
  Math,
  Classes,
  SysUtils,
  Windows,
  Graphics,
  Jpeg,

  Dmitry.CRC32,
  Dmitry.Graphics.Types,

  uMemory,
  uStrongCrypt,
  DECUtil,
  DECCipher;

const
  MaxSizeWidthHeight = 32768;
  StenoHeaderId = 'PHST';
  StenoHeaderIdLength = SizeOf(StenoHeaderId);

type
  StenographyHeader = record
    ID: string[StenoHeaderIdLength];
    Version : Byte;
    FileSize : Integer;
    Seed: TSeed;
    FileName: TFileNameUnicode;
    IsCrypted: Boolean;
    PassCRC: Cardinal;
    Chiper : Cardinal;
    DataCRC: Cardinal;
  end;

// BeginImage преобразовываетс€ в Tbitmap с учЄтом информации Info с €чейкой размером Cell
function SaveInfoToBmpFile(BeginImage: TGraphic; ResultImage : TBitmap; Info: TStream; Cell: Integer): Boolean;
// достаЄм информацию из Bitmap
function ExtractInfoFromBitmap(Dest: TStream; Bitmap: TBitmap) : Boolean;
// Save file to stream, optional crypting
procedure SaveFileToCryptedStream(FileName: string; Password: string; Dest : TStream; HeaderInTheEnd: Boolean);
// максимально возможное количество информации, которое можо записать в Graphic с €чейкой размером Cell
function MaxSizeInfoInGraphic(Graphic: TGraphic; Cell: Integer): Integer;
// выдаЄт размер Cell, наиболее оптимальный если сохран€ть в Graphic информацию о файле FileName
function GetMaxPixelsInSquare(FileName: string; Graphic: TGraphic): Integer;
function GetFileSizeByName(FileName: string): Integer;

//JPEG-steno
function CreateJPEGSteno(DataFileName, DestFileName: string; SourceJpegImage: string; Password: string): Boolean;
function CreateJPEGStenoEx(DataFileName, DestFileName: string; SourceJpegImage: TStream; Password: string): Boolean;
function IsValidJPEGSteno(FileName: string): Boolean;
function ExtractJPEGSteno(MS, Dest: TStream; out Header: StenographyHeader): Boolean;

implementation

function GetFileSizeByName(FileName: string): Integer;
var
  FindData: TWin32FindData;
  HFind: THandle;
begin
  Result := -1;
  HFind := FindFirstFile(PChar(FileName), FindData);
  if HFind <> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(HFind);
    if (FindData.DwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
      Result := FindData.NFileSizeLow;
  end;
end;

procedure SetPixel(P: PRGB; var C: Integer); inline;

  procedure SetByte(var B: Byte; var C: Integer); inline;
  begin
    if C > 0 then
    begin
      if B < $FF then
      begin
        B := B + 1;
        C := C - 1;
      end;
    end
    else if C < 0 then
    begin
      if B > $0 then
      begin
        B := B - 1;
        C := C + 1;
      end;
    end;
  end;

begin
  SetByte(P.R, C);
  SetByte(P.G, C);
  SetByte(P.B, C);
end;

function SaveInfoToBmpFile(BeginImage: TGraphic; ResultImage : TBitmap; Info: TStream; Cell: Integer): Boolean;
var
  XP: array of PARGB;
  S, I, J, K, L, C, N, Size: Integer;
  Bsize: array [1 .. 5] of Byte;
  InfoByte : Byte;
begin
  Randomize;
  Result := False;
  if Cell > 23 then
    Exit;
  if Cell < 2 then
    Exit;
  if BeginImage is TIcon then
  begin
    ResultImage.SetSize(BeginImage.Width, BeginImage.Height);
    ResultImage.Canvas.Draw(0, 0, BeginImage);
  end else
    ResultImage.Assign(BeginImage);

  ResultImage.PixelFormat := pf24bit;
  SetLength(XP, ResultImage.Height);
  for I := 0 to ResultImage.Height - 1 do
    XP[I] := ResultImage.ScanLine[I];

  //using no more than 2Gb
  Size := Integer(Info.Size);
  Bsize[1] := Cell;
  Bsize[2] := Size and $FF;
  Bsize[3] := (Size shr 8) and $FF;
  Bsize[4] := (Size shr 16) and $FF;
  Bsize[5] := (Size shr 24) and $FF;

  N := 0;
  S := XP[0, 0].R + XP[0, 0].G + XP[0, 0].B;
  C := Cell - S mod 24;
  if S + C > 254 * 3 then
    C := C - 24;
  if S + C < 0 then
    C := C + 24;

  repeat
    SetPixel(@XP[0, 0], C);
  until C = 0;

  Info.Seek(0, soFromBeginning);
  for I := 0 to (ResultImage.Height - 1) div Cell - 1 do
    for J := 0 to (ResultImage.Width - 1) div Cell - 1 do
    begin
      C := 0;
      Inc(N);
      if I * ((ResultImage.Height - 1) div Cell - 1) + J = 5 then
        N := 0;
      for K := I * Cell to (I + 1) * Cell - 1 do
        for L := J * Cell to (J + 1) * Cell - 1 do
          if K + L <> 0 then
          begin
            Inc(C, XP[K, L].R);
            Inc(C, XP[K, L].G);
            Inc(C, XP[K, L].B);
          end;
      S := C;

      if I * ((ResultImage.Height - 1) div Cell - 1) + J > 4 then
      begin
        if N > Size then
        begin
          // break;
          // continue with random
          C := Random(256) - C mod 256;
        end  else
        begin
          Info.Read(InfoByte, SizeOf(InfoByte));
          C := InfoByte - C mod 256;
        end;
        if I + J = 0 then
          if S + C > (Cell * Cell - 1) * 255 * 3 then
            C := C - 256;
        if I + J <> 0 then
          if S + C > (Cell * Cell) * 255 * 3 then
            C := C - 256;
        if S + C < 0 then
          C := C + 256;
      end else
      begin
        C := Bsize[N] - C mod 256;
        if I + J = 0 then
          if S + C > (Cell * Cell - 1) * 255 * 3 then
            C := C - 256;
        if I + J <> 0 then
          if S + C > (Cell * Cell) * 255 * 3 then
            C := C - 256;
        if S + C < 0 then
          C := C + 256;
      end;
      repeat
        for K := I * Cell to (I + 1) * Cell - 1 do
          for L := J * Cell to (J + 1) * Cell - 1 do
            if K + L <> 0 then
              SetPixel(@XP[K, L], C);
      until C = 0;
      for K := I * Cell to (I + 1) * Cell - 1 do
        for L := J * Cell to (J + 1) * Cell - 1 do
          if K + L <> 0 then
          begin
            Inc(C, XP[K, L].R);
            Inc(C, XP[K, L].G);
            Inc(C, XP[K, L].B);
          end;
    end;

  Result := True;
end;

function ExtractInfoFromBitmap(Dest: TStream; Bitmap: TBitmap): Boolean;
var
  I, J, C, K, L, N, Cell: Integer;
  Size: Int64;
  XP: array of PARGB;
  Bsize: array [1 .. 5] of Byte;
  InfoByte : Byte;
begin
  Size := 0;
  Result := False;
  Bitmap.PixelFormat := pf24bit;
  SetLength(XP, Bitmap.Height);
  for I := 0 to Bitmap.Height - 1 do
    XP[I] := Bitmap.ScanLine[I];
  N := 0;
  Bsize[1] := (XP[0, 0].R + XP[0, 0].G + XP[0, 0].B) mod 24;
  Cell := Bsize[1];
  Cell := Max(Cell, 0);
  Cell := Min(Cell, 24);
  if Cell = 0 then
    Exit(False);

  for I := 0 to (Bitmap.Height - 1) div Cell - 1 do
    for J := 0 to (Bitmap.Width - 1) div Cell - 1 do
    begin
      C := 0;
      Inc(N);
      for K := I * Cell to (I + 1) * Cell - 1 do
        for L := J * Cell to (J + 1) * Cell - 1 do
          if K + L <> 0 then
          begin
            if (K > (Bitmap.Height - 1)) or (L > (Bitmap.Width - 1)) then
            begin
              Bsize[1] := Bsize[1] + 1;
            end;
            C := C + XP[K, L].R;
            C := C + XP[K, L].G;
            C := C + XP[K, L].B;
          end;
      if I * ((Bitmap.Height - 1) div Cell - 1) + J > 4 then
      begin
        if N > Size then
        begin
          Result := True;
          Exit;
        end;

        InfoByte := C and $FF;
        Dest.Write(InfoByte, SizeOf(InfoByte));
      end else
        Bsize[N] := C mod 256;

      if I * ((Bitmap.Height - 1) div Cell - 1) + J = 4 then
      begin
        Size := Bsize[2] + Bsize[3] * 256 + Bsize[4] * 256 * 256 + Bsize[5] * 256 * 256 * 256;
        if (Size <= 0) or (Size > MaxSizeInfoInGraphic(Bitmap, 2)) then
        begin
          Result := False;
          Exit;
        end;
        N := 0;
      end;
    end;
end;

function MaxSizeInfoInGraphic(Graphic: TGraphic; Cell: Integer): Integer;
begin
  Result := ((Graphic.Height - 1) div Cell) * ((Graphic.Width - 1) div Cell) - SizeOf(StenographyHeader);
  Result := Max(0, Result);
end;

procedure SaveFileToCryptedStream(FileName: string; Password: string; Dest: TStream; HeaderInTheEnd: Boolean);
var
  FS: TFileStream;
  I: Integer;
  Header: StenographyHeader;
  MS : TMemoryStream;
  Seed : Binary;
  Chiper : TDECCipherClass;
begin
  try
    FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  except
    Exit;
  end;
  try
    MS := TMemoryStream.Create;
    try
      MS.CopyFrom(FS, FS.Size);

      //creating header
      FillChar(Header, SizeOf(Header), 0);
      Header.ID := StenoHeaderId;
      Header.Version := 1;
      FileName := ExtractFileName(FileName);
      for I := 0 to SizeOf(Header.FileName) div SizeOf(Header.FileName[0]) - 1 do
        Header.FileName[I] := #0;

      for I := 0 to Min(SizeOf(Header.FileName) div SizeOf(Header.FileName[0]) - 1, Length(FileName) - 1) do
        Header.FileName[I] := FileName[I + 1];

      CalcBufferCRC32(TMemoryStream(MS).Memory, MS.Size, Header.DataCRC);
      Header.FileSize := Integer(MS.Size);
      Header.IsCrypted := Length(Password) > 0;
      if not Header.IsCrypted then
        Header.PassCRC := 0
      else
        CalcStringCRC32(Password, Header.PassCRC);
      Chiper := ValidCipher(nil);
      Header.Chiper := Chiper.Identity;
      Seed := RandomBinary(16);
      Header.Seed := ConvertSeed(Seed);

      if not HeaderInTheEnd then
        Dest.Write(Header, SizeOf(Header));

      //Saving data
      MS.Seek(0, soFromBeginning);
      if not Header.IsCrypted then
        Dest.CopyFrom(MS, MS.Size)
      else
      begin
        StrongCryptInit;
        CryptStreamV2(MS, Dest, Password, Seed);
      end;

      if HeaderInTheEnd then
        Dest.Write(Header, SizeOf(Header));
    finally
      F(MS);
    end;
  finally
    F(FS);
  end;
end;

function GetMaxPixelsInSquare(FileName: string; Graphic: TGraphic): Integer;
var
  I, FileSize: Integer;
begin
  FileSize := GetFileSizeByName(FileName) + 255;
  Result := -1;
  for I := 23 downto 2 do
  begin
    if MaxSizeInfoInGraphic(Graphic, I) >= FileSize then
    begin
      Result := I;
      Break;
    end;
  end;
  if Result < 2 then
    Result := -1;
end;

function CreateJPEGSteno(DataFileName, DestFileName: string; SourceJpegImage: string; Password: string): Boolean;
var
  SS: TFileStream;
begin
  SS := TFileStream.Create(SourceJpegImage, fmOpenRead or fmShareDenyNone);
  try
    Result := CreateJPEGStenoEx(DataFileName, DestFileName, SS, Password);
  finally
    F(SS);
  end;
end;

function CreateJPEGStenoEx(DataFileName, DestFileName: string; SourceJpegImage: TStream; Password: string): Boolean;
var
  DS: TFileStream;
begin
  DS := TFileStream.Create(DestFileName, fmCreate);
  try
    DS.CopyFrom(SourceJpegImage, SourceJpegImage.Size);
    SaveFileToCryptedStream(DataFileName, Password, DS, True);
    Result := True;
  finally
    F(DS);
  end;
end;

function IsValidJPEGSteno(FileName: string): Boolean;
var
  FS: TFileStream;
  Header: StenographyHeader;
begin
  Result := False;
  FS := TFileStream.Create(FileName, fmOpenRead, fmShareDenyWrite);
  try
    if FS.Size > SizeOf(Header) then
    begin
      FS.Seek(SizeOf(Header), soFromEnd);
      FS.Read(Header, SizeOf(Header));
      Result := Header.ID = StenoHeaderId;
    end;
  finally
    F(FS);
  end;
end;

function ExtractJPEGSteno(MS, Dest: TStream; out Header: StenographyHeader): Boolean;
begin
  Result := False;
  if MS.Size > SizeOf(Header) then
  begin
    MS.Seek(-SizeOf(Header), soFromEnd);
    MS.Read(Header, SizeOf(Header));
    if Header.ID = StenoHeaderId then
    begin
      //valid jpeg steno
      MS.Seek(-(SizeOf(Header) + Header.FileSize), soFromEnd);
      Dest.CopyFrom(MS, Header.FileSize);
      Result := True;
    end;
  end;
end;

end.
