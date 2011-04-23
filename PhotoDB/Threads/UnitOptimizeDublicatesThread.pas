unit UnitOptimizeDublicatesThread;

interface

uses
  Classes, UnitLinksSupport, DB, SysUtils,
  CommonDBSupport, CmpUnit, UnitGroupsWork, win32crc, uFileUtils,
  UnitDBDeclare, uMemory, uConstants, uDBTypes, uDBBaseTypes,
  uTranslate, uDBThread;

type
  TThreadOptimizeDublicates = class(TDBThread)
  private
    { Private declarations }
    FStrParam: string;
    FIntParam: Integer;
    FOptions: TOptimizeDublicatesThreadOptions;
    ProgressInfo: TProgressCallBackInfo;
  protected
    function GetThreadID : string; override;
    procedure Execute; override;
    procedure DoExit;
    procedure TextOut;
    procedure TextOutEx;
    procedure DoProgress;
  public
    constructor Create(Options: TOptimizeDublicatesThreadOptions);
  end;

var
  TerminatingOptimizeDublicates: boolean;

implementation

uses CMDUnit;

{ TThreadOptimizeDublicates }

constructor TThreadOptimizeDublicates.Create(Options: TOptimizeDublicatesThreadOptions);
begin
  inherited Create(Options.OwnerForm, False);
  FOptions := Options;
end;

procedure TThreadOptimizeDublicates.DoExit;
begin
  FOptions.OnEnd(Self);
end;

procedure TThreadOptimizeDublicates.DoProgress;
begin
  FOptions.OnProgress(Self,ProgressInfo);
end;

procedure TThreadOptimizeDublicates.Execute;
var
  Table, SetQuery: TDataSet;
  FileName, Groups, Links, KeyWords, Comment, S, Folder, SQLText, SetStr: string;
  StrTh: AnsiString;
  I, ID, FileSize, Rating, Access, Paramno, RecordCount, Attr: Integer;
  Query: TDataSet;
  AFile: string;
  Include, Locked, Cont, FE: Boolean;
  Crc: Cardinal;
  FromDB: string;
  F: file;
  WideSearch: Boolean;

  procedure DoUpdate;
  var
    I: Integer;
  begin
    FStrParam := Format(L('Record #%d [%s] is updated'), [Table.FieldByName('ID').AsInteger,
      Trim(Table.FieldByname('Name').AsString)]);
    FIntParam := LINE_INFO_OK;
    SynchronizeEx(TextOutEx);
    Query.First;
    KeyWords := '';
    Query.First;
    for I := 1 to Query.RecordCount do
    begin
      FStrParam := L('Info is merged');
      FIntParam := LINE_INFO_INFO;
      SynchronizeEx(TextOutEx);

      FStrParam := IntToStr(Query.FieldByName('ID').AsInteger) + ' [' + Trim(Query.FieldByName('FFileName').AsString)
        + ']';
      FIntParam := LINE_INFO_PLUS;
      SynchronizeEx(TextOutEx);
      Query.Next;
    end;
  end;

  function NextParam: Integer;
  begin
    Result := Paramno;
    Inc(Paramno);
  end;

  procedure DeleteRecordByID(ID: Integer);
  var
    DelQuery: TDataSet;
  begin
    DelQuery := GetQuery;
    try
      SetSQL(DelQuery, 'DELETE FROM $DB$ WHERE ID = ' + IntToStr(ID));
      try
        ExecSQL(DelQuery);
      except
      end;
    finally
      FreeDS(DelQuery);
    end;
  end;

  procedure LockFile;
  begin
    if not FE then
      Exit;
    Assignfile(F, FileName);
    Locked := False;
    try
      Reset(F);
      Locked := True;
    except
      Locked := False;
    end;
  end;

  procedure UnLockFile;
  begin
    if not FE then
      Exit;
    try
      if Locked then
        System.Close(F);
    except
    end;
    Locked := False;
  end;

