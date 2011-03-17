unit uPrivateHelper;

interface

uses
  Classes, SyncObjs, SysUtils, DB, uConstants, CommonDBSupport, uMemory, uGOM,
  win32crc, ActiveX;

type
  TPrivateHelper = class(TObject)
  private
    FPrivateDirectoryList: TList;
    FListReady : Boolean;
    FSync : TCriticalSection;
    FInitialized : Boolean;
    procedure Add(DirectoryCRC : Integer);
    procedure BeginUpdate;
    procedure EndUpdate;
    function MakeFolderCRC(Folder : string) : Integer;
  public
    constructor Create;
    destructor Destroy; override;
    class function Instance : TPrivateHelper;
    function IsPrivateDirectory(Directory : string) : Boolean;
    procedure Reset;
    procedure Init;
    procedure AddToPrivateList(Directory : string);
  end;

  TPrivateHelperThread = class(TThread)
  protected
    procedure Execute; override;
  end;

implementation

var
  FPrivateHelper : TPrivateHelper = nil;

{ TPrivateHelper }

procedure TPrivateHelper.Add(DirectoryCRC: Integer);
begin
  FPrivateDirectoryList.Add(Pointer(DirectoryCRC));
end;

procedure TPrivateHelper.AddToPrivateList(Directory: string);
begin
  FSync.Enter;
  try
     Add(MakeFolderCRC(Directory));
  finally
     FSync.Leave;
  end;
end;

procedure TPrivateHelper.BeginUpdate;
begin
  FSync.Enter;
end;

constructor TPrivateHelper.Create;
begin
  FSync := TCriticalSection.Create;
  FPrivateDirectoryList := TList.Create;
  FInitialized := False;
end;

destructor TPrivateHelper.Destroy;
begin
  F(FSync);
  F(FPrivateDirectoryList);
  inherited;
end;

procedure TPrivateHelper.EndUpdate;
begin
  FSync.Leave;
end;

procedure TPrivateHelper.Init;
begin
  if not FInitialized then
  begin
    FInitialized := True;
    TPrivateHelperThread.Create(False);
  end;
end;

class function TPrivateHelper.Instance: TPrivateHelper;
begin
  if FPrivateHelper = nil then
    FPrivateHelper := TPrivateHelper.Create;

  Result := FPrivateHelper;
end;

function TPrivateHelper.IsPrivateDirectory(Directory: string): Boolean;
var
  CRC : Integer;
begin
  if not FListReady then
  begin
    Result := True;
    Exit;
  end;

  FSync.Enter;
  try
    CRC := MakeFolderCRC(Directory);
    Result := FPrivateDirectoryList.IndexOf(Pointer(CRC)) > -1;
  finally
     FSync.Leave;
  end;
end;

function TPrivateHelper.MakeFolderCRC(Folder : string): Integer;
begin
  if (Folder <> '') and (Folder[Length(Folder)] = '\') or (Folder[Length(Folder)] = '/') then
    Folder := Copy(Folder, 1, Length(Folder) - 1);

  Result := 0;
  if Folder <> '' then
    CalcStringCRC32(Folder, Cardinal(Result));
end;

procedure TPrivateHelper.Reset;
begin
  FSync.Enter;
  try
    FListReady := False;
    FPrivateDirectoryList.Clear;
    Init;
  finally
     FSync.Leave;
  end;
end;

{ TPrivateHelperThread }

procedure TPrivateHelperThread.Execute;
var
  Query : TDataSet;
begin
  FreeOnTerminate := True;
  CoInitialize(nil);
  try
    Query := GetQuery(True);
    try
      ForwardOnlyQuery(Query);
      SetSQL(Query, Format('SELECT DISTINCT FolderCRC from $DB$ WHERE Access = %d', [Db_access_private]));
      Query.Open;
      if not Query.IsEmpty then
      begin
        Query.First;
        FPrivateHelper.Instance.BeginUpdate;
        try
          while not Query.Eof do
          begin
            FPrivateHelper.Instance.Add(Query.Fields[0].AsInteger);
            Query.Next;
          end;
          FPrivateHelper.Instance.FListReady := True;
        finally
          FPrivateHelper.Instance.EndUpdate;
        end;
      end;
    finally
      FreeDS(Query);
    end;
  finally
    CoUninitialize;
  end;
end;

initialization

finalization

  F(FPrivateHelper);

end.
