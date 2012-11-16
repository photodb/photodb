unit UnitPrinterTypes;

interface

uses
  Windows,
  SysUtils,
  Math,
  Graphics,
  Printers,
  Classes,
  ComObj,
  uLogger,
  UnitDBKernel,
  GraphicCrypt,
  Dmitry.Graphics.Types,
  ActiveX,
  uMemory,
  uAssociations,
  uBitmapUtils,
  uPortableDeviceUtils,
  UnitDBDeclare,
  uImageLoader;

type
  TCallBackPrinterGeneratePreviewProc = procedure(Progress: Byte; var Terminate: Boolean) of object;

  TPaperSize = (TPS_A4, TPS_B5, TPS_CAN13X18, TPS_CAN10X15, TPS_CAN9X13, TPS_OTHER);

  TPrintSampleSizeOne = (TPSS_FullSize, TPSS_C35, TPSS_20X25C1, TPSS_13X18C2, TPSS_13X18C1, TPSS_10X15C1, TPSS_10X15C2,
    TPSS_10X15C3, TPSS_9X13C1, TPSS_9X13C4, TPSS_9X13C2, TPSS_C9, TPSS_CUSTOM, TPSS_3X4C6, TPSS_4X6C4);

  TPrintSampleSize = set of TPrintSampleSizeOne;

  TGenerateImageOptions = record
    VirtualImage: Boolean;
    Image: TBitmap;
    CropImages: Boolean;
    FreeCenterSize: Boolean;
    FreeWidthPx: Integer;
    FreeHeightPx: Integer;
  end;

type
  TMargins = record
    Left, Top, Right, Bottom: Double;
  end;

type
  TXSize = record
    Width, Height: Extended;
  end;

function GetCID: string;
function GenerateImage(FullImage: Boolean; Width, Height: Integer; SampleImage: TBitmap; Files: TStrings;
  SampleImageType: TPrintSampleSizeOne; Options: TGenerateImageOptions;
  CallBack: TCallBackPrinterGeneratePreviewProc = nil): TBitmap;
function GetPixelsPerInch: TXSize;
function InchToCm(Pixel: Single): Single;
function CmToInch(Pixel: Single): Single;
function GetPaperSize: TPaperSize;
function MmToPix(Size: TXSize): TXSize;
function XSize(Width, Height: Extended): TXSize;
function PixToSm(Size: TXSize): TXSize;
function PixToIn(Size: TXSize): TXSize;

implementation

function XSize(Width, Height: Extended): TXSize;
begin
  Result.Width := Width;
  Result.Height := Height;
end;

function MmToPix(Size: TXSize): TXSize;
var
  Inch, PixelsPerInch: TXSize;
begin
  PixelsPerInch := GetPixelsPerInch;
  Inch.Width := CmToInch(Size.Width / 10);
  Inch.Height := CmToInch(Size.Height / 10);
  Result.Width := Inch.Width * PixelsPerInch.Width;
  Result.Height := Inch.Height * PixelsPerInch.Height;
end;

function PixToSm(Size: TXSize): TXSize;
var
  Inch, PixelsPerInch: TXSize;
begin
  PixelsPerInch := GetPixelsPerInch;
  Inch.Width := Size.Width / PixelsPerInch.Width;
  Inch.Height := Size.Height / PixelsPerInch.Height;
  Result.Width := InchToCm(Inch.Width);
  Result.Height := InchToCm(Inch.Height);
end;

function PixToIn(Size: TXSize): TXSize;
var
  PixelsPerInch: TXSize;
begin
  PixelsPerInch := GetPixelsPerInch;
  Result.Width := Size.Width / PixelsPerInch.Width;
  Result.Height := Size.Height / PixelsPerInch.Height;
end;

function GetCID: string;
var
  CID: TGUID;
begin
  CoCreateGuid(CID);
  Result := GUIDToString(CID);
end;

procedure CropImageOfHeight(CroppedHeight: Integer; var Bitmap: TBitmap);
var
  I, J, Dy: Integer;
  Xp: array of PARGB;
begin
  Bitmap.PixelFormat := Pf24bit;
  SetLength(Xp, Bitmap.Height);
  if Bitmap.Height * Bitmap.Width = 0 then
    Exit;
  if CroppedHeight = Bitmap.Height then
    Exit;
  for I := 0 to Bitmap.Height - 1 do
    Xp[I] := Bitmap.ScanLine[I];
  Dy := Bitmap.Height div 2 - CroppedHeight div 2;
  for I := 0 to CroppedHeight - 1 do
    for J := 0 to Bitmap.Width - 1 do
    begin
      Xp[I, J] := Xp[I + Dy, J];
    end;
  Bitmap.Height := CroppedHeight;
end;

procedure CropImageOfWidth(CroppedWidth: Integer; var Bitmap: TBitmap);
var
  I, J, Dx: Integer;
  Xp: array of PARGB;
begin
  Bitmap.PixelFormat := Pf24bit;
  SetLength(Xp, Bitmap.Height);
  if Bitmap.Height * Bitmap.Width = 0 then
    Exit;
  if CroppedWidth = Bitmap.Width then
    Exit;
  for I := 0 to Bitmap.Height - 1 do
    Xp[I] := Bitmap.ScanLine[I];
  Dx := Bitmap.Width div 2 - CroppedWidth div 2;
  for I := 0 to Bitmap.Height - 1 do
    for J := 0 to CroppedWidth do
    begin
      Xp[I, J] := Xp[I, J + Dx];
    end;
  Bitmap.Width := CroppedWidth;
end;

procedure CropImage(AWidth, AHeight: Integer; var Bitmap: TBitmap);
var
  Temp: Integer;
begin
  if AHeight = 0 then
    Exit;
  if (((AWidth / AHeight) > 1) and ((Bitmap.Width / Bitmap.Height) < 1)) or
    (((AWidth / AHeight) < 1) and ((Bitmap.Width / Bitmap.Height) > 1)) then
  begin
    Temp := AWidth;
    AWidth := AHeight;
    AHeight := Temp;
  end;
  if Bitmap.Width / Bitmap.Height < AWidth / AHeight then
    CropImageOfHeight(Round(Bitmap.Width * (AHeight / AWidth)), Bitmap)
  else
    CropImageOfWidth(Round(Bitmap.Height * (AWidth / AHeight)), Bitmap);