begin

  Locked := False;
  TerminatingOptimizeDublicates := False;
  Table := GetQuery;
  try
    SetSQL(Table, 'Select ID, StrTh, FFileName, Name From $DB$ ORDER BY ID');
    try
      Table.Active := True;
      RecordCount := CommonDBSupport.GetRecordsCount(Dbname);
    except
      FStrParam := TA('Error');
      SynchronizeEx(TextOut);
      SynchronizeEx(DoExit);
      Exit;
    end;
    Table.First;
    WideSearch := False;
    repeat
      if TerminatingOptimizeDublicates or CMD_Command_Break then
        Break;

      FStrParam := Format(L('Current item: %s from %s [%s]'), [IntToStr(Table.RecNo), IntToStr(RecordCount),
        Trim(Table.FieldByname('Name').AsString)]);
      FIntParam := LINE_INFO_PROGRESS;
      SynchronizeEx(TextOut);

      ProgressInfo.MaxValue := Table.RecordCount;
      ProgressInfo.Position := Table.RecNo;
      SynchronizeEx(DoProgress);

      Query := GetQuery;
      try
        Paramno := 0;

        if WideSearch then
          FromDB := '$DB$'
        else
          FromDB := '(Select * from $DB$ where StrThCrc=:StrThCrc)';

        SetSQL(Query, 'SELECT * FROM ' + FromDB + ' WHERE StrTh = :StrTh ORDER BY ID');
        SetIntParam(Query, Nextparam, StringCRC(Table.FieldByName('StrTh').AsAnsiString));
        if not WideSearch then
          SetAnsiStrParam(Query, Nextparam, Table.FieldByName('StrTh').AsAnsiString);

        Query.Open;

        if Query.RecordCount < 2 then
        begin
          if (Query.RecordCount = 0) and not WideSearch then
          begin
            FStrParam := TA('Warning');
            FIntParam := LINE_INFO_INFO;
            SynchronizeEx(TextOutEx);
            FStrParam := Format(L('Item %d not foud by ID -> advanced search'), [Table.FieldByName('ID').AsInteger]);
            FIntParam := LINE_INFO_WARNING;
            SynchronizeEx(TextOutEx);
            WideSearch := True;
            Continue;
          end;
          if (Query.RecordCount = 0) and WideSearch then
          begin
            FStrParam := TA('Error');
            FIntParam := LINE_INFO_INFO;
            SynchronizeEx(TextOutEx);

            FStrParam := Format(L('Item %d not found! [%s]'), [Table.FieldByName('ID').AsInteger,
              Table.FieldByName('FFileName').AsString]);
            FIntParam := LINE_INFO_ERROR;
            SynchronizeEx(TextOutEx);
            WideSearch := False;
          end;

          Table.Next;
          Continue;
        end;
        WideSearch := False;
        Query.First;
        Cont := False;
        FileSize := Query.FieldByName('FileSize').AsInteger;
        for I := 1 to Query.RecordCount do
        begin
          if FileSize <> Query.FieldByName('FileSize').AsInteger then
          begin
            Table.Next;
            Cont := True;
            Break;
          end;
          Query.Next;
        end;
        if Cont then
          Continue;

        // Filesizes and StrTh equal - its dublicates!
        // Finding Real FileName ( min(ID) and FileExists )

        DoUpdate;

        // FileName + min(ID)
        Query.First;
        FileName := Query.FieldByName('FFileName').AsString;
        ID := Query.FieldByName('ID').AsInteger;
        StrTh := Query.FieldByName('StrTh').AsAnsiString;
        FE := False;
        for I := 1 to Query.RecordCount do
        begin
          if FileExistsSafe(Query.FieldByName('FFileName').AsString) then
          begin
            FileName := Query.FieldByName('FFileName').AsString;
            StrTh := Query.FieldByName('StrTh').AsAnsiString;
            ID := Query.FieldByName('ID').AsInteger;
            FE := True;
            Break;
          end;
          Query.Next;
        end;

        // CRC
        Folder := ExtractFileDir(FileName);
        CalcStringCRC32(Folder, Crc);

        // Max Rating
        Query.First;
        Rating := 0;
        for I := 1 to Query.RecordCount do
        begin
          if Query.FieldByName('Rating').AsInteger > Rating then
          begin
            Rating := Query.FieldByName('Rating').AsInteger;
            Break;
          end;
          Query.Next;
        end;

        // KeyWords
        Query.First;
        KeyWords := '';
        for I := 1 to Query.RecordCount do
        begin
          AddWordsA(Query.FieldByName('KeyWords').AsString, KeyWords);
          Query.Next;
        end;

        // Comment
        Query.First;
        Comment := '';
        S := '';
        for I := 1 to Query.RecordCount do
        begin
          if S <> Query.FieldByName('Comment').AsString then
          begin
            if Comment = '' then
              Comment := Query.FieldByName('Comment').AsString
            else
              Comment := Comment + #13 + Query.FieldByName('Comment').AsString;
          end;
          S := Query.FieldByName('KeyWords').AsString;
          Query.Next;
        end;

        // Groups
        Query.First;
        Groups := '';
        for I := 1 to Query.RecordCount do
        begin
          AddGroupsToGroups(Groups, Query.FieldByName('Groups').AsString);
          Query.Next;
        end;

        // Links
        Query.First;
        Links := '';
        for I := 1 to Query.RecordCount do
        begin
          ReplaceLinks('', Query.FieldByName('Links').AsString, Links);
          Query.Next;
        end;

        // Access
        Query.First;
        Access := Db_access_none;
        for I := 1 to Query.RecordCount do
        begin
          if Query.FieldByName('Access').AsInteger = Db_access_private then
          begin
            Access := Db_access_private;
            Break;
          end;
          Query.Next;
        end;

        // Include
        Query.First;
        Include := False;
        for I := 1 to Query.RecordCount do
        begin
          if Query.FieldByName('Include').AsBoolean then
          begin
            Include := True;
            Break;
          end;
          Query.Next;
        end;

        // ATTR

        if FileExistsSafe(FileName) then
          Attr := Db_attr_norm
        else
          Attr := Db_attr_not_exists;

        Paramno := 0;
        SetStr := 'FFileName=:FFileName,';
        SetStr := SetStr + 'Name=:Name,';
        SetStr := SetStr + 'StrTh=:StrTh,';
        SetStr := SetStr + 'StrThCrc=:StrThCrc,';
        SetStr := SetStr + 'KeyWords=:KeyWords,';
        SetStr := SetStr + 'Comment=:Comment,';
        SetStr := SetStr + 'Links=:Links,';
        SetStr := SetStr + 'Groups=:Groups,';
        SetStr := SetStr + 'Access=:Access,';
        SetStr := SetStr + 'Include=:Include,';
        SetStr := SetStr + 'Rating=:Rating,';

        SetStr := SetStr + 'Attr=:Attr,';
        SetStr := SetStr + 'FolderCRC=:FolderCRC';

        SetQuery := GetQuery;
        try
          SQLText := 'Update $DB$ Set ' + SetStr + ' Where ID = ' + IntToStr(ID);
          SetSQL(SetQuery, SQLText);

          SetStrParam(SetQuery, Nextparam, AnsiLowerCase(FileName));
          SetStrParam(SetQuery, Nextparam, ExtractFileName(FileName));
          SetAnsiStrParam(SetQuery, Nextparam, StrTh);
          SetIntParam(SetQuery, Nextparam, Integer(StringCRC(StrTh)));
          SetStrParam(SetQuery, Nextparam, KeyWords);
          SetStrParam(SetQuery, Nextparam, Comment);
          SetStrParam(SetQuery, Nextparam, Links);
          SetStrParam(SetQuery, Nextparam, Groups);
          SetIntParam(SetQuery, Nextparam, Access);
          SetBoolParam(SetQuery, Nextparam, Include);
          SetIntParam(SetQuery, Nextparam, Rating);
          SetIntParam(SetQuery, Nextparam, Attr);
          SetIntParam(SetQuery, Nextparam, Integer(Crc));

          try
            ExecSQL(SetQuery);
          except
            Table.Next;
            Continue;
          end;
        finally
          FreeDS(SetQuery);
        end;

        // DELETING OTHER RECORDS AND FILES!

        Query.First;
        LockFile;
        try
          for I := 1 to Query.RecordCount do
          begin
            if Query.FieldByName('ID').AsInteger <> ID then
            begin
              DeleteRecordByID(Query.FieldByName('ID').AsInteger);
              AFile := Query.FieldByName('FFileName').AsString;
              try
                if FileExistsSafe(AFile) then
                  if AnsiLowerCase(AFile) <> AnsiLowerCase(FileName) then
                    SilentDeleteFile(0, AFile, True, True);
              except
              end;
            end;
            Query.Next;
          end;
        finally
          UnLockFile;
        end;
      finally
        FreeDS(Query);
      end;


      Table.Next;
    until Table.Eof;

  finally
    FreeDS(Table);
  end;
  Sleep(5000);
  SynchronizeEx(DoExit);
end;

function TThreadOptimizeDublicates.GetThreadID: string;
begin
  Result := 'CMD';
end;

procedure TThreadOptimizeDublicates.TextOut;
begin
  FOptions.WriteLineProc(Self, FStrParam, FIntParam);
end;

procedure TThreadOptimizeDublicates.TextOutEx;
begin
  FOptions.WriteLnLineProc(Self, FStrParam, FIntParam);
end;

end.
