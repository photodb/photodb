unit uListViewUtils;

interface

uses
  Windows, Graphics, SysUtils, EasyListview;

function ItemByPointImage(EasyListview: TEasyListview; ViewportPoint: TPoint; ListView : Integer = 0): TEasyItem;
procedure ItemRectArray(Item: TEasyItem; tmHeight : integer; var RectArray: TEasyRectArrayObject; ListView : Integer = 0);

implementation

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
        RectArray.BoundsRect := Item.DisplayRect;    
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
  i: Integer;
  r : TRect;
  RectArray: TEasyRectArrayObject;
  aCanvas : TCanvas;
  Metrics: TTextMetric;
begin
  Result := nil;
  i := 0;
  r :=  EasyListview.Scrollbars.ViewableViewportRect;
  ViewportPoint.X:=ViewportPoint.X+r.Left;
  ViewportPoint.Y:=ViewportPoint.Y+r.Top;
  aCanvas:=EasyListview.Canvas;
  GetTextMetrics(aCanvas.Handle, Metrics);

  while not Assigned(Result) and (i < EasyListview.Items.Count) do
  begin
     ItemRectArray(EasyListview.Items[i],Metrics.tmHeight,RectArray);

     if ListView = 0 then
     begin
      if PtInRect(RectArray.IconRect, ViewportPoint) then
       Result := EasyListview.Items[i] else
      if PtInRect(RectArray.TextRect, ViewportPoint) then
       Result := EasyListview.Items[i];
    end else
      if PtInRect(RectArray.BoundsRect, ViewportPoint) then
       Result := EasyListview.Items[i];

    Inc(i);
  end
end;

end.
