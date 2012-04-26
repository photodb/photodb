unit UnitBackUpTableInCMD;

interface

uses
  uMemory,
  Classes,
  SysUtils,
  UnitDBKernel,
  Forms,
  uDBThread,
  uRuntime,
  UnitDBDeclare,
  uConstants,
  uFileUtils,
  uTranslate,
  uSettings,
  uConfiguration;

type
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

implementation

uses
  CMDUnit;

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
begin
  inherited;
  FreeOnTerminate := True;
  Directory := ExcludeTrailingBackslash(GetAppDataDirectory + BackUpFolder);
  CreateDirA(Directory);
  try
    FSOut := TFileStream.Create(Dbname, FmOpenRead or FmShareDenyNone);
    try
      FSIn := TFileStream.Create(IncludeTrailingBackslash(Directory) + ExtractFileName(Dbname), FmOpenWrite or FmCreate);
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
  Settings.WriteDateTime('Options', 'BackUpDateTime', Now)
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
