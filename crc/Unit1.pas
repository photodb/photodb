unit Unit1;

interface

uses
  dm, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    CRC: TEdit;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses win32crc;

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  x : cardinal;
  tb : comp;
  e : word;
begin
 CalcFileCRC32(GetDirectory(Application.ExeName)+'PhotoDB.exe',x,tb,e);
 CRC.text:=IntTOhex(x,8);
end;

end.
