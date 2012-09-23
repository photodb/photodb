unit uImageZoomHelper;

interface

uses
  System.Math,
  System.Classes,
  Winapi.Windows,
  Vcl.StdCtrls,
  Vcl.ExtCtrls;

type
  TImageZoomHelper = class
    class procedure ReAlignScrolls(IsCenter: Boolean;
      FHorizontalScrollBar, FVerticalScrollBar: TScrollBar; Block: TPanel; ImageSize, ClientSize: TSize;
      Zoom: Double; ZoomerOn: Boolean);
    class function GetImageVisibleRect(FHorizontalScrollBar, FVerticalScrollBar: TScrollBar;
                                       ImageSize, ClientSize: TSize; Zoom: Double): TRect;
  end;

implementation

class procedure TImageZoomHelper.ReAlignScrolls(IsCenter: Boolean;
  FHorizontalScrollBar, FVerticalScrollBar: TScrollBar; Block: TPanel; ImageSize, ClientSize: TSize;
  Zoom: Double; ZoomerOn: Boolean);
var
  Inc_: Integer;
  Pos, M, Ps: Integer;
  V1, V2: Boolean;
begin
  if Block <> nil then
    Block.Visible := False;

  if not ZoomerOn then
  begin
    FHorizontalScrollBar.Position := 0;
    FHorizontalScrollBar.Visible := False;
    FVerticalScrollBar.Position := 0;
    FVerticalScrollBar.Visible := False;
    Exit;
  end;
  V1 := FHorizontalScrollBar.Visible;
  V2 := FVerticalScrollBar.Visible;
  if not FHorizontalScrollBar.Visible and not FVerticalScrollBar.Visible then
  begin
    FHorizontalScrollBar.Visible := ImageSize.cx * Zoom > ClientSize.cx;
    if FHorizontalScrollBar.Visible then
      Inc_ := FHorizontalScrollBar.Height
    else
      Inc_ := 0;
    FVerticalScrollBar.Visible := ImageSize.cy * Zoom > ClientSize.cy - Inc_;
  end;
  begin
    if FVerticalScrollBar.Visible then
      Inc_ := FVerticalScrollBar.Width
    else
      Inc_ := 0;
    FHorizontalScrollBar.Visible := ImageSize.cx * Zoom > ClientSize.cx - Inc_;
    FHorizontalScrollBar.Width := ClientSize.cx - Inc_;
    if FHorizontalScrollBar.Visible then
      Inc_ := FHorizontalScrollBar.Height
    else
      Inc_ := 0;
    FHorizontalScrollBar.Top := ClientSize.cy - Inc_;
  end;
  begin
    if FHorizontalScrollBar.Visible then
      Inc_ := FHorizontalScrollBar.Height
    else
      Inc_ := 0;
    FVerticalScrollBar.Visible := ImageSize.cy * Zoom > ClientSize.cy - Inc_;
    FVerticalScrollBar.Height := ClientSize.cy - Inc_;
    if FVerticalScrollBar.Visible then
      Inc_ := FVerticalScrollBar.Width
    else
      Inc_ := 0;
    FVerticalScrollBar.Left := ClientSize.cx - Inc_;
  end;
  begin
    if FVerticalScrollBar.Visible then
      Inc_ := FVerticalScrollBar.Width
    else
      Inc_ := 0;
    FHorizontalScrollBar.Visible := ImageSize.cx * Zoom > ClientSize.cx - Inc_;
    FHorizontalScrollBar.Width := ClientSize.cx - Inc_;
    if FHorizontalScrollBar.Visible then
      Inc_ := FHorizontalScrollBar.Height
    else
      Inc_ := 0;
    FHorizontalScrollBar.Top := ClientSize.cy - Inc_;
  end;
  if not FHorizontalScrollBar.Visible then
    FHorizontalScrollBar.Position := 0;
  if not FVerticalScrollBar.Visible then
    FVerticalScrollBar.Position := 0;
  if FHorizontalScrollBar.Visible and not V1 then
  begin
    FHorizontalScrollBar.PageSize := 0;
    FHorizontalScrollBar.Position := 0;
    FHorizontalScrollBar.Max := 100;
    FHorizontalScrollBar.Position := 50;
  end;
  if FVerticalScrollBar.Visible and not V2 then
  begin
    FVerticalScrollBar.PageSize := 0;
    FVerticalScrollBar.Position := 0;
    FVerticalScrollBar.Max := 100;
    FVerticalScrollBar.Position := 50;
  end;

  if Block <> nil then
  begin
    Block.Width := FVerticalScrollBar.Width;
    Block.Height := FHorizontalScrollBar.Height;
    Block.Left := ClientSize.cx - Block.Width;
    Block.Top := ClientSize.cy - Block.Height;
    Block.Visible := FHorizontalScrollBar.Visible and FVerticalScrollBar.Visible;
  end;

  if FHorizontalScrollBar.Visible then
  begin
    if FVerticalScrollBar.Visible then
      Inc_ := FVerticalScrollBar.Width
    else
      Inc_ := 0;
    M := Round(ImageSize.cx * Zoom);
    Ps := ClientSize.cx - Inc_;
    if Ps > M then
      Ps := 0;
    if (FHorizontalScrollBar.Max <> FHorizontalScrollBar.PageSize) then
      Pos := Round(FHorizontalScrollBar.Position * ((M - Ps) / (FHorizontalScrollBar.Max - FHorizontalScrollBar.PageSize)))
    else
      Pos := FHorizontalScrollBar.Position;
    if M < FHorizontalScrollBar.PageSize then
      FHorizontalScrollBar.PageSize := Ps;
    FHorizontalScrollBar.Max := M;
    FHorizontalScrollBar.PageSize := Ps;
    FHorizontalScrollBar.LargeChange := Ps div 10;
    FHorizontalScrollBar.Position := Min(FHorizontalScrollBar.Max, Pos);
  end;
  if FVerticalScrollBar.Visible then
  begin
    if FHorizontalScrollBar.Visible then
      Inc_ := FHorizontalScrollBar.Height
    else
      Inc_ := 0;
    M := Round(ImageSize.cy * Zoom);
    Ps := ClientSize.cy - Inc_;
    if Ps > M then
      Ps := 0;
    if FVerticalScrollBar.Max <> FVerticalScrollBar.PageSize then
      Pos := Round(FVerticalScrollBar.Position * ((M - Ps) / (FVerticalScrollBar.Max - FVerticalScrollBar.PageSize)))
    else
      Pos := FVerticalScrollBar.Position;
    if M < FVerticalScrollBar.PageSize then
      FVerticalScrollBar.PageSize := Ps;
    FVerticalScrollBar.Max := M;
    FVerticalScrollBar.PageSize := Ps;
    FVerticalScrollBar.LargeChange := Ps div 10;
    FVerticalScrollBar.Position := Min(FVerticalScrollBar.Max, Pos);
  end;
  if FHorizontalScrollBar.Position > FHorizontalScrollBar.Max - FHorizontalScrollBar.PageSize then
    FHorizontalScrollBar.Position := FHorizontalScrollBar.Max - FHorizontalScrollBar.PageSize;
  if FVerticalScrollBar.Position > FVerticalScrollBar.Max - FVerticalScrollBar.PageSize then
    FVerticalScrollBar.Position := FVerticalScrollBar.Max - FVerticalScrollBar.PageSize;
