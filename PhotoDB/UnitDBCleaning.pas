unit UnitDBCleaning;

interface

uses
  Dolphin_DB, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DmProgress, SaveWindowPos, uConstants, UnitDBKernel,
  uDBForm;

type
  TDBCleaningForm = class(TDBForm)
    PbMain: TDmProgress;
    CheckBox1: TCheckBox;
    CbDuplicated: TCheckBox;
    CbDeleted: TCheckBox;
    CbAutoCleaning: TCheckBox;
    BtnSave: TButton;
    BntClose: TButton;
    BtnStart: TButton;
    BtnStop: TButton;
    SaveWindowPos1: TSaveWindowPos;
    CbFastCleaning: TCheckBox;
    CbFixExifDate: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BntCloseClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure VerifyEnabledToSave;
    procedure CbAutoCleaningMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CbAutoCleaningClick(Sender: TObject);
    procedure BtnStartClick(Sender: TObject);
    procedure BtnStopClick(Sender: TObject);
  private
    { Private declarations }
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    procedure LoadLanguage;
  end;

var
  DBCleaningForm: TDBCleaningForm = nil;

implementation

uses UnitCleanUpThread;

{$R *.dfm}

procedure TDBCleaningForm.FormCreate(Sender: TObject);
begin
  SaveWindowPos1.Key := RegRoot + 'Cleaning';
  SaveWindowPos1.SetPosition;
  CheckBox1.Checked := DBKernel.ReadBool('Options', 'DeleteNotValidRecords', True);
  CbDuplicated.Checked := DBKernel.ReadBool('Options', 'VerifyDublicates', False);
  CbDeleted.Checked := DBKernel.ReadBool('Options', 'MarkDeletedFiles', True);
  CbAutoCleaning.Checked := DBKernel.ReadBool('Options', 'AllowAutoCleaning', False);
  CbFastCleaning.Checked := DBKernel.ReadBool('Options', 'AllowFastCleaning', False);
  CbFixExifDate.Checked := DBKernel.ReadBool('Options', 'FixDateAndTime', True);
  BtnStart.Enabled := not UnitCleanUpThread.Active;
  BtnStop.Enabled := UnitCleanUpThread.Active;
  PbMain.MaxValue := UnitCleanUpThread.Share_MaxPosition;
  PbMain.Position := UnitCleanUpThread.Share_Position;
  LoadLanguage;
end;

procedure TDBCleaningForm.FormDestroy(Sender: TObject);
begin
  SaveWindowPos1.SavePosition;
end;

function TDBCleaningForm.GetFormID: string;
begin
  Result := 'DBCleaning';
end;

procedure TDBCleaningForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Hide;
end;

procedure TDBCleaningForm.BntCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TDBCleaningForm.BtnSaveClick(Sender: TObject);
begin
  DBKernel.WriteBool('Options', 'DeleteNotValidRecords', CheckBox1.Checked);
  DBKernel.WriteBool('Options', 'VerifyDublicates', CbDuplicated.Checked);
  DBKernel.WriteBool('Options', 'MarkDeletedFiles', CbDeleted.Checked);
  DBKernel.WriteBool('Options', 'AllowAutoCleaning', CbAutoCleaning.Checked);
  DBKernel.WriteBool('Options', 'AllowFastCleaning', CbFastCleaning.Checked);
  DBKernel.WriteBool('Options', 'FixDateAndTime', CbFixExifDate.Checked);
  VerifyEnabledToSave;
end;

procedure TDBCleaningForm.VerifyEnabledToSave;
begin
  if (CheckBox1.Checked = DBKernel.ReadBool('Options', 'DeleteNotValidRecords',
      True)) and (CbDuplicated.Checked = DBKernel.ReadBool('Options',
      'VerifyDublicates', False)) and (CbDeleted.Checked = DBKernel.ReadBool
      ('Options', 'MarkDeletedFiles', True)) and
    (CbAutoCleaning.Checked = DBKernel.ReadBool('Options', 'AllowAutoCleaning',
      True)) and (CbFastCleaning.Checked = DBKernel.ReadBool('Options',
      'AllowFastCleaning', False)) and (CbFixExifDate.Checked = DBKernel.ReadBool
      ('Options', 'FixDateAndTime', True)) then
    BtnSave.Enabled := False
  else
    BtnSave.Enabled := True;
end;

procedure TDBCleaningForm.CbAutoCleaningMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  VerifyEnabledToSave;
end;

procedure TDBCleaningForm.CbAutoCleaningClick(Sender: TObject);
begin
  VerifyEnabledToSave;
end;

procedure TDBCleaningForm.BtnStartClick(Sender: TObject);
begin
  BtnSaveClick(Sender);
  CleanUpThread.Create(False);
  BtnStart.Enabled := False;
  BtnStop.Enabled := True;
end;

procedure TDBCleaningForm.BtnStopClick(Sender: TObject);
begin
  UnitCleanUpThread.Termitating := True;
end;

procedure TDBCleaningForm.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Cleaning');
    PbMain.Text := L('Executing... (&amp;%%)');
    CheckBox1.Caption := L('Delete not valid items');
    CbDuplicated.Caption := L('Check for duplicates');
    CbDeleted.Caption := L('Mark deleted files');
    CbAutoCleaning.Caption := L('Allow auto cleaning');
    CbFastCleaning.Caption := L('Allow fast cleaning');
    CbFixExifDate.Caption := L('Update date from EXIF');
    BtnSave.Caption := L('Save');
    BntClose.Caption := L('Close');
    BtnStart.Caption := L('Start');
    BtnStop.Caption := L('Stop');
  finally
    EndTranslate;
  end;
end;

end.
