unit uFormCreatePerson;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, WatermarkedEdit, ExtCtrls, WatermarkedMemo, ComCtrls,
  WebLinkList, uFaceDetection, uPeopleSupport, uMemory, uMemoryEx, jpeg,
  uBitmapUtils, uDBThread, uDBForm, LoadingSign, u2DUtils, uSettings, Menus;

type
  TFormCreatePerson = class(TDBForm)
    PbPhoto: TPaintBox;
    LbName: TLabel;
    BvSeparator: TBevel;
    WedName: TWatermarkedEdit;
    LbComments: TLabel;
    WmComments: TWatermarkedMemo;
    BtnOk: TButton;
    BtnCancel: TButton;
    WllGroups: TWebLinkList;
    LbGroups: TLabel;
    LbBirthDate: TLabel;
    DtpBirthDay: TDateTimePicker;
    LsExtracting: TLoadingSign;
    PmImageOptions: TPopupMenu;
    Loadotherimage1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PbPhotoPaint(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BtnOkClick(Sender: TObject);
  private
    { Private declarations }
    FPicture: TBitmap;
    FDisplayImage: TBitmap;
    FOriginalFace: TFaceDetectionResultItem;
    FImageID: Integer;
    procedure Execute(ImageID: Integer; OriginalFace, FaceInImage: TFaceDetectionResultItem; Bitmap: TBitmap);
    procedure RecreateImage;
    procedure UpdateFaceArea(Face: TFaceDetectionResultItem);
    procedure LoadLanguage;
  protected
    function GetFormID: string; override;
  public
    { Public declarations }
  end;

  TPersonExtractor = class(TDBThread)
  private
    FBitmap: TBitmap;
    FFaces: TFaceDetectionResult;
    FOwner: TFormCreatePerson;
    FFace: TFaceDetectionResultItem;
    procedure UpdatePicture;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TFormCreatePerson; AFace: TFaceDetectionResultItem; Src: TBitmap);
    destructor Destroy; override;
  end;

procedure CreatePerson(ImageID: Integer; OriginalFace, FaceInImage: TFaceDetectionResultItem; Bitmap: TBitmap; out Person: TPerson);

implementation

{$R *.dfm}

procedure CreatePerson(ImageID: Integer; OriginalFace, FaceInImage: TFaceDetectionResultItem; Bitmap: TBitmap; out Person: TPerson);
var
  FormCreatePerson: TFormCreatePerson;
begin
  Application.CreateForm(TFormCreatePerson, FormCreatePerson);
  try
    FormCreatePerson.Execute(ImageID, OriginalFace, FaceInImage, Bitmap);
  finally
    R(FormCreatePerson);
  end;
end;

{ TFormCreatePerson }

procedure TFormCreatePerson.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormCreatePerson.BtnOkClick(Sender: TObject);
var
  Person: TPerson;
  PersonArea: TPersonArea;
  J: TJpegImage;
begin
  Person := TPerson.Create;
  try
    Person.Name := WedName.Text;
    Person.Birthday := DtpBirthDay.Date;
    //TODO: Person.Groups :=
    Person.Comment := WmComments.Text;
    J := TJPEGImage.Create;
    try
      J.Assign(FPicture);
      Person.Image := J;
    finally
      F(J);
    end;
    PersonManager.CreateNewPerson(Person);

    PersonArea := TPersonArea.Create(FImageID, Person.ID, FOriginalFace);
    try
      PersonManager.AddPersonForPhoto(PersonArea);
    finally
      F(PersonArea);
    end;
  finally
    F(Person);
  end;
end;

procedure TFormCreatePerson.Execute(ImageID: Integer; OriginalFace, FaceInImage: TFaceDetectionResultItem;
  Bitmap: TBitmap);
begin
  FPicture.Assign(Bitmap);
  FOriginalFace := OriginalFace;
  FImageID := ImageID;
  TPersonExtractor.Create(Self, FaceInImage, FPicture);
  RecreateImage;
  ShowModal;
end;

procedure TFormCreatePerson.FormCreate(Sender: TObject);
begin
  FPicture := TBitmap.Create;
  FDisplayImage := TBitmap.Create;
  LoadLanguage;
  PersonManager.InitDB;
end;

procedure TFormCreatePerson.FormDestroy(Sender: TObject);
begin
  F(FPicture);
  F(FDisplayImage);
end;

procedure TFormCreatePerson.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

