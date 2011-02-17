unit UnitExportThread;

interface

uses
  UnitGroupsWork, Classes, DB, UnitDBKernel, SysUtils, GraphicCrypt, ActiveX,
  win32crc, UnitDBDeclare, uFileUtils, uConstants,
  uTranslate, uDBThread;

Type
  TExportOptions = record
    ExportPrivate : Boolean;
    ExportNoFiles : Boolean;
    ExportRatingOnly : Boolean;
    ExportGroups : boolean;
    ExportCrypt : boolean;
    ExportCryptIfPassFinded : boolean;
    FileName : String;
  end;

type
  ExportThread = class(TDBThread)
  private
    { Private declarations }
    FOptions : TExportOptions;
    TableOut : TDataSet;
    TableIn : TDataSet;
    FIntParam : Integer;
    FStringParam : String;
    FRegGroups : TGroups;
    FGroupsFounded : TGroups;
  protected
    function GetThreadID : string; override;
  public
    procedure Execute; override;
    procedure SetText(Value : String);
    Procedure SetTextA;
    Procedure SetMaxValue(Value : Integer);
    Procedure SetMaxValueA;
    Procedure SetPosition(Value : Integer);
    Procedure SetPositionA;
    Procedure SetProgressText(Value : String);
    Procedure SetProgressTextA;
    Procedure DoExit;
  public
    constructor Create(Options : TExportOptions);
  end;

procedure CopyRecords(OutTable, InTable: TDataSet; ExportGroups : boolean; var GroupsFounded : TGroups);

var
  StopExport : boolean = false;

implementation

uses ExportUnit, CommonDBSupport;

{ ExportThread }

constructor ExportThread.Create(Options: TExportOptions);
begin
  inherited Create(False);
  StopExport := False;
  FOptions := Options;
end;

procedure ExportThread.Execute;
var
  I, J, Pos: Integer;
  FSpecQuery: TDataSet;
  ImageSettings: TImageDBOptions;
