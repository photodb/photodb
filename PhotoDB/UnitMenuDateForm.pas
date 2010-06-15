unit UnitMenuDateForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Menus, ExtCtrls, DateUtils;

type
  TFormMenuDateEdit = class(TForm)
    MonthCalendar1: TMonthCalendar;
    Button1: TButton;
    Button2: TButton;
    PopupMenu1: TPopupMenu;
    GoToCurrentDate1: TMenuItem;
    DateNotExists1: TMenuItem;
    DateExists1: TMenuItem;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    DateTimePicker1: TDateTimePicker;
    PopupMenu2: TPopupMenu;
    GoToCurrentTime1: TMenuItem;
    TimeNotExists1: TMenuItem;
    TimeExists1: TMenuItem;
    Image2: TImage;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure GoToCurrentDate1Click(Sender: TObject);
    procedure DateNotExists1Click(Sender: TObject);
    procedure DateExists1Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure GoToCurrentTime1Click(Sender: TObject);
    procedure TimeNotExists1Click(Sender: TObject);
    procedure TimeExists1Click(Sender: TObject);
    procedure PopupMenu2Popup(Sender: TObject);
  private
  FChanged : Boolean;
    { Private declarations }
  public
  procedure Execute(var Date : TDateTime; var IsDate : Boolean; out Changed : Boolean; var Time : TDateTime; var IsTime : Boolean);
  Procedure LoadLanguage;
    { Public declarations }
  end;

procedure ChangeDate(var Date : TDateTime; var IsDate : Boolean; out Changed : Boolean; var Time : TDateTime; var IsTime : Boolean);

implementation

{$R *.dfm}

uses Language, Dolphin_DB;

{ TFormMenuDateEdit }

procedure ChangeDate(var Date : TDateTime; var IsDate : Boolean;
  out Changed : Boolean; var Time : TDateTime; var IsTime : Boolean);
var
  FormMenuDateEdit: TFormMenuDateEdit;
begin
 Application.CreateForm(TFormMenuDateEdit,FormMenuDateEdit);
 FormMenuDateEdit.Execute(Date,IsDate,Changed,Time,IsTime);
 FormMenuDateEdit.Release;
 if UseFreeAfterRelease then FormMenuDateEdit.Free;
end;

procedure TFormMenuDateEdit.Execute(var Date: TDateTime; var IsDate : Boolean;
  out Changed: Boolean; var Time : TDateTime; var IsTime : Boolean);
begin
 MonthCalendar1.Date := Date;
 MonthCalendar1.Visible := IsDate;
 DateTimePicker1.Time:= Time;
 DateTimePicker1.Visible := IsTime;
 ShowModal;
 If FChanged then
 begin
  Date := MonthCalendar1.Date;
  IsDate := MonthCalendar1.Visible;
  Time := TimeOf(DateTimePicker1.Time);
  IsTime := DateTimePicker1.Visible;
 end;
 Changed:=FChanged;
end;

procedure TFormMenuDateEdit.FormCreate(Sender: TObject);
begin
 FChanged := false;
 LoadLanguage;
end;

procedure TFormMenuDateEdit.Button1Click(Sender: TObject);
begin
 FChanged:=True;
 Close;
end;

procedure TFormMenuDateEdit.Button2Click(Sender: TObject);
begin
 Close;
end;

procedure TFormMenuDateEdit.GoToCurrentDate1Click(Sender: TObject);
begin
 MonthCalendar1.Date:=Now;
end;

procedure TFormMenuDateEdit.DateNotExists1Click(Sender: TObject);
begin
 MonthCalendar1.Visible:=False;
end;

procedure TFormMenuDateEdit.DateExists1Click(Sender: TObject);
begin
 MonthCalendar1.Visible:=True;
end;

procedure TFormMenuDateEdit.PopupMenu1Popup(Sender: TObject);
begin
 GoToCurrentDate1.Visible:=MonthCalendar1.Visible;
 DateNotExists1.Visible:=MonthCalendar1.Visible;
 DateExists1.Visible:=not MonthCalendar1.Visible;
end;

procedure TFormMenuDateEdit.FormShow(Sender: TObject);
begin
 if Button2.Enabled then
 Button2.SetFocus else Button1.SetFocus;
end;

procedure TFormMenuDateEdit.FormKeyPress(Sender: TObject; var Key: Char);
begin
 if key=#27 then Close;
end;

procedure TFormMenuDateEdit.LoadLanguage;
begin
 Caption := TEXT_MES_CHANGE_DATE_CAPTION;
 GoToCurrentDate1.Caption:=TEXT_MES_GO_TO_CURRENT_DATE_ITEM;
 DateNotExists1.Caption:=TEXT_MES_DATE_NOT_EXISTS_ITEM;
 DateExists1.Caption:=TEXT_MES_DATE_EXISTS_ITEM;
 Label1.Caption:=TEXT_MES_DATE_NOT_EXISTS_BOX;
 Label2.Caption:=TEXT_MES_DATE_BOX_TEXT_TO_SET_DATE;
 Button1.Caption:=TEXT_MES_OK;
 Button2.Caption:=TEXT_MES_CANCEL;

 GoToCurrentTime1.Caption:=TEXT_MES_GO_TO_CURRENT_TIME;
 TimeNotExists1.Caption:=TEXT_MES_TIME_NOT_EXISTS;
 TimeExists1.Caption:=TEXT_MES_TIME_EXISTS;
 Label3.Caption:=TEXT_MES_TIME_NOT_SETS;
end;

procedure TFormMenuDateEdit.GoToCurrentTime1Click(Sender: TObject);
begin
 DateTimePicker1.Time:=Now;
end;

procedure TFormMenuDateEdit.TimeNotExists1Click(Sender: TObject);
begin
 DateTimePicker1.Visible:=false;
end;

procedure TFormMenuDateEdit.TimeExists1Click(Sender: TObject);
begin
 DateTimePicker1.Visible:=true;
end;

procedure TFormMenuDateEdit.PopupMenu2Popup(Sender: TObject);
begin
 GoToCurrentTime1.Visible:=DateTimePicker1.Visible;
 TimeNotExists1.Visible:=DateTimePicker1.Visible;
 TimeExists1.Visible:=not DateTimePicker1.Visible;
end;

end.
