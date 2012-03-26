unit uFormSharePhotos;

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
  Vcl.Dialogs,
  uBaseWinControl,
  WebLink,
  Vcl.Imaging.pngimage,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
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
  uDBPopupMenuInfo;

type
  TFormSharePhotos = class(TThreadForm)
    ImProviderImage: TImage;
    WlUserName: TWebLink;
    WlChangeUser: TWebLink;
    ImAvatar: TImage;
    LbProviderInfo: TLabel;
    BtnShare: TButton;
    BtnCancel: TButton;
    SbAlbums: TScrollBox;
    LbAlbumList: TLabel;
    ProgressBar1: TProgressBar;
    PnCreateAlbum: TPanel;
    WlCreateAlbumName: TWebLink;
    SbItemsToUpload: TScrollBox;
    LbItems: TLabel;
    Panel8: TPanel;
    Image3: TImage;
    WebLink4: TWebLink;
    WebLink5: TWebLink;
    LoadingSign1: TLoadingSign;
    WebLink6: TWebLink;
    BtnSettings: TButton;
    LsAuthorisation: TLoadingSign;
    LsLoadingAlbums: TLoadingSign;
    procedure BtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure WlUserNameClick(Sender: TObject);
    procedure WlChangeUserClick(Sender: TObject);
    procedure BtnSettingsClick(Sender: TObject);
  private
    { Private declarations }
    FFiles: TDBPopupMenuInfo;
    FAlbums: TList<IPhotoServiceAlbum>;
    FUserUrl: string;
    FProvider: IPhotoShareProvider;
    procedure LoadLanguage;
    procedure EnableControls(Value: Boolean);
    procedure OnBoxMouseLeave(Sender: TObject);
    procedure OnBoxMouseEnter(Sender: TObject);
    procedure ShowImages(Sender: TObject);

    procedure LoadProviderInfo;
    procedure UpdateUserInfo(Provider: IPhotoShareProvider; Info: IPhotoServiceUserInfo);
    procedure ErrorLoadingInfo;
    procedure LoadImageList;
    procedure LoadAlbumList(Provider: IPhotoShareProvider);
    procedure FillAlbumList(Albums: TList<IPhotoServiceAlbum>);
    procedure UpdateAlbumImage(Album: IPhotoServiceAlbum; Image: TBitmap);
  protected
    { Protected declarations }
    function GetFormID: string; override;
    procedure Execute(FileList: TDBPopupMenuInfo);
  public
    { Public declarations }
  end;

procedure SharePictures(Owner: TDBForm; Info: TDBPopupMenuInfo);
function CanShareVideo(FileName: string): Boolean;

implementation

uses
  SlideShow,
  uShareSettings,
  uShareImagesThread;

{$R *.dfm}

function CanShareVideo(FileName: string): Boolean;
begin
  Result := False;
end;

procedure SharePictures(Owner: TDBForm; Info: TDBPopupMenuInfo);
var
  FormSharePhotos: TFormSharePhotos;
begin
  FormSharePhotos := TFormSharePhotos.Create(Owner);
  try
    FormSharePhotos.Execute(Info);
  finally
    R(FormSharePhotos);
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

procedure TFormSharePhotos.EnableControls(Value: Boolean);
begin
  BtnShare.Enabled := Value;
  WlUserName.Enabled := Value;
  WlChangeUser.Enabled := Value;
end;

procedure TFormSharePhotos.Execute(FileList: TDBPopupMenuInfo);
begin
  FFiles.Assign(FileList);
  LoadImageList;
  LoadProviderInfo;
  ShowModal;
end;

procedure TFormSharePhotos.FormCreate(Sender: TObject);
begin
  FFiles := TDBPopupMenuInfo.Create;
  FAlbums := TList<IPhotoServiceAlbum>.Create;
  LoadLanguage;
  EnableControls(False);
  FProvider := nil;
  PnCreateAlbum.Width := SbAlbums.Width - 10;
end;

procedure TFormSharePhotos.FormDestroy(Sender: TObject);
begin
  F(FAlbums);
  F(FFiles);
end;

procedure TFormSharePhotos.FormResize(Sender: TObject);
begin
  Invalidate;
end;

function TFormSharePhotos.GetFormID: string;
begin
  Result := 'PhotoShare';
end;

procedure TFormSharePhotos.LoadImageList;
var
  I: Integer;
  Box: TBox;
  Top: Integer;
  LsImage: TLoadingSign;
  WlImageName,
  WlImageDate: TWebLink;
