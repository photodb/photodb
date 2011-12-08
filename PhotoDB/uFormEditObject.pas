unit uFormEditObject;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, uDBForm;

type
  TFormEditObject = class(TDBForm)
    CbColor: TColorBox;
    lbColor: TLabel;
    LbNoteText: TLabel;
    MemText: TMemo;
    BtnOk: TButton;
    BtnCancel: TButton;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure LoadLanguage;
  protected
    { Protected declarations }
    function GetFormID: string; override;
  public
    { Public declarations }
  end;

var
  FormEditObject: TFormEditObject;

implementation

{$R *.dfm}

procedure TFormEditObject.FormCreate(Sender: TObject);
const
  ColorCount = 3;
  Colors: array [1 .. ColorCount] of TColor = (clGreen, clred, clblue);
var
  I: Integer;
begin
  LoadLanguage;
  for I := 1 to High(Colors) do
    CbColor.AddItem(ColorToString(Colors[I]), TObject(Colors[I]));
end;

function TFormEditObject.GetFormID: string;
begin
  Result := 'EditObject';
end;

procedure TFormEditObject.LoadLanguage;
begin
  BeginTranslate;
  try

  finally
    EndTranslate;
  end;
end;

end.
