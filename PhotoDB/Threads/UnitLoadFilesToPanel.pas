unit UnitLoadFilesToPanel;

interface

uses
 SysUtils, Classes, Dolphin_DB, JPEG, DB, Forms,
 CommonDBSupport, Graphics, GraphicCrypt, Math, GraphicsCool, RAWImage,
 UnitDBCommonGraphics, UnitPanelLoadingBigImagesThread, UnitDBDeclare,
 UnitDBCommon, uLogger, ImageConverting, uMemory;

type
  LoadFilesToPanel = class(TThread)
  private
    FFiles: TArStrings;
    FIDs: TArInteger;
    FRotates: TArInteger;
    FQuery: TDataSet;
    FOwner: TForm;
    FBS: TStream;
    Fbit: TBitmap;
    FTermitated: Boolean;
    FByID: Boolean;
    FInfo: TOneRecordInfo;
    FArLoaded: TArBoolean;
    FUseLoaded: Boolean;
    FPictureSize: Integer;
    FValidThread: Boolean;
    FSID: TGUID;
    { Private declarations }
  protected
    procedure Execute; override;
    procedure GetInfoByFileNameOrID(FileName : string; ID, N : integer; out Graphic : TGraphic);
    Procedure NewItem(Graphic : TGraphic);
    procedure AddToPanel;
    procedure CreateItemsByID(IDs : TArInteger);
    procedure GetPictureSize;
    procedure GetSIDFromForm;
    procedure DoStopLoading;
  public
    constructor Create(Files : TArStrings; IDs : TArInteger; ArLoaded : TArBoolean; UseLoaded, ByID : boolean; Owner : TForm);
  end;

implementation

uses UnitFormCont;

{ LoadFilesToPanel }

procedure LoadFilesToPanel.AddToPanel;
begin
  if ManagerPanels.ExistsPanel(FOwner, FSID) then
    (FOwner as TFormCont).AddNewItem(Fbit, FInfo)
  else
  begin
    FTermitated := True;
    FValidThread := False;
    Exit;
  end;
end;

constructor LoadFilesToPanel.Create(Files: TArStrings; IDs : TArInteger; ArLoaded : TArBoolean; UseLoaded, ByID : boolean; Owner : TForm);
var
  I: Integer;
begin
 inherited Create(True);

 //enable stop button
 (Owner as TFormCont).TbStop.Enabled:=true;
 FValidThread:=true;

 fTermitated:=false;
 if Owner=nil then exit;
 if not (Owner is TFormCont) then exit;
 fSID:=(Owner as TFormCont).SID;
 (Owner as TFormCont).AddThread;
 fPictureSize:=(Owner as TFormCont).PictureSize;
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
 Resume;
end;

procedure LoadFilesToPanel.CreateItemsByID(IDs: TArInteger);
var
  Password, SQLText, s : string;
  n, i, j, L, Left, m : integer;
  r : extended;
  JPEG : TJpegImage;
const AllocBy = 50;
begin
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
   //TODO: review
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

    JPEG := TJpegImage.Create;
    try
      if ValidCryptBlobStreamJPG(fQuery.FieldByName('thum')) then
      begin
        Password:=DBKernel.FindPasswordForCryptBlobStream(fQuery.FieldByName('thum'));
        if Password <> '' then
          DeCryptBlobStreamJPG(fQuery.FieldByName('thum'), Password, JPEG);
      end else
      begin
        FBS:=GetBlobStream(fQuery.FieldByName('thum'), bmRead);
        try
          JPEG.LoadFromStream(fbs);
        finally
          FBS.Free;
        end;
      end;
      if not JPEG.Empty then
        NewItem(JPEG);
    finally
      JPEG.free;
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
  Graphic : TGraphic;
  Data : TImageContRecordArray;
begin
 FreeOnTerminate:=true;

 if fbyid then l:=Length(fIDs) else l:=Length(FFiles);

 FQuery := GetQuery;
 try
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
   if FTermitated then exit;
   fbit:=TBitmap.create;
   fbit.PixelFormat:=pf24bit;
   fbit.Canvas.Brush.color:=Theme_ListColor;
   fbit.Canvas.pen.color:=Theme_ListColor;
   fbit.Width:=fPictureSize;
   fbit.Height:=fPictureSize;
   if fbyid then
     GetInfoByFileNameOrID(ffiles[0],Fids[i],i, Graphic)
   else
     GetInfoByFileNameOrID(ffiles[i],Fids[0],i, Graphic);
   try
     fRotates[i]:=FInfo.ItemRotate;
     if not FValidThread then
       Break;
     if Assigned(Graphic) then
      NewItem(Graphic);

   finally
     F(Graphic);
   end;
  end;
 end else
  CreateItemsByID(Fids);

 finally
   FreeDS(FQuery);
 end;

 Synchronize(GetSIDFromForm);
 ////////////////////////////////////
 if (fPictureSize<>ThSizePanelPreview) and ManagerPanels.ExistsPanel(FOwner,fSID) then
 begin
  SetLength(Data,Length(FFiles));
  for i:=0 to Length(FFiles)-1 do
  Data[i].FileName:=FFiles[i];
  UnitPanelLoadingBigImagesThread.TPanelLoadingBigImagesThread.Create(FOwner,(FOwner as TFormCont).BigImagesSID,nil,fPictureSize,Copy(Data));
 end else
 begin
  Synchronize(DoStopLoading);
 end;

end;

