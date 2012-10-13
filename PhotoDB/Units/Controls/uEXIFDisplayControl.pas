unit uEXIFDisplayControl;

interface

uses
  Winapi.Windows,
  System.Classes,
  Vcl.Themes,
  Vcl.Grids,
  Vcl.ValEdit;

type
  TEXIFDisplayControl = class(TValueListEditor)
  private
    procedure CalcRowHeight(Row: Integer);
  protected
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect;
      AState: TGridDrawState); override;
    procedure Resize; override;
    procedure ColWidthsChanged; override;
  public
    procedure UpdateRowsHeight;
  end;

implementation

type
  TValueListStringsEx = class(TValueListStrings);

procedure TEXIFDisplayControl.DrawCell(ACol, ARow: Integer; ARect: TRect;
  AState: TGridDrawState);
var
  Offset: Integer;
  CellText: string;
  ItemProp: TItemProp;
  CRect, DrawRect: TRect;
begin
  if DefaultDrawing then
  begin
    if (ACol = 0) and (ARow > FixedRows - 1) then
      ItemProp := TValueListStringsEx(Strings).FindItemProp(ARow - FixedRows, False)
    else
      ItemProp := nil;
    if (ItemProp <> nil) and (ItemProp.KeyDesc <> '') then
      CellText := ItemProp.KeyDesc
    else
      CellText := Cells[ACol, ARow];
    if StyleServices.Enabled then
      Offset := 4
    else
      Offset := 2;

    CRect := CellRect(ACol, ARow);
    DrawRect := Rect(ARect.Left + Offset, ARect.Top + 2, CRect.Right, CRect.Bottom);

    DrawText(Canvas.Handle,
              PChar(CellText), Length(CellText), DrawRect,
              DT_WORDBREAK or DT_PLOTTER or DT_NOPREFIX);
  end;
end;

procedure TEXIFDisplayControl.Resize;
begin
  inherited;
  UpdateRowsHeight;
end;

procedure TEXIFDisplayControl.UpdateRowsHeight;
var
  I: Integer;
begin
  for I := 1 to RowCount - 1 do
    CalcRowHeight(I);
end;

procedure TEXIFDisplayControl.ColWidthsChanged;
begin
  inherited;
  UpdateRowsHeight;
end;

procedure TEXIFDisplayControl.CalcRowHeight(Row: Integer);
var
  J: Integer;
  RowHeight, Offset: Integer;
  S: string;
  CRect, DrawRect: TRect;
begin
  RowHeight := DefaultRowHeight;
  for J := 0 to 1 do
  begin
    S := Cells[J, Row];

    if StyleServices.Enabled then
      Offset := 4
    else
      Offset := 2;

    CRect := CellRect(J, Row);
    DrawRect := Rect(CRect.Left + Offset, CRect.Top + 2, CRect.Right, CRect.Bottom);
    DrawText(Canvas.Handle,
              PChar(S), Length(S), DrawRect,
              DT_WORDBREAK or DT_LEFT or DT_NOPREFIX or DT_CALCRECT );

    if DrawRect.Height > RowHeight then
      RowHeight := DrawRect.Height + 2 * 2;
  end;
  RowHeights[Row] := RowHeight;
end;

end.
