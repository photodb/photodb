unit UnitBackUpTableInCMD;

interface

uses
  Classes, Language, SysUtils, Dolphin_DB, Forms, CommonDBSupport,
  UnitDBDeclare, uConstants, uFileUtils;

type
  BackUpTableInCMD = class(TThread)
  private
    FStrParam : String;
    FIntParam : integer;
    fOptions : TBackUpTableThreadOptions;
    { Private declarations }
  protected
    procedure Execute; override;
    procedure DoExit;
    procedure TextOut;
    procedure TextOutEx;
  public
    constructor Create(CreateSuspennded: Boolean;
            Options : TBackUpTableThreadOptions);
  end;

implementation

uses CMDUnit;

{ BackUpTableInCMD }

constructor BackUpTableInCMD.Create(CreateSuspennded: Boolean;
  Options: TBackUpTableThreadOptions);
begin
 inherited Create(true);
 fOptions:=Options;
 if not CreateSuspennded then Resume;
end;

procedure BackUpTableInCMD.DoExit;
begin
 fOptions.OnEnd(Self);
// CMDForm.OnEnd(Self);
end;

procedure BackUpTableInCMD.Execute;
var
  FSIn, FSOut : TFileStream;
  s : string;
begin
 s:=GetDirectory(Application.ExeName);
 FormatDir(S);
 CreateDirA(GetAppDataDirectory+BackUpFolder);
 try
  FSOut := TFileStream.Create(dbname,fmOpenRead);
  FSIn := TFileStream.Create(GetAppDataDirectory+BackUpFolder+ExtractFileName(dbname),fmOpenWrite or fmCreate);
  FSIn.CopyFrom(FSOut,FSOut.Size);
  FSIn.Free;
  FSOut.Free;
 except
  FStrParam:=TEXT_MES_ERROR;
  FIntParam:=LINE_INFO_ERROR;
  Synchronize(TextOut);
  Synchronize(DoExit);
  exit;
 end;
 FStrParam:=TEXT_MES_BACKUP_SUCCESS;
 FIntParam:=LINE_INFO_OK;
 Synchronize(TextOut);
 Synchronize(DoExit);
 DBkernel.WriteDateTime('Options','BackUpDateTime',Now())
end;

procedure BackUpTableInCMD.TextOut;
begin
 fOptions.WriteLineProc(Self,FStrParam,FIntParam);
end;

procedure BackUpTableInCMD.TextOutEx;
begin
 fOptions.WriteLnLineProc(Self,FStrParam,FIntParam);
end;

end.
