unit UnitThreadShowBadLinks;

interface

uses
  Classes, uDBBaseTypes, uDBTypes, UnitLinksSupport, DB, SysUtils,
  CommonDBSupport, UnitDBDeclare, uDBUtils, uTranslate, uDBThread, ActiveX,
  uFileUtils;

type
  TThreadShowBadLinks = class(TDBThread)
  private
    { Private declarations }
    FStrParam: string;
    FIntParam: Integer;
    FOptions: TShowBadLinksThreadOptions;
    ProgressInfo: TProgressCallBackInfo;
  protected
    function GetThreadID : string; override;
    procedure Execute; override;
    procedure DoExit;
    procedure TextOut;
    procedure TextOutEx;
    procedure DoProgress;
  public
    constructor Create(Options: TShowBadLinksThreadOptions);
  end;

var
  TerminatingShowBadLinks: Boolean;

implementation

Uses CmdUnit;

{ TThreadShowBadLinks }

constructor TThreadShowBadLinks.Create(Options: TShowBadLinksThreadOptions);
begin
  inherited Create(Options.OwnerForm, False);
  FOptions := Options;
end;

procedure TThreadShowBadLinks.DoExit;
begin
  FOptions.OnEnd(Self);
end;

procedure TThreadShowBadLinks.DoProgress;
begin
  FOptions.OnProgress(Self, ProgressInfo);
end;

procedure TThreadShowBadLinks.Execute;
var
  Table: TDataSet;
  LI: TLinksInfo;
  SN: string;
  LT, I: Integer;

  procedure DoError;
  begin
    FStrParam := Format(L('Incorrect link in item #%d [%s]. Link "%s" has type "%s"'), [Table.FieldByName('ID').AsInteger,
      Trim(Table.FieldByname('Name').AsString), SN, LinkType(LT)]);
    FIntParam := LINE_INFO_WARNING;
    SynchronizeEx(TextOutEx);
  end;

begin
  FreeOnTerminate := True;
  try
    CoInitialize(nil);
    try
      TerminatingShowBadLinks := False;
      Table := GetTable;
      try
        try
          Table.Active := True;
        except
          FIntParam := LINE_INFO_ERROR;
          FStrParam := TA('Error');
          SynchronizeEx(TextOut);
          Exit;
        end;
        FIntParam := LINE_INFO_OK;
        FStrParam := TA(
          'Performing search, please wait ... $nl$(on completion of the log will be copied to the clipboard)', 'CMD');
        SynchronizeEx(TextOutEx);
        Table.First;
        repeat
          // TODO: CMD_Command_Break
          if TerminatingShowBadLinks or CMD_Command_Break then
            Break;
          FStrParam := Format(L('Current item: %s from %s [%s]'), [IntToStr(Table.RecNo), IntToStr(Table.RecordCount),
            Trim(Table.FieldByname('FFileName').AsString)]);
          ProgressInfo.MaxValue := Table.RecordCount;
          ProgressInfo.Position := Table.RecNo;
          SynchronizeEx(DoProgress);
          FIntParam := LINE_INFO_OK;
          SynchronizeEx(TextOut);
          if Table.FieldByName('Links').AsString <> '' then
          begin
            SetLength(LI, 0);
            LI := ParseLinksInfo(Table.FieldByName('Links').AsString);
            for I := 0 to Length(LI) - 1 do
            begin
              SN := LI[I].LinkName;
              LT := LI[I].LinkType;
              case LI[I].LinkType of
                LINK_TYPE_ID:
                  begin
                    // no action
                  end;
                LINK_TYPE_ID_EXT:
                  begin
                    if GetImageIDTh(DeCodeExtID(LI[I].LinkValue)).Count = 0 then
                      DoError;
                  end;
                LINK_TYPE_IMAGE:
                  begin
                    if not FileExistsSafe(LI[I].LinkValue) then
                      DoError;
                  end;
                LINK_TYPE_FILE:
                  begin
                    if not FileExistsSafe(LI[I].LinkValue) then
                      DoError;
                  end;
                LINK_TYPE_FOLDER:
                  begin
                    if not DirectoryExists(LI[I].LinkValue) then
                      DoError;
                  end;
                LINK_TYPE_TXT:
                  begin
                    // no action
                  end;
                LINK_TYPE_HTML:
                  begin
                    // no action
                  end;
              end;
            end;
          end;

          Table.Next;
        until Table.Eof;
      finally
        FreeDS(Table);
      end;
      Sleep(5000);
    finally
      CoUninitialize;
    end;
  finally
    SynchronizeEx(DoExit);
  end;
end;

function TThreadShowBadLinks.GetThreadID: string;
begin
  Result := 'CMD';
end;

procedure TThreadShowBadLinks.TextOut;
begin
  FOptions.WriteLineProc(Self, FStrParam, FIntParam);
end;

procedure TThreadShowBadLinks.TextOutEx;
begin
  FOptions.WriteLnLineProc(Self, FStrParam, FIntParam);
end;

end.
