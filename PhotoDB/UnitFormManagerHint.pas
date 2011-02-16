unit UnitFormManagerHint;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, uRuntime, uDBForm;

type
  TFormManagerHint = class(TDBForm)
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses Dolphin_DB;

{$R *.dfm}

procedure TFormManagerHint.FormCreate(Sender: TObject);
begin
  Width := ThImageSize + 10;
  Height := ThImageSize + 10;
end;

end.
