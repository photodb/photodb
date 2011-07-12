unit uGetPhotosThread;

interface

uses
  Classes, SysUtils, uDBThread, uMemory, uFileUtils, uAssociations,
  uShellIntegration, uConstants, uDBForm, uDBTypes, Windows, uTranslate;

type
  TGetPhotosThreadOptions = record
    BasePath: string;
    GetMultimediaFiles: Boolean;
    IsExtendedMode: Boolean;
    AddPhotosToDB: Boolean;
    Options: TGetImagesOptionsArray;
    FileData: TFileDateList;
    Move: Boolean;
    Data: TList;
    Folder: string;
    FolderName: string;
    MultimediaMask: string;
    OpenFolder: Boolean;
  end;

  TGetPhotosThread = class(TDBThread)
  private
    { Private declarations }
    FOptions: TGetPhotosThreadOptions;
    FOnDone: TNotifyEvent;
    FStrParam: string;
    FThreadDone: Boolean;
    FOwnerHandle: THandle;
    procedure DoCopyFilesSynch(Src: TStrings; Dest: string;
      Move, AutoRename: Boolean);
    procedure OnCopyThreadDone(Sender: TObject);
    procedure DoOnDone;
    procedure ShowCopyError;
    procedure ShowCreateDirectoryError;
  protected
    function GetThreadID: string; override;
    procedure Execute; override;
    procedure ShowExplorer;
    procedure HideForm;
    procedure RefreshListView;
    procedure AddDirectory;
  public
    constructor Create(OwnerForm: TDBForm; Options: TGetPhotosThreadOptions;
      OnDone: TNotifyEvent);
  end;

function FormatFolderName(Mask, Comment: String; Date: TDateTime): String;

implementation

uses
  UnitWindowsCopyFilesThread,
  UnitGetPhotosForm,
  ExplorerUnit,
  UnitUpdateDBObject,
  UnitUpdateDB;

{ TGetPhotosThread }

constructor TGetPhotosThread.Create(OwnerForm: TDBForm;
  Options: TGetPhotosThreadOptions; OnDone: TNotifyEvent);
begin
  inherited Create(OwnerForm, False);
  FOptions := Options;
  FOnDone := OnDone;
  FThreadDone := False;
  FOwnerHandle := OwnerForm.Handle;
end;

procedure TGetPhotosThread.DoCopyFilesSynch(Src: TStrings;
  Dest: string; Move, AutoRename: Boolean);
begin
  FThreadDone := False;
  TWindowsCopyFilesThread.Create(FOwnerHandle, Src, Dest, Move, AutoRename, OwnerForm, OnCopyThreadDone);
  while not FThreadDone do
  begin
    Sleep(10);
  end;
end;

procedure TGetPhotosThread.DoOnDone;
begin
  FOnDone(Self);
end;

procedure TGetPhotosThread.Execute;
var
  Files: TStrings;
  MaxFiles, FilesSearch,
  I, J: Integer;
  Folder, Mask: string;
  Options: TGetImagesOptions;
  ItemOptions: TItemRecordOptions;
  Date: TDateTime;
begin
  FreeOnTerminate := True;
  try

    if FOptions.IsExtendedMode then
    begin
      // EXTENDED LOADING FILES
      for I := 0 to FOptions.Data.Count - 1 do
      begin
        if Terminated then
          Break;

        ItemOptions := TItemRecordOptions(FOptions.Data[I]);
        if ItemOptions.Options = DIRECTORY_OPTION_DATE_EXCLUDE then
          Continue;
        Options := FOptions.Options[I];

        Folder := IncludeTrailingBackslash(Options.ToFolder);
        Folder := Folder + FormatFolderName(Options.FolderMask, Options.Comment, Options.Date);
        CreateDirA(Folder);
        if not DirectoryExists(Folder) then
        begin
          Synchronize(ShowCreateDirectoryError);
          Exit;
        end;
        Files := TStringList.Create;
        try
          Date := TItemRecordOptions(FOptions.Data[I]).Date;
          TItemRecordOptions(FOptions.Data[I]).Tag := -1;
          SynchronizeEx(RefreshListView);
          for J := 0 to Length(FOptions.FileData) - 1 do
            if FOptions.FileData[J].Date = Date then
              Files.Add(FOptions.FileData[J].FileName);

          if Options.OpenFolder then
          begin
            FStrParam := Folder;
            SynchronizeEx(ShowExplorer)
          end;

          try
            DoCopyFilesSynch(Files, Folder, Options.Move, True);
          except
            Synchronize(ShowCopyError);
          end;
          if Options.AddFolder then
          begin
            FStrParam := Folder;
            SynchronizeEx(AddDirectory);
          end;
        finally
          F(Files);
        end;
      end;//for
      // END
    end else
    begin

      Folder := IncludeTrailingBackslash(FOptions.Folder);
      Folder := Folder + FOptions.FolderName;
      CreateDirA(Folder);
      if not DirectoryExists(Folder) then
      begin
        FStrParam := Folder;
        Synchronize(ShowCreateDirectoryError);
        Exit;
      end;

      Files := TStringList.Create;
      try
        MaxFiles := 10000;
        FilesSearch := 100000;
        if FOptions.GetMultimediaFiles then
        begin
          Mask := FOptions.MultimediaMask;
          Mask := '|' + Mask + '|';
          for I := Length(Mask) downto 2 do
            if (Mask[I] = '|') and (Mask[I - 1] = '|') then
              Delete(Mask, I, 1);
          if Length(Mask) > 0 then
            Delete(Mask, 1, 1);
          Mask := TFileAssociations.Instance.ExtensionList + Mask;
        end else
          Mask := TFileAssociations.Instance.ExtensionList;

        GetFileNamesFromDrive(FOptions.BasePath, Mask, Files, FilesSearch, MaxFiles);

        SynchronizeEx(HideForm);
        if FOptions.OpenFolder then
        begin
          FStrParam := Folder;
          SynchronizeEx(ShowExplorer)
        end;

        try
          DoCopyFilesSynch(Files, Folder, FOptions.Move, True);
        except
          Synchronize(ShowCopyError);
        end;
        if FOptions.AddPhotosToDB then
        begin
          FStrParam := Folder;
          SynchronizeEx(AddDirectory);
        end;

      finally
        F(Files);
      end;
    end;

  finally
    if Assigned(FOnDone) then
      SynchronizeEx(DoOnDone);
    FOptions.Data.Free;
  end;
