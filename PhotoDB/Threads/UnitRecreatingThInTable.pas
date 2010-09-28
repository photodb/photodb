unit UnitRecreatingThInTable;

interface

uses
  Classes, Graphics, Jpeg, DB, CommonDBSupport, Dolphin_DB, SysUtils,
  GraphicCrypt, GraphicsCool, UnitDBDeclare, UnitCDMappingSupport,
  ActiveX;

type
  RecreatingThInTable = class(TThread)
  private
    { Private declarations }
    FStrParam: string;
    FBoolParam: Boolean;
    FIntParam: Integer;
    FOptions: TRecreatingThInTableOptions;
    FRec: TPasswordRecord;
    FCryptFileList: TList;
    ImageOptions: TImageDBOptions;
    ProgressInfo: TProgressCallBackInfo;
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
    constructor Create(Options: TRecreatingThInTableOptions);
  end;

var
  RecreatingThInTableTerminating : Boolean;

implementation

{ RecreatingThInTable }

uses CMDUnit, Language, UnitPasswordForm;

procedure RecreatingThInTable.AddCryptFileCall;
begin
  FOptions.AddCryptFileToListProc(Self, FRec);
end;

procedure RecreatingThInTable.AddPasswordFile(ID: integer; FileName : string);
begin
  FRec := TPasswordRecord.Create;
  FRec.FileName := FileName;
  FRec.ID := ID;
  FRec.CRC := GraphicCrypt.GetPasswordCRCFromCryptGraphicFile(FileName);
  Synchronize(AddCryptFileCall);
end;

constructor RecreatingThInTable.Create(Options: TRecreatingThInTableOptions);
begin
  inherited Create(False);
  FOptions := Options;
end;

procedure RecreatingThInTable.DoExit;
begin
  if Assigned(FOptions.OnEndProcedure) then
    FOptions.OnEndProcedure(Self);
end;

procedure RecreatingThInTable.DoProgress;
begin
  FOptions.OnProgress(Self, ProgressInfo);
end;

procedure RecreatingThInTable.Execute;
var
  Table: TDataSet;
  Info: TImageDBRecordA;
  Pass: string;
  Crypted: Boolean;
  Ms: TMemoryStream;
  BF: TBlobField;
  CurrentID: Integer;
  CryptFileList: TArInteger;
  I: Integer;
  Bmp: TBitmap;
  Jpeg: TJpegImage;
  TableRecordCount: Integer;
  Crypting: Boolean;
  CRC: Cardinal;

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
      MS := TMemoryStream.Create;
      try
        CryptGraphicImage(Info.Jpeg, Info.Password, MS);
        BF := TBlobField(Table.FieldByName('thum'));
        MS.Seek(0, soFromBeginning);
        BF.LoadFromStream(ms);
      finally
        MS.free;
      end;
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
  FreeOnTerminate := True;
  CoInitialize(nil);
  try
    RecreatingThInTableTerminating := False;
    FBoolParam := True;
    Table := GetTable(FOptions.FileName, DB_TABLE_IMAGES);
    try
      try
        ImageOptions := CommonDBSupport.GetImageSettingsFromTable(FOptions.FileName);
        Table.Active := True;
      except
        FStrParam := TEXT_MES_RECREATINH_TH_FORMAT_ERROR;
        FIntParam := LINE_INFO_ERROR;
        Synchronize(TextOut);
        Synchronize(DoExit);
        Exit;
      end;
      Crypting := False;
      Table.First;
      TableRecordCount := Table.RecordCount;
      repeat
        if RecreatingThInTableTerminating then
          Break;
        if FileExists(Table.FieldByName('FFileName').AsString) then
        begin

          Crypted := False;

          if not StaticPath(Table.FieldByName('FFileName').AsString) then
          begin
            FStrParam := Format(TEXT_MES_RECREATINH_TH_FOR_ITEM_FORMAT_CD_DVD_CANCELED_INFO_F,
              [IntToStr(Table.RecNo), IntToStr(Table.RecordCount), Trim(Table.FieldByname('Name').AsString)]);
            FIntParam := LINE_INFO_WARNING;
            Synchronize(TextOutEx);
            Table.Next;
            Continue;
          end;

          if ValidCryptGraphicFile(Table.FieldByName('FFileName').AsString) then
          begin
            Crypted := True;
            Pass := DBKernel.FindPasswordForCryptImageFile(Table.FieldByName('FFileName').AsString);
            if Pass = '' then
            begin
              AddPasswordFile(Table.FieldByName('ID').AsInteger, Table.FieldByName('FFileName').AsString);
              FStrParam := Format(TEXT_MES_RECREATINH_TH_FOR_ITEM_FORMAT_CRYPTED_POSTPONED,
                [IntToStr(Table.RecNo), IntToStr(Table.RecordCount), Trim(Table.FieldByname('Name').AsString)]);
              FIntParam := LINE_INFO_WARNING;
              Synchronize(TextOutEx);

              if not GraphicCrypt.ValidCryptBlobStreamJPG(Table.FieldByName('thum')) then
              begin
                FStrParam := Format(TEXT_MES_RECREATINH_TH_FOR_ITEM_FORMAT_CRYPTED_FIXED,
                  [IntToStr(Table.RecNo), IntToStr(Table.RecordCount), Trim(Table.FieldByname('Name').AsString)]);
                FIntParam := LINE_INFO_WARNING;
                Synchronize(TextOutEx);
                // fixing image -> deleting it
                Bmp := TBitmap.Create;
                Bmp.PixelFormat := Pf24bit;
                Bmp.Width := ImageOptions.ThSize;
                Bmp.Height := ImageOptions.ThSize;
                FillRectNoCanvas(Bmp, 0);
                Jpeg := TJpegImage.Create;
                Jpeg.Assign(Bmp);
                Bmp.Free;
                Jpeg.CompressionQuality := ImageOptions.DBJpegCompressionQuality;
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

          // DEBUG:
          // if not Crypted then begin Table.Next;continue; end;

          ProcessCurrentRecord;

          if CMD_Command_Break then
          begin
            FIntParam := LINE_INFO_WARNING;
            FStrParam := Format(TEXT_MES_ACTION_BREAKED_ITEM_FORMAT, [IntToStr(Table.RecNo), IntToStr(Table.RecordCount),
              Copy(Table.FieldByname('Name').AsString, 1, 15)]);
            Synchronize(TextOut);
            Break;
          end;

        end;
        Table.Next;
      until Table.Eof;

      Synchronize(GetCryptFileList);
      Crypting := True;
      repeat

        CryptFileList := GetAvaliableCryptFileList;
        for I := 0 to Length(CryptFileList) - 1 do
        begin
          CurrentID := CryptFileList[I];
          Table.Locate('ID', CurrentID, []);
          ProcessCurrentRecord;
        end;
        Sleep(500);

        // until files present in list
        GetCryptFileList;
      until FCryptFileList.Count = 0;

    finally
      FreeDS(Table);
    end;

    FIntParam := LINE_INFO_PROGRESS;
    FStrParam := TEXT_MES_PACKING_MAIN_DB_FILE;
    Synchronize(TextOut);

    PackTable(FOptions.FileName);

    FIntParam := LINE_INFO_OK;
    FStrParam := TEXT_MES_PACKING_END;
    Synchronize(TextOut);

    Synchronize(DoExit);
  finally
    CoUninitialize;
  end;
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
