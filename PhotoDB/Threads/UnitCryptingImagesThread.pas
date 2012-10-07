unit UnitCryptingImagesThread;

interface

uses
  Windows,
  SysUtils,
  Classes,
  ActiveX,
  Forms,
  DB,
  Dolphin_DB,
  UnitDBKernel,
  UnitPropeccedFilesSupport,
  UnitCrypting,
  GraphicCrypt,
  CommonDBSupport,
  Dmitry.Utils.Files,
  UnitDBDeclare,
  uGOM,
  uDBBaseTypes,
  uDBForm,
  uLogger,
  uDBThread,
  uConstants,
  uErrors,
  uShellIntegration,
  uFormInterfaces;

type
  TCryptingImagesThread = class(TDBThread)
  private
    { Private declarations }
    FOptions: TCryptImageThreadOptions;
    BoolParam: Boolean;
    IntParam: Integer;
    StrParam: string;
    Count: Integer;
    ProgressWindow: TForm;
    Table: TDataSet;
    FPassword: string;
    FField: TField;
    FE: Boolean;
    Position: Integer;
    CryptResult: Integer;
    FSender: TDBForm;
    FLastProgressTime: Cardinal;
    procedure ShowError(ErrorText: string);
    procedure ShowErrorSync;
    procedure OnFileProgress(FileName: string; BytesTotal, BytesDone: Int64);
  public
    constructor Create(Sender: TDBForm; Options: TCryptImageThreadOptions);
  protected
    procedure Execute; override;
    procedure InitializeProgress;
    procedure DestroyProgress;
    procedure IfBreakOperation;
    procedure SetProgressPosition(Position : integer);
    procedure SetProgressPositionSynch;
    procedure DoDBkernelEvent;
    procedure DoDBkernelEventRefreshList;
    procedure RemoveFileFromUpdatingList;
    procedure GetPassword;
    procedure FindPasswordToFile;
    procedure FindPasswordToBlob;
    procedure GetPasswordFromUserFile;
    procedure GetPasswordFromUserBlob;
  end;

implementation

uses ProgressActionUnit;

{ TCryptingImagesThread }

constructor TCryptingImagesThread.Create(Sender: TDBForm; Options: TCryptImageThreadOptions);
var
  I: Integer;
begin
  inherited Create(Sender, False);
  FSender := Sender;
  Table := nil;
  FLastProgressTime := 0;
  FOptions := Options;
  for I := 0 to Length(Options.Files) - 1 do
    if Options.Selected[I] then
      ProcessedFilesCollection.AddFile(Options.Files[I]);
  DoDBKernelEventRefreshList;
end;

procedure TCryptingImagesThread.DestroyProgress;
begin
  (ProgressWindow as TProgressActionForm).WindowCanClose := True;
  ProgressWindow.Release;
end;

procedure TCryptingImagesThread.DoDBkernelEvent;
var
  EventInfo: TEventValues;
begin
  if FOptions.Action = ACTION_ENCRYPT_IMAGES then
    EventInfo.Encrypted := CryptResult = CRYPT_RESULT_OK
  else
    EventInfo.Encrypted := CryptResult <> CRYPT_RESULT_OK;

  if IntParam <> 0 then
    DBKernel.DoIDEvent(FSender, IntParam, [EventID_Param_Crypt], EventInfo)
  else
  begin
    EventInfo.NewName := StrParam;
    DBKernel.DoIDEvent(FSender, IntParam, [EventID_Param_Crypt, EventID_Param_Name], EventInfo)
  end;
end;

procedure TCryptingImagesThread.DoDBkernelEventRefreshList;
var
  EventInfo: TEventValues;
begin
  DBKernel.DoIDEvent(FSender, 0, [EventID_Repaint_ImageList], EventInfo);
end;

procedure TCryptingImagesThread.Execute;
var
  I, J: Integer;
  C: Integer;
