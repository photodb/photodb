unit uMediaRepository;

interface

uses
  System.SysUtils,

  Dmitry.CRC32,

  uConstants,
  uMemory,
  uDBClasses,
  uDBConnection,
  uDBContext,
  uDBEntities;

type
  TMediaRepository = class(TInterfacedObject, IMediaRepository)
  private
    FContext: IDBContext;
  public
    constructor Create(Context: IDBContext);
    destructor Destroy; override;
    function GetIdByFileName(FileName: string): Integer;
    function GetFileNameById(ID: Integer): string;
    procedure SetFileNameById(ID: Integer; FileName: string);
    procedure SetAccess(ID, Access: Integer);
    procedure SetRotate(ID, Rotate: Integer);
    procedure SetRating(ID, Rating: Integer);
    procedure SetAttribute(ID, Attribute: Integer);
    function GetCount: Integer;
    function GetMenuItemByID(ID: Integer): TMediaItem;
    function GetMenuItemsByID(ID: Integer): TMediaItemCollection;
    function GetMenuInfosByUniqId(UniqId: string): TMediaItemCollection;
    procedure UpdateMediaInfosFromDB(Info: TMediaItemCollection);
    function UpdateMediaFromDB(Media: TMediaItem; LoadThumbnail: Boolean): Boolean;
  end;

implementation

{ TMediaRepository }

constructor TMediaRepository.Create(Context: IDBContext);
begin
  FContext := Context;
end;

destructor TMediaRepository.Destroy;
begin
  FContext := nil;
  inherited;
end;

function TMediaRepository.GetCount: Integer;
var
  SC: TSelectCommand;
begin
  Result := 0;

  SC := FContext.CreateSelect(ImageTable);
  try
    SC.AddParameter(TCustomFieldParameter.Create('COUNT(*) AS ITEMS_COUNT'));

    if SC.Execute > 0 then
      Result := SC.DS.FieldByName('ITEMS_COUNT').AsInteger;
  finally
    F(SC);
  end;
end;

function TMediaRepository.GetFileNameById(ID: Integer): string;
var
  SC: TSelectCommand;
begin
  Result := '';

  SC := FContext.CreateSelect(ImageTable);
  try
    SC.AddParameter(TStringParameter.Create('FFileName'));
    SC.AddWhereParameter(TIntegerParameter.Create('ID', ID));

    if SC.Execute > 0 then
      Result := SC.DS.FieldByName('FFileName').AsString;
  finally
    F(SC);
  end;
end;

function TMediaRepository.GetIdByFileName(FileName: string): Integer;
var
  SC: TSelectCommand;
begin
  Result := 0;

  SC := FContext.CreateSelect(ImageTable);
  try
    SC.AddParameter(TIntegerParameter.Create('ID'));

    SC.AddWhereParameter(TIntegerParameter.Create('FolderCRC', Integer(GetPathCRC(FileName, True))));
    SC.AddWhereParameter(TStringParameter.Create('Name', AnsiLowerCase(ExtractFileName(FileName)), paLike));

    if SC.Execute > 0 then
      Result := SC.DS.FieldByName('ID').AsInteger;
  finally
    F(SC);
  end;
end;

procedure TMediaRepository.SetAccess(ID, Access: Integer);
var
  UC: TUpdateCommand;
begin
  UC := FContext.CreateUpdate(ImageTable);
  try
    UC.AddWhereParameter(TIntegerParameter.Create('ID', ID));

    UC.AddParameter(TIntegerParameter.Create('Access', Access));
    UC.Execute;
  finally
    F(UC);
  end;
end;

procedure TMediaRepository.SetAttribute(ID, Attribute: Integer);
var
  UC: TUpdateCommand;
begin
  UC := FContext.CreateUpdate(ImageTable);
  try
    UC.AddWhereParameter(TIntegerParameter.Create('ID', ID));

    UC.AddParameter(TIntegerParameter.Create('Attr', Attribute));
    UC.Execute;
  finally
    F(UC);
  end;
end;

procedure TMediaRepository.SetFileNameById(ID: Integer; FileName: string);
var
  UC: TUpdateCommand;
begin
  UC := FContext.CreateUpdate(ImageTable);
  try
    UC.AddWhereParameter(TIntegerParameter.Create('ID', ID));

    UC.AddParameter(TIntegerParameter.Create('FolderCRC', GetPathCRC(FileName, True)));
    UC.AddParameter(TStringParameter.Create('FFileName', AnsiLowerCase(FileName)));
    UC.AddParameter(TStringParameter.Create('Name', ExtractFileName(FileName)));

    UC.Execute;
  finally
    F(UC);
  end;
