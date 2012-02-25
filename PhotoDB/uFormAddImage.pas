unit uFormAddImage;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, LoadingSign, StdCtrls, UnitDBDeclare, uMemory, uMemoryEx,
  UnitDBKernel, uFormUtils, ExtCtrls, uBitmapUtils, uDBForm;

type
  TFormAddingImage = class(TDBForm)
    LbMessage: TLabel;
    LsMain: TLoadingSign;
    TmrRedraw: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TmrRedrawTimer(Sender: TObject);
  private
    FInfo: TDBPopupMenuInfoRecord;
    FLoadingState: Extended;
    { Private declarations }
  protected
    procedure ChangedDBDataByID(Sender: TObject; ID: Integer; params: TEventFields; Value: TEventValues);
    procedure DrawForm;
    function GetFormID: string; override;
  public
    { Public declarations }
    procedure Execute(Info: TDBPopupMenuInfoRecord);
  end;

procedure AddImage(Info: TDBPopupMenuInfoRecord);

implementation

uses
  UnitUpdateDBObject;

procedure AddImage(Info: TDBPopupMenuInfoRecord);
var
  FormAddingImage: TFormAddingImage;
begin
  Application.CreateForm(TFormAddingImage, FormAddingImage);
  try
    FormAddingImage.Execute(Info);
  finally
    R(FormAddingImage);
  end;
end;

{$R *.dfm}

{ TFormAddingImage }

procedure TFormAddingImage.ChangedDBDataByID(Sender: TObject; ID: Integer;
  params: TEventFields; Value: TEventValues);
begin
  if SetNewIDFileData in Params then
  begin
    if AnsiLowerCase(Value.Name) = AnsiLowerCase(FInfo.FileName) then
    begin
      FInfo.ID := Value.ID;
      Close;
    end;

  end;
  if EventID_CancelAddingImage in Params then
  begin
    if AnsiLowerCase(Value.name) = AnsiLowerCase(FInfo.FileName) then
      Close;
  end;
end;

procedure TFormAddingImage.DrawForm;
var
  Bitmap : TBitmap;
  R: TRect;
begin
  Bitmap := TBitmap.Create;
  try
    Bitmap.Width := Width;
    Bitmap.Height := Height;
    FillTransparentColor(Bitmap, clBlack, 0);
    DrawRoundGradientVert(Bitmap, Rect(0, 0, Width, Height),
      clGradientActiveCaption, clGradientInactiveCaption, clHighlight, 8, 240);

    DrawLoadingSignImage(LsMain.Left, LsMain.Top,
      Round((LsMain.Height div 2) * 70 / 100),
      LsMain.Height, Bitmap, clBlack, FLoadingState, 240);

    R := Rect(LsMain.Left + LsMain.Width + 5, LsMain.Top, ClientWidth, ClientHeight);
    DrawText32Bit(Bitmap, L('Please wait...'), Font, R, 0);

    RenderForm(Self.Handle, Bitmap, 220);

  finally
    F(Bitmap);
  end;
end;

procedure TFormAddingImage.Execute(Info: TDBPopupMenuInfoRecord);
begin
  FInfo := Info;
  FInfo.Include := True;
  UpdaterDB.AddFileEx(FInfo, True, True);
  DrawForm;
  ShowModal;
end;

procedure TFormAddingImage.FormCreate(Sender: TObject);
begin
  DBKernel.RegisterChangesID(Self, ChangedDBDataByID);
end;

procedure TFormAddingImage.FormDestroy(Sender: TObject);
begin
  DBKernel.UnRegisterChangesID(Self, ChangedDBDataByID);
end;

function TFormAddingImage.GetFormID: string;
begin
  Result := 'AddImage';
end;

procedure TFormAddingImage.TmrRedrawTimer(Sender: TObject);
begin
  DrawForm;
end;

end.
