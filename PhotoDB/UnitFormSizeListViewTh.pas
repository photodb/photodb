unit UnitFormSizeListViewTh;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, WebLink, ComCtrls, StdCtrls;

type
  TFormSizeListViewTh = class(TForm)
    TrackBar1: TTrackBar;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormSizeListViewTh: TFormSizeListViewTh;

implementation

{$R *.dfm}

procedure TFormSizeListViewTh.FormCreate(Sender: TObject);
begin
 ClientWidth:=TrackBar1.Width;
end;

end.
