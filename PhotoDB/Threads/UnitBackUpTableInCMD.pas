unit UnitBackUpTableInCMD;

interface

uses
  System.Classes,
  System.SysUtils,
  Vcl.Forms,

  Dmitry.Utils.Files,

  UnitDBDeclare,

  uMemory,
  uDBThread,
  uDBForm,
  uDBContext,
  uDBManager,
  uRuntime,
  uConstants,
  uTranslate,
  uSettings,
  uConfiguration;

type
  TBackUpTableThreadOptions = record
    OwnerForm: TDBForm;
    FileName: string;
    OnEnd: TNotifyEvent;
    WriteLineProc: TWriteLineProcedure;
    WriteLnLineProc: TWriteLineProcedure;
  end;

  BackUpTableInCMD = class(TDBThread)
  private
    { Private declarations }
    FStrParam: string;
    FIntParam: Integer;
    FOptions: TBackUpTableThreadOptions;
  protected
    procedure Execute; override;
    procedure DoExit;
    procedure TextOut;
    procedure TextOutEx;
  public
    constructor Create(Options: TBackUpTableThreadOptions);
  end;

procedure CreateBackUpForCollection;

implementation

procedure CreateBackUpForCollection;
var
   Options: TBackUpTableThreadOptions;
begin
  if Now - AppSettings.ReadDateTime('Options', 'BackUpDateTime', 0) > AppSettings.ReadInteger('Options', 'BackUpdays', 7) then
  begin
    Options.WriteLineProc := nil;
    Options.WriteLnLineProc := nil;
    Options.OnEnd := nil;
    Options.FileName := DBManager.DBContext.CollectionFileName;
    Options.OwnerForm := nil;
    BackUpTableInCMD.Create(Options);
  end;
end;

{ BackUpTableInCMD }

constructor BackUpTableInCMD.Create(Options: TBackUpTableThreadOptions);
begin
  inherited Create(Options.OwnerForm, False);
  FOptions := Options;
end;

procedure BackUpTableInCMD.DoExit;
begin
  if Assigned(FOptions.OnEnd) then
    FOptions.OnEnd(Self);
end;

procedure BackUpTableInCMD.Execute;
var
  FSIn, FSOut: TFileStream;
  Directory : string;
  Context: IDBContext;
begin
  inherited;
  FreeOnTerminate := True;

  Context := DBManager.DBContext;
  Directory := ExcludeTrailingBackslash(GetAppDataDirectory + BackUpFolder);
  CreateDirA(Directory);
  try
    FSOut := TFileStream.Create(Context.CollectionFileName, FmOpenRead or FmShareDenyNone);
    try
      FSIn := TFileStream.Create(IncludeTrailingBackslash(Directory) + ExtractFileName(Context.CollectionFileName), FmOpenWrite or FmCreate);
      try
        FSIn.CopyFrom(FSOut, FSOut.Size);
      finally
        F(FSIn);
      end;
    finally
      F(FSOut);
    end;
  except
    on e: Exception do
    begin
      FStrParam := TA('Error') + ': ' + e.Message;
      FIntParam := LINE_INFO_ERROR;
      SynchronizeEx(TextOut);
      SynchronizeEx(DoExit);
      Exit;
    end;
  end;
  FStrParam := TA('Backup process successfully ended.', 'BackUp');
  FIntParam := LINE_INFO_OK;
  SynchronizeEx(TextOut);
  SynchronizeEx(DoExit);
  AppSettings.WriteDateTime('Options', 'BackUpDateTime', Now)
end;

procedure BackUpTableInCMD.TextOut;
begin
  if Assigned(FOptions.WriteLineProc) then
    FOptions.WriteLineProc(Self, FStrParam, FIntParam);
end;

procedure BackUpTableInCMD.TextOutEx;
begin
  if Assigned(FOptions.WriteLnLineProc) then
    FOptions.WriteLnLineProc(Self, FStrParam, FIntParam);
end;

end.
