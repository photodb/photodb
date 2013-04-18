unit uMediaInfo;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Math,
  Vcl.Graphics,
  Vcl.Imaging.Jpeg,
  Data.DB,

  Dmitry.CRC32,
  Dmitry.Graphics.Types,

  GraphicCrypt,
  UnitLinksSupport,
  UnitDBCommon,

  uConstants,
  uMemory,
  uRuntime,
  uLogger,
  uDBBaseTypes,
  uSettings,
  uDBConnection,
  uDBAdapter,
  uDBContext,
  uDBEntities,
  uRAWImage,
  uBitmapUtils,
  uJpegUtils,
  uGraphicUtils,
  uDBImageUtils,
  uCDMappingTypes,
  uSessionPasswords;

type
  TMediaInfo = record
    ImTh: string;
    Jpeg: TJpegImage;
    ImageWidth, ImageHeight: Integer;
    IsEncrypted: Boolean;
    Password: string;
    Size: Integer;

    Count: Integer;
    IDs: array of Integer;
    FileNames: array of string;
    ChangedRotate: array of Boolean;
    Attr: array of Integer;

    UsedFileNameSearch: Boolean;
    IsError: Boolean;
    ErrorText: string;
  end;

  TMediaInfoArray = array of TMediaInfo;


function GetImageIDW(Context: IDBContext; FileName: string; OnlyImTh: Boolean): TMediaInfo;
function GetImageIDWEx(DBContext: IDBContext; Images: TMediaItemCollection; OnlyImTh: Boolean = False): TMediaInfoArray;
function GetImageIDTh(DBContext: IDBContext; ImageTh: string): TMediaInfo;

implementation

function BitmapToString(Bit: TBitmap): string;
var
  I, J: Integer;
  Rr1, Bb1, Gg1: Byte;
  B1, B2: Byte;
  B: TBitmap;
  P: PARGB;
begin
  Result := '';
  B := TBitmap.Create;
  try
    B.PixelFormat := pf24bit;
    QuickReduceWide(10, 10, Bit, B);
{$IFOPT R+}
{$DEFINE CKRANGE}
{$R-}
{$ENDIF}
    for I := 0 to 9 do
    begin
      P := B.ScanLine[I];
      for J := 0 to 9 do
      begin
        Rr1 := P[J].R div 8;
        Gg1 := P[J].G div 8;
        Bb1 := P[J].B div 8;
        B1 := Rr1 shl 3;
        B1 := B1 + Gg1 shr 2;
        B2 := Gg1 shl 6;
        B2 := B2 + Bb1 shl 1;
        if (B1 = 0) and (B2 = 0) then
        begin
          B1 := 1;
          B2 := 1;
        end;
        Result := Result + Char(B1 shl 8 or B2);
      end;
    end;
{$IFDEF CKRANGE}
{$UNDEF CKRANGE}
{$R+}
{$ENDIF}
  finally
    F(B);
  end;
end;

function GetImageIDTh(DBContext: IDBContext; ImageTh: string): TMediaInfo;
var
  FQuery: TDataSet;
  I: Integer;
  FromDB: string;
  DA: TImageTableAdapter;
begin
  FQuery := DBContext.CreateQuery;

  DA := TImageTableAdapter.Create(FQuery);
  try
    FromDB := '(Select ID, FFileName, Attr from $DB$ where StrThCrc = ' + IntToStr(Integer(StringCRC(ImageTh))) + ')';

    SetSQL(FQuery, FromDB);
    try
      FQuery.Active := True;
    except
      Setlength(Result.Ids, 0);
      Setlength(Result.FileNames, 0);
      Setlength(Result.Attr, 0);
      Result.Count := 0;
      Result.ImTh := '';
      Exit;
    end;
    Setlength(Result.Ids, FQuery.RecordCount);
    Setlength(Result.FileNames, FQuery.RecordCount);
    Setlength(Result.Attr, FQuery.RecordCount);
    FQuery.First;
    for I := 1 to FQuery.RecordCount do
    begin
      Result.Ids[I - 1] := DA.ID;
      Result.FileNames[I - 1] := DA.FileName;
      Result.Attr[I - 1] := DA.Attributes;
      FQuery.Next;
    end;
    Result.Count := FQuery.RecordCount;
    Result.ImTh := ImageTh;
  finally
    F(DA);
    FreeDS(FQuery);
  end;
