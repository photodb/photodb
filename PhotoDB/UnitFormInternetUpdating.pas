unit UnitFormInternetUpdating;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, WebLink, ComCtrls, dolphin_db, ShellAPI;

type
  TFormInternetUpdating = class(TForm)
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
  DownloadURL : String;
    { Private declarations }
  public
  procedure Execute(NewVersion, Text, URL : String);
  procedure LoadLanguage;
    { Public declarations }
  end;

procedure ShowAvaliableUpdating(NewVersion, Text, URL : String);

implementation

uses language;

{$R *.dfm}

procedure ShowAvaliableUpdating(NewVersion, Text, URL : String);
var
  FormInternetUpdating: TFormInternetUpdating;
begin
 Application.CreateForm(TFormInternetUpdating, FormInternetUpdating);
 FormInternetUpdating.Execute(NewVersion,Text, URL);
end;

{ TFormInternetUpdating }

procedure TFormInternetUpdating.Execute(NewVersion, Text, URL : String);
begin
 Caption:=format(TEXT_MES_NEW_UPDATING_CAPTION,[NewVersion]);
 RichEdit1.Text:=Text;
 DownloadURL:=URL;
 Show;
end;

procedure TFormInternetUpdating.DestroyTimerTimer(Sender: TObject);
begin
 DestroyTimer.Enabled:=false;
 Release;
end;

procedure TFormInternetUpdating.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 DestroyTimer.Enabled:=true;
end;

procedure TFormInternetUpdating.Button1Click(Sender: TObject);
begin
 if CheckBox1.Checked then DBKernel.WriteDateTime('','LastUpdating',Now);
 Close;
end;

procedure TFormInternetUpdating.WebLink2Click(Sender: TObject);
begin
 DoHomePage;
end;

procedure TFormInternetUpdating.WebLink1Click(Sender: TObject);
begin
 ShellExecute(0, nil, PWideChar(DownloadURL), nil, nil, SW_NORMAL);
 Close;
end;

procedure TFormInternetUpdating.FormCreate(Sender: TObject);
begin
 LoadLanguage
end;

procedure TFormInternetUpdating.LoadLanguage;
begin
 Button1.Caption:=TEXT_MES_OK;
 WebLink2.Text:=TEXT_MES_HOME_PAGE;
 WebLink1.Text:=TEXT_MES_DOWNLOAD_NOW;
 CheckBox1.Caption:=TEXT_MES_REMAIND_ME_LATER;
end;

end.