begin
  FreeOnTerminate := True;
  try
    SetText(L('Initialization') + '...');
    CoInitialize(nil);
    try
      TableOut := GetTable;

      DBKernel.CreateDBbyName(FOptions.FileName);
      ImageSettings := CommonDBSupport.GetImageSettingsFromTable(DBName);
      CommonDBSupport.UpdateImageSettings(FOptions.FileName, ImageSettings);

      TableIn := GetTable(FOptions.FileName, DB_TABLE_IMAGES);

      try
        TableOut.Open;
        TableIn.Open;
      except
        Exit;
      end;
      try
        SetMaxValue(TableOut.RecordCount);
        TableOut.First;
        Pos := 0;
        if FOptions.ExportGroups then
        begin
          Setlength(FGroupsFounded, 0);
        end;
        repeat
          Pos := Pos + 1;
          if Pos mod 10 = 0 then
          begin
            SetText(Format(L('Item #%s from %s'), [Inttostr(TableOut.RecNo), Inttostr(TableOut.RecordCount)]));
            SetPosition(TableOut.RecNo);
            SetProgressText(TableOut.FieldByName('Name').AsString);
          end;
          if not FOptions.ExportPrivate then
            if TableOut.FieldByName('Access').AsInteger = Db_access_private then
            begin
              TableOut.Next;
              Continue;
            end;
          if not FOptions.ExportNoFiles then
            if not Fileexists(TableOut.FieldByName('FFileName').AsString) then
            begin
              TableOut.Next;
              Continue;
            end;
          if FOptions.ExportRatingOnly then
            if TableOut.FieldByName('Rating').AsInteger = 0 then
            begin
              TableOut.Next;
              Continue;
            end;
          if not FOptions.ExportCrypt then
            if ValidCryptBlobStreamJPG(TableOut.FieldByName('thum')) then
            begin
              TableOut.Next;
              Continue;
            end;
          if FOptions.ExportCrypt then
            if FOptions.ExportCryptIfPassFinded then
              if ValidCryptBlobStreamJPG(TableOut.FieldByName('thum')) then
                if DBKernel.FindPasswordForCryptBlobStream(TableOut.FieldByName('thum')) = '' then
                begin
                  TableOut.Next;
                  Continue;
                end;
          TableIn.Last;
          TableIn.Append;
          CopyRecords(TableOut, TableIn, True, FGroupsFounded);
          TableOut.Next;
          if StopExport then
            Break;
        until TableOut.Eof;

        FreeDS(TableOut);
        FreeDS(TableIn);
        if FOptions.ExportGroups then
        begin
          SetText(L('Saving groups') + '...');
          SetProgressText(TA('Progress... (&%%)'));
          SetMaxValue(Length(FGroupsFounded));
          SetPosition(0);
          FRegGroups := GetRegisterGroupList(True);
          CreateGroupsTableW(FOptions.FileName);
          for I := 0 to Length(FGroupsFounded) - 1 do
          begin
            SetText(Format(L('Saving group: %s'), [FGroupsFounded[I].GroupName]));
            SetPosition(I);
            for J := 0 to Length(FRegGroups) - 1 do
              if FRegGroups[J].GroupCode = FGroupsFounded[I].GroupCode then
              begin
                AddGroupW(FRegGroups[J], FOptions.FileName);
                Break;
              end;
          end;
        end;

        if GetDBType(FOptions.FileName) = DB_TYPE_MDB then
        begin
          FSpecQuery := GetQuery(FOptions.FileName);
          try
            SetSQL(FSpecQuery, 'Update $DB$ Set Comment="" where Comment is null');
            ExecSQL(FSpecQuery);
            SetSQL(FSpecQuery, 'Update $DB$ Set KeyWords="" where KeyWords is null');
            ExecSQL(FSpecQuery);
            SetSQL(FSpecQuery, 'Update $DB$ Set Groups="" where Groups is null');
            ExecSQL(FSpecQuery);
            SetSQL(FSpecQuery, 'Update $DB$ Set Links="" where Links is null');
            ExecSQL(FSpecQuery);
          finally
            FreeDS(FSpecQuery);
          end;
        end;
      except
      end;
    finally
      CoUnInitialize;
    end;
  finally
    Synchronize(DoExit);
  end;
end;

function ExportThread.GetThreadID: string;
begin
  Result := 'ExportDB';
end;

procedure ExportThread.SetMaxValue(Value: Integer);
begin
  FIntParam := Value;
  Synchronize(SetMaxValueA);
end;

procedure ExportThread.SetMaxValueA;
begin
  //TODO: send owner ExportForm.SetProgressMaxValue(FIntParam);
end;

procedure ExportThread.SetPositionA;
begin
  //TODO: send owner ExportForm.SetProgressPosition(FIntParam);
end;

procedure ExportThread.SetPosition(Value: Integer);
begin
  FIntParam := Value;
  Synchronize(SetPositionA);
end;

procedure ExportThread.SetProgressText(Value: string);
begin
  FStringParam := Value;
  Synchronize(SetProgressTextA);
end;

procedure ExportThread.SetProgressTextA;
begin
  // TODO: send owner ExportForm.SetProgressText(FStringParam);
end;

procedure ExportThread.SetText(Value: string);
begin
  FStringParam := Value;
  Synchronize(SetTextA);
end;

procedure ExportThread.SetTextA;
begin
  // TODO: send owner ExportForm.SetRecordText(FStringParam);
end;

procedure ExportThread.DoExit;
begin
  // TODO: send owner ExportForm.DoExit(Self);
end;

procedure CopyRecords(OutTable, InTable: TDataSet; ExportGroups: Boolean; var GroupsFounded: TGroups);
var
  S, Folder: string;
  Crc: Cardinal;
