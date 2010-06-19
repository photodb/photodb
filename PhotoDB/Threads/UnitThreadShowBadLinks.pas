unit UnitThreadShowBadLinks;

interface

uses
  Classes, Language, Dolphin_DB, UnitLinksSupport, DB, SysUtils,
  CommonDBSupport, UnitDBDeclare;

type
  TThreadShowBadLinks = class(TThread)
  private
  FStrParam : String;
  FIntParam : integer;
  fOptions : TShowBadLinksThreadOptions;  
  ProgressInfo : TProgressCallBackInfo;
    { Private declarations }
  protected
    procedure Execute; override;
    procedure DoExit;
    procedure TextOut;
    procedure TextOutEx;
    procedure DoProgress;
  public
    constructor Create(CreateSuspennded: Boolean;
            Options : TShowBadLinksThreadOptions);
  end;

var
  TerminatingShowBadLinks : boolean;

implementation

Uses CmdUnit;

{ TThreadShowBadLinks }

constructor TThreadShowBadLinks.Create(CreateSuspennded: Boolean;
  Options: TShowBadLinksThreadOptions);
begin
 inherited create(true);
 fOptions:=Options;
 if not CreateSuspennded then Resume;
end;

procedure TThreadShowBadLinks.DoExit;
begin
 fOptions.OnEnd(Self);
end;

procedure TThreadShowBadLinks.DoProgress;
begin
 FOptions.OnProgress(Self,ProgressInfo);
end;

procedure TThreadShowBadLinks.Execute;
var
  Table : TDataSet;
  LI : TLinksInfo;
  SN : String;
  LT, i : integer;

  procedure DoError;
  begin
   FStrParam:=Format(TEXT_MES_CURRENT_ITEM_LINK_BAD,[Table.FieldByName('ID').AsInteger,Trim(Table.FieldByname('Name').AsString),SN,LinkType(LT)]);
   FIntParam:=LINE_INFO_WARNING;
   Synchronize(TextOutEx);
  end;

begin
 TerminatingShowBadLinks:=false;
 Table := GetTable;
 try
  Table.Active:=true;
 except
  FIntParam:=LINE_INFO_ERROR;
  FStrParam:=TEXT_MES_ERROR;
  Synchronize(TextOut);
  FreeDS(Table);
  Synchronize(DoExit);
  exit;
 end;                
 FIntParam:=LINE_INFO_OK;
 FStrParam:=TEXT_MES_BAD_LINKS_TABLE_WORKING;
 Synchronize(TextOutEx);
 Table.First;
 Repeat
  //TODO: CMD_Command_Break
  if TerminatingShowBadLinks or CMD_Command_Break then Break;
  FStrParam:=Format(TEXT_MES_CURRENT_ITEM_F,[IntToStr(Table.RecNo),IntToStr(Table.RecordCount),Trim(Table.FieldByname('FFileName').AsString)]);
  ProgressInfo.MaxValue:=Table.RecordCount;
  ProgressInfo.Position:=Table.RecNo;
  Synchronize(DoProgress);
  FIntParam:=LINE_INFO_OK;
  Synchronize(TextOut);
  if Table.FieldByName('Links').AsString<>'' then
  begin
   SetLength(LI,0);
   LI:=ParseLinksInfo(Table.FieldByName('Links').AsString);
   for i:=0 to Length(LI)-1 do
   begin
    SN:=LI[i].LinkName;
    LT:=LI[i].LinkType;
    Case LI[i].LinkType of
    LINK_TYPE_ID     :
     begin
      //no action
     end;
    LINK_TYPE_ID_EXT :
     begin
      if GetImageIDTh(DeCodeExtID(LI[i].LinkValue)).Count=0 then
      DoError;
     end;
    LINK_TYPE_IMAGE  :
     begin
      if not FileExists(LI[i].LinkValue) then
      DoError;
     end;
    LINK_TYPE_FILE   :
     begin
      if not FileExists(LI[i].LinkValue) then
      DoError;
     end;
    LINK_TYPE_FOLDER :
     begin
      if not DirectoryExists(LI[i].LinkValue) then
      DoError;
     end;
    LINK_TYPE_TXT    :
     begin
      //no action
     end;
    LINK_TYPE_HTML   :
     begin
      //no action
     end;
    end;
   end;
  end;

  Table.Next;
 Until Table.Eof;
 FreeDS(Table);
 Sleep(5000);
 Synchronize(DoExit);
end;

procedure TThreadShowBadLinks.TextOut;
begin
 fOptions.WriteLineProc(Self,FStrParam,FIntParam);
end;

procedure TThreadShowBadLinks.TextOutEx;
begin             
 fOptions.WriteLnLineProc(Self,FStrParam,FIntParam);
end;

end.
 