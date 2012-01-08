unit UnitLoadFilesToPanel;

interface

uses
  SysUtils, Classes, Dolphin_DB, JPEG, DB, Forms, ActiveX,
  CommonDBSupport, Graphics, GraphicCrypt, Math, GraphicsCool, RAWImage,
  uJpegUtils, uBitmapUtils, UnitPanelLoadingBigImagesThread, UnitDBDeclare,
  UnitDBCommon, uLogger, uMemory, UnitDBKernel, uAssociations, uDBForm,
  uDBPopupMenuInfo, uGraphicUtils, uDBBaseTypes, uRuntime, uDBThread,
  uExifUtils, uConstants;

type
  LoadFilesToPanel = class(TDBThread)
  private
    { Private declarations }
    FFiles: TArStrings;
    FIDs: TArInteger;
    FRotates: TArInteger;
    FQuery: TDataSet;
    FOwner: TDBForm;
    FBS: TStream;
    Fbit: TBitmap;
    FByID: Boolean;
    FInfo: TDBPopupMenuInfoRecord;
    FArLoaded: TArBoolean;
    FUseLoaded: Boolean;
    FPictureSize: Integer;
    FSID: TGUID;
  protected
    procedure Execute; override;
    procedure GetInfoByFileNameOrID(FileName : string; ID, N : integer; out Graphic : TGraphic);
    Procedure NewItem(Graphic : TGraphic);
    procedure AddToPanel;
    procedure CreateItemsByID(IDs : TArInteger);
    procedure GetPictureSize;
    procedure GetSIDFromForm;
    procedure RemoveWorkerThread;
  public
    constructor Create(Files : TArStrings; IDs : TArInteger; ArLoaded : TArBoolean; UseLoaded, ByID : boolean; Owner : TDBForm);
    destructor Destroy; override;
  end;

implementation

uses
  UnitFormCont;

{ LoadFilesToPanel }

procedure LoadFilesToPanel.AddToPanel;
begin
  if ManagerPanels.ExistsPanel(FOwner, FSID) then
    if (FOwner as TFormCont).AddNewItem(Fbit, FInfo)then
      FBit := nil;
end;

constructor LoadFilesToPanel.Create(Files: TArStrings; IDs : TArInteger; ArLoaded : TArBoolean; UseLoaded, ByID : boolean; Owner : TDBForm);
var
  I: Integer;
begin
  inherited Create(Owner, False);
  FInfo := nil;

  FSID := (Owner as TFormCont).SID;
  (Owner as TFormCont).AddWorkerThread;
  FPictureSize := (Owner as TFormCont).PictureSize;
  SetLength(FFiles, Length(Files));
  for I := 0 to Length(FFiles) - 1 do
    FFiles[I] := Files[I];
  SetLength(Fids, Length(IDs));
  for I := 0 to Length(Fids) - 1 do
    Fids[I] := IDs[I];
  if UseLoaded then
  begin
    SetLength(FArLoaded, Length(ArLoaded));
    for I := 0 to Length(FArLoaded) - 1 do
      FArLoaded[I] := ArLoaded[I];
  end else
  begin
    SetLength(FArLoaded, Length(Files));
    for I := 0 to Length(FArLoaded) - 1 do
      FArLoaded[I] := False;
  end;
  FUseLoaded := UseLoaded;
  Fbyid := ByID;
  FOwner := Owner;
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
      Exit;
    end;
    if FQuery.RecordCount = 0 then
    begin
      F(FInfo);
      Continue;
    end else
    begin
      FQuery.First;
      for I := 1 to FQuery.RecordCount do
      begin
        if Terminated then
          Break;
        S := FQuery.FieldByName('FFileName').AsString;
        if FolderView then
        begin
          S := ProgramDir + S;
        end;
        F(FInfo);
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
          end else
          begin
            FBS := GetBlobStream(FQuery.FieldByName('thum'), BmRead);
            try
              JPEG.LoadFromStream(Fbs);
            finally
              F(FBS);
            end;
          end;
          if not JPEG.Empty then
            NewItem(JPEG);
        finally
          F(JPEG);
        end;

        FQuery.Next;
      end;
    end;
  end;
end;

destructor LoadFilesToPanel.Destroy;
begin
  F(FInfo);
  F(FBit);
  inherited;
end;

procedure LoadFilesToPanel.Execute;
var
  I, L: Integer;
  Graphic: TGraphic;
  Data: TDBPopupMenuInfo;
  DataRec: TDBPopupMenuInfoRecord;
