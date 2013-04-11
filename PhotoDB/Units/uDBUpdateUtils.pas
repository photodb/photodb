unit uDBUpdateUtils;

interface

uses
  Generics.Collections,
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  System.DateUtils,
  Vcl.Forms,
  Vcl.Imaging.jpeg,

  CCR.Exif,

  Dmitry.CRC32,
  Dmitry.Utils.System,
  Dmitry.Utils.Files,

  CommonDBSupport,
  GraphicCrypt,
  UnitDBDeclare,
  CmpUnit,
  UnitLinksSupport,
  UnitGroupsReplace,

  uConstants,
  uRuntime,
  uMemory,
  uDBTypes,
  uDBUtils,
  uStringUtils,
  uShellIntegration,
  uLogger,
  uDBForm,
  uTranslate,
  uSettings,
  uExifUtils,
  uDBClasses,
  uDBContext,
  uDBEntities,
  uCollectionEvents;

type
  TDatabaseUpdateManager = class
  class var
    FGroupReplaceActions: TGroupsActionsW;
  protected
    class procedure CleanUp;
    class procedure NotifyFileAdded(Info: TMediaItem; Res: TMediaInfo);
    class function AddNewImageRecord(Context: IDBContext; Info: TMediaItem; Res: TMediaInfo): Boolean;
    class procedure ProcessGroups(Context: IDBContext; Info: TMediaItem; ExifGroups: string);
  public
    class function AddFile(Context: IDBContext; Info: TMediaItem; Res: TMediaInfo): Boolean;
    class function AddFileAsDuplicate(Context: IDBContext; Info: TMediaItem; Res: TMediaInfo): Boolean;
    class function MergeWithExistedInfo(Context: IDBContext; ID: Integer; Info: TMediaItem; Res: TMediaInfo): Boolean;
  end;

implementation

class function TDatabaseUpdateManager.AddFile(Context: IDBContext; Info: TMediaItem; Res: TMediaInfo): Boolean;
var
  Groups, ExifGroups: string;
begin
  Result := False;
  try
    Info.FileName := AnsiLowerCase(Info.FileName);

    //save original groups and extract Exif groups
    Groups := Info.Groups;
    ExifGroups := '';
    Info.Groups := '';
    UpdateImageRecordFromExif(Info, True, True);

    ExifGroups := Info.Groups;
    Info.Groups := Groups;

    ProcessGroups(Context, Info, ExifGroups);

    if AddNewImageRecord(Context, Info, Res) then
    begin
      Result := True;
      Res.Jpeg.DIBNeeded;
      NotifyFileAdded(Info, Res);
    end else
      F(Res.Jpeg);

  except
    on e: Exception do
      EventLog(e);
  end;
end;

