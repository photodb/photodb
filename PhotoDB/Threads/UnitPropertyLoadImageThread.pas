unit UnitPropertyLoadImageThread;

interface

uses
  Windows, Classes, Messages, Forms, Graphics, SysUtils, RAWImage,
  Dolphin_DB, UnitDBKernel, GraphicCrypt, UnitDBCommonGraphics,
  uMemory, GraphicsCool, ImageConverting;

type
  TPropertyLoadImageThreadOptions = record
    FileName: string;
    Owner: TForm;
    SID: TGUID;
    OnDone: TNotifyEvent;
  end;

type
  TPropertyLoadImageThread = class(TThread)
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
    procedure GetPasswordFromUserSynch;
    procedure SetImage;
    procedure SetSizes;
  end;

implementation

uses PropertyForm, UnitPasswordForm;

{ TPropertyLoadImageThread }

constructor TPropertyLoadImageThread.Create(Options: TPropertyLoadImageThreadOptions);
begin
  inherited Create(False);
  FOptions := Options;
end;

procedure TPropertyLoadImageThread.Execute;
var
  Fb, Fb1, TempBitmap: TBitmap;
  Graphic : TGraphic;
  GraphicClass : TGraphicClass;
begin
  FreeOnTerminate := True;
  GraphicClass := GetGraphicClass(ExtractFileExt(FOptions.FileName), False);
  if GraphicClass = nil then
    Exit;

  Graphic := GraphicClass.Create;
  try
    if ValidCryptGraphicFile(FOptions.FileName) then
    begin
      PassWord := DBkernel.FindPasswordForCryptImageFile(FOptions.FileName);
      if PassWord = '' then
      begin
        StrParam := FOptions.FileName;
        Synchronize(GetPasswordFromUserSynch);
        PassWord := StrParam;
      end;
      if PassWord <> '' then
      begin
        F(Graphic);
        Graphic := DeCryptGraphicFile(FOptions.FileName, PassWord);
        StrParam := PassWord;
        Synchronize(SetCurrentPassword);
      end else
        Exit;
    end else
    begin
      if Graphic is TRAWImage then
      begin
        if not(Graphic as TRAWImage).LoadThumbnailFromFile(FOptions.FileName, ThSizePropertyPreview,
          ThSizePropertyPreview) then
          Graphic.LoadFromFile(FOptions.FileName);
      end else
        Graphic.LoadFromFile(FOptions.FileName);
    end;

    IntParamW := Graphic.Width;
    IntParamH := Graphic.Height;
    Synchronize(SetSizes);

    JPEGScale(Graphic,ThSizePropertyPreview, ThSizePropertyPreview);

    FB := TBitmap.Create;
    try
      FB.PixelFormat := Pf24bit;

      FB1 := TBitmap.Create;
      try
        FB1.PixelFormat := pf24bit;
        FB1.Width := ThSizePropertyPreview;
        FB1.Height := ThSizePropertyPreview;

        if Graphic.Width > Graphic.Height then
        begin
          FB.Width := ThSizePropertyPreview;
          FB.Height := Round(ThSizePropertyPreview * (Graphic.Height / Graphic.Width));
        end else
        begin
          FB.Width := Round(ThSizePropertyPreview * (Graphic.Width / Graphic.Height));
          FB.Height := ThSizePropertyPreview;
        end;

       TempBitmap:=TBitmap.Create;
       try
          TempBitmap.Assign(Graphic);
          F(Graphic);
          DoResize(FB.Width, FB.Height, TempBitmap, FB);
          F(TempBitmap);

          BitmapParam := FB1;

          FillRectNoCanvas(FB1, ClBtnFace);

          DrawImageEx(FB1, FB, ThSizePropertyPreview div 2 - FB.Width div 2,
            ThSizePropertyPreview div 2 - FB.Height div 2);

          Synchronize(SetImage);
        finally
          F(TempBitmap);
        end;
      finally
        F(FB1);
      end;
    finally
      F(FB);
    end;
  finally
    F(Graphic);
  end;
end;

procedure TPropertyLoadImageThread.GetPasswordFromUserSynch;
begin
  if PropertyManager.IsPropertyForm(fOptions.Owner) then
    if IsEqualGUID((fOptions.Owner as TPropertiesForm).SID, fOptions.SID) then
       StrParam:=GetImagePasswordFromUser(StrParam);
end;

procedure TPropertyLoadImageThread.SetCurrentPassword;
begin
  if PropertyManager.IsPropertyForm(fOptions.Owner) then
    if IsEqualGUID((fOptions.Owner as TPropertiesForm).SID, fOptions.SID) then
      (fOptions.Owner as TPropertiesForm).FCurrentPass:=StrParam;
end;

procedure TPropertyLoadImageThread.SetImage;
begin
  if PropertyManager.IsPropertyForm(fOptions.Owner) then
    if IsEqualGUID((fOptions.Owner as TPropertiesForm).SID, fOptions.SID) then
      begin
        if PassWord <> '' then
          DrawIconEx(BitmapParam.Canvas.Handle, 20, 0, UnitDBKernel.Icons[DB_IC_KEY + 1], 18, 18, 0, 0, DI_NORMAL);
        DrawIconEx(BitmapParam.Canvas.Handle, 0, 0, UnitDBKernel.Icons[DB_IC_NEW + 1], 18, 18, 0, 0, DI_NORMAL);

        with (FOptions.Owner as TPropertiesForm) do
        begin
          ImageLoadingFile.Visible := False;
          Image1.Picture.Graphic := BitmapParam;
          Image1.Refresh;
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
