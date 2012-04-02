unit uFormSharePhotos;

interface

uses
  uRuntime,
  uConstants,
  Generics.Collections,
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  uBaseWinControl,
  WebLink,
  Vcl.Imaging.pngimage,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  WatermarkedEdit,
  ShellApi,
  LoadingSign,
  Dolphin_DB,
  uMemory,
  uMemoryEx,
  uSysUtils,
  uDBForm,
  uThreadEx,
  uThreadTask,
  uThreadForm,
  uPhotoShareInterfaces,
  uBox,
  uVCLHelpers,
  uGraphicUtils,
  uInternetUtils,
  uBitmapUtils,
  UnitDBDeclare,
  uDBPopupMenuInfo,
  Vcl.AppEvnts,
  uAssociations,
  uShellIntegration,
  DateUtils,
  uDateUtils,
  SaveWindowPos,
  Vcl.Menus,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnPopup,
  uSettings,
  uDBBaseTypes,
  ShellContextMenu,
  uConfiguration,
  GraphicCrypt,
  uFileUtils,
  uLogger;

type
  TFormSharePhotos = class(TThreadForm)
    ImProviderImage: TImage;
    WlUserName: TWebLink;
    WlChangeUser: TWebLink;
    ImAvatar: TImage;
    LbProviderInfo: TLabel;
    LsAuthorisation: TLoadingSign;
    AeMain: TApplicationEvents;
    SaveWindowPos1: TSaveWindowPos;
    PmAlbums: TPopupActionBar;
    MiRefreshAlbums: TMenuItem;
    PmAlbumAccess: TPopupActionBar;
    PmAlbumOptions: TPopupActionBar;
    MiPublic: TMenuItem;
    MiProtected: TMenuItem;
    MiPrivate: TMenuItem;
    PmItemOptions: TPopupActionBar;
    MiRemoveFromList: TMenuItem;
    MiShowInBrowser: TMenuItem;
    PnContent: TPanel;
    PnAlbums: TPanel;
    SbAlbums: TScrollBox;
    LsLoadingAlbums: TLoadingSign;
    LbAlbumList: TLabel;
    SplAlbums: TSplitter;
    PnContentArea: TPanel;
    BtnSettings: TButton;
    PbMain: TProgressBar;
    BtnCancel: TButton;
    BtnShare: TButton;
    SbItemsToUpload: TScrollBox;
    LbItems: TLabel;
    procedure BtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure WlUserNameClick(Sender: TObject);
    procedure WlChangeUserClick(Sender: TObject);
    procedure BtnSettingsClick(Sender: TObject);
    procedure AeMainMessage(var Msg: tagMSG; var Handled: Boolean);
    procedure BtnShareClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MiRefreshAlbumsClick(Sender: TObject);
    procedure MiShowInBrowserClick(Sender: TObject);
    procedure MiPublicClick(Sender: TObject);
    procedure MiProtectedClick(Sender: TObject);
    procedure MiPrivateClick(Sender: TObject);
    procedure SplAlbumsCanResize(Sender: TObject; var NewSize: Integer;
      var Accept: Boolean);
  private
    { Private declarations }
    FFiles: TDBPopupMenuInfo;
    FPreviewImages: TList<Boolean>;
    FAlbums: TList<IPhotoServiceAlbum>;
    FUserUrl: string;
    FProvider: IPhotoShareProvider;
    FIsWorking: Boolean;
    FCreateAlbumBox: TBox;
    FWlCreateAlbumName: TWebLink;
    FEdAlbumName: TWatermarkedEdit;
    FDtpAlbumDate: TDateTimePicker;
    FWlAlbumNameOk: TWebLink;
    FWlAlbumDateOk: TWebLink;
    FWlAlbumName: TWebLink;
    FWlAlbumDate: TWebLink;
    FWlAlbumSettings: TWebLink;
    FAlbumAccess: Integer;
    procedure LoadLanguage;
    procedure EnableControls(Value: Boolean);
    procedure OnBoxMouseLeave(Sender: TObject);
    procedure OnBoxMouseEnter(Sender: TObject);
    procedure ShowImages(Sender: TObject);
    procedure CreateAlbumBoxResize(Sender: TObject);
    procedure WlCreateAlbumNameClick(Sender: TObject);
    procedure WlAlbumNameOkClick(Sender: TObject);
    procedure EdAlbumNameKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure WlAlbumDateOkClick(Sender: TObject);
    procedure DtpAlbumDateKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure WlAlbumNameClick(Sender: TObject);
    procedure WlAlbumDateClick(Sender: TObject);
    procedure SelectAlbumClick(Sender: TObject);
    procedure ShowAlbumClick(Sender: TObject);
    procedure WlAlbumSettingsClick(Sender: TObject);
    procedure ItemContexPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure DeleteItemFromList(Sender: TObject);

    procedure LoadProviderInfo;
    procedure UpdateUserInfo(Provider: IPhotoShareProvider; Info: IPhotoServiceUserInfo);
    procedure ErrorLoadingInfo;
    procedure LoadImageList;
    procedure InitAlbumCreating;
    procedure LoadAlbumList(Provider: IPhotoShareProvider);
    procedure FillAlbumList(Albums: TList<IPhotoServiceAlbum>);
    procedure UpdateAlbumImage(Album: IPhotoServiceAlbum; Image: TBitmap);
    function GetItemBlockByData(Index: TDBPopupMenuInfoRecord): TBox;
  protected
    { Protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
    function GetFormID: string; override;
    procedure Execute(FileList: TDBPopupMenuInfo);
    property ItemBlock[Index: TDBPopupMenuInfoRecord]: TBox read GetItemBlockByData;
  public
    { Public declarations }
    procedure GetDataForPreview(var Data: TDBPopupMenuInfoRecord);
    procedure GetData(var Data: TDBPopupMenuInfoRecord);
    procedure UpdatePreview(Data: TDBPopupMenuInfoRecord; Preview: TGraphic);
    procedure SharingDone;
    procedure GetAlbumInfo(var AlbumID, AlbumName: string; var AlbumDate: TDateTime;
      var Access: Integer; var Album: IPhotoServiceAlbum);
    procedure StartProcessing(Data: TDBPopupMenuInfoRecord);
    procedure NotifyItemProgress(Data: TDBPopupMenuInfoRecord; Max, Position: Int64);
    procedure EndProcessing(Data: TDBPopupMenuInfoRecord; ErrorInfo: string);
    procedure ReloadAlbums;
    procedure HideAlbumCreation;
  end;

const
  CONTROL_ITEM_UPLOADING_STATE = 1;
  CONTROL_ITEM_UPLOADING_INFO = 2;

procedure SharePictures(Owner: TDBForm; Info: TDBPopupMenuInfo);
function CanShareVideo(FileName: string): Boolean;

implementation

uses
  FormManegerUnit,
  SlideShow,
  uShareSettings,
  uShareImagesThread,
  DBCMenu;

{$R *.dfm}

function AlbumCacheDirectory: string;
begin
   Result := GetAppDataDirectory + ShareAlbumCacheDirectory
end;

function CanShareVideo(FileName: string): Boolean;
var
  Ext: string;
begin
  Ext := AnsiLowerCase(ExtractFileExt(FileName));
  Result := False;
  Result := Result or (Ext = '.mov');
end;

procedure SharePictures(Owner: TDBForm; Info: TDBPopupMenuInfo);
var
  FormSharePhotos: TFormSharePhotos;
begin
  FormSharePhotos := TFormSharePhotos.Create(Owner);
  FormSharePhotos.Execute(Info);
end;

procedure TFormSharePhotos.AeMainMessage(var Msg: tagMSG; var Handled: Boolean);
var
  CY: Integer;
  P: TPoint;
begin
  if not Active then
    Exit;

  if Msg.message = WM_MOUSEWHEEL then
  begin
    if NativeInt(Msg.WParam) > 0 then
      CY := -50
    else
      CY := 50;

    GetCursorPos(P);

    if PtInRect(SbAlbums.BoundsRectScreen, P) then
      SbAlbums.VertScrollBar.Position := SbAlbums.VertScrollBar.Position + CY;
    if PtInRect(SbItemsToUpload.BoundsRectScreen, P) then
      SbItemsToUpload.VertScrollBar.Position := SbItemsToUpload.VertScrollBar.Position + CY;
  end;
end;

procedure TFormSharePhotos.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormSharePhotos.BtnSettingsClick(Sender: TObject);
begin
  if ShowShareSettings then
    LoadImageList;
end;

procedure TFormSharePhotos.BtnShareClick(Sender: TObject);
begin
  FIsWorking := True;

  WlAlbumNameOkClick(FWlAlbumNameOk);
  WlAlbumDateOkClick(FWlAlbumDateOk);
  FWlAlbumName.Enabled := False;
  FWlAlbumDate.Enabled := False;
  FWlAlbumSettings.Enabled := False;
  WlChangeUser.Enabled := False;

  BtnShare.SetEnabledEx(False);
  BtnSettings.Enabled := False;
  TShareImagesThread.Create(Self, FProvider, False);
end;

procedure TFormSharePhotos.CreateAlbumBoxResize(Sender: TObject);
begin
  if FWlCreateAlbumName <> nil then
    FWlCreateAlbumName.Left := FCreateAlbumBox.Width div 2 - FWlCreateAlbumName.Width div 2;
end;

procedure TFormSharePhotos.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WndParent := GetDesktopWindow;
  with params do
    ExStyle := ExStyle or WS_EX_APPWINDOW;
end;

procedure TFormSharePhotos.DtpAlbumDateKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    Key := 0;
    WlAlbumDateOkClick(Sender);
  end;
end;

procedure TFormSharePhotos.EdAlbumNameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    Key := 0;
    WlAlbumNameOkClick(Sender);
  end;
end;

procedure TFormSharePhotos.EnableControls(Value: Boolean);
begin
  BtnShare.Enabled := FFiles.Count > 0;
  WlUserName.Enabled := Value;
  WlChangeUser.Enabled := Value;
end;

procedure TFormSharePhotos.Execute(FileList: TDBPopupMenuInfo);
var
  I: Integer;
  HasEncryptedFiles: Boolean;
begin
  for I := 0 to FileList.Count - 1 do
  begin
    if FFiles.Count = cMaxShareFilesLimit then
    begin
      MessageBoxDB(Handle, L('You can share maximum 100 files at one time!'), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
      Break;
    end;
    if FileList[I].FileSize > cMaxShareFileSize then
    begin
      if ID_OK <> MessageBoxDB(Handle, FormatEx(L('Maximum file size for sharing is {0}, skipping file "{1}", {2}!'),
        [SizeInText(cMaxShareFileSize), FileList[I].FileName, SizeInText(FileList[I].FileSize)]), L('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
      begin
        Close;
        Exit;
      end else
        Continue;
    end;
    FFiles.Add(FileList[I].Copy);
  end;

  if FFiles.Count = 0 then
  begin
    Close;
    Exit;
  end;

  HasEncryptedFiles := False;

  for I := 0 to FFiles.Count - 1 do
  begin
    if IsGraphicFile(FFiles[I].FileName) and not HasEncryptedFiles and ValidCryptGraphicFile(FFiles[I].FileName) then
      HasEncryptedFiles := True;

    FPreviewImages.Add(False);
  end;

  if HasEncryptedFiles then
  begin
    MessageBoxDB(Handle, L('Some files are encrypted! Album access is changed to "private"!'), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
    FAlbumAccess := PHOTO_PROVIDER_ALBUM_PRIVATE;
  end;

  InitAlbumCreating;
  LoadImageList;
  LoadProviderInfo;
  Show;
end;

procedure TFormSharePhotos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Settings.WriteInteger('Share', 'AlbumsSplitterPos', PnAlbums.Width);
  SaveWindowPos1.SavePosition;
  Action := caFree;
end;

procedure TFormSharePhotos.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if FIsWorking then
  begin
    if ID_YES <> MessageBoxDB(Handle, L('Do you really want to cancel current action?'), L('Warning'), TD_BUTTON_YESNO, TD_ICON_WARNING) then
      CanClose := False;
  end;
end;

procedure TFormSharePhotos.FormCreate(Sender: TObject);
var
  AccessIndex: Integer;
begin
  RegisterMainForm(Self);

  SaveWindowPos1.Key := RegRoot + 'SharePhotos';
  SaveWindowPos1.SetPosition;

  FIsWorking := False;
  FCreateAlbumBox := nil;
  FFiles := TDBPopupMenuInfo.Create;
  FAlbums := TList<IPhotoServiceAlbum>.Create;
  FPreviewImages := TList<Boolean>.Create;
  LoadLanguage;
  EnableControls(False);

  AccessIndex := Settings.ReadInteger('Share', 'AlbumAccess', 0);
  case AccessIndex of
    1:
    begin
      MiProtected.Checked := True;
      FAlbumAccess := PHOTO_PROVIDER_ALBUM_PROTECTED;
    end;
    2:
    begin
      MiPrivate.Checked := True;
      FAlbumAccess := PHOTO_PROVIDER_ALBUM_PRIVATE;
    end else
    begin
      MiPublic.Checked := True;
      FAlbumAccess := PHOTO_PROVIDER_ALBUM_PUBLIC;
    end;
  end;

  PnAlbums.Width := Settings.ReadInteger('Share', 'AlbumsSplitterPos', 160);
  FProvider := nil;
end;

procedure TFormSharePhotos.FormDestroy(Sender: TObject);
begin
  NewFormState;
  F(FAlbums);
  F(FFiles);
  F(FPreviewImages);
  UnRegisterMainForm(Self);
end;

procedure TFormSharePhotos.FormResize(Sender: TObject);
begin
  Invalidate;
end;

procedure TFormSharePhotos.GetAlbumInfo(var AlbumID, AlbumName: string;
  var AlbumDate: TDateTime; var Access: Integer; var Album: IPhotoServiceAlbum);
var
  I: Integer;
  Box: TBox;
begin
  AlbumID := '';
  AlbumName := FWlAlbumName.Text;
  AlbumDate := FDtpAlbumDate.Date;
  Access := FAlbumAccess;

  for I := 0 to SbAlbums.ControlCount - 1 do
  begin
    if SbAlbums.Controls[I] is TBox then
    begin
      Box := TBox(SbAlbums.Controls[I]);
      if (Box.IsSelected) and (Box <> FCreateAlbumBox) then
      begin
        Album := IPhotoServiceAlbum(Box.Tag);
        AlbumID := Album.AlbumID;
        AlbumName := Album.Name;
        AlbumDate := Album.Date;
      end;
    end;
  end;
end;

procedure TFormSharePhotos.GetData(var Data: TDBPopupMenuInfoRecord);
var
  I: Integer;
  D: TDBPopupMenuInfoRecord;
begin
  if Data = nil then
  begin
    PbMain.Max := FFiles.Count;
    PbMain.Position := 1;
    Data := FFiles[0].Copy;
    Exit;
  end;
  D := Data;
  Data := nil;
  for I := 0 to FFiles.Count - 2 do
  begin
    if AnsiLowerCase(FFiles[I].FileName) = AnsiLowerCase(D.FileName) then
    begin
      PbMain.Position := I + 1;
      Data := FFiles[I + 1].Copy;
      Exit;
    end;
  end;
  F(D);
end;

procedure TFormSharePhotos.GetDataForPreview(var Data: TDBPopupMenuInfoRecord);
var
  I: Integer;
begin
  F(Data);
  for I := 0 to FPreviewImages.Count - 1 do
    if not FPreviewImages[I] then
    begin
      FPreviewImages[I] := True;
      Data := FFiles[I].Copy;
      Break;
    end;
end;

function TFormSharePhotos.GetFormID: string;
begin
  Result := 'PhotoShare';
end;

function TFormSharePhotos.GetItemBlockByData(Index: TDBPopupMenuInfoRecord): TBox;
var
  I: Integer;
  Box: TBox;
  FI: TDBPopupMenuInfoRecord;
begin
  Result := nil;
  for I := 0 to SbItemsToUpload.ControlCount - 1 do
  begin
    Box := TBox(SbItemsToUpload.Controls[I]);
    FI := TDBPopupMenuInfoRecord(Box.Tag);
    if AnsiLowerCase(FI.FileName) = AnsiLowerCase(Index.FileName) then
    begin
      Result := Box;
      Exit;
    end;
  end;
end;

procedure TFormSharePhotos.HideAlbumCreation;
begin
  FCreateAlbumBox.Hide;
end;

procedure TFormSharePhotos.SharingDone;
begin
  FIsWorking := False;
  BtnSettings.Enabled := True;
  BtnCancel.Caption := L('Done');
end;

procedure TFormSharePhotos.InitAlbumCreating;
var
  VertIncrement: Integer;
  StatDate: TDateTime;
begin
  SbAlbums.VertScrollBar.Position := 0;

  FCreateAlbumBox := TBox.Create(SbAlbums);
  FCreateAlbumBox.Parent := SbAlbums;
  FCreateAlbumBox.Top := 3;
  FCreateAlbumBox.Height := 60;
  FCreateAlbumBox.Left := 3;
  FCreateAlbumBox.Width := SbAlbums.ClientWidth - 5;
  FCreateAlbumBox.Anchors := [akLeft, akTop, akRight];
  FCreateAlbumBox.ParentBackground := False;
  FCreateAlbumBox.OnMouseEnter := OnBoxMouseEnter;
  FCreateAlbumBox.OnMouseLeave := OnBoxMouseLeave;
  FCreateAlbumBox.Tag := 0;
  FCreateAlbumBox.OnResize := CreateAlbumBoxResize;
  FCreateAlbumBox.OnClick := SelectAlbumClick;
  FCreateAlbumBox.IsSelected := True;

  FWlCreateAlbumName := TWebLink.Create(FCreateAlbumBox);
  FWlCreateAlbumName.Parent := FCreateAlbumBox;
  FWlCreateAlbumName.OnMouseEnter := OnBoxMouseEnter;
  FWlCreateAlbumName.OnMouseLeave := OnBoxMouseLeave;
  FWlCreateAlbumName.OnClick := WlCreateAlbumNameClick;
  FWlCreateAlbumName.Text := L('Create new album');
  FWlCreateAlbumName.IconWidth := 0;
  FWlCreateAlbumName.IconHeight := 0;
  FWlCreateAlbumName.LoadImage;
  FWlCreateAlbumName.Top := FCreateAlbumBox.Height div 2 - FWlCreateAlbumName.Height div 2;

  FWlAlbumNameOk := TWebLink.Create(FCreateAlbumBox);
  FWlAlbumNameOk.Parent := FCreateAlbumBox;
  FWlAlbumNameOk.IconWidth := 16;
  FWlAlbumNameOk.IconHeight := 16;
  FWlAlbumNameOk.LoadFromResource('SERIES_OK');
  FWlAlbumNameOk.Refresh;
  FWlAlbumNameOk.Visible := False;
  FWlAlbumNameOk.Anchors := [akTop, akRight];
  FWlAlbumNameOk.OnMouseEnter := OnBoxMouseEnter;
  FWlAlbumNameOk.OnMouseLeave := OnBoxMouseLeave;
  FWlAlbumNameOk.OnClick := WlAlbumNameOkClick;

  FWlAlbumDateOk := TWebLink.Create(FCreateAlbumBox);
  FWlAlbumDateOk.Parent := FCreateAlbumBox;
  FWlAlbumDateOk.IconWidth := 16;
  FWlAlbumDateOk.IconHeight := 16;
  FWlAlbumDateOk.LoadFromResource('SERIES_OK');
  FWlAlbumDateOk.Refresh;
  FWlAlbumDateOk.Visible := False;
  FWlAlbumDateOk.Anchors := [akTop, akRight];
  FWlAlbumDateOk.OnMouseEnter := OnBoxMouseEnter;
  FWlAlbumDateOk.OnMouseLeave := OnBoxMouseLeave;
  FWlAlbumDateOk.OnClick := WlAlbumDateOkClick;

  FEdAlbumName := TWatermarkedEdit.Create(FCreateAlbumBox);
  FEdAlbumName.Parent := FCreateAlbumBox;
  FEdAlbumName.Visible := False;
  FEdAlbumName.Anchors := [akTop, akLeft, akRight];
  FEdAlbumName.Left := 3;
  FEdAlbumName.Width := FCreateAlbumBox.ClientWidth - FEdAlbumName.Left - FWlAlbumNameOk.Width - 5;
  FEdAlbumName.OnMouseEnter := OnBoxMouseEnter;
  FEdAlbumName.OnMouseLeave := OnBoxMouseLeave;
  FEdAlbumName.OnExit := WlAlbumNameOkClick;
  FEdAlbumName.OnKeyDown := EdAlbumNameKeyDown;

  FDtpAlbumDate := TDateTimePicker.Create(FCreateAlbumBox);
  FDtpAlbumDate.Parent := FCreateAlbumBox;
  FDtpAlbumDate.Visible := False;
  FDtpAlbumDate.Anchors := [akTop, akLeft, akRight];
  FDtpAlbumDate.Left := 3;
  FDtpAlbumDate.Width := FCreateAlbumBox.ClientWidth - FDtpAlbumDate.Left - FWlAlbumDateOk.Width - 5;
  FDtpAlbumDate.OnMouseEnter := OnBoxMouseEnter;
  FDtpAlbumDate.OnMouseLeave := OnBoxMouseLeave;
  FDtpAlbumDate.OnExit := WlAlbumDateOkClick;
  FDtpAlbumDate.OnKeyDown := DtpAlbumDateKeyDown;

  FWlAlbumNameOk.Left := FEdAlbumName.Left + FEdAlbumName.Width + 3;
  FWlAlbumDateOk.Left := FDtpAlbumDate.Left + FDtpAlbumDate.Width + 3;

  FWlAlbumName := TWebLink.Create(FCreateAlbumBox);
  FWlAlbumName.Parent := FCreateAlbumBox;
  FWlAlbumName.LoadFromResource('SERIES_EDIT');
  FWlAlbumName.LoadImage;
  FWlAlbumName.Visible := False;
  FWlAlbumName.Anchors := [akTop, akLeft, akRight];
  FWlAlbumName.Left := 5;
  FWlAlbumName.OnMouseEnter := OnBoxMouseEnter;
  FWlAlbumName.OnMouseLeave := OnBoxMouseLeave;
  FWlAlbumName.OnClick := WlAlbumNameClick;

  FWlAlbumDate := TWebLink.Create(FCreateAlbumBox);
  FWlAlbumDate.Parent := FCreateAlbumBox;
  FWlAlbumDate.LoadFromResource('SERIES_DATE');
  FWlAlbumDate.LoadImage;
  FWlAlbumDate.Visible := False;
  FWlAlbumDate.Anchors := [akTop, akLeft, akRight];
  FWlAlbumDate.Left := 5;
  FWlAlbumDate.OnMouseEnter := OnBoxMouseEnter;
  FWlAlbumDate.OnMouseLeave := OnBoxMouseLeave;
  FWlAlbumDate.OnClick := WlAlbumDateClick;

  FWlAlbumSettings := TWebLink.Create(FCreateAlbumBox);
  FWlAlbumSettings.Parent := FCreateAlbumBox;
  FWlAlbumSettings.IconWidth := 16;
  FWlAlbumSettings.IconHeight := 16;
  FWlAlbumSettings.LoadFromResource('SERIES_SETTINGS');
  FWlAlbumSettings.LoadImage;
  FWlAlbumSettings.Anchors := [akBottom, akRight];
  FWlAlbumSettings.Left := FCreateAlbumBox.ClientWidth - FWlAlbumSettings.Width;
  FWlAlbumSettings.Top := FCreateAlbumBox.ClientHeight - FWlAlbumSettings.Height - 3;
  FWlAlbumSettings.OnMouseEnter := OnBoxMouseEnter;
  FWlAlbumSettings.OnMouseLeave := OnBoxMouseLeave;
  FWlAlbumSettings.PopupMenu := PmAlbumAccess;
  FWlAlbumSettings.OnClick := WlAlbumSettingsClick;
  FWlAlbumSettings.Visible := False;

  VertIncrement := (FCreateAlbumBox.ClientHeight - FEdAlbumName.Height - FDtpAlbumDate.Height) div 2;

  FEdAlbumName.Top := VertIncrement div 2;
  FDtpAlbumDate.Top := VertIncrement div 2 + FEdAlbumName.Height + VertIncrement;

  FWlAlbumNameOk.Top := FEdAlbumName.Top + FEdAlbumName.Height div 2 - FWlAlbumNameOk.Height div 2;
  FWlAlbumDateOk.Top := FDtpAlbumDate.Top + FDtpAlbumDate.Height div 2 - FWlAlbumDateOk.Height div 2;

  FWlAlbumName.Top := FWlAlbumNameOk.Top + 2;
  FWlAlbumDate.Top := FWlAlbumDateOk.Top - 2;

  StatDate := FFiles.StatDate;
  if YearOf(StatDate) < 2000 then
    StatDate := DateOf(Now);

  FDtpAlbumDate.Date := StatDate;
  FEdAlbumName.Text := FormatDateTimeShortDate(StatDate);

  FWlAlbumName.Text := FEdAlbumName.Text;
  FWlAlbumDate.Text := FormatDateTimeShortDate(StatDate);

  CreateAlbumBoxResize(Self);
end;

procedure TFormSharePhotos.DeleteItemFromList(Sender: TObject);
var
  MI: TMenuItem;
  Sb: TBox;
  Info: TDBPopupMenuInfoRecord;
  I, Top: Integer;
  Box: TBox;
begin
  MI := TMenuItem(Sender);
  Sb := TBox(MI.Tag);

  Info := TDBPopupMenuInfoRecord(Sb.Tag);

  for I := 0 to FFiles.Count - 1 do
  begin
    if FFiles[I] = Info then
    begin
      FFiles.Delete(I);
      Sb.Free;
      Break;
    end;
  end;

  Top := 3;
  for I := 0 to SbItemsToUpload.ControlCount - 1 do
  begin
    if SbItemsToUpload.Controls[I] is TBox then
    begin
      Box := TBox(SbItemsToUpload.Controls[I]);
      Box.Top := Top - SbItemsToUpload.VertScrollBar.Position;
      Top := Box.Top + Box.Height + 3;
    end;
  end;

  BtnShare.Enabled := FFiles.Count > 0;
end;

procedure TFormSharePhotos.ItemContexPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  Info: TDBPopupMenuInfo;
  Menus: TArMenuItem;
  Sb: TBox;
  Rec: TDBPopupMenuInfoRecord;
  FileList: TStrings;
  P: TPoint;
begin
  Handled := True;
  if Sender is TBox then
    Sb := TBox(Sender)
  else
    Sb := TBox(TWinControl(Sender).Parent);

  P := TWinControl(Sender).ClientToScreen(MousePos);

  Rec := TDBPopupMenuInfoRecord(Sb.Tag);

  Info := TDBPopupMenuInfo.Create;
  try

    if IsGraphicFile(Rec.FileName) then
    begin
      Info.Add(Rec.Copy);
      Info.IsPlusMenu := False;
      Info.IsListItem := False;
      Setlength(Menus, 1);
      Menus[0] := TMenuItem.Create(nil);
      Menus[0].Caption := L('Delete item from list');
      Menus[0].Tag := Integer(Sb);
      Menus[0].ImageIndex := DB_IC_DELETE_INFO;
      Menus[0].OnClick := DeleteItemFromList;

      TDBPopupMenu.Instance.ExecutePlus(Self, P.X, P.Y, Info, Menus);
    end else
    begin
      FileList := TStringList.Create;
      try
        FileList.Add(Rec.FileName);
        GetProperties(FileList, MousePos, TWinControl(Sender));
      finally
        F(FileList);
      end;
    end;
  finally
    F(Info);
  end;
end;

procedure TFormSharePhotos.LoadImageList;
var
  I: Integer;
  Box: TBox;
  Top: Integer;
  Date: TDateTime;
  LsImage, LsUploading: TLoadingSign;
  WlImageName,
  WlImageDate: TWebLink;
  WlProgressState: TWebLink;
begin
  //clear old data
  for I := 0 to FPreviewImages.Count - 1 do
    FPreviewImages[I] := False;

  SbItemsToUpload.DisableAlign;
  try
    SbItemsToUpload.VertScrollBar.Position := 0;

    for I := SbItemsToUpload.ControlCount - 1 downto 0 do
    begin
      Box := TBox(SbItemsToUpload.Controls[I]);
      Box.Free;
    end;

    Top := 3;
    for I := 0 to FFiles.Count - 1 do
    begin
      Box := TBox.Create(SbItemsToUpload);
      Box.Parent := SbItemsToUpload;
      Box.Top := Top;
      Box.Height := 41;
      Box.Left := 3;
      Box.Width := SbItemsToUpload.ClientWidth - 5;
      Box.Anchors := [akLeft, akTop, akRight];
      Box.ParentBackground := False;
      Box.OnMouseEnter := OnBoxMouseEnter;
      Box.OnMouseLeave := OnBoxMouseLeave;
      Box.OnClick := ShowImages;
      Box.Tag := NativeInt(FFiles[I]);
      Box.OnContextPopup := ItemContexPopup;

      Top := Box.Top + Box.Height + 3;

      LsImage := TLoadingSign.Create(Box);
      LsImage.Parent := Box;
      LsImage.Left := 3;
      LsImage.Top := 3;
      LsImage.Width := 32;
      LsImage.Height := 32;
      LsImage.FillPercent := 80;
      LsImage.Active := True;
      LsImage.OnMouseEnter := OnBoxMouseEnter;
      LsImage.OnMouseLeave := OnBoxMouseLeave;
      LsImage.OnClick := ShowImages;

      WlImageName := TWebLink.Create(Box);
      WlImageName.Parent := Box;
      WlImageName.Left := 41;
      WlImageName.Top := 3;
      WlImageName.IconWidth := 0;
      WlImageName.IconHeight := 0;
      WlImageName.Text := ExtractFileName(FFiles[I].FileName);
      WlImageName.LoadImage;
      WlImageName.OnMouseEnter := OnBoxMouseEnter;
      WlImageName.OnMouseLeave := OnBoxMouseLeave;
      WlImageName.OnClick := ShowImages;

      WlImageDate := TWebLink.Create(Box);
      WlImageDate.Parent := Box;
      WlImageDate.Left := 41;
      WlImageDate.Top := 22;
      WlImageDate.IconWidth := 0;
      WlImageDate.IconHeight := 0;

      Date := FFiles[I].Date;
      if YearOf(Date) < 2000 then
        Date := Now;
      WlImageDate.Text := FormatDateTimeShortDate(Date);

      WlImageDate.LoadImage;
      WlImageDate.OnMouseEnter := OnBoxMouseEnter;
      WlImageDate.OnMouseLeave := OnBoxMouseLeave;
      WlImageDate.OnClick := ShowImages;

      WlProgressState := TWebLink.Create(Box);
      WlProgressState.Parent := Box;
      WlProgressState.Text := '0%';
      WlProgressState.IconWidth := 0;
      WlProgressState.IconHeight := 0;
      WlProgressState.LoadImage;
      WlProgressState.Top := Box.ClientHeight - WlProgressState.Height - 3;
      WlProgressState.Left := Box.ClientWidth - WlProgressState.Width - 2;
      WlProgressState.Anchors := [akTop, akRight];
      WlProgressState.OnMouseEnter := OnBoxMouseEnter;
      WlProgressState.OnMouseLeave := OnBoxMouseLeave;
      WlProgressState.OnClick := SelectAlbumClick;
      WlProgressState.Visible := False;
      WlProgressState.Tag := CONTROL_ITEM_UPLOADING_INFO;

      LsUploading := TLoadingSign.Create(Box);
      LsUploading.Parent := Box;
      LsUploading.Top := WlProgressState.Top - 1;
      LsUploading.Width := 16;
      LsUploading.Height := 16;
      LsUploading.FillPercent := 60;
      LsUploading.Left := WlProgressState.Left - LsUploading.Width;
      LsUploading.Anchors := [akTop, akRight];
      LsUploading.Active := True;
      LsUploading.OnMouseEnter := OnBoxMouseEnter;
      LsUploading.OnMouseLeave := OnBoxMouseLeave;
      LsUploading.OnClick := SelectAlbumClick;
      LsUploading.Visible := False;
      LsUploading.Tag := CONTROL_ITEM_UPLOADING_STATE;
    end;

  finally
    SbItemsToUpload.EnableAlign;
  end;

  for I := 0 to ProcessorCount do
    TShareImagesThread.Create(Self, FProvider, True);
end;

procedure TFormSharePhotos.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Share photos and videos');
    WlChangeUser.Text := L('Change user');

    BtnSettings.Caption := L('Settings');
    BtnCancel.Caption := L('Cancel');
    BtnShare.Caption := L('Share!');
    LbAlbumList.Caption := L('Album list') + ':';
    LbItems.Caption := L('Items to upload') + ':';
    MiRefreshAlbums.Caption := L('Refresh albums');

    MiPublic.Caption := L('Public on web');
    MiProtected.Caption := L('Limited, anyone with the link');
    MiPrivate.Caption := L('Only you');

    MiShowInBrowser.Caption := L('Show in browser');
  finally
    EndTranslate;
  end;
end;

procedure TFormSharePhotos.UpdateAlbumImage(Album: IPhotoServiceAlbum; Image: TBitmap);
var
  I: Integer;
  ImageConrol: TImage;
  Box: TBox;
  LS: TLoadingSign;
begin
  for I := 0 to SbAlbums.ControlCount - 1 do
  begin
    Box := TBox(SbAlbums.Controls[I]);
    if Box.Tag = Integer(Album) then
    begin
      //replace TLoadingSign to TImage
      LS := Box.FindChildByType<TLoadingSign>();
      if LS <> nil then
      begin
        ImageConrol := TImage.Create(Box);
        ImageConrol.Parent := Box;
        ImageConrol.Center := True;
        ImageConrol.Proportional := True;
        ImageConrol.SetBounds(LS.Left, LS.Top, LS.Width, LS.Height);
        ImageConrol.OnMouseEnter := OnBoxMouseEnter;
        ImageConrol.OnMouseLeave := OnBoxMouseLeave;
        ImageConrol.OnClick := SelectAlbumClick;
        LS.Free;
      end else
        ImageConrol := Box.FindChildByType<TImage>();

      if ImageConrol <> nil then
        ImageConrol.Picture.Graphic := Image;
    end;
  end;
end;

procedure TFormSharePhotos.UpdatePreview(Data: TDBPopupMenuInfoRecord;
  Preview: TGraphic);
var
  I: Integer;
  LS: TLoadingSign;
  ImageConrol: TImage;
  Box: TBox;
  FileName: string;
begin
  FileName := AnsiLowerCase(Data.FileName);
  for I := 0 to FFiles.Count - 1 do
    if AnsiLowerCase(FFiles[I].FileName) = FileName then
    begin
      Box := TBox(SbItemsToUpload.Controls[I]);
      LS := Box.FindChildByType<TLoadingSign>();
      if LS <> nil then
      begin
        ImageConrol := TImage.Create(Box);
        ImageConrol.Parent := Box;
        ImageConrol.Center := True;
        ImageConrol.Proportional := True;
        ImageConrol.SetBounds(LS.Left, LS.Top, LS.Width, LS.Height);
        ImageConrol.OnMouseEnter := OnBoxMouseEnter;
        ImageConrol.OnMouseLeave := OnBoxMouseLeave;
        ImageConrol.OnClick := ShowImages;
        ImageConrol.Picture.Graphic := Preview;
        LS.Free;
      end;
      Break;
    end;
end;

procedure TFormSharePhotos.UpdateUserInfo(Provider: IPhotoShareProvider;
  Info: IPhotoServiceUserInfo);
var
  S: string;
begin
  FProvider := Provider;

  FUserUrl := Info.HomeUrl;
  S := Provider.GetProviderName;
  if Info.AvailableSpace > -1 then
    S := S + ' ' + FormatEx(L('(Available space: {0})'), [SizeInText(Info.AvailableSpace)]);
  LbProviderInfo.Caption := S;

  WlUserName.Text := Info.UserDisplayName;
  WlUserName.LoadImage;
  WlUserName.Left := LsAuthorisation.Left - WlUserName.Width - 5;
  WlUserName.Show;
  WlChangeUser.LoadImage;
  WlChangeUser.Left := LsAuthorisation.Left - WlChangeUser.Width - 5;
  WlChangeUser.Show;

  TThreadTask.Create(Self, Info,
    procedure(Thread: TThreadTask; Data: Pointer)
    var
      B: TBitmap;
    begin
      B := TBitmap.Create;
      try
        if IPhotoServiceUserInfo(Data).GetUserAvatar(B) then
        begin
          Thread.SynchronizeTask(
            procedure
            begin
              LsAuthorisation.Hide;
              ImAvatar.Picture.Graphic := B;
            end
          );
        end;
      finally
        F(B);
      end;
    end
  );

  EnableControls(True);

  LoadAlbumList(Provider);
end;

procedure TFormSharePhotos.WlAlbumDateClick(Sender: TObject);
begin
  FWlAlbumDateOk.Show;
  FDtpAlbumDate.Show;
  FWlAlbumDate.Hide;
  FWlAlbumSettings.Hide;

  FDtpAlbumDate.SetFocus;
  SelectAlbumClick(Sender);
end;

procedure TFormSharePhotos.WlAlbumDateOkClick(Sender: TObject);
begin
  FWlAlbumDate.Text := FormatDateTimeShortDate(FDtpAlbumDate.Date);
  FWlAlbumDate.Show;
  FWlAlbumSettings.Show;

  FWlAlbumDateOk.Hide;
  FDtpAlbumDate.Hide;
  SelectAlbumClick(Sender);
end;

procedure TFormSharePhotos.WlAlbumNameClick(Sender: TObject);
begin
  FWlAlbumNameOk.Show;
  FEdAlbumName.Show;
  FWlAlbumName.Hide;

  FEdAlbumName.SetFocus;
  SelectAlbumClick(Sender);
end;

procedure TFormSharePhotos.WlAlbumNameOkClick(Sender: TObject);
begin
  FWlAlbumName.Text := FEdAlbumName.Text;
  FWlAlbumName.Show;

  FWlAlbumNameOk.Hide;
  FEdAlbumName.Hide;
  SelectAlbumClick(Sender);
end;

procedure TFormSharePhotos.WlAlbumSettingsClick(Sender: TObject);
var
  P: TPoint;
begin
  GetCursorPos(P);
  PmAlbumAccess.Popup(P.X, P.Y);
end;

procedure TFormSharePhotos.WlChangeUserClick(Sender: TObject);
begin
  if FProvider <> nil then
    if FProvider.ChangeUser then
    begin
      LoadProviderInfo;
      ReloadAlbums;
    end;
end;

procedure TFormSharePhotos.WlCreateAlbumNameClick(Sender: TObject);
begin
  FWlCreateAlbumName.Hide;
  FEdAlbumName.Show;
  FWlAlbumDate.Show;
  FWlAlbumNameOk.Show;
  FEdAlbumName.SelectAll;
  FEdAlbumName.SetFocus;
  FWlAlbumSettings.Show;
  SelectAlbumClick(Sender);
end;

procedure TFormSharePhotos.WlUserNameClick(Sender: TObject);
begin
  if FUserUrl <> '' then
    ShellExecute(GetActiveWindow, 'open', PWideChar(FUserUrl), nil, nil, SW_NORMAL);
end;

procedure TFormSharePhotos.ErrorLoadingInfo;
begin
  Close;
end;

procedure TFormSharePhotos.LoadAlbumList(Provider: IPhotoShareProvider);
var
  I: Integer;
  Box: TBox;
begin
  SbAlbums.DisableAlign;
  try
    //clear old data
    for I := SbAlbums.ControlCount - 1 downto 0 do
    begin
      if SbAlbums.Controls[I] is TBox then
      begin
        Box := TBox(SbAlbums.Controls[I]);
        if Box.Tag <> 0 then
          Box.Free;
      end;
    end;
    FAlbums.Clear;

    SbAlbums.VertScrollBar.Position := 0;

    //load albums
    LsLoadingAlbums.Show;

    TThreadTask.Create(Self, Provider,
      procedure(Thread: TThreadTask; Data: Pointer)
      var
        Albums: TList<IPhotoServiceAlbum>;
      begin
        Albums := TList<IPhotoServiceAlbum>.Create;
        try
          if IPhotoShareProvider(Data).GetAlbumList(Albums) then
          begin
            Thread.SynchronizeTask(
              procedure
              begin
                FillAlbumList(Albums);
              end
            );
          end;
        finally
          F(Albums);
        end;
      end
    );
  finally
    SbAlbums.EnableAlign;
  end;
  SbAlbums.Repaint;
end;

procedure TFormSharePhotos.FillAlbumList(Albums: TList<IPhotoServiceAlbum>);
var
  I: Integer;
  Box: TBox;
  Top: Integer;
  LsImage: TLoadingSign;
  LbName, LbDate: TLabel;
  ThreadData: TList<IPhotoServiceAlbum>;
  CacheFileName: string;
  B: TBitmap;
  ImImage: TImage;
begin
  FAlbums.Clear;
  FAlbums.AddRange(Albums);
  LsLoadingAlbums.Hide;

  SbAlbums.DisableAlign;
  try
    SbAlbums.VertScrollBar.Position := 0;
    Top := IIF(FCreateAlbumBox.Visible, FCreateAlbumBox.Top + FCreateAlbumBox.Height, 0) + 5;
    for I := 0 to FAlbums.Count - 1 do
    begin
      CacheFileName := AlbumCacheDirectory + '\' + Albums[I].AlbumID + '.bmp';

      Box := TBox.Create(SbAlbums);
      Box.Parent := SbAlbums;
      Box.Top := Top;
      Box.Height := 41;
      Box.Left := FCreateAlbumBox.Left;
      Box.Width := SbAlbums.ClientWidth - 5;
      Box.Anchors := FCreateAlbumBox.Anchors;
      Box.ParentBackground := False;
      Box.OnMouseEnter := OnBoxMouseEnter;
      Box.OnMouseLeave := OnBoxMouseLeave;
      Box.Tag := Integer(FAlbums[I]);
      Box.OnClick := SelectAlbumClick;
      Box.OnDblClick := ShowAlbumClick;
      Box.PopupMenu := PmAlbumOptions;

      Top := Box.Top + Box.Height + 5;

      ImImage := nil;
      if FileExistsSafe(CacheFileName) then
      begin
        B := TBitmap.Create;
        try
          try
            B.LoadFromFile(CacheFileName);

            ImImage := TImage.Create(Box);
            ImImage.Parent := Box;
            ImImage.Center := True;
            ImImage.Proportional := True;
            ImImage.Left := 4;
            ImImage.Top := 4;
            ImImage.Width := 32;
            ImImage.Height := 32;
            ImImage.OnMouseEnter := OnBoxMouseEnter;
            ImImage.OnMouseLeave := OnBoxMouseLeave;
            ImImage.OnClick := SelectAlbumClick;
            ImImage.Picture.Graphic := B;

          except
            on e: Exception do
              EventLog(e);
          end;
        finally
          F(B);
        end;
      end else

      if ImImage = nil then
      begin
        LsImage := TLoadingSign.Create(Box);
        LsImage.Parent := Box;
        LsImage.Left := 4;
        LsImage.Top := 4;
        LsImage.Width := 32;
        LsImage.Height := 32;
        LsImage.FillPercent := 80;
        LsImage.Active := True;
        LsImage.OnMouseEnter := OnBoxMouseEnter;
        LsImage.OnMouseLeave := OnBoxMouseLeave;
        LsImage.OnClick := SelectAlbumClick;
        LsImage.OnDblClick := ShowAlbumClick;
      end;

      LbName := TLabel.Create(Box);
      LbName.Parent := Box;
      LbName.Left := 41;
      LbName.Top := 3;
      LbName.Caption := FAlbums[I].Name;
      LbName.OnMouseEnter := OnBoxMouseEnter;
      LbName.OnMouseLeave := OnBoxMouseLeave;
      LbName.OnClick := SelectAlbumClick;
      LbName.OnDblClick := ShowAlbumClick;
              
      LbDate := TLabel.Create(Box);
      LbDate.Parent := Box;
      LbDate.Left := 41;
      LbDate.Top := 22;
      LbDate.Caption := FormatDateTimeShortDate(FAlbums[I].Date);
      LbDate.OnMouseEnter := OnBoxMouseEnter;
      LbDate.OnMouseLeave := OnBoxMouseLeave;
      LbDate.OnClick := SelectAlbumClick;
      LbDate.OnDblClick := ShowAlbumClick;
    end;
  finally
    SbAlbums.EnableAlign;
  end;

  //data for loading images thread
  ThreadData := TList<IPhotoServiceAlbum>.Create;
  ThreadData.AddRange(FAlbums);

  TThreadTask.Create(Self, ThreadData,
    procedure(Thread: TThreadTask; Data: Pointer)
    var
      I: Integer;
      B: TBitmap;
      Albums: TList<IPhotoServiceAlbum>;
      HttpContainer: THTTPRequestContainer;
      CacheFileName: string;
    begin
      Albums := TList<IPhotoServiceAlbum>(Data);

      CreateDirA(AlbumCacheDirectory);

      HttpContainer := THTTPRequestContainer.Create;
      try
        for I := 0 to Albums.Count - 1 do
        begin
          if Thread.IsTerminated then
            Break;
          B := TBitmap.Create;
          try
            if Albums[I].GetPreview(B, HttpContainer) then
            begin
              KeepProportions(B, 32, 32);

              Thread.SynchronizeTask(
                procedure
                begin
                  UpdateAlbumImage(Albums[I], B);
                end
              );

              CacheFileName := AlbumCacheDirectory + '\' + Albums[I].AlbumID + '.bmp';
              if Albums[I].Access <> PHOTO_PROVIDER_ALBUM_PRIVATE then
              begin
                //save album cover to cache
                B.SaveToFile(CacheFileName);
              end else
                //delete private cover
                DeleteFile(CacheFileName);

            end;
          finally
            F(B);
          end;
        end;
      finally
        F(HttpContainer);
      end;

      F(ThreadData);
    end
  );
end;

procedure TFormSharePhotos.LoadProviderInfo;
var
  Providers: TList<IPhotoShareProvider>;
  Provider: IPhotoShareProvider;
  B: TBitmap;
begin
  Providers := TList<IPhotoShareProvider>.Create;
  try
    PhotoShareManager.FillProviders(Providers);
    Provider := Providers[0];

    B := TBitmap.Create;
    try
      if Provider.GetProviderImage(B) then
       ImProviderImage.Picture.Graphic := B;
    finally
      F(B);
    end;
    LbProviderInfo.Caption := Provider.GetProviderName;

    TThreadTask.Create(Self, nil,
      procedure(Thread: TThreadTask; Data: Pointer)
      var
        Info: IPhotoServiceUserInfo;
      begin
        if Provider.GetUserInfo(Info) then
        begin
          Thread.SynchronizeTask(
            procedure
            begin
              UpdateUserInfo(Provider, Info);
            end
          );
        end else
        begin
          Thread.SynchronizeTask(
            procedure
            begin
              ErrorLoadingInfo;
            end
          );
        end;
      end
    );

  finally
    F(Providers);
  end;
end;

procedure TFormSharePhotos.MiPrivateClick(Sender: TObject);
begin
  FAlbumAccess := PHOTO_PROVIDER_ALBUM_PRIVATE;
  TMenuItem(Sender).Checked := True;
end;

procedure TFormSharePhotos.MiProtectedClick(Sender: TObject);
begin
  FAlbumAccess := PHOTO_PROVIDER_ALBUM_PROTECTED;
  TMenuItem(Sender).Checked := True;
end;

procedure TFormSharePhotos.MiPublicClick(Sender: TObject);
begin
  FAlbumAccess := PHOTO_PROVIDER_ALBUM_PUBLIC;
  TMenuItem(Sender).Checked := True;
end;

procedure TFormSharePhotos.MiRefreshAlbumsClick(Sender: TObject);
begin
  ReloadAlbums;
end;

procedure TFormSharePhotos.MiShowInBrowserClick(Sender: TObject);
var
  Album: IPhotoServiceAlbum;
begin
  if PmAlbumOptions.PopupComponent <> nil then
  begin
    Album := IPhotoServiceAlbum(PmAlbumOptions.PopupComponent.Tag);

    if Album.Url <> '' then
      ShellExecute(GetActiveWindow, 'open', PWideChar(Album.Url), nil, nil, SW_NORMAL);
  end;
end;

procedure TFormSharePhotos.OnBoxMouseEnter(Sender: TObject);
var
  Sb: TBox;
begin
  if Sender is TBox then
    Sb := TBox(Sender)
  else
    Sb := TBox(TWinControl(Sender).Parent);

  Sb.IsHovered := True;
end;

procedure TFormSharePhotos.OnBoxMouseLeave(Sender: TObject);
var
  Sb: TBox;
begin
  if Sender is TBox then
    Sb := TBox(Sender)
  else
    Sb := TBox(TWinControl(Sender).Parent);

  Sb.IsHovered := False;
end;

procedure TFormSharePhotos.ReloadAlbums;
begin
  LoadAlbumList(FProvider);
end;

procedure TFormSharePhotos.SelectAlbumClick(Sender: TObject);
var
  Sb: TBox;
  I: Integer;
begin
  if FIsWorking then
    Exit;

  if Sender is TBox then
    Sb := TBox(Sender)
  else
    Sb := TBox(TWinControl(Sender).Parent);

  for I := 0 to SbAlbums.ControlCount - 1 do
    if (SbAlbums.Controls[I] <> Sb) and (SbAlbums.Controls[I] is TBox) then
      TBox(SbAlbums.Controls[I]).IsSelected := False;

  Sb.IsSelected := True;
end;

procedure TFormSharePhotos.ShowAlbumClick(Sender: TObject);
var
  Sb: TBox;
  Album: IPhotoServiceAlbum;
begin
  if Sender is TBox then
    Sb := TBox(Sender)
  else
    Sb := TBox(TWinControl(Sender).Parent);

  Album := IPhotoServiceAlbum(Sb.Tag);

  if Album.Url <> '' then
    ShellExecute(GetActiveWindow, 'open', PWideChar(Album.Url), nil, nil, SW_NORMAL);
end;

procedure TFormSharePhotos.ShowImages(Sender: TObject);
var
  Sb: TBox;
  I: Integer;
  MI: TDBPopupMenuInfoRecord;
  ShellDir, CurrentFileName: string;
begin
  if Sender is TBox then
    Sb := TBox(Sender)
  else
    Sb := TBox(TWinControl(Sender).Parent);

  MI := TDBPopupMenuInfoRecord(Sb.Tag);
  for I := 0 to FFiles.Count - 1 do
    if FFiles[I] = MI then
    begin
      FFiles.Position := I;
      Break;
    end;

  CurrentFileName := FFiles[FFiles.Position].FileName;
  if not IsGraphicFile(CurrentFileName) then
  begin
    ShellDir := ExtractFileDir(CurrentFileName);
    ShellExecute(Handle, 'open', PWideChar(CurrentFileName), nil, PWideChar(ShellDir), SW_NORMAL);
    Exit;
  end;

  if Viewer = nil then
    Application.CreateForm(TViewer, Viewer);

  Viewer.Execute(Self, FFiles);
  Viewer.Show;
end;

procedure TFormSharePhotos.SplAlbumsCanResize(Sender: TObject;
  var NewSize: Integer; var Accept: Boolean);
begin
  Accept := (NewSize > 160) and (NewSize < 400);
end;

procedure TFormSharePhotos.EndProcessing(Data: TDBPopupMenuInfoRecord; ErrorInfo: string);
var
  Box: TBox;
  LS: TLoadingSign;
  WlInfo: TWebLink;
begin
  Box := ItemBlock[Data];
  if Box = nil then
    Exit;

  LS := Box.FindChildByTag<TLoadingSign>(CONTROL_ITEM_UPLOADING_STATE);
  WlInfo := Box.FindChildByTag<TWebLink>(CONTROL_ITEM_UPLOADING_INFO);

  LS.Hide;
  WlInfo.IconWidth := 16;
  WlInfo.IconHeight := 16;
  WlInfo.LoadFromResource('SERIES_OK');
  WlInfo.Text := '';
  WlInfo.Top := Box.ClientHeight - WlInfo.Height - 3;
  WlInfo.Left := Box.ClientWidth - WlInfo.Width - 4;
end;

procedure TFormSharePhotos.StartProcessing(Data: TDBPopupMenuInfoRecord);
var
  Box: TBox;
  LS: TLoadingSign;
  WlInfo: TWebLink;
begin
  Box := ItemBlock[Data];
  if Box = nil then
    Exit;

  LS := Box.FindChildByTag<TLoadingSign>(CONTROL_ITEM_UPLOADING_STATE);
  WlInfo := Box.FindChildByTag<TWebLink>(CONTROL_ITEM_UPLOADING_INFO);
  WlInfo.IconWidth := 0;
  WlInfo.IconHeight := 0;
  WlInfo.Text := '0%';
  WlInfo.Left := Box.ClientWidth - WlInfo.Width - 4;
  LS.Left := WlInfo.Left - LS.Width;

  LS.Show;
  WlInfo.Show;
end;

procedure TFormSharePhotos.NotifyItemProgress(Data: TDBPopupMenuInfoRecord; Max, Position: Int64);
var
  Box: TBox;
  LS: TLoadingSign;
  WlInfo: TWebLink;
begin
  Box := ItemBlock[Data];
  if Box = nil then
    Exit;

  if Max > 0 then
  begin
    LS := Box.FindChildByTag<TLoadingSign>(CONTROL_ITEM_UPLOADING_STATE);
    WlInfo := Box.FindChildByTag<TWebLink>(CONTROL_ITEM_UPLOADING_INFO);

    WlInfo.Text := IntToStr(Round(100 * Position / Max)) + '%';
    WlInfo.Left := Box.ClientWidth - WlInfo.Width - 4;

    LS.Left := WlInfo.Left - LS.Width;
  end;
end;

end.
