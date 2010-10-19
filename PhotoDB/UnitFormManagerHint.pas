unit UnitFormManagerHint;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls;

type
  TFormManagerHint = class(TForm)
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
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
 Width:=ThImageSize+10;
 Height:=ThImageSize+10;
 DBkernel.RegisterForm(self);
end;

procedure TFormManagerHint.FormDestroy(Sender: TObject);
begin
 DBkernel.UnRegisterForm(self);
end;

end.
