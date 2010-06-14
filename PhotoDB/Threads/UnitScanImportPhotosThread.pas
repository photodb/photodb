unit UnitScanImportPhotosThread;

interface

uses
  Classes, Messages, Forms, Dolphin_DB, EXIF, RawImage, SysUtils,
  Language, UnitDBDeclare;

type
  TScanImportPhotosThreadOptions = record
   Directory : String;
   Mask : String;
   OnEnd : TNotifyEvent;
   Owner : TForm;
   OnProgress : TCallBackProgressEvent;
  end;

  TFileDateRecord = record
   FileName : string;
   Date : TDateTime;
   Options : integer;
   Tag : integer;
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
   fOptions : TScanImportPhotosThreadOptions;
   fFiles : TStrings;
   FSID : string;
   StrParam : String;
   BoolParam : Boolean;
   DateFileList : TFileDateList;
   IntParam : integer;
//   fOnProgress : TCallBackProgressEvent;
    { Private declarations }
  protected
    procedure Execute; override; 
  public   
    constructor Create(CreateSuspennded: Boolean;
      Options : TScanImportPhotosThreadOptions); 
    procedure AddFileToList(FileName : String; Date : TDateTime);
    procedure SetDateDataList;
    procedure SetMaxPosition(MaxPos : integer);
    procedure SetMaxPositionSynch;  
    procedure SetPosition(Pos : integer);
    procedure SetPositionSynch;
    procedure DoOnDone;   
    procedure OnLoadingFilesCallBackEvent(Sender : TObject; var Info : TProgressCallBackInfo);
    procedure OnProgressSynch;
  end;

  var
    GetPhotosFormSID : String;

implementation

uses UnitGetPhotosForm;

{ TScanImportPhotosThread }

constructor TScanImportPhotosThread.Create(CreateSuspennded: Boolean;
  Options: TScanImportPhotosThreadOptions);
begin
 inherited create(true);
 fOptions:=Options;
 FSID:=GetPhotosFormSID;
 if not CreateSuspennded then Resume;
end;

procedure TScanImportPhotosThread.AddFileToList(FileName : String; Date : TDateTime);
begin
 SetLength(DateFileList,Length(DateFileList)+1);
 DateFileList[Length(DateFileList)-1].FileName:=FileName;
 DateFileList[Length(DateFileList)-1].Date:=Date;
end;

procedure TScanImportPhotosThread.Execute;
var
  i : integer;
  MaxFilesCount,MaxFilesSearch : Integer;   
  FEXIF : TEXIF;
  RAWExif : TExifRAWRecord;
  FDate : TDateTime;

  function L_Less_Than_R(L,R:TFileDateRecord):boolean;
  begin
   Result:=L.Date<R.Date;
  end;

  procedure Swap(var X:TFileDateList;I,J:integer);
  var
    temp : TFileDateRecord;
  begin
   temp:=X[i];
   X[i]:=X[J];
   X[J]:=temp;
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
 FreeOnTerminate:=true;

 fOptions.Mask:='|'+fOptions.Mask+'|';
 For i:=Length(fOptions.Mask) downto 2 do
 if (fOptions.Mask[i]='|') and (fOptions.Mask[i-1]='|') then Delete(fOptions.Mask,i,1);
 if Length(fOptions.Mask)>0 then Delete(fOptions.Mask,1,1);
 fOptions.Mask:=SupportedExt+fOptions.Mask;

 fFiles := TStringList.Create;
 MaxFilesCount:=10000;
 MaxFilesSearch:=100000;
 GetPhotosNamesFromDrive(fOptions.Directory, fOptions.Mask, fFiles, MaxFilesCount, MaxFilesSearch, OnLoadingFilesCallBackEvent);

 SetMaxPosition(fFiles.Count);
 for i:=0 to fFiles.Count-1 do
 begin
  SetPosition(i+1);
  FEXIF := TEXIF.Create;
  try
   FEXIF.ReadFromFile(fFiles[i]);
  except
  end;
  if FEXIF.Valid then
  begin
   AddFileToList(fFiles[i],FEXIF.Date);
  end else
  begin
   if RAWImage.IsRAWSupport and RAWImage.IsRAWImageFile(fFiles[i]) then
   begin
    RAWExif:=ReadRAWExif(fFiles[i]);
    if RAWExif.isEXIF then
    begin
     FDate:=Dolphin_DB.EXIFDateToDate(RAWExif.TimeStamp);
     if FDate>0 then AddFileToList(fFiles[i],FDate);
     if FSID=GetPhotosFormSID then break;
    end;
   end;
  end;
  FEXIF.Free;
 end;
 if Length(DateFileList)>1 then
 QuickSort(DateFileList,Length(DateFileList));
 Synchronize(SetDateDataList);
 Synchronize(DoOnDone);
end;

procedure TScanImportPhotosThread.SetDateDataList;
begin
 if FSID=GetPhotosFormSID then
 (fOptions.Owner as TGetToPersonalFolderForm).SetDataList(DateFileList);
end;

procedure TScanImportPhotosThread.SetMaxPosition(MaxPos: integer);
begin
 intParam:=MaxPos;
 Synchronize(SetMaxPositionSynch);
end;

procedure TScanImportPhotosThread.SetMaxPositionSynch;
begin
 if FSID=GetPhotosFormSID then
 begin
  (fOptions.Owner as TGetToPersonalFolderForm).ProgressBar.MaxValue:=intParam;
  (fOptions.Owner as TGetToPersonalFolderForm).ProgressBar.Text:=Language.TEXT_MES_PROGRESS_PR;
 end;
end;

procedure TScanImportPhotosThread.SetPosition(Pos: integer);
begin
 intParam:=Pos;
 Synchronize(SetPositionSynch);
end;

procedure TScanImportPhotosThread.SetPositionSynch;
begin
 if FSID=GetPhotosFormSID then
 begin
  (fOptions.Owner as TGetToPersonalFolderForm).ProgressBar.Position:=intParam;
 end;
end;

procedure TScanImportPhotosThread.DoOnDone;
begin
 FOptions.OnEnd(self);
end;

procedure TScanImportPhotosThread.OnLoadingFilesCallBackEvent(
  Sender: TObject; var Info: TProgressCallBackInfo);
begin
 if FSID=GetPhotosFormSID then
 begin
  StrParam:=Info.Information;
  BoolParam:=Info.Terminate;
  Synchronize(OnProgressSynch);
  Info.Terminate:=BoolParam;
 end else Info.Terminate:=true;
end;

procedure TScanImportPhotosThread.OnProgressSynch;
var
  Info: TProgressCallBackInfo;
begin
 if Assigned(fOptions.OnProgress) then
 begin
  Info.MaxValue:=-1;   
  Info.Position:=-1;
  Info.Information:=StrParam;
  Info.Terminate:=BoolParam;
  fOptions.OnProgress(self,info);
  BoolParam:=Info.Terminate;
 end;
end;

end.
 