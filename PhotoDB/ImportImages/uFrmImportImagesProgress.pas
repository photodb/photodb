unit uFrmImportImagesProgress;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, uFrameWizardBase, DmProgress, StdCtrls, pngimage, ExtCtrls,
  Dolphin_DB, UnitDBDeclare, uGraphicUtils, uMemory, uRuntime, UnitDBkernel,
  UnitUpdateDBObject, UnitTimeCounter, uFileUtils, uConstants, UnitDBCommon,
  UnitDBCommonGraphics;

type
  TFrmImportImagesProgress = class(TFrameWizardBase)
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
    TimeCounter: TTimeCounter;
    UpdateObject: TUpdaterDB;
    procedure ChangedDBDataByID(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
  protected
    { Protected declarations }
    procedure LoadLanguage; override;
  public
    { Public declarations }
    procedure DirectoryAdded(Sender: TObject);
    procedure FileFounded(Owner: TObject; FileName: string; Size: Int64);
    procedure OnDone(Sender: TObject);
    function IsFinal: Boolean; override;
    constructor Create(AOwner: TComponent); override;
    procedure Init(Manager: TWizardManagerBase; FirstInitialization: Boolean); override;
    procedure Unload; override;
    procedure Execute; override;
    procedure Pause(Value: Boolean); override;
    procedure SetMaxValue(Value: Integer);
    procedure SetPosition(Value: Integer);
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
  inherited;
  UpdateObject := nil;
end;

procedure TFrmImportImagesProgress.Execute;
var
  LandingStep: TFrmImportImagesLanding;
  OptionsStep: TFrmImportImagesOptions;
begin
  inherited;
  IsBusy := True;
  UpdateObject := TUpdaterDB.Create(Manager.Owner);
  UpdateObject.OwnerFormSetMaxValue := SetMaxValue;
  UpdateObject.OwnerFormSetPosition := SetPosition;
  UpdateObject.OnDirectoryAdded := DirectoryAdded;
  UpdateObject.SetDone := OnDone;

  OptionsStep := TFrmImportImagesOptions(Manager.GetStepByType(TFrmImportImagesOptions));
  case OptionsStep.DefaultActionIndex of
    1:
      UpdateObject.AutoAnswer := Result_add_all;
    2:
      UpdateObject.AutoAnswer := Result_skip_all;
    3:
      UpdateObject.AutoAnswer := Result_replace_all;
  end;

  UpdateObject.Auto := False;
  LandingStep := TFrmImportImagesLanding(Manager.GetStepByType(TFrmImportImagesLanding));
  UpdateObject.AddDirectory(LandingStep.FirstPath, FileFounded);
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
    FullSize := 0;
    TimeCounter := TTimeCounter.Create;
    TimeCounter.TimerInterval := 15000; // 15 seconds to refresh
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
  DBKernel.UnRegisterChangesID(Self, ChangedDBDataByID);
  if UpdateObject <> nil then
  begin
    UpdateObject.SetDone := nil;
    UpdateObject.DoTerminate;
    F(UpdateObject);
  end;
  F(TimeCounter);
end;

procedure TFrmImportImagesProgress.ChangedDBDataByID(Sender: TObject;
  ID: integer; params: TEventFields; Value: TEventValues);
var
  Bit, Preview: TBitmap;
  P: TPoint;
  FileSize: Integer;
  W, H: Integer;

begin
  if (SetNewIDFileData in params) or (EventID_FileProcessed in params) then
    if UpdateObject.Active then
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
      EdCurrentFileName.Text := Value.Name;

      Inc(ImageProcessedCounter);
      FileSize := GetFileSizeByName(Value.Name);
      ProcessingSize := ProcessingSize + FileSize;
      LbImagesSize.Caption := Format(L('Size: %s from %s'),
        [SizeInText(ProcessingSize), SizeInText(FullSize)]);
      LbImagesCount.Caption := Format(L('Processed %d from %d'),
        [ImageProcessedCounter, ImageCounter]);

      TimeCounter.NextAction(FileSize);

      LbTimeLeft.Visible := True;
      LbTimeLeft.Caption := Format(L('Time remaining: %s'),
        [FormatDateTime('hh:mm:ss', TimeCounter.GetTimeRemaining)]);

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

procedure TFrmImportImagesProgress.SetMaxValue(Value: integer);
begin
  PbMain.MaxValue := Value;
end;

procedure TFrmImportImagesProgress.SetPosition(Value: integer);
begin
  PbMain.Position := Value;
end;

procedure TFrmImportImagesProgress.FileFounded(Owner: TObject; FileName: string;
  Size: int64);
begin
  FullSize := FullSize + Size;
  Inc(ImageCounter);
  LbImagesSize.Caption := Format(L('Current size - %s'), [SizeInText(FullSize)]);
  LbImagesCount.Caption := Format(L('Found %d images'), [ImageCounter]);
  EdCurrentFileName.Text := FileName;
end;

procedure TFrmImportImagesProgress.OnDone(Sender: TObject);
begin
  PbMain.Position := PbMain.MaxValue;
  LbTimeLeft.Visible := False;
  IsBusy := False;
  IsStepComplete := True;
  Changed;
end;

function TFrmImportImagesProgress.IsPaused: Boolean;
begin
  Result := UpdateObject.Pause;
end;

procedure TFrmImportImagesProgress.Pause(Value: Boolean);
begin
  if Value then
    UpdateObject.DoPause
  else
    UpdateObject.DoUnPause;
end;

procedure TFrmImportImagesProgress.DirectoryAdded(Sender: TObject);
var
  LandingStep: TFrmImportImagesLanding;
  Directory: string;
begin
  LandingStep := TFrmImportImagesLanding(Manager.GetStepByType(TFrmImportImagesLanding));
  Directory := LandingStep.ExtractNextDirectory;

  if Directory <> '' then
    UpdateObject.AddDirectory(Directory, FileFounded)
  else
  begin
    if UpdateObject.GetCount = 0 then
    begin
      OnDone(Sender);
      Exit;
    end;
    TimeCounter.MaxActions := FullSize;
    TimeCounter.DoBegin;
    UpdateObject.Execute;
    LbStatus.Caption := L('Processing images');
  end;
end;

end.
