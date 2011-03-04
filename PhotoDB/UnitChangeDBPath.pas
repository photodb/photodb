unit UnitChangeDBPath;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Dolphin_DB, StdCtrls, DmProgress, DB, win32crc,
  UnitDBFileDialogs, UnitOpenQueryThread, CommonDBSupport, uConstants,
  UnitDBkernel, UnitDBDeclare, uFileUtils, uDBForm, uMemory,
  uShellIntegration;

type
  TFormChangeDBPath = class(TDBForm)
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    LbOldPath: TLabel;
    CbOldPath: TComboBox;
    BtnScanFolders: TButton;
    BtnChooseNewPath: TButton;
    EdNewPath: TEdit;
    LbNewPath: TLabel;
    DprMain: TDmProgress;
    BtnOk: TButton;
    BtnCancel: TButton;
    BtnChooseOldPath: TButton;
    CheckBox1: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnChooseNewPathClick(Sender: TObject);
    procedure BtnChooseOldPathClick(Sender: TObject);
    procedure BtnScanFoldersClick(Sender: TObject);
    procedure DBOpened(Sender : TObject; DS : TDataSet);
    procedure BtnOkClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    DBInOpening: Boolean;
    Working: Boolean;
    ClosingWork: Boolean;
    procedure DisableControls;
    procedure EnableControls;
  protected
    { Protected declarations }
    function GetFormID : string; override;
  public
    { Public declarations }
    procedure LoadLanguage;
  end;

procedure DoChangeDBPath;

implementation

var
  FormChangeDBPath: TFormChangeDBPath = nil;

{$R *.dfm}

procedure DoChangeDBPath;
begin
  if FormChangeDBPath = nil then
    Application.CreateForm(TFormChangeDBPath, FormChangeDBPath);

  FormChangeDBPath.Show;
end;

{ TFormChangeDBPath }

procedure TFormChangeDBPath.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Change path for files in DB');
    LbOldPath.Caption := L('Change path from (old path)');
    LbNewPath.Caption := L('Change path to (new path)');
    BtnScanFolders.Caption := L('Show directory list');
    BtnChooseOldPath.Caption := L('Choose');
    BtnChooseNewPath.Caption := L('Choose');
    Label1.Caption := L('Please, use this dialog if you want to update info in DB if many images was physically moved or drive name was changed.');
    BtnCancel.Caption := L('Cancel');
    BtnOk.Caption := L('Ok');
    CheckBox1.Caption := L('Change path only if new file exists');
    DprMain.Text := L('Progress... (&%%)');
  finally
    EndTranslate;
  end;
end;

procedure TFormChangeDBPath.FormCreate(Sender: TObject);
begin
  ClosingWork := False;
  DBInOpening := False;
  Working := False;
  LoadLanguage;
end;

procedure TFormChangeDBPath.FormDestroy(Sender: TObject);
begin
  FormChangeDBPath := nil;
end;

function TFormChangeDBPath.GetFormID: string;
begin
  Result := 'ChangeDBPath';
end;

procedure TFormChangeDBPath.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Release;
end;

procedure TFormChangeDBPath.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if Working then
  begin
    ClosingWork := True;
    CanClose := False;
  end;
end;

procedure TFormChangeDBPath.BtnCancelClick(Sender: TObject);
begin
  if not Working then
    Close
  else
    ClosingWork := True;
end;

procedure TFormChangeDBPath.BtnChooseNewPathClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := DBSelectDir(Handle, L('Please, choose folder'), False);
  if DirectoryExists(Dir) then
    EdNewPath.Text := Dir;
end;

procedure TFormChangeDBPath.BtnChooseOldPathClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := DBSelectDir(Handle, L('Please, choose folder'), False);
  if DirectoryExists(Dir) then
    CbOldPath.Text := Dir;
end;

procedure TFormChangeDBPath.BtnScanFoldersClick(Sender: TObject);
var
  WorkQuery: TDataSet;
  I: Integer;
  _sqlexectext: string;
  FileName: string;
  PathList: TStrings;

  function PathExists(Path: string): Boolean;
  begin
    Result := PathList.IndexOf(Path) > -1;
  end;

  procedure AddPathEntry(FileName: string);
  var
    Directory, UpDirectory: string;
  begin
    Directory := ExtractFileDir(FileName);
    if not PathExists(Directory) then
      PathList.Add(Directory);

    Directory := ExcludeTrailingBackslash(Directory);
    UpDirectory := ExtractFileDir(Directory);
    if (Length(UpDirectory) > 3) and (Directory <> FileName) then
      AddPathEntry(Directory)
    else if Length(UpDirectory) = 3 then
    begin
      if not PathExists(UpDirectory) then
        PathList.Add(UpDirectory);
    end;
  end;

begin
  DisableControls;
  Working := True;
  WorkQuery := GetQuery;
  try
    _sqlexectext := 'Select FFileName from $DB$ order by FFileName';
    SetSQL(WorkQuery, _sqlexectext);
    DBInOpening := True;
    TOpenQueryThread.Create(WorkQuery, DBOpened);
    I := 0;
    DprMain.MaxValue := 100;
    DprMain.Inverse := True;
    repeat
      Inc(I);
      DprMain.Position := I;
      if I = 100 then
      begin
        I := 0;
      end;
      Delay(5);
    until not DBInOpening;
    DprMain.Position := 0;
    DprMain.MaxValue := WorkQuery.RecordCount;
    DprMain.Inverse := False;
    PathList := TStringList.Create;
    try
      for I := 1 to WorkQuery.RecordCount do
      begin
        if I mod 100 = 0 then
        begin
          DprMain.Position := I;
          Application.ProcessMessages;
          if ClosingWork then
            Break;
        end;
        FileName := AnsiLowerCase(WorkQuery.FieldByName('FFileName').AsString);
        AddPathEntry(FileName);
        WorkQuery.Next;
      end;

      for I := 0 to PathList.Count - 1 do
        CbOldPath.Items.Add(PathList[I]);

    finally
      F(PathList);
    end;

  finally
    FreeDS(WorkQuery);
    EnableControls;
    Working := False;
  end;
