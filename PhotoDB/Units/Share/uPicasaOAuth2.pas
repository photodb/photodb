unit uPicasaOAuth2;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.OleCtrls,
  uPicasaProvider,
  uDBForm,
  SHDocVw,
  MSHTML;

type
  TFormPicasaOAuth = class(TDBForm)
    WbApplicationRequest: TWebBrowser;
    TmrCheckCode: TTimer;
    procedure TmrCheckCodeTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FProvider: TPicasaProvider;
    FApplicationCode: string;
    procedure LoadLanguage;
  protected
    function GetFormID: string; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent; Provider: TPicasaProvider); reintroduce;
    property ApplicationCode: string read FApplicationCode;
  end;

implementation

{$R *.dfm}

constructor TFormPicasaOAuth.Create(AOwner: TComponent;
  Provider: TPicasaProvider);
begin
  FProvider := Provider;
  inherited Create(AOwner);
  FApplicationCode := '';
end;

procedure TFormPicasaOAuth.FormCreate(Sender: TObject);
begin
  LoadLanguage;
  WbApplicationRequest.Navigate(FProvider.AccessURL);
end;

function TFormPicasaOAuth.GetFormID: string;
begin
  Result := 'Picasa';
end;

procedure TFormPicasaOAuth.LoadLanguage;
begin
  Caption := L('Picasa authorisation');
end;

procedure TFormPicasaOAuth.TmrCheckCodeTimer(Sender: TObject);
var
  S: string;
  P: Integer;
begin
  //Success code=4/wt1Yb_mFV9wbyZQ0-uluJFvjwqsC
  if WbApplicationRequest.Document <> nil then
  begin
    S := IHTMLDocument2(WbApplicationRequest.Document).title;
    if Pos(AnsiUpperCase('access_denied'), AnsiUpperCase(S)) > 0 then
      Close;

    if Pos('SUCCESS', AnsiUpperCase(S)) > 0 then
    begin
      P := Pos('=', S);
      if P > 0 then
      begin
        S := Copy(S, P + 1, Length(S) - P);
        FApplicationCode := S;
        Close;
      end;
    end;
  end;
end;

end.
