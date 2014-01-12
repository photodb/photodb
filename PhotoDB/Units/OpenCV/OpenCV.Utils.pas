unit OpenCV.Utils;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  Vcl.Graphics,

  OpenCV.Core,

  uMemory;

procedure Bitmap2IplImage(IplImg: PIplImage; Bitmap: TBitmap);
procedure IplImage2Bitmap(IplImg: PIplImage; Bitmap: TBitmap);
procedure SavePIplImageAsBitmap(IplImg: PIplImage; FileName: string);

implementation

procedure SavePIplImageAsBitmap(IplImg: PIplImage; FileName: string);
var
  B: TBitmap;
begin
  B := TBitmap.Create;
  try
    B.PixelFormat := pf24bit;
    B.SetSize(IplImg.width, IplImg.height);
    IplImage2Bitmap(IplImg, B);
    B.SaveToFile(FileName);
  finally
    F(B);
  end;
end;

{-----------------------------------------------------------------------------
  Procedure:  IplImage2Bitmap
  Author:     De Sanctis
  Date:       23-set-2005
  Arguments:  iplImg: PIplImage; bitmap: TBitmap
  Description: convert a IplImage to a Windows bitmap
  ----------------------------------------------------------------------------- }
procedure Bitmap2IplImage(IplImg: PIplImage; Bitmap: TBitmap);
const
 IPL_ORIGIN_TL = 0;
 IPL_ORIGIN_BL = 1;

var
  I: INTEGER;
  J: INTEGER;
  Offset: Longint;
  DataByte: PByteArray;
  RowIn: PByteArray;
  IsBGR, IsGray: Boolean;

  function ToString(A: TA4CVChar): string;
  var
    I: Integer;
  begin
    SetLength(Result, 4);
    for I := 0 to 3 do
      Result[I + 1] := Char(A[I]);

    Result := Trim(Result);
  end;

begin
  Assert((iplImg.Depth = 8) and (iplImg.NChannels in [1,3]), 'IplImage2Bitmap: Not a 24 bit color iplImage!');

  Bitmap.Height := IplImg.Height;
  Bitmap.Width := IplImg.Width;
  IsBGR := ToString(IplImg.ChannelSeq) = 'BGR';
  IsGray := ToString(IplImg.ChannelSeq) = 'GRAY';
  for J := 0 to Bitmap.Height - 1 do
  begin
    // origin BL = Bottom-Left
    if (Iplimg.Origin = IPL_ORIGIN_BL) then
      RowIn := Bitmap.Scanline[Bitmap.Height - 1 - J]
    else
      RowIn := Bitmap.Scanline[J];

    Offset := Longint(Iplimg.ImageData) + IplImg.WidthStep * J;
    DataByte := Pbytearray(Offset);

    if IsBGR then
    begin
      { direct copy of the iplImage row bytes to bitmap row }
      CopyMemory(DataByte, Rowin, IplImg.WidthStep);
    end else if IsGray then
    begin
      if Bitmap.PixelFormat = pf24Bit then
        for I := 0 to Bitmap.Width - 1 do
          Databyte[I] := (RowIn[3 * I] * 77  + RowIn[3 * I + 1] * 151 + RowIn[3 * I + 2] * 28) shr 8;
      if Bitmap.PixelFormat = pf8Bit then
        for I := 0 to Bitmap.Width - 1 do
          Databyte[I] := RowIn[I];
    end else
    begin
      for I := 0 to 3 * Bitmap.Width - 1 do
      begin
        Databyte[I + 2] := RowIn[I];
        Databyte[I + 1] := RowIn[I + 1];
        Databyte[I] := RowIn[I + 2];
      end;
    end;
  end;
end; { IplImage2Bitmap }


{-----------------------------------------------------------------------------
  Procedure:  IplImage2Bitmap
  Author:     De Sanctis
  Date:       23-set-2005
  Arguments:  iplImg: PIplImage; bitmap: TBitmap
  Description: convert a IplImage to a Windows bitmap
  ----------------------------------------------------------------------------- }
procedure IplImage2Bitmap(IplImg: PIplImage; Bitmap: TBitmap);
const
 IPL_ORIGIN_TL = 0;
 IPL_ORIGIN_BL = 1;

var
  I: INTEGER;
  J: INTEGER;
  Offset: Longint;
  DataByte: PByteArray;
  RowIn: PByteArray;
  IsBGR, IsGray: Boolean;

  function ToString(A: TA4CVChar): string;
  var
    I: Integer;
  begin
    SetLength(Result, 4);
    for I := 0 to 3 do
      Result[I + 1] := Char(A[I]);

    Result := Trim(Result);
  end;

begin
  Assert((iplImg.Depth = 8) and (iplImg.NChannels in [1,3]), 'IplImage2Bitmap: Not a 24 bit color iplImage!');

  Bitmap.SetSize(IplImg.Width, IplImg.Height);

  IsBGR := ToString(IplImg.ChannelSeq) = 'BGR';
  IsGray := ToString(IplImg.ChannelSeq) = 'GRAY';
  for J := 0 to Bitmap.Height - 1 do
  begin
    // origin BL = Bottom-Left
    if (Iplimg.Origin = IPL_ORIGIN_BL) then
      RowIn := Bitmap.Scanline[Bitmap.Height - 1 - J]
    else
      RowIn := Bitmap.Scanline[J];

    Offset := Longint(Iplimg.ImageData) + IplImg.WidthStep * J;
    DataByte := Pbytearray(Offset);

    if IsBGR then
    begin
      { direct copy of the iplImage row bytes to bitmap row }
      CopyMemory(Rowin, DataByte, IplImg.WidthStep);
    end else if IsGray then
    begin
      if Bitmap.PixelFormat = pf24Bit then
        for I := 0 to Bitmap.Width - 1 do
        begin
          RowIn[3 * I] := Databyte[I];
          RowIn[3 * I + 1] := Databyte[I];
          RowIn[3 * I + 2] := Databyte[I];
        end;
      if Bitmap.PixelFormat = pf8Bit then
        for I := 0 to Bitmap.Width - 1 do
          RowIn[I] := Databyte[I];
    end else
    begin
      for I := 0 to 3 * Bitmap.Width - 1 do
      begin
        RowIn[I] := Databyte[I + 2];
        RowIn[I + 1] := Databyte[I + 1];
        RowIn[I + 2] := Databyte[I];
      end;
    end;
  end;
end; { IplImage2Bitmap }

end.