begin
  inherited;
  FreeOnTerminate := True;
  CoInitializeEx(nil, COM_MODE);
  try
    Count := 0;
    for I := 0 to Length(FOptions.IDs) - 1 do
      if FOptions.Selected[I] then
        Inc(Count);
    Synchronize(InitializeProgress);
    try
      C := 0;
      for I := 0 to Length(FOptions.IDs) - 1 do
      begin
        StrParam := FOptions.Files[I];
        IntParam := FOptions.IDs[I];
        Position := I;
        if FOptions.Selected[I] then
        begin
          Synchronize(IfBreakOperation);
          if BoolParam then
          begin
            for J := I to Length(FOptions.IDs) - 1 do
            begin
              StrParam := FOptions.Files[J];
              Synchronize(RemoveFileFromUpdatingList);
            end;
            Synchronize(DoDBkernelEventRefreshList);
            Continue;
          end;
          Inc(C);
          SetProgressPosition(C);
          if FOptions.Action = ACTION_ENCRYPT_IMAGES then
          begin
            // Encrypting images
            try
              CryptResult := EncryptImageByFileName(FSender, FOptions.Files[I], FOptions.IDs[I], FOptions.Password,
                FOptions.EncryptOptions, False, OnFileProgress);

              if CryptResult <> CRYPT_RESULT_OK then
                ShowError(DBErrorToString(CryptResult));
            except
              on e: Exception do
                EventLog(e);
            end;
          end else
          begin
            // Decrypting images
            FE := FileExistsSafe(FOptions.Files[I]);
            // GetPassword
            StrParam := FOptions.Files[I];
            IntParam := FOptions.IDs[I];
            GetPassword;
            // DEcrypting images
            CryptResult := ResetPasswordImageByFileName(Self, FOptions.Files[I], FOptions.IDs[I], FPassword, OnFileProgress);

            if CryptResult <> CRYPT_RESULT_OK then
              ShowError(DBErrorToString(CryptResult));
          end;
          StrParam := FOptions.Files[I];
          IntParam := FOptions.IDs[I];
          Synchronize(RemoveFileFromUpdatingList);
          Synchronize(DoDBkernelEventRefreshList);
          Synchronize(DoDBkernelEvent);
        end;
      end;
    finally
      Synchronize(DestroyProgress);
    end;
    FreeDS(Table);
  finally
    CoUninitialize;
  end;
end;

procedure TCryptingImagesThread.GetPasswordFromUserFile;
begin
  FPassword := RequestPasswordForm.ForImage(StrParam);
end;

procedure TCryptingImagesThread.GetPasswordFromUserBlob;
begin
  FPassword := RequestPasswordForm.ForBlob(FField, StrParam);
end;

procedure TCryptingImagesThread.FindPasswordToFile;
begin
  FPassword := DBkernel.FindPasswordForCryptImageFile(StrParam)
end;

procedure TCryptingImagesThread.FindPasswordToBlob;
begin
  FPassword := DBkernel.FindPasswordForCryptBlobStream(FField);
end;

procedure TCryptingImagesThread.GetPassword;
begin
  if FE then
    Synchronize(FindPasswordToFile)
  else
  begin
    if Table = nil then
    begin
      Table := GetTable;
      Table.Open;
    end;
    Table.Locate('ID', IntParam, [LoPartialKey]);
    FField := Table.FieldByName('thum');
    Synchronize(FindPasswordToBlob);
  end;
  if FPassword = '' then
  begin
    begin
      if not FE then
      begin
        if IntParam = 0 then
        begin
          Exit;
        end;
        Table.Locate('ID', IntParam, [LoPartialKey]);
        Table.Edit;
        FField := Table.FieldByName('thum');
        Synchronize(FindPasswordToBlob);
        Table.Post;
      end
      else
      begin
        Synchronize(GetPasswordFromUserFile);
      end;
    end;
  end;
end;

procedure TCryptingImagesThread.IfBreakOperation;
begin
  BoolParam := True;

  if not GOM.IsObj(ProgressWindow) then
    Exit;

  BoolParam := (ProgressWindow as TProgressActionForm).Closed;
end;

procedure TCryptingImagesThread.InitializeProgress;
begin
  ProgressWindow := GetProgressWindow(True);
  with ProgressWindow as TProgressActionForm do
  begin
    CanClosedByUser := True;
    OneOperation := False;
    OperationCount := Count;
    OperationPosition := 1;
    MaxPosCurrentOperation := 0;
    XPosition := 0;
    Show;
  end;
end;

procedure TCryptingImagesThread.OnFileProgress(FileName: string; BytesTotal,
  BytesDone: Int64);
begin
  if GetTickCount - FLastProgressTime > 100 then
  begin
    FLastProgressTime := GetTickCount;

    Synchronize(
      procedure
      begin
        if not GOM.IsObj(ProgressWindow) then
          Exit;

        (ProgressWindow as TProgressActionForm).MaxPosCurrentOperation := BytesTotal;
        (ProgressWindow as TProgressActionForm).XPosition := BytesDone;
      end
    );
  end;
end;

procedure TCryptingImagesThread.RemoveFileFromUpdatingList;
begin
  ProcessedFilesCollection.RemoveFile(StrParam);
end;

procedure TCryptingImagesThread.SetProgressPosition(Position: Integer);
begin
  IntParam := Position;
  Synchronize(SetProgressPositionSynch);
end;

procedure TCryptingImagesThread.SetProgressPositionSynch;
begin
  if not GOM.IsObj(ProgressWindow) then
    Exit;

  (ProgressWindow as TProgressActionForm).OperationPosition := IntParam;
end;

procedure TCryptingImagesThread.ShowError(ErrorText: string);
begin
  StrParam := ErrorText;
  SynchronizeEx(ShowErrorSync);
end;

procedure TCryptingImagesThread.ShowErrorSync;
begin
  MessageBoxDB(0, StrParam, L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
end;

end.
