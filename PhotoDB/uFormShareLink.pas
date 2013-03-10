unit uFormShareLink;

interface

uses
  Generics.Collections,
  Winapi.Windows,
  Winapi.ShellApi,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.Buttons,
  Vcl.ExtCtrls,
  Vcl.Clipbrd,

  IdHTTP,
  IdGlobal,
  IdSSLOpenSSL,

  Data.DBXJSON,

  Dmitry.Utils.System,
  Dmitry.Graphics.LayeredBitmap,
  Dmitry.Controls.Base,
  Dmitry.Controls.WebLink,
  Dmitry.Controls.LoadingSign,

  UnitDBDeclare,


  uConstants,
  uMemory,
  uDBForm,
  uThreadForm,
  uDBPopupMenuInfo,
  uFormInterfaces,
  uThreadTask,
  uImageViewer,
  uBitmapUtils,
  uInternetUtils,
  uShellIntegration,
  uPhotoShareInterfaces,
  uShareUtils,
  uDBRepository,
  uSettings;

type
  TFormShareLink = class(TThreadForm, IShareLinkForm)
    CbShortUrl: TCheckBox;
    BtnClose: TButton;
    LsMain: TLoadingSign;
    PnPreview: TPanel;
    LnkPublicLink: TWebLink;
    SbCopyToClipboard: TSpeedButton;
    WlSettings: TWebLink;
    procedure FormDestroy(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);
    procedure CbShortUrlClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure LnkPublicLinkClick(Sender: TObject);
    procedure SbCopyToClipboardClick(Sender: TObject);
    procedure WlSettingsClick(Sender: TObject);
  private
    { Private declarations }
    FProvider: IPhotoShareProvider;
    FViewer: TImageViewer;
    FShortUrl: string;
    FShortUrlInProgress: Boolean;
    FUrl: string;
    FProgressCount: Integer;
    procedure GetImageLink(Info: TDBPopupMenuInfo; Provider: IPhotoShareProvider);
    procedure CheckShortLink;
    procedure LoadLanguage;
    procedure StartProgress;
    procedure EndProgress;
  protected
    function GetFormID: string; override;
    procedure InterfaceDestroyed; override;
    procedure UploadCompleted(Link: string);
    procedure UpdateShortUrl(ShortLink: string);
  public
    { Public declarations }
    destructor Destroy; override;
    procedure Execute(Owner: TDBForm; Info: TDBPopupMenuInfo);
    procedure UpdateProgress(Item: TDBPopupMenuInfoRecord; Max, Position: Int64);
  end;

type
  TShareThreadTask = class
  public
    Info: TDBPopupMenuInfo;
    Provider: IPhotoShareProvider
  end;

  TThreadTaskThread = TThreadTask<TShareThreadTask>;

  TItemUploadProgress = class(TInterfacedObject, IUploadProgress)
  private
    FThread: TThreadTaskThread;
    FItem: TDBPopupMenuInfoRecord;
  public
    constructor Create(Thread: TThreadTaskThread; Item: TDBPopupMenuInfoRecord);
    procedure OnProgress(Sender: IPhotoShareProvider; Max, Position: Int64);
  end;

implementation

uses
  uShareSettings;

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
        try
          Result := FJSONObject.Get('id').JsonValue.Value;
        finally
          F(FJSONObject);
        end;
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
    StartProgress;

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

destructor TFormShareLink.Destroy;
begin
  inherited;
end;

procedure TFormShareLink.FormDestroy(Sender: TObject);
begin
  NewFormState;
end;

procedure TFormShareLink.EndProgress;
begin
  Dec(FProgressCount);
  if FProgressCount <= 0 then
  begin
    LsMain.Visible := False;
    SbCopyToClipboard.Visible := True;
  end;
end;

procedure TFormShareLink.Execute(Owner: TDBForm; Info: TDBPopupMenuInfo);
var
  Photos: TDBPopupMenuInfo;
begin
  if Info.Count = 0 then
    Exit;

  FViewer := TImageViewer.Create;
  FViewer.AttachTo(Self, PnPreview, 0, 0);
  FViewer.ResizeTo(PnPreview.Width, PnPreview.Height);
  Photos := TDBPopupMenuInfo.Create;
  Photos.Assign(Info);
  FViewer.LoadFiles(Photos);

  GetImageLink(Info, FProvider);

  ShowModal;
end;

procedure TFormShareLink.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TFormShareLink.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFormShareLink.CbShortUrlClick(Sender: TObject);
begin
  Settings.WriteBool('Share', 'ShowrtLink', CbShortUrl.Checked);

  if CbShortUrl.Checked then
  begin
    if FShortUrl = '' then
    begin
      CheckShortLink;
      Exit;
    end;

    LnkPublicLink.Text := FShortUrl;
  end else
  begin
    if FUrl <> '' then
      LnkPublicLink.Text := FUrl;
  end;
end;

function TFormShareLink.GetFormID: string;
begin
  Result := 'ShareLink';
end;

procedure TFormShareLink.GetImageLink(Info: TDBPopupMenuInfo; Provider: IPhotoShareProvider);
var
  Task: TShareThreadTask;
  Progress: IUploadProgress;
