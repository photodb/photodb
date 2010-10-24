unit uFormListView;

interface

uses
  Windows, Graphics, Classes, Controls, EasyListview, uThreadForm,
  uDBDrawing, uListViewUtils, uImageSource;

type
  TListViewForm = class(TThreadForm, IImageSource)
  protected
    function GetListView : TEasyListview; virtual;
    function IsSelectedVisible : Boolean;
    procedure CreateParams(var Params: TCreateParams); override;
    { IImageSource }
    function GetImage(FileName : string; Bitmap : TBitmap) : Boolean;
    function InternalGetImage(FileName : string; Bitmap : TBitmap) : Boolean; virtual;
  public
    function GetFilePreviw(FileName : string; Bitmap : TBitmap) : Boolean; virtual;
  end;

implementation

{ TListViewForm }

function TListViewForm.GetFilePreviw(FileName: string;
  Bitmap: TBitmap): Boolean;
begin
  GetImage(FileName, Bitmap);
end;

function TListViewForm.GetListView: TEasyListview;
begin
  Result := nil;
end;

function TListViewForm.GetImage(FileName: string; Bitmap: TBitmap): Boolean;
begin
  Result := InternalGetImage(FileName, Bitmap);
end;

function TListViewForm.InternalGetImage(FileName: string; Bitmap: TBitmap): Boolean;
begin
  Result := False;
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
