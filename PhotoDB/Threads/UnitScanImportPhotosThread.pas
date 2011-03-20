unit UnitScanImportPhotosThread;

interface

uses
  Classes, Messages, Forms, Dolphin_DB, RawImage, SysUtils,
  UnitDBDeclare, DateUtils, UnitDBCommon, uAssociations,
  CCR.Exif, uMemory, uDBBaseTypes, uFileUtils, uTranslate,
  uGraphicUtils;

type
  TScanImportPhotosThreadOptions = record
    Directory: string;
    Mask: string;
    OnEnd: TNotifyEvent;
    Owner: TForm;
    OnProgress: TCallBackProgressEvent;
  end;

  TFileDateRecord = record
    FileName: string;
    Date: TDateTime;
    Options: Integer;
    Tag: Integer;
  end;

 TFileDateList = array of TFileDateRecord;

 const
  DIRECTORY_OPTION_DATE_SINGLE      = 0;
  DIRECTORY_OPTION_DATE_WITH_UP     = 1;
  DIRECTORY_OPTION_DATE_WITH_DOWN   = 2;
  DIRECTORY_OPTION_DATE_EXCLUDE     = 3;

type
  TScanImportPhotosThread = class(TThread)
  private
    { Private declarations }
    FOptions: TScanImportPhotosThreadOptions;
    FFiles: TStrings;
    FSID: TGUID;
    StrParam: string;
    BoolParam: Boolean;
    DateFileList: TFileDateList;
    IntParam: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspennded: Boolean; Options: TScanImportPhotosThreadOptions);
    procedure AddFileToList(FileName: string; Date: TDateTime);
    procedure SetDateDataList;
    procedure SetMaxPosition(MaxPos: Integer);
    procedure SetMaxPositionSynch;
    procedure SetPosition(Pos: Integer);
    procedure SetPositionSynch;
    procedure DoOnDone;
    procedure OnLoadingFilesCallBackEvent(Sender: TObject; var Info: TProgressCallBackInfo);
    procedure OnProgressSynch;
  end;

var
  GetPhotosFormSID: TGUID;

implementation

uses UnitGetPhotosForm;

{ TScanImportPhotosThread }

constructor TScanImportPhotosThread.Create(CreateSuspennded: Boolean;
  Options: TScanImportPhotosThreadOptions);
begin
  inherited Create(False);
  FOptions := Options;
  FSID := GetPhotosFormSID;
end;

procedure TScanImportPhotosThread.AddFileToList(FileName: string; Date: TDateTime);
begin
  SetLength(DateFileList, Length(DateFileList) + 1);
  DateFileList[Length(DateFileList) - 1].FileName := FileName;
  DateFileList[Length(DateFileList) - 1].Date := Date;
end;

procedure TScanImportPhotosThread.Execute;
var
  I: Integer;
  MaxFilesCount, MaxFilesSearch: Integer;
  ExifData: TExifData;
  RAWExif: TRAWExif;
  FDate: TDateTime;

  function L_Less_Than_R(L, R: TFileDateRecord): Boolean;
  begin
    Result := L.Date < R.Date;
  end;

  procedure Swap(var X: TFileDateList; I, J: Integer);
  var
    Temp: TFileDateRecord;
  begin
    Temp := X[I];
    X[I] := X[J];
    X[J] := Temp;
  end;

  procedure Qsort(var X:TFileDateList; Left,Right:integer);
  label
     Again;
  var
     Pivot:TFileDateRecord;
     P,Q:integer;
     m : integer;
   begin
      P:=Left;
      Q:=Right;
      m:=(Left+Right) div 2;
      Pivot:=X [m];

      while P<=Q do
      begin
         while L_Less_Than_R(X[P],Pivot) do
         begin
          if p=m then break;
          inc(P);
         end;
         while L_Less_Than_R(Pivot,X[Q]) do
         begin
          if q=m then break;
          dec(Q);
         end;
         if P>Q then goto Again;
         Swap(X,P,Q);
         inc(P);dec(Q);
      end;

      Again:
      if Left<Q  then Qsort(X,Left,Q);
      if P<Right then Qsort(X,P,Right);
   end;

  procedure QuickSort(var X:TFileDateList; N:integer);
  begin
    Qsort(X,0,N-1);
  end;


