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
  LoadingSign,
  Vcl.Imaging.GIFImg,
  Dolphin_DB,
  uMemory,
  uMemoryEx,
  uSysUtils,
  uDBForm,
  uThreadEx,
  uThreadTask,
  uThreadForm,
  uPhotoShareInterfaces;

type
  TFormSharePhotos = class(TThreadForm)
    ImProviderImage: TImage;
    WlUserName: TWebLink;
    WlUserAction: TWebLink;
    ImAvatar: TImage;
    LbProviderInfo: TLabel;
    BtnShare: TButton;
    BtnCancel: TButton;
    SbAlbums: TScrollBox;
    LbAlbumList: TLabel;
    ProgressBar1: TProgressBar;
    Panel1: TPanel;
    Panel2: TPanel;
    Image4: TImage;
    Label4: TLabel;
    Label5: TLabel;
    Panel3: TPanel;
    Image5: TImage;
    Label6: TLabel;
    Label7: TLabel;
    Panel4: TPanel;
    Image6: TImage;
    Label8: TLabel;
    Label9: TLabel;
    Panel5: TPanel;
    Image7: TImage;
    Label10: TLabel;
    Label11: TLabel;
    Panel6: TPanel;
    Image8: TImage;
    Label12: TLabel;
    Label13: TLabel;
    Panel7: TPanel;
    Image9: TImage;
    Label14: TLabel;
    Label15: TLabel;
    WebLink1: TWebLink;
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
    procedure BtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure LoadLanguage;
    procedure EnableControls(Value: Boolean);
    procedure LoadProviderInfo;
    procedure UpdateUserInfo(Provider: IPhotoShareProvider; Info: IPhotoServiceUserInfo);
    procedure ErrorLoadingInfo;
  protected
    { Protected declarations }
    function GetFormID: string; override;
    procedure Execute(FileList: TStrings);
  public
    { Public declarations }
  end;

procedure SharePictures(Owner: TDBForm; List: TStrings);
function CanShareVideo(FileName: string): Boolean;

implementation

{$R *.dfm}

function CanShareVideo(FileName: string): Boolean;
begin
  Result := False;
end;

procedure SharePictures(Owner: TDBForm; List: TStrings);
var
  FormSharePhotos: TFormSharePhotos;
begin
  FormSharePhotos := TFormSharePhotos.Create(Owner);
  try
    FormSharePhotos.Execute(List);
  finally
    R(FormSharePhotos);
  end;
end;

procedure TFormSharePhotos.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormSharePhotos.EnableControls(Value: Boolean);
begin
  BtnShare.Enabled := Value;
  WlUserName.Enabled := Value;
  WlUserAction.Enabled := Value;
end;

procedure TFormSharePhotos.Execute(FileList: TStrings);
begin
  LoadProviderInfo;
  ShowModal;
end;

procedure TFormSharePhotos.FormCreate(Sender: TObject);
begin
  LoadLanguage;
  EnableControls(False);
end;

function TFormSharePhotos.GetFormID: string;
begin
  Result := 'PhotoShare';
end;

procedure TFormSharePhotos.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Share photos and videos');
  finally
    EndTranslate;
  end;
end;

procedure TFormSharePhotos.UpdateUserInfo(Provider: IPhotoShareProvider; Info: IPhotoServiceUserInfo);
var
  B: TBitmap;
  S: string;
begin
  LsAuthorisation.Hide;
  B := TBitmap.Create;
  try
    if Info.GetUserAvatar(B) then
     ImAvatar.Picture.Graphic := B;
  finally
    F(B);
  end;

  B := TBitmap.Create;
  try
    if Provider.GetProviderImage(B) then
     ImProviderImage.Picture.Graphic := B;
  finally
    F(B);
  end;

  S := Provider.GetProviderName;
  if Info.AvailableSpace > -1 then
    S := S + ' ' + FormatEx(L('(Available space: {0})'), [SizeInText(Info.AvailableSpace)]);
  LbProviderInfo.Caption := S;
  LbProviderInfo.Show;
  WlUserName.Text := Info.UserDisplayName;
  WlUserName.Left := ImAvatar.Left - WlUserName.Width - 5;

  EnableControls(True);
end;

procedure TFormSharePhotos.ErrorLoadingInfo;
begin
  Close;
end;

procedure TFormSharePhotos.LoadProviderInfo;
begin
  TThreadTask.Create(Self,
    procedure(Thread: TThreadTask)
    var
      Providers: TList<IPhotoShareProvider>;
      Provider: IPhotoShareProvider;
      Info: IPhotoServiceUserInfo;
    begin
      Providers := TList<IPhotoShareProvider>.Create;
      try
        PhotoShareManager.FillProviders(Providers);
        Provider := Providers[0];
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
      finally
        F(Providers);
      end;
    end
  );
end;

end.
