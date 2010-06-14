unit UnitExportThread;

interface

uses
  UnitGroupsWork, Classes, DB, dolphin_db, SysUtils, GraphicCrypt, ActiveX,
   win32crc, UnitDBDeclare;

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
  ExportThread = class(TThread)
  private
    FOptions : TExportOptions;
    TableOut : TDataSet;
    TableIn : TDataSet;
    FIntParam : Integer;
    FStringParam : String;
    FRegGroups : TGroups;
    FGroupsFounded : TGroups;
    { Private declarations }
  protected
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
//    Procedure CopyRecordsW(OutTable, InTable : TDataSet);
  public
    constructor Create(CreateSuspennded: Boolean; Options : TExportOptions);
  end;

procedure CopyRecords(OutTable, InTable: TDataSet; ExportGroups : boolean; var GroupsFounded : TGroups);

var
  StopExport : boolean = false;

implementation

uses ExportUnit, Language, CommonDBSupport;

{ ExportThread }

constructor ExportThread.Create(CreateSuspennded: Boolean;
  Options: TExportOptions);
begin
 Inherited Create(True);
 StopExport:=false;
 fOptions := Options;
 If not CreateSuspennded then Resume;
end;

procedure ExportThread.Execute;
Var
  i, j, pos : Integer;
  fSpecQuery : TDataSet;
  ImageSettings : TImageDBOptions;
begin
 FreeOnTerminate:=true;
 SetText(TEXT_MES_INITIALIZATION+'...');     
 CoInitialize(nil);
 TableOut := GetTable;
 DBKernel.CreateDBbyName(FOptions.FileName);     

 ImageSettings:=CommonDBSupport.GetImageSettingsFromTable(DBName);
 CommonDBSupport.UpdateImageSettings(FOptions.FileName,ImageSettings);

 TableIn := GetTable(FOptions.FileName,DB_TABLE_IMAGES);



 try
  TableOut.Open;
  TableIn.Open;
 except
  Synchronize(DoExit);
  Exit;
 end;
 try
  SetMaxValue(TableOut.RecordCount);
  TableOut.First;
  pos:=0;
  if FOptions.ExportGroups then
  begin
   Setlength(FGroupsFounded,0);
  end;
  Repeat
   pos:=pos+1;
   if pos mod 10=0 then
   begin
    SetText(Format(TEXT_MES_REC_FROM_RECS_FORMAT,[inttostr(TableOut.RecNo),inttostr(TableOut.RecordCount)]));
    SetPosition(TableOut.RecNo);
    SetProgressText(TableOut.FieldByName('Name').AsString);
   end;
   if not FOptions.ExportPrivate then
   if TableOut.FieldByName('Access').AsInteger=db_access_private then
   begin
    TableOut.Next;
    Continue;
   end;
   if not FOptions.ExportNoFiles then
   if not fileexists(TableOut.FieldByName('FFileName').AsString) then
   begin
    TableOut.Next;
    Continue;
   end;
   if FOptions.ExportRatingOnly then
   if TableOut.FieldByName('Rating').AsInteger=0 then
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
   if DBKernel.FindPasswordForCryptBlobStream(TableOut.FieldByName('thum'))='' then
   begin
    TableOut.Next;
    Continue;
   end;
   TableIn.Last;
   TableIn.Append;
   CopyRecords(TableOut,TableIn,true,FGroupsFounded);
   TableOut.Next;
   if StopExport then break;
  Until TableOut.Eof;
  FlushBuffers(TableIn);

  FreeDS(TableOut);
  FreeDS(TableIn);
  if FOptions.ExportGroups then
  begin
   SetText(TEXT_MES_SAVING_GROUPS+'...');
   SetProgressText(TEXT_MES_PROGRESS_PR);
   SetMaxValue(length(FGroupsFounded));
   SetPosition(0);
   FRegGroups:=GetRegisterGroupList(True);
   CreateGroupsTableW(FOptions.FileName);
   for i:=0 to length(FGroupsFounded)-1 do
   begin
    SetText(Format(TEXT_MES_SAVING_GROUPS,[FGroupsFounded[i].GroupName]));
    SetPosition(i);
    for j:=0 to length(FRegGroups)-1 do
    if FRegGroups[j].GroupCode=FGroupsFounded[i].GroupCode then
    begin
     AddGroupW(FRegGroups[j],FOptions.FileName);
     Break;
    end;
   end;
  end;

 if GetDBType(FOptions.FileName)=DB_TYPE_MDB then
 begin
  fSpecQuery:=GetQuery(FOptions.FileName);
  try
   SetSQL(fSpecQuery,'Update '+GetDefDBName+' Set Comment="" where Comment is null');
   ExecSQL(fSpecQuery);
   SetSQL(fSpecQuery,'Update '+GetDefDBName+' Set KeyWords="" where KeyWords is null');
   ExecSQL(fSpecQuery);
   SetSQL(fSpecQuery,'Update '+GetDefDBName+' Set Groups="" where Groups is null');
   ExecSQL(fSpecQuery);
   SetSQL(fSpecQuery,'Update '+GetDefDBName+' Set Links="" where Links is null');
   ExecSQL(fSpecQuery);
  finally
   FreeDS(fSpecQuery);
  end;
 end;
 
 except
 end;
 Synchronize(DoExit);
end;

procedure ExportThread.SetMaxValue(Value: Integer);
begin
 FIntParam:=Value;
 Synchronize(SetMaxValueA);
end;

procedure ExportThread.SetMaxValueA;
begin
 ExportForm.SetProgressMaxValue(FIntParam);
