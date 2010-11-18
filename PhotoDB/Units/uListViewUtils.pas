unit uListViewUtils;

interface

uses
  Windows, Classes, Controls, Graphics, SysUtils, EasyListview, CommCtrl, ComCtrls, Math,
  UnitDBCommon, Dolphin_DB, UnitBitmapImageList, UnitDBCommonGraphics, uMemory,
  MPCommonUtilities, uDBDrawing, TLayered_Bitmap;

type
  TEasyCollectionItemX = class(TEasyCollectionItem)
  public
    function GetDisplayRect : TRect;
  end;

  {$HINTS OFF}
  TEasySelectionManagerX = class(TEasyOwnedPersistent)
  private
    FAlphaBlend: Boolean;
    FAlphaBlendSelRect: Boolean;
    FBlendAlphaImage: Byte;
    FBlendAlphaSelRect: Byte;
    FBlendAlphaTextRect: Byte;
    FBlendColorIcon: TColor;
    FBlendColorSelRect: TColor;
    FBlendIcon: Boolean;
    FBlurAlphaBkGnd: Boolean;
    FBorderColor: TColor;
    FBorderColorSelRect: TColor;
    FColor: TColor;
    FCount: Integer;
    FFocusedColumn: TEasyColumn;
    FFocusedItem: TEasyItem;
    FAnchorItem: TEasyItem;
    FFocusedGroup: TEasyGroup;
    FEnabled: Boolean;
    FForceDefaultBlend: Boolean;
    FFullCellPaint: Boolean;
    FFullItemPaint: Boolean;
    FFullRowSelect: Boolean;
    FGradient: Boolean;
    FGradientColorBottom: TColor;
    FGradientColorTop: TColor;
  public
    property AGradientColorBottom : TColor write FGradientColorBottom;
    property AGradientColorTop : TColor write FGradientColorTop;
  end;
  {$HINTS ON}

function ItemByPointImage(EasyListview: TEasyListview; ViewportPoint: TPoint; ListView : Integer = 0): TEasyItem;
procedure ItemRectArray(Item: TEasyItem; tmHeight : integer; var RectArray: TEasyRectArrayObject; ListView : Integer = 0);
function ItemByPointStar(EasyListview: TEasyListview; ViewportPoint: TPoint; PictureSize : Integer; Image : TGraphic): TEasyItem;
function GetListViewHeaderHeight(ListView: TListView): Integer;
procedure SetLVThumbnailSize(ListView : TEasyListView; ImageSize : Integer);
procedure SetLVSelection(ListView : TEasyListView);
procedure DrawDBListViewItem(ListView : TEasylistView; ACanvas: TCanvas; Item : TEasyItem;
                             ARect : TRect; BImageList : TBitmapImageList; var Y : Integer;
                             ShowInfo : Boolean; ID : Integer;
                             FileName : string; Rating : Integer;
                             Rotate : Integer; Access : Integer;
                             Crypted : Boolean; var Exists : Integer);

procedure CreateDragImage(ListView : TEasyListView; DImageList : TImageList; SImageList : TBitmapImageList; Caption : string;
                          DragPoint : TPoint; var SpotX, SpotY : Integer);
procedure CreateDragImageEx(ListView : TEasyListView; DImageList : TImageList; SImageList : TBitmapImageList;
  GradientFrom, GradientTo, SelectionColor : TColor; Font : TFont; Caption : string); overload;
procedure CreateDragImageEx(ListView : TEasyListView; DImageList : TImageList; SImageList : TBitmapImageList;
  GradientFrom, GradientTo, SelectionColor : TColor; Font : TFont; Caption : string;
  DragPoint : TPoint; var SpotX, SpotY : Integer); overload;
procedure EnsureSelectionInListView(EasyListview: TEasyListview; ListItem : TEasyItem;
  Shift: TShiftState; X, Y: Integer; var ItemSelectedByMouseDown : Boolean;
  var ItemByMouseDown : Boolean);
procedure RightClickFix(EasyListview: TEasyListview; Button: TMouseButton; Shift: TShiftState; Item : TEasyItem; ItemByMouseDown, ItemSelectedByMouseDown : Boolean);
procedure CreateMultiselectImage(ListView : TEasyListView; ResultImage : TBitmap; SImageList : TBitmapImageList;
  GradientFrom, GradientTo, SelectionColor : TColor; Font : TFont; Width, Height : Integer);

