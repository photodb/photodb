unit UnitCryptingImagesThread;

interface

uses
  Classes, Dolphin_DB, UnitDBKernel, Forms, UnitPropeccedFilesSupport,
  UnitCrypting, GraphicCrypt, SysUtils, CommonDBSupport, DB, UnitRotatingImagesThread,
  UnitDBDeclare, uGOM;

type
  TCryptImageThreadOptions = record
    Files: TArStrings;
    IDs: TArInteger;
    Selected: TArBoolean;
    Password: string;
    CryptOptions: Integer;
    Action: Integer;
  end;

const
  ACTION_CRYPT_IMAGES   = 1;
  ACTION_DECRYPT_IMAGES = 2;

type
  TCryptingImagesThread = class(TThread)
  private
    { Private declarations }
    FOptions: TCryptImageThreadOptions;
    BoolParam: Boolean;
    IntParam: Integer;
    StrParam: string;
    Count: Integer;
    ProgressWindow: TForm;
    Result: Integer;
    Table: TDataSet;
    FPassword: string;
    FField: TField;
    FE: Boolean;
    Position: Integer;
    CryptResult: Integer;
  public
    constructor Create(Options: TCryptImageThreadOptions);
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

uses ProgressActionUnit, UnitPasswordForm;

{ TCryptingImagesThread }

constructor TCryptingImagesThread.Create(Options: TCryptImageThreadOptions);
var
  I: Integer;
begin
  inherited Create(False);
  Table := nil;
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
  if FOptions.Action = ACTION_CRYPT_IMAGES then
    EventInfo.Crypt := Result = CRYPT_RESULT_OK
  else
    EventInfo.Crypt := Result <> CRYPT_RESULT_OK;

  if IntParam <> 0 then
    DBKernel.DoIDEvent(Self, IntParam, [EventID_Param_Crypt], EventInfo)
  else
  begin
    EventInfo.NewName := StrParam;
    DBKernel.DoIDEvent(Self, IntParam, [EventID_Param_Name], EventInfo)
  end;
end;

procedure TCryptingImagesThread.DoDBkernelEventRefreshList;
var
  EventInfo : TEventValues;
begin
  DBKernel.DoIDEvent(Self, 0, [EventID_Repaint_ImageList], EventInfo);
end;

procedure TCryptingImagesThread.Execute;
var
  I, J: Integer;
  C: Integer;
begin
  FreeOnTerminate := True;
  Count := 0;
  for I := 0 to Length(FOptions.IDs) - 1 do
    if FOptions.Selected[I] then
      Inc(Count);
  Synchronize(InitializeProgress);
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
      if FOptions.Action = ACTION_CRYPT_IMAGES then
      begin
        // Crypting images
        try
          Result := CryptImageByFileName(Self, FOptions.Files[I], FOptions.IDs[I], FOptions.Password,
            FOptions.CryptOptions, False);
        except
        end;
      end
      else
      begin
        // DEcrypting images
        FE := FileExists(FOptions.Files[I]);
        // GetPassword
        StrParam := FOptions.Files[I];
        IntParam := FOptions.IDs[I];
        GetPassword;
        // DEcrypting images
        CryptResult := ResetPasswordImageByFileName(Self, FOptions.Files[I], FOptions.IDs[I], FPassword);
      end;
      Synchronize(RemoveFileFromUpdatingList);
      Synchronize(DoDBkernelEventRefreshList);
      Synchronize(DoDBkernelEvent);
    end;
  end;
  if Table <> nil then
    Table.Free;
  Synchronize(DestroyProgress);
end;

procedure TCryptingImagesThread.GetPasswordFromUserFile;
begin
  FPassword := GetImagePasswordFromUser(StrParam);
end;

procedure TCryptingImagesThread.GetPasswordFromUserBlob;
begin
  FPassword := GetImagePasswordFromUserBlob(FField, StrParam);
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
  //TODO: review!!!
  if FE then
    Synchronize(FindPasswordToFile)
  else
  begin
  if Table=nil then
  begin
   Table := GetTable;
   Table.Open;
  end;
  Table.Locate('ID',IntParam,[loPartialKey]);
  fField:=Table.FieldByName('thum');
  Synchronize(FindPasswordToBlob);
 end;
 if fPassword='' then
 begin
  begin
   if not FE then
   begin
    if IntParam=0 then
    begin
     exit;
    end;
    Table.Locate('ID',IntParam,[loPartialKey]);
    Table.Edit;
    fField:=Table.FieldByName('thum');
    Synchronize(FindPasswordToBlob);
    Table.Post;
    end else
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
    OperationCount := 1;
    OperationPosition := 1;
    MaxPosCurrentOperation := Count;
    XPosition := 0;
    Show;
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
    Exit; (ProgressWindow as TProgressActionForm)
  .XPosition := IntParam;
end;

end.
