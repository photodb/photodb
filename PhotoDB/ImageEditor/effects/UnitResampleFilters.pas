unit UnitResampleFilters;

interface

uses Math, Windows, Graphics, SysUtils, GraphicsBaseTypes, uMath,
  uEditorTypes;

  // Sample filters for use with Stretch()
  function SplineFilter(Value: Single): Single; inline;
  function BellFilter(Value: Single): Single; inline;
  function TriangleFilter(Value: Single): Single; inline;
  function BoxFilter(Value: Single): Single; inline;
  function HermiteFilter(Value: Single): Single; inline;
  function Lanczos3Filter(Value: Single): Single; inline;
  function MitchellFilter(Value: Single): Single; inline;

{$DEFINE USE_SCANLINE}

const
  MaxPixelCount = 32768;

// -----------------------------------------------------------------------------
//
//			List of Filters
//
// -----------------------------------------------------------------------------
  type

  TFilterProc = function(Value: Single): Single;

  const
  ResampleFilters: array[0..6] of record
    Name: string;	// Filter name
    Filter: TFilterProc;// Filter implementation
    Width: Single;	// Suggested sampling width/radius
  end = (
    (Name: 'Box';	Filter: BoxFilter;	Width: 0.5),
    (Name: 'Triangle';	Filter: TriangleFilter;	Width: 1.0),
    (Name: 'Hermite';	Filter: HermiteFilter;	Width: 1.0),
    (Name: 'Bell';	Filter: BellFilter;	Width: 1.5),
    (Name: 'B-Spline';	Filter: SplineFilter;	Width: 2.0),
    (Name: 'Lanczos3';	Filter: Lanczos3Filter;	Width: 3.0),
    (Name: 'Mitchell';	Filter: MitchellFilter;	Width: 2.0)
    );

  procedure Strecth(Src, Dst: TBitmap; filter: TFilterProc;
  fwidth: single; CallBack : TBaseEffectCallBackProc = nil);

  type
  // Contributor for a pixel
  TContributor = record
    pixel: integer;		// Source pixel
    weight: single;		// Pixel weight
  end;

  TContributorList = array[0..0] of TContributor;
  PContributorList = ^TContributorList;

  // List of source pixels contributing to a destination pixel
  TCList = record
    n		: integer;
    p		: PContributorList;
  end;

  TCListList = array[0..0] of TCList;
  PCListList = ^TCListList;

  TRGB = packed record
    r, g, b	: single;
  end;

  // Physical bitmap pixel
  TColorRGB = packed record
    r, g, b	: BYTE;
  end;
  PColorRGB = ^TColorRGB;

  // Physical bitmap scanline (row)
  TRGBList = packed array[0..0] of TColorRGB;
  PRGBList = ^TRGBList;

type
TRGBTripleArray = ARRAY[0..MaxPixelCount-1] OF
TRGBTriple;
pRGBTripleArray = ^TRGBTripleArray;
TFColor=record
  b,g,r: Byte;
end;

implementation

// Bell filter
function BellFilter(Value: Single): Single;
begin
  if Value < 0 then
    Value := - Value;
  if (Value < 0.5) then
    Result := 0.75 - Sqr(Value)
  else if (Value < 1.5) then
  begin
    Value := Value - 1.5;
    Result := 0.5 * Sqr(Value);
  end else
    Result := 0.0;
end;

// Box filter
// a.k.a. "Nearest Neighbour" filter
// anme: I have not been able to get acceptable
//       results with this filter for subsampling.
function BoxFilter(Value: Single): Single;
begin
  if (Value > -0.5) and (Value <= 0.5) then
    Result := 1.0
  else
    Result := 0.0;
end;

// Hermite filter
function HermiteFilter(Value: Single): Single;
begin
  // f(t) = 2|t|^3 - 3|t|^2 + 1, -1 <= t <= 1
  if Value < 0 then
    Value := - Value;
  if (Value < 1.0) then
    Result := (2.0 * Value - 3.0) * Sqr(Value) + 1.0
  else
    Result := 0.0;
end;

// Lanczos3 filter
function Lanczos3Filter(Value: Single): Single;
 function SinC(Value: Single): Single; inline;
  begin
    if (Value <> 0.0) then
    begin
      Value := Value * Pi;
      Result := Sin(Value) / Value
    end else
      Result := 1.0;
  end;
begin
  if Value < 0 then
    Value := - Value;
  if (Value < 3.0) then
    Result := SinC(Value) * SinC(Value / 3.0)
  else
    Result := 0.0;
end;

function MitchellFilter(Value: Single): Single;
const
  B		= (1.0 / 3.0);
  C		= (1.0 / 3.0);
