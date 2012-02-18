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
  TComboBoxHelper = class helper for TComboBox
  private
    function GetValue: string;
    procedure SetValue(const Value: string);
  public
    property Value: string read GetValue write SetValue;
  end;

type
  TCheckBoxHelper = class helper for TCheckBox
  public
    procedure AdjustWidth;
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

{ TComboBoxHelper }

function TComboBoxHelper.GetValue: string;
begin
  Result := '';
  if ItemIndex > -1 then
    Result := Items[ItemIndex];
end;

procedure TComboBoxHelper.SetValue(const Value: string);
var
  I: Integer;
begin
  if Items.Count > 0 then
    ItemIndex := 0;
  for I := 0 to Items.Count - 1 do
    if Items[I] = Value then
    begin
      ItemIndex := I;
      Break;
    end;
end;

{ TCheckBoxHelper }

procedure TCheckBoxHelper.AdjustWidth;
var
  TextSize: TSize;
  ADC: HDC;
begin
  aDC := GetDC(Handle);
  try
    SelectObject(ADC, Font.Handle);
    GetTextExtentPoint32(ADC, PChar(Caption), Length(Caption), TextSize);
    Width := TextSize.Cx + GetSystemMetrics(SM_CXMENUCHECK) + GetSystemMetrics(SM_CXEDGE) * 2;
  finally
    ReleaseDc(Handle, ADC);
  end;
end;

end.