implementation

uses UnitPropeccedFilesSupport, UnitDBKernel;

procedure DrawDBListViewItem(ListView : TEasylistView; ACanvas: TCanvas; Item : TEasyItem;
                             ARect : TRect; BImageList : TBitmapImageList; var Y : Integer;
                             ShowInfo : Boolean; ID : Integer;
                             FileName : string; Rating : Integer;
                             Rotate : Integer; Access : Integer;
                             Crypted : Boolean; var Exists : Integer);

var
  Graphic : TGraphic;
  W, H : Integer;
  ImageW, ImageH : Integer;
  X : Integer;
  TempBmp : TBitmap;
  TempBmpShadow : TBitmap;
  CTD, CBD, DY : Integer;
  ClientRect : TRect;
  RectArray: TEasyRectArrayObject;
  ColorFrom, ColorTo : TColor;
begin
  Graphic := BImageList[Item.ImageIndex].Graphic;

  if Graphic = nil then
  begin
    Item.ImageIndex := 0;
    Exit;
  end;

  W := ARect.Right - ARect.Left;
  H := ARect.Bottom - ARect.Top;
  ImageW := Graphic.Width;
  ImageH := Graphic.Height;
  ProportionalSize(W, H, ImageW, ImageH);

  X := ARect.Left + W div 2 - ImageW div 2;
  Y := ARect.Bottom - ImageH;

  if (esosHotTracking in Item.State) then
  begin
    if (Rating = 0) and (ID <> 0) then
      Rating := -1;

    if not Item.Selected then
    begin
      Item.ItemRectArray(nil, ACanvas, RectArray);
      //HACK!
      ColorFrom := ListView.Selection.GradientColorTop;
      ColorTo := ListView.Selection.GradientColorBottom;
      TEasySelectionManagerX(ListView.Selection).AGradientColorTop := ColorDiv2(ColorDiv2(ColorDiv2(ColorFrom, ListView.Color), ListView.Color), ListView.Color);
      TEasySelectionManagerX(ListView.Selection).AGradientColorBottom := ColorDiv2(ColorDiv2(ColorDiv2(ColorTo, ListView.Color ), ListView.Color), ListView.Color);

      Item.View.PaintSelectionRect(Item, nil, Item.Caption, RectArray, ACanvas, RectArray.BoundsRect, True);

      //HACK!
      TEasySelectionManagerX(ListView.Selection).AGradientColorTop := ColorFrom;
      TEasySelectionManagerX(ListView.Selection).AGradientColorBottom := ColorTo;
    end;
  end;

  TempBmp := nil;
  TempBmpShadow := nil;
  try
  if (Graphic is TBitmap) and
      ((TBitmap(Graphic).Width > W) or (TBitmap(Graphic).Height > H)) then
    begin
      TempBmp := TBitmap.Create;
      ProportionalSizeA(W, H, ImageW, ImageH);
      StretchCool(ImageW, ImageH, TBitmap(Graphic), TempBmp);
      Graphic := TempBmp;
    end;

    if (Graphic is TBitmap) and (TBitmap(Graphic).PixelFormat = pf24Bit) then
    begin
      TempBmpShadow := TBitmap.Create;
      DrawShadowToImage(TempBmpShadow, TBitmap(Graphic));
      Graphic := TempBmpShadow;
    end;

    if (Graphic is TBitmap) and (TBitmap(Graphic).PixelFormat = pf32Bit) and HasMMX then
    begin
      ClientRect := ListView.Scrollbars.ViewableViewportRect;

      CTD := 0;
      CBD := 0;
      if Y < ClientRect.Top then
        CTD := ClientRect.Top - Y;

      DY := ClientRect.Top;

      if Y + Graphic.Height > ClientRect.Bottom then
        CBD := ClientRect.Bottom - (Y + Graphic.Height);

      if Y - DY < 0 then
        DY := Y;

      MPCommonUtilities.AlphaBlend(TBitmap(Graphic).Canvas.Handle, ACanvas.Handle,
              Rect(0, CTD, Graphic.Width, Graphic.Height + CBD), Point(X, Y - DY),
              cbmPerPixelAlpha, $FF, ColorToRGB(ListView.Color))
    end else
      ACanvas.StretchDraw(Rect(X, Y, X + ImageW, Y + ImageH), Graphic);

  finally
    F(TempBmp);
    F(TempBmpShadow);
  end;

  if ProcessedFilesCollection.ExistsFile(FileName) <> nil then
    DrawIconEx(ACanvas.Handle, X + 2, ARect.Bottom - 20, UnitDBKernel.Icons[DB_IC_RELOADING + 1], 16, 16, 0, 0, DI_NORMAL);

  if ShowInfo then
    DrawAttributesEx(ACanvas.Handle, Max(ARect.Left, ARect.Right - 100), Max(ARect.Top, Y - 16), Rating, Rotate, Access, FileName, Crypted, Exists, ID);
