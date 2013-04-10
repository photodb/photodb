unit UnitPropertyLoadImageThread;

interface

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  Vcl.Graphics,

  Dmitry.Graphics.Utils,

  UnitDBKernel,
  UnitDBDeclare,

  uBitmapUtils,
  uDBThread,
  uMemory,
  uRuntime,
  uConstants,
  uDBForm,
  uDBIcons,
  uThemesUtils,
  uImageLoader;

type
  TPropertyLoadImageThreadOptions = record
    FileName: string;
    Owner: TDBForm;
    SID: TGUID;
    OnDone: TNotifyEvent;
  end;

type
  TPropertyLoadImageThread = class(TDBThread)
  private
    { Private declarations }
    FOptions: TPropertyLoadImageThreadOptions;
    StrParam: string;
    IntParamW: Integer;
    IntParamH: Integer;
    Password: string;
    BitmapParam: TBitmap;
  protected
    procedure Execute; override;
  public
    constructor Create(Options : TPropertyLoadImageThreadOptions);
    procedure SetCurrentPassword;
    procedure SetImage;
    procedure SetSizes;
  end;

implementation

uses
  PropertyForm;

{ TPropertyLoadImageThread }

constructor TPropertyLoadImageThread.Create(Options: TPropertyLoadImageThreadOptions);
begin
  inherited Create(Options.Owner, False);
  FreeOnTerminate := True;
  FOptions := Options;
end;

procedure TPropertyLoadImageThread.Execute;
var
  TempBitmap: TBitmap;
  ImageInfo: ILoadImageInfo;
  Info: TMediaItem;
begin

  Info := TMediaItem.CreateFromFile(FOptions.FileName);
  try
    if LoadImageFromPath(Info, -1, '', [ilfGraphic, ilfICCProfile, ilfEXIF, ilfPassword, ilfAskUserPassword], ImageInfo,
      ThSizePropertyPreview, ThSizePropertyPreview) then
    begin
      IntParamW := ImageInfo.GraphicWidth;
      IntParamH := ImageInfo.GraphicHeight;
      Synchronize(SetSizes);

      if ImageInfo.IsImageEncrypted then
      begin
        StrParam := ImageInfo.Password;
        Synchronize(SetCurrentPassword);
      end;

      TempBitmap := ImageInfo.GenerateBitmap(Info, ThSizePropertyPreview, ThSizePropertyPreview, pf32bit, Theme.WindowColor,
        [ilboFreeGraphic, ilboAddShadow, ilboRotate, ilboApplyICCProfile]);
      try
        if TempBitmap <> nil then
        begin
          BitmapParam := TBitmap.Create;
          try
            BitmapParam.PixelFormat := pf24bit;
            BitmapParam.SetSize(ThSizePropertyPreview + 4, ThSizePropertyPreview + 4);

            FillRectNoCanvas(BitmapParam, Theme.WindowColor);

            if TempBitmap.PixelFormat = pf24Bit then
              DrawImageEx(BitmapParam, TempBitmap, BitmapParam.Width div 2 - TempBitmap.Width div 2,
                BitmapParam.Height div 2 - TempBitmap.Height div 2)
            else
              DrawImageEx32To24(BitmapParam, TempBitmap, BitmapParam.Width div 2 - TempBitmap.Width div 2,
                BitmapParam.Height div 2 - TempBitmap.Height div 2);

            Synchronize(SetImage);
          finally
            F(BitmapParam);
          end;
        end;
      finally
        F(TempBitmap);
      end;
    end;
  finally
    F(Info);
  end;
end;

procedure TPropertyLoadImageThread.SetCurrentPassword;
begin
  if PropertyManager.IsPropertyForm(fOptions.Owner) then
    if IsEqualGUID((fOptions.Owner as TPropertiesForm).SID, fOptions.SID) then
      (fOptions.Owner as TPropertiesForm).FCurrentPass := StrParam;
end;

procedure TPropertyLoadImageThread.SetImage;
begin
  if PropertyManager.IsPropertyForm(fOptions.Owner) then
    if IsEqualGUID((fOptions.Owner as TPropertiesForm).SID, fOptions.SID) then
      begin
        if PassWord <> '' then
          DrawIconEx(BitmapParam.Canvas.Handle, 20, 0, Icons[DB_IC_KEY], 18, 18, 0, 0, DI_NORMAL);
        DrawIconEx(BitmapParam.Canvas.Handle, 0, 0, Icons[DB_IC_NEW], 18, 18, 0, 0, DI_NORMAL);

        with (FOptions.Owner as TPropertiesForm) do
        begin
          ImageLoadingFile.Visible := False;
          ImMain.Picture.Graphic := BitmapParam;
          ImMain.Refresh;
        end;
      end;
end;

procedure TPropertyLoadImageThread.SetSizes;
begin
  if PropertyManager.IsPropertyForm(fOptions.Owner) then
    if IsEqualGUID((fOptions.Owner as TPropertiesForm).SID, fOptions.SID) then
      begin
        (fOptions.Owner as TPropertiesForm).WidthMemo.Text := IntToStr(IntParamW) + 'px.';
        (fOptions.Owner as TPropertiesForm).HeightMemo.Text := IntToStr(IntParamH) + 'px.';
      end;
end;

end.