end;

procedure TFormChangeDBPath.DBOpened(Sender : TObject; DS : TDataSet);
begin
  DBInOpening := False;
end;

procedure TFormChangeDBPath.DisableControls;
begin
  CbOldPath.Enabled := False;
  EdNewPath.Enabled := False;
  CheckBox1.Enabled := False;
  BtnChooseOldPath.Enabled := False;
  BtnScanFolders.Enabled := False;
  BtnChooseNewPath.Enabled := False;
  BtnOk.Enabled := False;
end;

procedure TFormChangeDBPath.EnableControls;
begin
  CbOldPath.Enabled := True;
  EdNewPath.Enabled := True;
  CheckBox1.Enabled := True;
  BtnChooseOldPath.Enabled := True;
  BtnScanFolders.Enabled := True;
  BtnChooseNewPath.Enabled := True;
  BtnOk.Enabled := True;
end;

procedure TFormChangeDBPath.BtnOkClick(Sender: TObject);
var
  WorkQuery: TDataSet;
  TempQuery: TDataSet;
  I, Len, Count: Integer;
  CRC: Cardinal;
  _sqlexectext, Dir, NewDir: string;
  FileName, FromPath, NewPath, ToPath: string;
  EventInfo: TEventValues;

begin
  if not DirectoryExists(EdNewPath.Text) then
    Exit;

  DisableControls;
  try
    Working := True;
    FromPath := IncludeTrailingBackslash(CbOldPath.Text);
    ToPath := IncludeTrailingBackslash(EdNewPath.Text);
    WorkQuery := GetQuery;
    try
      _sqlexectext := 'Select ID,FFileName from $DB$';
      SetSQL(WorkQuery, _sqlexectext);
      DBInOpening := True;
      TOpenQueryThread.Create(WorkQuery, DBOpened);
      I := 0;
      Count := 0;
      DprMain.MaxValue := 100;
      DprMain.Inverse := True;
      repeat
        Inc(I);
        DprMain.Position := I;
        if I = 100 then
        begin
          I := 0;
        end;
        Delay(5);
      until not DBInOpening;
      DprMain.Position := 0;
      DprMain.Inverse := False;
      Len := Length(FromPath);
      TempQuery := GetQuery;
      try
        DprMain.MaxValue := WorkQuery.RecordCount;
        for I := 1 to WorkQuery.RecordCount do
        begin
          if ClosingWork then
            Break;
          DprMain.Position := I;
          Application.ProcessMessages;
          FileName := AnsiLowerCase(WorkQuery.FieldByName('FFileName').AsString);
          if Copy(FileName, 1, Len) = FromPath then
          begin
            Dir := ExtractFileDir(FileName);
            if Dir <> FromPath then
            begin
              ExcludeTrailingBackslash(Dir);

              NewPath := FileName;
              Delete(NewPath, 1, Len);
              NewPath := ToPath + NewPath;
              NewDir := ExcludeTrailingBackslash(AnsiLowerCase(ExtractFileDir(NewPath)));

              CRC := 0;
              CalcStringCRC32(AnsiLowerCase(NewDir), CRC);
              if not CheckBox1.Checked or FileExistsSafe(NewPath) then
              begin
                _sqlexectext := 'UPDATE $DB$ SET FFileName=' + AnsiLowerCase(NormalizeDBString(NewPath))
                  + ' , FolderCRC = ' + Format('%d', [Crc]) + ' where ID = ' + IntToStr
                  (WorkQuery.FieldByName('ID').AsInteger);
                SetSQL(TempQuery, _sqlexectext);
                try
                  ExecSQL(TempQuery);
                  Inc(Count);
                except
                  on E: Exception do
                  begin
                    Working := False;
                    MessageBoxDB(Handle, Format(L('An unexpected error occurred: %s'), [E.message]), L('Error'),
                      TD_BUTTON_OK, TD_ICON_ERROR);
                    EnableControls;
                    Exit;
                  end;
                end;
              end;
            end;
          end;
          WorkQuery.Next;
        end;
      finally
        FreeDS(TempQuery);
      end;
    finally
      FreeDS(WorkQuery);
    end;
  except
    on E: Exception do
    begin
      Working := False;
      MessageBoxDB(Handle, Format(L('An unexpected error occurred: %s'), [E.message]), L('Information'), TD_BUTTON_OK,
        TD_ICON_INFORMATION);
      EnableControls;
      Exit;
    end;
  end;

  Working := False;
  MessageBoxDB(Handle, Format(L('DB Update successful! Total replaced% d paths. Update the data in the windows to apply changes!'), [Count]), L('Information'), TD_BUTTON_OK,
    TD_ICON_INFORMATION);

  EnableControls;
  if MessageBoxDB(Handle, L('Update data in open windows?'), L('Information'), TD_BUTTON_OKCANCEL, TD_ICON_QUESTION) = ID_OK then
    DBKernel.DoIDEvent(Self, 0, [EventID_Param_Refresh_Window], EventInfo);

  Close;
end;

end.
