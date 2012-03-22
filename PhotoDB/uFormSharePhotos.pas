unit uFormSharePhotos;

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
  uBaseWinControl,
  WebLink,
  Vcl.Imaging.pngimage,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  LoadingSign,
  Vcl.Imaging.GIFImg,
  uMemory,
  uMemoryEx,
  uDBForm;

type
  TFormSharePhotos = class(TDBForm)
    ImProviderImage: TImage;
    WlUserName: TWebLink;
    WlUserAction: TWebLink;
    Image2: TImage;
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
  private
    { Private declarations }
    procedure LoadLanguage;
  protected
    { Protected declarations }
    function GetFormID: string; override;
    procedure Execute(FileList: TStrings);
  public
    { Public declarations }
  end;

procedure SharePictures(Owner: TDBForm; List: TStrings);

implementation

{$R *.dfm}

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

procedure TFormSharePhotos.Execute(FileList: TStrings);
begin
  ShowModal;
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

end.
