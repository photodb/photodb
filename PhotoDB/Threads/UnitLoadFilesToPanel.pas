unit UnitLoadFilesToPanel;

interface

uses
 SysUtils, UnitDBKernel, Classes, Dolphin_DB, jpeg, DB,
 Forms, Graphics, GraphicCrypt, Math, GraphicsCool, RAWImage, UnitDBCommonGraphics,
 UnitPanelLoadingBigImagesThread, UnitDBDeclare, UnitDBCommon, uLogger;

type
  LoadFilesToPanel = class(TThread)
  private
  fFiles : TArStrings;
  fIDs : TArInteger;     
  fRotates : TArInteger;
  FQuery : TDataSet;
  FOwner : TForm;
  fBS : TStream;
  fbit : TBitmap;
  fTermitated : boolean;
  FByID : boolean;
  FInfo : TOneRecordInfo;
  FArLoaded : TArBoolean;
  FUseLoaded : boolean;
  fPictureSize : integer;
  FValidThread : boolean;
    { Private declarations }
  protected
    fSID : TGUID;
    procedure Execute; override;
    function GetInfoByFileNameOrID(FileName : string; id, N : integer) : TPicture;
    Procedure NewItem(Graphic : TGraphic);
    procedure AddToPanel;
    procedure CreateItemsByID(IDs : TArInteger);
    procedure GetPictureSize;
    procedure GetSIDFromForm;
    procedure DoStopLoading;
  public
  constructor Create(CreateSuspennded: Boolean; files : TArStrings; IDs : TArInteger; ArLoaded : TArBoolean; UseLoaded, ByID : boolean; Owner : TForm);
  end;

  var termitating : boolean = false;

implementation

uses UnitFormCont, Searching, ExplorerUnit, CommonDBSupport,
      ExplorerThreadUnit;

{ LoadFilesToPanel }

procedure LoadFilesToPanel.AddToPanel;
begin
 if ManagerPanels.ExistsPanel(FOwner, fSID) then
 (FOwner as TFormCont).AddNewItem(fbit, FInfo) else
 begin
  fTermitated:=true;
  FValidThread:=false;
  exit;
 end;
end;

constructor LoadFilesToPanel.Create(CreateSuspennded: Boolean;
  Files: TArStrings; IDs : TArInteger; ArLoaded : TArBoolean; UseLoaded, ByID : boolean; Owner : TForm);
var
  i : integer;
begin
 inherited Create(true);

 //enable stop button
 (Owner as TFormCont).ToolButton10.Enabled:=true;
 FValidThread:=true;
 
 fTermitated:=false;
 if Owner=nil then exit;
 if not (Owner is TFormCont) then exit;
 fSID:=(Owner as TFormCont).SID;
 (Owner as TFormCont).AddThread;
 fPictureSize:=(Owner as TFormCont).GetPictureSize;
 SetLength(fFiles,Length(Files));
 for i:=0 to Length(fFiles)-1 do
 fFiles[i]:=Files[i];
 SetLength(fids,Length(IDs));
 for i:=0 to Length(fids)-1 do
 fids[i]:=IDs[i];
 if UseLoaded then
 begin
  SetLength(FArLoaded,Length(ArLoaded));
  for i:=0 to Length(FArLoaded)-1 do
  FArLoaded[i]:=ArLoaded[i];
 end else
 begin
  SetLength(FArLoaded,Length(Files));
  for i:=0 to Length(FArLoaded)-1 do
  FArLoaded[i]:=false;
 end;
 FUseLoaded:=UseLoaded;
 fbyid := ByID;
 FOwner:=Owner;
 if not CreateSuspennded then Resume;
end;

procedure LoadFilesToPanel.CreateItemsByID(IDs: TArInteger);
var
  Password, SQLText, s : string;
  n, i, j, L, Left, m : integer;
  r : extended;
  FImage : TJpegImage;
