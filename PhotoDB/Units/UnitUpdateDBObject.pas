unit UnitUpdateDBObject;

interface

uses
  System.Math,
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  Winapi.Windows,
  Vcl.Controls,
  Vcl.Forms,

  Dmitry.CRC32,
  Dmitry.Utils.Files,

  UnitINI,
  UnitDBDeclare,
  UnitDBKernel,

  uDBPopupMenuInfo,
  uConfiguration,
  uConstants,
  uMemory,
  uRuntime,
  uMemoryEx,
  uTranslate,
  uDBForm,
  uSettings,
  uAssociations,
  uLogger,
  uUpdateDBTypes,
  uInterfaceManager;

type
  TUpdaterDB = class(TObject)
  private
    { Private declarations }
    FPosition: Integer;
    FShowWindow: Boolean;
    FMaxSize: Int64;
    FTerminate: Boolean;
    FActive: Boolean;
    FAuto: Boolean;
    FAutoAnswer: Integer;
    FPause: Boolean;
    BeginTime: TDateTime;
    FFilesInfo: TDBPopupMenuInfo;
    FUseFileNameScaning: Boolean;
    FIsSaved: Boolean;
    procedure SetAuto(const Value: Boolean);
    procedure SetAutoAnswer(Value: Integer);
    procedure SetUseFileNameScaning(const Value: Boolean);
    function GetForm: TDBForm;
    procedure FoundedEvent(Owner: TObject; FileName: string; Size: Int64);
  public
    NoLimit: Boolean;
    class procedure CheckSavedWork;
    constructor Create;
    destructor Destroy; override;
    function AddFile(FileName: string; Silent: Boolean = False): Boolean;
    function AddFileEx(FileInfo: TDBPopupMenuInfoRecord; Silent, Critical: Boolean): Boolean;
    function AddDirectory(Directory: string): Boolean;
    function HasFile(FileName: string): Boolean;
    procedure EndDirectorySize(Sender: TObject);
    procedure OnAddFileDone(Sender: TObject);
    procedure Execute;
    procedure ShowWindowNow;
    procedure DoTerminate;
    procedure DoPause;
    procedure DoUnPause;
    procedure SaveWork;
    procedure LoadWork;
    function GetFilesCount: Integer;
    function FileExistsInFileList(FileName: string): Boolean;
    function GetCount: Integer;
    function GetSize: Int64;
    property Active: Boolean read FActive;
    property Auto: Boolean read FAuto write SetAuto default True;
    property UseFileNameScaning: Boolean read FUseFileNameScaning write SetUseFileNameScaning default False;
    property AutoAnswer: Integer read FAutoAnswer write SetAutoAnswer;
    property Pause: Boolean read FPause;
    property Form: TDBForm read GetForm;
  end;

function UpdaterDB: TUpdaterDB;
procedure UpdaterObjectSaveWork;

implementation

uses
  UnitUpdateDBThread,
  CommonDBSupport,
  FormManegerUnit,
  UnitUpdateDB,
  ProgressActionUnit;

var
  FUpdaterDB: TUpdaterDB = nil;
  FSyncSingelton: TCriticalSection;

function UpdaterDB: TUpdaterDB;
begin
  if FUpdaterDB <> nil then
    Exit(FUpdaterDB);

  FSyncSingelton.Enter;
  try
    if FUpdaterDB = nil then
    begin
      FUpdaterDB := TUpdaterDB.Create;
      FUpdaterDB.LoadWork;
    end;

    Result := FUpdaterDB;
  finally
    FSyncSingelton.Leave;
  end;
end;

procedure UpdaterObjectSaveWork;
begin
  if FUpdaterDB <> nil then
    FUpdaterDB.SaveWork;
end;

{ TUpdaterDB }

