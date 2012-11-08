unit uFormSteganography;

interface

uses
  Windows,
  Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Themes,
  Vcl.Imaging.pngimage,

  Dmitry.Controls.Base,
  Dmitry.Controls.LoadingSign,

  uDBForm,
  uWizards,
  uMemory,
  uMemoryEx,
  uVCLHelpers,
  uFormInterfaces;

type
  TFormSteganography = class(TDBForm, ISteganographyForm)
    LbStepInfo: TLabel;
    Bevel1: TBevel;
    BtnNext: TButton;
    BtnCancel: TButton;
    BtnPrevious: TButton;
    BtnFinish: TButton;
    Image2: TImage;
    LsWorking: TLoadingSign;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnFinishClick(Sender: TObject);
    procedure BtnNextClick(Sender: TObject);
    procedure BtnPreviousClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    FWizard: TWizardManager;
    procedure StepChanged(Sender: TObject);
    procedure LoadLanguage;
  protected
    { Protected declarations }
    function GetFormID : string; override;
    procedure InterfaceDestroyed; override;
  public
    { Public declarations }
    procedure HideData(InitialFileName: string);
    procedure ExtractData(InitialFileName: string);
  end;

implementation

uses
  uFrmSteganographyLanding;

{$R *.dfm}

{ TFrmSteganography }

procedure TFormSteganography.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormSteganography.BtnFinishClick(Sender: TObject);
begin
  FWizard.Execute;
end;

procedure TFormSteganography.BtnNextClick(Sender: TObject);
begin
  if FWizard.CanGoNext then
    FWizard.NextStep;
end;

procedure TFormSteganography.BtnPreviousClick(Sender: TObject);
begin
  if FWizard.CanGoBack then
    FWizard.PrevStep;
end;

procedure TFormSteganography.ExtractData(InitialFileName: string);
var
  LandingFrame: TFrmSteganographyLanding;
begin
  LandingFrame := (FWizard.GetStepByType(TFrmSteganographyLanding)) as TFrmSteganographyLanding;
  if LandingFrame <> nil then
  begin
    LandingFrame.ImageFileName := InitialFileName;
    if not LandingFrame.LoadInfoFromFile(InitialFileName) then
      ShowModal;
  end;
end;

procedure TFormSteganography.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TFormSteganography.FormCreate(Sender: TObject);
begin
  FWizard := TWizardManager.Create(Self);
  FWizard.OnChange := StepChanged;
  FWizard.AddStep(TFrmSteganographyLanding);
  FWizard.Start(Self, 127, 8);
  LoadLanguage;
  if StyleServices.Enabled then
    Color := StyleServices.GetStyleColor(scWindow);
end;

procedure TFormSteganography.FormDestroy(Sender: TObject);
begin
  F(FWizard);
end;

procedure TFormSteganography.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

function TFormSteganography.GetFormID: string;
begin
  Result := 'Steganography';
end;

procedure TFormSteganography.HideData(InitialFileName: string);
var
  LandingFrame: TFrmSteganographyLanding;
begin
  LandingFrame := (FWizard.GetStepByType(TFrmSteganographyLanding)) as TFrmSteganographyLanding;
  if LandingFrame <> nil then
  begin
    LandingFrame.ImageFileName := InitialFileName;
    ShowModal;
  end;
end;

procedure TFormSteganography.InterfaceDestroyed;
begin
  inherited;
  Free;
end;

procedure TFormSteganography.LoadLanguage;
begin
  BeginTranslate;
  try
    BtnCancel.Caption := L('Close');
    BtnPrevious.Caption := L('Previous');
    BtnNext.Caption := L('Next');
    BtnFinish.Caption := L('Finish');
    Caption := L('Data hiding');
    LbStepInfo.Caption := L('The advantage of steganography, over cryptography alone, is that messages do not attract attention to themselves.');
  finally
    EndTranslate;
  end;
end;

procedure TFormSteganography.StepChanged(Sender: TObject);
begin
  BtnCancel.SetEnabledEx(not FWizard.IsBusy);
  BtnNext.SetEnabledEx(FWizard.CanGoNext);
  BtnPrevious.SetEnabledEx(FWizard.CanGoBack);
  BtnFinish.SetEnabledEx(FWizard.IsFinalStep and not FWizard.IsBusy and not FWizard.OperationInProgress);

  BtnFinish.Visible := FWizard.IsFinalStep;
  BtnNext.Visible := not FWizard.IsFinalStep;
  LsWorking.Visible := FWizard.IsBusy;

  if FWizard.WizardDone then
    Close;
end;

initialization
  FormInterfaces.RegisterFormInterface(ISteganographyForm, TFormSteganography);

end.
