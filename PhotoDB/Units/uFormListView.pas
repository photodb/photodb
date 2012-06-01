unit uFormListView;

interface

uses
  Windows,
  Graphics,
  Classes,
  Controls,
  EasyListview,
  uThreadForm,
  uDBDrawing,
  uListViewUtils,
  uImageSource;

type
  TListViewForm = class(TThreadForm, IImageSource)
  protected
    function GetListView: TEasyListview; virtual;
    function IsSelectedVisible: Boolean;
    function IsFocusedVisible: Boolean;
    procedure CreateParams(var Params: TCreateParams); override;
    { IImageSource }
    function GetImage(FileName: string; Bitmap: TBitmap; var Width: Integer; var Height: Integer): Boolean;
    function InternalGetImage(FileName: string; Bitmap: TBitmap; var Width: Integer; var Height: Integer): Boolean; virtual;
  public
    function GetFilePreviw(FileName: string; Bitmap: TBitmap;
      var Width: Integer; var Height: Integer): Boolean; virtual;
  end;

implementation

{ TListViewForm }

function TListViewForm.GetFilePreviw(FileName: string;
  Bitmap: TBitmap; var Width: Integer; var Height: Integer): Boolean;
begin
  Result := GetImage(FileName, Bitmap, Width, Height);
end;

function TListViewForm.GetListView: TEasyListview;
begin
  Result := nil;
end;

function TListViewForm.GetImage(FileName: string; Bitmap: TBitmap; var Width: Integer; var Height: Integer): Boolean;
begin
  Result := InternalGetImage(FileName, Bitmap, Width, Height);
end;

function TListViewForm.InternalGetImage(FileName: string; Bitmap: TBitmap; var Width: Integer; var Height: Integer): Boolean;
begin
  Result := False;
end;

function TListViewForm.IsFocusedVisible: Boolean;
var
  R: TRect;
  Rv: TRect;
  ElvMain : TEasyListview;
begin
  ElvMain := GetListView;
  Result := False;
  if ElvMain.Selection.FocusedItem <> nil then
  begin
    Rv := ElvMain.Scrollbars.ViewableViewportRect;
    R := Rect(ElvMain.ClientRect.Left + Rv.Left, ElvMain.ClientRect.Top + Rv.Top, ElvMain.ClientRect.Right + Rv.Left,
      ElvMain.ClientRect.Bottom + Rv.Top);
    Result := RectInRect(R, TEasyCollectionItemX(ElvMain.Selection.FocusedItem).GetDisplayRect);
  end;
end;
function TListViewForm.IsSelectedVisible: Boolean;
var
  I: Integer;
  R: TRect;
  Rv: TRect;
  ElvMain : TEasyListview;
begin
  ElvMain := GetListView;
  Result := False;
  Rv := ElvMain.Scrollbars.ViewableViewportRect;
  for I := 0 to ElvMain.Items.Count - 1 do
  begin
    R := Rect(ElvMain.ClientRect.Left + Rv.Left, ElvMain.ClientRect.Top + Rv.Top, ElvMain.ClientRect.Right + Rv.Left,
      ElvMain.ClientRect.Bottom + Rv.Top);
    if RectInRect(R, TEasyCollectionItemX(ElvMain.Items[I]).GetDisplayRect) then
    begin
      if ElvMain.Items[I].Selected then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
end;

procedure TListViewForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WndParent := GetDesktopWindow;
  with Params do
    ExStyle := ExStyle or WS_EX_APPWINDOW;
end;

end.
