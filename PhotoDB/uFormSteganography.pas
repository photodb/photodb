unit uFormSteganography;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uDBForm, StdCtrls, ExtCtrls, uWizards, uMemory, uMemoryEx;

type
  TFormSteganography = class(TDBForm)
    Image2: TImage;
    LbStepInfo: TLabel;
    Bevel1: TBevel;
    BtnNext: TButton;
    BtnCancel: TButton;
    BtnPrevious: TButton;
    BtnFinish: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnFinishClick(Sender: TObject);
    procedure BtnNextClick(Sender: TObject);
    procedure BtnPreviousClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FWizard: TWizardManager;
    procedure StepChanged(Sender: TObject);
  protected
    { Protected declarations }
    function GetFormID : string; override;
  public
    { Public declarations }
    procedure HideData(InitialFileName: string);
    procedure ExtractData(InitialFileName: string);
  end;

procedure HideDataInImage(InitialFileName: string);
procedure ExtractDataInImage(InitialFileName: string);

implementation

{$R *.dfm}

procedure HideDataInImage(InitialFileName: string);
var
  FormSteganography: TFormSteganography;
begin
  Application.CreateForm(TFormSteganography, FormSteganography);
  FormSteganography.HideData(InitialFileName);
end;

procedure ExtractDataInImage(InitialFileName: string);
var
  FormSteganography: TFormSteganography;
begin
  Application.CreateForm(TFormSteganography, FormSteganography);
  FormSteganography.ExtractData(InitialFileName);
end;

{ TFrmSteganography }

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
begin
  //
end;

procedure TFormSteganography.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Release;
end;

procedure TFormSteganography.FormCreate(Sender: TObject);
begin
  FWizard := TWizardManager.Create(Self);
  FWizard.OnChange := StepChanged;
//  FWizard.AddStep(TFrmStegoLanding);
  FWizard.Start(Self, 127, 8);
end;

procedure TFormSteganography.FormDestroy(Sender: TObject);
begin
  F(FWizard);
end;

function TFormSteganography.GetFormID: string;
begin
  Result := 'Steganography';
end;

procedure TFormSteganography.HideData(InitialFileName: string);
begin
  //
end;

procedure TFormSteganography.StepChanged(Sender: TObject);
begin
  BtnCancel.Enabled := not FWizard.IsBusy;
  BtnNext.Enabled := FWizard.CanGoNext;
  BtnPrevious.Enabled := FWizard.CanGoBack;
  BtnFinish.Enabled := FWizard.IsFinalStep and not FWizard.IsBusy and not FWizard.OperationInProgress;

  BtnFinish.Visible := FWizard.IsFinalStep;
  BtnNext.Visible := not FWizard.IsFinalStep;

  if FWizard.WizardDone then
    Close;
end;

end.