end;

function GetImageIDWEx(DBContext: IDBContext; Images: TMediaItemCollection; OnlyImTh: Boolean = False): TMediaInfoArray;
var
  K, I, L, Len: Integer;
  FQuery: TDataSet;
  Temp, Sql, FromDB: string;
  ThImS: TMediaInfoArray;
begin
  L := Images.Count;
  SetLength(ThImS, L);
  SetLength(Result, L);
  for I := 0 to L - 1 do
    ThImS[I] := GetImageIDW(DBContext, Images[I].FileName, True);

  FQuery := DBContext.CreateQuery(dbilRead);

  Sql := '';

  FromDB := '(SELECT ID, FFileName, Attr, StrTh FROM $DB$ WHERE ';
  for I := 1 to L do
  begin
    if I = 1 then
      Sql := Sql + Format(' (IsNull(StrThCrc) or StrThCrc = :strcrc%d) ', [I])
    else
      Sql := Sql + Format(' or (IsNull(StrThCrc) or StrThCrc = :strcrc%d) ', [I]);
  end;
  FromDB := FromDB + Sql + ')';

  Sql := 'SELECT ID, FFileName, Attr, StrTh FROM ' + FromDB + ' WHERE ';

  for I := 1 to L do
  begin
    if I = 1 then
      Sql := Sql + Format(' (StrTh = :str%d) ', [I])
    else
      Sql := Sql + Format(' or (StrTh = :str%d) ', [I]);
  end;
  SetSQL(FQuery, Sql);


  for I := 0 to L - 1 do
  begin
    Result[I] := ThImS[I];
    SetIntParam(FQuery, I, Integer(StringCRC(ThImS[I].ImTh)));
  end;
  for I := L to 2 * L - 1 do
    SetStrParam(FQuery, I, ThImS[I - L].ImTh);

  try
    FQuery.Active := True;
  except
    FreeDS(FQuery);
    for I := 0 to L - 1 do
    begin
      Setlength(Result[I].Ids, 0);
      Setlength(Result[I].FileNames, 0);
      Setlength(Result[I].Attr, 0);
      Result[I].Count := 0;
      Result[I].ImTh := '';
      if Result[I].Jpeg <> nil then
        Result[I].Jpeg.Free;
      Result[I].Jpeg := nil;
    end;
    Exit;
  end;

  for K := 0 to L - 1 do
  begin
    Setlength(Result[K].Ids, 0);
    Setlength(Result[K].FileNames, 0);
    Setlength(Result[K].Attr, 0);
    Len := 0;
    FQuery.First;
    for I := 1 to FQuery.RecordCount do
    begin

      Temp := FQuery.FieldByName('StrTh').AsString;
      if Temp = ThImS[K].ImTh then
      begin
        Inc(Len);
        Setlength(Result[K].Ids, Len);
        Setlength(Result[K].FileNames, Len);
        Setlength(Result[K].Attr, Len);
        Result[K].Ids[Len - 1] := FQuery.FieldByName('ID').AsInteger;
        Result[K].FileNames[Len - 1] := FQuery.FieldByName('FFileName').AsString;
        Result[K].Attr[Len - 1] := FQuery.FieldByName('Attr').AsInteger;
      end;
      FQuery.Next;
    end;
    Result[K].Count := Len;
    Result[K].ImTh := ThImS[K].ImTh;
  end;
  FreeDS(FQuery);
end;

