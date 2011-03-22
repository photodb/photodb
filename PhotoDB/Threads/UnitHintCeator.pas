unit UnitHintCeator;

interface

uses
  Windows, Messages, SysUtils, Classes, ExtCtrls, JPEG, DB,
  Graphics, Controls, Forms, GIFImage, GraphicEx, Math, UnitDBCommonGraphics,
  Dialogs, StdCtrls, ComCtrls, ShellCtrls, RAWImage,
  GraphicCrypt, UnitDBCommon, uGOM, uFileUtils,
  uMemory, SyncObjs, dolphin_db, UnitDBKernel, UnitDBDeclare,
  uGraphicUtils, uRuntime, uAssociations;

type
  HintCeator = class(TThread)
  private
    { Private declarations }
    Graphic: TGraphic;
    FOriginalWidth: Integer;
    FOriginalHeight: Integer;
    BooleanResult: Boolean;
    FStateID: TGUID;
    FInfo : TDBPopupMenuInfoRecord;
    FOwner : TForm;
    FHintCheckProc : THintCheckFunction;
    FPoint : TPoint;
    function CheckThreadState: Boolean;
    procedure CheckThreadStateSync;
    procedure DoShowHint;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner : TForm; AStateID : TGUID; AInfo : TDBPopupMenuInfoRecord;
      Point : TPoint; HintCheckProc : THintCheckFunction);
  end;

  THintManager = class(TObject)
  private
    FStateID : TGUID;
    FSync : TCriticalSection;
    FHints : TList;
    constructor Create;
  public
    destructor Destroy; override;
    class function Instance : THintManager;
    procedure CreateHintWindow(Owner : TForm; Info : TDBPopupMenuInfoRecord;
      Point : TPoint; HintCheckProc : THintCheckFunction);
    procedure NewState;
    procedure RegisterHint(HintWindow : TForm);
    procedure UnRegisterHint(HintWindow : TForm);
    procedure CloseHint;
    function HintAtPoint(Point : TPoint) : TForm;
  end;

implementation

uses UnitImHint;

var
  HintManager : THintManager = nil;

{ HintcCeator }

constructor HintCeator.Create(AOwner : TForm; AStateID : TGUID; AInfo : TDBPopupMenuInfoRecord;
                              Point : TPoint; HintCheckProc : THintCheckFunction);
begin
  inherited Create(False);
  FOwner := AOwner;
  FStateID := AStateID;
  FInfo := AInfo;
  FPoint := Point;
  FHintCheckProc := HintCheckProc;
  Graphic := nil;
end;

procedure HintCeator.Execute;
var
  GraphicClass : TGraphicClass;
  Crypted : Boolean;
  FilePass: string;
  Bitmap, FB : TBitmap;
  FW, FH : Integer;
begin
  FreeOnTerminate := True;

  try
    if not FileExistsSafe(FInfo.FileName) then
      Exit;

    GraphicClass := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(FInfo.FileName));
    if GraphicClass = nil then
      Exit;

    Graphic := GraphicClass.Create;
    try
      Crypted := False;
      FilePass := '';
      if ValidCryptGraphicFile(FInfo.FileName) then
      begin
        Crypted := True;
        FilePass := DBKernel.FindPasswordForCryptImageFile(FInfo.FileName);
        if FilePass = '' then
          Exit;
      end;

      if not CheckThreadState then
        Exit;

      FInfo.FileSize := GetFileSizeByName(FInfo.FileName);

      if not CheckThreadState then
        Exit;

      if Crypted then
      begin
        F(Graphic);
        Graphic := DeCryptGraphicFile(FInfo.FileName, FilePass);
        if Graphic = nil then
          Exit;
      end else
      begin
        if Graphic is TRAWImage then
        begin
          if not (Graphic as TRAWImage).LoadThumbnailFromFile(FInfo.FileName, ThHintSize, ThHintSize) then
            Graphic.LoadFromFile(FInfo.FileName);
        end else
          Graphic.LoadFromFile(FInfo.FileName);
      end;

      if not CheckThreadState then
        Exit;

      FOriginalWidth := Graphic.Width;
      FOriginalHeight := Graphic.Height;

      if (Graphic is TGifImage) and (TGifImage(Graphic).Images.Count > 1) then
      begin
        Synchronize(DoShowHint);
        Exit;
      end else
      begin
        JPEGScale(Graphic, ThHintSize, ThHintSize);
        Bitmap := TBitmap.Create;
        try
          AssignGraphic(Bitmap, Graphic);

          if not CheckThreadState then
            exit;

          F(Graphic);
          FW := Bitmap.Width;
          FH := Bitmap.Height;
          ProportionalSize(ThHintSize, ThHintSize, FW, FH);

          FB := TBitmap.Create;
          try
            FB.PixelFormat := Bitmap.PixelFormat;

            DoResize(FW, FH, Bitmap, FB);

            if not CheckThreadState then
              exit;

            ApplyRotate(FB, FInfo.Rotation);

            if not CheckThreadState then
              exit;

            Graphic := FB;
            FB := nil;
            Synchronize(DoShowHint);
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

function HintCeator.CheckThreadState: boolean;
begin
  Synchronize(CheckThreadStateSync);
  Result := BooleanResult;
end;

procedure HintCeator.CheckThreadStateSync;
begin
  if GOM.IsObj(FOwner) then
    BooleanResult := FHintCheckProc(FInfo);
end;

procedure HintCeator.DoShowHint;
var
  ImHint : TImHint;
begin
  Application.CreateForm(TImHint, ImHint);
  ImHint.Execute(FOwner, Graphic, FOriginalWidth, FOriginalHeight, FInfo.Copy, FPoint, FHintCheckProc);
  Graphic := nil;
end;

{ THintManager }

procedure THintManager.CloseHint;
var
  I : Integer;
begin
  for I := FHints.Count - 1 downto 0 do
    TForm(FHints[I]).Close;
end;

constructor THintManager.Create;
begin
  FHints := TList.Create;
  FSync := TCriticalSection.Create;
end;

procedure THintManager.CreateHintWindow(Owner: TForm;
  Info: TDBPopupMenuInfoRecord; Point: TPoint; HintCheckProc : THintCheckFunction);
begin
  FSync.Enter;
  try
    NewState;
    HintCeator.Create(Owner, FStateID, Info, Point, HintCheckProc);
  finally
    FSync.Leave;
  end;
end;

destructor THintManager.Destroy;
begin
  FSync.Free;
  FHints.Free;
  inherited;
end;

function THintManager.HintAtPoint(Point: TPoint): TForm;
var
  I : Integer;
  R : TRect;
  HintWindow : TForm;
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

  THintManager.Instance.Free;

end.
