unit uExplorerCollectionProvider;

interface

uses
  System.SysUtils,
  System.StrUtils,
  Vcl.Graphics,
  Data.DB,

  Dmitry.Utils.System,
  Dmitry.Utils.Files,
  Dmitry.Utils.ShellIcons,
  Dmitry.PathProviders,
  Dmitry.PathProviders.MyComputer,

  uConstants,
  uMemory,
  uTranslate,
  uPhotoShelf,
  uDBConnection,
  uDBManager,
  uDBContext,
  uExplorerPathProvider;

type
  TCollectionItem = class(TPathItem)
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
    function GetIsDirectory: Boolean; override;
  public
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    constructor Create; override;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
  end;

  TCollectionFolder = class(TPathItem)
  private
    FCount: Integer;
    function GetPhysicalPath: string;
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
    function GetIsDirectory: Boolean; override;
    function GetDisplayName: string; override;
  public
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    procedure SetCount(Count: Integer);
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
    property PhysicalPath: string read GetPhysicalPath;
  end;

  TCollectionDeletedItemsFolder = class(TPathItem)
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
    function GetIsDirectory: Boolean; override;
  public
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
  end;

  TCollectionDuplicateItemsFolder = class(TPathItem)
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
    function GetIsDirectory: Boolean; override;
  public
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
  end;

type
  TCollectionProvider = class(TExplorerPathProvider)
  protected
    function GetTranslateID: string; override;
  public
    function Supports(Item: TPathItem): Boolean; override;
    function Supports(Path: string): Boolean; override;
    function CreateFromPath(Path: string): TPathItem; override;
    function InternalFillChildList(Sender: TObject; Item: TPathItem; List: TPathItemCollection; Options, ImageSize: Integer; PacketSize: Integer; CallBack: TLoadListCallBack): Boolean; override;
  end;

implementation

{ TCollectionItem }

constructor TCollectionItem.Create;
begin
  inherited;
  FCanHaveChildren := True;
  FDisplayName := TA('Collection', 'CollectionProvider');
end;

constructor TCollectionItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
begin
  inherited;
  Create;
  if Options and PATH_LOAD_NO_IMAGE = 0 then
    LoadImage(Options, ImageSize);
end;

function TCollectionItem.GetIsDirectory: Boolean;
begin
  Result := True;
end;

function TCollectionItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TCollectionItem.Create;
end;

function TCollectionItem.InternalGetParent: TPathItem;
begin
  Result := THomeItem.Create;
end;

function TCollectionItem.LoadImage(Options, ImageSize: Integer): Boolean;
var
  Icon: TIcon;
begin
  F(FImage);
  FindIcon(HInstance, 'COLLECTION', ImageSize, 32, Icon);
  FImage := TPathImage.Create(Icon);
  Result := True;
end;

{ TCollectionFolder }

constructor TCollectionFolder.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
var
  I: Integer;