const AllocBy = 50;
begin
 FImage:=nil;
 fQuery.Active:=false;
 L:=Length(IDs);
 n:=Trunc(L/AllocBy);
 r:=L/AllocBy-n;
 if r>0 then inc(n);
 Left:=L;
 for j:=1 to n do
 begin
  SQLText:='SELECT * FROM $DB$ WHERE ';
  m:=Min(Left,Min(L,AllocBy));
  for i:=1 to m do
  begin
   Dec(Left);
   SQLText:=SQLText+' (ID='+inttostr(IDs[i-1+AllocBy*(j-1)])+') ';
   if i<>m then SQLText:=SQLText+'or';
  end;
  SetSQL(fQuery,SQLText);
  try
   fQuery.active:=true;
  except
   FreeDS(fQuery); 
   exit;
  end;
  if fQuery.RecordCount=0 then
  begin
   FInfo:=RecordInfoOne('',0,0,0,0,0,'','','','','',0,false,false,0,false,true,true,'');
   Continue;
  end else
  begin
   fQuery.First;
   for i:=1 to fQuery.RecordCount do
   begin
    if not FValidThread then break;
    s:=fQuery.fieldByName('FFileName').AsString;
    if FolderView then
    begin
     s:=ProgramDir+s;
    end;
    FInfo:=RecordInfoOne(s,fQuery.fieldByName('ID').AsInteger,fQuery.fieldByName('Rotated').AsInteger,fQuery.fieldByName('Rating').AsInteger,fQuery.fieldByName('Access').AsInteger,fQuery.fieldByName('FileSize').AsInteger,fQuery.fieldByName('Comment').AsString,fQuery.fieldByName('KeyWords').AsString,fQuery.fieldByName('Owner').AsString,fQuery.fieldByName('Collection').AsString,fQuery.fieldByName('Groups').AsString,fQuery.fieldByName('DateToAdd').AsDateTime,fQuery.fieldByName('IsDate').AsBoolean,fQuery.fieldByName('IsTime').AsBoolean,fQuery.fieldByName('aTime').AsDateTime, ValidCryptBlobStreamJPG(fQuery.fieldByName('thum')),fQuery.fieldByName('Include').AsBoolean,true,fQuery.FieldByName('Links').AsString);
    FInfo.ItemImTh:=fQuery.fieldByName('StrTh').AsString;
    if TBlobField(fQuery.FieldByName('thum'))=nil then Continue;

    if ValidCryptBlobStreamJPG(fQuery.FieldByName('thum')) then
    begin
     Password:=DBKernel.FindPasswordForCryptBlobStream(fQuery.FieldByName('thum'));
     if Password<>'' then
     FImage:=DeCryptBlobStreamJPG(fQuery.FieldByName('thum'),Password) as TJpegImage;
    end else
    begin
     FImage:=TJpegImage.Create;
     fbs:=GetBlobStream(fQuery.FieldByName('thum'),bmRead);
     try
      if fbs.Size<>0 then
      FImage.LoadFromStream(fbs) else
     except
      FImage.Free;
      FImage:=nil;
     end;
     fbs.Free;
    end;
    if FImage<>nil then
    begin
     NewItem(FImage); 
     FImage.free;
     FImage:=nil;
    end;

    fQuery.Next;
   end;
  end;
 end;

end;

procedure LoadFilesToPanel.DoStopLoading;
begin
 if ManagerPanels.ExistsPanel(FOwner,fSID) then
 (FOwner as TFormCont).DoStopLoading(fSID) else
 begin
  fTermitated:=true;
  FValidThread:=false;
  exit;
 end;
end;

procedure LoadFilesToPanel.Execute;
var
  i ,l : integer;
  pic : TPicture;
  Data : TImageContRecordArray;
begin
 FreeOnTerminate:=true;

 if fbyid then l:=Length(fIDs) else l:=Length(FFiles);

 FQuery := GetQuery;
 SetLength(fRotates,Max(Length(fIDs),Length(FFiles)));
 if not fbyid then
 begin
  for i:=0 to l-1 do
  begin
   Synchronize(GetPictureSize);   
   if not FValidThread then break;
   if not fbyid then
   SetLength(fIDs,1);
   if fbyid then
   SetLength(FFiles,1);
   if FTermitated or Termitating then exit;
   fbit:=TBitmap.create;
   fbit.PixelFormat:=pf24bit;
   fbit.Canvas.Brush.color:=Theme_ListColor;
   fbit.Canvas.pen.color:=Theme_ListColor;
   fbit.Width:=fPictureSize;
   fbit.Height:=fPictureSize;
   if fbyid then
   pic:=GetInfoByFileNameOrID(ffiles[0],Fids[i],i) else
   pic:=GetInfoByFileNameOrID(ffiles[i],Fids[0],i);
   fRotates[i]:=FInfo.ItemRotate;  
   if not FValidThread then break;
   if pic<>nil then
   begin
    NewItem(pic.Graphic);
    pic.Free;
    pic:=nil;
   end;
  end;
 end else
 begin
  CreateItemsByID(Fids);
 end;
 FQuery.Close;
 FreeDS(FQuery);

 Synchronize(GetSIDFromForm);
 ////////////////////////////////////
 if (fPictureSize<>ThSizePanelPreview) and ManagerPanels.ExistsPanel(FOwner,fSID) then
 begin
  SetLength(Data,Length(FFiles));
  for i:=0 to Length(FFiles)-1 do
  Data[i].FileName:=FFiles[i];
  UnitPanelLoadingBigImagesThread.TPanelLoadingBigImagesThread.Create(false,FOwner,(FOwner as TFormCont).BigImagesSID,nil,fPictureSize,Copy(Data));
 end else
 begin
  Synchronize(DoStopLoading);
 end;

end;

function LoadFilesToPanel.GetInfoByFileNameOrID(FileName: string; ID, N  : integer) : TPicture;
var
  Password, s : string;
  CryptFile : boolean;
  c : integer;