end;

procedure ProportionalSize(aWidth, aHeight: Integer; var aWidthToSize, aHeightToSize: Integer);
begin
  if AWidthToSize * AWidth = 0 then
    Exit;
  if (AWidthToSize = 0) or (AHeightToSize = 0) then
  begin
    AHeightToSize := 0;
    AWidthToSize := 0;
  end else
  begin
    if (AHeightToSize / AWidthToSize) < (AHeight / AWidth) then
    begin
      AHeightToSize := Round((AWidth / AWidthToSize) * AHeightToSize);
      AWidthToSize := AWidth;
    end else
    begin
      AWidthToSize := Round((AHeight / AHeightToSize) * AWidthToSize);
      AHeightToSize := AHeight;
    end;
  end;
end;

procedure GetPrinterMargins(var Margins: TMargins);
var
  PixelsPerInch: TPoint;
  PhysPageSize: TPoint;
  OffsetStart: TPoint;
  PageRes: TPoint;
begin
  PixelsPerInch.y := GetDeviceCaps(Printer.Handle, LOGPIXELSY);
  PixelsPerInch.x := GetDeviceCaps(Printer.Handle, LOGPIXELSX);
  Escape(Printer.Handle, GETPHYSPAGESIZE, 0, nil, @PhysPageSize);
  Escape(Printer.Handle, GETPRINTINGOFFSET, 0, nil, @OffsetStart);
  PageRes.y := GetDeviceCaps(Printer.Handle, VERTRES);
  PageRes.x := GetDeviceCaps(Printer.Handle, HORZRES);
  // Top Margin
  Margins.Top := OffsetStart.y / PixelsPerInch.y;
  // Left Margin
  Margins.Left := OffsetStart.x / PixelsPerInch.x;
  // Bottom Margin
  Margins.Bottom := ((PhysPageSize.y - PageRes.y) / PixelsPerInch.y) -
    (OffsetStart.y / PixelsPerInch.y);
  // Right Margin
  Margins.Right := ((PhysPageSize.x - PageRes.x) / PixelsPerInch.x) -
    (OffsetStart.x / PixelsPerInch.x);
end;

function InchToCm(Pixel: Single): Single;
// Convert inch to Centimeter
begin
  Result := Pixel * 2.54
end;

function CmToInch(Pixel: Single): Single;
// Convert Centimeter to inch
begin
  Result := Pixel / 2.54
end;

function GetPixelsPerInch : TXSize;
begin
  Result.Height := GetDeviceCaps(Printer.Handle, LOGPIXELSY);
  Result.Width := GetDeviceCaps(Printer.Handle, LOGPIXELSX);
end;

function SizeIn(X, A, B: Extended): Boolean;
begin
  Result := ((X > A) and (X < B));
end;

function GetPaperSize: TPaperSize;
var
  PixInInch, PageSizeMm: TXSize;
begin
  PixInInch := GetPixelsPerInch;
  PageSizeMm.Width := InchToCm(Printer.PageWidth * 10 / PixInInch.Width);
  PageSizeMm.Height := InchToCm(Printer.PageHeight * 10 / PixInInch.Height);
  if SizeIn(PageSizeMm.Width, 200, 220) and SizeIn(PageSizeMm.Height, 270, 300) then
  begin
    Result := TPS_A4;
    Exit;
  end;
  if SizeIn(PageSizeMm.Width, 170, 182) and SizeIn(PageSizeMm.Height, 235, 260) then
  begin
    Result := TPS_B5;
    Exit;
  end;
  if (Min(PageSizeMm.Width, PageSizeMm.Height) >= 130) and (Max(PageSizeMm.Width, PageSizeMm.Height) >= 180) then
  begin
    Result := TPS_CAN13X18;
    Exit;
  end;
  if (Min(PageSizeMm.Width, PageSizeMm.Height) >= 100) and (Max(PageSizeMm.Width, PageSizeMm.Height) >= 150) then
  begin
    Result := TPS_CAN10X15;
    Exit;
  end;
  if (Min(PageSizeMm.Width, PageSizeMm.Height) >= 90) and (Max(PageSizeMm.Width, PageSizeMm.Height) > 130) then
  begin
    Result := TPS_CAN9X13;
    Exit;
  end;
  Result := TPS_OTHER;
end;

procedure Rotate90A(var Im: TBitmap);
var
  I, J: Integer;
  P1: PARGB;
  P: array of PARGB;
  Image: TBitmap;
begin
  Im.PixelFormat := Pf24bit;

  Image := Tbitmap.Create;
  try
    Image.PixelFormat := pf24bit;
    Image.Assign(Im);
    Im.Width := Image.Height;
    Im.Height := Image.Width;
    Setlength(P, Image.Width);
    for I := 0 to Image.Width - 1 do
      P[I] := Im.ScanLine[I];
    for I := 0 to Image.Height - 1 do
    begin
      P1 := Image.ScanLine[Image.Height - I - 1];
      for J := 0 to Image.Width - 1 do
        P[J, I] := P1[J];
    end;
  finally
    F(Image);
  end;
end;

function LoadPicture(var Graphic: TGraphic; FileName: string; out ImageInfo: ILoadImageInfo): Boolean;
var
  Info: TDBPopupMenuInfoRecord;
begin
  Result := False;
  Graphic := nil;

  try
    Info := TDBPopupMenuInfoRecord.CreateFromFile(FileName);
    try
      if LoadImageFromPath(Info, -1, '', [ilfGraphic, ilfICCProfile, ilfEXIF, ilfPassword], ImageInfo) then
        Graphic := ImageInfo.ExtractGraphic;

      Result := (Graphic <> nil) and not Graphic.Empty;
    finally
      F(Info);
    end;
  except
    on e: Exception do
      EventLog(e.Message);
  end;
