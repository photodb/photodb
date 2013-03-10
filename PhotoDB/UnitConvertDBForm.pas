unit UnitConvertDBForm;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Graphics,
  Vcl.AppEvnts,
  Vcl.Imaging.jpeg,
  Vcl.Imaging.pngimage,

  Dmitry.Controls.DmProgress,

  Dolphin_DB,
  CommonDBSupport,

  uMemoryEx,
  uWizards,
  uSplashThread,
  uThreadForm,
  uMemory,
  uConstants,
  uShellIntegration,
  uInterfaces,
  uVCLHelpers;

type
  TFormConvertingDB = class(TThreadForm, IDBImageSettings)
    ImMain: TImage;
    Label1: TLabel;
    Bevel1: TBevel;
    BtnNext: TButton;
    BtnCancel: TButton;
    BtnPrevious: TButton;
    BtnFinish: TButton;
    procedure FormCreate(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtnFinishClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnPreviousClick(Sender: TObject);
    procedure BtnNextClick(Sender: TObject);
  private
    { Private declarations }
    FFileName: string;
    Step: Integer;
    FImageOptions: TImageDBOptions;
    RecordCount: Integer;
    CurrentWideIndex: Integer;
    FWizard: TWizardManager;
    procedure StepChanged(Sender: TObject);
    function GetImageOptions: TImageDBOptions;
    procedure UpdateLayout;
  protected
    function GetFormID : string; override;
  public
   { Public declarations }
    SilentClose: Boolean;
    procedure LoadLanguage;
    procedure Execute(FileName: string);
    property FileName: string read FFileName;
    property RecordsCount: Integer read RecordCount;
  end;

procedure ConvertDB(FileName : string);

implementation

{$R *.dfm}

uses
  UnitDBKernel,
  uFrmConvertationLanding,
  uFrmConvertationSettings,
  uFrmConvertationProgress;

procedure ConvertDB(FileName: string);
var
  FormConvertingDB: TFormConvertingDB;
begin
  Application.CreateForm(TFormConvertingDB, FormConvertingDB);
  try
    FormConvertingDB.Execute(FileName);
  finally
    R(FormConvertingDB);
  end;
end;

{ TFormConvertingDB }

procedure TFormConvertingDB.Execute(FileName: string);
begin
  CloseSplashWindow;
  FFileName := FileName;
  F(FImageOptions);
  FImageOptions := CommonDBSupport.GetImageSettingsFromTable(FFileName);
  RecordCount := CommonDBSupport.GetRecordsCount(FFileName);
  NewFormState;

  FWizard := TWizardManager.Create(Self);
  FWizard.OnChange := StepChanged;
  FWizard.AddStep(TFrmConvertationLanding);
  FWizard.AddStep(TFrmConvertationSettings);
  FWizard.AddStep(TFrmConvertationProgress);
  FWizard.Start(Self, 120, 8);

  ShowModal;
end;

procedure TFormConvertingDB.FormCreate(Sender: TObject);
begin
  UpdateLayout;
  FImageOptions := TImageDBOptions.Create;

  LoadLanguage;
  Step := 1;
  SilentClose := False;

  CurrentWideIndex := -1;
end;

procedure TFormConvertingDB.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Convert collection');
    Label1.Caption := L('This wizard will help you convert your database from one format to another.');
    BtnCancel.Caption := L('Cancel');
    BtnPrevious.Caption := L('Previous');
    BtnNext.Caption := L('Next');
    BtnFinish.Caption := L('Start');
    BtnFinish.Caption := L('Finish');
  finally
    EndTranslate;
  end;
end;

procedure TFormConvertingDB.StepChanged(Sender: TObject);
begin
  BtnCancel.SetEnabledEx(not FWizard.IsBusy);
  BtnNext.SetEnabledEx(FWizard.CanGoNext);
  BtnPrevious.SetEnabledEx(FWizard.CanGoBack);
  BtnFinish.SetEnabledEx(FWizard.IsFinalStep and not FWizard.IsBusy and not FWizard.OperationInProgress);

  BtnFinish.Visible := FWizard.IsFinalStep;
  BtnNext.Visible := not FWizard.IsFinalStep;

  if FWizard.WizardDone then
    Close;
end;

procedure TFormConvertingDB.UpdateLayout;
var
  CW: Integer;
begin
  CW := ClientWidth;
  BtnFinish.Left := CW - BtnFinish.Width - 5;
  BtnNext.Left := CW - BtnFinish.Width - 5;
  BtnPrevious.Left := BtnFinish.Left - BtnPrevious.Width - 5;
  BtnCancel.Left := BtnPrevious.Left - BtnCancel.Width - 5;
  Bevel1.Width := ClientWidth - 10;
end;

procedure TFormConvertingDB.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormConvertingDB.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  NewFormState;
end;

procedure TFormConvertingDB.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  DialogResult: Integer;
begin
  if not BtnCancel.Enabled then
  begin
    CanClose := False;
    Exit;
  end;

  if FWizard.OperationInProgress then
    if ID_YES = MessageBoxDB(Handle, L('Do you really want to cancel current action?'), L('Warning'),
      TD_BUTTON_YESNO, TD_ICON_WARNING) then
    begin
      BtnCancel.Enabled := False;
      CanClose := False;
      FWizard.BreakOperation;
      Exit;
    end;

  if not SilentClose then
  begin
    DialogResult := MessageBoxDB(Handle,
      L('Do you really want to close this wizard?'), L('Question'),
      TD_BUTTON_OKCANCEL, TD_ICON_QUESTION);
    CanClose := DialogResult = ID_OK;
  end;
end;

procedure TFormConvertingDB.BtnFinishClick(Sender: TObject);
begin
  FWizard.Execute;
end;

procedure TFormConvertingDB.BtnNextClick(Sender: TObject);
begin
  if FWizard.CanGoNext then
    FWizard.NextStep;
end;

procedure TFormConvertingDB.BtnPreviousClick(Sender: TObject);
begin
  if FWizard.CanGoBack then
    FWizard.PrevStep;
end;

procedure TFormConvertingDB.FormDestroy(Sender: TObject);
begin
  F(FWizard);
  F(FImageOptions);
  DBKernel.ReadDBOptions;
end;

function TFormConvertingDB.GetFormID: string;
begin
  Result := 'ConvertDB';
end;

function TFormConvertingDB.GetImageOptions: TImageDBOptions;
begin
  Result := FImageOptions;
end;

end.
