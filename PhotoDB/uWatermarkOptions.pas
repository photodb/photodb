unit uWatermarkOptions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, ExtCtrls;

type
  TFrmWatermarkOptions = class(TForm)
    LbBlocksX: TLabel;
    ColorBox1: TColorBox;
    SeBlocksX: TSpinEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;


procedure ShowWatermarkOptions;

implementation

procedure ShowWatermarkOptions;
var
  FrmWatermarkOptions: TFrmWatermarkOptions;
begin
  Application.CreateForm(TFrmWatermarkOptions, FrmWatermarkOptions);
  try
    FrmWatermarkOptions.ShowModal;
  finally
    FrmWatermarkOptions.Release;
  end;
end;

{$R *.dfm}

end.
