unit uListViewUtils;

interface

uses
  Windows, Classes, Graphics, SysUtils, EasyListview, CommCtrl, ComCtrls;

function ItemByPointImage(EasyListview: TEasyListview; ViewportPoint: TPoint; ListView : Integer = 0): TEasyItem;
procedure ItemRectArray(Item: TEasyItem; tmHeight : integer; var RectArray: TEasyRectArrayObject; ListView : Integer = 0);
function ItemByPointStar(EasyListview: TEasyListview; ViewportPoint: TPoint; PictureSize : Integer): TEasyItem;
function GetListViewHeaderHeight(ListView: TListView): Integer;

implementation

function GetListViewHeaderHeight(ListView: TListView): Integer;
var
  Header_Handle: HWND;
  WindowPlacement: TWindowPlacement;
begin
  Header_Handle := ListView_GetHeader(ListView.Handle);
  FillChar(WindowPlacement, SizeOf(WindowPlacement), 0);
  WindowPlacement.Length := SizeOf(WindowPlacement);
  GetWindowPlacement(Header_Handle, @WindowPlacement);
  Result  := WindowPlacement.rcNormalPosition.Bottom -
    WindowPlacement.rcNormalPosition.Top;
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

function ItemByPointStar(EasyListview: TEasyListview; ViewportPoint: TPoint; PictureSize : Integer): TEasyItem;
var
  i: Integer;
  r : TRect;
  RectArray: TEasyRectArrayObject;
  t,l, a,b : integer;
begin
  Result := nil;
  i := 0;
  r :=  EasyListview.Scrollbars.ViewableViewportRect;
  ViewportPoint.X:=ViewportPoint.X+r.Left;
  ViewportPoint.Y:=ViewportPoint.Y+r.Top;
  while not Assigned(Result) and (i < EasyListview.Items.Count) do
  begin
   if EasyListview.Items[i].Visible then
   begin
      EasyListview.Items[i].ItemRectArray(EasyListview.Header.FirstColumn, EasyListview.Canvas, RectArray);
      a:=EasyListview.CellSizes.Thumbnail.Width - 35;
      b:=0;
      t:=RectArray.IconRect.Top;
      l:=RectArray.IconRect.Left;
      r:=Rect(a+l,b+t,a+22+l,b+t+18);
      if PtInRect(r, ViewportPoint) then
       Result := EasyListview.Items[i];
   end;
   Inc(i)
  end
end;

end.