end;

procedure TGetPhotosThread.AddDirectory;
begin
  UpdaterDB.AddDirectory(FStrParam, nil);
end;

function TGetPhotosThread.GetThreadID: string;
begin
  Result := 'GetPhotos';
end;

procedure TGetPhotosThread.HideForm;
begin
  OwnerForm.Hide;
end;

procedure TGetPhotosThread.OnCopyThreadDone(Sender: TObject);
begin
  FThreadDone := True;
end;

procedure TGetPhotosThread.RefreshListView;
begin
  TGetToPersonalFolderForm(OwnerForm).LvMain.Refresh;
end;

procedure TGetPhotosThread.ShowCopyError;
begin
  MessageBoxDB(Handle, L('An error occurred during the preparation of photographs. Perhaps you''re trying to move pictures from media which is read-only'), L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
end;

procedure TGetPhotosThread.ShowCreateDirectoryError;
begin
  MessageBoxDB(Handle, Format(L('Unable to create directory: "%s"'), [FStrParam]), L('Error'), TD_BUTTON_OK,
    TD_ICON_ERROR);
end;

procedure TGetPhotosThread.ShowExplorer;
begin
  with ExplorerManager.NewExplorer(False) do
  begin
    SetPath(FStrParam);
    Show;
    SetFocus;
  end;
end;

function FormatFolderName(Mask, Comment: String; Date: TDateTime): String;
var
  S : String;
  i : integer;
  TempSysTime: TSystemTime;
  FineDate: array[0..255] of Char;
begin
  S := Mask;
  if S = '' then
    S := '%yy:mm:dd';
  S := StringReplace(S, '%yy:mm:dd', FormatDateTime('yy.mm.dd', Date), [RfReplaceAll, RfIgnoreCase]);
  DateTimeToSystemTime(Date, TempSysTime);
  GetDateFormat(LOCALE_USER_DEFAULT, DATE_USE_ALT_CALENDAR, @TempSysTime, 'dddd, d MMMM yyyy ', @FineDate, 255);
  S := StringReplace(S, '%YMD', FineDate + TA('y.', 'GetPhotos'), [RfReplaceAll, RfIgnoreCase]);
  S := StringReplace(S, '%coment', Comment, [RfReplaceAll, RfIgnoreCase]);
  S := StringReplace(S, '%yyyy', FormatDateTime('yyyy', Date), [RfReplaceAll, RfIgnoreCase]);
  S := StringReplace(S, '%yy', FormatDateTime('yy', Date), [RfReplaceAll, RfIgnoreCase]);
  GetDateFormat(LOCALE_USER_DEFAULT, DATE_USE_ALT_CALENDAR, @TempSysTime, 'dd MMMM', @FineDate, 255);
  S := StringReplace(S, '%mmmdd', FineDate, [RfReplaceAll, RfIgnoreCase]);
  GetDateFormat(LOCALE_USER_DEFAULT, DATE_USE_ALT_CALENDAR, @TempSysTime, 'd MMMM', @FineDate, 255);
  S := StringReplace(S, '%mmmd', FineDate, [RfReplaceAll, RfIgnoreCase]);
  S := StringReplace(S, '%mmm', FormatDateTime('mmm', Date), [RfReplaceAll, RfIgnoreCase]);
  S := StringReplace(S, '%mm', FormatDateTime('mm', Date), [RfReplaceAll, RfIgnoreCase]);
  S := StringReplace(S, '%m', FormatDateTime('m', Date), [RfReplaceAll, RfIgnoreCase]);
  GetDateFormat(LOCALE_USER_DEFAULT, DATE_USE_ALT_CALENDAR, @TempSysTime, 'dddd', @FineDate, 255);
  S := StringReplace(S, '%dddd', FineDate, [RfReplaceAll, RfIgnoreCase]);
  S := StringReplace(S, '%ddd', FormatDateTime('ddd', Date), [RfReplaceAll, RfIgnoreCase]);
  S := StringReplace(S, '%dd', FormatDateTime('dd', Date), [RfReplaceAll, RfIgnoreCase]);
  S := StringReplace(S, '%d', FormatDateTime('d', Date), [RfReplaceAll, RfIgnoreCase]);
  for I := Length(S) downto 1 do
    if (CharInSet(S[I], Unusedchar_folders)) then
      Delete(S, I, 1);
  if S = '' then
    S := FormatDateTime('yy.mm.dd', Date);
  Result := S;
end;

end.
