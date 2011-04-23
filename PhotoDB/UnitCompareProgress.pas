unit UnitCompareProgress;

interface

uses
  Dolphin_DB, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DmProgress, uDBForm;

type
  TImportProgressForm = class(TDBForm)
    PbMain: TDmProgress;
    Label13: TLabel;
    ActionLabel: TLabel;
    Label14: TLabel;
    StatusLabel: TLabel;
    BtnStop: TButton;
    BtnPause: TButton;
    PbItemsAdded: TDmProgress;
    Label1: TLabel;
    Label2: TLabel;
    PbItemsUpdated: TDmProgress;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnPauseClick(Sender: TObject);
    procedure BtnStopClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    procedure SetActionText(Value: String);
    procedure SetStatusText(Value: String);
    procedure SetMaxRecords(Value: Integer);
    procedure AddNewRecord;
    procedure AddUpdatedRecord;
    procedure SetProgress(Value: Integer);
    procedure Done(Sender: TObject);
    Procedure LoadLanguage;
  end;

var
  ImportProgressForm: TImportProgressForm;

implementation

uses
  UnitCmpDB, FormManegerUnit;

{$R *.dfm}

procedure TImportProgressForm.SetActionText(Value: String);
begin
  ActionLabel.Caption := Value;
end;

procedure TImportProgressForm.SetMaxRecords(Value: Integer);
begin
  PbMain.MaxValue := Value;
  PbItemsAdded.MaxValue := Value;
  PbItemsUpdated.MaxValue := Value;
end;

procedure TImportProgressForm.SetStatusText(Value: String);
begin
  StatusLabel.Caption := Value;
end;

procedure TImportProgressForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Release;
end;

procedure TImportProgressForm.FormCreate(Sender: TObject);
begin
  FormManager.RegisterMainForm(self);
  PbMain.MaxValue := 1;
  PbItemsAdded.MaxValue := 1;
  PbItemsUpdated.MaxValue := 1;
  PbMain.Position := 0;
  PbItemsAdded.Position := 0;
  PbItemsUpdated.Position := 0;
  LoadLanguage;
end;

procedure TImportProgressForm.AddNewRecord;
begin
  PbItemsAdded.Position := PbItemsAdded.Position + 1;
end;

procedure TImportProgressForm.AddUpdatedRecord;
begin
  PbItemsUpdated.Position := PbItemsUpdated.Position + 1;
end;

procedure TImportProgressForm.SetProgress(Value: Integer);
begin
  PbMain.Position := Value;
end;

procedure TImportProgressForm.FormDestroy(Sender: TObject);
begin
  FormManager.UnRegisterMainForm(Self);
end;

function TImportProgressForm.GetFormID: string;
begin
  Result := 'ImportDB';
end;

procedure TImportProgressForm.BtnPauseClick(Sender: TObject);
begin
  UnitCmpDB.CompareThreadPaused := not UnitCmpDB.CompareThreadPaused;
  if UnitCmpDB.CompareThreadPaused then
    BtnPause.Caption := L('Unpause')
  else
    BtnPause.Caption := L('Pause');
end;

procedure TImportProgressForm.BtnStopClick(Sender: TObject);
begin
  UnitCmpDB.CompareThreadTerminated := True;
end;

procedure TImportProgressForm.Done(Sender: TObject);
begin
  self.Close;
end;

procedure TImportProgressForm.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Import collection');
    PbMain.Text := L('Progress... (&%%)');
    PbItemsAdded.Text := L('&%% (Added)');
    PbItemsUpdated.Text := L('&%% (Updated)');
    BtnPause.Caption := L('Pause');
    BtnStop.Caption := L('Stop');
    Label14.Caption := L('Status') + ':';
    Label13.Caption := L('Current action') + ':';
    ActionLabel.Caption := L('<Status>');
    Label1.Caption := L('Records added') + ':';
    Label2.Caption := L('Records updated') + ':';
    StatusLabel.Caption := L('Waiting') + '...';
    ActionLabel.Caption := L('Waiting') + '...';
  finally
    EndTranslate;
  end;
end;

end.