function TUpdaterDB.AddDirectory(Directory: string): Boolean;
begin
  TThread.Synchronize(nil,
    procedure
    var
      I: IDBUpdaterCallBack;
    begin
      if FFilesInfo.Count = 0 then
        for I in InterfaceManager.QueryInterfaces<IDBUpdaterCallBack>(IID_DBUpdaterCallBack) do
          I.UpdaterSetText(TA('Getting list of files from directory', 'Updater'));

      for I in InterfaceManager.QueryInterfaces<IDBUpdaterCallBack>(IID_DBUpdaterCallBack) do
        I.UpdaterSetFullSize(0);
    end
  );
  FTerminate := False;
  DirectorySizeThread.Create(Directory, EndDirectorySize, @FTerminate, FoundedEvent);
  Result := True;
end;

procedure TUpdaterDB.FoundedEvent(Owner: TObject; FileName: string; Size: Int64);
begin
  TThread.Synchronize(nil,
    procedure
    var
      I: IDBUpdaterCallBack;
    begin
      for I in InterfaceManager.QueryInterfaces<IDBUpdaterCallBack>(IID_DBUpdaterCallBack) do
        I.UpdaterFoundedEvent(Owner, FileName, Size);
    end
  );
end;

function TUpdaterDB.FileExistsInFileList(FileName: String): Boolean;
var
  I: Integer;
  CRC: Cardinal;
  Info: TDBPopupMenuInfoRecord;
begin
  Result := False;
  FileName := AnsiLowerCase(FileName);
  CRC := StringCRC(FileName);
  for I := 0 to FFilesInfo.Count - 1 do
  begin
    Info := FFilesInfo[I];
    if (CRC = Info.FileNameCRC) and (FileName = AnsiLowerCase(Info.FileName)) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function TUpdaterDB.AddFile(FileName: string; Silent: Boolean = False): Boolean;
var
  Info: TDBPopupMenuInfoRecord;
begin
  Info := TDBPopupMenuInfoRecord.Create;
  try
    Info.FileName := FileName;
    Info.Include := True;
    Result := AddFileEx(Info, Silent, False);
  finally
    F(Info);
  end;
end;

function TUpdaterDB.AddFileEx(FileInfo: TDBPopupMenuInfoRecord; Silent, Critical: Boolean): Boolean;
var
  FileName: string;
  Info: TDBPopupMenuInfoRecord;
begin
  Result := False;
  if DBTerminating then
    Exit;

  FileName := FileInfo.FileName;
  FileInfo.FileName := FileName;

  if Silent or (FileExistsSafe(FileName) and IsGraphicFile(FileName)) then
    if not(FileExistsInFileList(FileName)) then
    begin
      if FileInfo.FileSize = 0 then
        FileInfo.FileSize := GetFileSizeByName(FileName);
      Inc(FMaxSize, FileInfo.FileSize);

      Info := FileInfo.Copy;
      if not Critical then
        FFilesInfo.Add(Info)
      else
        FFilesInfo.Insert(FPosition, Info);

      TThread.Synchronize(nil,
        procedure
        var
          I: IDBUpdaterCallBack;
        begin
          for I in InterfaceManager.QueryInterfaces<IDBUpdaterCallBack>(IID_DBUpdaterCallBack) do
          begin
            I.UpdaterSetMaxValue(FFilesInfo.Count);
            I.UpdaterAddFileSizes(FileInfo.FileSize);
          end;
        end
      );

      if Auto then
      begin
        Execute;
        if not Silent then
        begin

          TThread.Synchronize(nil,
            procedure
            var
              I: IDBUpdaterCallBack;
            begin
              for I in InterfaceManager.QueryInterfaces<IDBUpdaterCallBack>(IID_DBUpdaterCallBack) do
                I.UpdaterShowForm(Self);
            end
          );

        end;
      end;
    end;
  Result := True;
end;

class procedure TUpdaterDB.CheckSavedWork;
begin
  //do nothing
end;

constructor TUpdaterDB.Create;
begin
  FIsSaved := False;
  FFilesInfo := TDBPopupMenuInfo.Create;

  NoLimit := False;
  FUseFileNameScaning := False;

  FFilesInfo.Clear;
  FPosition := 0;
  Auto := True;
  FTErminate := False;
  FShowWindow := False;
  FActive := False;
  FmaxSize := 0;
  FPause := False;
  FAutoAnswer := Result_invalid;

  BeginTime := -1;
