unit uFormPersonSuggest;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,

  Dmitry.PathProviders,
  Dmitry.Controls.WebLink,

  uExplorerPathProvider,
  uExplorerPersonsProvider,
  uDBForm;

type
  TFormPersonSuggest = class(TDBForm)
    LbInfo: TLabel;
    BvSeparator: TBevel;
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
  private
    FPersonID: Integer;
    FSender: TDBForm;
  protected
    function GetFormID: string; override;
    procedure SelectPerson(Sender: TObject);
    procedure CloseForm(Sender: TObject);
    procedure LoadLanguage;
  public
    procedure LoadPersons(Sender: TDBForm; P: TPoint; PersonList: TPathItemCollection);
    procedure UpdatePos(P: TPoint);
    property PersonID: Integer read FPersonID;
  end;

implementation

uses
  uFormCreatePerson;

{$R *.dfm}

{ TFormPersonSuggest }

procedure TFormPersonSuggest.CloseForm(Sender: TObject);
begin
  FPersonID := 0;
  Close;
end;

procedure TFormPersonSuggest.FormCreate(Sender: TObject);
begin
  LoadLanguage;
  FPersonID := 0;
end;

procedure TFormPersonSuggest.FormDeactivate(Sender: TObject);
begin
  CloseForm(Sender);
end;

procedure TFormPersonSuggest.FormPaint(Sender: TObject);
begin
  Canvas.Pen.Color := Theme.WindowTextColor;
  Canvas.MoveTo(0, 0);
  Canvas.LineTo(Width - 1, 0);
  Canvas.LineTo(Width - 1, Height - 1);
  Canvas.LineTo(0, Height - 1);
  Canvas.LineTo(0, 0);
end;

function TFormPersonSuggest.GetFormID: string;
begin
  Result := 'FormPersonSuggest';
end;

procedure TFormPersonSuggest.LoadLanguage;
begin
  LbInfo.Caption := L('Select other person') + ':';
end;

procedure TFormPersonSuggest.LoadPersons(Sender: TDBForm; P: TPoint; PersonList: TPathItemCollection);
var
  I, TopInc: Integer;
  WL: TWebLink;
  B: TBitmap;

  procedure CreateLink(Index: Integer);
  begin
    WL := TWebLink.Create(Self);
    WL.Parent := Self;
    WL.Left := 2;
    WL.Top := TopInc + Index * 18;
    WL.Width := Width - 2;
    WL.Height := 16;
    WL.Color := Theme.ListColor;
  end;

begin
  FSender := Sender;
  UpdatePos(P);
  TopInc := LbInfo.Top + LbInfo.Height + 3;
  if PersonList.Count > 0 then
  begin
    Height := TopInc + (PersonList.Count + 1) * 18 + 3;

    for I := ControlCount - 1 downto 0 do
      if Controls[I] is TWebLink then
        Controls[I].Free;

    for I := 0 to PersonList.Count - 1 do
    begin
      B := PersonList[I].Image.Bitmap;
      CreateLink(I);
      WL.IconWidth := B.Width;
      WL.IconHeight := B.Height;
      WL.Text := PersonList[I].DisplayName;
      WL.LoadBitmap(B);
      WL.StretchImage := False;
      WL.OnClick := SelectPerson;
      WL.Tag := TPersonItem(PersonList[I]).PersonID;
    end;

    CreateLink(PersonList.Count);
    BvSeparator.Top := WL.Top + 1;
    WL.Top := WL.Top + 3;
    WL.OnClick := CloseForm;
    WL.Text := L('Close');
    WL.IconWidth := 0;
    WL.IconHeight := 0;

    ShowWindow(Handle, SW_SHOWNOACTIVATE);
    Visible := True;
  end else
    Visible := False;
end;

procedure TFormPersonSuggest.SelectPerson(Sender: TObject);
begin
  Close;
  FPersonID := TWebLink(Sender).Tag;
  TFormCreatePerson(FSender).SelectOtherPerson(FPersonID);
end;

procedure TFormPersonSuggest.UpdatePos(P: TPoint);
begin
  Left := P.X;
  Top := P.Y;
end;

end.