end;

class function TImageZoomHelper.GetImageVisibleRect(FHorizontalScrollBar, FVerticalScrollBar: TScrollBar;
                                                    ImageSize, ClientSize: TSize; Zoom: Double): TRect;
var
  Increment: Integer;
  FX, FY, FH, FW: Integer;
begin
  if FHorizontalScrollBar.Visible then
  begin
    FX := 0;
  end else
  begin
    if FVerticalScrollBar.Visible then
      Increment := FVerticalScrollBar.width
    else
      Increment := 0;
    FX := Max(0, Round(ClientSize.cx / 2 - Increment - ImageSize.cx * Zoom / 2));
  end;
  if FVerticalScrollBar.Visible then
  begin
    FY := 0;
  end else
  begin
    if FHorizontalScrollBar.Visible then
      Increment := FHorizontalScrollBar.Height
    else
      Increment := 0;
    FY := Max(0,
      Round(ClientSize.cy / 2 - Increment - ImageSize.cy * Zoom / 2));
  end;
  if FVerticalScrollBar.Visible then
    Increment := FVerticalScrollBar.width
  else
    Increment := 0;
  FW := Round(Min(ClientSize.cx - Increment, ImageSize.cx * Zoom));
  if FHorizontalScrollBar.Visible then
    Increment := FHorizontalScrollBar.Height
  else
    Increment := 0;
  FH := Round(Min(ClientSize.cy - Increment, ImageSize.cy * Zoom));
  FH := FH;

  Result := Rect(FX, FY, FW + FX, FH + FY);
end;

end.