end;

procedure PrintFullSize(Result: TBitmap; SampleBitmap: TBitmap; Files: TStrings; FullImage: Boolean;
  Options: TGenerateImageOptions; CallBack: TCallBackPrinterGeneratePreviewProc;
  var Terminating: Boolean);
var
  Graphic: TGraphic;
  SampleImage: TBitmap;
  AWidth, AHeight: Integer;
  ImageInfo: ILoadImageInfo;
begin
  SampleImage := TBitmap.Create;
  try
    SampleImage.PixelFormat := pf24bit;
    if FullImage then
    begin
      if not Options.VirtualImage then
      begin
        LoadPicture(Graphic, Files[0], ImageInfo);
        try
          if Assigned(CallBack) then
            CallBack(Round(100 * (1 / 5)), Terminating);
          if Terminating then
            Exit;
          SampleImage.Assign(Graphic);
          SampleImage.PixelFormat := pf24bit;
          ImageInfo.AppllyICCProfile(SampleImage);
        finally
          F(Graphic);
        end;

      end else
        SampleImage.Assign(Options.Image);
    end else
      SampleImage.Assign(SampleBitmap);
    if Assigned(CallBack) then
      CallBack(Round(100 * (2 / 5)), Terminating);
    if Terminating then
      Exit;

    if ((Result.Width / Result.Height) > 1) and ((SampleImage.Width / SampleImage.Height) < 1) or
      ((Result.Width / Result.Height) < 1) and ((SampleImage.Width / SampleImage.Height) > 1) then
      Rotate90A(SampleImage);

    if Assigned(CallBack) then
      CallBack(Round(100 * (3 / 5)), Terminating);
    if Terminating then
      Exit;

    AWidth := SampleImage.Width - 2;
    AHeight := SampleImage.Height - 2;
    ProportionalSize(Result.Width - 2, Result.Height - 2, AWidth, AHeight);
    if AWidth / SampleImage.Width < 1 then
      StretchCool(Result.Width div 2 - AWidth div 2, Result.Height div 2 - AHeight div 2, AWidth, AHeight, SampleImage,
        Result)
    else
      Interpolate(Result.Width div 2 - AWidth div 2, Result.Height div 2 - AHeight div 2, AWidth, AHeight,
        Rect(0, 0, SampleImage.Width, SampleImage.Height), SampleImage, Result);
    if Assigned(CallBack) then
      CallBack(Round(100 * (4 / 4)), Terminating);

  finally
    F(SampleImage);
  end;
end;

procedure PrintCenterImageSize(Result: TBitmap; SampleBitmap: TBitmap;
  Files: TStrings; FullImage: Boolean; ImWidth, ImHeight: Integer;
  Options: TGenerateImageOptions; CallBack: TCallBackPrinterGeneratePreviewProc;
  var Terminating: Boolean);
var
  Graphic: TGraphic;
  SampleImage: TBitmap;
  Size, PrSize: TXSize;
  AWidth, AHeight: Integer;
  ImageInfo: ILoadImageInfo;
begin
  SampleImage := TBitmap.Create;
  SampleImage.PixelFormat := pf24bit;
  try
    if FullImage and (Files.Count > 0) then
    begin
      if not Options.VirtualImage then
      begin
        LoadPicture(Graphic, Files[0], ImageInfo);
        try
          if Assigned(CallBack) then
            CallBack(Round(100 * (1 / 7)), Terminating);

          if Terminating then
            Exit;

          SampleImage.Assign(Graphic);
          SampleImage.PixelFormat := pf24bit;
          ImageInfo.AppllyICCProfile(SampleImage);
        finally
          F(Graphic);
        end;
      end else
        SampleImage.Assign(Options.Image);
    end else
      SampleImage.Assign(SampleBitmap);

    if Assigned(CallBack) then
      CallBack(Round(100 * (2 / 7)), Terminating);

    if Terminating then
      Exit;

    if ((Result.Width / Result.Height) > 1) and ((SampleImage.Width / SampleImage.Height) < 1) or
      ((Result.Width / Result.Height) < 1) and ((SampleImage.Width / SampleImage.Height) > 1) then
      Rotate90A(SampleImage);

    if Assigned(CallBack) then
      CallBack(Round(100 * (3 / 7)), Terminating);

    if Terminating then
      Exit;

    if Options.CropImages then
      CropImage(ImWidth, ImHeight, SampleImage);

    if Assigned(CallBack) then
      CallBack(Round(100 * (4 / 7)), Terminating);

    if Terminating then
      Exit;

    AWidth := SampleImage.Width;
    AHeight := SampleImage.Height;
    Size := MmToPix(XSize(ImWidth, ImHeight));
    if not FullImage then
    begin
      PrSize := XSize(Size.Width / Printer.PageWidth, Size.Height / Printer.PageHeight);
      Size := XSize(Result.Width * PrSize.Width, Result.Height * PrSize.Height);
    end;
    ProportionalSize(Round(Size.Width), Round(Size.Height), AWidth, AHeight);
    if AWidth / SampleImage.Width < 1 then
      StretchCool(Result.Width div 2 - AWidth div 2, Result.Height div 2 - AHeight div 2, AWidth, AHeight, SampleImage,
        Result)
    else
      Interpolate(Result.Width div 2 - AWidth div 2, Result.Height div 2 - AHeight div 2, AWidth, AHeight,
        Rect(0, 0, SampleImage.Width, SampleImage.Height), SampleImage, Result);

    if Assigned(CallBack) then
      CallBack(Round(100 * (7 / 7)), Terminating);

  finally
    F(SampleImage);
  end;
end;

procedure PrintImageSizeTwo(Result: TBitmap; SampleBitmap: TBitmap;
  Files: TStrings; FullImage: Boolean; ImWidth, ImHeight: Integer;
  Options: TGenerateImageOptions; CallBack: TCallBackPrinterGeneratePreviewProc;
  var Terminating: Boolean);