begin
  StartProgress;

  Task := TShareThreadTask.Create;
  Task.Info := Info;
  Task.Provider := Provider;

  TThreadTaskThread.Create(Self, Task,
    procedure(Thread: TThreadTaskThread; Data: TShareThreadTask)
    var
      Item: TDBPopupMenuInfoRecord;
      DBItemRepository: TDBItemRepository;
      DBItem: TDBItem;
    begin
      try
        Item := Data.Info[0];

        DBItemRepository := TDBItemRepository.Create;
        DBItem := DBItemRepository.WithKey().Add(DBItemFields.Links).Table()
          .SelectItem().ById(Item.Id)
          .FirstOrDefault();

        ProcessImageForSharing(Item, False,
          procedure(Data: TDBPopupMenuInfoRecord; Preview: TGraphic)
          begin
            //no preview is available
          end,
          procedure(Data: TDBPopupMenuInfoRecord; S: TStream; ContentType: string)
          var
            Photo: IPhotoServiceItem;
          begin
            Progress := TItemUploadProgress.Create(Thread, Item);
            try

              if Provider.UploadPhoto('', ExtractFileName(Data.FileName), ExtractFileName(Data.FileName),
                  Data.Comment, Data.Date, ContentType, S, Progress, Photo) then
              begin
                Thread.SynchronizeTask(
                  procedure
                  begin
                    TFormShareLink(Thread.ThreadForm).UploadCompleted(Photo.Url);
                  end
                );
              end;

            finally
              Progress := nil;
            end;
          end
        );

      finally
        F(Data);
      end;
    end
  );
end;

procedure TFormShareLink.FormCreate(Sender: TObject);
var
  Providers: TList<IPhotoShareProvider>;
  LB: TLayeredBitmap;
  Icon: HIcon;
begin
  FShortUrl := '';
  FShortUrlInProgress := False;
  FProgressCount := 0;
  CbShortUrl.Checked := Settings.ReadBool('Share', 'ShowrtLink', True);

  Providers := TList<IPhotoShareProvider>.Create;
  try
    PhotoShareManager.FillProviders(Providers);
    FProvider := Providers[0];
  finally
    F(Providers);
  end;

  LB := TLayeredBitmap.Create;
  try
    Icon := LoadIcon(HInstance, 'EXPLORER_COPY');
    try
      LB.LoadFromHIcon(Icon, 32, 32);
    finally
      DestroyIcon(Icon);
    end;
    KeepProportions(TBitmap(LB), 22, 22);
    SbCopyToClipboard.Glyph := LB;
  finally
    F(LB);
  end;
  LoadLanguage;

  WlSettings.LoadFromResource('SERIES_SETTINGS');
  WlSettings.RefreshBuffer(True);
  WlSettings.Left := ClientWidth - WlSettings.Width;
end;

procedure TFormShareLink.InterfaceDestroyed;
begin
  inherited;
  Release;
end;

procedure TFormShareLink.LnkPublicLinkClick(Sender: TObject);
begin
  ShellExecute(GetActiveWindow, 'open', PWideChar(LnkPublicLink.Text), nil, nil, SW_NORMAL);
end;

procedure TFormShareLink.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Image link');
    BtnClose.Caption := L('Close');
    CbShortUrl.Caption := L('Make short url');
    LnkPublicLink.Text := FormatEx(L('Authorizing: {0}'), [FProvider.GetProviderName]);
    WlSettings.Text := L('Settings');
  finally
    EndTranslate;
  end;
end;

procedure TFormShareLink.SbCopyToClipboardClick(Sender: TObject);
begin
  Clipboard.AsText := LnkPublicLink.Text;
  MessageBoxDB(Handle, FormatEx(L('Link: "{0}" was copied to clipboard!'), [LnkPublicLink.Text]), L('Information'), TD_BUTTON_OK, TD_ICON_INFORMATION);
end;

procedure TFormShareLink.StartProgress;
begin
  Inc(FProgressCount);
  LsMain.Visible := True;
  SbCopyToClipboard.Visible := False;
end;

procedure TFormShareLink.UpdateProgress(Item: TDBPopupMenuInfoRecord; Max,
  Position: Int64);
begin
  LnkPublicLink.Text := FormatEx(L('Uploading: {0:0.#}%'), [100.0 * Position / Max]);
end;

procedure TFormShareLink.UpdateShortUrl(ShortLink: string);
begin
  EndProgress;
  FShortUrl := ShortLink;
  FShortUrlInProgress := False;
  if CbShortUrl.Checked then
    LnkPublicLink.Text := ShortLink;
end;

procedure TFormShareLink.UploadCompleted(Link: string);
begin
  FUrl := Link;
  LnkPublicLink.Text := Link;
  LnkPublicLink.Enabled := True;
  EndProgress;
  CheckShortLink;
end;

procedure TFormShareLink.WlSettingsClick(Sender: TObject);
begin
  if ShowShareSettings then
    //Update smth
end;

{ TItemUploadProgress }

constructor TItemUploadProgress.Create(Thread: TThreadTaskThread;
  Item: TDBPopupMenuInfoRecord);
begin
  FThread := Thread;
  FItem := Item;
end;

procedure TItemUploadProgress.OnProgress(Sender: IPhotoShareProvider; Max,
  Position: Int64);
begin
  FThread.SynchronizeTask(
    procedure
    begin
      TFormShareLink(FThread.ThreadForm).UpdateProgress(FItem, Max, Position);
    end
  );
end;

initialization
  FormInterfaces.RegisterFormInterface(IShareLinkForm, TFormShareLink);

end.
