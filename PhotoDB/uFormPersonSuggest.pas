unit uFormPersonSuggest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uExplorerPathProvider, uPathProviders, WebLink,
  uExplorerPersonsProvider, uDBForm;

type
  TFormPersonSuggest = class(TDBForm)
    procedure FormDeactivate(Sender: TObject);
  protected
    function GetFormID: string; override;
    procedure SelectPerson(Sender: TObject);
  public
    procedure LoadPersons(P: TPoint; PersonList: TPathItemCollection);
    procedure UpdatePos(P: TPoint);
  end;

var
  FormPersonSuggest: TFormPersonSuggest;

implementation

{$R *.dfm}

{ TFormPersonSuggest }

procedure TFormPersonSuggest.FormDeactivate(Sender: TObject);
begin
  Close;
end;

function TFormPersonSuggest.GetFormID: string;
begin
  Result := 'FormPersonSuggest';
end;

procedure TFormPersonSuggest.LoadPersons(P: TPoint; PersonList: TPathItemCollection);
var
  I: Integer;
  WL: TWebLink;
  B: TBitmap;
begin
  UpdatePos(P);

  if PersonList.Count > 0 then
  begin
    Height := 2 + PersonList.Count * 18;

    for I := ControlCount - 1 downto 0 do
      if Controls[I] is TWebLink then
        Controls[I].Free;

    for I := 0 to PersonList.Count - 1 do
    begin
      B := PersonList[I].Image.Bitmap;
      WL := TWebLink.Create(Self);
      WL.Parent := Self;
      WL.Left := 1;
      WL.Top := 1 + I * 18;
      WL.Width := Width - 2;
      WL.Height := 16;
      WL.IconWidth := B.Width;
      WL.IconHeight := B.Height;
      WL.Color := clWhite;
      WL.LoadBitmap(B);
      WL.Text := PersonList[I].DisplayName;
      WL.OnClick := SelectPerson;
      WL.Tag := TPersonItem(PersonList[I]).PersonID;
      WL.ImageCanRegenerate := True;
    end;

    ShowWindow(Handle, SW_SHOWNOACTIVATE);
    Visible := True;
  end else
    Visible := False;
end;

procedure TFormPersonSuggest.SelectPerson(Sender: TObject);
begin
  Close;
end;

procedure TFormPersonSuggest.UpdatePos(P: TPoint);
begin
  Left := P.X;
  Top := P.Y;
end;

end.
