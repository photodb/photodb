unit UnitGetPhotosForm;

interface

uses
  Registry, Windows, Messages, SysUtils, Variants, Classes,
  Graphics, Controls, Forms, DateUtils, uShellIntegration,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Dolphin_DB,
  acDlgSelect, Math, UnitUpdateDBObject, UnitScanImportPhotosThread,
  DmProgress, ImgList, CommCtrl, UnitDBKernel, Menus, uVistaFuncs, uFileUtils,
  UnitDBDeclare, UnitDBFileDialogs, UnitDBCommon, uConstants,
  CCR.Exif, uMemory, uTranslate, uDBForm, uShellUtils, uSysUtils,
  uDBUtils, uDBTypes, uRuntime, uDBBaseTypes, uDBPopupMenuInfo,
  uSettings;

type
  TGetImagesOptions = record
    Date: TDateTime;
    FolderMask: string;
    Comment: string;
    ToFolder: string;
    GetMultimediaFiles: Boolean;
    MultimediaMask: string;
    Move: Boolean;
    OpenFolder: Boolean;
    AddFolder: Boolean;
  end;

  TGetImagesOptionsArray = array of TGetImagesOptions;

type
  TGetToPersonalFolderForm = class(TDBForm)
    BtnOk: TButton;
    BtnCancel: TButton;
    DtpFromDate: TDateTimePicker;
    EdFolderMask: TEdit;
    Image1: TImage;
    LbDate: TLabel;
    Label2: TLabel;
    MemComment: TMemo;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    EdFolder: TEdit;
    BtnChooseFolder: TButton;
    CbMethod: TComboBox;
    Label6: TLabel;
    CbOpenFolder: TCheckBox;
    MemFolderName: TMemo;
    BtnSave: TButton;
    CheckBox2: TCheckBox;
    EdMultimediaMask: TEdit;
    CbAddProtosToDB: TCheckBox;
    DestroyTimer: TTimer;
    LvMain: TListView;
    LbListComment: TLabel;
    BtnScanDates: TButton;
    ExtendedButton: TButton;
    ProgressBar: TDmProgress;
    OptionsImageList: TImageList;
    PmListView: TPopupMenu;
    MoveUp1: TMenuItem;
    MoveDown1: TMenuItem;
    N1: TMenuItem;
    Remove1: TMenuItem;
    N2: TMenuItem;
    MergeUp1: TMenuItem;
    MergeDown1: TMenuItem;
    DontCopy1: TMenuItem;
    SimpleCopy1: TMenuItem;
    N3: TMenuItem;
    ShowImages1: TMenuItem;
    procedure BtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnChooseFolderClick(Sender: TObject);
    procedure EdFolderMaskChange(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure DestroyTimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnScanDatesClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LvMainResize(Sender: TObject);
    procedure ExtendedButtonClick(Sender: TObject);
    procedure LvMainContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure SimpleCopy1Click(Sender: TObject);
    procedure MergeUp1Click(Sender: TObject);
    procedure MergeDown1Click(Sender: TObject);
    procedure DontCopy1Click(Sender: TObject);
    procedure LvMainAdvancedCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; Stage: TCustomDrawStage;
      var DefaultDraw: Boolean);
    procedure ShowImages1Click(Sender: TObject);
    procedure Remove1Click(Sender: TObject);
    procedure MoveUp1Click(Sender: TObject);
    procedure MoveDown1Click(Sender: TObject);
    procedure LvMainSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
  private
    { Private declarations }
    FPath: string;
    FDataList: TFileDateList;
    ExtendedMode: Boolean;
    ThreadInProgress: Boolean;
    DefaultOptions: TGetImagesOptions;
    OptionsArray: TGetImagesOptionsArray;
    procedure ClearList;    
    procedure LoadLanguage;
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    procedure Execute(Pach: string);
    procedure OnEndScanFolder(Sender: TObject);
    procedure OnLoadingFilesCallBackEvent(Sender: TObject; var Info: TProgressCallBackInfo);
    procedure SetDataList(DataList: TFileDateList);
    procedure RecountGroups;
    function FormatFolderName(Mask, Comment: string; Date: TDateTime): string;
  end;

  TItemRecordOptions = class
  public
    StringDate: string;
    Date: TDateTime;
    Options: Integer;
    Tag: Integer;
  end;

procedure GetPhotosFromDrive(DriveLetter: Char);
procedure GetPhotosFromFolder(Folder: string);

implementation

uses
  ExplorerUnit, UnitUpdateDB, SlideShow;

procedure GetPhotosFromDrive(DriveLetter: Char);
var
  GetToPersonalFolderForm: TGetToPersonalFolderForm;