begin
  //clear old data
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
    Box.Width := SbItemsToUpload.Width - 7;
    Box.Anchors := [akLeft, akTop, akRight];
    Box.ParentBackground := False;
    Box.OnMouseEnter := OnBoxMouseEnter;
    Box.OnMouseLeave := OnBoxMouseLeave;
    Box.OnClick := ShowImages;
    Box.Tag := NativeInt(FFiles[I]);

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
    WlImageDate.Text := FormatDateTime('yyyy/mm/dd', Now);
    WlImageDate.LoadImage;
    WlImageDate.OnMouseEnter := OnBoxMouseEnter;
    WlImageDate.OnMouseLeave := OnBoxMouseLeave;
    WlImageDate.OnClick := ShowImages;
  end;

  TShareImagesThread.Create(Self, FFiles, True);
end;

procedure TFormSharePhotos.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Share photos and videos');
    WlChangeUser.Text := L('Change user');
    WlCreateAlbumName.Text := L('Create new album');
    BtnSettings.Caption := L('Settings');
    BtnCancel.Caption := L('Cancel');
    BtnShare.Caption := L('Share!');
    LbAlbumList.Caption := L('Album list') + ':';
    LbItems.Caption := L('Items to upload') + ':';
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
        ImageConrol.SetBounds(LS.Left, LS.Top, LS.Width, LS.Height);
        ImageConrol.OnMouseEnter := OnBoxMouseEnter;
        ImageConrol.OnMouseLeave := OnBoxMouseLeave;
        LS.Free;
      end else
        ImageConrol := Box.FindChildByType<TImage>();

      if ImageConrol <> nil then
        ImageConrol.Picture.Graphic := Image;
    end;
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

procedure TFormSharePhotos.WlChangeUserClick(Sender: TObject);
begin
  if FProvider <> nil then
    FProvider.ChangeUser;
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
  //clear old data
  for I := SbAlbums.ControlCount - 1 downto 0 do
  begin
    Box := TBox(SbAlbums.Controls[I]);
    if Box.Tag > 0 then
      Box.Free;
  end;
  FAlbums.Clear;

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
end;

procedure TFormSharePhotos.FillAlbumList(Albums: TList<IPhotoServiceAlbum>);
var
  I: Integer;
  Box: TBox;
  Top: Integer;
  LsImage: TLoadingSign;
  LbName, LbDate: TLabel;
  ThreadData: TList<IPhotoServiceAlbum>;
begin
  FAlbums.Clear;
  FAlbums.AddRange(Albums);
  LsLoadingAlbums.Hide;

  Top := PnCreateAlbum.Top + PnCreateAlbum.Height + 5;
  for I := 0 to FAlbums.Count - 1 do
  begin
    Box := TBox.Create(SbAlbums);
    Box.Parent := SbAlbums;
    Box.Top := Top;
    Box.Height := 41;
    Box.Left := PnCreateAlbum.Left;
    Box.Width := SbAlbums.Width - 10;
    Box.Anchors := PnCreateAlbum.Anchors;
    Box.ParentBackground := False;
    Box.OnMouseEnter := OnBoxMouseEnter;
    Box.OnMouseLeave := OnBoxMouseLeave;
    Box.Tag := Integer(FAlbums[I]);

    Top := Box.Top + Box.Height + 5;

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

    LbName := TLabel.Create(Box);
    LbName.Parent := Box;
    LbName.Left := 41;
    LbName.Top := 3;
    LbName.Caption := FAlbums[I].Name;  
    LbName.OnMouseEnter := OnBoxMouseEnter;
    LbName.OnMouseLeave := OnBoxMouseLeave;
              
    LbDate := TLabel.Create(Box);
    LbDate.Parent := Box;
    LbDate.Left := 41;
    LbDate.Top := 22;
    LbDate.Caption := FormatDateTime('yyyy/mm/dd', FAlbums[I].Date);  
    LbDate.OnMouseEnter := OnBoxMouseEnter;
    LbDate.OnMouseLeave := OnBoxMouseLeave;
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
    begin
      Albums := TList<IPhotoServiceAlbum>(Data);

      for I := 0 to Albums.Count - 1 do
      begin
        B := TBitmap.Create;
        try
          if Albums[I].GetPreview(B) then
          begin
            KeepProportions(B, 32, 32);
            Thread.SynchronizeTask(
              procedure
              begin
                UpdateAlbumImage(Albums[I], B);
              end
            );
          end;
        finally
          F(B);
        end;
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

procedure TFormSharePhotos.ShowImages(Sender: TObject);
var
  Sb: TBox;
  I: Integer;
  MI: TDBPopupMenuInfoRecord;
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

  if Viewer = nil then
    Application.CreateForm(TViewer, Viewer);

  Viewer.Execute(Self, FFiles);
  Viewer.Show;
end;

end.
