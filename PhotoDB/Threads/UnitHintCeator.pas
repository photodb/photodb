unit UnitHintCeator;

interface

uses
  Math,
  SysUtils,
  Classes,
  System.Types,
  SyncObjs,
  Windows,
  ActiveX,
  Messages,
  StdCtrls,
  ComCtrls,
  ShellCtrls,
  ExtCtrls,
  Graphics,
  Controls,
  Forms,

  Dmitry.Utils.Files,

  GIFImage,
  GraphicEx,
  RAWImage,
  GraphicCrypt,

  uConstants,
  uMemory,
  uRuntime,
  uAnimatedJPEG,
  uJpegUtils,
  uBitmapUtils,
  uDBForm,
  uGraphicUtils,
  uAssociations,
  uDBThread,
  uDBEntities,
  uPortableDeviceUtils,
  uSessionPasswords,
  uImageLoader;

type
  THintCheckFunction = function(Info: TMediaItem): Boolean of object;

type
  THintCeator = class(TDBThread)
  private
    { Private declarations }
    Graphic: TGraphic;
    FOriginalWidth: Integer;
    FOriginalHeight: Integer;
    BooleanResult: Boolean;
    FStateID: TGUID;
    FInfo: TMediaItem;
    FOwner: TDBForm;
    FHintCheckProc: THintCheckFunction;
    FPoint: TPoint;
    function CheckThreadState: Boolean;
    procedure CheckThreadStateSync;
    procedure DoShowHint;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TDBForm; AStateID: TGUID; AInfo: TMediaItem; Point: TPoint;
      HintCheckProc: THintCheckFunction);
  end;

  THintManager = class(TObject)
  private
    FStateID: TGUID;
    FSync: TCriticalSection;
    FHints: TList;
    constructor Create;
  public
    destructor Destroy; override;
    class function Instance: THintManager;
    procedure CreateHintWindow(Owner: TDBForm; Info: TMediaItem;
      Point: TPoint; HintCheckProc: THintCheckFunction);
    procedure NewState;
    procedure RegisterHint(HintWindow: TForm);
    procedure UnRegisterHint(HintWindow: TForm);
    procedure CloseHint;
    function HintAtPoint(Point: TPoint): TForm;
  end;

implementation

uses
  UnitImHint;

var
  HintManager: THintManager = nil;

{ HintcCeator }

constructor THintCeator.Create(AOwner: TDBForm; AStateID: TGUID; AInfo: TMediaItem;
                              Point: TPoint; HintCheckProc: THintCheckFunction);
begin
  inherited Create(AOwner, False);
  FOwner := AOwner;
  FStateID := AStateID;
  FInfo := AInfo;
  FPoint := Point;
  FHintCheckProc := HintCheckProc;
  Graphic := nil;
end;

procedure THintCeator.Execute;
var
  Password: string;
  Bitmap, FB: TBitmap;
  FW, FH: Integer;
  ImageInfo: ILoadImageInfo;