end;

procedure CreateDragImage(ListView : TEasyListView; DImageList : TImageList; SImageList : TBitmapImageList;
          Caption : string;
          DragPoint : TPoint; var SpotX, SpotY : Integer);
begin
  CreateDragImageEx(ListView, DImageList, SImageList,
    ListView.Selection.GradientColorBottom, ListView.Selection.GradientColorTop,
    ListView.Selection.Color, ListView.Font, Caption, DragPoint, SpotX, SpotY);
end;

procedure CreateDragImageEx(ListView : TEasyListView; DImageList : TImageList; SImageList : TBitmapImageList;
  GradientFrom, GradientTo, SelectionColor : TColor; Font : TFont; Caption : string);
var
  X, Y : Integer;
  Point : TPoint;
begin
  CreateDragImageEx(ListView, DImageList, SImageList, GradientFrom, GradientTo, SelectionColor,
    Font, Caption, Point, X, Y);
end;

procedure DrawSelectionCount(Bitmap : TBitmap; ItemsSelected : Integer; Font : TFont; RoundRadius : Integer);
var
  AFont : TFont;
  W, H : Integer;
  R : TRect;
begin
  AFont := TFont.Create;
  try
    AFont.Assign(Font);
    AFont.Style := [fsBold];
    AFont.Size := AFont.Size + 2;
    AFont.Color := clHighlightText;
    W := Bitmap.Canvas.TextWidth(IntToStr(ItemsSelected));
    H := Bitmap.Canvas.TextHeight(IntToStr(ItemsSelected));
    Inc(W, 10);
    Inc(H, 10);
    R := Rect(5, 5, 5 + W, 5 + H);
    DrawRoundGradientVert(Bitmap, R, clBlack, clHighlight, clHighlightText, RoundRadius);
    DrawText32Bit(Bitmap, IntToStr(ItemsSelected), AFont, R, DT_CENTER or DT_VCENTER);
  finally
    AFont.Free;
  end;
end;

procedure  CreateMultiselectImage(ListView : TEasyListView; ResultImage : TBitmap; SImageList : TBitmapImageList;
  GradientFrom, GradientTo, SelectionColor : TColor; Font : TFont; Width, Height : Integer);
var
  SelCount : Integer;
  SelectedItem : TEasyItem;
  Items : array of TEasyItem;
  MaxH, MaxW, I, N, FSelCount, ItemsSelected, ImageW, ImageH : Integer;
  Graphic : TGraphic;
  DX, DY, DMax : Extended;
  TmpImage,
  SelectedImage : TBitmap;
  LBitmap : TLayeredBitmap;
  FocusedItem : TEasyItem;

  function LastSelected : TEasyItem;
  var
    Item : TEasyItem;
  begin
    Result := nil;
    Item := ListView.Selection.First;
    while Item <> nil do
    begin
      Result := Item;
      Item := ListView.Selection.Next(Result);
    end;
  end;

const
  MaxItems = 5;
  ImagePadding = 10;
  RoundRadius = 8;

