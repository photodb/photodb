unit uFormUpdateStatus;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.AppEvnts,
  Vcl.Imaging.pngimage,

  Dmitry.Utils.System,
  Dmitry.Controls.Base,
  Dmitry.Controls.WebLink,
  Dmitry.Controls.LoadingSign,
  Dmitry.Controls.DmProgress,
  Dmitry.Controls.SaveWindowPos,

  UnitDBKernel,
  UnitDBDeclare,

  uConstants,
  uMemory,
  uDBForm,
  uFormInterfaces,
  uJpegUtils,
  uGraphicUtils,
  uBitmapUtils,
  uTranslateUtils,
  uDatabaseDirectoriesUpdater;

type
  TFormUpdateStatus = class(TDBForm, IFormUpdateStatus)
    AeMain: TApplicationEvents;
    TmrHide: TTimer;
    PnMain: TPanel;
    PrbMain: TDmProgress;
    ImCurrentPreview: TImage;
    LbInfo: TLabel;
    TmrShow: TTimer;
    WlStartStop: TWebLink;
    TmrUpdateInfo: TTimer;
    SwpWindow: TSaveWindowPos;
    LsLoading: TLoadingSign;
    procedure AeMainMessage(var Msg: tagMSG; var Handled: Boolean);
    procedure TmrHideTimer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure TmrShowTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ImCurrentPreviewClick(Sender: TObject);
    procedure TmrUpdateInfoTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FCurrentFileName: string;
    FHiddenByUser: Boolean;
    procedure ChangedDBDataByID(Sender: TObject; ID: integer; Params: TEventFields; Value: TEventValues);
    procedure UpdateInfo;
  public
    { Public declarations }
    procedure ShowForm(Automatically: Boolean);
    procedure HideForm;
  end;

implementation

{$R *.dfm}

procedure TFormUpdateStatus.ChangedDBDataByID(Sender: TObject; ID: integer;
  Params: TEventFields; Value: TEventValues);
var
  Bit, Bitmap: TBitmap;
begin
  if (SetNewIDFileData in Params) or (EventID_FileProcessed in Params) then
  begin
    FCurrentFileName := Value.FileName;
    LbInfo.Caption := Value.FileName;

    Bit := TBitmap.Create;
    try
      Bit.PixelFormat := pf24bit;
      AssignJpeg(Bit, Value.JPEGImage);
      ApplyRotate(Bit, Value.Rotation);

      KeepProportions(Bit, ImCurrentPreview.Width - 4, ImCurrentPreview.Height - 4);

      Bitmap := TBitmap.Create;
      try
        DrawShadowToImage(Bitmap, Bit);

        Bitmap.AlphaFormat := afDefined;
        ImCurrentPreview.Picture.Graphic := Bitmap;
        ShowForm(True);
      finally
        F(Bitmap);
      end;
    finally
      F(Bit);
    end;

  end;
end;

procedure TFormUpdateStatus.AeMainMessage(var Msg: tagMSG; var Handled: Boolean);
begin
  if not Active then
    Exit;

  if Msg.message = WM_LBUTTONDOWN then
  begin
    if (Msg.hwnd = PnMain.Handle) and PtInRect(ImCurrentPreview.BoundsRect, PnMain.ScreenToClient(Msg.pt)) then
      Exit;

    Perform(WM_NCLBUTTONDOWN, HTCAPTION, Msg.LParam);
    Msg.message  := 0;
  end;
end;

procedure TFormUpdateStatus.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TFormUpdateStatus.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  FHiddenByUser := True;
  CanClose := TmrHide.Enabled;
  if not CanClose then
    HideForm;
end;

procedure TFormUpdateStatus.FormCreate(Sender: TObject);
begin
  FCurrentFileName := '';
  FHiddenByUser := False;
  DBKernel.RegisterChangesID(Self, ChangedDBDataByID);

  SwpWindow.Key := RegRoot + 'CollectionUpdateForm';
  if not SwpWindow.SetPosition(False) then
  begin
    Top := Monitor.WorkareaRect.BottomRight.Y - Height;
    Left := Monitor.WorkareaRect.BottomRight.X - Width;
  end;
end;

procedure TFormUpdateStatus.FormDestroy(Sender: TObject);
begin
  SwpWindow.SavePosition;
  DBKernel.UnRegisterChangesID(Self, ChangedDBDataByID);
end;

procedure TFormUpdateStatus.HideForm;
begin
  TmrShow.Enabled := False;
  TmrHide.Enabled := True;
end;

procedure TFormUpdateStatus.ImCurrentPreviewClick(Sender: TObject);
begin
  if FCurrentFileName <> '' then
  begin
    Viewer.ShowImageInDirectoryEx(FCurrentFileName);
    Viewer.Show;
    Viewer.Restore;
  end;
end;

procedure TFormUpdateStatus.ShowForm(Automatically: Boolean);
begin
  if FHiddenByUser and Automatically then
    Exit;

  if not Visible then
    Visible := True;

  TmrHide.Enabled := False;
  TmrShow.Enabled := True;
end;

procedure TFormUpdateStatus.TmrHideTimer(Sender: TObject);
var
  BlendValue: Integer;
begin
  BlendValue := AlphaBlendValue;
  Dec(BlendValue, 10);
  if (BlendValue <= 0) then
  begin
    BlendValue := 0;
    Close;
    TmrHide.Enabled := False;
  end;
  AlphaBlendValue := BlendValue;
end;

procedure TFormUpdateStatus.TmrShowTimer(Sender: TObject);
var
  BlendValue: Integer;
begin
  BlendValue := AlphaBlendValue;
  Inc(BlendValue, 10);
  if (BlendValue >= 200) then
  begin
    BlendValue := 200;
    TmrShow.Enabled := False;
  end;
  AlphaBlendValue := BlendValue;
end;

procedure TFormUpdateStatus.TmrUpdateInfoTimer(Sender: TObject);
begin
  UpdateInfo;
end;

procedure TFormUpdateStatus.UpdateInfo;
var
  PercentComplete: Double;
begin
  PrbMain.MaxValue := UpdaterStorage.TotalItemsCount;
  PrbMain.Position := UpdaterStorage.TotalItemsCount - UpdaterStorage.ActiveItemsCount;

  PercentComplete := 100;
  if PrbMain.MaxValue > 0 then
    PercentComplete :=100 *  PrbMain.Position / PrbMain.MaxValue;

  PrbMain.Text := FormatEx('{0}, {1:0.#%}', [TimeIntervalInString(UpdaterStorage.EstimateRemainingTime), PercentComplete]);
end;

initialization
  FormInterfaces.RegisterFormInterface(IFormUpdateStatus, TFormUpdateStatus);

end.