begin
 c:=0;
 Result:=nil;
 if not (FUseLoaded and not fbyid and (FArLoaded[N]=true)) then
 begin
  fQuery.Active:=False;
  if fbyid then
   SetSQL(fQuery,'SELECT * FROM $DB$ WHERE ID = '+inttostr(id))
  else
  begin
   SetSQL(fQuery,'SELECT * FROM $DB$ WHERE FolderCRC = '+IntToStr(GetPathCRC(FileName))+' AND FFileName LIKE :FFileName');
   s:=FileName;
   if FolderView then
   Delete(s,1,Length(ProgramDir));
   SetStrParam(fQuery,0,delnakl(normalizeDBStringLike(NormalizeDBString(AnsiLowerCase(s)))));
  end;
  fQuery.active:=true;
  c:=fQuery.RecordCount;
 end;
 if (c=0) then
 begin
  CryptFile:=ValidCryptGraphicFile(FileName);
  FInfo:=RecordInfoOne(FileName,0,0,0,0,0,'','','','','',0,false,false,0,CryptFile,true,true,'');
  Result := TPicture.Create;
  if CryptFile then
  begin
   Password:=DBKernel.FindPasswordForCryptImageFile(FileName);
   if Password='' then
   begin
    Result.Free;
    Result:=nil;
    exit;
   end;
   Result.Graphic:=DeCryptGraphicFile(FileName,Password);
  end else
  begin

   if IsRAWImageFile(FileName) then
   begin
    Result.Graphic:=TRAWImage.Create;
    if not (Result.Graphic as TRAWImage).LoadThumbnailFromFile(FileName,fPictureSize,fPictureSize) then
    Result.Graphic.LoadFromFile(FileName);
   end else
   Result.LoadFromFile(FileName);
  end;
  JPEGScale(Result.Graphic,fPictureSize,fPictureSize);
 end else
 begin
  FInfo:=RecordInfoOne(fQuery.fieldByName('FFileName').AsString,fQuery.fieldByName('ID').AsInteger,fQuery.fieldByName('Rotated').AsInteger,fQuery.fieldByName('Rating').AsInteger,fQuery.fieldByName('Access').AsInteger,fQuery.fieldByName('FileSize').AsInteger,fQuery.fieldByName('Comment').AsString,fQuery.fieldByName('KeyWords').AsString,fQuery.fieldByName('Owner').AsString,fQuery.fieldByName('Collection').AsString,fQuery.fieldByName('Groups').AsString,fQuery.fieldByName('DateToAdd').AsDateTime,fQuery.fieldByName('IsDate').AsBoolean,fQuery.fieldByName('IsTime').AsBoolean,fQuery.fieldByName('aTime').AsDateTime, ValidCryptBlobStreamJPG(fQuery.fieldByName('thum')),fQuery.fieldByName('Include').AsBoolean,true,fQuery.FieldByName('Links').AsString);
  FInfo.ItemImTh:=fQuery.fieldByName('StrTh').AsString;
  if TBlobField(fQuery.FieldByName('thum'))=nil then exit;
  if ValidCryptBlobStreamJPG(fQuery.FieldByName('thum')) then
  begin
   Password:=DBKernel.FindPasswordForCryptBlobStream(fQuery.FieldByName('thum'));
   if Password<>'' then
   Result.Graphic:=DeCryptBlobStreamJPG(fQuery.FieldByName('thum'),Password) as TJpegImage else
   begin
    Result.Free;
    Result:=nil;
   end;
  end else
  begin
   Result:=TPicture.Create;
   Result.Graphic:=TJpegImage.Create;
   fbs:=GetBlobStream(fQuery.FieldByName('thum'),bmRead);
   try
    if fbs.Size<>0 then
    Result.Graphic.LoadFromStream(fbs) else
   except
    Result.Free;
    Result:=nil;
   end;
   fbs.Free;
  end;
 end;
end;

procedure LoadFilesToPanel.GetPictureSize;
begin
 if ManagerPanels.ExistsPanel(FOwner,fSID) then
 fPictureSize:=(fOwner as TFormCont).GetPictureSize  else FValidThread:=false;
end;

procedure LoadFilesToPanel.GetSIDFromForm;
begin
 if ManagerPanels.ExistsPanel(FOwner,fSID) then
 fSID:=(fOwner as TFormCont).SID else FValidThread:=false;
end;

procedure LoadFilesToPanel.NewItem(Graphic : TGraphic);
var
  B : TBitmap;
  w,h : integer;
begin
  if Graphic=nil then exit;
  B:=TBitmap.create;
  if Min(Graphic.Height,Graphic.Width)>1 then
  begin
   try
    LoadImageX(Graphic,B,Theme_ListColor);
   except
    on e : Exception do EventLog(':LoadFilesToPanel::NewItem()/LoadImageX throw exception: '+e.Message);
   end;
  end else
  begin
   B.Assign(Graphic);
  end;
  w:=B.Width;
  h:=B.Height;
  ProportionalSize(fPictureSize,fPictureSize,w,h);
  fbit:=TBitmap.create;
  DoResize(w,h,B,fbit);
  B.Free;
  ApplyRotate(fbit, FInfo.ItemRotate);

 Synchronize(AddToPanel);
end;

end.
