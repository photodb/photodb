unit uEditorTypes;

interface

uses
  Windows, Classes, Graphics, Math, uDBForm;

type
  TSetPointerToNewImage = procedure(Image: TBitmap) of object;
  TCancelTemporaryImage = procedure(Destroy: Boolean) of object;
  TBaseEffectCallBackProc = procedure(Progress: Integer; var Break: Boolean) of object;

  TBaseEffectProc = procedure(S, D: TBitmap; CallBack: TBaseEffectCallBackProc = nil);
  TBaseEffectProcThreadExit = procedure(Image: TBitmap; SID: string) of object;

  TBaseEffectProcW = record
    Proc: TBaseEffectProc;
    name: string;
    ID: string;
  end;

  TBaseEffectProcedures = array of TBaseEffectProcW;
  TResizeProcedure = procedure(Width, Height: Integer; S, D: TBitmap; CallBack: TBaseEffectCallBackProc = nil);
  TEffectOneIntParam = procedure(S, D: TBitmap; Int: Integer; CallBack: TBaseEffectCallBackProc = nil);

type
  TTool = (ToolNone, ToolPen, ToolCrop, ToolRotate, ToolResize, ToolEffects, ToolColor, ToolRedEye, ToolText,
    ToolBrush, ToolInsertImage);

type
  TVBrushType = array of TPoint;

type
  TImageEditorForm = class(TDBForm)
  protected
    function GetZoom : Extended; virtual; abstract;
  public
    Transparency: Extended;
    VirtualBrushCursor: Boolean;
    VBrush: TVBrushType;
    property Zoom : Extended read GetZoom;
  end;

function NormalizeRect(R : TRect) : TRect;
procedure ClearBrush(var Brush : TVBrushType);
procedure MakeRadialBrush(var Brush : TVBrushType; Size : Integer);

implementation


procedure ClearBrush(var Brush : TVBrushType);
begin
  SetLength(Brush, 0);
end;

procedure MakeRadialBrush(var Brush : TVBrushType; Size : Integer);
var
  I: Integer;
  Count: Integer;
  X: Extended;
begin
  Count := Round(Size * 4 / Sqrt(2));
  SetLength(Brush, Count);
  for I := 0 to Length(Brush) - 1 do
  begin
    X := 2 * I * Pi / Count;
    Brush[I].X := Round(Size * Cos(X));
    Brush[I].Y := Round(Size * Sin(X));
  end;
end;

function NormalizeRect(R: TRect): TRect;
begin
  Result.Left := Min(R.Left, R.Right);
  Result.Right := Max(R.Left, R.Right);
  Result.Top := Min(R.Top, R.Bottom);
  Result.Bottom := Max(R.Top, R.Bottom);
end;

end.