var
  Graphic: TGraphic;
  I: Integer;
  SampleImage: TBitmap;
  Size, PrSize: TXSize;
  AWidth, AHeight: Integer;
  ImageInfo: ILoadImageInfo;
begin
  SampleImage := TBitmap.Create;
  try
    for I := 0 to 1 do
    begin
      if FullImage then
      begin
        if (Files.Count = 1) and (I = 1) then
          Continue;
        LoadPicture(Graphic, Files[I], ImageInfo);
        try
          if Assigned(CallBack) then
            CallBack(Round(100 * ((1 + I * 7) / 14)), Terminating);
          if Terminating then
            Exit;

          SampleImage.Assign(Graphic);
          SampleImage.PixelFormat := pf24bit;
          ImageInfo.AppllyICCProfile(SampleImage);
        finally
          F(Graphic);
        end;
        if Assigned(CallBack) then
          CallBack(Round(100 * ((2 + I * 7) / 14)), Terminating);
        if Terminating then
          Exit;
      end else
        SampleImage.Assign(SampleBitmap);

      if ((Result.Width / Result.Height) < 1) and ((SampleImage.Width / SampleImage.Height) < 1) or
        ((Result.Width / Result.Height) > 1) and ((SampleImage.Width / SampleImage.Height) > 1) then
        Rotate90A(SampleImage);

      if Assigned(CallBack) then
        CallBack(Round(100 * ((3 + I * 7) / 14)), Terminating);
      if Terminating then
        Exit;

      if Options.CropImages then
        CropImage(ImWidth, ImHeight, SampleImage);
      if Assigned(CallBack) then
        CallBack(Round(100 * ((4 + I * 7) / 14)), Terminating);
      if Terminating then
        Exit;

      AWidth := SampleImage.Width;
      AHeight := SampleImage.Height;
      Size := MmToPix(XSize(ImWidth, ImHeight));
      if not FullImage then
      begin
        PrSize := XSize(Size.Width / Printer.PageWidth, Size.Height / Printer.PageHeight);
        Size := XSize(Result.Width * PrSize.Width, Result.Height * PrSize.Height);
      end;
      ProportionalSize(Round(Size.Width), Round(Size.Height), AWidth, AHeight);
      if AWidth / SampleImage.Width < 1 then
        StretchCool(Result.Width div 2 - AWidth div 2,
          (Result.Height div 4 + (Result.Height div 2) * I) - AHeight div 2, AWidth, Aheight, SampleImage, Result)
      else
        Interpolate(Result.Width div 2 - AWidth div 2,
          (Result.Height div 4 + (Result.Height div 2) * I) - AHeight div 2, AWidth, Aheight,
          Rect(0, 0, SampleImage.Width, SampleImage.Height), SampleImage, Result);
      if Assigned(CallBack) then
        CallBack(Round(100 * ((7 + I * 7) / 14)), Terminating);
      if Terminating then
        Exit;
    end;
  finally
    F(SampleImage);
  end;
end;

procedure Print35Previews(Result: TBitmap; SampleBitmap: TBitmap;
  Files: TStrings; FullImage: Boolean; Options: TGenerateImageOptions;
  CallBack: TCallBackPrinterGeneratePreviewProc; var Terminating: Boolean);
var
  Graphic: TGraphic;
  Pos, W, H, I, J: Integer;
  AWidth, AHeight: Integer;
  SampleImage, SmallImage: TBitmap;
  ImageInfo: ILoadImageInfo;
begin
  Pos := 0;
  if not FullImage then
  begin
    SmallImage := TBitmap.Create;
    try
      SampleImage := TBitmap.Create;
      try
        SampleImage.Assign(SampleBitmap);
        AWidth := SampleImage.Width;
        AHeight := SampleImage.Height;
        ProportionalSize(Result.Width div 6, Result.Height div 8, AWidth, AHeight);
        StretchCool(AWidth, Aheight, SampleImage, SmallImage);
        W := (Result.Width div 5);
        H := (Result.Height div 7);
        for I := 1 to 7 do
          for J := 1 to 5 do
            Result.Canvas.Draw(W * (J - 1) + W div 2 - SmallImage.Width div 2,
              H * (I - 1) + H div 2 - SmallImage.Height div 2, SmallImage);
      finally
        F(SampleImage);
      end;
    finally
      F(SmallImage);
    end;
  end else
  begin
    SampleImage := TBitmap.Create;
    try
      SampleImage.PixelFormat := pf24bit;
      W := (Result.Width div 5);
      H := (Result.Height div 7);
      for I := 1 to 7 do
      begin
        for J := 1 to 5 do
        begin
          if Files.Count < (I - 1) * 5 + J then
            Exit;
          LoadPicture(Graphic, Files[(I - 1) * 5 + J - 1], ImageInfo);
          try
            Inc(Pos);
            if Assigned(CallBack) then
              CallBack(Round(100 * (Pos / (5 * Files.Count))), Terminating);
            if Terminating then
              Exit;
            SampleImage.Assign(Graphic);
            SampleImage.PixelFormat := pf24Bit;
            ImageInfo.AppllyICCProfile(SampleImage);
            F(Graphic);
            Inc(Pos);
            if Assigned(CallBack) then
              CallBack(Round(100 * (Pos / (5 * Files.Count))), Terminating);
            if Terminating then
              Exit;

            AWidth := SampleImage.Width;
            AHeight := SampleImage.Height;
            ProportionalSize(Result.Width div 6, Result.Height div 8, AWidth, AHeight);
            if AWidth / SampleImage.Width < 1 then
              StretchCool(W * (J - 1) + W div 2 - AWidth div 2, H * (I - 1) + H div 2 - AHeight div 2, AWidth, Aheight,
                SampleImage, Result)
            else
              Interpolate(W * (J - 1) + W div 2 - AWidth div 2, H * (I - 1) + H div 2 - AHeight div 2, AWidth, Aheight,
                Rect(0, 0, SampleImage.Width, SampleImage.Height), SampleImage, Result);

            Inc(Pos, 3);
            if Assigned(CallBack) then
              CallBack(Round(100 * (Pos / (5 * Files.Count))), Terminating);
            if Terminating then
              Exit;
          finally
            F(Graphic);
          end;
        end;
      end;
    finally
      F(SampleImage);
    end;
  end;
