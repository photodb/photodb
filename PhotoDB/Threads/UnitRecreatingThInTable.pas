unit UnitRecreatingThInTable;

interface

uses
  Classes, Graphics, Jpeg, DB, CommonDBSupport, Dolphin_DB, SysUtils,
  GraphicCrypt, GraphicsCool, UnitDBDeclare, UnitCDMappingSupport; 

type
  RecreatingThInTable = class(TThread)
  private
    FStrParam : String;
    FBoolParam : Boolean;
    FIntParam : integer;
    fOptions : TRecreatingThInTableOptions;
    fRec : TPasswordRecord;
    fCryptFileList : TList;
    ImageOptions : TImageDBOptions;
    ProgressInfo : TProgressCallBackInfo;
    { Private declarations }
  protected
    procedure Execute; override;
    procedure DoExit;
    procedure TextOut;
    procedure TextOutEx;
    procedure GetPass;
    procedure AddPasswordFile(ID: integer; FileName : string);
    procedure AddCryptFileCall;
    procedure GetCryptFileList;
    function GetAvaliableCryptFileList : TArInteger;
    procedure DoProgress;
  public
    constructor Create(CreateSuspennded: Boolean; Options: TRecreatingThInTableOptions);
  end;

var
  RecreatingThInTableTerminating : Boolean;

implementation

{ RecreatingThInTable }

uses CMDUnit, Language, UnitPasswordForm;

procedure RecreatingThInTable.AddCryptFileCall;
begin
 fOptions.AddCryptFileToListProc(self,fRec);
end;

procedure RecreatingThInTable.AddPasswordFile(ID: integer; FileName : string);
begin
 fRec.FileName:=FileName;
 fRec.ID:=ID;
 fRec.CRC:=GraphicCrypt.GetPasswordCRCFromCryptGraphicFile(FileName);
 Synchronize(AddCryptFileCall);
end;

constructor RecreatingThInTable.Create(CreateSuspennded: Boolean;
  Options: TRecreatingThInTableOptions);
begin
 inherited create(true);
 fOptions:=Options;
 if not CreateSuspennded then Resume;
end;

procedure RecreatingThInTable.DoExit;
begin
 if Assigned(FOptions.OnEndProcedure) then FOptions.OnEndProcedure(self);
end;

procedure RecreatingThInTable.DoProgress;
begin
 FOptions.OnProgress(Self,ProgressInfo);
end;

procedure RecreatingThInTable.Execute;
var
  Table : TDataSet;
  info : TImageDBRecordA;
  Pass : string;
  Crypted : Boolean;  
  ms : TMemoryStream;
  BF : TBlobField;
  CurrentID : integer;
  CryptFileList : TArInteger;
  i : integer;
  Bmp : TBitmap;
  Jpeg : TJpegImage;
  TableRecordCount : integer;
  Crypting : boolean;
  CRC : Cardinal;

  procedure ProcessCurrentRecord;
  begin
   try
    info:=GetImageIDW(Table.FieldByName('FFileName').AsString,false,true,ImageOptions.ThSize,ImageOptions.DBJpegCompressionQuality);
    if info.IsError then
    begin   
     FStrParam:=Format(TEXT_MES_FAILED_TH_FOR_ITEM,[Trim(Table.FieldByname('Name').AsString),info.ErrorText]);
     FIntParam:=LINE_INFO_ERROR; 
     Synchronize(TextOutEx);
     exit;
    end;
    Table.Edit;
    if info.Jpeg<>nil then
    begin
     if info.Crypt or Crypting then
     begin
      ms:=CryptGraphicImage(info.Jpeg,info.Password);
      BF:=TBlobField(Table.FieldByName('thum'));
      ms.Seek(0,soFromBeginning);
      BF.LoadFromStream(ms);
      ms.free;
     end else
     Table.FieldByName('thum').Assign(info.Jpeg);
    end;
    if info.ImTh<>'' then
    begin
     if Table.FieldByName('StrTh').AsString<>info.ImTh then
     begin
      FStrParam:=Format(TEXT_MES_FIXED_TH_FOR_ITEM,[Trim(Table.FieldByname('Name').AsString)]);
      FIntParam:=LINE_INFO_OK;
      if Crypted then FStrParam:=FStrParam+' *';
      Synchronize(TextOutEx);
      Table.FieldByName('StrTh').AsString:=info.ImTh;
      CRC:=StringCRC(info.ImTh);
      if CRC<>Table.FieldByName('StrThCrc').AsInteger then
      Table.FieldByName('StrThCrc').AsInteger:=Integer(CRC);
     end;
    end;
    info.Jpeg.free;
    FStrParam:=Format(TEXT_MES_RECREATINH_TH_FOR_ITEM_FORMAT,[IntToStr(Table.RecNo),IntToStr(TableRecordCount),Trim(Table.FieldByname('Name').AsString)]);
    if Assigned(fOptions.OnProgress) then
    begin              
     ProgressInfo.MaxValue:=TableRecordCount;
     ProgressInfo.Position:=Table.RecNo;
     ProgressInfo.Information:=TEXT_MES_RECREATING_PREVIEWS;
     ProgressInfo.Terminate:=false;
     Synchronize(DoProgress);
    end;
    FIntParam:=LINE_INFO_OK;
    Synchronize(TextOut);
    Table.Post;
   except
    FStrParam:=Format(TEXT_MES_RECREATINH_TH_FOR_ITEM_FORMAT_ERROR,[Table.FieldByname('Name').AsString]);  
    FIntParam:=LINE_INFO_ERROR;
    Synchronize(TextOut);
   end;
  end;