end;

procedure ExportThread.SetPositionA;
begin
 ExportForm.SetProgressPosition(FIntParam);
end;

procedure ExportThread.SetPosition(Value: Integer);
begin
 FIntParam:=Value;
 Synchronize(SetPositionA);
end;

procedure ExportThread.SetProgressText(Value: String);
begin
 FStringParam:=Value;
 Synchronize(SetProgressTextA);
end;

procedure ExportThread.SetProgressTextA;
begin
 ExportForm.SetProgressText(FStringParam);
end;

procedure ExportThread.SetText(Value: String);
begin
 FStringParam:=Value;
 Synchronize(SetTextA);
end;

procedure ExportThread.SetTextA;
begin
 ExportForm.SetRecordText(FStringParam);
end;

procedure ExportThread.DoExit;
begin
 CoUnInitialize;
 ExportForm.DoExit(Self);
end;

procedure CopyRecords(OutTable, InTable: TDataSet; ExportGroups : boolean; var GroupsFounded : TGroups);
var
  S, folder : String;
  crc : Cardinal;
begin
try
 InTable.FieldByName('Name').AsString:=OutTable.FieldByName('Name').AsString;
 InTable.FieldByName('FFileName').AsString:=OutTable.FieldByName('FFileName').AsString;
 InTable.FieldByName('Comment').AsString:=OutTable.FieldByName('Comment').AsString;
 InTable.FieldByName('DateToAdd').AsDateTime:=OutTable.FieldByName('DateToAdd').AsDateTime;
 InTable.FieldByName('Owner').AsString:=OutTable.FieldByName('Owner').AsString;
 InTable.FieldByName('Rating').AsInteger:=OutTable.FieldByName('Rating').AsInteger;
 InTable.FieldByName('Thum').AsVariant:=OutTable.FieldByName('Thum').AsVariant;
 InTable.FieldByName('FileSize').AsInteger:=OutTable.FieldByName('FileSize').AsInteger;
 InTable.FieldByName('KeyWords').AsString:=OutTable.FieldByName('KeyWords').AsString;
 InTable.FieldByName('StrTh').AsString:=OutTable.FieldByName('StrTh').AsString;
 If fileexists(InTable.FieldByName('FFileName').AsString) then
 InTable.FieldByName('Attr').AsInteger:=db_attr_norm else
 InTable.FieldByName('Attr').AsInteger:=db_attr_not_exists;
 InTable.FieldByName('Attr').AsInteger:=OutTable.FieldByName('Attr').AsInteger;
 InTable.FieldByName('Collection').AsString:=OutTable.FieldByName('Collection').AsString;
 if OutTable.FindField('Groups')<>nil then
 begin
  S:=OutTable.FieldByName('Groups').AsString;
  if ExportGroups then
  AddGroupsToGroups(GroupsFounded,EnCodeGroups(S));
  InTable.FieldByName('Groups').AsString:=S;
 end;
 InTable.FieldByName('Groups').AsString:=OutTable.FieldByName('Groups').AsString;
 InTable.FieldByName('Access').AsInteger:=OutTable.FieldByName('Access').AsInteger;
 InTable.FieldByName('Width').AsInteger:=OutTable.FieldByName('Width').AsInteger;
 InTable.FieldByName('Height').AsInteger:=OutTable.FieldByName('Height').AsInteger;
 InTable.FieldByName('Colors').AsInteger:=OutTable.FieldByName('Colors').AsInteger;
 InTable.FieldByName('Rotated').AsInteger:=OutTable.FieldByName('Rotated').AsInteger;
 InTable.FieldByName('IsDate').AsBoolean:=OutTable.FieldByName('IsDate').AsBoolean;
 if OutTable.FindField('Include')<>nil then
 InTable.FieldByName('Include').AsBoolean:=OutTable.FieldByName('Include').AsBoolean;
 if OutTable.FindField('Links')<>nil then
 InTable.FieldByName('Links').AsString:=OutTable.FieldByName('Links').AsString;
 if OutTable.FindField('aTime')<>nil then
 InTable.FieldByName('aTime').AsDateTime:=OutTable.FieldByName('aTime').AsDateTime;
 if OutTable.FindField('IsTime')<>nil then
 InTable.FieldByName('IsTime').AsBoolean:=OutTable.FieldByName('IsTime').AsBoolean;
 if InTable.Fields.FindField('FolderCRC')<>nil then
 begin

  if OutTable.Fields.FindField('FolderCRC')<>nil then InTable.FieldByName('FolderCRC').AsInteger:=OutTable.FieldByName('FolderCRC').AsInteger else
  begin
   folder:=GetDirectory(OutTable.FieldByName('FFileName').AsString);
   AnsiLowerCase(folder);
   UnFormatDir(folder);                  
   {$R-}
   CalcStringCRC32(AnsiLowerCase(folder),crc);
   InTable.FieldByName('FolderCRC').AsInteger:=crc;
   {$R+}
  end;
 end;

 if InTable.Fields.FindField('StrThCRC')<>nil then
 begin
  if OutTable.Fields.FindField('StrThCRC')<>nil then InTable.FieldByName('StrThCRC').AsInteger:=OutTable.FieldByName('StrThCRC').AsInteger else
  begin               
   {$R-}
   CalcStringCRC32(OutTable.FieldByName('StrTh').AsString,crc);
   InTable.FieldByName('StrThCRC').AsInteger:=crc;    
   {$R+}
  end;
 end;

except
end;
end;

end.
