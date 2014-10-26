unit uFormShareLink;

interface

uses
  Generics.Collections,
  Winapi.Windows,
  Winapi.ShellApi,
  System.SysUtils,
  System.StrUtils,
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

  System.JSON,

  Dmitry.Utils.System,
  Dmitry.Graphics.LayeredBitmap,
  Dmitry.Controls.Base,
  Dmitry.Controls.WebLink,
  Dmitry.Controls.LoadingSign,

  UnitDBDeclare,
  UnitLinksSupport,

  uConstants,
  uMemory,
  uDBForm,
  uThreadForm,
  uFormInterfaces,
  uCollectionEvents,
  uThreadTask,
  uImageViewer,
  uBitmapUtils,
  uInternetUtils,
  uShellIntegration,
  uPhotoShareInterfaces,
  uShareUtils,
  uDBEntities,
  uDBManager,
  uDBContext,
  uSettings,
  uProgramStatInfo;

type
  TFormShareLink = class(TThreadForm, IShareLinkForm)
    CbShortUrl: TCheckBox;
    BtnClose: TButton;
    LsMain: TLoadingSign;
    PnPreview: TPanel;
    LnkPublicLink: TWebLink;
    SbCopyToClipboard: TSpeedButton;
    WlSettings: TWebLink;
    BtnUploadAgain: TButton;
    procedure FormDestroy(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);
    procedure CbShortUrlClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure LnkPublicLinkClick(Sender: TObject);
    procedure SbCopyToClipboardClick(Sender: TObject);
    procedure WlSettingsClick(Sender: TObject);
    procedure BtnUploadAgainClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    FProvider: IPhotoShareProvider;
    FViewer: TImageViewer;
    FShortUrl: string;
    FShortUrlInProgress: Boolean;
    FUrl: string;
    FProgressCount: Integer;
    FInfos: TMediaItemCollection;
    procedure GetImageLink(Info: TMediaItemCollection; Provider: IPhotoShareProvider);
    procedure CheckShortLink;
    procedure LoadLanguage;
    procedure StartProgress;
    procedure EndProgress;
    procedure ChangedDBDataByID(Sender: TObject; ID: Integer; Params: TEventFields; Value: TEventValues);
  protected
    function GetFormID: string; override;
    procedure InterfaceDestroyed; override;
    procedure UploadCompleted(Link: string);
    procedure UploadCanceled;
    procedure UpdateShortUrl(ShortLink: string);
  public
    { Public declarations }
    destructor Destroy; override;
    procedure Execute(Owner: TDBForm; Info: TMediaItemCollection);
    procedure UpdateProgress(Item: TMediaItem; Max, Position: Int64);
  end;

type
  TShareThreadTask = class
  public
    Info: TMediaItemCollection;
    Provider: IPhotoShareProvider;
    MediaRepository: IMediaRepository;
  end;

  TShareShortUrlTask = class
  public
    Info: TMediaItem;
    Url: string;
    MediaRepository: IMediaRepository;
  end;

  TThreadTaskThread = TThreadTask<TShareThreadTask>;

  TItemUploadProgress = class(TInterfacedObject, IUploadProgress)
  private
    FThread: TThreadTaskThread;
    FItem: TMediaItem;
  public
    constructor Create(Thread: TThreadTaskThread; Item: TMediaItem);
    procedure OnProgress(Sender: IPhotoShareProvider; Max, Position: Int64; var Cancel: Boolean);
  end;

implementation

uses
  uShareSettings;

const
  cFastShareProvider = 'Picasa';

function UpdateFastLinkInLinks(SLinks: string; Url: string): string;
var
  Links: TLinksInfo;
  Link: TLinkInfo;
  I: Integer;
  IsLinkUpdated: Boolean;
begin
  Links := ParseLinksInfo(SLinks);

  IsLinkUpdated := False;
  for I := 0 to Length(Links) - 1 do
  begin
    if (Links[I].LinkType = LINK_TYPE_HREF) and (Links[I].LinkName = cFastShareProvider) then
    begin
      Link.LinkValue := Url;
      IsLinkUpdated := True;
    end;
  end;

  if not IsLinkUpdated then
  begin
    Link.LinkType := LINK_TYPE_HREF;
    Link.LinkName := cFastShareProvider;
    Link.LinkValue := Url;
    SetLength(Links, Length(Links) + 1);
    Links[Length(Links) - 1] := Link;
  end;

  Result := CodeLinksInfo(Links);
end;

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
        WriteStringToStream(MS, '{"longUrl": "' + LongUrl + '"}', IndyTextEncoding_UTF8);
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

procedure TFormShareLink.ChangedDBDataByID(Sender: TObject; ID: Integer;
  Params: TEventFields; Value: TEventValues);
begin
end;

procedure TFormShareLink.CheckShortLink;
var
  Task: TShareShortUrlTask;
begin
  if (FUrl <> '') and (FShortUrl = '') and not FShortUrlInProgress and CbShortUrl.Checked then
  begin
    FShortUrlInProgress := True;
    StartProgress;

    Task := TShareShortUrlTask.Create;
    Task.Info := FInfos[0].Copy;
    Task.Url := FUrl;
    Task.MediaRepository := DBManager.DBContext.Media;

    TThreadTask<TShareShortUrlTask>.Create(Self, Task, False,
      procedure(Thread: TThreadTask<TShareShortUrlTask>; Data: TShareShortUrlTask)
      var
        ShortUrl: string;
        Info: TMediaItem;
      begin
        try
          ShortUrl := GenerateShortenUrl(Data.Url);
          Info := Data.Info;

          Thread.SynchronizeTask(
            procedure
            begin
              TFormShareLink(Thread.ThreadForm).UpdateShortUrl(ShortUrl);
            end
          );

          if (Data.Info.ID > 0) then
          begin
            Info.Links := UpdateFastLinkInLinks(Info.Links, ShortUrl);
            Data.MediaRepository.UpdateLinks(Info.ID, Info.Links);
          end;
        finally
          Data.Info.Free;
          F(Data);
        end;
      end
    );
  end;