begin
  Application.CreateForm(TGetToPersonalFolderForm, GetToPersonalFolderForm);
  GetToPersonalFolderForm.Execute(DriveLetter + ':\');
end;

procedure GetPhotosFromFolder(Folder: string);
var
  GetToPersonalFolderForm: TGetToPersonalFolderForm;
begin
  Application.CreateForm(TGetToPersonalFolderForm, GetToPersonalFolderForm);
  GetToPersonalFolderForm.Execute(Folder);
end;

{$R *.dfm}

{ TGetToPersonalFolderForm }

function GetPhotosDate(Mask: string; Path: string): TDateTime;
var
  Files: TStrings;
  ExifData: TExifData;
  Dates: array [1 .. 4] of TDateTime;
  I, MaxFiles, FilesSearch: Integer;
begin
  Files := TStringList.Create;
  try
    MaxFiles := 500;
    FilesSearch := 4;
    GetFileNamesFromDrive(Path, SupportedExt, Files, MaxFiles, FilesSearch);
    if Files.Count = 0 then
    begin
      MaxFiles := 500;
      FilesSearch := 4;
      GetFileNamesFromDrive(Path, Mask, Files, MaxFiles, FilesSearch);
      if Files.Count = 0 then
      begin
        MessageBoxDB(GetActiveFormHandle, Format(TA('Photos in the specified path: "%s" not found', 'GetPhotos'), [Path]), TA('Warning'),
          TD_BUTTON_OK, TD_ICON_WARNING);

        Result := -1;
        Exit;
      end else
      begin
        Result := Now;
        Exit;
      end;
    end;
    for I := 1 to Min(4, Files.Count) do
    begin
      ExifData := TExifData.Create;
      try
        ExifData.LoadFromJPEG(Files[I - 1]);
        Dates[I] := DateOf(ExifData.DateTime);
      except
        Dates[I] := DateOf(Now);
      end;
      F(ExifData);
    end;
    Result := Now;
    for I := 1 to Min(4, Files.Count) - 1 do
      if Dates[I + 1] <> Dates[1] then
      begin
        Result := Now;
        Exit;
      end
      else
        Result := Dates[1];
  finally
    F(Files);
  end;
end;

procedure TGetToPersonalFolderForm.Execute(Pach: string);
var
  Date: TDateTime;
  Mask: string;
  I: Integer;
  OldMode: Cardinal;
begin
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    FPath := Pach;
    if CheckBox2.Checked then
    begin
      Mask := EdMultimediaMask.Text;
      Mask := '|' + Mask + '|';
      for I := Length(Mask) downto 2 do
        if (Mask[I] = '|') and (Mask[I - 1] = '|') then
          Delete(Mask, I, 1);
      if Length(Mask) > 0 then
        Delete(Mask, 1, 1);
      Mask := SupportedExt + Mask;
    end
    else
      Mask := SupportedExt;
    Date := GetPhotosDate(Mask, Pach);
  finally
    SetErrorMode(OldMode);
  end;
  if Date = -1 then
    Exit;

  DtpFromDate.DateTime := Date;
  EdFolderMaskChange(Self);
  Show;
end;

procedure TGetToPersonalFolderForm.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Import of photos');
    LbDate.Caption := L('Date of photos') + ':';
    CbOpenFolder.Caption := L('Open this folder');
    Label2.Caption := L('Folder mask') + ':';
    Label3.Caption := L('Comment for folder') + ':';
    MemComment.Text := L('Your comment');  //TODO: shadow
    Label4.Caption := L('Folder name') + ':';
    Label5.Caption := L('Final location');
    Label6.Caption := L('Method') + ':';
    CbMethod.Items.Clear;
    CbMethod.Items.Add(L('Move'));
    CbMethod.Items.Add(L('Copy'));
    BtnCancel.Caption := L('Cancel');
    BtnOk.Caption := L('Ok');
    BtnSave.Caption := L('Save');
    CheckBox2.Caption := L('Copy multimedia files');
    CbAddProtosToDB.Caption := L('Add folder');
    LbListComment.Caption := L('Series of pictures by dates') + ':';
    LvMain.Columns[0].Caption := L('Options');
    LvMain.Columns[1].Caption := L('Date');

    MoveUp1.Caption := L('Up');
    MoveDown1.Caption := L('Down');
    Remove1.Caption := L('Delete');

    SimpleCopy1.Caption := L('Separate folder');
    MergeUp1.Caption := L('Merge up');
    MergeDown1.Caption := L('Merge down');
    DontCopy1.Caption := L('Skip');
    ShowImages1.Caption := L('Show photos');

    BtnScanDates.Caption := L('Scan directory');
  finally
    EndTranslate;
  end;
end;

procedure TGetToPersonalFolderForm.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TGetToPersonalFolderForm.FormCreate(Sender: TObject);
begin
  Width := 273;
  ExtendedButton.Left := 248;
  ExtendedMode := False;
  GetPhotosFormSID := GetGUID;
  ThreadInProgress := False;
  LoadLanguage;
  if DirectoryExists(Settings.ReadString('GetPhotos', 'DFolder')) then
    EdFolder.Text := Settings.ReadString('GetPhotos', 'DFolder')
  else
  begin
    EdFolder.Text := GetMyPicturesPath;
  end;
  OptionsImageList.BkColor := ClWindow;
  ImageList_ReplaceIcon(OptionsImageList.Handle, -1, Icons[DB_IC_SENDTO + 1]);
  ImageList_ReplaceIcon(OptionsImageList.Handle, -1, Icons[DB_IC_UP + 1]);
  ImageList_ReplaceIcon(OptionsImageList.Handle, -1, Icons[DB_IC_DOWN + 1]);
  ImageList_ReplaceIcon(OptionsImageList.Handle, -1, Icons[DB_IC_DELETE_INFO + 1]);
  PmListView.Images := DBKernel.ImageList;

  MoveUp1.ImageIndex := DB_IC_UP;
  MoveDown1.ImageIndex := DB_IC_DOWN;
  Remove1.ImageIndex := DB_IC_DELETE_INFO;
  SimpleCopy1.ImageIndex := DB_IC_SENDTO;
  MergeUp1.ImageIndex := DB_IC_UP;
  MergeDown1.ImageIndex := DB_IC_DOWN;
  DontCopy1.ImageIndex := DB_IC_DELETE_INFO;
  ShowImages1.ImageIndex := DB_IC_SLIDE_SHOW;

  CbOpenFolder.Checked := Settings.ReadBool('GetPhotos', 'OpenFolder', True);
  CbAddProtosToDB.Checked := Settings.ReadBool('GetPhotos', 'AddPhotos', True);
  if Settings.ReadString('GetPhotos', 'MaskFolder') <> '' then
    EdFolderMask.Text := Settings.ReadString('GetPhotos', 'MaskFolder')
  else
    EdFolderMask.Text := '%yy:mm:dd = %YMD (%coment)';

  MemComment.Text := Settings.ReadString('GetPhotos', 'Comment', L('Your comment'));

  case Settings.ReadInteger('GetPhotos', 'GetMethod', 0) of
    0:
      CbMethod.ItemIndex := 0;
    1:
      CbMethod.ItemIndex := 1;
  else
    CbMethod.ItemIndex := 0;
  end;
  EdFolderMaskChange(Sender);

  CheckBox2.Checked := Settings.ReadBool('GetPhotos', 'UseMultimediaMask', True);
  EdMultimediaMask.Text := Settings.ReadString('GetPhotos', 'MultimediaMask', MultimediaBaseFiles)
end;

procedure TGetToPersonalFolderForm.BtnChooseFolderClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := UnitDBFileDialogs.DBSelectDir(Handle, L('Select a folder to place images'), EdFolder.Text,
    UseSimpleSelectFolderDialog);

  if DirectoryExists(Dir) then
    EdFolder.Text := Dir;
end;

procedure TGetToPersonalFolderForm.EdFolderMaskChange(Sender: TObject);
var
  Options: TGetImagesOptions;
  I, GroupTag: Integer;
begin
  MemFolderName.Text := FormatFolderName(EdFolderMask.Text, MemComment.Text, DtpFromDate.DateTime);
  if ExtendedMode then
    if LvMain.Selected <> nil then
    begin
      Options.Date := DtpFromDate.Date;
      Options.FolderMask := EdFolderMask.Text;
      Options.Comment := MemComment.Text;
      Options.ToFolder := EdFolder.Text;
      Options.GetMultimediaFiles := CheckBox2.Checked;
      Options.MultimediaMask := EdMultimediaMask.Text;
      Options.Move := CbMethod.ItemIndex = 0;
      Options.OpenFolder := CbOpenFolder.Checked;
      Options.AddFolder := CbAddProtosToDB.Checked;
      OptionsArray[LvMain.Selected.index] := Options;
      GroupTag := TItemRecordOptions(LvMain.Items[LvMain.Selected.index].Data).Tag;

      // look index-down
      for I := LvMain.Selected.index downto 0 do
        if TItemRecordOptions(LvMain.Items[I].Data).Tag = GroupTag then
          OptionsArray[I] := Options
        else
          Break;

      // look index-ip
      for I := LvMain.Selected.index to LvMain.Items.Count - 1 do
        if TItemRecordOptions(LvMain.Items[I].Data).Tag = GroupTag then
          OptionsArray[I] := Options
        else
          Break;

    end;
end;

procedure TGetToPersonalFolderForm.BtnSaveClick(Sender: TObject);
begin
  Settings.WriteBool('GetPhotos', 'OpenFolder', CbOpenFolder.Checked);
  Settings.WriteBool('GetPhotos', 'AddPhotos', CbAddProtosToDB.Checked);
  Settings.WriteString('GetPhotos', 'DFolder', EdFolder.Text);
  Settings.WriteString('GetPhotos', 'MaskFolder', EdFolderMask.Text);
  Settings.WriteString('GetPhotos', 'Comment', MemComment.Text);
  Settings.WriteInteger('GetPhotos', 'GetMethod', CbMethod.ItemIndex);
  Settings.WriteString('GetPhotos', 'MultimediaMask', EdMultimediaMask.Text);
  Settings.WriteBool('GetPhotos', 'UseMultimediaMask', CheckBox2.Checked);
end;

procedure TGetToPersonalFolderForm.BtnOkClick(Sender: TObject);
var
  Files: TStrings;
  MaxFiles, FilesSearch,
  I, J: Integer;
  Folder, Mask: string;
  Options: TGetImagesOptions;
  ItemOptions: TItemRecordOptions;
  Date: TDateTime;
begin

  if ExtendedMode then
  begin

    DtpFromDate.Enabled := False;
    EdFolderMask.Enabled := False;
    MemComment.Enabled := False;
    EdFolder.Enabled := False;
    CheckBox2.Enabled := False;
    EdMultimediaMask.Enabled := False;
    CbMethod.Enabled := False;
    CbOpenFolder.Enabled := False;
    CbAddProtosToDB.Enabled := False;
    LvMain.Enabled := False;
    BtnOk.Enabled := False;
    BtnCancel.Enabled := False;
    BtnChooseFolder.Enabled := False;
    BtnSave.Enabled := False;
    BtnScanDates.Enabled := False;

    // EXTENDED LOADING FILES
    for I := 0 to LvMain.Items.Count - 1 do
    begin
      ItemOptions := TItemRecordOptions(LvMain.Items[I].Data);
      if ItemOptions.Options = DIRECTORY_OPTION_DATE_EXCLUDE then
        Continue;
      Options := OptionsArray[I];

      Folder := IncludeTrailingBackslash(Options.ToFolder);
      Folder := Folder + FormatFolderName(Options.FolderMask, Options.Comment, Options.Date);
      CreateDirA(Folder);
      if not DirectoryExists(Folder) then
      begin
        MessageBoxDB(Handle, Format(L('Unable to create directory: "%s"'), [Folder]), L('Error'), TD_BUTTON_OK,
          TD_ICON_ERROR);
        Exit;
      end;
      Files := TStringList.Create;
      try
        Date := TItemRecordOptions(LvMain.Items[I].Data).Date;
        TItemRecordOptions(LvMain.Items[I].Data).Tag := -1;
        LvMain.Refresh;
        for J := 0 to Length(FDataList) - 1 do
          if FDataList[J].Date = Date then
            Files.Add(FDataList[J].FileName);

        if Options.OpenFolder then
          with ExplorerManager.NewExplorer(False) do
          begin
            SetPath(Folder);
            Show;
            SetFocus;
          end;
        // TODO:
        // WHAT IT??????
        GetFileNameById(0);
        Delay(1500);
        /// ///////////////

        try
          CopyFilesSynch(0, Files, Folder, Options.Move, True);
        except
          MessageBoxDB(Handle, L('An error occurred during the preparation of photographs. Perhaps you''re trying to move pictures from media which is read-only'), L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
        end;
        if Options.AddFolder then
        begin
          if UpdaterDB = nil then
            UpdaterDB := TUpdaterDB.Create;
          UpdaterDB.AddDirectory(Folder, nil);
        end;
      finally
        F(Files);
      end;
    end;
    // END
  end else
  begin

    Folder := IncludeTrailingBackslash(EdFolder.Text);
    Folder := Folder + MemFolderName.Text;
    CreateDirA(Folder);
    if not DirectoryExists(Folder) then
    begin
      MessageBoxDB(Handle, Format(L('Unable to create directory: "%s"'), [Folder]), L('Error'), TD_BUTTON_OK,
        TD_ICON_ERROR);
      Exit;
    end;

    Files := TStringList.Create;
    try
      MaxFiles := 10000;
      FilesSearch := 100000;
      if CheckBox2.Checked then
      begin
        Mask := EdMultimediaMask.Text;
        Mask := '|' + Mask + '|';
        for I := Length(Mask) downto 2 do
          if (Mask[I] = '|') and (Mask[I - 1] = '|') then
            Delete(Mask, I, 1);
        if Length(Mask) > 0 then
          Delete(Mask, 1, 1);
        Mask := SupportedExt + Mask;
      end
      else
        Mask := SupportedExt;
      GetFileNamesFromDrive(FPath, Mask, Files, FilesSearch, MaxFiles);

      Hide;
      if CbOpenFolder.Checked then
        with ExplorerManager.NewExplorer(False) do
        begin
          SetPath(Folder);
          Show;
          SetFocus;
        end;
      // WHAT IT??????
      GetFileNameById(0);
      Delay(1500);
      /// ///////////////
      try
        CopyFilesSynch(0, Files, Folder, CbMethod.ItemIndex <> 1, True);
      except
        MessageBoxDB(Handle, L('An error occurred during the preparation of photographs. Perhaps you''re trying to move pictures from media which is read-only'), L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
      end;
      if CbAddProtosToDB.Checked then
      begin
        if UpdaterDB = nil then
          UpdaterDB := TUpdaterDB.Create;
        UpdaterDB.AddDirectory(Folder, nil);
      end;

    finally
      F(Files);
    end;
  end;

  Close;
end;

procedure TGetToPersonalFolderForm.CheckBox2Click(Sender: TObject);
begin
  EdMultimediaMask.Enabled := CheckBox2.Checked;
  EdFolderMaskChange(Sender);
end;

procedure TGetToPersonalFolderForm.ClearList;
var
  I : Integer;
begin
  for I := 0 to LvMain.Items.Count - 1 do
    TObject(LvMain.Items[I].Data).Free;

  LvMain.Clear;
end;

procedure TGetToPersonalFolderForm.DestroyTimerTimer(Sender: TObject);
begin
  DestroyTimer.Enabled := False;
  Release;
end;

procedure TGetToPersonalFolderForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DestroyTimer.Enabled := True;
end;

procedure TGetToPersonalFolderForm.BtnScanDatesClick(Sender: TObject);
var
  Options: TScanImportPhotosThreadOptions;
begin
  ThreadInProgress := True;
  Options.Directory := FPath;
  Options.Mask := EdMultimediaMask.Text;
  Options.OnEnd := OnEndScanFolder;
  Options.Owner := Self;
  Options.OnProgress := OnLoadingFilesCallBackEvent;
  TScanImportPhotosThread.Create(False, Options);
  ProgressBar.Visible := True;
  BtnScanDates.Visible := False;
end;

procedure TGetToPersonalFolderForm.OnEndScanFolder(Sender: TObject);
begin
  ThreadInProgress := False;
  ProgressBar.Visible := ThreadInProgress;
  BtnScanDates.Visible := not ThreadInProgress;
  RecountGroups;
  LvMain.Refresh;
  if ExtendedMode then
    BtnOk.Enabled := LvMain.Items.Count > 0;
  //
end;

procedure TGetToPersonalFolderForm.FormDestroy(Sender: TObject);
begin
  ClearList;
  GetPhotosFormSID := GetGUID; // to prevent Thread AV
end;

function TGetToPersonalFolderForm.GetFormID: string;
begin
  Result := 'GetPhotos';
end;

procedure TGetToPersonalFolderForm.OnLoadingFilesCallBackEvent(Sender: TObject; var Info: TProgressCallBackInfo);
begin
  ProgressBar.MaxValue := 1;
  ProgressBar.Position := 0;
  ProgressBar.Text := Mince(Info.Information, 25);
end;

procedure TGetToPersonalFolderForm.SetDataList(DataList: TFileDateList);
var
  I: Integer;
  LastDate: TDateTime;
  P: TItemRecordOptions;
  Options: TGetImagesOptions;
begin
  FDataList := DataList;
  LastDate := 0;
  ClearList;
  SetLength(OptionsArray, 0);
  for I := 0 to Length(FDataList) - 1 do
  begin
    if (LastDate = 0) or (LastDate <> FDataList[I].Date) then
      with LvMain.Items.Add do
      begin
        LastDate := FDataList[I].Date;
        P := TItemRecordOptions.Create;
        P.StringDate := DateToStr(FDataList[I].Date);
        P.Date := FDataList[I].Date;
        P.Options := DIRECTORY_OPTION_DATE_SINGLE;
        P.Tag := 0;
        Data := P;

        Options.Date := FDataList[I].Date;
        Options.FolderMask := EdFolderMask.Text;
        Options.Comment := MemComment.Text;
        Options.ToFolder := EdFolder.Text;
        Options.GetMultimediaFiles := CheckBox2.Checked;
        Options.MultimediaMask := EdMultimediaMask.Text;
        Options.Move := CbMethod.ItemIndex = 0;
        Options.OpenFolder := CbOpenFolder.Checked;
        Options.AddFolder := CbAddProtosToDB.Checked;
        SetLength(OptionsArray, Length(OptionsArray) + 1);
        OptionsArray[Length(OptionsArray) - 1] := Options;
      end;
  end;
end;

procedure TGetToPersonalFolderForm.LvMainResize(Sender: TObject);
begin
  LvMain.Columns[1].Width := LvMain.Width - LvMain.Columns[0].Width - 5;
end;

procedure TGetToPersonalFolderForm.LvMainAdvancedCustomDrawItem(Sender: TCustomListView; Item: TListItem;
  State: TCustomDrawState; Stage: TCustomDrawStage; var DefaultDraw: Boolean);
var
  ARect: TRect;
  I: Integer;
  Data : TItemRecordOptions;

  function MergeColors(Color1, Color2: TColor): TColor;
  var
    R, G, B: Byte;
  begin
    Color1 := ColorToRGB(Color1) and $00FFFFFF;
    Color2 := ColorToRGB(Color2) and $00FFFFFF;
    R := (GetRValue(Color1) * 2 + GetRValue(Color2)) div 3;
    G := (GetGValue(Color1) * 2 + GetGValue(Color2)) div 3;
    B := (GetBValue(Color1) * 2 + GetBValue(Color2)) div 3;
    Result := RGB(R, G, B);
  end;

begin
  Data := TItemRecordOptions(Item.Data);
  for I := 0 to 1 do
  begin
    ListView_GetSubItemRect(LvMain.Handle, Item.index, I, 0, @ARect);

    if Item.Selected then
    begin
      Sender.Canvas.Brush.Color := ClHighlight;
      Sender.Canvas.Pen.Color := ClHighlight;
    end else
    begin
      if Data.Tag = 1 then
      begin
        Sender.Canvas.Brush.Color := MergeColors(ClWindow, ClRed);
        Sender.Canvas.Pen.Color := MergeColors(ClWindow, ClRed);
      end;
      if Data.Tag = 0 then
      begin
        Sender.Canvas.Brush.Color := MergeColors(ClWindow, ClGreen);
        Sender.Canvas.Pen.Color := MergeColors(ClWindow, ClGreen);
      end;
      if Data.Tag = -1 then
      begin
        Sender.Canvas.Brush.Color := MergeColors(ClWindow, ClBlue);
        Sender.Canvas.Pen.Color := MergeColors(ClWindow, ClBlue);
      end;
    end;
    Sender.Canvas.Rectangle(ARect);
    if I = 0 then
      OptionsImageList.Draw(Sender.Canvas, ARect.Left, Item.Top, Data.Options);
    if I = 1 then
      Sender.Canvas.TextOut(ARect.Left, Item.Top, Mince(Data.StringDate, 50));

    DefaultDraw := True;
  end;
end;

procedure TGetToPersonalFolderForm.ExtendedButtonClick(Sender: TObject);
begin
  if ExtendedMode then
  begin
    ExtendedMode := False;
    DtpFromDate.Enabled := True;
    EdFolderMask.Enabled := True;
    MemComment.Enabled := True;
    EdFolder.Enabled := True;
    CheckBox2.Enabled := True;
    EdMultimediaMask.Enabled := True;
    CbMethod.Enabled := True;
    CbOpenFolder.Enabled := True;
    CbAddProtosToDB.Enabled := True;

    try
      DtpFromDate.Date := DefaultOptions.Date;
    except
    end;
    EdFolderMask.Text := DefaultOptions.FolderMask;
    MemComment.Text := DefaultOptions.Comment;
    EdFolder.Text := DefaultOptions.ToFolder;
    CheckBox2.Checked := DefaultOptions.GetMultimediaFiles;
    EdMultimediaMask.Text := DefaultOptions.MultimediaMask;
    if DefaultOptions.Move then
      CbMethod.ItemIndex := 0
    else
      CbMethod.ItemIndex := 1;
    CbOpenFolder.Checked := DefaultOptions.OpenFolder;
    CbAddProtosToDB.Checked := DefaultOptions.AddFolder;

    Width := 273;
    BtnCancel.Left := 104;
    BtnOk.Left := 176;
    BtnScanDates.Visible := False;
    ProgressBar.Visible := False;
    LbListComment.Visible := False;
    LvMain.Visible := False;
    ExtendedButton.Caption := '>';
    ExtendedButton.Left := 248;
    BtnOk.Enabled := True;
  end else
  begin

    DefaultOptions.Date := DtpFromDate.Date;
    DefaultOptions.FolderMask := EdFolderMask.Text;
    DefaultOptions.Comment := MemComment.Text;
    DefaultOptions.ToFolder := EdFolder.Text;
    DefaultOptions.GetMultimediaFiles := CheckBox2.Checked;
    DefaultOptions.MultimediaMask := EdMultimediaMask.Text;
    DefaultOptions.Move := CbMethod.ItemIndex = 0;
    DefaultOptions.OpenFolder := CbOpenFolder.Checked;
    DefaultOptions.AddFolder := CbAddProtosToDB.Checked;

    if LvMain.Selected = nil then
    begin
      DtpFromDate.Enabled := False;
      EdFolderMask.Enabled := False;
      MemComment.Enabled := False;
      EdFolder.Enabled := False;
      CheckBox2.Enabled := False;
      EdMultimediaMask.Enabled := False;
      CbMethod.Enabled := False;
      CbOpenFolder.Enabled := False;
      CbAddProtosToDB.Enabled := False;
    end else
      LvMainSelectItem(LvMain, LvMain.Selected, True);

    BtnCancel.Left := 344;
    BtnOk.Left := 416;
    BtnOk.Enabled := LvMain.Items.Count > 0;
    LbListComment.Visible := True;
    LvMain.Visible := True;
    ProgressBar.Visible := ThreadInProgress;
    BtnScanDates.Visible := not ThreadInProgress;
    Width := 513;
    ExtendedMode := True;
    ExtendedButton.Caption := '<';
    ExtendedButton.Left := 488;
  end;
end;

procedure TGetToPersonalFolderForm.LvMainContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
var
  Item: TListItem;
begin
  Item := LvMain.GetItemAt(10, MousePos.Y);
  if Item <> nil then
  begin
    PmListView.Tag := Item.index;
    Item.Selected := True;
    MoveUp1.Visible := Item.index > 0;
    MoveDown1.Visible := Item.index < LvMain.Items.Count - 1;

    MergeUp1.Visible := MoveUp1.Visible;
    MergeDown1.Visible := MoveDown1.Visible;

    case TItemRecordOptions(Item.Data).Options of
      DIRECTORY_OPTION_DATE_SINGLE:
        SimpleCopy1.default := True;
      DIRECTORY_OPTION_DATE_WITH_UP:
        MergeUp1.default := True;
      DIRECTORY_OPTION_DATE_WITH_DOWN:
        MergeDown1.default := True;
      DIRECTORY_OPTION_DATE_EXCLUDE:
        DontCopy1.default := True;
    end;
    PmListView.Popup(LvMain.ClientToScreen(MousePos).X, LvMain.ClientToScreen(MousePos).Y);
  end;
end;

procedure TGetToPersonalFolderForm.SimpleCopy1Click(Sender: TObject);
begin
  FDataList[PmListView.Tag].Options := DIRECTORY_OPTION_DATE_SINGLE;
  TItemRecordOptions(LvMain.Items[PmListView.Tag].Data).Options := DIRECTORY_OPTION_DATE_SINGLE;
  RecountGroups;
  LvMain.Refresh;
end;

procedure TGetToPersonalFolderForm.MergeUp1Click(Sender: TObject);
begin
  FDataList[PmListView.Tag].Options := DIRECTORY_OPTION_DATE_WITH_UP;
  TItemRecordOptions(LvMain.Items[PmListView.Tag].Data).Options := DIRECTORY_OPTION_DATE_WITH_UP;
  OptionsArray[PmListView.Tag] := OptionsArray[PmListView.Tag - 1];
  RecountGroups;
  LvMain.Refresh;
end;

procedure TGetToPersonalFolderForm.MergeDown1Click(Sender: TObject);
begin
  FDataList[PmListView.Tag].Options := DIRECTORY_OPTION_DATE_WITH_DOWN;
  TItemRecordOptions(LvMain.Items[PmListView.Tag].Data).Options := DIRECTORY_OPTION_DATE_WITH_DOWN;
  OptionsArray[PmListView.Tag] := OptionsArray[PmListView.Tag + 1];
  RecountGroups;
  LvMain.Refresh;
end;

procedure TGetToPersonalFolderForm.DontCopy1Click(Sender: TObject);
begin
  FDataList[PmListView.Tag].Options := DIRECTORY_OPTION_DATE_EXCLUDE;
  TItemRecordOptions(LvMain.Items[PmListView.Tag].Data).Options := DIRECTORY_OPTION_DATE_EXCLUDE;
  RecountGroups;
  LvMain.Refresh;
end;

procedure TGetToPersonalFolderForm.RecountGroups;
var
  I: Integer;
  LastGroup: Boolean;
  CurrentRecord, NextRecord: TItemRecordOptions;
begin
  LastGroup := False;
  for I := 0 to LvMain.Items.Count - 2 do
  begin
    CurrentRecord := TItemRecordOptions(LvMain.Items[I].Data);
    NextRecord := TItemRecordOptions(LvMain.Items[I + 1].Data);
    if LastGroup then
      TItemRecordOptions(LvMain.Items[I].Data).Tag := 0
    else
      TItemRecordOptions(LvMain.Items[I].Data).Tag := 1;
    if (CurrentRecord.Options = DIRECTORY_OPTION_DATE_WITH_DOWN) and
      (NextRecord.Options = DIRECTORY_OPTION_DATE_EXCLUDE) then
    begin
      Continue;
    end;
    if (CurrentRecord.Options = DIRECTORY_OPTION_DATE_WITH_DOWN) and
      (NextRecord.Options = DIRECTORY_OPTION_DATE_SINGLE) then
    begin
      Continue;
    end;
    if (CurrentRecord.Options = DIRECTORY_OPTION_DATE_WITH_DOWN) and
      (NextRecord.Options = DIRECTORY_OPTION_DATE_WITH_DOWN) then
    begin
      Continue;
    end;
    if (CurrentRecord.Options = DIRECTORY_OPTION_DATE_EXCLUDE)
       and (NextRecord.Options = DIRECTORY_OPTION_DATE_WITH_UP) then
      Continue;
    if (CurrentRecord.Options = DIRECTORY_OPTION_DATE_SINGLE)
       and (NextRecord.Options = DIRECTORY_OPTION_DATE_WITH_UP) then
      Continue;

    if (CurrentRecord.Options = DIRECTORY_OPTION_DATE_WITH_UP)
       and (NextRecord.Options = DIRECTORY_OPTION_DATE_WITH_UP) then
      Continue;

    LastGroup := not LastGroup;
  end;
  I := LvMain.Items.Count - 1;
  if I > -1 then
  begin
    CurrentRecord := TItemRecordOptions(LvMain.Items[I].Data);
    if CurrentRecord.Options <> DIRECTORY_OPTION_DATE_WITH_UP then
    begin
      if LastGroup then
        TItemRecordOptions(LvMain.Items[I].Data).Tag := 0
      else
        TItemRecordOptions(LvMain.Items[I].Data).Tag := 1;
    end else
    begin
      if LastGroup then
        TItemRecordOptions(LvMain.Items[I].Data).Tag := 1
      else
        TItemRecordOptions(LvMain.Items[I].Data).Tag := 0;
    end;
  end else
  begin
    Hide;
    MessageBoxDB(Handle, L('No photos found! Window will be closed!'), L('Information'), TD_BUTTON_OK, TD_ICON_WARNING);
    Close;
  end;
end;

procedure TGetToPersonalFolderForm.ShowImages1Click(Sender: TObject);
var
  Info: TDBPopupMenuInfo;
  InfoItem: TDBPopupMenuInfoRecord;
  I: Integer;
  Date: TDateTime;

  function L_Less_Than_R(L, R: TFileDateRecord): Boolean;
  begin
    Result := SysUtils.CompareText(ExtractFileName(L.FileName), ExtractFileName(R.FileName)) < 0;
  end;

  procedure Swap(var X: TFileDateList; I, J: Integer);
  var
    Temp: TFileDateRecord;
  begin
    Temp := X[I];
    X[I] := X[J];
    X[J] := Temp;
  end;

  procedure Qsort(var X: TFileDateList; Left, Right: Integer);
  label Again;
  var
    Pivot: TFileDateRecord;
    P, Q: Integer;
    M: Integer;
  begin
    P := Left;
    Q := Right;
    M := (Left + Right) div 2;
    Pivot := X[M];

    while P <= Q do
    begin
      while L_Less_Than_R(X[P], Pivot) do
      begin
        if P = M then
          Break;
        Inc(P);
      end;
      while L_Less_Than_R(Pivot, X[Q]) do
      begin
        if Q = M then
          Break;
        Dec(Q);
      end;
      if P > Q then
        goto Again;
      Swap(X, P, Q);
      Inc(P);
      Dec(Q);
    end;

  Again :
    if Left < Q then
      Qsort(X, Left, Q);
    if P < Right then
      Qsort(X, P, Right);
  end;

  procedure QuickSort(var X: TFileDateList; N: Integer);
  begin
    Qsort(X, 0, N - 1);
  end;

begin
  if Viewer = nil then
    Application.CreateForm(TViewer, Viewer);

  Info := TDBPopupMenuInfo.Create;
  try

    Date := TItemRecordOptions(LvMain.Items[PmListView.Tag].Data).Date;
    QuickSort(FDataList, Length(FDataList));
    for I := 0 to Length(FDataList) - 1 do
    begin
      if Date = FDataList[I].Date then
      begin
        InfoItem := TDBPopupMenuInfoRecord.CreateFromFile(FDataList[I].FileName);
        InfoItem.Date := FDataList[I].Date;
        Info.Add(InfoItem);
      end;
    end;
    Viewer.Execute(Sender, Info);
    Viewer.Show;

  except
    F(Info);
  end;
end;

procedure TGetToPersonalFolderForm.Remove1Click(Sender: TObject);
var
  I: Integer;
begin
  if ID_OK <> MessageBoxDB(Handle, L('Do you really want to delete this item?'), L('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
    Exit;

  LvMain.Items.Delete(PmListView.Tag);
  for I := PmListView.Tag to Length(OptionsArray) - 2 do
    OptionsArray[I] := OptionsArray[I + 1];
  SetLength(OptionsArray, Length(OptionsArray) - 1);
  RecountGroups;
  LvMain.Refresh;
end;

procedure TGetToPersonalFolderForm.MoveUp1Click(Sender: TObject);
var
  P: Pointer;
begin
  P := LvMain.Items[PmListView.Tag - 1].Data;
  LvMain.Items[PmListView.Tag - 1].Data := LvMain.Items[PmListView.Tag].Data;
  LvMain.Items[PmListView.Tag].Data := P;
  RecountGroups;
  LvMain.Refresh;
end;

procedure TGetToPersonalFolderForm.MoveDown1Click(Sender: TObject);
var
  P: Pointer;
begin
  P := LvMain.Items[PmListView.Tag + 1].Data;
  LvMain.Items[PmListView.Tag + 1].Data := LvMain.Items[PmListView.Tag].Data;
  LvMain.Items[PmListView.Tag].Data := P;
  RecountGroups;
  LvMain.Refresh;
end;

procedure TGetToPersonalFolderForm.LvMainSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  Options: TGetImagesOptions;
begin
  if (Item <> nil) and Selected then
  begin
    DtpFromDate.Enabled := True;
    EdFolderMask.Enabled := True;
    MemComment.Enabled := True;
    EdFolder.Enabled := True;
    CheckBox2.Enabled := True;
    EdMultimediaMask.Enabled := True;
    CbMethod.Enabled := True;
    CbOpenFolder.Enabled := True;
    CbAddProtosToDB.Enabled := True;

    Options := OptionsArray[Item.index];
    try
      DtpFromDate.Date := Options.Date;
    except
    end;
    EdFolderMask.Text := Options.FolderMask;
    MemComment.Text := Options.Comment;
    EdFolder.Text := Options.ToFolder;
    CheckBox2.Checked := Options.GetMultimediaFiles;
    EdMultimediaMask.Text := Options.MultimediaMask;
    if Options.Move then
      CbMethod.ItemIndex := 0
    else
      CbMethod.ItemIndex := 1;

    CbOpenFolder.Checked := Options.OpenFolder;
    CbAddProtosToDB.Checked := Options.AddFolder;
    EdFolderMaskChange(Self);
  end else
  begin
    DtpFromDate.Enabled := False;
    EdFolderMask.Enabled := False;
    MemComment.Enabled := False;
    EdFolder.Enabled := False;
    CheckBox2.Enabled := False;
    EdMultimediaMask.Enabled := False;
    CbMethod.Enabled := False;
    CbOpenFolder.Enabled := False;
    CbAddProtosToDB.Enabled := False;
  end;
end;

function TGetToPersonalFolderForm.FormatFolderName(Mask, Comment: String;
  Date: TDateTime): String;
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
  S := StringReplace(S, '%YMD', FineDate + L('y.'), [RfReplaceAll, RfIgnoreCase]);
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
