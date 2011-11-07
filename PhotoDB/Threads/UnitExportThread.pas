unit UnitExportThread;

interface

uses
  UnitGroupsWork, Classes, DB, UnitDBKernel, SysUtils, GraphicCrypt, ActiveX,
  UnitDBDeclare, uFileUtils, uConstants, uDBUtils, uDBForm, uMemory, uRuntime,
  uTranslate, uDBThread;

Type
  TExportOptions = record
    OwnerForm: TDBForm;
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

var
  StopExport : Boolean = false;

implementation

uses
  ExportUnit, CommonDBSupport;

{ ExportThread }

constructor ExportThread.Create(Options: TExportOptions);
begin
  inherited Create(Options.OwnerForm, False);
  StopExport := False;
  FOptions := Options;
end;

procedure ExportThread.Execute;
var
  I, J, Pos: Integer;
  FSpecQuery: TDataSet;
  ImageSettings: TImageDBOptions;
  FRegGroups : TGroups;
begin
  inherited;
  FreeOnTerminate := True;
  try
    SetText(L('Initialization') + '...');
    CoInitialize(nil);
    try
      TableOut := GetTable;

      DBKernel.CreateDBbyName(FOptions.FileName);
      ImageSettings := CommonDBSupport.GetImageSettingsFromTable(DBName);
      try
        CommonDBSupport.UpdateImageSettings(FOptions.FileName, ImageSettings);
      finally
        F(ImageSettings);
      end;

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
          Setlength(FGroupsFounded, 0);

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
            if not FileExistsSafe(TableOut.FieldByName('FFileName').AsString) then
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
          CopyRecordsW(TableOut, TableIn, True, False, '', FGroupsFounded);
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
          try
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
          finally
            FreeGroups(FRegGroups);
          end;
        end;

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
      except
      end;
      TryRemoveConnection(FOptions.FileName, True);
    finally
      CoUnInitialize;
    end;
  finally
    SynchronizeEx(DoExit);
  end;
end;

function ExportThread.GetThreadID: string;
begin
  Result := 'ExportDB';
end;

procedure ExportThread.SetMaxValue(Value: Integer);
begin
  FIntParam := Value;
  SynchronizeEx(SetMaxValueA);
end;

procedure ExportThread.SetMaxValueA;
begin
  TExportForm(OwnerForm).SetProgressMaxValue(FIntParam);
end;

procedure ExportThread.SetPositionA;
begin
  TExportForm(OwnerForm).SetProgressPosition(FIntParam);
end;

procedure ExportThread.SetPosition(Value: Integer);
begin
  FIntParam := Value;
  SynchronizeEx(SetPositionA);
end;

procedure ExportThread.SetProgressText(Value: string);
begin
  FStringParam := Value;
  SynchronizeEx(SetProgressTextA);
end;

procedure ExportThread.SetProgressTextA;
begin
  TExportForm(OwnerForm).SetProgressText(FStringParam);
end;

procedure ExportThread.SetText(Value: string);
begin
  FStringParam := Value;
  SynchronizeEx(SetTextA);
end;

procedure ExportThread.SetTextA;
begin
  TExportForm(OwnerForm).SetRecordText(FStringParam);
end;

procedure ExportThread.DoExit;
begin
  Working := False;
  TExportForm(OwnerForm).Close;
end;

end.
