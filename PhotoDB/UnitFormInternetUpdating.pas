unit UnitFormInternetUpdating;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, WebLink, ComCtrls, UnitDBKernel, ShellAPI,
  Dolphin_DB, uTranslate, uDBForm;

type
  TFormInternetUpdating = class(TDBForm)
    Panel1: TPanel;
    Button1: TButton;
    WebLink1: TWebLink;
    RichEdit1: TRichEdit;
    DestroyTimer: TTimer;
    WebLink2: TWebLink;
    CheckBox1: TCheckBox;
    procedure DestroyTimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure WebLink2Click(Sender: TObject);
    procedure WebLink1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    DownloadURL: string;
    procedure LoadLanguage;
  protected
    function GetFormID: string; override;
  public
    { Public declarations }
    procedure Execute(NewVersion, Text, URL: string);
  end;

procedure ShowAvaliableUpdating(NewVersion, Text, URL : String);

implementation

{$R *.dfm}

procedure ShowAvaliableUpdating(NewVersion, Text, URL: string);
var
  FormInternetUpdating: TFormInternetUpdating;
begin
  Application.CreateForm(TFormInternetUpdating, FormInternetUpdating);
  FormInternetUpdating.Execute(NewVersion, Text, URL);
end;

{ TFormInternetUpdating }

procedure TFormInternetUpdating.Execute(NewVersion, Text, URL: string);
begin
  Caption := Format(L('New version is available - %s'), [NewVersion]);
  RichEdit1.Text := Text;
  DownloadURL := URL;
  Show;
end;

procedure TFormInternetUpdating.DestroyTimerTimer(Sender: TObject);
begin
  DestroyTimer.Enabled := False;
  Release;
end;

procedure TFormInternetUpdating.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DestroyTimer.Enabled := True;
end;

procedure TFormInternetUpdating.Button1Click(Sender: TObject);
begin
  if CheckBox1.Checked then
    DBKernel.WriteDateTime('', 'LastUpdating', Now);
  Close;
end;

procedure TFormInternetUpdating.WebLink2Click(Sender: TObject);
begin
  DoHomePage;
end;

procedure TFormInternetUpdating.WebLink1Click(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PWideChar(DownloadURL), nil, nil, SW_NORMAL);
  Close;
end;

procedure TFormInternetUpdating.FormCreate(Sender: TObject);
begin
  LoadLanguage
end;

function TFormInternetUpdating.GetFormID: string;
begin
  Result := 'Updates';
end;

procedure TFormInternetUpdating.LoadLanguage;
begin
  BeginTranslate;
  try
    Button1.Caption := L('Ok');
    WebLink2.Text := L('Home page');
    WebLink1.Text := L('Download now!');
    CheckBox1.Caption := L('Remind me later');
  finally
    EndTranslate;
  end;
end;

end.
