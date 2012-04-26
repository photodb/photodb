unit UnitImportingImagesForm;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  ExtCtrls,
  Menus,
  DmProgress,
  Dolphin_DB,
  ComCtrls,
  acDlgSelect,
  ImgList,
  UnitUpdateDBObject,
  UnitDBkernel,
  uVistaFuncs,
  UnitDBFileDialogs,
  UnitDBDeclare,
  UnitDBCommon,
  UnitDBCommonGraphics,
  uFileUtils,
  uGraphicUtils,
  uConstants,
  uMemory,
  uDBForm,
  uShellIntegration,
  uRuntime,
  uShellUtils,
  uSettings,
  pngimage,
  uMemoryEx,
  uWizards,
  LoadingSign,
  uThemesUtils,
  uFastLoad,
  uBaseWinControl,
  uVCLHelpers;

type
  TFormImportingImages = class(TDBForm)
    ImWizard: TImage;
    LbWizardInfo: TLabel;
    BtnNext: TButton;
    BtnPrev: TButton;
    BtnCancel: TButton;
    BtnPause: TButton;
    BtnFinish: TButton;
    Bevel1: TBevel;
    LsWorking: TLoadingSign;
    procedure FormCreate(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtnNextClick(Sender: TObject);
    procedure BtnPrevClick(Sender: TObject);
    procedure BtnPauseClick(Sender: TObject);
    procedure BtnFinishClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FFileName: string;
    SilentClose: Boolean;
    FWizard: TWizardManager;
    procedure LoadLanguage;
    procedure StepChanged(Sender: TObject);
  protected
    function GetFormID: string; override;
  public
    { Public declarations }
    procedure Execute(FileName: string);
  end;

procedure ImportImages(FileName : string);

implementation

{$R *.dfm}

uses
  uFrmImportImagesLanding,
  uFrmImportImagesOptions,
  uFrmImportImagesProgress;

procedure ImportImages(FileName: string);
var
  FormImportingImages: TFormImportingImages;
begin
  Application.CreateForm(TFormImportingImages, FormImportingImages);
  try
    FormImportingImages.Execute(FileName);
  finally
    R(FormImportingImages);
  end;
end;

procedure TFormImportingImages.Execute(FileName: string);
begin
  FFileName := FileName;
  ShowModal;
end;

procedure TFormImportingImages.FormCreate(Sender: TObject);
begin
  TLoad.Instance.RequaredStyle;
  LsWorking.Color := Theme.WizardColor;
  FWizard := TWizardManager.Create(Self);
  FWizard.OnChange := StepChanged;
  FWizard.AddStep(TFrmImportImagesLanding);
  FWizard.AddStep(TFrmImportImagesOptions);
  FWizard.AddStep(TFrmImportImagesProgress);
  FWizard.Start(Self, 124, 8);
  LoadLanguage;
end;

procedure TFormImportingImages.FormDestroy(Sender: TObject);
begin
  F(FWizard);
end;

procedure TFormImportingImages.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Import your images into the database');
    LbWizardInfo.Caption := L('This wizard will help you add to the database your photos or other images');
    BtnCancel.Caption := L('Cancel');
    BtnPrev.Caption := L('Previous');
    BtnNext.Caption := L('Next');
    BtnPause.Caption := L('Pause');
    BtnFinish.Caption := L('Finish');
  finally
    EndTranslate;
  end;
end;

procedure TFormImportingImages.StepChanged(Sender: TObject);
begin
  BtnCancel.SetEnabledEx(not FWizard.IsBusy);
  BtnNext.SetEnabledEx(FWizard.CanGoNext);
  BtnPrev.SetEnabledEx(FWizard.CanGoBack);
  BtnPrev.Visible := not FWizard.IsBusy;
  BtnPause.Visible := FWizard.IsBusy;
  BtnFinish.SetEnabledEx(FWizard.IsFinalStep and not FWizard.IsBusy and not FWizard.OperationInProgress);
  BtnFinish.Visible := FWizard.IsFinalStep;
  BtnNext.Visible := not FWizard.IsFinalStep;
  LsWorking.Visible := FWizard.IsBusy;

  if FWizard.WizardDone then
  begin
    SilentClose := True;
    Close;
  end;
end;

procedure TFormImportingImages.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormImportingImages.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if not SilentClose then
  begin
    CanClose := ID_OK = MessageBoxDB(Handle,
      L('Do you really want to close this wizard?'), L('Question'),
      TD_BUTTON_OKCANCEL, TD_ICON_QUESTION);
  end;
end;

procedure TFormImportingImages.BtnNextClick(Sender: TObject);
begin
  if FWizard.CanGoNext then
    FWizard.NextStep;
end;

procedure TFormImportingImages.BtnPrevClick(Sender: TObject);
begin
  if FWizard.CanGoBack then
    FWizard.PrevStep;
end;

procedure TFormImportingImages.BtnPauseClick(Sender: TObject);
begin
  if FWizard.IsPaused then
  begin
    FWizard.Pause(False);
    BtnPause.Caption := L('Pause');
  end else
  begin
    FWizard.Pause(True);
    BtnPause.Caption := L('Resume');
  end;
end;

function TFormImportingImages.GetFormID: string;
begin
  Result := 'ImportImages';
end;

procedure TFormImportingImages.BtnFinishClick(Sender: TObject);
begin
  FWizard.Execute;
end;

end.