var
  tt			: single;
begin
  if Value < 0 then
    Value := - Value;
  tt := Sqr(Value);
  if (Value < 1.0) then
  begin
    Value := (((12.0 - 9.0 * B - 6.0 * C) * (Value * tt))
      + ((-18.0 + 12.0 * B + 6.0 * C) * tt)
      + (6.0 - 2 * B));
    Result := Value / 6.0;
  end else
  if (Value < 2.0) then
  begin
    Value := (((-1.0 * B - 6.0 * C) * (Value * tt))
      + ((6.0 * B + 30.0 * C) * tt)
      + ((-12.0 * B - 48.0 * C) * Value)
      + (8.0 * B + 24 * C));
    Result := Value / 6.0;
  end else
    Result := 0.0;
end;

// B-spline filter
function SplineFilter(Value: Single): Single;
var
  tt			: single;
begin
  if Value < 0 then
    Value := - Value;
  if (Value < 1.0) then
  begin
    tt := Sqr(Value);
    Result := 0.5*tt*Value - tt + 2.0 / 3.0;
  end else if (Value < 2.0) then
  begin
    Value := 2.0 - Value;
    Result := 1.0/6.0 * Sqr(Value) * Value;
  end else
    Result := 0.0;
end;

// Triangle filter
// a.k.a. "Linear" or "Bilinear" filter
function TriangleFilter(Value: Single): Single;
begin
 if (Value < 0.0) then
    Value := -Value;
  if (Value < 1.0) then
    Result := 1.0 - Value
  else
    Result := 0.0;
end;

procedure Strecth(Src, Dst: TBitmap; filter: TFilterProc;
  fwidth: single; CallBack : TBaseEffectCallBackProc = nil);
var
  xscale, yscale	: single;		// Zoom scale factors
  i, j, k		: integer;		// Loop variables
  center		: single;		// Filter calculation variables
  width, fscale, weight	: single;		// Filter calculation variables
  left, right		: integer;		// Filter calculation variables
  n			: integer;		// Pixel number
  Work			: TBitmap;
  contrib		: PCListList;
  rgb			: TRGB;
  color			: TColorRGB;
{$IFDEF USE_SCANLINE}
  SourceLine		,
  DestLine		: PRGBList;
  SourcePixel		,
  DestPixel		: PColorRGB;
  Delta			,
  DestDelta		: integer;
{$ENDIF}
  SrcWidth		,
  SrcHeight		,
  DstWidth		,
  DstHeight		: integer;
  Terminating : boolean;

  function Color2RGB(Color: TColor): TColorRGB;
  begin
    Result.r := Color AND $000000FF;
    Result.g := (Color AND $0000FF00) SHR 8;
    Result.b := (Color AND $00FF0000) SHR 16;
  end;

  function RGB2Color(Color: TColorRGB): TColor;
  begin
    Result := Color.r OR (Color.g SHL 8) OR (Color.b SHL 16);
  end;


