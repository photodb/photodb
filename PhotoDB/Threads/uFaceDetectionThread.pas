unit uFaceDetectionThread;

interface

uses
  Windows, Classes, Graphics, uDBThread, uThreadForm, uFaceDetection, uMemory,
  xmldom, ActiveX, SysUtils, uLogger, win32crc, uFileUtils, uConstants, SyncObjs,
  uRuntime, uGraphicUtils, uGOM, uInterfaces, Math, uBitmapUtils, uSettings,
  uDateUtils, uPeopleSupport, u2DUtils, uConfiguration, uStringUtils;

const
  FACE_DETECTION_OK           = 0;
  FACE_DETECTION_NOT_READY    = 1;
  FACE_DETECTION_IN_PROGRESSS = 2;

type
  TFaceDetectionData = class;

  TFaceDetectionThread = class(TDBThread)
  private
    ImageData: TFaceDetectionData;
    FFaces: TFaceDetectionResult;
  protected
    procedure Execute; override;
    procedure UpdateFaceList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TDBFaceLoadThread = class(TDBThread)
  private
    FImageID: Integer;
    FPersonAreas: TPersonAreaCollection;
  protected
    procedure Execute; override;
  public
    constructor Create(ImageID: Integer);
    destructor Destroy; override;
  end;

  TFaceDetectionData = class
  public
    Image: TGraphic;
    FileName: string;
    ID: Integer;
    Caller: TThreadForm;
    constructor Create(AImage: TGraphic; AFileName: string; AID: Integer; ACaller: TThreadForm);
    destructor Destroy; override;
  end;

  TFaceDetectionDataManager = class(TObject)
  private
    FImages: TList;
    FSync: TCriticalSection;
    function CreateCacheFileName(DetectMethod, FileName: string): string;
    function CreateCacheFileDirectory(FileName: string): string;
    function CreateCacheFileXMLName(FileName: string): string;
    function ExtractData: TFaceDetectionData;
    function GetDetectionMethod: string;
  public
    procedure RequestFaceDetection(Caller: TThreadForm; var Image: TGraphic; FileName: string; ID: Integer);
    function GetFaceDataFromCache(CacheFileName: string; Faces: TFaceDetectionResult): Integer;
    function RotateCacheData(ImageFileName: string; Rotate: Integer): Boolean;
    function RotateDBData(ID: Integer; Rotate: Integer): Boolean;
    constructor Create;
    destructor Destroy; override;
    property DetectionMethod: string read GetDetectionMethod;
  end;

type
  TDBFaceDetectionResult = class helper for TFaceDetectionResult
  public
    function LoadFromFile(FileName: string): Boolean;
    function SaveToFile(FileName: string): Boolean;
    procedure MergeWithDBInfo(DBInfo: TPersonAreaCollection);
    procedure RemoveFaceResult(FR: TFaceDetectionResultItem);
    procedure RemoveCache;
  end;

function FaceDetectionDataManager: TFaceDetectionDataManager;

implementation

uses
  SlideShow;

var
  FManager: TFaceDetectionDataManager = nil;

function FaceDetectionDataManager: TFaceDetectionDataManager;
begin
  if FManager = nil then
    FManager := TFaceDetectionDataManager.Create;

  Result := FManager;
end;

{ TFaceDetectionThread }

constructor TFaceDetectionThread.Create;
begin
  inherited Create(nil, False);
  FFaces := TFaceDetectionResult.Create;
end;

destructor TFaceDetectionThread.Destroy;
begin
  F(FFaces);
  inherited;
end;

procedure TFaceDetectionThread.Execute;
var
  FBitmap, SmallBitmap: TBitmap;
  CacheFileName: string;
  LoadResult, W, H: Integer;
  RMp, AMp, RR: Double;
  FaceMethod: string;
  Thread: TDBFaceLoadThread;
