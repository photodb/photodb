unit UnitPropertyLoadGistogrammThread;

interface

uses
  Windows, Classes, Messages, Forms, Graphics, SysUtils, RAWImage,
  Dolphin_DB, UnitDBKernel, GraphicCrypt, JPEG, Effects, GraphicsBaseTypes,
  uMemory, uGraphicUtils, uDBGraphicTypes, uAssociations;

type
  TPropertyLoadGistogrammThreadOptions = record
    FileName : String;
    Owner : TForm;
    SID : TGUID;
    OnDone : TNotifyEvent;
  end;

type
  TPropertyLoadGistogrammThread = class(TThread)
  private
    { Private declarations }
    FOptions: TPropertyLoadGistogrammThreadOptions;
    StrParam: string;
    Password: string;
    Data: TGistogrammData;
  protected
    procedure Execute; override;
  public
    constructor Create(Options : TPropertyLoadGistogrammThreadOptions);
    procedure GetCurrentpassword;
    procedure GetPasswordFromUserSynch;
    procedure SetGistogrammData;
    procedure DoOnDone;
  end;

implementation

uses PropertyForm, UnitPasswordForm;

{ TPropertyLoadGistogrammThread }

constructor TPropertyLoadGistogrammThread.Create(Options: TPropertyLoadGistogrammThreadOptions);
begin
  inherited Create(False);
  FOptions := Options;
end;

function Gistogramma(w,h : integer; S : PARGBArray) : TGistogrammData;
var
  I, j : integer;
  ps : PARGB;
  LGray, LR, LG, LB : byte;
begin
  for I := 0 to 255 do
  begin
    Result.Gray[I] := 0;
    Result.Red[I] := 0;
    Result.Green[I] := 0;
    Result.Blue[I] := 0;
  end;

  for I := 0 to H - 1 do
  begin
    Ps := S[I];
    for J := 0 to W - 1 do
    begin
      LR := ps[J].R;
      LG := ps[J].G;
      LB := ps[J].B;
      LGray:= (LR * 77 + LG * 151 + LB * 28) shr 8;
      Inc(Result.Gray[LGray]);
      Inc(Result.Red[LR]);
      Inc(Result.Green[LG]);
      Inc(Result.Blue[LB]);
    end;
  end;
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
  PRGBArr: PARGBArray;
  I: Integer;
  Graphic: TGraphic;
  GraphicClass : TGraphicClass;
  OldMode : Cardinal;
begin
  FreeOnTerminate := True;
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    GraphicClass := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(FOptions.FileName));
    if GraphicClass = nil then
      Exit;

    Graphic := GraphicClass.Create;
    try
      if ValidCryptGraphicFile(FOptions.FileName) then
      begin
        PassWord := DBkernel.FindPasswordForCryptImageFile(FOptions.FileName);
        Synchronize(GetCurrentpassword);
        if ValidPassInCryptGraphicFile(FOptions.FileName, StrParam) then
          PassWord := StrParam;
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
        end else
          Exit;
      end else
        Graphic.LoadFromFile(fOptions.FileName);

      if Graphic is TJPEGImage then
      begin
        if Graphic.Width * Graphic.Height > 640 * 480 then
          JPEGScale(Graphic, 640, 480);
      end;
      Bitmap := TBitmap.Create;
      try
        Bitmap.Assign(Graphic);
        F(Graphic);
        Bitmap.PixelFormat := pf24bit;
        SetLength(PRGBArr, Bitmap.Height);
        for I := 0 to Bitmap.Height - 1 do
          PRGBArr[I] := Bitmap.ScanLine[I];
        Data := Gistogramma(Bitmap.Width, Bitmap.Height, PRGBArr);
      finally
        Bitmap.Free;
      end;
      Synchronize(SetGistogrammData);
    finally
      F(Graphic);
    end;
  finally
    SetErrorMode(OldMode);
    Synchronize(DoOnDone);
  end;
end;

procedure TPropertyLoadGistogrammThread.GetCurrentpassword;
begin
  if PropertyManager.IsPropertyForm(fOptions.Owner) then
    if IsEqualGUID((fOptions.Owner as TPropertiesForm).SID, fOptions.SID) then
      StrParam := (fOptions.Owner as TPropertiesForm).FCurrentPass;
end;

procedure TPropertyLoadGistogrammThread.GetPasswordFromUserSynch;
begin
  if PropertyManager.IsPropertyForm(fOptions.Owner) then
    if IsEqualGUID((fOptions.Owner as TPropertiesForm).SID, fOptions.SID) then
      StrParam:=GetImagePasswordFromUser(StrParam);
end;

procedure TPropertyLoadGistogrammThread.SetGistogrammData;
begin
  if PropertyManager.IsPropertyForm(FOptions.Owner) then
    if IsEqualGUID((FOptions.Owner as TPropertiesForm).SID, FOptions.SID) then
      (FOptions.Owner as TPropertiesForm).GistogrammData := Data;
end;

end.