begin
  SetLength(Items, 0);
  if ListView <> nil then
  begin
    ItemsSelected := ListView.Selection.Count;
    FSelCount := Min(MaxItems, ItemsSelected);

    SelectedItem := ListView.Selection.First;
    FocusedItem := nil;
    if ListView.Selection.FocusedItem <> nil then
      if ListView.Selection.FocusedItem.Selected then
        FocusedItem := ListView.Selection.FocusedItem;

    if FocusedItem = nil then
      FocusedItem := LastSelected;

    for I := 1 to FSelCount do
    begin
      if FocusedItem <> SelectedItem then
      begin
        if Length(Items) = FSelCount - 1 then
          Break;

        SetLength(Items, Length(Items) + 1);
        Items[Length(Items) - 1] := SelectedItem;
      end;
      SelectedItem := ListView.Selection.Next(SelectedItem);
    end;
    SetLength(Items, Length(Items) + 1);
    Items[Length(Items) - 1] := FocusedItem;
    FSelCount := Length(Items);
  end else begin
    ItemsSelected := SImageList.Count;
    FSelCount := Min(MaxItems, ItemsSelected);
  end;

  N := 0;

  MaxH := 0;
  MaxW := 0;
  for I := 1 to FSelCount do
  begin

    if ListView <> nil then
      Graphic := SImageList[Items[I - 1].ImageIndex].Graphic
    else
      Graphic := SImageList[I - 1].Graphic;

    MaxH := Max(MaxH, N + Graphic.Height);
    MaxW := Max(MaxW, N + Graphic.Width);
  end;

  DX := MaxW / (Width - FSelCount * (ImagePadding - 1));
  DY := MaxH / (Height  - FSelCount * (ImagePadding - 1));

  ResultImage.Width := Width;
  ResultImage.Height := Height;
  FillTransparentColor(ResultImage, ClBlack, 0);

  N := 0;

  for I := 1 to FSelCount do
  begin
    if ListView <> nil then
      Graphic := SImageList[Items[I - 1].ImageIndex].Graphic
    else
      Graphic := SImageList[I - 1].Graphic;

    if Graphic is TBitmap then
    begin
      ImageW := Graphic.Width;
      ImageH := Graphic.Height;
      ProportionalSizeA(Round(ImageW / DX), Round(ImageH / DY), ImageW, ImageH);
      if TBitmap(Graphic).PixelFormat = pf24bit then
      begin
        SelectedImage := TBitmap.Create;
        try
          TmpImage := TBitmap.Create;
          try
            DoResize(ImageW, ImageH, Graphic as TBitmap, TmpImage);
            DrawShadowToImage(SelectedImage, TmpImage);
            DrawImageEx32(ResultImage, SelectedImage, N, N);
          finally
            F(TmpImage);
          end;
        finally
          F(SelectedImage);
        end;
      end else if TBitmap(Graphic).PixelFormat = pf32bit then
      begin
        TmpImage := TBitmap.Create;
        try
          DoResize(ImageW, ImageH, Graphic as TBitmap, TmpImage);
          DrawImageEx32(ResultImage, TmpImage, N, N);
        finally
          F(TmpImage);
        end;
      end;
    end else if Graphic is TIcon then
    begin
      LBitmap := TLayeredBitmap.Create;
      try
        LBitmap.LoadFromHIcon(TIcon(Graphic).Handle, TIcon(Graphic).Height, TIcon(Graphic).Width);
        InverseTransparenty(LBitmap);
        DrawImageEx32(ResultImage, LBitmap, N, N);
      finally
        F(LBitmap);
      end;
    end;
    Inc(N, ImagePadding);
  end;

  DrawSelectionCount(ResultImage, ItemsSelected, Font, RoundRadius);
end;

procedure CreateDragImageEx(ListView : TEasyListView; DImageList : TImageList; SImageList : TBitmapImageList;
  GradientFrom, GradientTo, SelectionColor : TColor; Font : TFont; Caption : string;
  DragPoint : TPoint; var SpotX, SpotY : Integer);
var
  DragImage, TempImage : TBitmap;
  SelCount : Integer;
  SelectedItem : TEasyItem;
  I, N, MaxH, MaxW, ImH, ImW, FSelCount, ItemsSelected : Integer;
  W, H : Integer;
  ImageW, ImageH, X, Y : Integer;
  Graphic : TGraphic;
  ARect, R, SelectionRect : TRect;
  LBitmap : TLayeredBitmap;
  Items : array of TEasyItem;
  EasyRect : TEasyRectArrayObject;