end;

procedure TMediaRepository.SetRating(ID, Rating: Integer);
var
  UC: TUpdateCommand;
begin
  UC := FContext.CreateUpdate(ImageTable);
  try
    UC.AddWhereParameter(TIntegerParameter.Create('ID', ID));

    UC.AddParameter(TIntegerParameter.Create('Rating', Rating));
    UC.Execute;
  finally
    F(UC);
  end;
end;

procedure TMediaRepository.SetRotate(ID, Rotate: Integer);
var
  UC: TUpdateCommand;
begin
  UC := FContext.CreateUpdate(ImageTable);
  try
    UC.AddWhereParameter(TIntegerParameter.Create('ID', ID));

    UC.AddParameter(TIntegerParameter.Create('Rotated', Rotate));
    UC.Execute;
  finally
    F(UC);
  end;
end;

function TMediaRepository.GetMenuItemByID(ID: Integer): TMediaItem;
var
  SC: TSelectCommand;
begin
  Result := nil;
  SC := FContext.CreateSelect(ImageTable);
  try
    SC.AddParameter(TAllParameter.Create);
    SC.AddWhereParameter(TIntegerParameter.Create('ID', ID));

    if SC.Execute > 0 then
      Result := TMediaItem.CreateFromDS(SC.DS);
  finally
    F(SC);
  end;
end;

function TMediaRepository.GetMenuItemsByID(ID: Integer): TMediaItemCollection;
var
  MediaItem: TMediaItem;
begin
  Result := TMediaItemCollection.Create;
  MediaItem := GetMenuItemByID(ID);
  if MediaItem <> nil then
    Result.Add(MediaItem);
end;

function TMediaRepository.GetMenuInfosByUniqId(UniqId: string): TMediaItemCollection;
var
  SC: TSelectCommand;
  MediaItem: TMediaItem;
begin
  Result := TMediaItemCollection.Create;

  SC := FContext.CreateSelect(ImageTable);
  try
    SC.AddParameter(TAllParameter.Create);

    SC.AddWhereParameter(TIntegerParameter.Create('StrThCrc', StringCRC(UniqId)));
    SC.AddWhereParameter(TStringParameter.Create('StrTh', UniqId));

    if SC.Execute > 0 then
    begin
      while not SC.DS.Eof do
      begin
        MediaItem := TMediaItem.CreateFromDS(SC.DS);
        Result.Add(MediaItem);

        SC.DS.Next;
      end;
      Result.Position := 0;
    end;

  finally
    F(SC);
  end;
end;

procedure TMediaRepository.UpdateMediaInfosFromDB(Info: TMediaItemCollection);
var
  I, J: Integer;
  SC: TSelectCommand;
  MediaItem: TMediaItem;
begin
  for I := 0 to Info.Count - 1 do
  begin
    if not Info[I].InfoLoaded then
    begin
      SC := FContext.CreateSelect(ImageTable);
      try
        //todo: don't select images
        SC.AddParameter(TAllParameter.Create);

        SC.AddWhereParameter(TIntegerParameter.Create('FolderCRC', GetPathCRC(Info[I].FileName, True)));

        if SC.Execute > 0 then
        begin
          while not SC.DS.Eof do
          begin
            MediaItem := TMediaItem.CreateFromDS(SC.DS);

            for J := I to Info.Count - 1 do
            begin
              if AnsiLowerCase(Info[I].FileName) = MediaItem.FileName then
                Info[I].Assign(MediaItem);
            end;

            SC.DS.Next;
          end;

        end;
      finally
        F(SC);
      end;
    end;
  end;
end;

function TMediaRepository.UpdateMediaFromDB(Media: TMediaItem; LoadThumbnail: Boolean): Boolean;
var
  SC: TSelectCommand;
begin
  Result := False;

  SC := FContext.CreateSelect(ImageTable);
  try
    if Media.ID > 0 then
      SC.AddWhereParameter(TIntegerParameter.Create('ID', Media.ID))
    else
    begin
      SC.AddWhereParameter(TIntegerParameter.Create('FolderCRC', GetPathCRC(Media.FileName, True)));
      SC.AddParameter(TStringParameter.Create('Name', ExtractFileName(Media.FileName)));
    end;

    if SC.Execute > 0 then
    begin
      Media.ReadFromDS(SC.DS);
      Media.Tag := EXPLORER_ITEM_IMAGE;
    end;
  finally
    F(SC);
  end;
end;

end.
