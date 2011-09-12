unit uFaceDetectionThread;

interface

uses
  Classes, Graphics, uDBThread, uThreadForm, uFaceDetection, uMemory, SyncObjs,
  xmldom, ActiveX, SysUtils, uLogger, win32crc, uFileUtils, uConstants,
  uRuntime, uGraphicUtils, uGOM, uInterfaces, Math, uBitmapUtils, uSettings;

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

  TFaceDetectionData = class
  public
    Image: TGraphic;
    FileName: string;
    Caller: TThreadForm;
    constructor Create(AImage: TGraphic; AFileName: string; ACaller: TThreadForm);
    destructor Destroy; override;
  end;

  TFaceDetectionDataManager = class(TObject)
  private
    FImages: TList;
    FSync: TCriticalSection;
    function CreateCacheFileName(DetectMethod, FileName: string): string;
    function ExtractData: TFaceDetectionData;
  public
    procedure RequestFaceDetection(Caller: TThreadForm; var Image: TGraphic; FileName: string);
    function GetFaceData(FileName: string; Faces: TFaceDetectionResult): Integer;
    constructor Create;
    destructor Destroy; override;
  end;

type
  TDBFaceDetectionResult = class helper for TFaceDetectionResult
  public
    function LoadFromFile(FileName: string): Boolean;
    function SaveToFile(FileName: string): Boolean;
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
  LoadResult: Integer;
  FBitmap, SmallBitmap: TBitmap;
  CacheFileName: string;
  W, H: Integer;
  RMp, AMp, RR: Double;
  FaceMethod: string;
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

          FaceMethod := Settings.ReadString('Face', 'DetectionMethod', DefaultCascadeFileName);

          CacheFileName := FaceDetectionDataManager.CreateCacheFileName(FaceMethod, ImageData.FileName);
         { LoadResult := FaceDetectionDataManager.GetFaceData(CacheFileName, FFaces);
          if LoadResult = FACE_DETECTION_OK then
          begin
            Synchronize(UpdateFaceList);
            Continue;
          end;    }

          FBitmap := TBitmap.Create;
          try
            AssignGraphic(FBitmap, ImageData.Image);
            W := FBitmap.Width;
            H := FBitmap.Height;
            RMp := W * H;
            AMp := 0.3 * 1000000;

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
          Synchronize(UpdateFaceList);
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

function TFaceDetectionDataManager.CreateCacheFileName(DetectMethod, FileName: string): string;
var
  CRC, DetectCRC: Cardinal;
begin
  CRC := StringCRC(FileName);
  DetectCRC := StringCRC(DetectMethod);
  Result := GetAppDataDirectory + FaceCacheDirectory + IntToStr(DetectCRC and $FF) + '\' + IntToStr(CRC and $FF) + '\' + IntToStr((CRC shr 8) and $FF) + '\' + ExtractFileName(FileName) + '.xml';
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

function TFaceDetectionDataManager.GetFaceData(FileName: string;
  Faces: TFaceDetectionResult): Integer;
begin
  Result := FACE_DETECTION_NOT_READY;
  if Faces.LoadFromFile(FileName) then
    Result := FACE_DETECTION_OK;
end;

procedure TFaceDetectionDataManager.RequestFaceDetection(Caller: TThreadForm;
  var Image: TGraphic; FileName: string);
var
  I: Integer;
  Data: TFaceDetectionData;
begin
  FSync.Enter;
  try
    if Image = nil then
      Exit;

    Data := TFaceDetectionData.Create(Image, FileName, Caller);
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

{ TFaceDetectionData }

constructor TFaceDetectionData.Create(AImage: TGraphic; AFileName: string;
  ACaller: TThreadForm);
begin
  Image := AImage;
  FileName := AFileName;
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
  XAttr, YAttr, WidthAttr, HeightAttr: IDOMNode;
begin
  Result := False;
  Doc := GetDOM.createDocument('', '', nil);
  try
    (Doc as IDOMPersist).load(FileName);
    DocumentElement := Doc.documentElement;
    if DocumentElement <> nil then
    begin
      {ImageWidthAttr := DocumentElement.getNamedItem('ImageWidth');
      ImageHeightAttr := DocumentElement.getNamedItem('ImageHeight');
      PageAttr := DocumentElement.getNamedItem('Page');
      SizeAttr := DocumentElement.getNamedItem('Size');
      DateModifiedAttr := DocumentElement.getNamedItem('DateModified');}

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

          if (XAttr <> nil) and (YAttr <> nil) and (WidthAttr <> nil) and (HeightAttr <> nil) then
            AddFace(StrToIntDef(XAttr.nodeValue, 0), StrToIntDef(YAttr.nodeValue, 0),
              StrToIntDef(WidthAttr.nodeValue, 0), StrToIntDef(HeightAttr.nodeValue, 0));
        end;
      end;
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

    for I := 0 to Count - 1 do
    begin
      FaceNode := Doc.createElement('face');

      AddProperty('X', IntToStr(Items[I].X));
      AddProperty('Y', IntToStr(Items[I].Y));
      AddProperty('Width', IntToStr(Items[I].Width));
      AddProperty('Height', IntToStr(Items[I].Height));

      Doc.documentElement.appendChild(FaceNode);
    end;

    CreateDirA(ExtractFileDir(FileName));
    (Doc as IDOMPersist).save(FileName);
    Result := True;
  except
    on e: Exception do
      EventLog(e);
  end;
end;

initialization

finalization
  F(FManager);

end.
