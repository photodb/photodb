unit uFrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ZLib, pngimage, ExtCtrls, uDBForm, StdCtrls, WatermarkedEdit,
  uFrmProgress, uInstallTypes, uInstallUtils, uMemory, uConstants,
  uVistaFuncs, uInstallScope, Registry, uShellUtils;

type
  TFrmMain = class(TDBForm)
    ImMain: TImage;
    BtnNext: TButton;
    BtnCancel: TButton;
    Label1: TLabel;
    Bevel1: TBevel;
    BtnInstall: TButton;
    procedure BtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CbAcceptLicenseAgreementClick(Sender: TObject);
    procedure BtnInstallClick(Sender: TObject);
  private
    { Private declarations }
    FrmProgress: TFrmProgress;
    procedure LoadLanguage;
    procedure LoadMainImage;
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    function UpdateProgress(Position, Total : Int64) : Boolean;
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

uses
  uFrmLanguage, uInstallThread;

{ TFrmMain }

procedure TFrmMain.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmMain.BtnInstallClick(Sender: TObject);
begin
  Application.CreateForm(TFrmProgress, FrmProgress);
  Hide;
  FrmProgress.Show;
  FrmProgress.Progress := 0;
  CurrentInstall.DestinationPath := IncludeTrailingBackslash(GetProgramFilesPath) + 'Photo DataBase';
  TInstallThread.Create(Self);
end;

procedure TFrmMain.CbAcceptLicenseAgreementClick(Sender: TObject);
begin
//  BtnNext.Enabled := CbAcceptLicenseAgreement.Checked;
//  BtnInstall.Enabled := CbAcceptLicenseAgreement.Checked;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
var
  hSemaphore : THandle;
begin
  FrmProgress := nil;
  hSemaphore := CreateSemaphore( nil, 0, 1, PWideChar(DBID));
  if ((hSemaphore <> 0) and (GetLastError = ERROR_ALREADY_EXISTS)) then
  begin
    TaskDialogEx(Handle, L('Install already in progress!'), L('Warning'), '', TD_BUTTON_OK, TD_ICON_ERROR, False);
    Application.Terminate;
    Exit;
  end;
  LoadMainImage;
  LoadLanguage;
end;

function TFrmMain.GetFormID: string;
begin
  Result := 'Setup';
end;

procedure TFrmMain.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('PhotoDB 2.3 Setup');
    BtnCancel.Caption := L('Cancel');
    BtnNext.Caption := L('Next');
    BtnInstall.Caption := L('Install');
  finally
    EndTranslate;
  end;
end;

procedure TFrmMain.LoadMainImage;
var
  MS : TMemoryStream;
  Png : TPngImage;
begin
  MS := TMemoryStream.Create;
  try
    GetRCDATAResourceStream('Image', MS);
    Png := TPngImage.Create;
    try
      MS.Seek(0, soFromBeginning);
      Png.LoadFromStream(MS);
      ImMain.Picture.Graphic := Png;
    finally
      F(Png);
    end;
  finally
    F(MS);
  end;
end;

function TFrmMain.UpdateProgress(Position, Total: Int64): Boolean;
begin
  FrmProgress.Progress := Round((Position * 255) / Total);
  Result := True;
end;

end.
