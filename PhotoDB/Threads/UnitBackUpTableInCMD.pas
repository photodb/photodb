unit UnitBackUpTableInCMD;

interface

uses
  Classes, SysUtils, Dolphin_DB, Forms, CommonDBSupport,
  UnitDBDeclare, uConstants, uFileUtils, uTranslate;

type
  BackUpTableInCMD = class(TThread)
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

uses CMDUnit;

{ BackUpTableInCMD }

constructor BackUpTableInCMD.Create(Options: TBackUpTableThreadOptions);
begin
  inherited Create(False);
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
  S: string;
begin
  FreeOnTerminate := True;
  S := GetDirectory(Application.ExeName);
  FormatDir(S);
  CreateDirA(GetAppDataDirectory + BackUpFolder);
  try
    FSOut := TFileStream.Create(Dbname, FmOpenRead or FmShareDenyNone);
    try
      FSIn := TFileStream.Create(GetAppDataDirectory + BackUpFolder + ExtractFileName(Dbname), FmOpenWrite or FmCreate);
      try
        FSIn.CopyFrom(FSOut, FSOut.Size);
      finally
        FSIn.Free;
      end;
    finally
      FSOut.Free;
    end;
  except
    on e : Exception do
    begin
      FStrParam := TA('Error') + ': ' + e.Message;
      FIntParam := LINE_INFO_ERROR;
      Synchronize(TextOut);
      Synchronize(DoExit);
      Exit;
    end;
  end;
  FStrParam := TA('Backup process successfully ended.', 'BackUp');
  FIntParam := LINE_INFO_OK;
  Synchronize(TextOut);
  Synchronize(DoExit);
  DBkernel.WriteDateTime('Options', 'BackUpDateTime', Now)
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