begin
  FreeOnTerminate := True;

  FOptions.Mask := '|' + FOptions.Mask + '|';
  for I := Length(FOptions.Mask) downto 2 do
    if (FOptions.Mask[I] = '|') and (FOptions.Mask[I - 1] = '|') then
      Delete(FOptions.Mask, I, 1);
  if Length(FOptions.Mask) > 0 then
    Delete(FOptions.Mask, 1, 1);
  FOptions.Mask := TFileAssociations.Instance.ExtensionList + FOptions.Mask;

  FFiles := TStringList.Create;
  MaxFilesCount := 10000;
  MaxFilesSearch := 100000;
  GetFileNamesFromDrive(FOptions.Directory, FOptions.Mask, FFiles, MaxFilesCount, MaxFilesSearch,
    OnLoadingFilesCallBackEvent);

  SetMaxPosition(FFiles.Count);
  for I := 0 to FFiles.Count - 1 do
  begin
    SetPosition(I + 1);
    ExifData := TExifData.Create;
    try
      ExifData.LoadFromGraphic(FFiles[I]);
    except
    end;
    if not ExifData.Empty then
    begin
      AddFileToList(FFiles[I], DateOf(ExifData.DateTimeOriginal));
    end else
    begin
      if RAWImage.IsRAWSupport and IsRAWImageFile(FFiles[I]) then
      begin
        RAWExif := ReadRAWExif(FFiles[I]);
        if RAWExif.IsEXIF then
        begin
          FDate := DateOf(RAWExif.TimeStamp);
          if FDate > 0 then
            AddFileToList(FFiles[I], FDate);

          if IsEqualGUID(FSID, GetPhotosFormSID) then
            Break;
        end;
      end;
    end;
    F(ExifData);
  end;
  if Length(DateFileList) > 1 then
    QuickSort(DateFileList, Length(DateFileList));
  Synchronize(SetDateDataList);
  Synchronize(DoOnDone);
end;

procedure TScanImportPhotosThread.SetDateDataList;
begin
  if IsEqualGUID(FSID, GetPhotosFormSID) then
    (fOptions.Owner as TGetToPersonalFolderForm).SetDataList(DateFileList);
end;

procedure TScanImportPhotosThread.SetMaxPosition(MaxPos: Integer);
begin
  IntParam := MaxPos;
  Synchronize(SetMaxPositionSynch);
end;

procedure TScanImportPhotosThread.SetMaxPositionSynch;
begin
  if IsEqualGUID(FSID, GetPhotosFormSID) then
  begin
    (FOptions.Owner as TGetToPersonalFolderForm).ProgressBar.MaxValue := IntParam;
    (FOptions.Owner as TGetToPersonalFolderForm).ProgressBar.Text := TA('Progress... (&%%)');
  end;
end;

procedure TScanImportPhotosThread.SetPosition(Pos: integer);
begin
  IntParam := Pos;
  Synchronize(SetPositionSynch);
end;

procedure TScanImportPhotosThread.SetPositionSynch;
begin
  if IsEqualGUID(FSID, GetPhotosFormSID) then
    (FOptions.Owner as TGetToPersonalFolderForm).ProgressBar.Position := IntParam;
end;

procedure TScanImportPhotosThread.DoOnDone;
begin
  FOptions.OnEnd(Self);
end;

procedure TScanImportPhotosThread.OnLoadingFilesCallBackEvent(Sender: TObject; var Info: TProgressCallBackInfo);
begin
  if IsEqualGUID(FSID, GetPhotosFormSID) then
  begin
    StrParam := Info.Information;
    BoolParam := Info.Terminate;
    Synchronize(OnProgressSynch);
    Info.Terminate := BoolParam;
  end
  else
    Info.Terminate := True;
end;

procedure TScanImportPhotosThread.OnProgressSynch;
var
  Info: TProgressCallBackInfo;
begin
  if Assigned(FOptions.OnProgress) then
  begin
    Info.MaxValue := -1;
    Info.Position := -1;
    Info.Information := StrParam;
    Info.Terminate := BoolParam;
    FOptions.OnProgress(Self, Info);
    BoolParam := Info.Terminate;
  end;
end;

end.
