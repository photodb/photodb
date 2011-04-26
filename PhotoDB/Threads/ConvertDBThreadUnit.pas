unit ConvertDBThreadUnit;

interface

uses
  Windows, Classes, SysUtils, ActiveX, CommonDBSupport, DB, Forms,
  UnitGroupsWork, uConstants, uShellIntegration, UnitDBDeclare, uFileUtils,
  uMemory, uTranslate, uThreadEx, uFrameWizardBase, uDBUtils, uThreadForm;

type
  TConvertDBThread = class(TThreadEx)
  private
    { Private declarations }
    FFileName: string;
    FStringParam: string;
    TableIn: TDataSet;
    TableOut: TDataSet;
    FIntParam: Integer;
    FParamStr: string;
    FForm: TForm;
    FGroupsFounded: TGroups;
    FRegGroups: TGroups;
    FImageOptions: TImageDBOptions;
    NewFileName: string;
    FOwner: TFrameWizardBase;
    ConvertationResult: Boolean;
  protected
    function GetThreadID : string; override;
  public
    procedure Execute; override;
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
    procedure OnDone;
  public
    constructor Create(Form: TThreadForm; Owner: TFrameWizardBase; ADBName: string; ImageOptions: TImageDBOptions);
    destructor Destroy; override;
  end;

var
  BreakConverting: Boolean = False;

implementation

uses
  UnitDBKernel,
  uFrmConvertationProgress;

constructor TConvertDBThread.Create(Form: TThreadForm; Owner: TFrameWizardBase; ADBName: string; ImageOptions: TImageDBOptions);
begin
  inherited Create(Form, Form.StateID);
  BreakConverting := False;
  FFileName := ADBName;
  FForm := Form;
  FOwner := Owner;
  FImageOptions := ImageOptions;
end;

destructor TConvertDBThread.Destroy;
begin
  F(FImageOptions);
  inherited;
end;

procedure TConvertDBThread.Execute;
var
  I, J, Pos: Integer;
  ToFileName: string;
  FileName: string;
  FSpecQuery: TDataSet;
begin
  ConvertationResult := False;
  FreeOnTerminate := True;
  CoInitialize(nil);
  try
    ToFileName := IncludeTrailingBackslash(ExtractFileDir(FFileName)) + GetFileNameWithoutExt(FFileName) + '$';

    ToFileName := ToFileName + '.photodb';

    Log(L('Creating collection'));
    DBKernel.CreateDBbyName(ToFileName);
    Log(L('Creating collection: success!'));

    UpdateImageSettings(ToFileName, FImageOptions);
    Log(L('Update collection configuration is complete!'));

    Log(L('Opening collection'));
    TableIn := GetTable(ToFileName, DB_TABLE_IMAGES);
    try
      TableOut := GetTable(FFileName, DB_TABLE_IMAGES);
      try
        try
          TableOut.Open;
          TableIn.Open;
        except
          on E: Exception do
          begin
            FParamStr := E.message;
            SynchronizeEx(ShowErrorMessage);
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
              TableIn.Post;

            TableIn.Append;
            CopyRecordsW(TableOut, TableIn, True, False, '', FGroupsFounded);
            TableOut.Next;
            if Terminated then
              Break;
          until TableOut.Eof;
        finally
          FreeDS(TableOut);
        end;
      finally
        FreeDS(TableIn);
      end;

      SetText(L('Saving groups') + '...');

      Log(L('Saving groups'));
      SetMaxValue(Length(FGroupsFounded));
      SetPosition(0);
      FRegGroups := GetRegisterGroupListW(FFileName, True, DBKernel.SortGroupsByName);
      try
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
      finally
        FreeGroups(FGroupsFounded);
        FreeGroups(FRegGroups);
      end;
      SetMaxValue(100);
      SetPosition(100);
    except
      on e: Exception do
      begin
        FParamStr := E.message;
        SynchronizeEx(ShowErrorMessage);
        Exit;
      end;
    end;
    CommonDBSupport.TryRemoveConnection(FFileName, True);
    CommonDBSupport.TryRemoveConnection(ToFileName, True);
    if BreakConverting then
      Exit;

    if not DeleteFile(FFileName) then
    begin
      FParamStr := Format(L('Can not delete file %s, maybe he''s busy with another program or process. Will use a different name (file_name_1)'), [FFileName]);
      FIntParam := LINE_INFO_ERROR;
      SynchronizeEx(ShowErrorMessage);
    end;

    // deleting temp and system db files
    FileName := ExtractFileDir(FFileName) + GetFileNameWithoutExt(FFileName) + '.ldb';
    if FileExists(FileName) and not DeleteFile(FileName) then
    begin
      FParamStr := Format(L('Can not delete file %s, maybe he''s busy with another program or process. Will use a different name (file_name_1)'), [FileName]);
      FIntParam := LINE_INFO_ERROR;
      SynchronizeEx(ShowErrorMessage);
    end;

    FFileName := SysUtils.StringReplace(FFileName, '$', '', [RfReplaceAll]);
    NewFileName := IncludeTrailingBackSlash(ExtractFileDir(FFileName)) + GetFileNameWithoutExt(FFileName);
    NewFileName := NewFileName + '.photodb';
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
    ConvertationResult := True;
  finally
    CoUninitialize;
    SynchronizeEx(OnDone);
  end;
