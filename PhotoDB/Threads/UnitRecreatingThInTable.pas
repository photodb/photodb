unit UnitRecreatingThInTable;

interface

uses
  Classes, Graphics, Jpeg, DB, CommonDBSupport, UnitDBKernel, SysUtils,
  GraphicCrypt, GraphicsCool, UnitDBDeclare, uCDMappingTypes,
  ActiveX, Dolphin_DB, uMemory, uDBBaseTypes, uDBTypes, uDBUtils,
  win32crc, uDBThread, uFileUtils, uGOM;

type
  RecreatingThInTable = class(TDBThread)
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
    function GetThreadID : string; override;
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
    destructor Destroy; override;
  end;

var
  RecreatingThInTableTerminating : Boolean;

implementation

{ RecreatingThInTable }

uses
  CMDUnit, UnitPasswordForm;

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
  SynchronizeEx(AddCryptFileCall);
end;

constructor RecreatingThInTable.Create(Options: TRecreatingThInTableOptions);
begin
  ImageOptions := nil;
  inherited Create(Options.OwnerForm, False);
  FOptions := Options;
  FCryptFileList := nil;
end;

destructor RecreatingThInTable.Destroy;
begin
  F(ImageOptions);
  F(FCryptFileList);
  inherited;
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
      Info := GetImageIDW(Table.FieldByName('FFileName').AsString, False, True, ImageOptions.ThSize,
        ImageOptions.DBJpegCompressionQuality);
      if Info.IsError then
      begin
        FStrParam := Format(L('Unable to get information about the file "%s" because: %s'), [Trim(Table.FieldByname('Name').AsString), Info.ErrorText]);
        FIntParam := LINE_INFO_ERROR;
        SynchronizeEx(TextOutEx);
        Exit;
      end;
      Table.Edit;
      if Info.Jpeg <> nil then
      begin
        if Info.Crypt or Crypting then
        begin
          MS := TMemoryStream.Create;
          try
            CryptGraphicImage(Info.Jpeg, Info.Password, MS);
            BF := TBlobField(Table.FieldByName('thum'));
            MS.Seek(0, SoFromBeginning);
            BF.LoadFromStream(Ms);
          finally
            F(MS);
          end;
        end
        else
          Table.FieldByName('thum').Assign(Info.Jpeg);
      end;
      if Info.ImTh <> '' then
      begin
        if Table.FieldByName('StrTh').AsString <> Info.ImTh then
        begin
          FStrParam := Format(L('Updated information about file "%s"'), [Trim(Table.FieldByname('Name').AsString)]);
          FIntParam := LINE_INFO_OK;
          if Crypted then
            FStrParam := FStrParam + ' *';
          SynchronizeEx(TextOutEx);
          Table.FieldByName('StrTh').AsString := Info.ImTh;
          CRC := StringCRC(Info.ImTh);
          if Integer(CRC) <> Table.FieldByName('StrThCrc').AsInteger then
            Table.FieldByName('StrThCrc').AsInteger := Integer(CRC);
        end;
      end;
      Info.Jpeg.Free;
      FStrParam := Format(L('Updating item %s from %s [%s]'), [IntToStr(Table.RecNo), IntToStr(TableRecordCount),
        Trim(Table.FieldByname('Name').AsString)]);
      if Assigned(FOptions.OnProgress) then
      begin
        ProgressInfo.MaxValue := TableRecordCount;
        ProgressInfo.Position := Table.RecNo;
        ProgressInfo.Information := L('Update previews in collection...');
        ProgressInfo.Terminate := False;
        SynchronizeEx(DoProgress);
      end;
      FIntParam := LINE_INFO_OK;
      SynchronizeEx(TextOut);
      Table.Post;
    except
      FStrParam := Format(L('Failed to update item: %s'), [Table.FieldByname('Name').AsString]);
      FIntParam := LINE_INFO_ERROR;
      SynchronizeEx(TextOut);
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
        on e: Exception do
        begin
          FStrParam := Format(L('Failed to update item: %s'), [e.Message]);
          FIntParam := LINE_INFO_ERROR;
          SynchronizeEx(TextOut);
          SynchronizeEx(DoExit);
          Exit;
        end;
      end;
      Crypting := False;
      Table.First;
      TableRecordCount := Table.RecordCount;
      repeat
        if RecreatingThInTableTerminating then
          Break;
        if FileExistsSafe(Table.FieldByName('FFileName').AsString) then
        begin

          Crypted := False;

          if not StaticPath(Table.FieldByName('FFileName').AsString) then
          begin
            FStrParam := Format(L('Update item %s from %s [%s] is canceled (CD\DVD files are updated from disk management window)'),
              [IntToStr(Table.RecNo), IntToStr(Table.RecordCount), Trim(Table.FieldByname('Name').AsString)]);
            FIntParam := LINE_INFO_WARNING;
            SynchronizeEx(TextOutEx);
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
              FStrParam := Format(L('Update item %s from %s [%s] postponed (encrypted)'),
                [IntToStr(Table.RecNo), IntToStr(Table.RecordCount), Trim(Table.FieldByname('Name').AsString)]);
              FIntParam := LINE_INFO_WARNING;
              SynchronizeEx(TextOutEx);

              if not GraphicCrypt.ValidCryptBlobStreamJPG(Table.FieldByName('thum')) then
              begin
                FStrParam := Format(L('For item %s from %s [%s] removed the preview (the file is encrypted, and the record - no)'),
                  [IntToStr(Table.RecNo), IntToStr(Table.RecordCount), Trim(Table.FieldByname('Name').AsString)]);
                FIntParam := LINE_INFO_WARNING;
                SynchronizeEx(TextOutEx);
                // fixing image -> deleting it
                Bmp := TBitmap.Create;
                try
                  Bmp.PixelFormat := pf24bit;
                  Bmp.SetSize(ImageOptions.ThSize, ImageOptions.ThSize);
                  FillRectNoCanvas(Bmp, 0);
                  Jpeg := TJpegImage.Create;
                  try
                    Jpeg.Assign(Bmp);
                    F(Bmp);
                    Jpeg.CompressionQuality := ImageOptions.DBJpegCompressionQuality;
                    Jpeg.Compress;
                    Table.Edit;
                    Table.FieldByName('thum').Assign(Jpeg);
                    Table.Post;
                  finally
                    F(Jpeg);
                  end;
                finally
                  F(Bmp);
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
            FStrParam := Format(L('The action was interrupted on item %s from %s [%s]'), [IntToStr(Table.RecNo), IntToStr(Table.RecordCount),
              Copy(Table.FieldByname('Name').AsString, 1, 15)]);
            SynchronizeEx(TextOut);
            Break;
          end;

        end;
        Table.Next;
      until Table.Eof;

      SynchronizeEx(GetCryptFileList);
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
    FStrParam := L('Packing collection files...');
    SynchronizeEx(TextOut);

    PackTable(FOptions.FileName);

    FIntParam := LINE_INFO_OK;
    FStrParam := L('Packing is completed...');
    SynchronizeEx(TextOut);

    SynchronizeEx(DoExit);
  finally
    CoUninitialize;
  end;
end;

function RecreatingThInTable.GetAvaliableCryptFileList: TArInteger;
begin
  Result := FOptions.GetAvaliableCryptFileList(Self);
end;

procedure RecreatingThInTable.GetCryptFileList;
begin
  F(FCryptFileList);
  FCryptFileList := FOptions.GetFilesWithoutPassProc(Self);
end;

procedure RecreatingThInTable.GetPass;
begin
  FStrParam := GetImagePasswordFromUserEx(FStrParam, FBoolParam);
end;

function RecreatingThInTable.GetThreadID: string;
begin
  Result := 'CMD';
end;

procedure RecreatingThInTable.TextOut;
begin
  FOptions.WriteLineProc(Self, FStrParam, FIntParam);
end;

procedure RecreatingThInTable.TextOutEx;
begin
  FOptions.WriteLnLineProc(Self, FStrParam, FIntParam);
end;

end.