function TFormCreatePerson.GetFormID: string;
begin
  Result := 'EditPerson';
end;

procedure TFormCreatePerson.LoadLanguage;
begin
  BeginTranslate;
  try
    LbName.Caption := L('Name') + ':';
    LbBirthDate.Caption := L('Birthday') + ':';
    LbGroups.Caption := L('Related groups') + ':';
    LbComments.Caption := L('Comment') + ':';
    WmComments.WatermarkText := L('Comment');
    BtnCancel.Caption := L('Cancel');
    BtnOk.Caption := L('Ok');
  finally
    EndTranslate;
  end;
end;

procedure TFormCreatePerson.PbPhotoPaint(Sender: TObject);
begin
  PbPhoto.Canvas.Draw(PbPhoto.Width div 2 - FDisplayImage.Width div 2,
    PbPhoto.Height div 2 - FDisplayImage.Height div 2, FDisplayImage);
end;

procedure TFormCreatePerson.RecreateImage;
var
  B, SmallB: TBitmap;
  W, H: Integer;
begin
  B := TBitmap.Create;
  try
    B.PixelFormat := pf32bit;
    DrawShadowToImage(B, FPicture);
    W := B.Width;
    H := B.Height;
    ProportionalSize(PbPhoto.Width, PbPhoto.Height, W, H);
    SmallB := TBitmap.Create;
    try
      SmallB.PixelFormat := pf32Bit;
      DoResize(W, H, B, SmallB);
      F(FDisplayImage);
      FDisplayImage := TBitmap.Create;
      LoadBMPImage32bit(SmallB, FDisplayImage, clBtnFace);
    finally
      F(SmallB);
    end;
  finally
    F(B);
  end;
end;

procedure TFormCreatePerson.UpdateFaceArea(Face: TFaceDetectionResultItem);
var
  B: TBitmap;
begin
  LsExtracting.Hide;

  if Face <> nil then
  begin
    B := TBitmap.Create;
    try
      B.SetSize(Face.Width, Face.Height);
      B.Canvas.CopyRect(Rect(0, 0, Face.Width, Face.Height), FPicture.Canvas, Face.Rect);
      Exchange(FPicture, B);
    finally
      F(B);
    end;
    RecreateImage;
    PbPhoto.Refresh;
  end;
end;

{ TPersonExtractor }

constructor TPersonExtractor.Create(AOwner: TFormCreatePerson; AFace: TFaceDetectionResultItem; Src: TBitmap);
begin
  inherited Create(AOwner, False);
  FOwner := AOwner;
  FBitmap := TBitmap.Create;
  FBitmap.Assign(Src);
  FFace := AFace.Copy;
end;

destructor TPersonExtractor.Destroy;
begin
  F(FBitmap);
  F(FFace);
  inherited;
end;

procedure TPersonExtractor.Execute;
var
  W, H: Integer;
  RMp, AMp, RR: Double;
  SmallBitmap: TBitmap;
begin
  inherited;
  FreeOnTerminate := True;
  FFaces := TFaceDetectionResult.Create;
  try

    W := FBitmap.Width;
    H := FBitmap.Height;
    RMp := W * H;
    AMp := Settings.ReadInteger('Options', 'FaceDetectionSize', 3) * 100000;

    if RMp > AMp then
    begin
      RR := Sqrt(RMp / AMp);
      SmallBitmap := TBitmap.Create;
      try
        ProportionalSize(Round(W / RR), Round(H / RR), W, H);
        uBitmapUtils.QuickReduceWide(W, H, FBitmap, SmallBitmap);
        FaceDetectionManager.FacesDetection(SmallBitmap, 0, FFaces, 'haarcascade_head_and_shoulders.xml');
      finally
        F(SmallBitmap);
      end;
    end else
      FaceDetectionManager.FacesDetection(FBitmap, 0, FFaces, 'haarcascade_head_and_shoulders.xml');

    SynchronizeEx(UpdatePicture);
  finally
    F(FFaces);
  end;
end;

procedure TPersonExtractor.UpdatePicture;
var
  I: Integer;
begin
  for I := 0 to FFaces.Count - 1 do
    if RectIntersectWithRectPercent(FFaces[I].Rect, FFace.Rect) > 60 then
    begin
      FOwner.UpdateFaceArea(FFaces[I]);
      Exit;
    end;

  FOwner.UpdateFaceArea(nil);
end;

end.