begin
 {$R-}
 Terminating:=false;
 DstWidth := Dst.Width;
 DstHeight := Dst.Height;
 SrcWidth := Src.Width;
 SrcHeight := Src.Height;
  if (SrcWidth < 1) or (SrcHeight < 1) then
    raise Exception.Create('Source bitmap too small');

  // Create intermediate image to hold horizontal zoom
  Work := TBitmap.Create;
  try
    Work.SetSize(DstWidth, SrcHeight);
    // xscale := DstWidth / SrcWidth;
    // yscale := DstHeight / SrcHeight;
    // Improvement suggested by David Ullrich:
    if (SrcWidth = 1) then
      xscale:= DstWidth / SrcWidth
    else
      xscale:= (DstWidth - 1) / (SrcWidth - 1);
    if (SrcHeight = 1) then
      yscale:= DstHeight / SrcHeight
    else
      yscale:= (DstHeight - 1) / (SrcHeight - 1);
    // This implementation only works on 24-bit images because it uses
    // TBitmap.Scanline
{$IFDEF USE_SCANLINE}
    Src.PixelFormat := pf24bit;
    Dst.PixelFormat := Src.PixelFormat;
    Work.PixelFormat := Src.PixelFormat;
{$ENDIF}
    // --------------------------------------------
    // Pre-calculate filter contributions for a row
    // -----------------------------------------------
    GetMem(contrib, DstWidth* sizeof(TCList));
    // Horizontal sub-sampling
    // Scales from bigger to smaller width
    if (xscale < 1.0) then
    begin
      width := fwidth / xscale;
      fscale := 1.0 / xscale;
      for i := 0 to DstWidth-1 do
      begin
        contrib^[i].n := 0;
        GetMem(contrib^[i].p, FastTrunc(width * 2.0 + 1) * sizeof(TContributor));
        center := i / xscale;
        // Original code:
        // left := FastCeil(center - width);
        // right := FastFloor(center + width);
        left := FastFloor(center - width);
        right := FastCeil(center + width);
        for j := left to right do
        begin
          weight := filter((center - j) / fscale) / fscale;
          if (weight = 0.0) then
            continue;
          if (j < 0) then
            n := -j
          else if (j >= SrcWidth) then
            n := SrcWidth - j + SrcWidth - 1
          else
            n := j;
          k := contrib^[i].n;
          contrib^[i].n := contrib^[i].n + 1;
          contrib^[i].p^[k].pixel := n;
          contrib^[i].p^[k].weight := weight;
        end;
      end;
    end else
    // Horizontal super-sampling
    // Scales from smaller to bigger width
    begin
      for i := 0 to DstWidth-1 do
      begin
        contrib^[i].n := 0;
        GetMem(contrib^[i].p, FastTrunc(fwidth * 2.0 + 1) * sizeof(TContributor));
        center := i / xscale;
        // Original code:
        // left := FastCeil(center - fwidth);
        // right := FastFloor(center + fwidth);
        left := FastFloor(center - fwidth);
        right := FastCeil(center + fwidth);
        for j := left to right do
        begin
          weight := filter(center - j);
          if (weight = 0.0) then
            continue;
          if (j < 0) then
            n := -j
          else if (j >= SrcWidth) then
            n := SrcWidth - j + SrcWidth - 1
          else
            n := j;
          k := contrib^[i].n;
          contrib^[i].n := contrib^[i].n + 1;
          contrib^[i].p^[k].pixel := n;
          contrib^[i].p^[k].weight := weight;
        end;
      end;
    end;

    // ----------------------------------------------------
    // Apply filter to sample horizontally from Src to Work
    // ----------------------------------------------------
    for k := 0 to SrcHeight-1 do
    begin
{$IFDEF USE_SCANLINE}
      SourceLine := Src.ScanLine[k];
      DestPixel := Work.ScanLine[k];
{$ENDIF}
      for i := 0 to DstWidth-1 do
      begin
        rgb.r := 0.0;
        rgb.g := 0.0;
        rgb.b := 0.0;
        for j := 0 to contrib^[i].n-1 do
        begin
{$IFDEF USE_SCANLINE}
          color := SourceLine^[contrib^[i].p^[j].pixel];
{$ELSE}
          color := Color2RGB(Src.Canvas.Pixels[contrib^[i].p^[j].pixel, k]);
{$ENDIF}
          weight := contrib^[i].p^[j].weight;
          if (weight = 0.0) then
            continue;
          rgb.r := rgb.r + color.r * weight;
          rgb.g := rgb.g + color.g * weight;
          rgb.b := rgb.b + color.b * weight;
        end;
        if (rgb.r > 255.0) then
          color.r := 255
        else if (rgb.r < 0.0) then
          color.r := 0
        else
          color.r := Round(rgb.r);
        if (rgb.g > 255.0) then
          color.g := 255
        else if (rgb.g < 0.0) then
          color.g := 0
        else
          color.g := Round(rgb.g);
        if (rgb.b > 255.0) then
          color.b := 255
        else if (rgb.b < 0.0) then
          color.b := 0
        else
          color.b := Round(rgb.b);
{$IFDEF USE_SCANLINE}
        // Set new pixel value
        DestPixel^ := color;
        // Move on to next column
        inc(DestPixel);
{$ELSE}
        Work.Canvas.Pixels[i, k] := RGB2Color(color);
{$ENDIF}
      end;

      if K mod 50 = 0 then
        if Assigned(CallBack) then
          CallBack(Round(50 * K / SrcHeight), Terminating);
      if Terminating then
        Break;

    end;

    // Free the memory allocated for horizontal filter weights
    for i := 0 to DstWidth-1 do
      FreeMem(contrib^[i].p);

    FreeMem(contrib);

    // -----------------------------------------------
    // Pre-calculate filter contributions for a column
    // -----------------------------------------------
    GetMem(contrib, DstHeight* sizeof(TCList));
    // Vertical sub-sampling
    // Scales from bigger to smaller height
    if (yscale < 1.0) then
    begin
      width := fwidth / yscale;
      fscale := 1.0 / yscale;
      for i := 0 to DstHeight-1 do
      begin
        contrib^[i].n := 0;
        GetMem(contrib^[i].p, FastTrunc(width * 2.0 + 1) * sizeof(TContributor));
        center := i / yscale;
        // Original code:
        // left := FastCeil(center - width);
        // right := FastFloor(center + width);
        left := FastFloor(center - width);
        right := FastCeil(center + width);
        for j := left to right do
        begin
          weight := filter((center - j) / fscale) / fscale;
          if (weight = 0.0) then
            continue;
          if (j < 0) then
            n := -j
          else if (j >= SrcHeight) then
            n := SrcHeight - j + SrcHeight - 1
          else
            n := j;
          k := contrib^[i].n;
          contrib^[i].n := contrib^[i].n + 1;
          contrib^[i].p^[k].pixel := n;
          contrib^[i].p^[k].weight := weight;
        end;
      end
    end else
    // Vertical super-sampling
    // Scales from smaller to bigger height
    begin
      for i := 0 to DstHeight-1 do
      begin
        contrib^[i].n := 0;
        GetMem(contrib^[i].p, FastTrunc(fwidth * 2.0 + 1) * sizeof(TContributor));
        center := i / yscale;
        // Original code:
        // left := FastCeil(center - fwidth);
        // right := FastFloor(center + fwidth);
        left := FastFloor(center - fwidth);
        right := FastCeil(center + fwidth);
        for j := left to right do
        begin
          weight := filter(center - j);
          if (weight = 0.0) then
            continue;
          if (j < 0) then
            n := -j
          else if (j >= SrcHeight) then
            n := SrcHeight - j + SrcHeight - 1
          else
            n := j;
          k := contrib^[i].n;
          contrib^[i].n := contrib^[i].n + 1;
          contrib^[i].p^[k].pixel := n;
          contrib^[i].p^[k].weight := weight;
        end;
        if K mod 50 = 0 then
          if Assigned(CallBack) then
            CallBack(Round(50 * K / DstHeight), Terminating);
        if Terminating then
          Break;
      end;
    end;

    // --------------------------------------------------
    // Apply filter to sample vertically from Work to Dst
    // --------------------------------------------------
{$IFDEF USE_SCANLINE}
    SourceLine := Work.ScanLine[0];
    Delta := 0;
    if Work.Height > 1 then
      Delta := integer(Work.ScanLine[1]) - integer(SourceLine);
    DestLine := Dst.ScanLine[0];
    DestDelta := 0;
    if Dst.Height > 1 then
      DestDelta := integer(Dst.ScanLine[1]) - integer(DestLine);
{$ENDIF}
    for k := 0 to DstWidth-1 do
    begin
{$IFDEF USE_SCANLINE}
      DestPixel := pointer(DestLine);
{$ENDIF}
      for i := 0 to DstHeight-1 do
      begin
        rgb.r := 0;
        rgb.g := 0;
        rgb.b := 0;
        // weight := 0.0;
        for j := 0 to contrib^[i].n-1 do
        begin
{$IFDEF USE_SCANLINE}
          color := PColorRGB(integer(SourceLine)+contrib^[i].p^[j].pixel*Delta)^;
{$ELSE}
          color := Color2RGB(Work.Canvas.Pixels[k, contrib^[i].p^[j].pixel]);
{$ENDIF}
          weight := contrib^[i].p^[j].weight;
          if (weight = 0.0) then
            continue;
          rgb.r := rgb.r + color.r * weight;
          rgb.g := rgb.g + color.g * weight;
          rgb.b := rgb.b + color.b * weight;
        end;
        if (rgb.r > 255.0) then
          color.r := 255
        else if (rgb.r < 0.0) then
          color.r := 0
        else
          color.r := Round(rgb.r);
        if (rgb.g > 255.0) then
          color.g := 255
        else if (rgb.g < 0.0) then
          color.g := 0
        else
          color.g := Round(rgb.g);
        if (rgb.b > 255.0) then
          color.b := 255
        else if (rgb.b < 0.0) then
          color.b := 0
        else
          color.b := Round(rgb.b);
{$IFDEF USE_SCANLINE}
        DestPixel^ := color;
        inc(integer(DestPixel), DestDelta);
{$ELSE}
        Dst.Canvas.Pixels[k, i] := RGB2Color(color);
{$ENDIF}
      end;
{$IFDEF USE_SCANLINE}
      Inc(SourceLine, 1);
      Inc(DestLine, 1);
{$ENDIF}
      if K mod 50 = 0 then
        if Assigned(CallBack) then
          CallBack(Round(50 + 50 * K / DstHeight), Terminating);
      if Terminating then
        Break;
    end;

    // Free the memory allocated for vertical filter weights
    for i := 0 to DstHeight-1 do
      FreeMem(contrib^[i].p);

    FreeMem(contrib);

  finally
    Work.Free;
  end;
end;


end.