function GetImageIDW(Context: IDBContext; FileName: string; OnlyImTh: Boolean): TMediaInfo;
var
  Bmp, Thbmp: TBitmap;
  PassWord,
  Imth: string;
  IsEncrypted: Boolean;
  G: TGraphic;

  JpegCompressionQuality: TJPEGQualityRange;
  ThumbnailSize: Integer;

  SettingsRepository: ISettingsRepository;
  Settings: TSettings;
begin
  SettingsRepository := Context.Settings;

  Settings := SettingsRepository.Get;
  try
    JpegCompressionQuality := Settings.DBJpegCompressionQuality;
    ThumbnailSize := Settings.ThSize;
  finally
    F(Settings);
  end;

  DoProcessPath(FileName);

  Result.IsEncrypted := False;
  Result.Password := '';
  Result.ImTh := '';
  Result.Count := 0;
  Result.UsedFileNameSearch := False;
  Result.IsError := False;
  Result.Jpeg := nil;
  Result.ImageWidth := 0;
  Result.ImageHeight := 0;

  G := nil;
  try
    try
      LoadGraphic(FileName, G, IsEncrypted, PassWord);
      Result.IsEncrypted := IsEncrypted;
      Result.Password := Password;
      if G = nil then
        Exit;
    except
      on E: Exception do
      begin
        EventLog(E);
        Result.IsError := True;
        Result.ErrorText := E.message;
        Exit;
      end;
    end;

    Result.ImageWidth := G.Width;
    Result.ImageHeight := G.Height;
    try
      JpegScale(G, ThumbnailSize, ThumbnailSize);
      Result.Jpeg := TJpegImage.Create;
      Result.Jpeg.CompressionQuality := JpegCompressionQuality;
      Thbmp := TBitmap.Create;
      try
        Thbmp.PixelFormat := pf24bit;
        Bmp := TBitmap.Create;
        try
          Bmp.PixelFormat := pf24bit;

          if (G is TRAWImage) then
            TRAWImage(G).DisplayDibSize := True;

          if Max(G.Width, G.Height) > ThumbnailSize then
          begin
            if G.Width > G.Height then
              Thbmp.SetSize(ThumbnailSize, Round(ThumbnailSize * (G.Height / G.Width)))
            else
              Thbmp.SetSize(Round(ThumbnailSize * (G.Width / G.Height)), ThumbnailSize);

          end else
            Thbmp.SetSize(G.Width, G.Height);

          LoadImageX(G, Bmp, $FFFFFF);
          F(G);
          DoResize(Thbmp.Width, Thbmp.Height, Bmp, Thbmp);
        finally
          F(Bmp);
        end;
        Result.Jpeg.Assign(Thbmp);
        Result.Jpeg.JPEGNeeded;
        AssignGraphic(Thbmp, Result.Jpeg);
        Imth := BitmapToString(Thbmp);
      finally
        F(Thbmp);
      end;

      if OnlyImTh then
        Result.ImTh := Imth
      else
        Result := GetImageIDTh(Context, Imth);
    except
      on E: Exception do
      begin
        EventLog(E);
        Result.IsError := True;
        Result.ErrorText := E.message;
      end;
    end;
  finally
    F(G);
  end;
end;

procedure UpdateImageThInLinks(Context: IDBContext; OldImageTh, NewImageTh: string);
var
  FQuery: TDataSet;
  IDs: TArInteger;
  Links: TArStrings;
  I, J: Integer;
  Info: TArLinksInfo;
  Link, OldImageThCode: string;
  Table: TDataSet;