const
  DrawTextOpt = DT_NOPREFIX + DT_WORDBREAK + DT_CENTER;
  ImageMoveLength = 7;
  ImagePadding = 10;
  RoundRadius = 8;
  MaxItems = 6;

begin
  TempImage := TBitmap.Create;
  try
    TempImage.PixelFormat := pf32bit;

    SetLength(Items, 0);
    if ListView <> nil then
    begin
      ItemsSelected := ListView.Selection.Count;
      FSelCount := Min(MaxItems, ItemsSelected);

      SelectedItem := ListView.Selection.First;

      for I := 1 to FSelCount do
      begin
        if ListView.Selection.FocusedItem <> SelectedItem then
        begin
          SetLength(Items, Length(Items) + 1);
          Items[Length(Items) - 1] := SelectedItem;
        end;
        SelectedItem := ListView.Selection.Next(SelectedItem);
      end;
      SetLength(Items, Length(Items) + 1);
      Items[Length(Items) - 1] := ListView.Selection.FocusedItem;
      FSelCount := Length(Items);
    end else begin
      ItemsSelected := SImageList.Count;
      FSelCount := Min(MaxItems, ItemsSelected);
    end;

    MaxH := 50;
    MaxW := 50;
    N := ImagePadding - ImageMoveLength;
    for I := 1 to FSelCount do
    begin
      Inc(N, ImageMoveLength);

      if ListView <> nil then
        Graphic := SImageList[Items[I - 1].ImageIndex].Graphic
      else
        Graphic := SImageList[I - 1].Graphic;

      MaxH := Max(MaxH, N + Graphic.Height);
      MaxW := Max(MaxW, N + Graphic.Width);
    end;
    Inc(MaxH, ImagePadding);
    Inc(MaxW, ImagePadding);

    R := Rect(3, MaxH + 3, MaxW, 1000);
    TempImage.Canvas.Font := Font;
    DrawText(TempImage.Canvas.Handle, PChar(Caption), Length(Caption), R, DrawTextOpt or DT_CALCRECT);

    TempImage.Width := Max(MaxW, R.Right + 3);
    TempImage.Height := Max(MaxH, R.Bottom) + 5 * 2;
    FillTransparentColor(TempImage, ClBlack, 1);
    SelectionRect := Rect(0, 0, TempImage.Width, TempImage.Height);

    DrawRoundGradientVert(TempImage, SelectionRect, GradientFrom, GradientTo, SelectionColor, RoundRadius);
    R.Right := TempImage.Width;
    DrawText32Bit(TempImage, Caption, Font, R, DrawTextOpt);

    N := ImagePadding - ImageMoveLength;

    for I := 1 to FSelCount do
    begin
      Inc(N, ImageMoveLength);
      if ListView <> nil then
        Graphic := SImageList[Items[I - 1].ImageIndex].Graphic
      else
        Graphic := SImageList[I - 1].Graphic;

      if Graphic is TBitmap then
      begin
        if TBitmap(Graphic).PixelFormat = pf24bit then
        begin
          DragImage := TBitmap.Create;
          try
            DrawShadowToImage(DragImage, Graphic as TBitmap, 1);
            DrawImageEx32(TempImage, DragImage, N, N);
          finally
            DragImage.Free;
          end;
        end else if TBitmap(Graphic).PixelFormat = pf32bit then
        begin
          DrawImageEx32(TempImage, Graphic as TBitmap, N, N);
        end;
      end else if Graphic is TIcon then
      begin
        LBitmap := TLayeredBitmap.Create;
        try
          LBitmap.LoadFromHIcon(TIcon(Graphic).Handle, TIcon(Graphic).Height, TIcon(Graphic).Width);
          InverseTransparenty(LBitmap);
          DrawImageEx32(TempImage, LBitmap, N, N);
        finally
          LBitmap.Free;
        end;
      end;
    end;

    if ItemsSelected > 1 then
      DrawSelectionCount(TempImage, ItemsSelected, Font, RoundRadius);

    if ListView <> nil then
    begin
      Graphic := SImageList.Items[ListView.Selection.FocusedItem.ImageIndex].Graphic;

      ListView.Selection.FocusedItem.ItemRectArray(nil, ListView.Canvas, EasyRect);
      ARect := EasyRect.IconRect;

      W := ARect.Right - ARect.Left;
      H := ARect.Bottom - ARect.Top;
      ImageW := Graphic.Width;
      ImageH := Graphic.Height;
      ProportionalSize(W, H, ImageW, ImageH);

      X := ARect.Left + W div 2 - ImageW div 2;
      Y := ARect.Bottom - ImageH;

      SpotX := Min(MaxW, Max(1, DragPoint.X + N - X));
      SpotY := Min(MaxH, Max(1, DragPoint.Y + N - Y + ListView.Scrollbars.ViewableViewportRect.Top));
    end;

    DImageList.Clear;

    DImageList.Height := TempImage.Height;
    DImageList.Width := TempImage.Width;
    DImageList.Add(TempImage, nil);
  finally
    TempImage.Free;
  end;
