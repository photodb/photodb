unit uFormShareLink;

interface

uses
  Generics.Collections,
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.Buttons,
  Vcl.ExtCtrls,

  IdHTTP,
  IdMultipartFormData,
  IdGlobal,
  IdSSLOpenSSL,

  Data.DBXJSON,

  Dmitry.Controls.Base,
  Dmitry.Controls.LoadingSign,


  uMemory,
  uDBForm,
  uThreadForm,
  uDBPopupMenuInfo,
  uFormInterfaces,
  uThreadTask,
  uImageViewer,
  uInternetUtils,
  uPhotoShareInterfaces;

type
  TFormShareLink = class(TThreadForm, IShareLinkForm)
    EdPublicLink: TEdit;
    SbCopy: TSpeedButton;
    CbShortUrl: TCheckBox;
    BtnClose: TButton;
    LoadingSign1: TLoadingSign;
    PnPreview: TPanel;
    procedure CbShortUrlClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SbCopyClick(Sender: TObject);
  private
    { Private declarations }
    FViewer: TImageViewer;
    FShortUrl: string;
    FShortUrlInProgress: Boolean;
    FUrl: string;
    procedure GetImageLink(Info: TDBPopupMenuInfo; Provider: IPhotoShareProvider);
    procedure CheckShortLink;
  protected
    procedure InterfaceDestroyed; override;
    procedure UploadCompleted(Link: string);
    procedure UpdateShortUrl(ShortLink: string);
  public
    { Public declarations }
    procedure Execute(Owner: TDBForm; Info: TDBPopupMenuInfo);
  end;

implementation

{$R *.dfm}

function GenerateShortenUrl(LongUrl: string): string;
var
  ResponseText, ActionUrl: String;
  MS: TMemoryStream;
  IdHTTP: TIdHttp;
  SSLIOHandler: TIdSSLIOHandlerSocketOpenSSL;
  FJSONObject: TJSONObject;
begin
  Result := '';

  IdHTTP := TIdHttp.Create(nil);
  SSLIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    IdHTTP.ConnectTimeout := cConnectionTimeout;
    IdHTTP.ReadTimeout := 0;
    IdHTTP.IOHandler := SSLIOHandler;
    try
      MS := TMemoryStream.Create;
      try
        ActionUrl := 'https://www.googleapis.com/urlshortener/v1/url';
        WriteStringToStream(MS, '{"longUrl": "' + LongUrl + '"}', TIdTextEncoding.UTF8);
        MS.Position := 0;

        IdHTTP.Request.ContentType := 'application/json';
        IdHTTP.Request.Charset := 'utf-8';

        ResponseText := IdHTTP.Post(ActionUrl, MS);

        FJSONObject := TJSONObject.ParseJSONValue(ResponseText) as TJSONObject;

        Result := FJSONObject.Get('id').JsonValue.Value;
      finally
        F(MS);
      end;

    except
      on e: Exception do
      begin
        Result := E.Message;
        if e is EIdHTTPProtocolException then
          Result := EIdHTTPProtocolException(e).ErrorMessage;
      end;
    end;
  finally
    F(SSLIOHandler);
    F(IdHTTP);
  end;
end;

procedure TFormShareLink.CheckShortLink;
begin
  if (FUrl <> '') and (FShortUrl = '') and not FShortUrlInProgress and CbShortUrl.Checked then
  begin
    FShortUrlInProgress := True;

    TThreadTask<string>.Create(Self, FUrl,
      procedure(Thread: TThreadTask<string>; Data: string)
      var
        ShortUrl: string;
      begin
        ShortUrl := GenerateShortenUrl(Data);

        Thread.SynchronizeTask(
          procedure
          begin
            TFormShareLink(Thread.ThreadForm).UpdateShortUrl(ShortUrl);
          end
        );
      end
    );
  end;
end;

procedure TFormShareLink.Execute(Owner: TDBForm; Info: TDBPopupMenuInfo);
var
  Providers: TList<IPhotoShareProvider>;
  Provider: IPhotoShareProvider;
begin
  if Info.Count = 0 then
    Exit;

  Providers := TList<IPhotoShareProvider>.Create;
  try
    PhotoShareManager.FillProviders(Providers);
    Provider := Providers[0];

   { FViewer := TImageViewer.Create;
    FViewer.AttachTo(Self, PnPreview, 0, 0);
    FViewer.ResizeTo(PnPreview.Width, PnPreview.Height);
    FViewer.LoadFiles(Info);   }

    GetImageLink(Info, Provider);

    ShowModal;
  finally
    F(Providers);
  end;
end;

procedure TFormShareLink.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
end;

type
  TShareThreadTask = class
  public
    Info: TDBPopupMenuInfo;
    Provider: IPhotoShareProvider
  end;

procedure TFormShareLink.CbShortUrlClick(Sender: TObject);
begin
  if CbShortUrl.Checked then
  begin
    if FShortUrl = '' then
    begin
      CheckShortLink;
      Exit;
    end;

    EdPublicLink.Text := FShortUrl;
  end else
  begin

    EdPublicLink.Text := FUrl;
  end;
end;

procedure TFormShareLink.GetImageLink(Info: TDBPopupMenuInfo; Provider: IPhotoShareProvider);
var
  Task: TShareThreadTask;
begin
  Task := TShareThreadTask.Create;
  Task.Info := Info;
  Task.Provider := Provider;

  TThreadTask<TShareThreadTask>.Create(Self, Task,
    procedure(Thread: TThreadTask<TShareThreadTask>; Data: TShareThreadTask)
    var
      FileName: string;
      FS: TFileStream;
      Photo: IPhotoServiceItem;
    begin
      try
        FileName := Data.Info[0].FileName;
        FS := TFileStream.Create(FileName, fmOpenRead, fmShareDenyWrite);
        try
          if Provider.UploadPhoto('', FileName, ExtractFileName(FileName), '', Now, 'image/jpeg', FS, nil, Photo) then
          begin
            Thread.SynchronizeTask(
              procedure
              begin
                TFormShareLink(Thread.ThreadForm).UploadCompleted(Photo.Url);
              end
            );
          end;

        finally
          F(FS);
        end;
      finally
        F(Data);
      end;
    end
  );
end;

procedure TFormShareLink.FormCreate(Sender: TObject);
begin
  FShortUrl := '';
  FShortUrlInProgress := False;
end;

procedure TFormShareLink.InterfaceDestroyed;
begin
  inherited;
  Release;
end;

procedure TFormShareLink.SbCopyClick(Sender: TObject);
begin
  EdPublicLink.CopyToClipboard;
end;

procedure TFormShareLink.UpdateShortUrl(ShortLink: string);
begin
  FShortUrl := ShortLink;
  FShortUrlInProgress := False;
  CheckShortLink;
end;

procedure TFormShareLink.UploadCompleted(Link: string);
begin
  FUrl := Link;
  EdPublicLink.Text := Link;
  CheckShortLink;
end;

initialization
  FormInterfaces.RegisterFormInterface(IShareLinkForm, TFormShareLink);

end.
