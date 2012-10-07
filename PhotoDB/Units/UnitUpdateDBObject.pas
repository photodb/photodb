unit UnitUpdateDBObject;

interface

uses
  Windows,
  Controls,
  Classes,
  Forms,
  SysUtils,
  uScript,
  UnitScripts,
  UnitDBDeclare,
  uMemory,
  UnitDBKernel,
  uRuntime,

  Dmitry.CRC32,
  Dmitry.Utils.Files,

  uDBPopupMenuInfo,
  uConstants,
  uAppUtils,
  uGOM,
  uMemoryEx,
  uTranslate,
  Dolphin_DB,
  uDBForm,
  uSettings,
  uAssociations,
  uLogger,
  SyncObjs,
  uUpdateDBTypes,
  uInterfaceManager,
  StrUtils,
  UnitINI;

type
  TUpdaterDB = class(TObject)
  private
    { Private declarations }
    FProcessScript: TScript;
    ScriptProcessString: string;
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
    FSync: TCriticalSection;
    FIsSaved: Boolean;
    procedure SetAuto(const Value: Boolean);
    procedure SetAutoAnswer(Value: Integer);
    procedure SetUseFileNameScaning(const Value: boolean);
    procedure ProcessFile(var FileName : string);
    function GetForm: TDBForm;
    procedure FoundedEvent(Owner: TObject; FileName: string; Size: Int64);
  public
    NoLimit: Boolean;
    constructor Create;
    destructor Destroy; override;
    function AddFile(FileName: string; Silent: Boolean = False; NoExecute: Boolean = False): Boolean;
    function AddFileEx(FileInfo: TDBPopupMenuInfoRecord; Silent, Critical: Boolean; NoExecute: Boolean = False): Boolean;
    function AddDirectory(Directory: string): Boolean;
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
  DBScriptFunctions,
  CommonDBSupport,
  FormManegerUnit,
  UnitUpdateDB,
  ProgressActionUnit;

var
  FUpdaterDB: TUpdaterDB = nil;
  FSync: TCriticalSection;

function UpdaterDB: TUpdaterDB;
begin
  FSync.Enter;
  try
    if FUpdaterDB = nil then
    begin
      FUpdaterDB := TUpdaterDB.Create;
      FUpdaterDB.LoadWork;
    end;

    Result := FUpdaterDB;
  finally
    FSync.Leave;
  end;
end;

procedure UpdaterObjectSaveWork;
begin
  if FUpdaterDB <> nil then
    FUpdaterDB.SaveWork;
end;

{ TUpdaterDB }

function TUpdaterDB.AddDirectory(Directory: string): Boolean;
var
  Dir: string;
begin
  Dir := Directory;

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
  DirectorySizeThread.Create(Dir, EndDirectorySize, @FTerminate, FoundedEvent, ProcessFile);
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

function TUpdaterDB.AddFile(FileName : string; Silent: Boolean = False; NoExecute: Boolean = False): Boolean;
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

function TUpdaterDB.AddFileEx(FileInfo: TDBPopupMenuInfoRecord; Silent, Critical: Boolean; NoExecute: Boolean = False): Boolean;
var
  FileSize: Int64;
  FileName: string;
  Info: TDBPopupMenuInfoRecord;
begin
  Result := False;
  if DBTerminating then
    Exit;

  FileName := FileInfo.FileName;
  ProcessFile(FileName);
  FileInfo.FileName := FileName;

  if Silent or (FileExistsSafe(FileName) and IsGraphicFile(FileName)) then
    if not(FileExistsInFileList(FileName)) then
    begin
      FileSize := GetFileSizeByName(FileName);
      Inc(FmaxSize, FileSize);

      Info := FileInfo.Copy;
      Info.FileSize := FileSize;
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
            I.UpdaterAddFileSizes(FileSize);
          end;
        end
      );

      if Auto and not NoExecute then
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

constructor TUpdaterDB.Create;
begin
  FIsSaved := False;
  FSync := TCriticalSection.Create;
  FFilesInfo := TDBPopupMenuInfo.Create;
  ScriptProcessString := Include('Scripts\Adding_AddFile.dbini');
  FProcessScript := TScript.Create(nil, '');
  FProcessScript.Description := 'Add File script';

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
  F(FProcessScript);
  F(FFilesInfo);
  F(FSync);
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
      EventInfo.Name := AnsiLowerCase(FFilesInfo[I].FileName);
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

procedure TUpdaterDB.ProcessFile(var FileName: string);
var
  C: Integer;
begin
  SetNamedValueStr(FProcessScript, '$File', FileName);
  ExecuteScript(nil, FProcessScript, ScriptProcessString, C, nil);
  FileName := GetNamedValueString(FProcessScript, '$File');
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
    I: Integer;
    DBPrefix: string;
    ProgressWindow: TProgressActionForm;
    T: Cardinal;
    Reg: TBDRegistry;

    procedure AddFileToList(FileName: string);
    var
      FileSize: Int64;
      Info: TDBPopupMenuInfoRecord;
    begin
      ProcessFile(FileName);

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
    ProgressWindow := GetProgressWindow;
    try
      C := Settings.ReadInteger('Updater_' + DBPrefix, 'Counter', 0);
      ProgressWindow.OneOperation := True;
      ProgressWindow.MaxPosCurrentOperation := C;
      ProgressWindow.XPosition := 0;
      ProgressWindow.SetAlternativeText(TA('Wait until the program is restore the work', 'Updater'));
      ProgressWindow.CanClosedByUser := True;
      if C > 10 then
        ProgressWindow.Show;

      T := GetTickCount;
      Reg := Settings.GetSection('Updater_' + DBPrefix);
      for I := 0 to C - 1 do
      begin
        if ProgressWindow.Closed then
          Break;
        if I mod 50 = 0 then
        begin
          ProgressWindow.XPosition := I;
          ProgressWindow.Repaint;
        end;
        if GetTickCount - T > 100 then
        begin
          Application.ProcessMessages;
          T := GetTickCount;
        end;
        AddFileToList(Reg.ReadString('File' + IntToStr(I)));
      end;

    finally
      R(ProgressWindow);
    end;
  end
  );
  if C > 0 then
    Execute;
end;

procedure TUpdaterDB.SaveWork;
var
  I: Integer;
  DBPrefix: string;
  Reg: TBDRegistry;
begin
  if FIsSaved then
    Exit;

  FIsSaved := True;

  DBPrefix := ExtractFileName(dbname) + IntToStr(StringCRC(dbname));
  Settings.WriteInteger('Updater_' + DBPrefix, 'Counter', FFilesInfo.Count);
  Reg := Settings.GetSection('Updater_' + DBPrefix);

  for I := 0 to FFilesInfo.Count - 1 do
    Reg.WriteString('File' + IntToStr(I), FFilesInfo[I].FileName);
end;

function TUpdaterDB.GetCount: Integer;
begin
  Result := FFilesInfo.Count;
end;

initialization
  FSync := TCriticalSection.Create;

finalization
  F(FUpdaterDB);
  F(FSync);

end.