begin
  inherited;
  FreeOnTerminate := True;
  CoInitializeEx(nil, COM_MODE);

  try
    if not IsDevicePath(FInfo.FileName) and not FInfo.FileExists then
      Exit;

    Password := '';
    if not IsDevicePath(FInfo.FileName) and ValidCryptGraphicFile(FInfo.FileName) then
    begin
      Password := SessionPasswords.FindForFile(FInfo.FileName);
      if Password = '' then
        Exit;
    end;

    if not CheckThreadState then
      Exit;

    Graphic := nil;
    try

      if not FInfo.InnerImage and not LoadImageFromPath(FInfo, -1, Password, [ilfGraphic, ilfICCProfile, ilfEXIF], ImageInfo, ThHintSize, ThHintSize) then
        Exit;

      if ImageInfo <> nil then
        Graphic := ImageInfo.ExtractGraphic;

      if not CheckThreadState then
        Exit;

      if FInfo.FileSize = 0 then
        FInfo.FileSize := GetFileSizeByName(FInfo.FileName);

      if not CheckThreadState then
        Exit;

      if not FInfo.InnerImage then
      begin
        FOriginalWidth := Graphic.Width;
        FOriginalHeight := Graphic.Height;
      end else
      begin
        FOriginalWidth := FInfo.Image.Width;
        FOriginalHeight := FInfo.Image.Height;
      end;

      if IsAnimatedGraphic(Graphic) then
      begin
        if (Graphic is TAnimatedJPEG) then
          TAnimatedJPEG(Graphic).ResizeTo(500, 500);
        SynchronizeEx(DoShowHint);
        Exit;
      end else
      begin
        if not FInfo.InnerImage then
          JPEGScale(Graphic, ThHintSize, ThHintSize);

        Bitmap := TBitmap.Create;
        try
          if FInfo.InnerImage then
            AssignGraphic(Bitmap, FInfo.Image)
          else
            AssignGraphic(Bitmap, Graphic);

          if not CheckThreadState then
            Exit;

          F(Graphic);
          FW := Bitmap.Width;
          FH := Bitmap.Height;
          if not FInfo.InnerImage then
            ProportionalSize(ThHintSize, ThHintSize, FW, FH);

          FB := TBitmap.Create;
          try
            FB.PixelFormat := Bitmap.PixelFormat;

            DoResize(FW, FH, Bitmap, FB);

            if not CheckThreadState then
              Exit;

            ApplyRotate(FB, FInfo.Rotation);

            if not CheckThreadState then
              Exit;

            if ImageInfo <> nil then
              ImageInfo.AppllyICCProfile(FB);

            if not CheckThreadState then
              Exit;

            Graphic := FB;
            FB := nil;
            if not SynchronizeEx(DoShowHint) then
              F(Graphic);
          finally
            F(FB);
          end;
        finally
          F(Bitmap);
        end;
      end;
    finally
      F(Graphic);
    end;
  finally
    F(FInfo);
  end;
end;

function THintCeator.CheckThreadState: boolean;
begin
  SynchronizeEx(CheckThreadStateSync);
  Result := BooleanResult;
end;

procedure THintCeator.CheckThreadStateSync;
begin
  BooleanResult := FHintCheckProc(FInfo);
end;

procedure THintCeator.DoShowHint;
var
  ImHint : TImHint;
begin
  Application.CreateForm(TImHint, ImHint);
  if not ImHint.Execute(FOwner, Graphic, FOriginalWidth, FOriginalHeight, FInfo.Copy, FPoint, FHintCheckProc) then
    F(Graphic);
  Graphic := nil;
end;

{ THintManager }

procedure THintManager.CloseHint;
var
  I: Integer;
begin
  for I := FHints.Count - 1 downto 0 do
    TForm(FHints[I]).Close;
end;

constructor THintManager.Create;
begin
  FHints := TList.Create;
  FSync := TCriticalSection.Create;
end;

procedure THintManager.CreateHintWindow(Owner: TDBForm;
  Info: TMediaItem; Point: TPoint; HintCheckProc : THintCheckFunction);
begin
  FSync.Enter;
  try
    NewState;
    THintCeator.Create(Owner, FStateID, Info, Point, HintCheckProc);
  finally
    FSync.Leave;
  end;
end;

destructor THintManager.Destroy;
begin
  F(FSync);
  F(FHints);
  inherited;
end;

function THintManager.HintAtPoint(Point: TPoint): TForm;
var
  I: Integer;
  R: TRect;
  HintWindow: TForm;
begin
  Result := nil;
  for I := 0 to FHints.Count - 1 do
  begin
    HintWindow := FHints[I];
    R := Rect(HintWindow.Left, HintWindow.Top, HintWindow.Left + HintWindow.Width, HintWindow.Top + HintWindow.Height);
    if PtInRect(R, Point) then
    begin
      Result := HintWindow;
      Exit;
    end;
  end;
end;

class function THintManager.Instance: THintManager;
begin
  if HintManager = nil then
    HintManager := THintManager.Create;

  Result := HintManager;
end;

procedure THintManager.NewState;
begin
  FSync.Enter;
  try
    CreateGUID(FStateID);
  finally
    FSync.Leave;
  end;
end;

procedure THintManager.RegisterHint(HintWindow: TForm);
begin
  FHints.Add(HintWindow);
end;

procedure THintManager.UnRegisterHint(HintWindow: TForm);
begin
  FHints.Remove(HintWindow);
end;

initialization

finalization

  F(HintManager);

end.