begin
  inherited;
  FreeOnTerminate := True;
  CoInitialize(nil);
  try
    Priority := tpNormal;

    while not DBTerminating do
    begin
      Sleep(50);
      try
        ImageData := FaceDetectionDataManager.ExtractData;
        try
          if ImageData = nil then
            Continue;

          FFaces.Clear;

          FaceMethod := FaceDetectionDataManager.DetectionMethod;

          if ImageData.ID > 0 then
            Thread := TDBFaceLoadThread.Create(ImageData.ID);
          try
            CacheFileName := FaceDetectionDataManager.CreateCacheFileName(FaceMethod, ImageData.FileName);
            LoadResult := FaceDetectionDataManager.GetFaceDataFromCache(CacheFileName, FFaces);
            if LoadResult = FACE_DETECTION_OK then
            begin
              if ImageData.ID > 0 then
              begin
                Thread.WaitFor;
                FFaces.MergeWithDBInfo(Thread.FPersonAreas);
              end;
              Synchronize(UpdateFaceList);
              Continue;
            end;

            FBitmap := TBitmap.Create;
            try
              AssignGraphic(FBitmap, ImageData.Image);
              W := FBitmap.Width;
              H := FBitmap.Height;
              RMp := W * H;
              AMp := Settings.ReadInteger('Options', 'FaceDetectionSize', 3) * 100000;

              if RMp > AMp then
              begin
                RR := Sqrt(RMp / AMp);
                SmallBitmap := TBitmap.Create;
                try
                  ProportionalSize(Round(W / RR), Round(H / RR), W, H);
                  uBitmapUtils.QuickReduceWide(W, H, FBitmap, SmallBitmap);
                  FaceDetectionManager.FacesDetection(SmallBitmap, 0, FFaces, FaceMethod);
                finally
                  F(SmallBitmap);
                end;
              end else
                FaceDetectionManager.FacesDetection(FBitmap, 0, FFaces, FaceMethod);
            finally
              F(FBitmap);
            end;
            FFaces.SaveToFile(CacheFileName);

            if ImageData.ID > 0 then
            begin
              Thread.WaitFor;
              FFaces.MergeWithDBInfo(Thread.FPersonAreas);
            end;
            Synchronize(UpdateFaceList);
          finally
            if ImageData.ID > 0 then
              F(Thread);
          end;
        finally
          F(ImageData);
        end;
      except
        on e: Exception do
          EventLog(e);
      end;
    end;

  finally
    CoUninitialize;
  end;
end;

procedure TFaceDetectionThread.UpdateFaceList;
begin
  if GOM.IsObj(ImageData.Caller) and Supports(ImageData.Caller, IFaceResultForm) then
    (ImageData.Caller as IFaceResultForm).UpdateFaces(ImageData.FileName, FFaces);
end;

{ TFaceDetectionData }

constructor TFaceDetectionDataManager.Create;
begin
  FImages := TList.Create;
  FSync := TCriticalSection.Create;
  TFaceDetectionThread.Create;
end;

function TFaceDetectionDataManager.CreateCacheFileDirectory(
  FileName: string): string;
var
  CRC: Cardinal;
  Directory: string;
  I: Integer;