end;

procedure PrintA4Three10X15(Result: TBitmap; SampleBitmap: TBitmap;
  Files: TStrings; FullImage: Boolean; Options: TGenerateImageOptions;
  CallBack: TCallBackPrinterGeneratePreviewProc; var Terminating: Boolean);
var
  Pos, TopSize, AW, AH, I, H, Ainc: Integer;
  Graphic: TGraphic;
  SampleImage: TBitmap;
  AWidth, AHeight: Integer;
  PrSize, Size: TXSize;
  ImageInfo: ILoadImageInfo;
begin
  Pos := 0;
  SampleImage := TBitmap.Create;
  try
    for I := 0 to 2 do
    begin
      if FullImage then
      begin
        if I >= Files.Count then
          Continue;

        LoadPicture(Graphic, Files[I], ImageInfo);
        try
          Inc(Pos);
          if Assigned(CallBack) then
            CallBack(Round(100 * (Pos / (7 * Files.Count))), Terminating);
          if Terminating then
            Exit;

          SampleImage.Assign(Graphic);
          SampleImage.PixelFormat := pf24bit;
          ImageInfo.AppllyICCProfile(SampleImage);
          Inc(Pos);
          if Assigned(CallBack) then
            CallBack(Round(100 * (Pos / (7 * Files.Count))), Terminating);
        finally
          F(Graphic);
        end;
        if Terminating then
          Exit;
      end
      else
        SampleImage.Assign(SampleBitmap);

      case I of
        0:
          if ((Result.Width / Result.Height) < 1) and ((SampleImage.Width / SampleImage.Height) < 1) or
            ((Result.Width / Result.Height) > 1) and ((SampleImage.Width / SampleImage.Height) > 1) then
            Rotate90A(SampleImage);
        1, 2:
          if ((Result.Width / Result.Height) > 1) and ((SampleImage.Width / SampleImage.Height) < 1) or
            ((Result.Width / Result.Height) < 1) and ((SampleImage.Width / SampleImage.Height) > 1) then
            Rotate90A(SampleImage);
      end;

      Inc(Pos);
      if Assigned(CallBack) then
        CallBack(Round(100 * (Pos / (7 * Files.Count))), Terminating);
      if Terminating then
        Exit;

      case I of
        0:
          begin
            AW := 150;
            AH := 100;
          end;
        1:
          begin
            AW := 100;
            AH := 150;
          end;
        2:
          begin
            AW := 100;
            AH := 150;
          end;
      else
        begin
          AW := 150;
          AH := 100;
        end;
      end;

      if Options.CropImages then
        CropImage(AW, AH, SampleImage);

      Inc(Pos);

      if Assigned(CallBack) then
        CallBack(Round(100 * (Pos / (7 * Files.Count))), Terminating);
      if Terminating then
        Exit;

      AWidth := SampleImage.Width;
      AHeight := SampleImage.Height;
      Size := MmToPix(XSize(AW, AH));
      if not FullImage then
      begin
        PrSize := XSize(Size.Width / Printer.PageWidth, Size.Height / Printer.PageHeight);
        Size := XSize(Result.Width * PrSize.Width, Result.Height * PrSize.Height);
      end;

      ProportionalSize(Round(Size.Width), Round(Size.Height), AWidth, AHeight);
      if FullImage then
        TopSize := Round(MmToPix(XSize(10, 10)).Height)
      else
        TopSize := Round((MmToPix(XSize(10, 10)).Height / Printer.PageHeight) * Result.Height);

      case I of
        0:
          begin
            if FullImage then
              H := Result.Height - AHeight - Round(MmToPix(XSize(10, 10)).Height)
            else
              H := Result.Height - AHeight - Round((MmToPix(XSize(10, 10)).Height / Printer.PageHeight)
                  * Result.Height);

            if AWidth / SampleImage.Width < 1 then
              StretchCool(Result.Width div 2 - AWidth div 2, H, AWidth, AHeight, SampleImage, Result)
            else
              Interpolate(Result.Width div 2 - AWidth div 2, H, AWidth, AHeight,
                Rect(0, 0, SampleImage.Width, SampleImage.Height), SampleImage, Result);
          end;
        1:
          begin
            if FullImage then
              Ainc := 0
            else
              Ainc := 1;
            if AWidth / SampleImage.Width < 1 then
              StretchCool(Result.Width div 4 - AWidth div 2 + Ainc, TopSize, AWidth, AHeight, SampleImage, Result)
            else
              Interpolate(Result.Width div 4 - AWidth div 2 + Ainc, TopSize, AWidth, AHeight,
                Rect(0, 0, SampleImage.Width, SampleImage.Height), SampleImage, Result);
          end;
        2:
          begin
            if FullImage then
              Ainc := 0
            else
              Ainc := 1;
            if AWidth / SampleImage.Width < 1 then
              StretchCool((Result.Width div 4) * 3 - AWidth div 2 + Ainc, TopSize, AWidth, AHeight, SampleImage, Result)
            else
              Interpolate((Result.Width div 4) * 3 - AWidth div 2 + Ainc, TopSize, AWidth, AHeight,
                Rect(0, 0, SampleImage.Width, SampleImage.Height), SampleImage, Result);
          end;
      end;
      Inc(Pos, 3);
      if Assigned(CallBack) then
        CallBack(Round(100 * (Pos / (7 * Files.Count))), Terminating);
      if Terminating then
        Exit;

    end;
  finally
    F(SampleImage);
  end;
end;

procedure PrintA4Four9X13(Result: TBitmap; SampleBitmap: TBitmap;
  Files: TStrings; FullImage: Boolean; Options: TGenerateImageOptions;
  CallBack: TCallBackPrinterGeneratePreviewProc; var Terminating: Boolean);
