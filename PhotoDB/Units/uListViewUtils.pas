unit uListViewUtils;

interface

uses
  Windows, Classes, Controls, Graphics, SysUtils, EasyListview, CommCtrl, ComCtrls, Math,
  UnitDBCommon, Dolphin_DB;

type
  TEasyCollectionItemX = class(TEasyCollectionItem)
  public
    function GetDisplayRect : TRect;
  end;

function ItemByPointImage(EasyListview: TEasyListview; ViewportPoint: TPoint; ListView : Integer = 0): TEasyItem;
procedure ItemRectArray(Item: TEasyItem; tmHeight : integer; var RectArray: TEasyRectArrayObject; ListView : Integer = 0);
function ItemByPointStar(EasyListview: TEasyListview; ViewportPoint: TPoint; PictureSize : Integer; Image : TGraphic): TEasyItem;
function GetListViewHeaderHeight(ListView: TListView): Integer;
procedure SetLVThumbnailSize(ListView : TEasyListView; ImageSize : Integer);
procedure SetLVSelection(ListView : TEasyListView);

implementation

procedure SetLVSelection(ListView : TEasyListView);
begin
  ListView.Selection.MouseButton := [];
  ListView.Selection.AlphaBlend := True;
  ListView.Selection.AlphaBlendSelRect := True;
  ListView.Selection.MultiSelect := True;
  ListView.Selection.RectSelect := True;
  ListView.Selection.EnableDragSelect := True;
  ListView.Selection.FullItemPaint := True;
  ListView.Selection.Gradient := True;
  ListView.Selection.GradientColorBottom := clGradientActiveCaption;
  ListView.Selection.GradientColorTop := clGradientInactiveCaption;
  ListView.Selection.RoundRect := True;
  ListView.Selection.UseFocusRect := False;
  ListView.Selection.TextColor := Theme_ListFontColor;
  ListView.PaintInfoItem.ShowBorder := False;
  ListView.HotTrack.Cursor := CrArrow;
end;

procedure SetLVThumbnailSize(ListView : TEasyListView; ImageSize : Integer);
const
  LVWidthBetweenItems = 20;
var
  CountOfItemsX, ThWidth, AddSize : Integer;
  CellWidth : Integer;
begin
  ThWidth := ImageSize + 10 + 6;
  CountOfItemsX := Max(1, Trunc((ListView.Width - LVWidthBetweenItems) / ThWidth));
  AddSize := ListView.Width - LVWidthBetweenItems - ThWidth * CountOfItemsX;

  ListView.CellSizes.Thumbnail.Width := ThWidth + AddSize div CountOfItemsX;
  ListView.CellSizes.Thumbnail.Height := ImageSize + 40;
  ListView.Selection.RoundRectRadius := ImageSize div 10;
end;

function GetListViewHeaderHeight(ListView: TListView): Integer;
var
  Header_Handle: HWND;
  WindowPlacement: TWindowPlacement;
begin
  Header_Handle := ListView_GetHeader(ListView.Handle);
  FillChar(WindowPlacement, SizeOf(WindowPlacement), 0);
  WindowPlacement.Length := SizeOf(WindowPlacement);
  GetWindowPlacement(Header_Handle, @WindowPlacement);
  Result  := WindowPlacement.rcNormalPosition.Bottom - WindowPlacement.rcNormalPosition.Top;
end;

procedure ItemRectArray(Item: TEasyItem; tmHeight : integer; var RectArray: TEasyRectArrayObject; ListView : Integer = 0);
var
  PositionIndex: Integer;
