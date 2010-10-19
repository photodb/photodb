unit UnitCompareProgress;

interface

uses
  Dolphin_DB, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DmProgress;

type
  TImportProgressForm = class(TForm)
    DmProgress1: TDmProgress;
    Label13: TLabel;
    ActionLabel: TLabel;
    Label14: TLabel;
    StatusLabel: TLabel;
    Button1: TButton;
    Button2: TButton;
    DmProgress2: TDmProgress;
    Label1: TLabel;
    Label2: TLabel;
    DmProgress3: TDmProgress;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
  procedure SetActionText(Value : String);
  procedure SetStatusText(Value : String);
  procedure SetMaxRecords(Value : Integer);
  procedure AddNewRecord;
  procedure AddUpdatedRecord;
  procedure SetProgress(Value : Integer);
  procedure Done(Sender : Tobject);
  Procedure LoadLanguage;
    { Public declarations }
  end;

var
  ImportProgressForm: TImportProgressForm;

implementation

uses UnitCmpDB, Language, FormManegerUnit;

{$R *.dfm}

procedure TImportProgressForm.SetActionText(Value: String);
begin
 ActionLabel.Caption:=Value;
end;

procedure TImportProgressForm.SetMaxRecords(Value: Integer);
begin
 DmProgress1.MaxValue:=Value;
 DmProgress2.MaxValue:=Value;
 DmProgress3.MaxValue:=Value;
end;

procedure TImportProgressForm.SetStatusText(Value: String);
begin
 StatusLabel.Caption:=Value;
end;

procedure TImportProgressForm.FormCreate(Sender: TObject);
begin
 DBKernel.RegisterForm(ImportProgressForm);
 FormManager.RegisterMainForm(self);
 StatusLabel.Caption:=TEXT_MES_WAITING+'...';
 ActionLabel.Caption:=TEXT_MES_WAITING+'...';
 DmProgress1.MaxValue:=1;
 DmProgress2.MaxValue:=1;
 DmProgress3.MaxValue:=1;
 DmProgress1.Position:=0;
 DmProgress2.Position:=0;
 DmProgress3.Position:=0;
 LoadLanguage;
end;

procedure TImportProgressForm.AddNewRecord;
begin
 DmProgress2.Position:=DmProgress2.Position+1;
end;

procedure TImportProgressForm.AddUpdatedRecord;
begin
 DmProgress3.Position:=DmProgress3.Position+1;
end;

procedure TImportProgressForm.SetProgress(Value: Integer);
begin
 DmProgress1.Position:=Value;
end;

procedure TImportProgressForm.FormDestroy(Sender: TObject);
begin
 FormManager.UnRegisterMainForm(self);
 DBKernel.UnRegisterForm(ImportProgressForm);
end;

procedure TImportProgressForm.Button2Click(Sender: TObject);
begin
 UnitCmpDB.Paused:=not UnitCmpDB.Paused;
 if UnitCmpDB.Paused then Button2.Caption:=TEXT_MES_UNPAUSE else Button2.Caption:=TEXT_MES_PAUSE;
end;

procedure TImportProgressForm.Button1Click(Sender: TObject);
begin
 UnitCmpDB.Terminated_:=True;
end;

procedure TImportProgressForm.Done(Sender: Tobject);
begin
 Self.Close;
end;

procedure TImportProgressForm.LoadLanguage;
begin
 Caption:=TEXT_MES_IMPORTING_CAPTION;
 DmProgress1.Text:=TEXT_MES_PROGRESS_PR;
 DmProgress2.Text:=TEXT_MES_RECS_ADDED_PR;
 DmProgress3.Text:=TEXT_MES_RECS_UPDATED_PR;
 Button2.Caption:=TEXT_MES_PAUSE;
 Button1.Caption:=TEXT_MES_STOP;
 Label3.Caption:=TEXT_MES_STATUS;
 Label14.Caption:=TEXT_MES_STATUS+':';
 Label13.Caption:=TEXT_MES_CURRENT_ACTION+':';
 ActionLabel.Caption:=TEXT_MES_ACTIONA;
 Label1.Caption:=TEXT_MES_RECORDS_ADDED+':';
 Label2.Caption:=TEXT_MES_RECORDS_UPDATED+':';
end;

end.