begin
  inherited;
  FreeOnTerminate := True;
  Graphic := nil;
  CoInitializeEx(nil, COM_MODE);
  try

    if Fbyid then
      L := Length(FIDs)
    else
      L := Length(FFiles);

    FQuery := GetQuery;
    try
      SetLength(FRotates, Max(Length(FIDs), Length(FFiles)));
      if not Fbyid then
      begin
        for I := 0 to L - 1 do
        begin
          SynchronizeEx(GetPictureSize);
          if Terminated then
            Break;
          if not Fbyid then
            SetLength(FIDs, 1);
          if Fbyid then
            SetLength(FFiles, 1);

          Graphic := nil;

          if Fbyid then
            GetInfoByFileNameOrID(Ffiles[0], Fids[I], I, Graphic)
          else
            GetInfoByFileNameOrID(Ffiles[I], Fids[0], I, Graphic);
          try
            FRotates[I] := FInfo.Rotation;

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

    SynchronizeEx(GetSIDFromForm);
    /// /////////////////////////////////
    if (FPictureSize <> ThSizePanelPreview) and ManagerPanels.ExistsPanel(FOwner, FSID) then
    begin
      Data := TDBPopupMenuInfo.Create;
      try
        for I := 0 to Length(FFiles) - 1 do
        begin
          DataRec := TDBPopupMenuInfoRecord.Create;
          DataRec.FileName := FFiles[I];
          Data.Add(DataRec);
        end;
        UnitPanelLoadingBigImagesThread.TPanelLoadingBigImagesThread.Create(FOwner, (FOwner as TFormCont).BigImagesSID,
          nil, FPictureSize, Data);

      finally
        F(Data);
      end;
    end;
  finally
    SynchronizeEx(RemoveWorkerThread);
    CoUninitialize;
  end;
end;

procedure LoadFilesToPanel.GetInfoByFileNameOrID(FileName: string; ID, N  : integer; out Graphic: TGraphic);
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
      SetSQL(FQuery, 'SELECT * FROM $DB$ WHERE FolderCRC = ' + IntToStr(GetPathCRC(FileName, True))
          + ' AND FFileName LIKE :FFileName');
      S := FileName;
      if FolderView then
        Delete(S, 1, Length(ProgramDir));
      SetStrParam(FQuery, 0, NormalizeDBStringLike(AnsiLowerCase(S)));
    end;
    FQuery.Active := True;
    C := FQuery.RecordCount;
  end;

  GraphicClass := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(FileName));
  if GraphicClass = nil then
    Exit;

  F(Graphic);
  Graphic := GraphicClass.Create;

  if (C = 0) then
  begin
    CryptFile := ValidCryptGraphicFile(FileName);
    F(FInfo);
    FInfo := TDBPopupMenuInfoRecord.CreateFromFile(FileName);
    FInfo.Crypted := CryptFile;
    FInfo.Include := True;
    FInfo.InfoLoaded := True;
    UpdateImageRecordFromExif(FInfo, False);
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
        TRAWImage(Graphic).HalfSizeLoad := True;
        if not (Graphic as TRAWImage).LoadThumbnailFromFile(FileName, FPictureSize, FPictureSize) then
          Graphic.LoadFromFile(FileName)
        else
          FInfo.Rotation := ExifDisplayButNotRotate(FInfo.Rotation);
      end else
        Graphic.LoadFromFile(FileName);
    end;
    FInfo.Width := Graphic.Width;
    FInfo.Height := Graphic.Height;

    JPEGScale(Graphic, FPictureSize, FPictureSize);
  end else
  begin
    F(FInfo);
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
          F(JPEG);
        end;
      end;
    end else
    begin
      F(Graphic);
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
    FPictureSize := (FOwner as TFormCont).PictureSize;
end;

procedure LoadFilesToPanel.GetSIDFromForm;
begin
  if ManagerPanels.ExistsPanel(FOwner, FSID) then
    FSID := (FOwner as TFormCont).SID;
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
      FBit.PixelFormat := B.PixelFormat;
      DoResize(W, H, B, Fbit);
      F(B);
      ApplyRotate(Fbit, FInfo.Rotation);
      SynchronizeEx(AddToPanel);

    finally
      F(FBit);
    end;
  finally
    F(B);
  end;
end;

procedure LoadFilesToPanel.RemoveWorkerThread;
begin
  (FOwner as TFormCont).RemoveWorkerThread;
end;

end.
