unit ConvertDBThreadUnit;

interface

uses
  Windows, Classes, SysUtils, ActiveX, CommonDBSupport, DB, Forms,
  UnitGroupsWork, uConstants, uShellIntegration, UnitDBDeclare, uFileUtils,
  uMemory, uTranslate, uDBThread;

type
  TConvertDBThread = class(TDBThread)
  private
    { Private declarations }
    FFileName: string;
    FStringParam: string;
    FToMDB: Boolean;
    TableIn: TDataSet;
    TableOut: TDataSet;
    FIntParam: Integer;
    FParamStr: string;
    FForm: TForm;
    FGroupsFounded: TGroups;
    FRegGroups: TGroups;
    FImageOptions: TImageDBOptions;
    NewFileName: string;
  protected
    function GetThreadID : string; override;
  public
    procedure Execute; override;
    procedure DoExit;
    procedure SetMaxValue(Value: Integer);
    procedure SetMaxValueSynch;
    procedure SetTextSynch;
    procedure SetText(Value: String);
    procedure SetProgressTextSynch;
    procedure SetProgressText(Value: String);
    procedure SetPositionSynch;
    procedure SetPosition(Value: Integer);
    procedure LogSynch;
    procedure Log(Value: String);
    procedure ShowErrorMessage;
  public
    constructor Create(Form: TForm; ADBName: string; ToMDB: Boolean; ImageOptions: TImageDBOptions);
  end;

var
  BreakConverting: Boolean = False;

implementation

uses
  UnitDBkernel, UnitExportThread,
  UnitConvertDBForm, UnitUpdateDB;

constructor TConvertDBThread.Create(Form: TForm; ADBName: string; ToMDB: Boolean; ImageOptions: TImageDBOptions);
begin
  inherited Create(False);
  BreakConverting := False;
  FFileName := ADBName;
  FToMDB := ToMDB;
  FForm := Form;
  FImageOptions := ImageOptions;
end;

procedure TConvertDBThread.Execute;
var
  I, J, Pos: Integer;
  ToFileName: string;
  FileName: string;
  FSpecQuery: TDataSet;
begin
  FreeOnTerminate := True;
  CoInitialize(nil);
  ToFileName := ExtractFileDir(FFileName) + GetFileNameWithoutExt(FFileName) + '$';
  if FToMDB then
    ToFileName := ToFileName + '.photodb'
  else
    ToFileName := ToFileName + '.db';
  Log(L('Creating collection'));
  DBKernel.CreateDBbyName(ToFileName);
  Log(L('Creating collection: success!'));
  if FToMDB then
  begin
    UpdateImageSettings(ToFileName, FImageOptions);
    Log(L('Update collection configuration is complete!'));
  end;
  TableIn := GetTable(ToFileName, DB_TABLE_IMAGES);
  TableOut := GetTable(FFileName, DB_TABLE_IMAGES);
  Log(L('Opening collection'));
  try
    TableOut.Open;
    TableIn.Open;
  except
    on E: Exception do
    begin
      FParamStr := E.message;
      Synchronize(ShowErrorMessage);
      Synchronize(DoExit);
      Exit;
    end;
  end;
  try
    Log(L('Converting the structure...'));
    SetMaxValue(TableOut.RecordCount);
    TableOut.First;
    Pos := 0;
    repeat
      if BreakConverting then
        Break;
      Pos := Pos + 1;
      if Pos mod 10 = 0 then
      begin
        SetText(Format(L('Item #%d from %d'), [TableOut.RecNo, TableOut.RecordCount]));
        SetPosition(TableOut.RecNo);
      end;
      if Pos mod 100 = 0 then
      begin
        TableIn.Post;
      end;
      // TableIn.Last;
      TableIn.Append;
      CopyRecords(TableOut, TableIn, True, FGroupsFounded);
      TableOut.Next;
      if StopExport then
        Break;
    until TableOut.Eof;

    FreeDS(TableOut);
    FreeDS(TableIn);

    SetText(L('Saving groups') + '...');

    Log(L('Saving groups'));
    SetMaxValue(Length(FGroupsFounded));
    SetPosition(0);
    FRegGroups := GetRegisterGroupListW(FFileName, True, DBKernel.SortGroupsByName);
    CreateGroupsTableW(ToFileName);

    AddGroupsToGroups(FGroupsFounded, FRegGroups);

    for I := 0 to Length(FGroupsFounded) - 1 do
    begin
      if BreakConverting then
        Break;
      SetText(Format(L('Saving group: %s'), [FGroupsFounded[I].GroupName]));
      SetPosition(I);
      for J := 0 to Length(FRegGroups) - 1 do
        if FRegGroups[J].GroupCode = FGroupsFounded[I].GroupCode then
        begin
          AddGroupW(FRegGroups[J], ToFileName);
          Break;
        end;
    end;
    SetMaxValue(100);
    SetPosition(100);
  except
  end;
  CommonDBSupport.TryRemoveConnection(FFileName, True);
  CommonDBSupport.TryRemoveConnection(ToFileName, True);
  try
    SilentDeleteFile(0, FFileName, True);
  except
    FParamStr := Format(L('Can not delete file %s, maybe he''s busy with another program or process. Will use a different name (file_name_1)'), [FFileName]);
    FIntParam := LINE_INFO_ERROR;
    Synchronize(ShowErrorMessage);
  end;

  try
    // deleting temp and system db files

    FileName := ExtractFileDir(FFileName) + GetFileNameWithoutExt(FFileName) + '.ldb';
    if FileExistsSafe(FileName) then
      SilentDeleteFile(0, FileName, True);

  except
    on E: Exception do
    begin
      FParamStr := E.message;
      FIntParam := LINE_INFO_ERROR;
      Synchronize(ShowErrorMessage);
    end;
  end;

  FFileName := SysUtils.StringReplace(FFileName, '$', '', [RfReplaceAll]);

  NewFileName := ExtractFileDir(FFileName) + GetFileNameWithoutExt(FFileName);
  if FToMDB then
    NewFileName := NewFileName + '.photodb'
  else
    NewFileName := NewFileName + '.db';

  RenameFile(ToFileName, NewFileName);

  if AnsiLowerCase(FFileName) = AnsiLowerCase(Dbname) then
  begin
    Dbname := NewFileName;
    DBKernel.SetDataBase(NewFileName);
  end;
  DBKernel.MoveDB(FFileName, NewFileName);

  FSpecQuery := GetQuery(NewFileName);
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
  Synchronize(DoExit);