end;

destructor TUpdaterDB.Destroy;
begin
  F(FFilesInfo);
end;

procedure TUpdaterDB.DoPause;
begin
  FPause := True;
end;

procedure TUpdaterDB.DoTerminate;
var
  EventInfo: TEventValues;
  I: Integer;
begin
  FTerminate := True;

  if not DBTerminating then
  begin
    for I := 0 to FFilesInfo.Count - 1 do
    begin
      EventInfo.FileName := AnsiLowerCase(FFilesInfo[I].FileName);
      DBKernel.DoIDEvent(Form, 0, [EventID_CancelAddingImage], EventInfo);
    end;
  end;
  FFilesInfo.Clear;
  FPosition := 0;
  FActive := False;
  BeginTime := -1;

  if not DBTerminating then
    TThread.Synchronize(nil,
      procedure
      var
        I: IDBUpdaterCallBack;
      begin
        for I in InterfaceManager.QueryInterfaces<IDBUpdaterCallBack>(IID_DBUpdaterCallBack) do
          I.UpdaterOnDone(Self);
      end
    );
end;

procedure TUpdaterDB.DoUnPause;
begin
  FPause := False;
  Execute;
end;

procedure TUpdaterDB.EndDirectorySize(Sender: TObject);
var
  I: Integer;
  Info: TDBPopupMenuInfo;
  Size: Int64;
begin
  Info := Sender as TDBPopupMenuInfo;

  TThread.Synchronize(nil,
    procedure
    var
      I: IDBUpdaterCallBack;
    begin
      if FFilesInfo.Count = 0 then
        for I in InterfaceManager.QueryInterfaces<IDBUpdaterCallBack>(IID_DBUpdaterCallBack) do
          I.UpdaterSetFileName(TA('<No files>', 'Updater'));
    end
  );

  Size := 0;
  for I := 0 to Info.Count - 1 do
    Inc(Size, Info[I].FileSize);

  FMaxSize := FMaxSize + Size;

  TThread.Synchronize(nil,
    procedure
    var
      I: IDBUpdaterCallBack;
    begin
      for I in InterfaceManager.QueryInterfaces<IDBUpdaterCallBack>(IID_DBUpdaterCallBack) do
        I.UpdaterAddFileSizes(Size);
    end
  );

  for I := 0 to Info.Count - 1 do
    FFilesInfo.Add(Info[I].Copy);

  TThread.Synchronize(nil,
    procedure
    var
      I: IDBUpdaterCallBack;
    begin
      for I in InterfaceManager.QueryInterfaces<IDBUpdaterCallBack>(IID_DBUpdaterCallBack) do
        I.UpdaterSetMaxValue(FFilesInfo.Count);
    end
  );

  if Auto then
  begin
    ShowMessageAboutLimit := True;
    Execute;

    TThread.Synchronize(nil,
      procedure
      var
        I: IDBUpdaterCallBack;
      begin
        for I in InterfaceManager.QueryInterfaces<IDBUpdaterCallBack>(IID_DBUpdaterCallBack) do
          I.UpdaterShowForm(Self);
      end
    );
  end;

  TThread.Synchronize(nil,
    procedure
    var
      I: IDBUpdaterCallBack;
    begin
      for I in InterfaceManager.QueryInterfaces<IDBUpdaterCallBack>(IID_DBUpdaterCallBack) do
        I.UpdaterDirectoryAdded(Self);
    end
  );
end;

procedure TUpdaterDB.Execute;
var
  Info: TDBPopupMenuInfo;
  I: Integer;