begin
  if OldImageTh = NewImageTh then
    Exit;
  if not AppSettings.ReadBool('Options', 'CheckUpdateLinks', False) then
    Exit;

  FQuery := Context.CreateQuery(dbilRead);
  try
    OldImageThCode := CodeExtID(OldImageTh);
    SetSQL(FQuery, 'Select ID, Links from $DB$ where Links like "%' + OldImageThCode + '%"');
    try
      FQuery.Active := True;
    except
      Exit;
    end;
    if FQuery.RecordCount = 0 then
      Exit;

    FQuery.First;
    SetLength(IDs, 0);
    SetLength(Links, 0);
    for I := 1 to FQuery.RecordCount do
    begin
      SetLength(IDs, Length(IDs) + 1);
      IDs[Length(IDs) - 1] := FQuery.FieldByName('ID').AsInteger;
      SetLength(Links, Length(Links) + 1);
      Links[Length(Links) - 1] := FQuery.FieldByName('Links').AsString;
      FQuery.Next;
    end;
  finally
    FreeDS(FQuery);
  end;
  SetLength(Info, Length(Links));
  for I := 0 to Length(IDs) - 1 do
  begin
    Info[I] := ParseLinksInfo(Links[I]);
    for J := 0 to Length(Info[I]) - 1 do
    begin
      if Info[I, J].LinkType = LINK_TYPE_ID_EXT then
        if Info[I, J].LinkValue = OldImageThCode then
        begin
          Info[I, J].LinkValue := CodeExtID(NewImageTh);
        end;
    end;
  end;
  // correction
  // Access
  Table := Context.CreateQuery;
  try
    for I := 0 to Length(IDs) - 1 do
    begin
      Link := CodeLinksInfo(Info[I]);
      SetSQL(Table, 'Update $DB$ set Links=' + NormalizeDBString(Link) + ' where ID = ' + IntToStr(IDs[I]));
      ExecSQL(Table);
    end;
  finally
    FreeDS(Table);
  end;
end;

function GetInfoByFileNameA(Context: IDBContext; FileName: string; LoadThum: Boolean; Info: TMediaItem): Boolean;
var
  FQuery: TDataSet;
  FBS: TStream;
  Folder, QueryString, S: string;
  CRC: Cardinal;
begin
  Result := False;
  Info.FileName := FileName;
  FQuery := Context.CreateQuery(dbilRead);
  try
    FileName := AnsiLowerCase(FileName);
    FileName := ExcludeTrailingBackslash(FileName);

    if FolderView then
    begin
      Folder := ExtractFileDir(FileName);
      Delete(Folder, 1, Length(ProgramDir));
      Folder := ExcludeTrailingBackslash(Folder);
      S := FileName;
      Delete(S, 1, Length(ProgramDir));
    end else
    begin
      Folder := ExtractFileDir(FileName);
      Folder := ExcludeTrailingBackslash(Folder);
      S := FileName;
    end;
    CalcStringCRC32(Folder, CRC);
    QueryString := 'Select * from $DB$ where FolderCRC=' + IntToStr(Integer(CRC)) + ' and Name = :name';
    SetSQL(FQuery, QueryString);
    SetStrParam(FQuery, 0, ExtractFileName(S));
    TryOpenCDS(FQuery);

    if not TryOpenCDS(FQuery) or (FQuery.RecordCount = 0) then
      Exit;

    Result := True;
    Info.ReadFromDS(FQuery);
    Info.Tag := EXPLORER_ITEM_IMAGE;

    if LoadThum then
    begin
      if Info.Image = nil then
        Info.Image := TJpegImage.Create;

      if ValidCryptBlobStreamJPG(FQuery.FieldByName('thum')) then
      begin
        DeCryptBlobStreamJPG(FQuery.FieldByName('thum'),
          SessionPasswords.FindForBlobStream(FQuery.FieldByName('thum')), Info.Image);
        Info.Encrypted := True;
        if (Info.Image <> nil) and (not Info.Image.Empty) then
          Info.Tag := 1;

      end else
      begin
        FBS := GetBlobStream(FQuery.FieldByName('thum'), BmRead);
        try
          Info.Image.LoadFromStream(FBS);
        finally
          F(FBS);
        end;
      end;
    end;
  finally
    FreeDS(FQuery);
  end;
end;

end.
