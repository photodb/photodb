unit uFrmProgress;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, pngimage, ExtCtrls, uFormUtils, uMemory, uPNGUtils, GraphicsBaseTypes;

type
  TFrmProgress = class(TForm)
    ImBackground: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FProgress: Byte;
    FBackgroundImage : TBitmap;
    procedure RenderFormImage;
    procedure SetProgress(const Value: Byte);
    procedure WMMouseDown(var s : Tmessage); message WM_LBUTTONDOWN;
  public
    { Public declarations }
    property Progress : Byte read FProgress write SetProgress;
  end;

implementation

{$R *.dfm}

procedure TFrmProgress.FormCreate(Sender: TObject);
var
  MS : TMemoryStream;
begin
  FBackgroundImage := TBitmap.Create;
  FBackgroundImage.PixelFormat := pf32bit;
  FBackgroundImage.Assign(ImBackground.Picture.Graphic);
  Progress := 75;
end;

procedure TFrmProgress.RenderFormImage;
var
  FCurrentImage : TBitmap;
  I, J, L, C: Integer;
  P : PARGB32;
begin
  FCurrentImage := TBitmap.Create;
  try
    FBackgroundImage.PixelFormat := pf32bit;
    FCurrentImage.Assign(FBackgroundImage);
    L := FCurrentImage.Width * Progress div 100;
    for I := 0 to FCurrentImage.Height - 1 do
    begin
      P := FCurrentImage.ScanLine[I];
      for J := L to FCurrentImage.Width - 1 do
      begin
        C := (P[J].R * 77 + P[J].G * 151 + P[J].B * 28) shr 8;
        P[J].R := C;
        P[J].G := C;
        P[J].B := C;
      end;
    end;

    RenderForm(Self, FCurrentImage, 255);
  finally
    F(FCurrentImage);
  end;
end;

procedure TFrmProgress.FormDestroy(Sender: TObject);
begin
  F(FBackgroundImage);
end;

procedure TFrmProgress.SetProgress(const Value: Byte);
var
  OldProgress : Byte;
begin
  OldProgress := FProgress;
  FProgress := Value;

  if OldProgress <> FProgress then
    RenderFormImage;
end;

procedure TFrmProgress.WMMouseDown(var s: Tmessage);
begin
  Perform(WM_NCLBUTTONDOWN, HTCaption, s.lparam);
end;

end.