var
  I, J: Integer;
  Graphic: TGraphic;
  SampleImage: TBitmap;
  AWidth, AHeight: Integer;
  PrSize, Size: TXSize;
  ImageInfo: ILoadImageInfo;
begin
  SampleImage := TBitmap.Create;
  SampleImage.PixelFormat := pf24bit;
  try
    for J := 0 to 1 do
    begin
      for I := 0 to 1 do
      begin
        if FullImage then
        begin
          if J * 2 + I >= Files.Count then
            Continue;
          LoadPicture(Graphic, Files[J * 2 + I], ImageInfo);
          try
          if Assigned(CallBack) then
            CallBack(Round(100 * ((1 + (J * 2 + I) * 7) / 28)), Terminating);
          if Terminating then
            Exit;

          SampleImage.Assign(Graphic);
          SampleImage.PixelFormat := pf24Bit;
          ImageInfo.AppllyICCProfile(SampleImage);
          if Assigned(CallBack) then
            CallBack(Round(100 * ((2 + (J * 2 + I) * 7) / 28)), Terminating);
          finally
            F(Graphic);
          end;
          if Terminating then
            Exit;
        end else
          SampleImage.Assign(SampleBitmap);

        if ((Result.Width / Result.Height) > 1) and ((SampleImage.Width / SampleImage.Height) < 1) or
          ((Result.Width / Result.Height) < 1) and ((SampleImage.Width / SampleImage.Height) > 1) then
          Rotate90A(SampleImage);

        if Assigned(CallBack) then
          CallBack(Round(100 * ((3 + (J * 2 + I) * 7) / 28)), Terminating);
        if Terminating then
          Exit;

        if Options.CropImages then
          CropImage(90, 130, SampleImage);

        if Assigned(CallBack) then
          CallBack(Round(100 * ((4 + (J * 2 + I) * 7) / 28)), Terminating);
        if Terminating then
          Exit;

        AWidth := SampleImage.Width;
        AHeight := SampleImage.Height;
        Size := MmToPix(XSize(90, 130));
        if not FullImage then
        begin
          PrSize := XSize(Size.Width / Printer.PageWidth, Size.Height / Printer.PageHeight);
          Size := XSize(Result.Width * PrSize.Width, Result.Height * PrSize.Height);
        end;
        ProportionalSize(Round(Size.Width), Round(Size.Height), AWidth, AHeight);

        if AWidth / SampleImage.Width < 1 then
          StretchCool(Result.Width div 4 + (Result.Width div 2) * I - AWidth div 2,
            Result.Height div 4 + (Result.Height div 2) * J - AHeight div 2, AWidth, AHeight, SampleImage, Result)
        else
          Interpolate(Result.Width div 4 + (Result.Width div 2) * I - AWidth div 2,
            Result.Height div 4 + (Result.Height div 2) * J - AHeight div 2, AWidth, AHeight,
            Rect(0, 0, SampleImage.Width, SampleImage.Height), SampleImage, Result);

        if Assigned(CallBack) then
          CallBack(Round(100 * ((7 + (J * 2 + I) * 7) / 28)), Terminating);
        if Terminating then
          Exit;
      end;
    end;
  finally
    F(SampleImage);
  end;
end;

procedure Print9Images(Result: TBitmap; SampleBitmap: TBitmap; Files: TStrings;
  FullImage: Boolean; Options: TGenerateImageOptions;
  CallBack: TCallBackPrinterGeneratePreviewProc; var Terminating: Boolean);
var
  SmallImage, SampleImage: TBitmap;
  Pos, I, J, W, H, AWidth, AHeight: Integer;
  Graphic: TGraphic;
  ImageInfo: ILoadImageInfo;
begin
  Pos := 0;
  SampleImage := TBitmap.Create;
  try
    SampleImage.PixelFormat := Pf24bit;
    if not FullImage then
    begin
      SampleImage.Assign(SampleBitmap);
      if ((Result.Width / Result.Height) > 1) and ((SampleImage.Width / SampleImage.Height) < 1) or
        ((Result.Width / Result.Height) < 1) and ((SampleImage.Width / SampleImage.Height) > 1) then
        Rotate90A(SampleImage);

      AWidth := SampleImage.Width;
      AHeight := SampleImage.Height;
      SmallImage := TBitmap.Create;
      try
        ProportionalSize(Result.Width div 4, Result.Height div 4, AWidth, AHeight);
        StretchCool(AWidth, Aheight, SampleImage, SmallImage);
        W := (Result.Width div 3);
        H := (Result.Height div 3);
        for I := 1 to 3 do
          for J := 1 to 3 do
            Result.Canvas.Draw(W * (J - 1) + W div 2 - SmallImage.Width div 2,
              H * (I - 1) + H div 2 - SmallImage.Height div 2, SmallImage);
      finally
        F(SmallImage);
      end;
    end else
    begin
      W := (Result.Width div 3);
      H := (Result.Height div 3);
      for I := 1 to 3 do
      begin
        for J := 1 to 3 do
        begin
          if Files.Count < (I - 1) * 3 + J then
            Exit;
          LoadPicture(Graphic, Files[(I - 1) * 3 + J - 1], ImageInfo);
          try
            Inc(Pos);
            if Assigned(CallBack) then
              CallBack(Round(100 * (Pos / (6 * Files.Count))), Terminating);
            if Terminating then
              Exit;

            SampleImage.Assign(Graphic);
            SampleImage.PixelFormat := pf24Bit;
            ImageInfo.AppllyICCProfile(SampleImage);
            Inc(Pos);
            if Assigned(CallBack) then
              CallBack(Round(100 * (Pos / (6 * Files.Count))), Terminating);
            if Terminating then
              Exit;
          finally
            F(Graphic);
          end;

          if ((Result.Width / Result.Height) > 1) and ((SampleImage.Width / SampleImage.Height) < 1) or
            ((Result.Width / Result.Height) < 1) and ((SampleImage.Width / SampleImage.Height) > 1) then
            Rotate90A(SampleImage);
          Inc(Pos);
          if Assigned(CallBack) then
            CallBack(Round(100 * (Pos / (6 * Files.Count))), Terminating);
          if Terminating then
            Exit;

          AWidth := SampleImage.Width;
          AHeight := SampleImage.Height;
          ProportionalSize(Result.Width div 4, Result.Height div 4, AWidth, AHeight);

          if AWidth / SampleImage.Width < 1 then
            StretchCool(W * (J - 1) + W div 2 - AWidth div 2, H * (I - 1) + H div 2 - AHeight div 2, AWidth, AHeight,
              SampleImage, Result)
          else
            Interpolate(W * (J - 1) + W div 2 - AWidth div 2, H * (I - 1) + H div 2 - AHeight div 2, AWidth, AHeight,
              Rect(0, 0, SampleImage.Width, SampleImage.Height), SampleImage, Result);

          Inc(Pos, 3);
          if Assigned(CallBack) then
            CallBack(Round(100 * (Pos / (6 * Files.Count))), Terminating);
          if Terminating then
            Exit;
        end;
      end;
    end;
  finally
    F(SampleImage);
  end;
