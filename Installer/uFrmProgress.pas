unit uFrmProgress;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.AppEvnts,
  Vcl.Imaging.pngimage,

  Dmitry.Graphics.Types,

  uFormUtils,
  uMemory,
  uInstallUtils,
  uDBForm,
  uInstallScope;

type
  TFrmProgress = class(TDBForm)
    AeMain: TApplicationEvents;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure AeMainMessage(var Msg: tagMSG; var Handled: Boolean);
  private
    { Private declarations }
    FProgress: Byte;
    FBackgroundImage : TBitmap;
    FProgressMessage: Cardinal;
    procedure RenderFormImage;
    procedure LoadLanguage;
    procedure SetProgress(const Value: Byte);
    procedure WMMouseDown(var s : Tmessage); message WM_LBUTTONDOWN;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    function GetFormID: string; override;
  public
    { Public declarations }
    property Progress : Byte read FProgress write SetProgress;
  end;

implementation

{$R *.dfm}

procedure TFrmProgress.AeMainMessage(var Msg: tagMSG; var Handled: Boolean);
begin
  if Msg.message = FProgressMessage then
    RenderFormImage;
end;

procedure TFrmProgress.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WndParent := GetDesktopWindow;
  with params do
    ExStyle := ExStyle or WS_EX_APPWINDOW;
end;

procedure TFrmProgress.FormCreate(Sender: TObject);
var
  MS: TMemoryStream;
  Png: TPngImage;
begin
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_LAYERED);
  LoadLanguage;
  FProgress := 0;
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
  RenderFormImage;
  FProgressMessage := RegisterWindowMessage('UPDATE_PROGRESS');
end;

procedure TFrmProgress.RenderFormImage;
var
  FCurrentImage: TBitmap;
  I, J, L, C: Integer;
  P: PARGB32;
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

    RenderForm(Handle, FCurrentImage, 255, False);
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
    Caption := L('Photo Database 4.0 Setup');
  finally
    EndTranslate;
  end;
end;

procedure TFrmProgress.SetProgress(const Value: Byte);
var
  OldProgress: Byte;
begin
  OldProgress := FProgress;
  FProgress := Value;

  if OldProgress <> FProgress then
    PostMessage(Handle, FProgressMessage, 0, 0);
end;

procedure TFrmProgress.WMMouseDown(var s: Tmessage);
begin
  Perform(WM_NCLBUTTONDOWN, HTCaption, s.lparam);
end;

end.
