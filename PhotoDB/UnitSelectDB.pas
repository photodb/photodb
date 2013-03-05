unit UnitSelectDB;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,

  UnitDBDeclare,
  CommonDBSupport,

  uConstants,
  uMemory,
  uMemoryEx,
  uDBForm,
  uWizards,
  uInterfaces,
  uVCLHelpers;

type
  TFormSelectDB = class(TDBForm, IDBImageSettings)
    Image2: TImage;
    LbStepInfo: TLabel;
    Bevel1: TBevel;
    BtnNext: TButton;
    BtnCancel: TButton;
    BtnPrevious: TButton;
    BtnFinish: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnPreviousClick(Sender: TObject);
    procedure BtnNextClick(Sender: TObject);
    procedure BtnFinishClick(Sender: TObject);
  private
    { Private declarations }
    FImageOptions: TImageDBOptions;
    FDBFile: TDatabaseInfo;
    FOptions: Integer;
    FWizard: TWizardManager;
    procedure LoadLanguage;
    procedure StepChanged(Sender: TObject);
    function GetImageOptions : TImageDBOptions;
  protected
    { Protected declarations }
    function GetFormID : string; override;
  public
    { Public declarations }
    function InvalidDBFileMessage : string;
    procedure Execute;
    function GetResultDB: TDatabaseInfo;
    property Options: Integer read FOptions write FOptions;
    function LReadOnly : string;
    property DBFile: TDatabaseInfo read FDBFile;
  end;

function DoChooseDBFile(Options: Integer = SELECT_DB_OPTION_GET_DB): TDatabaseInfo;

implementation

uses
  uFrmSelectDBLanding;

{$R *.dfm}

function DoChooseDBFile(Options: Integer = SELECT_DB_OPTION_GET_DB): TDatabaseInfo;
var
  FormSelectDB: TFormSelectDB;
begin
  Application.CreateForm(TFormSelectDB, FormSelectDB);
  try
    FormSelectDB.Options := Options;
    FormSelectDB.Execute;
    Result := FormSelectDB.GetResultDB;
  finally
    R(FormSelectDB);
  end;
end;

function TFormSelectDB.GetFormID: string;
begin
  Result := 'SelectDB';
end;

function TFormSelectDB.GetImageOptions: TImageDBOptions;
begin
  Result := FImageOptions;
end;

function TFormSelectDB.LReadOnly: string;
begin
  Result := L('Database file marked as "Read only"! Please, reset this attribute and try again!');
end;

procedure TFormSelectDB.StepChanged(Sender: TObject);
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

function TFormSelectDB.InvalidDBFileMessage : string;
begin
  Result := L('Invalid or missing file $nl$"%s"! $nl$Check for a file or try to add it through the database manager - perhaps the file was created in an earlier version of the program and must be converted to the current version');
end;

procedure TFormSelectDB.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormSelectDB.BtnFinishClick(Sender: TObject);
begin
  FWizard.Execute;
end;

procedure TFormSelectDB.BtnNextClick(Sender: TObject);
begin
  if FWizard.CanGoNext then
    FWizard.NextStep;
end;

procedure TFormSelectDB.BtnPreviousClick(Sender: TObject);
begin
  if FWizard.CanGoBack then
    FWizard.PrevStep;
end;

procedure TFormSelectDB.Execute;
begin
  FWizard := TWizardManager.Create(Self);
  FWizard.OnChange := StepChanged;
  FWizard.AddStep(TFrmSelectDBLanding);
  FWizard.Start(Self, 127, 8);
  ShowModal;
end;

procedure TFormSelectDB.FormCreate(Sender: TObject);
begin
  FDBFile := TDatabaseInfo.Create;
  FImageOptions := CommonDBSupport.GetDefaultImageDBOptions;
  FImageOptions.Version := 0; // VERSION IS SETTED AFTER PROCESSING IMAGES
  LoadLanguage;
end;

procedure TFormSelectDB.FormDestroy(Sender: TObject);
begin
  F(FWizard);
  F(FDBFile);
  F(FImageOptions);
end;

procedure TFormSelectDB.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Choose\create\edit collection wizard');
    LbStepInfo.Caption := L('Choose an action from the list and click "Next" button');
    BtnCancel.Caption := L('Cancel');
    BtnPrevious.Caption := L('Back');
    BtnNext.Caption := L('Next');
    BtnFinish.Caption := L('Finish');
  finally
    EndTranslate;
  end;
end;

function TFormSelectDB.GetResultDB: TDatabaseInfo;
begin
  Result := TDatabaseInfo.Create;
  Result.Title := FDBFile.Title;
  Result.Icon := FDBFile.Icon;
  Result.Path := FDBFile.Path;
end;

end.
