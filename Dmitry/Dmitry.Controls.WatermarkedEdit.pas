unit Dmitry.Controls.WatermarkedEdit;

interface

uses
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Graphics,
  Vcl.Themes;

type
  TWatermarkedEdit = class(TEdit)
  private
    { Private declarations }
    FWatermarkText: string;
    FText: string;
    FInnerMouse: Boolean;
    procedure SetWatermarkText(const Value: string);
  protected
    { Protected declarations }
    procedure WndProc(var Message: TMessage); override;
    procedure CMMouseLeave(var Message: TWMNoParams); message CM_MOUSELEAVE;
    procedure CMMouseEnter(var Message: TWMNoParams); message CM_MOUSEENTER;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure WmSetFocus(var Message: TMessage); message WM_SETFOCUS;
    procedure WmKillFocus(var Message: TMessage); message WM_KILLFOCUS;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  published
    { Published declarations }
    property WatermarkText: string read FWatermarkText write SetWatermarkText;
    property Text;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Dm', [TWatermarkedEdit]);
end;

function ColorDiv2(Color1, Color2: TColor): TColor;
begin
  Result := RGB((GetRValue(Color1) + GetRValue(Color2)) div 2,
    (GetGValue(Color1) + GetGValue(Color2)) div 2,
    (GetBValue(Color1) + GetBValue(Color2)) div 2);
end;

{ TWatermarkedEdit }

procedure TWatermarkedEdit.CMMouseEnter(var Message: TWMNoParams);
begin
  FInnerMouse := True;
  inherited;
end;

procedure TWatermarkedEdit.CMMouseLeave(var Message: TWMNoParams);
begin
  FInnerMouse := False;
  inherited;
end;

procedure TWatermarkedEdit.CMTextChanged(var Message: TMessage);
begin
  FText := Text;
  inherited;
end;

constructor TWatermarkedEdit.Create(AOwner: TComponent);
begin
  inherited;
  FInnerMouse := False;
end;

procedure TWatermarkedEdit.SetWatermarkText(const Value: string);
begin
  FWatermarkText := Value;
  if HandleAllocated and not (csReadingState in ControlState) then
    Invalidate;
end;

procedure TWatermarkedEdit.WmKillFocus(var Message: TMessage);
begin
  PostMessage(Handle, WM_PAINT, 0, 0);
  inherited;
end;

procedure TWatermarkedEdit.WmSetFocus(var Message: TMessage);
begin
  PostMessage(Handle, WM_PAINT, 0, 0);
  inherited;
end;

procedure TWatermarkedEdit.WndProc(var Message: TMessage);
var
  RcItem: TRect;
  DC: HDC;
  TC, C, FC: TColor;
  PS: TPaintStruct;
  Hf, OldFont: HFont;
  BrushInfo: TagLOGBRUSH;
  Brush: HBrush;
begin
  if {not Focused and} (Message.Msg <> WM_GETTEXT) and Visible and (FText = '') then
  begin
    if (Message.Msg = WM_PAINT) or (Message.Msg = WM_ERASEBKGND) then
    begin
      rcItem := Rect(1, 1, Width, Height);
      DC := BeginPaint(Handle, PS);
      if DC = 0 then
        Exit;
      try

        if StyleServices.Enabled and not (Color <> clWindow) then
        begin
          C := StyleServices.GetStyleColor(scEdit);
          FC := StyleServices.GetStyleFontColor(sfEditBoxTextNormal);
        end else
        begin
          C := Color;
          FC := Font.Color;
        end;

        TC := ColorDiv2(ColorToRGB(C), ColorToRGB(FC));
        if not Enabled then
          TC := ColorDiv2(ColorToRGB(C), ColorToRGB(TC));
        
        SetTextColor(DC, TC);

        brushInfo.lbStyle := BS_SOLID;
        brushInfo.lbColor := ColorToRGB(C);
        Brush := CreateBrushIndirect(brushInfo);
        FillRect(DC, Rect(0, 0, Width, Height), Brush);

        hf := CreateFont(Font.Height, 0,
                         0,0,
                         FW_NORMAL,
                         0,
                         0,
                         0,
                         DEFAULT_CHARSET,
                         OUT_TT_ONLY_PRECIS,
                         CLIP_DEFAULT_PRECIS,
                         ANTIALIASED_QUALITY,
                         FF_DONTCARE or DEFAULT_PITCH,
                         PChar(Font.Name));

        oldFont := SelectObject(DC, hf);
        SetBkColor(DC, ColorToRGB(C));
        DrawText(DC, PChar(FWatermarkText), Length(FWatermarkText), rcItem, DT_TOP);
        SelectObject(DC, oldFont);
        if(hf > 0) then
          DeleteObject(hf);

        if(Brush > 0) then
          DeleteObject(Brush);

      finally
        EndPaint(Handle, PS);
      end;
      Exit;
    end
  end;
  if (Message.Msg = WM_KEYDOWN) then
    PostMessage(Handle, CM_TEXTCHANGED, 0, 0);
  inherited;
end;

end.