begin
  inherited;
  FCanHaveChildren := True;
  if (APath = '') or (APath = cCollectionPath + '\' + cCollectionBrowsePath) then
    FDisplayName := TA('Browse directories', 'CollectionProvider')
  else
  begin
    I := APath.LastDelimiter(PathDelim);
    FDisplayName := APath.SubString(I + 1);
  end;

  if Options and PATH_LOAD_NO_IMAGE = 0 then
    LoadImage(Options, ImageSize);
end;

function TCollectionFolder.GetDisplayName: string;
begin
  if FCount = 0 then
   Exit(FDisplayName);

  Result := FormatEx('{0} ({1})', [FDisplayName, FCount]);
end;

function TCollectionFolder.GetIsDirectory: Boolean;
begin
  Result := True;
end;

function TCollectionFolder.GetPhysicalPath: string;
begin
  Result := Path;
  Delete(Result, 1, Length(cCollectionPath + '\' + cCollectionBrowsePath + '\'));
end;

function TCollectionFolder.InternalCreateNewInstance: TPathItem;
begin
  Result := TCollectionFolder.Create;
end;

function TCollectionFolder.InternalGetParent: TPathItem;
var
  S: string;
begin
  S := Path;
  Delete(S, 1, Length(cCollectionPath + '\' + cCollectionBrowsePath + '\'));

  if IsDrive(S) or IsNetworkServer(S) then
    Exit(TCollectionFolder.CreateFromPath(cCollectionPath + '\' + cCollectionBrowsePath, PATH_LOAD_NO_IMAGE, 0));

  while IsPathDelimiter(S, Length(S)) do
    S := ExcludeTrailingPathDelimiter(S);

  if S.EndsWith('::') and S.StartsWith('::') and (Pos('\', S) = 0) then
    //this is CD mapper path
    Exit(TCollectionFolder.CreateFromPath(cCollectionPath + '\' + cCollectionBrowsePath, PATH_LOAD_NO_IMAGE, 0))
  else
    S := ExtractFileDir(S);

  if (S = '') then
    Exit(TCollectionItem.CreateFromPath(cCollectionPath, PATH_LOAD_NO_IMAGE, 0));

  Result := TCollectionFolder.CreateFromPath(cCollectionPath + '\' + cCollectionBrowsePath + '\' + S, PATH_LOAD_NO_IMAGE, 0)
end;

function TCollectionFolder.LoadImage(Options, ImageSize: Integer): Boolean;
var
  Icon: TIcon;
begin
  F(FImage);
  FindIcon(HInstance, 'DIRECTORY', ImageSize, 32, Icon);
  FImage := TPathImage.Create(Icon);
  Result := True;
end;

procedure TCollectionFolder.SetCount(Count: Integer);
begin
  FCount := Count;
end;

{ TCollectionDeletedItemsFolder }

constructor TCollectionDeletedItemsFolder.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
begin
  inherited;
  FCanHaveChildren := True;
  FDisplayName := TA('Missed items', 'CollectionProvider');
  if Options and PATH_LOAD_NO_IMAGE = 0 then
    LoadImage(Options, ImageSize);
end;

function TCollectionDeletedItemsFolder.GetIsDirectory: Boolean;
begin
  Result := True;
end;

function TCollectionDeletedItemsFolder.InternalCreateNewInstance: TPathItem;
begin
  Result := TCollectionDeletedItemsFolder.Create;
end;

function TCollectionDeletedItemsFolder.InternalGetParent: TPathItem;
begin
  Result := TCollectionItem.CreateFromPath(cCollectionPath, PATH_LOAD_NO_IMAGE, 0);
end;

function TCollectionDeletedItemsFolder.LoadImage(Options,
  ImageSize: Integer): Boolean;
var
  Icon: TIcon;
begin
  F(FImage);
  FindIcon(HInstance, 'DELETEDITEMS', ImageSize, 32, Icon);
  FImage := TPathImage.Create(Icon);
  Result := True;
end;

{ TCollectionDuplicateItemsFolder }

constructor TCollectionDuplicateItemsFolder.CreateFromPath(APath: string;
  Options, ImageSize: Integer);
begin
  inherited;
  FCanHaveChildren := True;
  FDisplayName := TA('Duplicates', 'CollectionProvider');
  if Options and PATH_LOAD_NO_IMAGE = 0 then
    LoadImage(Options, ImageSize);
end;

function TCollectionDuplicateItemsFolder.GetIsDirectory: Boolean;
begin
  Result := True;
end;

function TCollectionDuplicateItemsFolder.InternalCreateNewInstance: TPathItem;
begin
  Result := TCollectionDuplicateItemsFolder.Create;
end;

function TCollectionDuplicateItemsFolder.InternalGetParent: TPathItem;
begin
  Result := TCollectionItem.CreateFromPath(cCollectionPath, PATH_LOAD_NO_IMAGE, 0);
end;

function TCollectionDuplicateItemsFolder.LoadImage(Options,
  ImageSize: Integer): Boolean;
var
  Icon: TIcon;
begin
  F(FImage);
  FindIcon(HInstance, 'DUPLICAT', ImageSize, 32, Icon);
  FImage := TPathImage.Create(Icon);
  Result := True;
end;

{ TCollectionProvider }

function TCollectionProvider.CreateFromPath(Path: string): TPathItem;
begin
  Result := nil;
  if StartsText(cCollectionPath + '\' + cCollectionBrowsePath, AnsiLowerCase(Path)) then
  begin
    Result := TCollectionFolder.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0);
    Exit;
  end;

  if StartsText(cCollectionPath + '\' + cCollectionDeletedPath, AnsiLowerCase(Path)) then
  begin
    Result := TCollectionDeletedItemsFolder.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0);
    Exit;
  end;

  if StartsText(cCollectionPath + '\' + cCollectionDuplicatesPath, AnsiLowerCase(Path)) then
  begin
    Result := TCollectionDuplicateItemsFolder.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0);
    Exit;
  end;

  if StartsText(cCollectionPath, AnsiLowerCase(Path)) then
  begin
    Result := TCollectionItem.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0);
    Exit;
  end;
end;

function TCollectionProvider.GetTranslateID: string;
begin
  Result := 'CollectionProvider';
end;

function TCollectionProvider.InternalFillChildList(Sender: TObject;
  Item: TPathItem; List: TPathItemCollection; Options, ImageSize,
  PacketSize: Integer; CallBack: TLoadListCallBack): Boolean;
var
  Cancel: Boolean;
  CI: TCollectionItem;
  CF: TCollectionFolder;
  DF: TCollectionDeletedItemsFolder;
  CD: TCollectionDuplicateItemsFolder;
  Path, Query, Folder: string;
  Context: IDBContext;
  FFoldersDS: TDataSet;
  P, Count: Integer;
begin
  inherited;
  Result := True;
  Cancel := False;

  if Options and PATH_LOAD_ONLY_FILE_SYSTEM > 0 then
    Exit;

  if Item is THomeItem then
  begin
    CI := TCollectionItem.CreateFromPath(cCollectionPath, Options, ImageSize);
    List.Add(CI);
  end;

  if Item is TCollectionItem then
  begin
    CF := TCollectionFolder.CreateFromPath(cCollectionPath + '\' + cCollectionBrowsePath, Options, ImageSize);
    List.Add(CF);

    DF := TCollectionDeletedItemsFolder.CreateFromPath(cCollectionPath + '\' + cCollectionDeletedPath, Options, ImageSize);
    List.Add(DF);

    CD := TCollectionDuplicateItemsFolder.CreateFromPath(cCollectionPath + '\' + cCollectionDuplicatesPath, Options, ImageSize);
    List.Add(CD);
  end;

  if Item is TCollectionFolder then
  begin
    Path := IncludeTrailingBackslash(Item.Path);
    Delete(Path, 1, Length(cCollectionPath + '\' + cCollectionBrowsePath + ':'));

    Context := DBManager.DBContext;
    FFoldersDS := Context.CreateQuery(dbilRead);
    try
      ForwardOnlyQuery(FFoldersDS);

      Query := FormatEx('SELECT First(FFileName) as [FileName], Count(*) from ImageTable Im '+
        'where FFileName like "{0}%" '+
        'group by Left(FFileName, Instr ({1},FFileName, "\")) ', [Path, Length(Path) + 1]);

      SetSQL(FFoldersDS, Query);
      OpenDS(FFoldersDS);

      while not FFoldersDS.EOF do
      begin
        Folder := FFoldersDS.Fields[0].AsString;
        Count := FFoldersDS.Fields[1].AsInteger;

        Delete(Folder, 1, Length(Path));
        if (Path = '') and StartsText('\\', Folder) then
          P := PosEx('\', Folder, 3)
        else
          P := Pos('\', Folder);

        //file
        if P = 0 then
        begin
          FFoldersDS.Next;
          Continue;
        end;

        Delete(Folder, P, Length(Folder) - P + 1);

        CF := TCollectionFolder.CreateFromPath(cCollectionPath + '\' + cCollectionBrowsePath + IIF(Path = '\', '', '\' + Path) + Folder, Options, ImageSize);
        CF.SetCount(Count);
        List.Add(CF);

        FFoldersDS.Next;
      end;
    finally
      FreeDS(FFoldersDS);
    end;

  end;

  if Assigned(CallBack) then
    CallBack(Sender, Item, List, Cancel);
end;

function TCollectionProvider.Supports(Item: TPathItem): Boolean;
begin
  Result := Item is TCollectionItem;
  Result := Result or Supports(Item.Path);
end;

function TCollectionProvider.Supports(Path: string): Boolean;
begin
  Result := StartsText(cCollectionPath, AnsiLowerCase(Path));
end;

end.
