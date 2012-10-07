unit uFrmImportImagesProgress;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  uFrameWizardBase,

  Dmitry.Utils.Files,
  Dmitry.Controls.DmProgress,

  Dolphin_DB,
  UnitDBDeclare,
  uGraphicUtils,
  uMemory,
  uRuntime,
  UnitDBkernel,
  UnitUpdateDBObject,
  uCounters,
  uConstants,
  uBitmapUtils,
  uUpdateDBTypes,
  uInterfaceManager,
  uDBForm,
  pngimage;

type
  TFrmImportImagesProgress = class(TFrameWizardBase, IDBUpdaterCallBack)
    LbStepInfo: TLabel;
    ImWait: TImage;
    ImCurrentPreview: TImage;
    LbStatus: TLabel;
    LbImagesCount: TLabel;
    LbImagesSize: TLabel;
    EdCurrentFileName: TEdit;
    PbMain: TDmProgress;
    LbTimeLeft: TLabel;
  private
    { Private declarations }
    FullSize: Int64;
    ImageCounter: Integer;
    ProcessingSize: Int64;
    ImageProcessedCounter: Integer;
    FSpeedCounter: TSpeedEstimateCounter;
    procedure ChangedDBDataByID(Sender: TObject; ID: Integer;  params: TEventFields; Value: TEventValues);
  protected
    { Protected declarations }
    procedure LoadLanguage; override;
  public
    { Public declarations }
    procedure UpdaterSetText(Text: string);
    procedure UpdaterSetMaxValue(Value: Integer);
    procedure UpdaterSetAutoAnswer(Value: Integer);
    procedure UpdaterSetTimeText(Text: string);
    procedure UpdaterSetPosition(Value, Max: Integer);
    procedure UpdaterSetFileName(FileName: string);
    procedure UpdaterAddFileSizes(Value: Int64);
    procedure UpdaterDirectoryAdded(Sender: TObject);
    procedure UpdaterOnDone(Sender: TObject);
    procedure UpdaterShowForm(Sender: TObject);
    procedure UpdaterSetBeginUpdation(Sender: TObject);
    procedure UpdaterShowImage(Sender: TObject);
    procedure UpdaterFoundedEvent(Owner: TObject; FileName: string; Size: Int64);
    procedure UpdaterSetFullSize(Value: Int64);
    function UpdaterGetForm: TDBForm;

    function IsFinal: Boolean; override;
    constructor Create(AOwner: TComponent); override;
    procedure Init(Manager: TWizardManagerBase; FirstInitialization: Boolean); override;
    procedure Unload; override;
    procedure Execute; override;
    procedure Pause(Value: Boolean); override;
    function IsPaused: Boolean; override;
  end;

implementation

uses
  uFrmImportImagesLanding,
  uFrmImportImagesOptions,
  UnitUpdateDBThread,
  UnitHelp;

{$R *.dfm}

{ TFrmImportImagesProgress }

constructor TFrmImportImagesProgress.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

procedure TFrmImportImagesProgress.Execute;
var
  LandingStep: TFrmImportImagesLanding;
  OptionsStep: TFrmImportImagesOptions;
begin
  inherited;
  IsBusy := True;

  OptionsStep := TFrmImportImagesOptions(Manager.GetStepByType(TFrmImportImagesOptions));
  case OptionsStep.DefaultActionIndex of
    1:
      UpdaterDB.AutoAnswer := Result_add_all;
    2:
      UpdaterDB.AutoAnswer := Result_skip_all;
    3:
      UpdaterDB.AutoAnswer := Result_replace_all;
  end;

  UpdaterDB.Auto := False;
  LandingStep := TFrmImportImagesLanding(Manager.GetStepByType(TFrmImportImagesLanding));
  UpdaterDB.AddDirectory(LandingStep.FirstPath);
  LbStatus.Visible := True;
  LbImagesSize.Visible := True;
  LbImagesCount.Visible := True;
  ImWait.Visible := True;
  EdCurrentFileName.Visible := True;
  PbMain.Visible := True;
  Changed;
end;

procedure TFrmImportImagesProgress.Init(Manager: TWizardManagerBase;
  FirstInitialization: Boolean);
begin
  inherited;
  if FirstInitialization then
  begin
    InterfaceManager.RegisterObject(Self);
    FullSize := 0;
    FSpeedCounter := TSpeedEstimateCounter.Create(15000); // 15 seconds to refresh
    ImageCounter := 0;
    ImageProcessedCounter := 0;
    ProcessingSize := 0;

    DBKernel.RegisterChangesID(Self, ChangedDBDataByID);
  end;
end;

function TFrmImportImagesProgress.IsFinal: Boolean;
begin
  Result := True;
end;

procedure TFrmImportImagesProgress.LoadLanguage;
begin
  inherited;
  LbStepInfo.Caption := L('Click the "Start" button and wait until the program finds and adds all your images. This may require a long time depending on the size of your photo album');
  LbStatus.Caption := L('Searching for images...');
  LbImagesSize.Caption := Format(L('Current size - %s'), [SizeInText(FullSize)]);
  LbImagesCount.Caption := Format(L('Found %d images'), [ImageCounter]);
  PbMain.Text := L('Progress... (&%%)');
end;

procedure TFrmImportImagesProgress.Unload;
begin
  inherited;
  UpdaterDB.Auto := True;
  InterfaceManager.UnRegisterObject(Self);
  DBKernel.UnRegisterChangesID(Self, ChangedDBDataByID);

  UpdaterDB.DoTerminate;
  F(FSpeedCounter);
end;