procedure LoadFilesToPanel.GetInfoByFileNameOrID(FileName: string; ID, N  : integer; out Graphic : TGraphic);
var
  Password, S: string;
  CryptFile: Boolean;
  C: Integer;
  JPEG: TJPEGImage;
  GraphicClass : TGraphicClass;
begin
  C := 0;
  if not(FUseLoaded and not Fbyid and (FArLoaded[N] = True)) then
  begin
    FQuery.Active := False;
    if Fbyid then
      SetSQL(FQuery, 'SELECT * FROM $DB$ WHERE ID = ' + Inttostr(Id))
    else
    begin
      SetSQL(FQuery, 'SELECT * FROM $DB$ WHERE FolderCRC = ' + IntToStr(GetPathCRC(FileName))
          + ' AND FFileName LIKE :FFileName');
      S := FileName;
      if FolderView then
        Delete(S, 1, Length(ProgramDir));
      SetStrParam(FQuery, 0, Delnakl(NormalizeDBStringLike(NormalizeDBString(AnsiLowerCase(S)))));
    end;
    FQuery.Active := True;
    C := FQuery.RecordCount;
  end;

  GraphicClass := GetGraphicClass(ExtractFileExt(FileName), False);
  if GraphicClass = nil then
    Exit;

  Graphic := GraphicClass.Create;

  if (C = 0) then
  begin
    CryptFile := ValidCryptGraphicFile(FileName);
    FInfo := RecordInfoOne(FileName, 0, 0, 0, 0, 0, '', '', '', '', '', 0, False, False, 0, CryptFile, True, True, '');
    if CryptFile then
    begin
      Password := DBKernel.FindPasswordForCryptImageFile(FileName);
      if Password = '' then
        Exit;

      F(Graphic);
      Graphic := DeCryptGraphicFile(FileName, Password);
    end else
    begin
      if Graphic is TRAWImage then
      begin
        if not(Graphic as TRAWImage).LoadThumbnailFromFile(FileName, FPictureSize, FPictureSize) then
          Graphic.LoadFromFile(FileName);
      end
      else
        Graphic.LoadFromFile(FileName);
    end;
    JPEGScale(Graphic, FPictureSize, FPictureSize);
  end else
  begin
    FInfo := RecordInfoOne(FQuery.FieldByName('FFileName').AsString, FQuery.FieldByName('ID').AsInteger,
      FQuery.FieldByName('Rotated').AsInteger, FQuery.FieldByName('Rating').AsInteger,
      FQuery.FieldByName('Access').AsInteger, FQuery.FieldByName('FileSize').AsInteger,
      FQuery.FieldByName('Comment').AsString, FQuery.FieldByName('KeyWords').AsString,
      FQuery.FieldByName('Owner').AsString, FQuery.FieldByName('Collection').AsString,
      FQuery.FieldByName('Groups').AsString, FQuery.FieldByName('DateToAdd').AsDateTime,
      FQuery.FieldByName('IsDate').AsBoolean, FQuery.FieldByName('IsTime').AsBoolean,
      FQuery.FieldByName('aTime').AsDateTime, ValidCryptBlobStreamJPG(FQuery.FieldByName('thum')),
      FQuery.FieldByName('Include').AsBoolean, True, FQuery.FieldByName('Links').AsString);
    FInfo.ItemImTh := FQuery.FieldByName('StrTh').AsString;
    if TBlobField(FQuery.FieldByName('thum')) = nil then
      Exit;

    if ValidCryptBlobStreamJPG(FQuery.FieldByName('thum')) then
    begin
      Password := DBKernel.FindPasswordForCryptBlobStream(FQuery.FieldByName('thum'));
      if Password <> '' then
      begin
        JPEG := TJpegImage.Create;
        try
          DeCryptBlobStreamJPG(FQuery.FieldByName('thum'), Password, JPEG);
          F(Graphic);
          Graphic := JPEG;
          JPEG := nil;
        finally
          JPEG.Free;
        end;
      end;
    end else
    begin
      Graphic := TJpegImage.Create;
      Fbs := GetBlobStream(FQuery.FieldByName('thum'), BmRead);
      try
        if Fbs.Size <> 0 then
          Graphic.LoadFromStream(Fbs) finally Fbs.Free;
      end;
    end;
  end;
end;

procedure LoadFilesToPanel.GetPictureSize;
begin
  if ManagerPanels.ExistsPanel(FOwner, FSID) then
    FPictureSize := (FOwner as TFormCont).PictureSize
  else
    FValidThread := False;
end;

procedure LoadFilesToPanel.GetSIDFromForm;
begin
  if ManagerPanels.ExistsPanel(FOwner, FSID) then
    FSID := (FOwner as TFormCont).SID
  else
    FValidThread := False;
end;

procedure LoadFilesToPanel.NewItem(Graphic : TGraphic);
var
  B: TBitmap;
  W, H: Integer;
begin
  B := TBitmap.Create;
  try
    LoadImageX(Graphic, B, Theme_ListColor);
    W := B.Width;
    H := B.Height;
    ProportionalSize(FPictureSize, FPictureSize, W, H);
    FBit := TBitmap.Create;
    try
      DoResize(W, H, B, Fbit);
      F(B);
      ApplyRotate(Fbit, FInfo.ItemRotate);
      Synchronize(AddToPanel);
      FBit := nil;
    finally
      F(FBit);
    end;
  finally
    B.Free;
  end;
end;

end.