end;

procedure TConvertDBThread.OnDone;
begin
  TFrmConvertationProgress(FOwner).OnConvertingStructureEnd(Self, NewFileName, ConvertationResult);
end;

function TConvertDBThread.GetThreadID: string;
begin
  Result := 'ConvertDB';
end;

procedure TConvertDBThread.SetMaxValue(Value: Integer);
begin
  FIntParam := Value;
  SynchronizeEx(SetMaxValueSynch);
end;

procedure TConvertDBThread.SetMaxValueSynch;
begin
  TFrmConvertationProgress(FOwner).TempProgress.MaxValue := FIntParam;
  TFrmConvertationProgress(FOwner).Progress.MaxValue := FIntParam;
end;

procedure TConvertDBThread.SetText(Value: string);
begin
  FStringParam := Value;
  SynchronizeEx(SetTextSynch);
end;

procedure TConvertDBThread.SetTextSynch;
begin
  TFrmConvertationProgress(FOwner).Progress.Text := FStringParam;
end;

procedure TConvertDBThread.SetProgressText(Value: string);
begin
  FStringParam := Value;
  SynchronizeEx(SetProgressTextSynch);
end;

procedure TConvertDBThread.SetProgressTextSynch;
begin
  TFrmConvertationProgress(FOwner).Progress.Text := FStringParam;
end;

procedure TConvertDBThread.SetPositionSynch;
begin
  TFrmConvertationProgress(FOwner).Progress.Position := FIntParam;
  TFrmConvertationProgress(FOwner).TempProgress.Position := FIntParam;
  TFrmConvertationProgress(FOwner).InfoListBox.Repaint;
end;

procedure TConvertDBThread.SetPosition(Value: Integer);
begin
  FIntParam := Value;
  SynchronizeEx(SetPositionSynch);
end;

procedure TConvertDBThread.LogSynch;
begin
  TFrmConvertationProgress(FOwner).WriteLnLine(Self, FStringParam, LINE_INFO_OK);
  TFrmConvertationProgress(FOwner).LbAction.Caption := FStringParam;
end;

procedure TConvertDBThread.Log(Value: string);
begin
  FStringParam := Value;
  SynchronizeEx(LogSynch);
end;

procedure TConvertDBThread.ShowErrorMessage;
begin
  MessageBoxDB(FForm.Handle, Format(L('An error occurred during converting the collection! (%s)'), [FParamStr]), TA('Error'), TD_BUTTON_OK,
    TD_ICON_ERROR);
end;

end.
