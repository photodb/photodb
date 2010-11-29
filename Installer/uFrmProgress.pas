unit uFrmProgress;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, pngimage, ExtCtrls, uFormUtils, uMemory, GraphicsBaseTypes,
  uInstallUtils, uDBForm, uInstallScope;

type
  TFrmProgress = class(TDBForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FProgress: Byte;
    FBackgroundImage : TBitmap;
    procedure RenderFormImage;
    procedure LoadLanguage;
    procedure SetProgress(const Value: Byte);
    procedure WMMouseDown(var s : Tmessage); message WM_LBUTTONDOWN;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    function GetFormID : string; override;
  public
    { Public declarations }
    property Progress : Byte read FProgress write SetProgress;
  end;

implementation

{$R *.dfm}

procedure TFrmProgress.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WndParent := GetDesktopWindow;
  with params do
    ExStyle := ExStyle or WS_EX_APPWINDOW;
end;

procedure TFrmProgress.FormCreate(Sender: TObject);
var
  MS : TMemoryStream;
  Png : TPngImage;
begin
  LoadLanguage;
  FBackgroundImage := TBitmap.Create;
  FBackgroundImage.PixelFormat := pf32bit;
  MS := TMemoryStream.Create;
  try
    GetRCDATAResourceStream('PROGRESS', MS);
    Png := TPngImage.Create;
    try
      MS.Seek(0, soFromBeginning);
      Png.LoadFromStream(MS);
      FBackgroundImage.Assign(Png);
    finally
      F(Png);
    end;
  finally
    F(MS);
  end;
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
    L := FCurrentImage.Width * Progress div 255;

    if not CurrentInstall.IsUninstall then
    begin
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
    end else
    begin
      for I := 0 to FCurrentImage.Height - 1 do
      begin
        P := FCurrentImage.ScanLine[I];
        for J := 0 to L - 1 do
        begin
          C := (P[J].R * 77 + P[J].G * 151 + P[J].B * 28) shr 8;
          P[J].R := C;
          P[J].G := C;
          P[J].B := C;
        end;
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

function TFrmProgress.GetFormID: string;
begin
  Result := 'Setup';
end;

procedure TFrmProgress.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('PhotoDB 2.3 Setup');
  finally
    EndTranslate;
  end;
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