end;

function TConvertDBThread.GetThreadID: string;
begin
  Result := 'ConvertDB';
end;

procedure TConvertDBThread.DoExit;
begin
  CoUnInitialize;
  TFormConvertingDB(FForm).OnConvertingStructureEnd(Self, NewFileName);
end;

procedure TConvertDBThread.SetMaxValue(Value: Integer);
begin
  FIntParam := Value;
  Synchronize(SetMaxValueSynch);
end;

procedure TConvertDBThread.SetMaxValueSynch;
begin
  TFormConvertingDB(FForm).TempProgress.MaxValue := FIntParam;
  TFormConvertingDB(FForm).Progress.MaxValue := FIntParam;
end;

procedure TConvertDBThread.SetText(Value: string);
begin
  FStringParam := Value;
  Synchronize(SetTextSynch);
end;

procedure TConvertDBThread.SetTextSynch;
begin
  TFormConvertingDB(FForm).Progress.Text := FStringParam;
end;

procedure TConvertDBThread.SetProgressText(Value: string);
begin
  FStringParam := Value;
  Synchronize(SetProgressTextSynch);
end;

procedure TConvertDBThread.SetProgressTextSynch;
begin
  TFormConvertingDB(FForm).Progress.Text := FStringParam;
end;

procedure TConvertDBThread.SetPositionSynch;
begin
  TFormConvertingDB(FForm).Progress.Position := FIntParam;
  TFormConvertingDB(FForm).TempProgress.Position := FIntParam;
  TFormConvertingDB(FForm).InfoListBox.Repaint;
end;

procedure TConvertDBThread.SetPosition(Value: Integer);
begin
  FIntParam := Value;
  Synchronize(SetPositionSynch);
end;

procedure TConvertDBThread.LogSynch;
begin
  TFormConvertingDB(FForm).WriteLnLine(Self, FStringParam, LINE_INFO_OK);
  TFormConvertingDB(FForm).Label7.Caption := FStringParam;
end;

procedure TConvertDBThread.Log(Value: string);
begin
  FStringParam := Value;
  Synchronize(LogSynch);
end;

procedure TConvertDBThread.ShowErrorMessage;
begin
  MessageBoxDB(FForm.Handle, Format(L('An error occurred during converting the collection! (%s)'), [FParamStr]), TA('Error'), TD_BUTTON_OK,
    TD_ICON_ERROR);
end;

end.
