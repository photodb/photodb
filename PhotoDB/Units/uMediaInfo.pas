unit uMediaInfo;

interface

uses
  Generics.Collections,
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
  uDBGraphicTypes,
  uSettings,
  uColorUtils,
  uDBConnection,
  uDBAdapter,
  uDBContext,
  uDBEntities,
  uRAWImage,
  uBitmapUtils,
  uJpegUtils,
  uImageLoader,
  uGraphicUtils,
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

    Colors: TArray<TColor>;
    Histogram: THistogrammData;
  end;

  TMediaInfoArray = array of TMediaInfo;

  TImageInfoOption = (iioPreview, iioColors, iioHistogram{, iioFaces});
  TImageInfoOptions = set of TImageInfoOption;

function GetImageIDW(Context: IDBContext; FileName: string; OnlyImTh: Boolean; Settings: TSettings = nil): TMediaInfo;
function GetImageIDWEx(DBContext: IDBContext; Images: TMediaItemCollection; OnlyImTh: Boolean = False; Settings: TSettings = nil): TMediaInfoArray;
function GetImageDuplicates(DBContext: IDBContext; ImageTh: string): TMediaInfo;
function GenerateImageInfo(FileName: string; Options: TImageInfoOptions; ThumbnailSize: Integer; JpegCompressionQuality: TJPEGQualityRange): TMediaInfo;

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

function GetImageDuplicates(DBContext: IDBContext; ImageTh: string): TMediaInfo;
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
      OpenDS(FQuery);
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

function GetImageIDWEx(DBContext: IDBContext; Images: TMediaItemCollection; OnlyImTh: Boolean = False; Settings: TSettings = nil): TMediaInfoArray;
var
  K, I, L, Len: Integer;
  FQuery: TDataSet;
  Temp, Sql, FromDB: string;
  ThImS: TMediaInfoArray;
  Info: TMediaInfo;
begin
  L := Images.Count;
  SetLength(ThImS, 0);
  SetLength(Result, 0);

  for I := 0 to L - 1 do
  begin

    try
      Info := GetImageIDW(DBContext, Images[I].FileName, True, Settings);
    except
      on e: Exception do
      begin
        EventLog(e);
        Continue;
      end;
    end;

    SetLength(ThImS, I + 1);
    ThImS[I] := Info;
  end;

  FQuery := DBContext.CreateQuery(dbilRead);
  try
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

    SetLength(Result, L);
    for I := 0 to L - 1 do
    begin
      Result[I] := ThImS[I];
      SetIntParam(FQuery, I, Integer(StringCRC(ThImS[I].ImTh)));
    end;
    for I := L to 2 * L - 1 do
      SetStrParam(FQuery, I, ThImS[I - L].ImTh);

    try
      OpenDS(FQuery);
    except
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
  finally
    FreeDS(FQuery);
  end;
end;

procedure ClearMediaInfo(var Info: TMediaInfo);
begin
  Info.ImTh := '';
  Info.Jpeg := nil;
  Info.ImageWidth := 0;
  Info.ImageHeight := 0;
  Info.IsEncrypted := False;
  Info.Password := '';
  Info.Size := 0;
  Info.Count := 0;
  SetLength(Info.IDs, 0);
  SetLength(Info.FileNames, 0);
  SetLength(Info.ChangedRotate, 0);
  SetLength(Info.Attr, 0);
  SetLength(Info.Colors, 0);
  Info.Histogram.Loaded := False;
  Info.Histogram.Loading := False;
end;

function GenerateImageInfo(FileName: string; Options: TImageInfoOptions; ThumbnailSize: Integer; JpegCompressionQuality: TJPEGQualityRange): TMediaInfo;
const
  MaxPreviewSize = 500;
var
  Bmp: TBitmap;
  MediaItem: TMediaItem;
  ImageInfo: ILoadImageInfo;
  Colors: TList<TColor>;
  LoadFlags: TImageLoadFlags;
begin
  ClearMediaInfo(Result);

  Colors := TList<TColor>.Create;
  MediaItem := TMediaItem.CreateFromFile(FileName);
  try
    LoadFlags := [ilfGraphic, ilfThrowError, ilfDontUpdateInfo];
    if iioColors in Options then
      LoadFlags := LoadFlags + [ilfICCProfile];

    if LoadImageFromPath(MediaItem, 1, '', [ilfGraphic, ilfDontUpdateInfo], ImageInfo) then
    begin
      Result.ImageWidth := ImageInfo.GraphicWidth;
      Result.ImageHeight := ImageInfo.GraphicHeight;
      Result.IsEncrypted := ImageInfo.IsImageEncrypted;
      Result.Password := ImageInfo.Password;
      Result.Size := ThumbnailSize;

      Bmp := ImageInfo.GenerateBitmap(MediaItem, MaxPreviewSize, MaxPreviewSize, pf24bit, clWhite, []);
      try
        if Bmp <> nil then
        begin
          Result.ImTh := BitmapToString(Bmp);

          KeepProportions(Bmp, ThumbnailSize, ThumbnailSize);

          if iioColors in Options then
          begin
            ImageInfo.AppllyICCProfile(Bmp);
            FindPaletteColorsOnImage(Bmp, Colors, 3);
            Result.Colors := Colors.ToArray();
          end;

          if iioHistogram in Options then
          begin
            Result.Histogram := FillHistogramma(Bmp);
          end;

          if iioPreview in Options then
          begin
            Result.Jpeg := TJpegImage.Create;
            Result.Jpeg.CompressionQuality := JpegCompressionQuality;
            Result.Jpeg.Assign(Bmp);
            Result.Jpeg.JPEGNeeded;
          end;

        end;
      finally
        F(Bmp);
      end;
    end;
  finally
    F(Colors);
    F(MediaItem);
  end;
end;

function GetImageIDW(Context: IDBContext; FileName: string; OnlyImTh: Boolean; Settings: TSettings = nil): TMediaInfo;
var
  JpegCompressionQuality: TJPEGQualityRange;
  ThumbnailSize: Integer;

  SettingsRepository: ISettingsRepository;
  DuplicatesInfo: TMediaInfo;
begin
  ClearMediaInfo(Result);

  if Settings <> nil then
  begin
    JpegCompressionQuality := Settings.DBJpegCompressionQuality;
    ThumbnailSize := Settings.ThSize;
  end else
  begin
    SettingsRepository := Context.Settings;
    Settings := SettingsRepository.Get;
    try
      JpegCompressionQuality := Settings.DBJpegCompressionQuality;
      ThumbnailSize := Settings.ThSize;
    finally
      F(Settings);
    end;
  end;

  DoProcessPath(FileName);

  Result := GenerateImageInfo(FileName, [iioPreview, iioColors, iioHistogram], ThumbnailSize, JpegCompressionQuality);

  if not OnlyImTh and (Result.Imth <> '') then
  begin
    DuplicatesInfo := GetImageDuplicates(Context, Result.Imth);
    Result.IDs := DuplicatesInfo.IDs;
    Result.FileNames := DuplicatesInfo.FileNames;
    Result.ChangedRotate := DuplicatesInfo.ChangedRotate;
    Result.Attr := DuplicatesInfo.Attr;
    Result.Count := DuplicatesInfo.Count;
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
      OpenDS(FQuery);
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

end.