end;

procedure PrintFour6X4(Result: TBitmap; SampleBitmap: TBitmap; Files: TStrings;
  FullImage: Boolean; Options: TGenerateImageOptions;
  CallBack: TCallBackPrinterGeneratePreviewProc; var Terminating: Boolean);
var
  Graphic: TGraphic;
  SampleImage: TBitmap;
  I, J, AWidth, AHeight: Integer;
  Size, PrSize: TXSize;
  ImageInfo: ILoadImageInfo;
begin
  SampleImage := TBitmap.Create;
  SampleImage.PixelFormat := pf24bit;
  try
    if FullImage then
    begin
      if not Options.VirtualImage and (Files.Count > 0) then
      begin
        LoadPicture(Graphic, Files[0], ImageInfo);
        try
          if Assigned(CallBack) then
            CallBack(Round(100 * (1 / 7)), Terminating);
          if Terminating then
            Exit;

          SampleImage.Assign(Graphic);
          SampleImage.PixelFormat := pf24Bit;
          ImageInfo.AppllyICCProfile(SampleImage);

          if Assigned(CallBack) then
            CallBack(Round(100 * (2 / 7)), Terminating);
        finally
          F(Graphic);
        end;
        if Terminating then
          Exit;
      end else
      begin
        SampleImage.Assign(Options.Image);
        if Assigned(CallBack) then
          CallBack(Round(100 * (3 / 7)), Terminating);
      end;
    end else
      SampleImage.Assign(SampleBitmap);
    if ((Result.Width / Result.Height) > 1) and ((SampleImage.Width / SampleImage.Height) < 1) or
      ((Result.Width / Result.Height) < 1) and ((SampleImage.Width / SampleImage.Height) > 1) then
      Rotate90A(SampleImage);

    if Assigned(CallBack) then
      CallBack(Round(100 * (3 / 7)), Terminating);
    if Terminating then
      Exit;

    if Options.CropImages then
      CropImage(40, 60, SampleImage);
    if Assigned(CallBack) then
      CallBack(Round(100 * (4 / 7)), Terminating);
    if Terminating then
      Exit;

    AWidth := SampleImage.Width;
    AHeight := SampleImage.Height;
    Size := MmToPix(XSize(40, 60));
    if not FullImage then
    begin
      PrSize := XSize(Size.Width / Printer.PageWidth, Size.Height / Printer.PageHeight);
      Size := XSize(Result.Width * PrSize.Width, Result.Height * PrSize.Height);
    end;
    ProportionalSize(Round(Size.Width), Round(Size.Height), AWidth, AHeight);
    for I := -1 to 1 do
    begin
      for J := -1 to 1 do
      begin
        if I * J = 0 then
          Continue;
        if AWidth / SampleImage.Width < 1 then
          StretchCool(Result.Width div 2 - AWidth div 2 + Round(I * AWidth * 0.55),
            Result.Height div 2 - AHeight div 2 + Round(J * AHeight * 0.55), AWidth, AHeight, SampleImage, Result)
        else
          Interpolate(Result.Width div 2 - AWidth div 2 + Round(I * AWidth * 0.55),
            Result.Height div 2 - AHeight div 2 + Round(J * AHeight * 0.55), AWidth, AHeight,
            Rect(0, 0, SampleImage.Width, SampleImage.Height), SampleImage, Result);

        if Assigned(CallBack) then
          CallBack(Round(100 * (7 / 7)), Terminating);
        if Terminating then
          Exit;
      end;
    end;
  finally
    F(SampleImage);
  end;
end;

procedure PrintSix3X4(Result: TBitmap; SampleBitmap: TBitmap; Files: TStrings;
  FullImage: Boolean; Options: TGenerateImageOptions;
  CallBack: TCallBackPrinterGeneratePreviewProc; var Terminating: Boolean);
var
  SampleImage: TBitmap;
  Graphic: TGraphic;
  I, J, AWidth, AHeight: Integer;
  PrSize, Size: TXSize;
  ImageInfo: ILoadImageInfo;