begin
  try
    if FIsSaved then
      Exit;

    if BeginTime < 0 then
      BeginTime := Now;
    if FTerminate then
    begin
      FTerminate := False;
      FActive := False;
      BeginTime := -1;
      Exit;
    end;
    if FActive then
      Exit;
    FActive := True;
    if FPosition = 0 then
    begin

      TThread.Synchronize(nil,
        procedure
        var
          I: IDBUpdaterCallBack;
        begin
          for I in InterfaceManager.QueryInterfaces<IDBUpdaterCallBack>(IID_DBUpdaterCallBack) do
            I.UpdaterSetBeginUpdation(Self);
        end
      );

    end;
    if FPosition >= FFilesInfo.Count then
    begin
      FFilesInfo.Clear;
      FPosition := 0;
      FActive := False;
      BeginTime := -1;

      TThread.Synchronize(nil,
        procedure
        var
          I: IDBUpdaterCallBack;
        begin
          for I in InterfaceManager.QueryInterfaces<IDBUpdaterCallBack>(IID_DBUpdaterCallBack) do
            I.UpdaterOnDone(Self);
        end
      );

      Exit;
    end;
    if FFilesInfo.Count = 0 then
    begin
      FActive := False;

      TThread.Synchronize(nil,
        procedure
        var
          I: IDBUpdaterCallBack;
        begin
          for I in InterfaceManager.QueryInterfaces<IDBUpdaterCallBack>(IID_DBUpdaterCallBack) do
            I.UpdaterOnDone(Self);
        end
      );

      Exit;
    end;
    if (FPosition <> 0) then
    begin

      TThread.Synchronize(nil,
        procedure
        var
          I: IDBUpdaterCallBack;
        begin
          for I in InterfaceManager.QueryInterfaces<IDBUpdaterCallBack>(IID_DBUpdaterCallBack) do
            I.UpdaterShowImage(Self);
        end
      );

      if (FFilesInfo.Count - FPosition > 1) then
      begin

        TThread.Synchronize(nil,
          procedure
          var
            I: IDBUpdaterCallBack;
          begin
            for I in InterfaceManager.QueryInterfaces<IDBUpdaterCallBack>(IID_DBUpdaterCallBack) do
              I.UpdaterSetTimeText(TimeTostr(((Now - BeginTime) / FPosition) * (FFilesInfo.Count - FPosition)));
          end
        );

      end else
      begin

        TThread.Synchronize(nil,
          procedure
          var
            I: IDBUpdaterCallBack;
          begin
            for I in InterfaceManager.QueryInterfaces<IDBUpdaterCallBack>(IID_DBUpdaterCallBack) do
              I.UpdaterSetTimeText(TA('The last file', 'Updater') + '...');
          end
        );

      end;
    end;

    TThread.Synchronize(nil,
      procedure
      var
        I: IDBUpdaterCallBack;
      begin
        for I in InterfaceManager.QueryInterfaces<IDBUpdaterCallBack>(IID_DBUpdaterCallBack) do
        begin
          I.UpdaterSetPosition(FPosition + 1, FFilesInfo.Count);
          I.UpdaterSetFileName(FFilesInfo[FPosition].FileName);
        end;
      end
    );

    if FPause then
    begin
      FActive := False;
      Exit;
    end;

    Info := TDBPopupMenuInfo.Create;

    for I := 0 to 4 do
    begin
      Info.Add(FFilesInfo[FPosition].Copy);
      Inc(FPosition);
      if (FFilesInfo.Count - FPosition = 0) then
        Break;
    end;
    UpdateDBThread.Create(Self, Info, OnAddFileDone, FAutoAnswer, UseFileNameScaning, @FTerminate, @FPause, NoLimit);
  except
    on e: Exception do
      EventLog(e);
  end;
end;

procedure TUpdaterDB.OnAddFileDone(Sender: TObject);
begin
  FActive := False;
  Execute;
end;

procedure TUpdaterDB.SetAuto(const Value: Boolean);
begin
  FAuto := Value;
end;

procedure TUpdaterDB.SetAutoAnswer(Value: Integer);
begin
  FAutoAnswer := Value;

  TThread.Synchronize(nil,
    procedure
    var
      I: IDBUpdaterCallBack;
    begin
      for I in InterfaceManager.QueryInterfaces<IDBUpdaterCallBack>(IID_DBUpdaterCallBack) do
        I.UpdaterSetAutoAnswer(Value);
    end
  );
end;

procedure TUpdaterDB.SetUseFileNameScaning(const Value: boolean);
begin
  FUseFileNameScaning := Value;
