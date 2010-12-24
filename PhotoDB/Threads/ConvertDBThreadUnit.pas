unit ConvertDBThreadUnit;

interface

uses
  Windows, Classes, SysUtils, ActiveX, CommonDBSupport, DB, Forms,
  UnitGroupsWork, uVistaFuncs, uShellIntegration, UnitDBDeclare, uFileUtils;

type
  TConvertDBThread = class(TThread)
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

uses UnitDBkernel, UnitExportThread, Language,
UnitConvertDBForm, UnitUpdateDB;

constructor TConvertDBThread.Create(Form : TForm;
  aDBName: string ; ToMDB : boolean; ImageOptions : TImageDBOptions);
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
  i, j,  pos : integer;
  ToFileName : string;
  FileName : string;
  fSpecQuery : TDataSet;
begin
 FreeOnTerminate:=true;
 CoInitialize(nil);
 ToFileName:=ExtractFileDir(FFileName)+GetFileNameWithoutExt(FFileName)+'$';
 if FToMDB then ToFileName:=ToFileName+'.photodb' else
 ToFileName:=ToFileName+'.db';
 Log(TEXT_MES_CREATING_DB);
 DBKernel.CreateDBbyName(ToFileName);
 Log(TEXT_MES_CREATING_DB_OK);
 if FToMDB then
 begin
  UpdateImageSettings(ToFileName,FImageOptions);
  Log(TEXT_MES_UPDATING_SETTINGS_OK);
 end;
 TableIn := GetTable(ToFileName, DB_TABLE_IMAGES);
 TableOut := GetTable(FFileName, DB_TABLE_IMAGES);
 Log(TEXT_MES_OPENING_DATABASES);
 try
  TableOut.Open;
  TableIn.Open;
 except
  on e : Exception do
  begin
   fParamStr:=e.Message;
   Synchronize(ShowErrorMessage);
   Synchronize(DoExit);
   Exit;
  end;
 end;
 try
  Log(TEXT_MES_CONVERTION_IN_PROGRESS);
  SetMaxValue(TableOut.RecordCount);
  TableOut.First;
  pos:=0;
  Repeat
   if BreakConverting then break;
   pos:=pos+1;
   if pos mod 10=0 then
   begin
    SetText(Format(TEXT_MES_REC_FROM_RECS_FORMAT, [inttostr(TableOut.RecNo), inttostr(TableOut.RecordCount)]));
    SetPosition(TableOut.RecNo);
   end;
   if pos mod 100=0 then
   begin
    TableIn.Post;
   end;
   //TableIn.Last;
   TableIn.Append;
   CopyRecords(TableOut, TableIn, true, FGroupsFounded);
   TableOut.Next;
   if StopExport then break;
  Until TableOut.Eof;

  FreeDS(TableOut);
  FreeDS(TableIn);

  SetText(TEXT_MES_SAVING_GROUPS+'...');

  Log(TEXT_MES_SAVING_GROUPS);
  SetMaxValue(length(FGroupsFounded));
  SetPosition(0);
  FRegGroups:=GetRegisterGroupListW(FFileName, True, DBKernel.SortGroupsByName);
  CreateGroupsTableW(ToFileName);

  AddGroupsToGroups(FGroupsFounded, FRegGroups);

  for i:=0 to length(FGroupsFounded)-1 do
  begin
   if BreakConverting then break;
   SetText(Format(TEXT_MES_SAVING_GROUPS, [FGroupsFounded[i].GroupName]));
   SetPosition(i);
   for j:=0 to length(FRegGroups)-1 do
   if FRegGroups[j].GroupCode=FGroupsFounded[i].GroupCode then
   begin
    AddGroupW(FRegGroups[j], ToFileName);
    Break;
   end;
  end;
  SetMaxValue(100);
  SetPosition(100);
 except
 end;
 CommonDBSupport.TryRemoveConnection(FFileName,true);
 CommonDBSupport.TryRemoveConnection(ToFileName,true);
 try
  SilentDeleteFile(0, FFileName, true);
 except
  fParamStr:=Format(TEXT_MES_CANNOT_DELETE_FILE_NEW_NAME_F,[FFileName]);
  FIntParam:=LINE_INFO_ERROR;
  Synchronize(ShowErrorMessage);
 end;

 try
  //deleting temp and system db files

   FileName:=ExtractFileDir(FFileName)+GetFileNameWithoutExt(FFileName)+'.ldb';
   if FileExists(FileName) then
   SilentDeleteFile(0, FileName, true);

 except
  on e : Exception do
  begin
   fParamStr:=e.Message;
   FIntParam:=LINE_INFO_ERROR;
   Synchronize(ShowErrorMessage);
  end;
 end;

 FFileName:=SysUtils.StringReplace(FFileName,'$','',[rfReplaceAll]);

 NewFileName:=ExtractFileDir(FFileName)+GetFileNameWithoutExt(FFileName);
 if FToMDB then NewFileName:=NewFileName+'.photodb' else
 NewFileName:=NewFileName+'.db';

 RenameFile(ToFileName, NewFileName);

 if AnsiLowerCase(FFileName)=AnsiLowerCase(dbname) then
 begin
  dbname:=NewFileName;
  DBKernel.SetDataBase(NewFileName);
 end;
 DBKernel.MoveDB(FFileName, NewFileName);

  fSpecQuery:=GetQuery(NewFileName);
  try
    SetSQL(fSpecQuery, 'Update $DB$ Set Comment="" where Comment is null');
    ExecSQL(fSpecQuery);
    SetSQL(fSpecQuery, 'Update $DB$ Set KeyWords="" where KeyWords is null');
    ExecSQL(fSpecQuery);
    SetSQL(fSpecQuery, 'Update $DB$ Set Groups="" where Groups is null');
    ExecSQL(fSpecQuery);
    SetSQL(fSpecQuery, 'Update $DB$ Set Links="" where Links is null');
    ExecSQL(fSpecQuery);
  finally
    FreeDS(fSpecQuery);
  end;
  Synchronize(DoExit);
