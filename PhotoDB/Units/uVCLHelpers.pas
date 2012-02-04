unit uVCLHelpers;

interface

uses
  ExtCtrls,
  Windows,
  Classes,
  FOrms,
  Controls,
  Graphics,
  StdCtrls;

type
  TTimerHelper = class helper for TTimer
  public
    procedure Restart;
  end;

type
  TButtonHelper = class helper for TButton
  public
    procedure AdjustButtonWidth;
  end;

type
  TNotifyEventRef = reference to procedure(Sender: TObject);
  TKeyEventRef = reference to procedure(Sender: TObject; var Key: Word; Shift: TShiftState);
  TMessageEventRef = reference to procedure(var Msg: TMsg; var Handled: Boolean);

function MakeNotifyEvent(const ANotifyRef: TNotifyEventRef): TNotifyEvent;
function MakeKeyEvent(const ANotifyRef: TKeyEventRef): TKeyEvent;
function MakMessageEvent(const ANotifyRef: TMessageEventRef): TMessageEvent;

implementation

procedure MethRefToMethPtr(const MethRef; var MethPtr);
type
  TVtable = array[0..3] of Pointer;
  PVtable = ^TVtable;
  PPVtable = ^PVtable;
begin
  // 3 is offset of Invoke, after QI, AddRef, Release
  TMethod(MethPtr).Code := PPVtable(MethRef)^^[3];
  TMethod(MethPtr).Data := Pointer(MethRef);
end;

function MakeNotifyEvent(const ANotifyRef: TNotifyEventRef): TNotifyEvent;
begin
  MethRefToMethPtr(ANotifyRef, Result);
end;

function MakeKeyEvent(const ANotifyRef: TKeyEventRef): TKeyEvent;
begin
  MethRefToMethPtr(ANotifyRef, Result);
end;

function MakMessageEvent(const ANotifyRef: TMessageEventRef): TMessageEvent;
begin
  MethRefToMethPtr(ANotifyRef, Result);
end;

procedure TButtonHelper.AdjustButtonWidth;
var
  TextSize: TSize;
  ADC: HDC;
begin
  aDC := GetDC(Handle);
  try
    SelectObject(ADC, Font.Handle);
    GetTextExtentPoint32(ADC, PChar(Caption), Length(Caption), TextSize);
    Width := TextSize.Cx + 10;
  finally
    ReleaseDc(Handle, ADC);
  end;
end;

{ TTimerHelper }

procedure TTimerHelper.Restart;
begin
  Enabled := False;
  Enabled := True;
end;

end.