procedure TFrmImportImagesProgress.ChangedDBDataByID(Sender: TObject;
  ID: integer; params: TEventFields; Value: TEventValues);
var
  Bit, Preview: TBitmap;
  P: TPoint;
  FileSize: Integer;
  W, H: Integer;

  procedure UpdateInfo;
  begin
    EdCurrentFileName.Text := Value.Name;

    Inc(ImageProcessedCounter);
    FileSize := GetFileSizeByName(Value.Name);
    FSpeedCounter.AddSpeedInterval(FileSize);
    ProcessingSize := ProcessingSize + FileSize;
    LbImagesSize.Caption := Format(L('Size: %s from %s'), [SizeInText(ProcessingSize), SizeInText(FullSize)]);
    LbImagesCount.Caption := Format(L('Processed %d from %d'), [ImageProcessedCounter, ImageCounter]);

    LbTimeLeft.Visible := True;
    LbTimeLeft.Caption := Format(L('Time remaining: %s'), [TimeIntervalInString(FSpeedCounter.GetTimeRemaining(UpdaterDB.GetSize))]);
  end;

begin
  if (EventID_CancelAddingImage in Params) then
  begin
    EdCurrentFileName.Text := Value.Name;
    UpdateInfo;
  end;

  if (SetNewIDFileData in params) or (EventID_FileProcessed in params) then
    if UpdaterDB.Active then
    begin
      ImWait.Visible := False;
      Bit := TBitmap.Create;
      try
        Bit.Assign(Value.JPEGImage);
        Bit.PixelFormat := pf24bit;
        W := Bit.Width;
        H := Bit.Height;
        ProportionalSize(100, 100, W, H);
        Preview := TBitmap.Create;
        try
          DoResize(W, H, Bit, Preview);
          DrawShadowToImage(Bit, Preview);
          LoadBMPImage32bit(Bit, Preview, Color);
          ImCurrentPreview.Picture.Graphic := Preview;
        finally
          F(Preview);
        end;

      finally
        F(Bit);
      end;

      UpdateInfo;
      Exit;
    end;

  if EventID_Param_Add_Crypt_WithoutPass in params then
  begin
    if not CryptFileWithoutPassChecked then
    begin
      DoHelpHint(L('Warning'), L('Can''t add some files to collection because password was not found!'), P,
        Self);
    end;
  end;
end;

procedure TFrmImportImagesProgress.UpdaterAddFileSizes(Value: Int64);
begin
  //isn't used
end;

procedure TFrmImportImagesProgress.UpdaterSetAutoAnswer(Value: Integer);
begin
  //isn't used
end;

procedure TFrmImportImagesProgress.UpdaterSetBeginUpdation(Sender: TObject);
begin
  //isn't used
end;

procedure TFrmImportImagesProgress.UpdaterSetFileName(FileName: string);
begin
  //isn't used
end;

procedure TFrmImportImagesProgress.UpdaterSetFullSize(Value: Int64);
begin
  //isn't used
end;

procedure TFrmImportImagesProgress.UpdaterSetMaxValue(Value: integer);
begin
  PbMain.MaxValue := Value;
end;

procedure TFrmImportImagesProgress.UpdaterSetPosition(Value, Max: integer);
begin
  PbMain.Position := Value;
  PbMain.MaxValue := Max;
end;

procedure TFrmImportImagesProgress.UpdaterSetText(Text: string);
begin
  //isn't used
end;

procedure TFrmImportImagesProgress.UpdaterSetTimeText(Text: string);
begin
  //isn't used
end;

procedure TFrmImportImagesProgress.UpdaterShowForm(Sender: TObject);
begin
  //isn't used
end;

procedure TFrmImportImagesProgress.UpdaterShowImage(Sender: TObject);
begin
  //isn't used
end;

procedure TFrmImportImagesProgress.UpdaterFoundedEvent(Owner: TObject; FileName: string;
  Size: int64);
begin
  FullSize := FullSize + Size;
  Inc(ImageCounter);
  LbImagesSize.Caption := Format(L('Current size - %s'), [SizeInText(FullSize)]);
  LbImagesCount.Caption := Format(L('Found %d images'), [ImageCounter]);
  EdCurrentFileName.Text := FileName;
end;

procedure TFrmImportImagesProgress.UpdaterOnDone(Sender: TObject);
begin
  PbMain.Position := PbMain.MaxValue;
  LbTimeLeft.Visible := False;
  IsBusy := False;
  IsStepComplete := True;
  Changed;
end;

function TFrmImportImagesProgress.IsPaused: Boolean;
begin
  Result := UpdaterDB.Pause;
end;

procedure TFrmImportImagesProgress.Pause(Value: Boolean);
begin
  if Value then
    UpdaterDB.DoPause
  else
    UpdaterDB.DoUnPause;
end;

procedure TFrmImportImagesProgress.UpdaterDirectoryAdded(Sender: TObject);
var
  LandingStep: TFrmImportImagesLanding;
  Directory: string;
begin
  LandingStep := TFrmImportImagesLanding(Manager.GetStepByType(TFrmImportImagesLanding));
  Directory := LandingStep.ExtractNextDirectory;

  if Directory <> '' then
    UpdaterDB.AddDirectory(Directory)
  else
  begin
    if UpdaterDB.GetCount = 0 then
    begin
      UpdaterOnDone(Sender);
      Exit;
    end;
    FSpeedCounter.Reset;
    UpdaterDB.Execute;
    LbStatus.Caption := L('Processing images');
  end;
end;

function TFrmImportImagesProgress.UpdaterGetForm: TDBForm;
begin
  Result := Manager.Owner;
end;

end.
