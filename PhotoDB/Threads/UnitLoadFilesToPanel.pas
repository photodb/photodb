unit UnitLoadFilesToPanel;

interface

uses
 SysUtils, Classes, Dolphin_DB, JPEG, DB, Forms, ActiveX,
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
    FInfo: TDBPopupMenuInfoRecord;
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
 inherited Create(False);

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
end;

procedure LoadFilesToPanel.CreateItemsByID(IDs: TArInteger);
var
  Password, SQLText, S: string;
  N, I, J, L, Left, M: Integer;
  R: Extended;
  JPEG: TJpegImage;
const
  AllocBy = 50;
begin
  FQuery.Active := False;
  L := Length(IDs);
  N := Trunc(L / AllocBy);
  R := L / AllocBy - N;
  if R > 0 then
    Inc(N);
  Left := L;
  for J := 1 to N do
  begin
    SQLText := 'SELECT * FROM $DB$ WHERE ';
    M := Min(Left, Min(L, AllocBy));
    for I := 1 to M do
    begin
      Dec(Left);
      SQLText := SQLText + ' (ID=' + Inttostr(IDs[I - 1 + AllocBy * (J - 1)]) + ') ';
      if I <> M then
        SQLText := SQLText + 'or';
    end;
    SetSQL(FQuery, SQLText);
    try
      FQuery.Active := True;
    except
      // TODO: review
      FreeDS(FQuery);
      Exit;
    end;
    if FQuery.RecordCount = 0 then
    begin
      FInfo := nil;
      Continue;
    end
    else
    begin
      FQuery.First;
      for I := 1 to FQuery.RecordCount do
      begin
        if not FValidThread then
          Break;
        S := FQuery.FieldByName('FFileName').AsString;
        if FolderView then
        begin
          S := ProgramDir + S;
        end;
        FInfo := TDBPopupMenuInfoRecord.CreateFromDS(FQuery);
        if TBlobField(FQuery.FieldByName('thum')) = nil then
          Continue;

        JPEG := TJpegImage.Create;
        try
          if ValidCryptBlobStreamJPG(FQuery.FieldByName('thum')) then
          begin
            Password := DBKernel.FindPasswordForCryptBlobStream(FQuery.FieldByName('thum'));
            if Password <> '' then
              DeCryptBlobStreamJPG(FQuery.FieldByName('thum'), Password, JPEG);
          end
          else
          begin
            FBS := GetBlobStream(FQuery.FieldByName('thum'), BmRead);
            try
              JPEG.LoadFromStream(Fbs);
            finally
              FBS.Free;
            end;
          end;
          if not JPEG.Empty then
            NewItem(JPEG);
        finally
          JPEG.Free;
        end;

        FQuery.Next;
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
  I, L: Integer;
  Graphic: TGraphic;
  Data: TDBPopupMenuInfo;
  DataRec: TDBPopupMenuInfoRecord;
begin
  FreeOnTerminate := True;
  CoInitialize(nil);
  try

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
    Fbit.Canvas.Brush.Color := ClWindow;
    Fbit.Canvas.Pen.Color := ClWindow;
   fbit.Width:=fPictureSize;
   fbit.Height:=fPictureSize;
   if fbyid then
     GetInfoByFileNameOrID(ffiles[0],Fids[i],i, Graphic)
   else
     GetInfoByFileNameOrID(ffiles[i],Fids[0],i, Graphic);
   try
     fRotates[i]:=FInfo.Rotation;
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
    Data := TDBPopupMenuInfo.Create;
    try
      for I := 0 to Length(FFiles) - 1 do
      begin
        DataRec := TDBPopupMenuInfoRecord.Create;
        DataRec.FileName := FFiles[i];
        Data.Add(DataRec);
      end;
      UnitPanelLoadingBigImagesThread.TPanelLoadingBigImagesThread.Create(FOwner,(FOwner as TFormCont).BigImagesSID, nil, FPictureSize, Data);

      finally
        F(Data);
      end;
    end else
    begin
      Synchronize(DoStopLoading);
    end;
  finally
    CoUninitialize;
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
    FInfo := TDBPopupMenuInfoRecord.Create;
    FInfo.FileName := FileName;
    FInfo.Crypted := CryptFile;
    FInfo.Include := True;
    FInfo.InfoLoaded := True;
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
    FInfo := TDBPopupMenuInfoRecord.CreateFromDS(FQuery);
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
    LoadImageX(Graphic, B, clWindow);
    W := B.Width;
    H := B.Height;
    ProportionalSize(FPictureSize, FPictureSize, W, H);
    FBit := TBitmap.Create;
    try
      DoResize(W, H, B, Fbit);
      F(B);
      ApplyRotate(Fbit, FInfo.Rotation);
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