begin
  Directory := ExtractFileDir(FileName);
  for I := 1 to Length(Directory) do
    if CharInSet(Directory[I], ['/', '\', ':']) then
      Directory[I] := '_';

  CRC := StringCRC(Directory);
  Directory := Left(Directory, 250);

  Result := GetAppDataDirectory + FaceCacheDirectory + IntToStr(CRC and $FF) + '\' + IntToStr((CRC shr 8) and $FF) + '\' + IntToStr(CRC) + '\' + Directory;
end;

function TFaceDetectionDataManager.CreateCacheFileName(DetectMethod, FileName: string): string;
begin
  Result := CreateCacheFileDirectory(FileName) + '\' + DetectMethod + '\' + CreateCacheFileXMLName(FileName);
end;

function TFaceDetectionDataManager.CreateCacheFileXMLName(
  FileName: string): string;
begin
  Result := Left(ExtractFileName(FileName), 250) + '.xml';
end;

destructor TFaceDetectionDataManager.Destroy;
begin
  FreeList(FImages);
  F(FSync);
  inherited;
end;

function TFaceDetectionDataManager.ExtractData: TFaceDetectionData;
begin
  Result := nil;
  FSync.Enter;
  try
    if FImages.Count > 0 then
    begin
      Result := FImages[0];
      FImages.Delete(0);
    end;
  finally
    FSync.Leave;
  end;
end;

function TFaceDetectionDataManager.GetDetectionMethod: string;
begin
  Result := Settings.ReadString('Face', 'DetectionMethod', DefaultCascadeFileName);
end;

function TFaceDetectionDataManager.GetFaceDataFromCache(CacheFileName: string;
  Faces: TFaceDetectionResult): Integer;
begin
  Result := FACE_DETECTION_NOT_READY;
  if Faces.LoadFromFile(CacheFileName) then
    Result := FACE_DETECTION_OK;
end;

procedure TFaceDetectionDataManager.RequestFaceDetection(Caller: TThreadForm;
  var Image: TGraphic; FileName: string; ID: Integer);
var
  I: Integer;
  Data: TFaceDetectionData;
begin
  FSync.Enter;
  try
    if Image = nil then
      Exit;

    Data := TFaceDetectionData.Create(Image, FileName, ID, Caller);
    FImages.Insert(0, Data);
    Image := nil;
    for I := FImages.Count - 1 downto 1 do
    begin
      TObject(FImages[I]).Free;
      FImages.Delete(I);
    end;
  finally
    FSync.Leave;
  end;
end;

function TFaceDetectionDataManager.RotateCacheData(ImageFileName: string;
  Rotate: Integer): Boolean;
var
  Directory, FileName: string;
  SearchRec: TSearchRec;
  Found: Integer;
  Faces: TFaceDetectionResult;
begin
  Result := False;
  Directory := CreateCacheFileDirectory(ImageFileName);

  Found := FindFirst(Directory + '\*', faDirectory, SearchRec);
  try
    while Found = 0 do
    begin
      if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
      begin
        FileName := Directory + '\' + SearchRec.Name + '\' + CreateCacheFileXMLName(ImageFileName);
        if FileExistsSafe(FileName) then
        begin
          Faces := TFaceDetectionResult.Create;
          try
            if Faces.LoadFromFile(FileName) and (Faces.Count > 0) then
            begin
              case Rotate of
                DB_IMAGE_ROTATE_270:
                  Faces.RotateLeft;
                DB_IMAGE_ROTATE_90:
                  Faces.RotateRight;
                DB_IMAGE_ROTATE_180:
                  begin
                    Faces.RotateRight;
                    Faces.RotateRight;
                  end;
              end;

              Faces.SaveToFile(FileName);
            end;
          finally
            F(Faces);
          end;
        end;
      end;
      Found := SysUtils.FindNext(SearchRec);
    end;
  finally
    FindClose(SearchRec);
  end;

end;

function TFaceDetectionDataManager.RotateDBData(ID, Rotate: Integer): Boolean;
var
  PersonAreas: TPersonAreaCollection;
begin
  PersonAreas := PersonManager.GetAreasOnImage(ID);
  try
    case Rotate of
      DB_IMAGE_ROTATE_270:
        PersonAreas.RotateLeft;
      DB_IMAGE_ROTATE_90:
        PersonAreas.RotateRight;
      DB_IMAGE_ROTATE_180:
        begin
          PersonAreas.RotateRight;
          PersonAreas.RotateRight;
        end;
    end;
    PersonAreas.UpdateDB;
    Result := True;
  finally
    F(PersonAreas);
  end;
end;

{ TFaceDetectionData }

constructor TFaceDetectionData.Create(AImage: TGraphic; AFileName: string;
  AID: Integer; ACaller: TThreadForm);
begin
  Image := AImage;
  FileName := AFileName;
  ID := AID;
  Caller := ACaller;
end;

destructor TFaceDetectionData.Destroy;
begin
  F(Image);
  inherited;
end;

{ TDBFaceDetectionResult }

function TDBFaceDetectionResult.LoadFromFile(FileName: string): Boolean;
var
  I: Integer;
  Doc: IDOMDocument;
  DocumentElement: IDOMElement;
  FacesList: IDOMNodeList;
  FaceNode: IDOMNode;
  XAttr, YAttr, WidthAttr, HeightAttr,
  ImageWidthAttr, ImageHeightAttr, PageAttr, SizeAttr, DateModifiedAttr: IDOMNode;
begin
  Result := False;
  Doc := GetDOM.createDocument('', '', nil);
  try
    (Doc as IDOMPersist).load(FileName);
    DocumentElement := Doc.documentElement;
    if DocumentElement <> nil then
    begin
      PageAttr := DocumentElement.attributes.getNamedItem('Page');
      SizeAttr := DocumentElement.attributes.getNamedItem('Size');
      DateModifiedAttr := DocumentElement.attributes.getNamedItem('DateModified');

      if ImageWidthAttr <> nil then
      if ImageHeightAttr <> nil then
      if PageAttr <> nil then
        Page := StrToIntDef(PageAttr.nodeValue, 0);
      if SizeAttr <> nil then
        Size := StrToInt64Def(SizeAttr.nodeValue, 0);
      if DateModifiedAttr <> nil then
        DateModified := DateTimeStrEval(DateModifiedAttr.nodeValue, 'yyyy.MM.dd mm:ss');

      FacesList := DocumentElement.childNodes;
      if FacesList <> nil then
      begin
        for I := 0 to FacesList.length - 1 do
        begin
          FaceNode := FacesList.item[I];

          XAttr := FaceNode.attributes.getNamedItem('X');
          YAttr := FaceNode.attributes.getNamedItem('Y');
          WidthAttr := FaceNode.attributes.getNamedItem('Width');
          HeightAttr := FaceNode.attributes.getNamedItem('Height');
          ImageWidthAttr := FaceNode.attributes.getNamedItem('ImageWidth');
          ImageHeightAttr := FaceNode.attributes.getNamedItem('ImageHeight');

          if (XAttr <> nil) and (YAttr <> nil) and (WidthAttr <> nil) and (HeightAttr <> nil) and (ImageWidthAttr <> nil) and (ImageHeightAttr <> nil) then
            AddFace(StrToIntDef(XAttr.nodeValue, 0), StrToIntDef(YAttr.nodeValue, 0),
              StrToIntDef(WidthAttr.nodeValue, 0), StrToIntDef(HeightAttr.nodeValue, 0),
              StrToIntDef(ImageWidthAttr.nodeValue, 0), StrToIntDef(ImageHeightAttr.nodeValue, 0), Page);
        end;
      end;

      PersistanceFileName := FileName;
      Result := True;
    end;
  except
    on e: Exception do
     EventLog(e);
  end;
end;

function TDBFaceDetectionResult.SaveToFile(FileName: string): Boolean;
var
  I: Integer;
  Doc: IDOMDocument;
  DocumentElement: IDOMElement;
  FaceNode: IDOMNode;

  procedure AddProperty(Name: string; Value: string);
  var
    Attr: IDOMAttr;
  begin
    Attr := Doc.createAttribute(Name);
    Attr.value := Value;
    FaceNode.attributes.setNamedItem(Attr);
  end;

begin
  Result := False;
  Doc := GetDOM.createDocument('', '', nil);
  try
    DocumentElement := Doc.createElement('faces');
    Doc.documentElement := DocumentElement;

    FaceNode := DocumentElement;
    AddProperty('Size', IntToStr(Size));
    AddProperty('DateModified', FormatDateTime('yyyy.MM.dd mm:ss', DateModified));

    for I := 0 to Count - 1 do
    begin
      FaceNode := Doc.createElement('face');

      AddProperty('X', IntToStr(Items[I].X));
      AddProperty('Y', IntToStr(Items[I].Y));
      AddProperty('Width', IntToStr(Items[I].Width));
      AddProperty('Height', IntToStr(Items[I].Height));
      AddProperty('ImageWidth', IntToStr(Items[I].ImageWidth));
      AddProperty('ImageHeight', IntToStr(Items[I].ImageHeight));

      Doc.documentElement.appendChild(FaceNode);
    end;

    CreateDirA(ExtractFileDir(FileName));
    (Doc as IDOMPersist).save(FileName);

    PersistanceFileName := FileName;
    Result := True;
  except
    on e: Exception do
      EventLog(e);
  end;
end;

procedure TDBFaceDetectionResult.MergeWithDBInfo(DBInfo: TPersonAreaCollection);
var
  I, J: Integer;
  PA: TPersonArea;
  FA: TFaceDetectionResultItem;

  function FaceEquals(A: TPersonArea; F: TFaceDetectionResultItem): Boolean;
  var
    RA, RF: TRect;
  begin
    RA.Left   := Round(A.X * 1000 / A.FullWidth);
    RA.Top    := Round(A.Y * 1000 / A.FullHeight);
    RA.Right  := Round((A.X + A.Width)  * 1000 / A.FullWidth);
    RA.Bottom := Round((A.Y + A.Height) * 1000 / A.FullHeight);

    RF.Left   := Round(F.X * 1000 / F.ImageWidth);
    RF.Top    := Round(F.Y * 1000 / F.ImageHeight);
    RF.Right  := Round((F.X + F.Width)  * 1000 / F.ImageWidth);
    RF.Bottom := Round((F.Y + F.Height) * 1000 / F.ImageHeight);

    Result := RectIntersectWithRectPercent(RA, RF) > 90;
  end;

begin
  for I := DBInfo.Count - 1 downto 0 do
  begin
    PA := DBInfo[I];
    for J := 0 to Count - 1 do
    begin
      FA := Items[J];
      if FaceEquals(PA, FA) then
      begin
        FA.Data := DBInfo.Extract(I);
        Break;
      end;
    end;
  end;


  for I := DBInfo.Count - 1 downto 0 do
  begin       
    PA := DBInfo[I];

    FA := TFaceDetectionResultItem.Create;
    FA.X := PA.X;
    FA.Y := PA.Y;
    FA.Width := PA.Width;
    FA.Height := PA.Height;
    FA.ImageWidth := PA.FullWidth;
    FA.ImageHeight := PA.FullHeight;
    FA.Page := PA.Page;
    FA.Data := DBInfo.Extract(I);
    Add(FA);

  end;
end;

procedure TDBFaceDetectionResult.RemoveCache;
begin
  DeleteFile(PersistanceFileName);
end;

procedure TDBFaceDetectionResult.RemoveFaceResult(FR: TFaceDetectionResultItem);
begin
  Remove(FR);
  SaveToFile(PersistanceFileName);
end;

{ TDBFaceLoadThread }

constructor TDBFaceLoadThread.Create(ImageID: Integer);
begin
  inherited Create(nil, False);
  FImageID := ImageID;
  FPersonAreas := nil;
end;

destructor TDBFaceLoadThread.Destroy;
begin
  F(FPersonAreas);
  inherited;
end;

procedure TDBFaceLoadThread.Execute;
begin
  inherited;
  CoInitialize(nil);
  try
    FPersonAreas := PersonManager.GetAreasOnImage(FImageID);
  finally
    CoUninitialize;
  end;
end;

initialization

finalization
  F(FManager);

end.
