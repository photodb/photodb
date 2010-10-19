unit UnitPanelLoadingBigImagesThread;

interface

uses
  Windows, Classes, SysUtils, Forms, Graphics, Math, GraphicCrypt, Dolphin_DB,
  UnitDBDeclare, RAWImage, UnitDBCommonGraphics, UnitDBCommon,
  UnitCDMappingSupport, uLogger, ImageConverting, uMemory;

type
  TPanelLoadingBigImagesThread = class(TThread)
  private
    { Private declarations }
    FSender: TForm;
    FSID: TGUID;
    FOnDone: TNotifyEvent;
    FPictureSize: Integer;
    FData: TDBPopupMenuInfo;
    FVisibleFiles: TArStrings;
    BoolParam: Boolean;
    StrParam: string;
    Intparam: Integer;
    BitmapParam: TBitmap;
    FI: Integer;
    FUpdating: Boolean;
    procedure VisibleUp(TopIndex: integer);
    procedure FileNameExists;
    procedure GetVisibleFiles;
  protected
    procedure Execute; override;
  public
    constructor Create(Sender : TForm; SID : TGUID;
      AOnDone : TNotifyEvent; PictureSize : integer; Files : TDBPopupMenuInfo; Updating : boolean = false);
    procedure ReplaceBigBitmap;
    procedure DoStopLoading;
    destructor Destroy; override;
  end;

var
  PanelUpdateBigImageThreadsCount: Integer = 0;
  PanelUpdateBigImageThreadsCountByID: Integer = 0;

implementation

uses UnitFormCont;

{ TPanelLoadingBigImagesThread }

constructor TPanelLoadingBigImagesThread.Create(Sender : TForm; SID : TGUID;
      AOnDone : TNotifyEvent; PictureSize : integer; Files : TDBPopupMenuInfo; Updating : boolean = false);
begin
  inherited Create(False);
  FData := TDBPopupMenuInfo.Create;
  FData.Assign(Files);
  FSender := Sender;
  FSID := SID;
  FOnDone := AOnDone;
  FPictureSize := PictureSize;
  FUpdating := Updating;
end;

procedure TPanelLoadingBigImagesThread.VisibleUp(TopIndex: integer);
var
  I, C: Integer;
  J: Integer;
begin
  C := TopIndex;
  for I := 0 to Length(FVisibleFiles) - 1 do
    for J := TopIndex to FData.Count - 1 do
    begin
      if FVisibleFiles[I] = FData[J].FileName then
      begin
        FData.Exchange(C, J);
        Inc(C);
      end;
    end;
end;

procedure TPanelLoadingBigImagesThread.Execute;
var
  I: Integer;
  GraphicClass: TGraphicClass;
  Graphic: TGraphic;
  PassWord: string;
  FBit, TempBitmap: TBitmap;
  W, H: Integer;
begin
  FreeOnTerminate := True;

  if not FUpdating then
  begin

    repeat
      Sleep(100);
    until PanelUpdateBigImageThreadsCount < (ProcessorCount + 1);

    PanelUpdateBigImageThreadsCount := PanelUpdateBigImageThreadsCount + 1;

    for I := 0 to FData.Count - 1 do
    begin

      if I mod 5 = 0 then
      begin
        Synchronize(GetVisibleFiles);
        VisibleUp(I);
      end;

      StrParam := FData[I].FileName;
      Synchronize(FileNameExists);
      if BoolParam then
      begin

        GraphicClass := GetGraphicClass(ExtractFileExt(StrParam), False);
        if GraphicClass = nil then
          Continue;
        Graphic := GraphicClass.Create;

        try
          if GraphicCrypt.ValidCryptGraphicFile(ProcessPath(StrParam)) then
          begin
            PassWord := DBKernel.FindPasswordForCryptImageFile(StrParam);
            if PassWord = '' then
              Continue;

            F(Graphic);
            Graphic := DeCryptGraphicFile(ProcessPath(StrParam), PassWord);
          end else
          begin
            if Graphic is TRAWImage then
            begin
              if not(Graphic as TRAWImage).LoadThumbnailFromFile(StrParam, FPictureSize, FPictureSize) then
                Graphic.LoadFromFile(ProcessPath(StrParam));
            end else
              Graphic.LoadFromFile(ProcessPath(StrParam));
          end;

          JPEGScale(Graphic, FPictureSize, FPictureSize);
          Fbit := TBitmap.Create;
          try
            Fbit.PixelFormat := Pf24bit;

            LoadImageX(Graphic, Fbit, clWindow);
            F(Graphic);
            TempBitmap := TBitmap.Create;
            try
              TempBitmap.PixelFormat := Pf24bit;
              W := Fbit.Width;
              H := Fbit.Height;
              ProportionalSize(FPictureSize, FPictureSize, W, H);
              TempBitmap.Width := W;
              TempBitmap.Height := H;
              DoResize(W, H, Fbit, TempBitmap);
              F(FBit);

              ApplyRotate(TempBitmap, FData[I].Rotation);
              BitmapParam := TempBitmap;
              FI := I + 1;
              IntParam := FI;

              Synchronize(ReplaceBigBitmap);
            finally
              F(TempBitmap);
            end;
          finally
            F(Fbit);
          end;

        finally
          F(Graphic);
        end;
      end;
    end;
  end else
  begin
    repeat
      Sleep(100);
    until PanelUpdateBigImageThreadsCountByID < (ProcessorCount + 1);

    PanelUpdateBigImageThreadsCountByID := PanelUpdateBigImageThreadsCountByID + 1;
  end;
  Synchronize(DoStopLoading);
end;

procedure TPanelLoadingBigImagesThread.FileNameExists;
begin
  BoolParam:=false;
  if ManagerPanels.IsPanelForm(FSender) then
    if IsEqualGUID((FSender as TFormCont).BigImagesSID, FSID) then
      if (FSender as TFormCont).FileNameExistsInList(StrParam) then
        BoolParam:=true;
end;

procedure TPanelLoadingBigImagesThread.GetVisibleFiles;
begin
  if ManagerPanels.IsPanelForm(FSender) then
  begin
    FVisibleFiles := (FSender as TFormCont).GetVisibleItems;
    if not FSender.Active then
      Priority := TpLowest;
  end
end;

destructor TPanelLoadingBigImagesThread.Destroy;
begin
  if not FUpdating then
    Dec(PanelUpdateBigImageThreadsCount)
  else
    Dec(PanelUpdateBigImageThreadsCountByID);

  inherited Destroy;
  F(FData);
end;

procedure TPanelLoadingBigImagesThread.ReplaceBigBitmap;
begin
  if ManagerPanels.IsPanelForm(FSender) then
    if IsEqualGUID((FSender as TFormCont).BigImagesSID, FSID) then
      (FSender as TFormCont).ReplaseBitmapWithPath(StrParam,BitmapParam);
end;

procedure TPanelLoadingBigImagesThread.DoStopLoading;
begin
  if ManagerPanels.ExistsPanel(FSender, FSID) then
    (FSender as TFormCont).DoStopLoading(FSID)
  else
    Exit;
end;

end.
