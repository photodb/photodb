unit UnitFormInternetUpdating;

interface

uses
  Winapi.Windows,
  Winapi.ShellAPI,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ComCtrls,

  Dmitry.Utils.System,
  Dmitry.Controls.Base,
  Dmitry.Controls.WebLink,

  Dolphin_DB,

  uSettings,
  uDBForm,
  uInternetUtils;

type
  TFormInternetUpdating = class(TDBForm)
    RedInfo: TRichEdit;
    WlHomePage: TWebLink;
    CbRemindMeLater: TCheckBox;
    BtnOk: TButton;
    WlDownload: TWebLink;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOkClick(Sender: TObject);
    procedure WlHomePageClick(Sender: TObject);
    procedure WlDownloadClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    DownloadURL: string;
    FInfo: TUpdateInfo;
    procedure LoadLanguage;
  protected
    function GetFormID: string; override;
    procedure CustomFormAfterDisplay; override;
  public
    { Public declarations }
    procedure Execute(Info: TUpdateInfo);
  end;

procedure ShowAvaliableUpdating(Info: TUpdateInfo);

implementation

{$R *.dfm}

procedure ShowAvaliableUpdating(Info: TUpdateInfo);
var
  FormInternetUpdating: TFormInternetUpdating;
begin
  Application.CreateForm(TFormInternetUpdating, FormInternetUpdating);
  FormInternetUpdating.Execute(Info);
end;

{ TFormInternetUpdating }

procedure TFormInternetUpdating.CustomFormAfterDisplay;
begin
  inherited;
  RedInfo.Refresh;
end;

procedure TFormInternetUpdating.Execute(Info: TUpdateInfo);
begin
  FInfo := Info;
  if FInfo.ReleaseNotes <> '' then
    Caption := FInfo.ReleaseNotes
  else
    Caption := Format(L('New version is available - %s'), [ReleaseToString(FInfo.Release)]);

  RedInfo.Lines.Text := FInfo.ReleaseText;
  DownloadURL := FInfo.UrlToDownload;
  Show;
end;

procedure TFormInternetUpdating.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Release;
end;

procedure TFormInternetUpdating.BtnOkClick(Sender: TObject);
begin
  if CbRemindMeLater.Checked then
    Settings.WriteDateTime('Updater', 'LastTime', Now);
  Close;
end;

procedure TFormInternetUpdating.WlHomePageClick(Sender: TObject);
begin
  DoHomePage;
end;

procedure TFormInternetUpdating.WlDownloadClick(Sender: TObject);
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
    BtnOk.Caption := L('Ok');
    WlHomePage.Text := L('Home page');
    WlDownload.Text := L('Download now!');
    CbRemindMeLater.Caption := L('Remind me later');
  finally
    EndTranslate;
  end;
end;

end.
