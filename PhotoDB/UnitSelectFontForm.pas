unit UnitSelectFontForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Language, Dolphin_DB;

type
  TFormSelectFont = class(TForm)
    ListBox1: TListBox;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure Button2Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure ListBox1MeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
  FOldFont : String;
  ExecutedOk : boolean;
  procedure LoadLanguage;
  function Execute(OldFont : String; out NewFont : String) : boolean;
    { Public declarations }
  end;

function SelectFont(OldFont : String; out NewFont : String) : boolean;

implementation

{$R *.dfm}

function SelectFont(OldFont : String; out NewFont : String) : boolean;
var
  FormSelectFont: TFormSelectFont;
begin
 Application.CreateForm(TFormSelectFont, FormSelectFont);
 Result:=FormSelectFont.Execute(OldFont,NewFont);
 FormSelectFont.Release;
end;

procedure TFormSelectFont.Button2Click(Sender: TObject);
begin
 ExecutedOk:=true;
 Close;
end;

procedure TFormSelectFont.ListBox1Click(Sender: TObject);
begin
 Label2.Font.Name := ListBox1.Items[ListBox1.ItemIndex];
end;

procedure TFormSelectFont.ListBox1MeasureItem(Control: TWinControl; Index: Integer;
  var Height: Integer);
begin
  with ListBox1.Canvas do
  begin
    Font.Name := Listbox1.Items[Index];
    Font.Size := 0;                 // use font's preferred size
    Height := TextHeight('Wg') + 2; // measure ascenders and descenders
  end;
end;

procedure TFormSelectFont.ListBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
  with ListBox1.Canvas do
  begin
    Brush.Color:=Theme_ListColor;
    Font.Color:=Theme_ListFontColor;
    FillRect(Rect);
    Font.Name := ListBox1.Items[Index];
    Font.Size := 0;    // use font's preferred size
    TextOut(Rect.Left+1, Rect.Top+1, ListBox1.Items[Index]);
  end;
end;

procedure TFormSelectFont.FormCreate(Sender: TObject);
begin
 ListBox1.Color:=Theme_ListColor;
 DBKernel.RecreateThemeToForm(self);
 LoadLanguage;
 ExecutedOk:=false;
 Listbox1.Items := Screen.Fonts;
 if Listbox1.Items.Count>0 then
 begin
  Listbox1.Selected[0]:=True;
  ListBox1Click(Sender);
 end;
end;

procedure TFormSelectFont.LoadLanguage;
begin
 Label1.Caption:=TEXT_MES_OLD_FONT_NAME;
 Label2.Caption:=TEXT_MES_NEW_FONT_NAME;
 Caption:=TEXT_MES_SELECT_FONT;
 Label3.Caption:=TEXT_MES_SELECT_FONT_INFO;
 Button2.Caption:=TEXT_MES_OK;
 Button1.Caption:=TEXT_MES_CANCEL;
end;

function TFormSelectFont.Execute(OldFont: String;
  out NewFont: String): boolean;
var
  i : integer;
begin
 Label1.Font.Name:=OldFont;
 FOldFont:=OldFont;
 for i:=0 to ListBox1.Items.Count-1 do
 if AnsiLowerCase(ListBox1.Items[i])=AnsiLowerCase(OldFont) then
 begin
  ListBox1.Selected[i]:=true;
  break;
 end;
 ListBox1Click(self);
 ShowModal;
 if ExecutedOk then NewFont:=ListBox1.Items[ListBox1.ItemIndex] else
 NewFont:=OldFont;
 Result:=ExecutedOk;
end;

procedure TFormSelectFont.Button1Click(Sender: TObject);
begin
 Close;
end;

end.
