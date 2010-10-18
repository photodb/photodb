unit uFormListView;

interface

uses
  Windows, Classes, Controls, EasyListview, uThreadForm,
  uDBDrawing, uListViewUtils;

type
  TListViewForm = class(TThreadForm)
  protected
    function GetListView : TEasyListview; virtual; abstract;
    function IsSelectedVisible : Boolean;
    procedure CreateParams(var Params: TCreateParams); override;
  public
    function GetFilePreviw(FileName : string; Bitmap : TBitmap) : Boolean; virtual;
  end;

implementation

{ TListViewForm }

function TListViewForm.GetFilePreviw(FileName: string;
  Bitmap: TBitmap): Boolean;
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