begin
  if Assigned(Item) then
  begin
    if not Item.Initialized then
      Item.Initialized := True;
      PositionIndex := 0;

    if PositionIndex > -1 then
    begin
      FillChar(RectArray, SizeOf(RectArray), #0);
      try
        RectArray.BoundsRect := TEasyCollectionItemX(Item).GetDisplayRect;
        if ListView = 0 then
          InflateRect(RectArray.BoundsRect, -Item.Border, -Item.Border);

        // Calcuate the Bounds of the Cell that is allowed to be drawn in
        // **********
        RectArray.IconRect := RectArray.BoundsRect;
        RectArray.IconRect.Bottom := RectArray.IconRect.Bottom - tmHeight * 2;

        // Calculate area that the Checkbox may be drawn
        RectArray.CheckRect.Top := RectArray.IconRect.Bottom;
        RectArray.CheckRect.Left := RectArray.BoundsRect.Left;
        RectArray.CheckRect.Bottom := RectArray.BoundsRect.Bottom;
        RectArray.CheckRect.Right := RectArray.CheckRect.Left;

        // Calcuate the Bounds of the Cell that is allowed to be drawn in
        // **********
        RectArray.LabelRect.Left := RectArray.CheckRect.Right + Item.CaptionIndent;
        RectArray.LabelRect.Top := RectArray.IconRect.Bottom + 1;
        RectArray.LabelRect.Right := RectArray.BoundsRect.Right;
        RectArray.LabelRect.Bottom := RectArray.BoundsRect.Bottom;

        // Calcuate the Text rectangle based on the current text
        // **********
        RectArray.TextRect := RectArray.LabelRect;
        // Leave room for a small border between edge of the selection rect and text
        if ListView = 0 then
          InflateRect(RectArray.TextRect, -2, -2);

      finally
      end;
    end
  end
end;

function ItemByPointImage(EasyListview: TEasyListview; ViewportPoint: TPoint; ListView : Integer = 0): TEasyItem;
var
  I: Integer;
  R: TRect;
  RectArray: TEasyRectArrayObject;
  ACanvas: TCanvas;
  Metrics: TTextMetric;
begin
  Result := nil;
  I := 0;
  R := EasyListview.Scrollbars.ViewableViewportRect;
  ViewportPoint.X := ViewportPoint.X + R.Left;
  ViewportPoint.Y := ViewportPoint.Y + R.Top;
  ACanvas := EasyListview.Canvas;
  GetTextMetrics(ACanvas.Handle, Metrics);

  while not Assigned(Result) and (I < EasyListview.Items.Count) do
  begin
    ItemRectArray(EasyListview.Items[I], Metrics.TmHeight, RectArray);

    if ListView = 0 then
    begin
      if PtInRect(RectArray.IconRect, ViewportPoint) then
        Result := EasyListview.Items[I]
      else if PtInRect(RectArray.TextRect, ViewportPoint) then
        Result := EasyListview.Items[I];
    end
    else if PtInRect(RectArray.BoundsRect, ViewportPoint) then
      Result := EasyListview.Items[I];

    Inc(I);
  end
end;

function ItemByPointStar(EasyListview: TEasyListview; ViewportPoint: TPoint; PictureSize : Integer; Image : TGraphic): TEasyItem;
var
  I: Integer;
  R: TRect;
  RectArray: TEasyRectArrayObject;
  T, L, A, B, W, H, Y: Integer;
  ImageW, ImageH : Integer;
begin
  Result := nil;
  I := 0;
  R := EasyListview.Scrollbars.ViewableViewportRect;
  ViewportPoint.X := ViewportPoint.X + R.Left;
  ViewportPoint.Y := ViewportPoint.Y + R.Top;
  while not Assigned(Result) and (I < EasyListview.Items.Count) do
  begin
    if EasyListview.Items[I].Visible then
    begin
      EasyListview.Items[I].ItemRectArray(EasyListview.Header.FirstColumn, EasyListview.Canvas, RectArray);
      A := EasyListview.CellSizes.Thumbnail.Width - 35;
      B := 0;

      W := RectArray.IconRect.Right - RectArray.IconRect.Left;
      H := RectArray.IconRect.Bottom - RectArray.IconRect.Top;
      ImageW := Image.Width;
      ImageH := Image.Height;
      ProportionalSize(W, H, ImageW, ImageH);
      Y := RectArray.IconRect.Bottom - ImageH;

      T := Max(RectArray.IconRect.Top, Y - 20);
      L := RectArray.IconRect.Left;
      R := Rect(A + L, B + T, A + 22 + L, B + T + 18);
      if PtInRect(R, ViewportPoint) then
        Result := EasyListview.Items[I];
    end;
    Inc(I)
  end
end;

{ TEasyCollectionItemX }

function TEasyCollectionItemX.GetDisplayRect: TRect;
begin
  Result := DisplayRect;
end;

end.
