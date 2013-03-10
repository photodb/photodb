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

  Vcl.Imaging.pngimage,


  Dmitry.Controls.DmProgress,

  Dolphin_DB,


  uFrameWizardBase,

  uMemory,
  uRuntime,

  UnitUpdateDBObject,

  uConstants,



  uProgramStatInfo,
  uDBForm;

type
  TFrmImportImagesProgress = class(TFrameWizardBase)
    LbStepInfo: TLabel;
  private
    { Private declarations }
  protected
    { Protected declarations }
    procedure LoadLanguage; override;
  public
    { Public declarations }
    function IsFinal: Boolean; override;
    constructor Create(AOwner: TComponent); override;
    procedure Execute; override;
  end;

implementation

uses
  uFrmImportImagesLanding,
  uFrmImportImagesOptions,
  UnitUpdateDBThread;

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
  Directories: TStrings;
  Directory: string;
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

  LandingStep := TFrmImportImagesLanding(Manager.GetStepByType(TFrmImportImagesLanding));

  Directories := TStringList.Create;
  try
    Directory := LandingStep.FirstPath;
    while(Directory <> '') do
    begin
      Directories.Add(Directory);
      Directory := LandingStep.ExtractNextDirectory;
    end;

    UpdaterDB.AddDirectory(Directories.Text);
    UpdaterDB.ShowWindowNow;
  finally
    F(Directories);
  end;

  ProgramStatistics.InitialImportUsed;

  IsBusy := False;
  IsStepComplete := True;
  Changed;
end;

function TFrmImportImagesProgress.IsFinal: Boolean;
begin
  Result := True;
end;

procedure TFrmImportImagesProgress.LoadLanguage;
begin
  inherited;
  LbStepInfo.Caption := L('Click the "Start" button and wait until the program finds and adds all your images. This may require a long time depending on the size of your photo album');
end;

end.
