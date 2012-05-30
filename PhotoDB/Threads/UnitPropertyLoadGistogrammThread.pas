unit UnitPropertyLoadGistogrammThread;

interface

uses
  Windows,
  Classes,
  Graphics,
  SysUtils,
  UnitDBDeclare,
  uDBForm,
  GraphicsBaseTypes,
  uMemory,
  uBitmapUtils,
  uDBGraphicTypes,
  uDBThread,
  uImageLoader;

type
  TPropertyLoadGistogrammThreadOptions = record
    FileName: string;
    Password: string;
    Owner: TDBForm;
    SID: TGUID;
    OnDone: TNotifyEvent;
  end;

type
  TPropertyLoadGistogrammThread = class(TDBThread)
  private
    { Private declarations }
    FOptions: TPropertyLoadGistogrammThreadOptions;
    StrParam: string;
    Data: TGistogrammData;
  protected
    procedure Execute; override;
  public
    constructor Create(Options: TPropertyLoadGistogrammThreadOptions);
    procedure GetCurrentpassword;
    procedure SetGistogrammData;
    procedure DoOnDone;
  end;

implementation

uses
  PropertyForm;

{ TPropertyLoadGistogrammThread }

constructor TPropertyLoadGistogrammThread.Create(Options: TPropertyLoadGistogrammThreadOptions);
begin
  inherited Create(Options.Owner, False);
  FreeOnTerminate := True;
  FOptions := Options;
end;

procedure TPropertyLoadGistogrammThread.DoOnDone;
begin
  if PropertyManager.IsPropertyForm(FOptions.Owner) then
    if IsEqualGUID((FOptions.Owner as TPropertiesForm).SID, FOptions.SID) then
      FOptions.OnDone(Self);
end;

procedure TPropertyLoadGistogrammThread.Execute;
var
  Bitmap: TBitmap;
  Info: TDBPopupMenuInfoRecord;
  ImageInfo: ILoadImageInfo;
begin
  try
    Info := TDBPopupMenuInfoRecord.CreateFromFile(FOptions.FileName);
    try
      if LoadImageFromPath(Info, -1, FOptions.Password, [ilfGraphic, ilfICCProfile, ilfEXIF, ilfPassword, ilfAskUserPassword], ImageInfo, 800, 800) then
      begin
        Bitmap := ImageInfo.GenerateBitmap(Info, 800, 800, pf24Bit, clNone, [ilboFreeGraphic, ilboApplyICCProfile]);
        try
          if Bitmap <> nil then
          begin
            Data := FillHistogramma(Bitmap);
            Synchronize(SetGistogrammData);
          end;
        finally
          F(Bitmap);
        end;
      end;
    finally
      F(Info);
    end;
  finally
    Synchronize(DoOnDone);
  end;
end;

procedure TPropertyLoadGistogrammThread.GetCurrentpassword;
begin
  if PropertyManager.IsPropertyForm(fOptions.Owner) then
    if IsEqualGUID((fOptions.Owner as TPropertiesForm).SID, FOptions.SID) then
      StrParam := (fOptions.Owner as TPropertiesForm).FCurrentPass;
end;

procedure TPropertyLoadGistogrammThread.SetGistogrammData;
begin
  if PropertyManager.IsPropertyForm(FOptions.Owner) then
    if IsEqualGUID((FOptions.Owner as TPropertiesForm).SID, FOptions.SID) then
      (FOptions.Owner as TPropertiesForm).GistogrammData := Data;
end;

end.