end;

procedure TConvertDBThread.DoExit;
begin
 CoUnInitialize;
 TFormConvertingDB(FForm).OnConvertingStructureEnd(Self, NewFileName);
end;

procedure TConvertDBThread.SetMaxValue(Value: Integer);
begin
 FIntParam:=Value;
 Synchronize(SetMaxValueSynch);
end;

procedure TConvertDBThread.SetMaxValueSynch;
begin
 TFormConvertingDB(FForm).TempProgress.MaxValue:=FIntParam;
 TFormConvertingDB(FForm).Progress.MaxValue:=FIntParam;
end;

procedure TConvertDBThread.SetText(Value: String);
begin
 FStringParam:=Value;
 Synchronize(SetTextSynch);
end;

procedure TConvertDBThread.SetTextSynch;
begin
 TFormConvertingDB(FForm).Progress.Text:=FStringParam;
end;

procedure TConvertDBThread.SetProgressText(Value: String);
begin
 FStringParam:=Value;
 Synchronize(SetProgressTextSynch);
end;

procedure TConvertDBThread.SetProgressTextSynch;
begin
 TFormConvertingDB(FForm).Progress.Text:=FStringParam;
end;

procedure TConvertDBThread.SetPositionSynch;
begin
 TFormConvertingDB(FForm).Progress.Position:=FIntParam;
 TFormConvertingDB(FForm).TempProgress.Position:=FIntParam;
 TFormConvertingDB(FForm).InfoListBox.Repaint;
end;

procedure TConvertDBThread.SetPosition(Value: Integer);
begin
 FIntParam:=Value;
 Synchronize(SetPositionSynch);
end;

procedure TConvertDBThread.LogSynch;
begin
 TFormConvertingDB(FForm).WriteLnLine(Self,FStringParam,LINE_INFO_OK);
 TFormConvertingDB(FForm).Label7.Caption:=FStringParam;
end;

procedure TConvertDBThread.Log(Value: String);
begin
 FStringParam:=Value;
 Synchronize(LogSynch);
end;

procedure TConvertDBThread.ShowErrorMessage;
begin
 MessageBoxDB(FForm.Handle, Format(TEXT_MES_CONVERTING_ERROR_F, [fParamStr]),
      TEXT_MES_ERROR, TD_BUTTON_OK, TD_ICON_ERROR);
end;

end.
