unit uExplorerFolderImages;

interface

uses
  SysUtils,
  SyncObjs,
  Graphics,
  uMemory,
  uFileUtils,
  uBitmapUtils;

type
  TFolderImages = record
    Images: array [1 .. 4] of TBitmap;
    FileNames: array [1 .. 4] of string;
    FileDates: array [1 .. 4] of TDateTime;
    Directory: string;
    Width: Integer;
    Height: Integer;
  end;

  TExplorerFolders = class(TObject)
  private
    FImages: array of TFolderImages;
    FSaveFoldersToDB: Boolean;
    FSync: TCriticalSection;
    procedure SetSaveFoldersToDB(const Value: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure SaveFolderImages(FolderImages: TFolderImages; Width: Integer; Height: Integer);
    function GetFolderImages(Directory: string; Width: Integer; Height: Integer): TFolderImages;
    property SaveFoldersToDB: Boolean read FSaveFoldersToDB write SetSaveFoldersToDB;
    procedure CheckFolder(Folder: string);
    procedure Clear;
  end;

function ExplorerFolders: TExplorerFolders;

implementation

var
  FExplorerFolders: TExplorerFolders = nil;
                 
function ExplorerFolders: TExplorerFolders;
begin
  if FExplorerFolders = nil then
    FExplorerFolders := TExplorerFolders.Create;

  Result := FExplorerFolders;
end;

{ TExplorerFolders }

procedure TExplorerFolders.CheckFolder(Folder: string);
var
  I, K, L: Integer;
begin
  FSync.Enter;
  try
    for I := Length(FImages) - 1 downto 0 do
    begin
      if AnsiLowerCase(FImages[I].Directory) = AnsiLowerCase(Folder) then
      for k := 1 to 4 do
      if FImages[I].FileNames[K] = '' then
      begin
        for L := 1 to 4 do
          F(FImages[I].Images[L]);

        for L := I to Length(FImages) - 2 do
          FImages[L] := FImages[L + 1];
        if Length(FImages) > 0 then
          SetLength(FImages, Length(FImages) - 1);
        Exit;
      end;
    end;
  finally
    FSync.Leave;
  end;
end;

procedure TExplorerFolders.Clear;
var
  I, J: Integer;
begin
  FSync.Enter;
  try
    for I := 0 to Length(FImages) - 1 do
      for J := 1 to 4 do
        F(FImages[I].Images[J]);
    SetLength(FImages, 0);
  finally
    FSync.Leave;
  end;
end;

constructor TExplorerFolders.Create;
begin
  FSync := TCriticalSection.Create;
  SaveFoldersToDB := False;
  SetLength(FImages, 0);
end;

destructor TExplorerFolders.Destroy;
begin
  Clear;
  F(FSync);
  inherited;
end;

function TExplorerFolders.GetFolderImages(
  Directory: String; Width: Integer; Height: Integer): TFolderImages;
var
  I, J, K, W, H: Integer;
  B: Boolean;
begin
  FSync.Enter;
  try
    Directory := IncludeTrailingBackslash(Directory);
    Result.Directory := '';
    for I := 1 to 4 do
      Result.Images[I] := nil;

    for I := 0 to Length(FImages)-1 do
    begin
      if (AnsiLowerCase(FImages[I].Directory) = AnsiLowerCase(Directory))
        and (Width <= FImages[i].Width) then
      begin
        B := True;
        for K := 1 to 4 do
          if FImages[I].FileNames[K]<>'' then
            if not FileExistsSafe(FImages[I].FileNames[K]) then
            begin
              B := False;
              Break;
            end;
        if B then
          for k:=1 to 4 do
            if FImages[I].FileNames[K] <> '' then
              if FImages[I].FileDates[K] <> GetFileDateTime(FImages[I].FileNames[K]) then
              begin
                B := False;
                Break;
              end;
        if B then
        begin
          Result.Directory := Directory;
          for J := 1 to 4 do
          begin
            Result.Images[J] := TBitmap.create;
            if FImages[I].Images[J] <> nil then
            begin
              W := FImages[I].Images[J].Width;
              H := FImages[I].Images[J].height;
              ProportionalSize(Width, Height, W, H);
              Result.Images[J].PixelFormat := FImages[I].Images[J].PixelFormat;
              DoResize(W, H, FImages[I].Images[J], Result.Images[J]);
            end;
          end;
        end;
      end;
    end;
  finally
    FSync.Leave;
  end;
end;

procedure TExplorerFolders.SaveFolderImages(FolderImages: TFolderImages;
  Width: Integer; Height: Integer);
var
  I, J: Integer;
  B: Boolean;
  L: Integer;
begin
  FSync.Enter;
  try
    B := False;
    FolderImages.Directory := IncludeTrailingBackslash(FolderImages.Directory);
    for I := 0 to Length(FImages) - 1 do
    begin
      if AnsiLowerCase(FImages[I].Directory) = AnsiLowerCase(FolderImages.Directory) then
      if FImages[I].Width < Width then
      begin
        FImages[I].Width := Width;
        FImages[I].Height := Height;
        FImages[I].Directory := FolderImages.Directory;
        for J := 1 to 4 do
          FImages[I].FileNames[J] := FolderImages.FileNames[J];
        for J := 1 to 4 do
          FImages[I].FileDates[J] := FolderImages.FileDates[J];
        for J := 1 to 4 do
          F(FImages[I].Images[J]);

        for J := 1 to 4 do
        begin
          if FolderImages.Images[J] = nil then
            Break;
          FImages[I].Images[J] := TBitmap.Create;
          AssignBitmap(FImages[I].Images[J], FolderImages.Images[J]);
        end;
        B := True;
        Break;
     end;
   end;
   if not B and (FolderImages.Images[1] <> nil) then
   begin
     SetLength(FImages, Length(FImages) + 1);
     L := Length(FImages) - 1;
     FImages[L].Width := Width;
     FImages[L].Height := Height;
     FImages[L].Directory := FolderImages.Directory;
     for I := 1 to 4 do
       FImages[L].FileNames[I] := FolderImages.FileNames[I];
     for I := 1 to 4 do
       FImages[L].FileDates[I] := FolderImages.FileDates[I];
     for I := 1 to 4 do
       FImages[L].Images[I] := nil;
     for I := 1 to 4 do
     begin
       if FolderImages.Images[I] = nil then
         Break;
       FImages[L].Images[I] := TBitmap.Create;
       AssignBitmap(FImages[L].Images[I], FolderImages.Images[I]);
     end;
   end;
  finally
    FSync.Leave;
  end;
end;

procedure TExplorerFolders.SetSaveFoldersToDB(const Value: Boolean);
begin
  FSaveFoldersToDB := Value;
end;

initialization

finalization
  F(FExplorerFolders);

end.