begin
 RecreatingThInTableTerminating:=false;
 FBoolParam:=true;
 Table := GetTable(fOptions.FileName,DB_TABLE_IMAGES);
 try    
  ImageOptions:=CommonDBSupport.GetImageSettingsFromTable(fOptions.FileName);
  Table.Active:=true;
 except
  FStrParam:=TEXT_MES_RECREATINH_TH_FORMAT_ERROR;
  FIntParam:=LINE_INFO_ERROR;
  Synchronize(TextOut);
  Table.Free;
  Synchronize(DoExit);
  exit;
 end;
 Crypting:=false;
 Table.First;
 TableRecordCount:=Table.RecordCount;
 Repeat
  if RecreatingThInTableTerminating then Break;
  if FileExists(Table.FieldByName('FFileName').AsString) then
  begin

   Crypted:=false;

   if not StaticPath(Table.FieldByName('FFileName').AsString) then
   begin
    FStrParam:=Format(TEXT_MES_RECREATINH_TH_FOR_ITEM_FORMAT_CD_DVD_CANCELED_INFO_F,[IntToStr(Table.RecNo),IntToStr(Table.RecordCount),Trim(Table.FieldByname('Name').AsString)]);
    FIntParam:=LINE_INFO_WARNING;
    Synchronize(TextOutEx); 
    Table.Next;
    Continue;
   end;

   if ValidCryptGraphicFile(Table.FieldByName('FFileName').AsString) then
   begin
    Crypted:=true;
    Pass:=DBKernel.FindPasswordForCryptImageFile(Table.FieldByName('FFileName').AsString);
    if Pass='' then
    begin
     AddPasswordFile(Table.FieldByName('ID').AsInteger,Table.FieldByName('FFileName').AsString);
     FStrParam:=Format(TEXT_MES_RECREATINH_TH_FOR_ITEM_FORMAT_CRYPTED_POSTPONED,[IntToStr(Table.RecNo),IntToStr(Table.RecordCount),Trim(Table.FieldByname('Name').AsString)]);
     FIntParam:=LINE_INFO_WARNING;
     Synchronize(TextOutEx);

     if not GraphicCrypt.ValidCryptBlobStreamJPG(Table.FieldByName('thum')) then
     begin
      FStrParam:=Format(TEXT_MES_RECREATINH_TH_FOR_ITEM_FORMAT_CRYPTED_FIXED,[IntToStr(Table.RecNo),IntToStr(Table.RecordCount),Trim(Table.FieldByname('Name').AsString)]);
      FIntParam:=LINE_INFO_WARNING;
      Synchronize(TextOutEx);
      //fixing image -> deleting it
      Bmp:=TBitmap.Create;
      Bmp.PixelFormat:=pf24bit;
      Bmp.Width:=ImageOptions.ThSize;
      Bmp.Height:=ImageOptions.ThSize;
      FillRectNoCanvas(Bmp,0);
      Jpeg:=TJpegImage.Create;
      Jpeg.Assign(Bmp);
      Bmp.Free;
      Jpeg.CompressionQuality:=ImageOptions.DBJpegCompressionQuality;
      Jpeg.Compress;
      try
       Table.Edit;
       Table.FieldByName('thum').Assign(Jpeg);
       Table.Post;
       Jpeg.Free;
      except
      end;
     end;

     Table.Next;
     Continue;
    end;   
   end;

   //DEBUG:
   //if not Crypted then begin Table.Next;continue; end;

   ProcessCurrentRecord;

   if CMD_Command_Break then
   begin
    FIntParam:=LINE_INFO_WARNING;
    FStrParam:=Format(TEXT_MES_ACTION_BREAKED_ITEM_FORMAT,[IntToStr(Table.RecNo),IntToStr(Table.RecordCount),Copy(Table.FieldByname('Name').AsString,1,15)]);
    Synchronize(TextOut);
    Break;
   end;

  end;
  Table.Next;
 Until Table.Eof;

 Synchronize(GetCryptFileList);
 Crypting:=true;
 Repeat

  CryptFileList:=GetAvaliableCryptFileList;
  for i:=0 to Length(CryptFileList)-1 do
  begin
   CurrentID:=CryptFileList[i];
   Table.Locate('ID',CurrentID,[]);
   ProcessCurrentRecord;
  end;
  Sleep(500);

  //until files present in list
  GetCryptFileList;
 until fCryptFileList.Count=0;
 FreeDS(Table);

 FIntParam:=LINE_INFO_PROGRESS;
 FStrParam:=TEXT_MES_PACKING_MAIN_DB_FILE;
 Synchronize(TextOut);

 PackTable(fOptions.FileName);
                               
 FIntParam:=LINE_INFO_OK;
 FStrParam:=TEXT_MES_PACKING_END;
 Synchronize(TextOut);

 Synchronize(DoExit);
end;

function RecreatingThInTable.GetAvaliableCryptFileList: TArInteger;
begin
 Result:=fOptions.GetAvaliableCryptFileList(self);
end;

procedure RecreatingThInTable.GetCryptFileList;
begin
 fCryptFileList := fOptions.GetFilesWithoutPassProc(self);
end;

procedure RecreatingThInTable.GetPass;
begin
 FStrParam:=GetImagePasswordFromUserEx(FStrParam,FBoolParam);
end;

procedure RecreatingThInTable.TextOut;
begin
 fOptions.WriteLineProc(self,FStrParam,FIntParam);
end;

procedure RecreatingThInTable.TextOutEx;
begin
 fOptions.WriteLnLineProc(self,FStrParam,FIntParam);
end;

end.