end;

procedure TUpdaterDB.ShowWindowNow;
begin
  TThread.Synchronize(nil,
    procedure
    var
      I: IDBUpdaterCallBack;
    begin
      for I in InterfaceManager.QueryInterfaces<IDBUpdaterCallBack>(IID_DBUpdaterCallBack) do
        I.UpdaterShowForm(Self);
    end
  );
end;

function TUpdaterDB.GetFilesCount: Integer;
begin
  Result := FFilesInfo.Count;
end;

function TUpdaterDB.GetForm: TDBForm;
var
  F: TDBForm;
begin
  TThread.Synchronize(nil,
    procedure
    var
      I: IDBUpdaterCallBack;
    begin
      for I in InterfaceManager.QueryInterfaces<IDBUpdaterCallBack>(IID_DBUpdaterCallBack) do
        F := I.UpdaterGetForm;
    end
  );

  Result := F;
end;

function TUpdaterDB.GetSize: Int64;
var
  I: Integer;
begin
  Result := 0;
  for I := FPosition to FFilesInfo.Count - 1 do
    Result := Result + FFilesInfo[I].FileSize;
end;

function TUpdaterDB.HasFile(FileName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  FileName := AnsiLowerCase(FileName);
  for I := 0 to FFilesInfo.Count - 1 do
    if AnsiLowerCase(FFilesInfo[I].FileName) = FileName then
      Exit(True);
end;

procedure TUpdaterDB.LoadWork;
var
  C: Integer;
begin
  if FIsSaved then
    Exit;

  TThread.Synchronize(nil,
    procedure
    begin
      CreateUpdaterForm;
    end
  );

  TThread.Synchronize(nil,
  procedure
  var
    DataFileName, DBPrefix, FileName: string;
    Items: TStrings;

    procedure AddFileToList(FileName: string);
    var
      FileSize: Int64;
      Info: TDBPopupMenuInfoRecord;
    begin
      if IsGraphicFile(FileName) and not(FileExistsInFileList(FileName)) then
      begin
        FileSize := GetFileSizeByName(FileName);
        if FileSize > 0 then
        begin
          Inc(FMaxSize, FileSize);

          Info := TDBPopupMenuInfoRecord.CreateFromFile(FileName);
          Info.FileSize := FileSize;
          Info.Include := True;

          FFilesInfo.Add(Info);
        end;
      end;
    end;

  begin
    DBPrefix := ExtractFileName(dbname) + IntToStr(StringCRC(dbname));
    DataFileName := GetAppDataDirectory + UpdaterDirectory + DBPrefix + '.dat';

    Items := TStringList.Create;
    try
      try
        Items.LoadFromFile(DataFileName);

        C := Items.Count;

        for FileName in Items do
          AddFileToList(FileName);

      except
        on E: Exception do
          EventLog(E);
      end;
    finally
      F(Items);
    end;
  end
  );

  if C > 0 then
    Execute;
end;

procedure TUpdaterDB.SaveWork;
var
  I, SkipCount: Integer;
  DBPrefix, DataFileName: string;
  Data: TStrings;
begin
  if FIsSaved then
    Exit;

  FIsSaved := True;

  //Start saving from current psition minus possible 4 items in progress
  SkipCount := Max(0, FPosition - 4);

  DBPrefix := ExtractFileName(dbname) + IntToStr(StringCRC(dbname));
  DBPrefix := ExtractFileName(dbname) + IntToStr(StringCRC(dbname));
  DataFileName := GetAppDataDirectory + UpdaterDirectory + DBPrefix + '.dat';

  Data := TStringList.Create;
  try
    for I := 0 to FFilesInfo.Count - 1 - SkipCount do
      Data.Add(FFilesInfo[I + SkipCount].FileName);
  finally
    F(Data);
  end;
end;

function TUpdaterDB.GetCount: Integer;
begin
  Result := FFilesInfo.Count;
end;

initialization
  FSyncSingelton := TCriticalSection.Create;

finalization
  F(FUpdaterDB);
  F(FSyncSingelton);

end.
