unit UnitSelectFontForm;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  uDBForm,
  uThemesUtils,
  uMemoryEx;

type
  TFormSelectFont = class(TDBForm)
    LstFonts: TListBox;
    BtnCancel: TButton;
    BntOk: TButton;
    Label1: TLabel;
    Label2: TLabel;
    LbInfo: TLabel;
    procedure BntOkClick(Sender: TObject);
    procedure LstFontsClick(Sender: TObject);
    procedure LstFontsMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    procedure LstFontsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormCreate(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
  private
    { Private declarations }
    FOldFont: string;
    procedure LoadLanguage;
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    ExecutedOk: Boolean;
    function Execute(OldFont: string; out NewFont: string): Boolean;
  end;

function SelectFont(OldFont : String; out NewFont : String) : boolean;

implementation

{$R *.dfm}

function SelectFont(OldFont : String; out NewFont : String) : boolean;
var
  FormSelectFont: TFormSelectFont;
begin
  Application.CreateForm(TFormSelectFont, FormSelectFont);
  try
    Result := FormSelectFont.Execute(OldFont, NewFont);
  finally
    R(FormSelectFont);
  end;
end;

procedure TFormSelectFont.BntOkClick(Sender: TObject);
begin
  ExecutedOk := True;
  Close;
end;

procedure TFormSelectFont.LstFontsClick(Sender: TObject);
begin
  Label2.Font.name := LstFonts.Items[LstFonts.ItemIndex];
end;

procedure TFormSelectFont.LstFontsMeasureItem(Control: TWinControl; index: Integer; var Height: Integer);
begin
  with LstFonts.Canvas do
  begin
    Font.name := LstFonts.Items[index];
    Font.Size := 0; // use font's preferred size
    Height := TextHeight('Wg') + 2; // measure ascenders and descenders
  end;
end;

procedure TFormSelectFont.LstFontsDrawItem(Control: TWinControl; index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  with LstFonts.Canvas do
  begin
    Brush.Color := Theme.ListColor;
    Font.Color := Theme.ListFontColor;
    FillRect(Rect);
    Font.name := LstFonts.Items[index];
    Font.Size := 0; // use font's preferred size
    TextOut(Rect.Left + 1, Rect.Top + 1, LstFonts.Items[index]);
  end;
end;

procedure TFormSelectFont.FormCreate(Sender: TObject);
begin
  LstFonts.Color := Theme.ListColor;
  LoadLanguage;
  ExecutedOk := False;
  LstFonts.Items := Screen.Fonts;
  if LstFonts.Items.Count > 0 then
  begin
    LstFonts.Selected[0] := True;
    LstFontsClick(Sender);
  end;
end;

function TFormSelectFont.GetFormID: string;
begin
  Result := 'SelectFont';
end;

procedure TFormSelectFont.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Select font');
    Label1.Caption := L('Current font');
    Label2.Caption := L('New font');
    LbInfo.Caption := L('Select font from list below');
    BntOk.Caption := L('Ok');
    BtnCancel.Caption := L('Cancel');
  finally
    EndTranslate;
  end;
end;

function TFormSelectFont.Execute(OldFont: string; out NewFont: string): Boolean;
var
  I: Integer;
begin
  Label1.Font.name := OldFont;
  FOldFont := OldFont;
  for I := 0 to LstFonts.Items.Count - 1 do
    if AnsiLowerCase(LstFonts.Items[I]) = AnsiLowerCase(OldFont) then
    begin
      LstFonts.Selected[I] := True;
      Break;
    end;
  LstFontsClick(Self);
  ShowModal;
  if ExecutedOk then
    NewFont := LstFonts.Items[LstFonts.ItemIndex]
  else
    NewFont := OldFont;
  Result := ExecutedOk;
end;

procedure TFormSelectFont.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

end.
