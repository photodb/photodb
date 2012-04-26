unit Navig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ScrollingImageAddons;

type
  TNavigatorForm = class(TForm)
    ScrollingImageNavigator: TScrollingImageNavigator;
    procedure FormCreate(Sender: TObject);
    procedure FormCanResize(Sender: TObject; var NewWidth,
      NewHeight: Integer; var Resize: Boolean);
  public
    function CorrectNavigatorHeight(const NewWidth: Integer): Integer;
  end;

var
  NavigatorForm: TNavigatorForm;

implementation

{$R *.dfm}

uses Main;

procedure TNavigatorForm.FormCreate(Sender: TObject);
begin
  Width := 250;
end;

function TNavigatorForm.CorrectNavigatorHeight(const NewWidth: Integer): Integer;
var
  ClientWidthDiff, ClientHeightDiff: Integer;
begin
  Result := Height;

  ClientWidthDiff := ClientWidth - Width;
  ClientHeightDiff := ClientHeight - Height;

  if not Assigned(ScrollingImageNavigator.ScrollingImage) or
    ScrollingImageNavigator.ScrollingImage.Empty then Exit;

  with ScrollingImageNavigator.ScrollingImage.Picture do
  begin
    Result :=
      Round((NewWidth + ClientWidthDiff) * Height / Width) - ClientHeightDiff;
  end;
end;

procedure TNavigatorForm.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  if Assigned(Parent) then Exit;

  if (Width = NewWidth) and (Height = NewHeight) then Exit;

  NewHeight := CorrectNavigatorHeight(NewWidth);
end;

end.