end;

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
  ListView.Selection.TextColor := clWindowText;
  ListView.PaintInfoItem.ShowBorder := False;
  ListView.HotTrack.Cursor := CrArrow;
end;

procedure SetLVThumbnailSize(ListView : TEasyListView; ImageSize : Integer);
const
  LVWidthBetweenItems = 20;
var
  CountOfItemsX, ThWidth, AddSize : Integer;
begin
  ThWidth := ImageSize + 10 + 6;
  CountOfItemsX := Max(1, Trunc((ListView.Width - LVWidthBetweenItems) / ThWidth));
  AddSize := ListView.Width - LVWidthBetweenItems - ThWidth * CountOfItemsX;

  ListView.CellSizes.Thumbnail.Width := ThWidth + AddSize div CountOfItemsX;
  ListView.CellSizes.Thumbnail.Height := ImageSize + 40;
  ListView.Selection.RoundRect := ListView.View = elsThumbnail;
  ListView.Selection.RoundRectRadius := Min(10, ImageSize div 10)
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

procedure EnsureSelectionInListView(EasyListview: TEasyListview; ListItem : TEasyItem;
  Shift: TShiftState; X, Y: Integer; var ItemSelectedByMouseDown : Boolean;
  var ItemByMouseDown : Boolean);
var
  R: TRect;
  I: Integer;
begin
  R := EasyListview.Scrollbars.ViewableViewportRect;
  if (ListItem <> nil) and ListItem.SelectionHitPt(Point(X + R.Left, Y + R.Top), EshtClickSelect) then
  begin

    ItemSelectedByMouseDown := False;
    if not ListItem.Selected then
    begin
      if [SsCtrl, SsShift] * Shift = [] then
        for I := 0 to EasyListview.Items.Count - 1 do
          if EasyListview.Items[I].Selected then
            if ListItem <> EasyListview.Items[I] then
              EasyListview.Items[I].Selected := False;
      if [SsShift] * Shift <> [] then
        EasyListview.Selection.SelectRange(ListItem, EasyListview.Selection.FocusedItem, False, False)
      else
      begin
        ItemSelectedByMouseDown := True;
        ListItem.Selected := True;
        ListItem.Focused := True;
      end;
    end else
      ItemByMouseDown := True;

    ListItem.Focused := True;
  end;
end;

procedure RightClickFix(EasyListview: TEasyListview; Button: TMouseButton; Shift: TShiftState; Item : TEasyItem; ItemByMouseDown, ItemSelectedByMouseDown : Boolean);
var
  I : Integer;
begin
  if Item <> nil then
    if Item.Selected and (Button = MbLeft) then
    begin
      if (Shift = []) and Item.Selected then
        if ItemByMouseDown then
        begin
          for I := 0 to EasyListview.Items.Count - 1 do
            if EasyListview.Items[I].Selected then
              if Item <> EasyListview.Items[I] then
                EasyListview.Items[I].Selected := False;
        end;
      if not(EbcsDragSelecting in EasyListview.States) then
        if ([SsCtrl] * Shift <> []) and not ItemSelectedByMouseDown then
          Item.Selected := False;
    end;
end;

{ TEasyCollectionItemX }

function TEasyCollectionItemX.GetDisplayRect: TRect;
begin
  Result := DisplayRect;
end;

end.
