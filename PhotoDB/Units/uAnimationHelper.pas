unit uAnimationHelper;

interface

uses
  System.Math,
  Winapi.Windows,
  Vcl.Graphics,
  Vcl.ExtCtrls,

  Dmitry.Utils.System,

  GIFImage,
  uConstants,
  uAnimatedJPEG;

type
  TDrawProcedure = reference to procedure;

type
  TAnimationHelper = class helper for TGraphic
  public
    function ValidFrameCount: Integer;
    function IsTransparentAnimation: Boolean;

    function GetFirstFrameNumber: Integer;
    function GetNextFrameNumber(CurrentFrameNumber: Integer): Integer;
    function GetPreviousFrameNumber(CurrentFrameNumber: Integer): Integer;

    procedure ProcessNextFrame(AnimatedBuffer: TBitmap; var CurrentFrameNumber: Integer;
                               BackgrondColor: TColor; Timer: TTimer; DrawCallBack: TDrawProcedure);
  end;

implementation

function TAnimationHelper.GetFirstFrameNumber: Integer;
var
  I: Integer;
begin
  Result := 0;
  if ValidFrameCount = 0 then
    Result := 0
  else
  begin
    if (Self is TGIFImage) then
    begin
      for I := 0 to (Self as TGIFImage).Images.Count - 1 do
        if not(Self as TGIFImage).Images[I].Empty then
        begin
          Result := I;
          Break;
        end;
    end else if (Self is TAnimatedJPEG) then
    begin
      Result := 0;
    end;
  end;
end;

function TAnimationHelper.GetNextFrameNumber(CurrentFrameNumber: Integer): Integer;
var
  Im: TGIFImage;
begin
  if CurrentFrameNumber = -1 then
    Exit(GetFirstFrameNumber);

  Result := 0;
  if ValidFrameCount = 0 then
    Result := 0
  else
  begin
    if (Self is TGIFImage) then
    begin
      Im := (Self as TGIFImage);
      Result := CurrentFrameNumber;
      Inc(Result);
      if Result >= Im.Images.Count then
        Result := 0;

      if Im.Images[Result].Empty then
        Result := GetNextFrameNumber(Result);
    end else if (Self is TAnimatedJPEG) then
    begin
      //onle 2 slides
      Result := IIF(CurrentFrameNumber = 1, 0, 1);
    end;
  end;
end;

function TAnimationHelper.GetPreviousFrameNumber(CurrentFrameNumber: Integer): Integer;
var
  Im: TGIFImage;
begin
  Result := 0;
  if ValidFrameCount = 0 then
    Result := 0
  else
  begin
    if (Self is TGIFImage) then
    begin
      Im := (Self as TGIFImage);
      Result := CurrentFrameNumber;
      Dec(Result);
      if Result < 0 then
        Result := Im.Images.Count - 1;

      if Im.Images[Result].Empty then
        Result := GetPreviousFrameNumber(Result);
    end else if (Self is TAnimatedJPEG) then
    begin
      //onle 2 slides
      Result := IIF(CurrentFrameNumber = 1, 0, 1);
    end;
  end;
end;

function TAnimationHelper.IsTransparentAnimation: Boolean;
var
  I: Integer;
  Gif: TGifImage;
begin
  Result := False;
  if Self is TGIFImage then
  begin
    Gif := (Self as TGIFImage);
    for I := 0 to Gif.Images.Count - 1 do
      if Gif.Images[I].Transparent then
        Exit(True);
  end;
end;

function TAnimationHelper.ValidFrameCount: Integer;
var
  I: Integer;
  Gif: TGifImage;
begin
  Result := 0;
  if Self is TGIFImage then
  begin
    Gif := (Self as TGIFImage);
    for I := 0 to Gif.Images.Count - 1 do
    begin
      if not Gif.Images[I].Empty then
        Inc(Result);
    end;
  end else if Self is TAnimatedJPEG then
    Result := TAnimatedJPEG(Self).Count;
end;

procedure TAnimationHelper.ProcessNextFrame(AnimatedBuffer: TBitmap; var CurrentFrameNumber: Integer;
  BackgrondColor: TColor; Timer: TTimer; DrawCallBack: TDrawProcedure);
var
  C, PreviousNumber: Integer;
  R, Bounds_: TRect;
  Im: TGifImage;
  DisposalMethod: TDisposalMethod;
  Del, Delta: Integer;
  TimerEnabled: Boolean;
  Gsi: TGIFSubImage;
  TickCountStart: Cardinal;
begin
  TickCountStart := GetTickCount;
  Del := 100;
  TimerEnabled := False;

  CurrentFrameNumber := Self.GetNextFrameNumber(CurrentFrameNumber);

  if Self is TGIFImage then
  begin
    Im := Self as TGIFImage;
    R := Im.Images[CurrentFrameNumber].BoundsRect;

    TimerEnabled := False;
    PreviousNumber := Self.GetPreviousFrameNumber(CurrentFrameNumber);
    if (Im.Animate) and (Im.Images.Count > 1) then
    begin
      Gsi := Im.Images[CurrentFrameNumber];
      if Gsi.Empty then
        Exit;
      if Im.Images[PreviousNumber].Empty then
        DisposalMethod := DmNone
      else begin
        if Im.Images[PreviousNumber].GraphicControlExtension <> nil then
          DisposalMethod := Im.Images[PreviousNumber].GraphicControlExtension.Disposal
        else
          DisposalMethod := DmNone;
      end;

      if Im.Images[CurrentFrameNumber].GraphicControlExtension <> nil then
        Del := Im.Images[CurrentFrameNumber].GraphicControlExtension.Delay * 10;
      if Del = 10 then
        Del := 100;
      if Del = 0 then
        Del := 100;
      TimerEnabled := True;
    end else
      DisposalMethod := DmNone;

    if (DisposalMethod = DmBackground) then
    begin
      Bounds_ := Im.Images[PreviousNumber].BoundsRect;
      AnimatedBuffer.Canvas.Pen.Color := BackgrondColor;
      AnimatedBuffer.Canvas.Brush.Color := BackgrondColor;
      AnimatedBuffer.Canvas.Rectangle(Bounds_);
    end;

    if DisposalMethod = DmPrevious then
    begin
      C := CurrentFrameNumber;
      Dec(C);
      if C < 0 then
        C := Im.Images.Count - 1;
      Im.Images[C].StretchDraw(AnimatedBuffer.Canvas, R, Im.Images[CurrentFrameNumber].Transparent, False);
    end;
    Im.Images[CurrentFrameNumber].StretchDraw(AnimatedBuffer.Canvas, R, Im.Images[CurrentFrameNumber].Transparent, False);

  end else if Self is TAnimatedJPEG then
  begin
    TimerEnabled := True;
    AnimatedBuffer.Assign(TAnimatedJPEG(Self).Images[CurrentFrameNumber]);
    Del := Animation3DDelay;
  end;

  DrawCallBack;

  Timer.Enabled := False;
  Delta := Integer(GetTickCount - TickCountStart);
  Timer.Interval := Max(Del div 2, Del - Delta);
  Timer.Enabled := TimerEnabled;
end;

end.