begin
  try
    InTable.FieldByName('Name').AsString := OutTable.FieldByName('Name').AsString;
    InTable.FieldByName('FFileName').AsString := OutTable.FieldByName('FFileName').AsString;
    InTable.FieldByName('Comment').AsString := OutTable.FieldByName('Comment').AsString;
    InTable.FieldByName('DateToAdd').AsDateTime := OutTable.FieldByName('DateToAdd').AsDateTime;
    InTable.FieldByName('Owner').AsString := OutTable.FieldByName('Owner').AsString;
    InTable.FieldByName('Rating').AsInteger := OutTable.FieldByName('Rating').AsInteger;
    InTable.FieldByName('Thum').AsVariant := OutTable.FieldByName('Thum').AsVariant;
    InTable.FieldByName('FileSize').AsInteger := OutTable.FieldByName('FileSize').AsInteger;
    InTable.FieldByName('KeyWords').AsString := OutTable.FieldByName('KeyWords').AsString;
    InTable.FieldByName('StrTh').AsString := OutTable.FieldByName('StrTh').AsString;
    if Fileexists(InTable.FieldByName('FFileName').AsString) then
      InTable.FieldByName('Attr').AsInteger := Db_attr_norm
    else
      InTable.FieldByName('Attr').AsInteger := Db_attr_not_exists;
    InTable.FieldByName('Attr').AsInteger := OutTable.FieldByName('Attr').AsInteger;
    InTable.FieldByName('Collection').AsString := OutTable.FieldByName('Collection').AsString;
    if OutTable.FindField('Groups') <> nil then
    begin
      S := OutTable.FieldByName('Groups').AsString;
      if ExportGroups then
        AddGroupsToGroups(GroupsFounded, EnCodeGroups(S));
      InTable.FieldByName('Groups').AsString := S;
    end;
    InTable.FieldByName('Groups').AsString := OutTable.FieldByName('Groups').AsString;
    InTable.FieldByName('Access').AsInteger := OutTable.FieldByName('Access').AsInteger;
    InTable.FieldByName('Width').AsInteger := OutTable.FieldByName('Width').AsInteger;
    InTable.FieldByName('Height').AsInteger := OutTable.FieldByName('Height').AsInteger;
    InTable.FieldByName('Colors').AsInteger := OutTable.FieldByName('Colors').AsInteger;
    InTable.FieldByName('Rotated').AsInteger := OutTable.FieldByName('Rotated').AsInteger;
    InTable.FieldByName('IsDate').AsBoolean := OutTable.FieldByName('IsDate').AsBoolean;
    if OutTable.FindField('Include') <> nil then
      InTable.FieldByName('Include').AsBoolean := OutTable.FieldByName('Include').AsBoolean;
    if OutTable.FindField('Links') <> nil then
      InTable.FieldByName('Links').AsString := OutTable.FieldByName('Links').AsString;
    if OutTable.FindField('aTime') <> nil then
      InTable.FieldByName('aTime').AsDateTime := OutTable.FieldByName('aTime').AsDateTime;
    if OutTable.FindField('IsTime') <> nil then
      InTable.FieldByName('IsTime').AsBoolean := OutTable.FieldByName('IsTime').AsBoolean;
    if InTable.Fields.FindField('FolderCRC') <> nil then
    begin

      if OutTable.Fields.FindField('FolderCRC') <> nil then
        InTable.FieldByName('FolderCRC').AsInteger := OutTable.FieldByName('FolderCRC').AsInteger
      else
      begin
        Folder := AnsiLowerCase(ExtractFilePath(OutTable.FieldByName('FFileName').AsString));
{$R-}
        CalcStringCRC32(AnsiLowerCase(Folder), Crc);
        InTable.FieldByName('FolderCRC').AsInteger := Crc;
{$R+}
      end;
    end;

    if InTable.Fields.FindField('StrThCRC') <> nil then
    begin
      if OutTable.Fields.FindField('StrThCRC') <> nil then
        InTable.FieldByName('StrThCRC').AsInteger := OutTable.FieldByName('StrThCRC').AsInteger
      else
      begin
{$R-}
        CalcStringCRC32(OutTable.FieldByName('StrTh').AsString, Crc);
        InTable.FieldByName('StrThCRC').AsInteger := Crc;
{$R+}
      end;
    end;

  except
  end;
end;

end.