begin
  SampleImage := TBitmap.Create;
  SampleImage.PixelFormat := Pf24bit;
  try
    if FullImage then
    begin
      if not Options.VirtualImage then
      begin
        LoadPicture(Graphic, Files[0], ImageInfo);
        try
          if Assigned(CallBack) then
            CallBack(Round(100 * (1 / 7)), Terminating);
          if Terminating then
            Exit;
          SampleImage.Assign(Graphic);
          SampleImage.PixelFormat := pf24bit;
          ImageInfo.AppllyICCProfile(SampleImage);
          if Assigned(CallBack) then
            CallBack(Round(100 * (2 / 7)), Terminating);
        finally
          F(Graphic);
        end;
        if Terminating then
          Exit;
      end else
      begin
        SampleImage.Assign(Options.Image);
        if Assigned(CallBack) then
          CallBack(Round(100 * (3 / 7)), Terminating);
      end;
    end else
      SampleImage.Assign(SampleBitmap);

    if ((Result.Width / Result.Height) > 1) and ((SampleImage.Width / SampleImage.Height) < 1) or
      ((Result.Width / Result.Height) < 1) and ((SampleImage.Width / SampleImage.Height) > 1) then
      Rotate90A(SampleImage);

    if Assigned(CallBack) then
      CallBack(Round(100 * (3 / 7)), Terminating);
    if Terminating then
      Exit;

    if Options.CropImages then
      CropImage(30, 40, SampleImage);

    if Assigned(CallBack) then
      CallBack(Round(100 * (4 / 7)), Terminating);
    if Terminating then
      Exit;

    AWidth := SampleImage.Width;
    AHeight := SampleImage.Height;
    Size := MmToPix(XSize(30, 40));
    if not FullImage then
    begin
      PrSize := XSize(Size.Width / Printer.PageWidth, Size.Height / Printer.PageHeight);
      Size := XSize(Result.Width * PrSize.Width, Result.Height * PrSize.Height);
    end;
    ProportionalSize(Round(Size.Width), Round(Size.Height), AWidth, AHeight);
    for I := -1 to 1 do
    begin
      for J := -1 to 1 do
      begin
        if J <> 0 then
        begin
          if AWidth / SampleImage.Width < 1 then
            StretchCool(Result.Width div 2 - AWidth div 2 + Round(I * AWidth * 1.05),
              Result.Height div 2 - AHeight div 2 + Round(J * AHeight * 0.55), AWidth, AHeight, SampleImage, Result)
          else
            Interpolate(Result.Width div 2 - AWidth div 2 + Round(I * AWidth * 1.05),
              Result.Height div 2 - AHeight div 2 + Round(J * AHeight * 0.55), AWidth, AHeight,
              Rect(0, 0, SampleImage.Width, SampleImage.Height), SampleImage, Result);

          if Assigned(CallBack) then
            CallBack(Round(100 * (7 / 7)), Terminating);
          if Terminating then
            Exit;
        end;
      end;
    end;

  finally
    F(SampleImage);
  end;
end;

function GenerateImage(FullImage: Boolean; Width, Height: Integer; SampleImage: TBitmap; Files: TStrings;
  SampleImageType: TPrintSampleSizeOne; Options: TGenerateImageOptions;
  CallBack: TCallBackPrinterGeneratePreviewProc = nil): TBitmap;
var
  ImageWidth, ImageHeight: Integer;
  Terminating: Boolean;
begin
  Result := nil;
  if Options.VirtualImage then
  begin
    if (Options.Image = nil) or Options.Image.Empty then
      Exit;
    SampleImage := Options.Image;
  end;

  Terminating := False;
  Result := TBitmap.Create;
  Result.PixelFormat := Pf24bit;
  Result.Width := Width;
  Result.Height := Height;

  try
    if not FullImage then
    begin
      Result.Canvas.Brush.Color := $EEEEEE;
      Result.Canvas.Pen.Color := $0;
      Result.Canvas.Rectangle(0, 0, Width, Height);
    end;

    case SampleImageType of

      TPSS_FullSize:
        begin
          PrintFullSize(Result, SampleImage, Files, FullImage, Options, CallBack, Terminating);
        end;

      TPSS_C35:
        begin
          Print35Previews(Result, SampleImage, Files, FullImage, Options, CallBack, Terminating);
        end;

      TPSS_20X25C1:
        begin
          PrintCenterImageSize(Result, SampleImage, Files, FullImage, 200, 250, Options, CallBack, Terminating);
        end;

      TPSS_13X18C1:
        begin
          PrintCenterImageSize(Result, SampleImage, Files, FullImage, 130, 180, Options, CallBack, Terminating);
        end;

      TPSS_10X15C1:
        begin
          PrintCenterImageSize(Result, SampleImage, Files, FullImage, 100, 150, Options, CallBack, Terminating);
        end;

      TPSS_9X13C1:
        begin
          PrintCenterImageSize(Result, SampleImage, Files, FullImage, 90, 130, Options, CallBack, Terminating);
        end;

      TPSS_13X18C2:
        begin
          PrintImageSizeTwo(Result, SampleImage, Files, FullImage, 180, 130, Options, CallBack, Terminating);
        end;

      TPSS_10X15C2:
        begin
          PrintImageSizeTwo(Result, SampleImage, Files, FullImage, 150, 100, Options, CallBack, Terminating);
        end;

      TPSS_9X13C2:
        begin
          PrintImageSizeTwo(Result, SampleImage, Files, FullImage, 130, 90, Options, CallBack, Terminating);
        end;

      TPSS_10X15C3:
        begin
          PrintA4Three10X15(Result, SampleImage, Files, FullImage, Options, CallBack, Terminating);
        end;

      TPSS_9X13C4:
        begin
          PrintA4Four9X13(Result, SampleImage, Files, FullImage, Options, CallBack, Terminating);
        end;

      TPSS_C9:
        begin
          Print9Images(Result, SampleImage, Files, FullImage, Options, CallBack, Terminating);
        end;

      TPSS_CUSTOM:
        begin
          ImageWidth := Round(PixToSm(XSize(Options.FreeWidthPx, 0)).Width * 10);
          ImageHeight := Round(PixToSm(XSize(0, Options.FreeHeightPx)).Height * 10);
          PrintImageSizeTwo(Result, SampleImage, Files, FullImage, ImageWidth, ImageHeight, Options, CallBack, Terminating);
        end;

      TPSS_4X6C4:
        begin
          PrintFour6X4(Result, SampleImage, Files, FullImage, Options, CallBack, Terminating);
        end;

      TPSS_3X4C6:
        begin
          PrintSix3X4(Result, SampleImage, Files, FullImage, Options, CallBack, Terminating);
        end;

    end;
  except
    on E: Exception do
      EventLog(':GenerateImage() throw exception: ' + E.message);
  end;
end;

end.
