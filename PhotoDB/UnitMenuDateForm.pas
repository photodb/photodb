unit UnitMenuDateForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Menus, ExtCtrls, DateUtils, uDBForm;

type
  TFormMenuDateEdit = class(TDBForm)
    McDate: TMonthCalendar;
    BtOK: TButton;
    BtCancel: TButton;
    PmDate: TPopupMenu;
    GoToCurrentDate1: TMenuItem;
    DateNotExists1: TMenuItem;
    DateExists1: TMenuItem;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    DtpTime: TDateTimePicker;
    PmTime: TPopupMenu;
    GoToCurrentTime1: TMenuItem;
    TimeNotExists1: TMenuItem;
    TimeExists1: TMenuItem;
    Image2: TImage;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure GoToCurrentDate1Click(Sender: TObject);
    procedure DateNotExists1Click(Sender: TObject);
    procedure DateExists1Click(Sender: TObject);
    procedure PmDatePopup(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure GoToCurrentTime1Click(Sender: TObject);
    procedure TimeNotExists1Click(Sender: TObject);
    procedure TimeExists1Click(Sender: TObject);
    procedure PmTimePopup(Sender: TObject);
  private
    { Private declarations }
    FChanged : Boolean;
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    procedure Execute(var Date: TDateTime; var IsDate: Boolean; out Changed: Boolean; var Time: TDateTime;
      var IsTime: Boolean);
    procedure LoadLanguage;
  end;

procedure ChangeDate(var Date : TDateTime; var IsDate : Boolean; out Changed : Boolean; var Time : TDateTime; var IsTime : Boolean);

implementation

{$R *.dfm}

uses Language, Dolphin_DB;

{ TFormMenuDateEdit }

procedure ChangeDate(var Date: TDateTime; var IsDate: Boolean; out Changed: Boolean; var Time: TDateTime;
  var IsTime: Boolean);
var
  FormMenuDateEdit: TFormMenuDateEdit;
begin
  Application.CreateForm(TFormMenuDateEdit, FormMenuDateEdit);
  try
    FormMenuDateEdit.Execute(Date, IsDate, Changed, Time, IsTime);
  finally
    FormMenuDateEdit.Release;
  end;
end;

procedure TFormMenuDateEdit.Execute(var Date: TDateTime; var IsDate: Boolean; out Changed: Boolean;
  var Time: TDateTime; var IsTime: Boolean);
begin
  McDate.Date := Date;
  McDate.Visible := IsDate;
  DtpTime.Time := Time;
  DtpTime.Visible := IsTime;
  ShowModal;
  if FChanged then
  begin
    Date := McDate.Date;
    IsDate := McDate.Visible;
    Time := TimeOf(DtpTime.Time);
    IsTime := DtpTime.Visible;
  end;
  Changed := FChanged;
end;

procedure TFormMenuDateEdit.FormCreate(Sender: TObject);
begin
  FChanged := False;
  LoadLanguage;
end;

procedure TFormMenuDateEdit.BtOKClick(Sender: TObject);
begin
  FChanged := True;
  Close;
end;

procedure TFormMenuDateEdit.BtCancelClick(Sender: TObject);
begin
  Close;
end;

function TFormMenuDateEdit.GetFormID: string;
begin
  Result := 'DateChange';
end;

procedure TFormMenuDateEdit.GoToCurrentDate1Click(Sender: TObject);
begin
  McDate.Date := Now;
end;

procedure TFormMenuDateEdit.DateNotExists1Click(Sender: TObject);
begin
  McDate.Visible := False;
end;

procedure TFormMenuDateEdit.DateExists1Click(Sender: TObject);
begin
  McDate.Visible := True;
end;

procedure TFormMenuDateEdit.PmDatePopup(Sender: TObject);
begin
  GoToCurrentDate1.Visible := McDate.Visible;
  DateNotExists1.Visible := McDate.Visible;
  DateExists1.Visible := not McDate.Visible;
end;

procedure TFormMenuDateEdit.FormShow(Sender: TObject);
begin
  if BtCancel.Enabled then
    BtCancel.SetFocus
  else
    BtOK.SetFocus;
end;

procedure TFormMenuDateEdit.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_ESCAPE) then
    Close;
end;

procedure TFormMenuDateEdit.LoadLanguage;
begin
  Caption := L('Change date and time');
  GoToCurrentDate1.Caption := L('Go to current date');
  DateNotExists1.Caption := L('Date not sets');
  DateExists1.Caption := L('Date set');
  Label1.Caption := L('Date not set');
  Label2.Caption := L('Choose "Date set" in popup menu');
  BtOK.Caption := L('Ok');
  BtCancel.Caption := L('Cancel');

  GoToCurrentTime1.Caption := L('Go to current time');
  TimeNotExists1.Caption := L('Time not set');
  TimeExists1.Caption := L('Time set');
  Label3.Caption := L('Time not set');
end;

procedure TFormMenuDateEdit.GoToCurrentTime1Click(Sender: TObject);
begin
  DtpTime.Time := Now;
end;

procedure TFormMenuDateEdit.TimeNotExists1Click(Sender: TObject);
begin
  DtpTime.Visible := False;
end;

procedure TFormMenuDateEdit.TimeExists1Click(Sender: TObject);
begin
  DtpTime.Visible := True;
end;

procedure TFormMenuDateEdit.PmTimePopup(Sender: TObject);
begin
  GoToCurrentTime1.Visible := DtpTime.Visible;
  TimeNotExists1.Visible := DtpTime.Visible;
  TimeExists1.Visible := not DtpTime.Visible;
end;

end.