class function TDatabaseUpdateManager.AddNewImageRecord(Context: IDBContext; Info: TMediaItem; Res: TMediaInfo): Boolean;
var
  IC: TInsertCommand;
  M: TMemoryStream;
  ExifData: TExifData;
  FileDate: TDateTime;

  procedure HandleError(Error: string);
  begin
    MessageBoxDB(0, Error, TA('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
    EventLog(Error);
  end;

begin
  Result := False;
  M := nil;

  if AppSettings.ReadBool('Options', 'DontAddSmallImages', True) then
  begin
    if (AppSettings.ReadInteger('Options', 'DontAddSmallImagesWidth', 64) > Res.ImageWidth) or
       (AppSettings.ReadInteger('Options', 'DontAddSmallImagesHeight', 64) > Res.ImageHeight) then
      // small images are no photos
      Exit;
  end;

  //if date isn't defined yet
  if not ((YearOf(Date) > cMinEXIFYear) and Info.IsTime and Info.IsDate) then
  begin
    ExifData := TExifData.Create;
    try
      Info.Date := 0;
      Info.Time := 0;
      Info.IsDate := False;
      Info.IsTime := False;
      try
        ExifData.LoadFromGraphic(Info.FileName);
        if not ExifData.Empty and (ExifData.DateTimeOriginal > 0) then
        begin;
          Info.Date := DateOf(ExifData.DateTimeOriginal);
          Info.Time := TimeOf(ExifData.DateTimeOriginal);
          Info.IsDate := True;
          Info.IsTime := True;

          //if rotation no==isn't set
          if (Info.Rotation and DB_IMAGE_ROTATE_MASK = DB_IMAGE_ROTATE_0) and (Info.Rotation <> DB_IMAGE_ROTATE_FIXED) then
            Info.Rotation := ExifOrientationToRatation(Ord(ExifData.Orientation));
        end else
        begin
          FileDate := GetFileDateTime(Info.FileName);
          if not FileAge(Info.FileName, FileDate) then
            FileDate := Now;

          if YearOf(Date) < cMinEXIFYear then
            FileDate := Now;

          Info.Date := DateOf(FileDate);
          Info.Time := TimeOf(FileDate);
          Info.IsDate := True;
          Info.IsTime := True;
        end;
      except
        on e: Exception do
          Eventlog('Reading EXIF failed: ' + e.Message);
      end;
    finally
      F(ExifData);
    end;
  end;
  Info.Rotation := Info.Rotation and DB_IMAGE_ROTATE_MASK;

  IC := Context.CreateInsert(ImageTable);
  try
    IC.AddParameter(TStringParameter.Create('Name', ExtractFileName(Info.FileName)));
    IC.AddParameter(TStringParameter.Create('FFileName', AnsiLowerCase(Info.FileName)));
    IC.AddParameter(TIntegerParameter.Create('FileSize', GetFileSize(Info.FileName)));
    if YearOf(Date) < cMinEXIFYear then
    begin
      IC.AddParameter(TDateTimeParameter.Create('DateToAdd', Now));
      IC.AddParameter(TBooleanParameter.Create('IsDate', True));
      IC.AddParameter(TDateTimeParameter.Create('aTime', TimeOf(Now)));
      IC.AddParameter(TBooleanParameter.Create('IsTime', True));
    end else
    begin
      IC.AddParameter(TDateTimeParameter.Create('DateToAdd', Info.Date));
      IC.AddParameter(TBooleanParameter.Create('IsDate', True));
      IC.AddParameter(TDateTimeParameter.Create('aTime', TimeOf(Info.Time)));
      IC.AddParameter(TBooleanParameter.Create('IsTime', True));
    end;

    IC.AddParameter(TStringParameter.Create('StrTh', Res.ImTh));
    IC.AddParameter(TStringParameter.Create('KeyWords', Info.KeyWords));
    IC.AddParameter(TIntegerParameter.Create('Access', Info.Access));
    IC.AddParameter(TIntegerParameter.Create('Width', Res.ImageWidth));
    IC.AddParameter(TIntegerParameter.Create('Height', Res.ImageHeight));
    IC.AddParameter(TStringParameter.Create('Comment', Info.Comment));
    IC.AddParameter(TIntegerParameter.Create('Attr', Db_attr_norm));
    IC.AddParameter(TIntegerParameter.Create('Rotated', Info.Rotation));
    IC.AddParameter(TIntegerParameter.Create('Rating', Info.Rating));
    IC.AddParameter(TBooleanParameter.Create('Include', Info.Include));
    IC.AddParameter(TStringParameter.Create('Links', Info.Links));
    IC.AddParameter(TStringParameter.Create('Groups', Info.Groups));

    IC.AddParameter(TIntegerParameter.Create('FolderCRC', GetPathCRC(Info.FileName, True)));
    IC.AddParameter(TIntegerParameter.Create('StrThCRC', Integer(StringCRC(Res.ImTh))));

    if Res.IsEncrypted then
    begin
      M := TMemoryStream.Create;
      EncryptGraphicImage(Res.Jpeg, Res.Password, M);
      IC.AddParameter(TStreamParameter.Create('Thum', M));
    end else
      IC.AddParameter(TPersistentParameter.Create('Thum', Res.Jpeg));

    Info.ID := IC.Execute;
  finally
    F(IC);
    F(M);
  end;
  Result := True;
end;

class procedure TDatabaseUpdateManager.ProcessGroups(Context: IDBContext; Info: TMediaItem; ExifGroups: string);
var
  RegisteredGroups: TGroups;
  GroupsRepository: IGroupsRepository;
begin
  if ExifGroups <> '' then
  begin
    GroupsRepository := Context.Groups;
    RegisteredGroups := GroupsRepository.GetAll(False, True);
    try

      TThread.Synchronize(nil,
        procedure
        var
          Groups, GExifGroups: TGroups;
          InRegGroups: TGroups;
        begin
          Groups := TGroups.CreateFromString(Info.Groups);
          GExifGroups := TGroups.CreateFromString(ExifGroups);
          //in groups are empty because in exif no additional groups information
          InRegGroups := TGroups.Create;
          try
            FilterGroups(Context, GExifGroups, RegisteredGroups, InRegGroups, FGroupReplaceActions);

            Groups.AddGroups(GExifGroups);
            Info.Groups := Groups.ToString;
          finally
            F(InRegGroups);
          end;
        end
      );

    finally
      F(RegisteredGroups);
    end;

  end;
end;

class procedure TDatabaseUpdateManager.CleanUp;
begin
  F(FGroupReplaceActions.ActionForUnKnown.OutGroup);
  F(FGroupReplaceActions.ActionForUnKnown.InGroup);
  F(FGroupReplaceActions.ActionForKnown.OutGroup);
  F(FGroupReplaceActions.ActionForKnown.InGroup);
end;

class function TDatabaseUpdateManager.MergeWithExistedInfo(Context: IDBContext; ID: Integer;
  Info: TMediaItem; Res: TMediaInfo): Boolean;
var
  MediaItem: TMediaItem;
  UC: TUpdateCommand;
  Comment, Groups, KeyWords, Links: string;

  MediaRepository: IMediaRepository;
begin
  Result := False;

  MediaRepository := Context.Media;

  MediaItem := MediaRepository.GetMenuItemByID(ID);
  if MediaItem = nil then
    Exit;

  UC := Context.CreateUpdate(ImageTable);
  try
    if Info.Comment <> '' then
    begin
      Comment := Info.Comment;
      if MediaItem.Comment <> '' then
        Comment := Comment + sLineBreak + MediaItem.Comment;

      UC.AddParameter(TStringParameter.Create('Comment', Comment));
    end;

    if (Info.Rotation <> DB_IMAGE_ROTATE_0) and (Info.Rotation <> DB_IMAGE_ROTATE_UNKNOWN) then
      UC.AddParameter(TIntegerParameter.Create('Rotated', Info.Rotation));

    if Info.Rating <> 0 then
      UC.AddParameter(TIntegerParameter.Create('Rating', Info.Rating));

    if Info.Groups <> '' then
    begin
      Groups := Info.Groups;
      TGroups.AddGroupsToGroups(Groups, MediaItem.Groups);
      UC.AddParameter(TStringParameter.Create('Groups', Groups));
    end;

    if Info.KeyWords <> '' then
    begin
      KeyWords := Info.KeyWords;
      AddWordsA(MediaItem.KeyWords, KeyWords);
      UC.AddParameter(TStringParameter.Create('KeyWords', KeyWords));
    end;

    if Info.Links <> '' then
    begin
      Links := Info.Links;
      ReplaceLinks('', MediaItem.Links, Links);
      UC.AddParameter(TStringParameter.Create('Links', Links));
    end;

    if not Info.Include then
      UC.AddParameter(TBooleanParameter.Create('Include', Info.Include));

    UC.AddParameter(TStringParameter.Create('Name', ExtractFileName(Info.FileName)));
    UC.AddParameter(TStringParameter.Create('FFileName', AnsiLowerCase(Info.FileName)));
    UC.AddParameter(TIntegerParameter.Create('FolderCRC', GetPathCRC(Info.FileName, True)));

    UC.AddWhereParameter(TIntegerParameter.Create('ID', ID));

    UC.Execute;
  finally
    F(UC);
  end;
end;

class function TDatabaseUpdateManager.AddFileAsDuplicate(Context: IDBContext; Info: TMediaItem; Res: TMediaInfo): Boolean;
var
  I: Integer;
  Infos: TMediaItemCollection;
  ItemsToDelete: TStringList;
  ItemsDuplicates: TStringList;
  DC: TDeleteCommand;
  UC: TUpdateCommand;

  MediaRepository: IMediaRepository;

  procedure AddInfo(Info: TMediaItem; InfoToAdd: TMediaItem);
  var
    Groups, KeyWords, Links: string;
  begin
   if InfoToAdd.Comment <> '' then
    begin
      if Info.Comment <> '' then
        Info.Comment := Info.Comment + sLineBreak + InfoToAdd.Comment
      else
        Info.Comment := InfoToAdd.Comment;
    end;

    if (Info.Rating = 0) and (InfoToAdd.Rating <> 0) then
      Info.Rating := InfoToAdd.Rating;

    if ((Info.Rotation = DB_IMAGE_ROTATE_0) or (Info.Rotation = DB_IMAGE_ROTATE_UNKNOWN)) and (InfoToAdd.Rotation <> DB_IMAGE_ROTATE_0) and (InfoToAdd.Rotation <> DB_IMAGE_ROTATE_UNKNOWN) then
      Info.Rotation := InfoToAdd.Rotation;

    if InfoToAdd.Groups <> '' then
    begin
      Groups := Info.Groups;
      TGroups.AddGroupsToGroups(Groups, InfoToAdd.Groups);
      Info.Groups := Groups;
    end;

    if InfoToAdd.KeyWords <> '' then
    begin
      KeyWords := Info.KeyWords;
      AddWordsA(InfoToAdd.KeyWords, KeyWords);
      Info.KeyWords := KeyWords;
    end;

    if Info.Links <> '' then
    begin
      Links := Info.Links;
      ReplaceLinks('', InfoToAdd.Links, Links);
      Info.Links := Links;
    end;
  end;

begin
  Result := False;

  MediaRepository := Context.Media;

  Infos := TMediaItemCollection.Create;
  ItemsToDelete := TStringList.Create;
  ItemsDuplicates := TStringList.Create;
  try
    for I := 0 to Res.Count - 1 do
      Infos.Add(MediaRepository.GetMenuItemByID(Res.IDs[0]));

    for I := 0 to Infos.Count - 1 do
    begin
      if not FileExistsSafe(Infos[I].FileName) then
      begin
        AddInfo(Info, Infos[I]);
        ItemsToDelete.Add(IntToStr(Infos[I].ID));
      end else
        ItemsDuplicates.Add(IntToStr(Infos[I].ID));
    end;

    Info.Attr := Db_attr_duplicate;
    if not AddFile(Context, Info, Res) then
      Exit;

    //delete old not existed files
    if ItemsToDelete.Count > 0 then
    begin
      DC := Context.CreateDelete(ImageTable);
      try
        DC.AddWhereParameter(TCustomConditionParameter.Create(FormatEx('[ID] in ({0})', [ItemsToDelete.Join(',')])));
        DC.Execute;
      finally
        F(DC);
      end;
    end;

    //all these files - duplicates
    if ItemsDuplicates.Count > 0 then
    begin
      UC := Context.CreateUpdate(ImageTable);
      try
        UC.AddParameter(TIntegerParameter.Create('Attr', Db_attr_duplicate));
        UC.AddWhereParameter(TCustomConditionParameter.Create(FormatEx('[ID] in ({0})', [ItemsDuplicates.Join(',')])));
        UC.Execute;
      finally
        F(UC);
      end;
    end;
  finally
    F(ItemsDuplicates);
    F(ItemsToDelete);
    F(Infos);
  end;
end;

class procedure TDatabaseUpdateManager.NotifyFileAdded(Info: TMediaItem; Res: TMediaInfo);
var
  EventInfo: TEventValues;
begin
  TThread.Synchronize(nil,
    procedure
    begin
      Info.SaveToEvent(EventInfo);

      EventInfo.JPEGImage := Res.Jpeg;
      EventInfo.IsEncrypted := Res.IsEncrypted;
      CollectionEvents.DoIDEvent(TDBForm(Application.MainForm), Info.ID, [SetNewIDFileData], EventInfo);
    end
  );
end;


initialization

finalization
  TDatabaseUpdateManager.CleanUp;

end.