end;

destructor TFormShareLink.Destroy;
begin
  F(FInfos);
  inherited;
end;

procedure TFormShareLink.FormDestroy(Sender: TObject);
begin
  NewFormState;
  CollectionEvents.UnRegisterChangesID(Self, ChangedDBDataByID);
end;

procedure TFormShareLink.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
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

procedure TFormShareLink.Execute(Owner: TDBForm; Info: TMediaItemCollection);
var
  Photos: TMediaItemCollection;
  Links: TLinksInfo;
  I: Integer;
  IsLinkSaved: Boolean;
  Url: string;
begin
  if Info.Count = 0 then
    Exit;

  FInfos.Assign(Info);

  FViewer := TImageViewer.Create;
  FViewer.AttachTo(Self, PnPreview, 0, 0);
  FViewer.ResizeTo(PnPreview.Width, PnPreview.Height);
  FViewer.SetOptions([]);
  Photos := TMediaItemCollection.Create;
  Photos.Assign(Info);
  FViewer.LoadFiles(Photos);

  IsLinkSaved := False;
  Links := ParseLinksInfo(Info[0].Links);
  for I := 0 to Length(Links) - 1 do
  begin
    if (Links[I].LinkType = LINK_TYPE_HREF) and (Links[I].LinkName = cFastShareProvider) then
    begin
      IsLinkSaved := True;
      Url := Links[I].LinkValue;
      CbShortUrl.Checked := Pos('goo.gl', Url) > 0;
      FShortUrlInProgress := False;
      if CbShortUrl.Checked then
        FShortUrl := Url;

      UploadCompleted(Links[I].LinkValue);
    end;
  end;

  if not IsLinkSaved then
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

procedure TFormShareLink.BtnUploadAgainClick(Sender: TObject);
begin
  GetImageLink(FInfos, FProvider);
end;

procedure TFormShareLink.CbShortUrlClick(Sender: TObject);
begin
  AppSettings.WriteBool('Share', 'ShortLink', CbShortUrl.Checked);

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

procedure TFormShareLink.GetImageLink(Info: TMediaItemCollection; Provider: IPhotoShareProvider);
var
  Task: TShareThreadTask;
  Progress: IUploadProgress;
begin
  StartProgress;

  Task := TShareThreadTask.Create;
  Task.Info := TMediaItemCollection.Create;
  Task.Info.Assign(Info);
  Task.Provider := Provider;
  Task.MediaRepository := DBManager.DBContext.Media;

  TThreadTaskThread.Create(Self, Task, False,
    procedure(Thread: TThreadTaskThread; Data: TShareThreadTask)
    var
      Item: TMediaItem;
      Media: IMediaRepository;
      SaveUrl: Boolean;
    begin
      try
        Item := Data.Info[0];
        Media := Data.MediaRepository;

        ProcessImageForSharing(Item, False,
          procedure(Data: TMediaItem; Preview: TGraphic)
          begin
            //no preview is available
          end,
          procedure(Data: TMediaItem; S: TStream; ContentType: string)
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
                    SaveUrl := not TFormShareLink(Thread.ThreadForm).CbShortUrl.Checked;
                    if SaveUrl then
                      TFormShareLink(Thread.ThreadForm).BtnUploadAgain.Show;
                  end
                );

                if SaveUrl and (Data.ID > 0) then
                begin
                  Data.Links := UpdateFastLinkInLinks(Data.Links, Photo.Url);
                  Media.UpdateLinks(Data.ID, Data.Links);
                end;

              end else
                Thread.SynchronizeTask(
                  procedure
                  begin
                    TFormShareLink(Thread.ThreadForm).UploadCanceled();
                  end
                );

            finally
              Progress := nil;
            end;
          end
        );

      finally
        Data.Info.Free;
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
  CollectionEvents.RegisterChangesID(Self, ChangedDBDataByID);

  FInfos := TMediaItemCollection.Create;
  FShortUrl := '';
  FShortUrlInProgress := False;
  FProgressCount := 0;
  CbShortUrl.Checked := AppSettings.ReadBool('Share', 'ShortLink', True);

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
    BtnUploadAgain.Caption := L('Upload again');
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

procedure TFormShareLink.UpdateProgress(Item: TMediaItem; Max, Position: Int64);
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

  BtnUploadAgain.Visible := True;
end;

procedure TFormShareLink.UploadCanceled;
begin
  EndProgress;
  Close;
end;

procedure TFormShareLink.UploadCompleted(Link: string);
begin
  FUrl := Link;
  LnkPublicLink.Text := Link;
  LnkPublicLink.Enabled := True;
  EndProgress;
  CheckShortLink;
  ProgramStatistics.FastShareUsed;
end;

procedure TFormShareLink.WlSettingsClick(Sender: TObject);
begin
  if ShowShareSettings then
    //Update smth
end;

{ TItemUploadProgress }

constructor TItemUploadProgress.Create(Thread: TThreadTaskThread;
  Item: TMediaItem);
begin
  FThread := Thread;
  FItem := Item;
end;

procedure TItemUploadProgress.OnProgress(Sender: IPhotoShareProvider; Max, Position: Int64; var Cancel: Boolean);
begin
  Cancel := not FThread.SynchronizeTask(
    procedure
    begin
      TFormShareLink(FThread.ThreadForm).UpdateProgress(FItem, Max, Position);
    end
  );
end;

initialization
  FormInterfaces.RegisterFormInterface(IShareLinkForm, TFormShareLink);

end.
