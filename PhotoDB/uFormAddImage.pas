unit uFormAddImage;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.Themes,

  Dmitry.Controls.Base,
  Dmitry.Controls.LoadingSign,

  UnitDBDeclare,
  UnitDBKernel,

  uMemory,
  uFormUtils,
  uBitmapUtils,
  uThemesUtils,
  uDBForm,
  uFormInterfaces;

type
  TFormAddingImage = class(TDBForm, ICollectionAddItemForm)
    LbMessage: TLabel;
    LsMain: TLoadingSign;
    TmrRedraw: TTimer;
    TmrCheck: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure TmrRedrawTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure TmrCheckTimer(Sender: TObject);
  private
    FInfo: TDBPopupMenuInfoRecord;
    FLoadingState: Extended;
    { Private declarations }
  protected
    procedure ChangedDBDataByID(Sender: TObject; ID: Integer; params: TEventFields; Value: TEventValues);
    procedure DrawForm;
    function GetFormID: string; override;
    procedure InterfaceDestroyed; override;
    function DisableMasking: Boolean; override;
  public
    { Public declarations }
    procedure Execute(Info: TDBPopupMenuInfoRecord);
  end;

implementation

uses
  UnitUpdateDBObject;

{$R *.dfm}

{ TFormAddingImage }

function TFormAddingImage.DisableMasking: Boolean;
begin
  Result := True;
end;

procedure TFormAddingImage.ChangedDBDataByID(Sender: TObject; ID: Integer;
  params: TEventFields; Value: TEventValues);
begin
  if SetNewIDFileData in Params then
  begin
    if AnsiLowerCase(Value.Name) = AnsiLowerCase(FInfo.FileName) then
    begin
      FInfo.ID := Value.ID;
      TmrCheck.Enabled := False;
      Close;
      Exit;
    end;

  end;
  if EventID_CancelAddingImage in Params then
  begin
    if (AnsiLowerCase(Value.NewName) = AnsiLowerCase(FInfo.FileName)) and (Value.ID > 0) then
    begin
      FInfo.ID := Value.ID;
      TmrCheck.Enabled := False;
      Close;
      Exit;
    end;

    if AnsiLowerCase(Value.name) = AnsiLowerCase(FInfo.FileName) then
    begin
      TmrCheck.Enabled := False;
      Close;
    end;
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
      Theme.GradientFromColor, Theme.GradientToColor, Theme.HighlightColor, 8, 240);

    DrawLoadingSignImage(LsMain.Left, LsMain.Top,
      Round((LsMain.Height div 2) * 70 / 100),
      LsMain.Height, Bitmap, clBlack, FLoadingState, 240);

    if StyleServices.Enabled and TStyleManager.IsCustomStyleActive then
      Font.Color := Theme.GradientText;
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
  TmrCheck.Enabled := True;
  ShowModal;
  FInfo := nil;
end;

procedure TFormAddingImage.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
  TmrRedraw.Enabled := False;
  DBKernel.UnRegisterChangesID(Self, ChangedDBDataByID);
end;

procedure TFormAddingImage.FormCreate(Sender: TObject);
begin
  FInfo := nil;
  DBKernel.RegisterChangesID(Self, ChangedDBDataByID);
end;

procedure TFormAddingImage.FormDestroy(Sender: TObject);
begin
  TmrRedraw.Enabled := False;
  DBKernel.UnRegisterChangesID(Self, ChangedDBDataByID);
end;

function TFormAddingImage.GetFormID: string;
begin
  Result := 'AddImage';
end;

procedure TFormAddingImage.InterfaceDestroyed;
begin
  inherited;
  Release;
end;

procedure TFormAddingImage.TmrCheckTimer(Sender: TObject);
begin
  if FInfo = nil then
    Exit;
  if not UpdaterDB.HasFile(FInfo.FileName) then
    Close;
end;

procedure TFormAddingImage.TmrRedrawTimer(Sender: TObject);
begin
  DrawForm;
end;

initialization
  FormInterfaces.RegisterFormInterface(ICollectionAddItemForm, TFormAddingImage);

end.
