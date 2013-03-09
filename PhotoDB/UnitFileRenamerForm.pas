unit UnitFileRenamerForm;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.Grids,
  Vcl.ValEdit,
  Vcl.StdCtrls,
  Vcl.Menus,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnPopup,
  Vcl.Samples.Spin,
  Data.DB,

  Dmitry.Utils.Files,
  Dmitry.Controls.Base,
  Dmitry.Controls.WebLink,

  uConstants,
  UnitDBDeclare,
  UnitDBKernel,
  Dolphin_DB,

  uMemory,
  uDBForm,
  uProgramStatInfo,
  uShellIntegration,
  uDBBaseTypes,
  uDBUtils,
  uSettings;

type
  TFormFastFileRenamer = class(TDBForm)
    ValueListEditor1: TValueListEditor;
    Panel1: TPanel;
    Panel2: TPanel;
    LblTitle: TLabel;
    pmSort: TPopupActionBar;
    SortbyFileName1: TMenuItem;
    SortbyFileSize1: TMenuItem;
    BtnHelp: TButton;
    Panel3: TPanel;
    BtnOK: TButton;
    BtnCancel: TButton;
    CheckBox1: TCheckBox;
    Label2: TLabel;
    CmMaskList: TComboBox;
    BtAdd: TButton;
    BtDelete: TButton;
    SortbyFileNumber1: TMenuItem;
    SortbyModified1: TMenuItem;
    SortbyFileType1: TMenuItem;
    WebLinkWarning: TWebLink;
    SedStartN: TSpinEdit;
    procedure FormCreate(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure BtnHelpClick(Sender: TObject);
    procedure SortbyFileName1Click(Sender: TObject);
    procedure SortbyFileSize1Click(Sender: TObject);
    procedure SortbyFileNumber1Click(Sender: TObject);
    procedure SortbyFileType1Click(Sender: TObject);
    procedure SortbyModified1Click(Sender: TObject);
    procedure BtAddClick(Sender: TObject);
    procedure BtDeleteClick(Sender: TObject);
    procedure WebLinkWarningClick(Sender: TObject);
    procedure KernelEventCallBack(ID: Integer; Params: TEventFields; Value: TEventValues);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  protected
    function GetFormID : string; override;
    procedure SaveSettings;
  public
    { Public declarations }
    FFiles: TStrings;
    FIDS: TArInteger;
    procedure SetFiles(Files: TStrings; IDS: TArInteger);
    procedure SetFilesA;
    procedure LoadLanguage;
    procedure DoCalculateRename;
    procedure DoRename;
    function CheckConflictFileNames: Boolean;
  end;

procedure FastRenameManyFiles(Files : TStrings; IDS : TArInteger);

implementation

{$R *.dfm}

procedure FastRenameManyFiles(Files : TStrings; IDS : TArInteger);
var
  FormFastFileRenamer: TFormFastFileRenamer;
begin
  Application.CreateForm(TFormFastFileRenamer, FormFastFileRenamer);
  try
    FormFastFileRenamer.SetFiles(Files, IDS);
    FormFastFileRenamer.ShowModal;
  finally
    FormFastFileRenamer.Release;
  end;
end;

{ TFormFastFileRenamer }

procedure TFormFastFileRenamer.SaveSettings;
var
  I: Integer;
begin
  Settings.DeleteValues('Renamer');
  for I := 0 to CmMaskList.Items.Count - 1 do
    Settings.WriteString('Renamer', 'val' + IntToStr(I + 1), CmMaskList.Items[I]);

  Settings.WriteString('Options', 'RenameText', CmMaskList.Text);
end;

procedure TFormFastFileRenamer.SetFiles(Files: TStrings; IDS: TArInteger);
begin
  FFiles := Files;
  FIDS := IDS;
  SetFilesA;
end;

procedure TFormFastFileRenamer.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SaveSettings;
end;

procedure TFormFastFileRenamer.FormCreate(Sender: TObject);
var
  List: TStrings;
  I: Integer;
begin
  LoadLanguage;
  List := Settings.ReadValues('Renamer');
  try
    CmMaskList.Items.Clear;
    for I := 0 to List.Count - 1 do
      CmMaskList.Items.Add(Settings.ReadString('Renamer', List[I]));

    CmMaskList.Text := Settings.ReadString('Options', 'RenameText');
  finally
    F(List);
  end;

  if CmMaskList.Text = '' then
    CmMaskList.Text := L('Image #%3d [%date]');
  WebLinkWarning.Visible := False;
  ValueListEditor1.ColWidths[0] := ValueListEditor1.Width div 2;
end;

procedure TFormFastFileRenamer.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('File renamer');
    ValueListEditor1.TitleCaptions[0] := L('Original file name');
    ValueListEditor1.TitleCaptions[1] := L('New file name');
    BtnCancel.Caption := L('Cancel');
    BtnOk.Caption := L('Ok');

    LblTitle.Caption := L('Mask for files');
    SortbyFileName1.Caption := L('Sort by file name');
    SortbyFileSize1.Caption := L('Sort by file size');

    SortbyFileNumber1.Caption := L('Sort by file number');
    SortbyModified1.Caption := L('Sort by modified date');
    SortbyFileType1.Caption := L('Sort by file type');

    CheckBox1.Caption := L('Change extension');
    Label2.Caption := L('From number');

    BtAdd.Caption := L('Add');
    BtDelete.Caption := L('Delete');

    WebLinkWarning.Text := L('Conflict in file names!');
  finally
    EndTranslate;
  end;
end;

procedure TFormFastFileRenamer.DoCalculateRename;
var
  I, N: Integer;
  S: string;
begin
  for I := 1 to ValueListEditor1.Strings.Count do
  begin
    N := SedStartN.Value - 1 + I;
    S := CmMaskList.Text;
    S := StringReplace(S, '%fn', GetFileNameWithoutExt(ExtractFileName(ValueListEditor1.Cells[0, I])),
      [RfReplaceAll, RfIgnoreCase]);
    S := StringReplace(S, '%date', DateToStr(Now), [RfReplaceAll, RfIgnoreCase]);
    S := StringReplace(S, '%d', Format('%d', [N]), [RfReplaceAll, RfIgnoreCase]);
    S := StringReplace(S, '%1d', Format('%.1d', [N]), [RfReplaceAll, RfIgnoreCase]);
    S := StringReplace(S, '%2d', Format('%.2d', [N]), [RfReplaceAll, RfIgnoreCase]);
    S := StringReplace(S, '%3d', Format('%.3d', [N]), [RfReplaceAll, RfIgnoreCase]);
    S := StringReplace(S, '%4d', Format('%.4d', [N]), [RfReplaceAll, RfIgnoreCase]);
    S := StringReplace(S, '%5d', Format('%.5d', [N]), [RfReplaceAll, RfIgnoreCase]);
    S := StringReplace(S, '%6d', Format('%.6d', [N]), [RfReplaceAll, RfIgnoreCase]);
    S := StringReplace(S, '%h', IntToHex(N, 0), [RfReplaceAll, RfIgnoreCase]);
    S := StringReplace(S, '%1h', IntToHex(N, 1), [RfReplaceAll, RfIgnoreCase]);
    S := StringReplace(S, '%2h', IntToHex(N, 2), [RfReplaceAll, RfIgnoreCase]);
    S := StringReplace(S, '%3h', IntToHex(N, 3), [RfReplaceAll, RfIgnoreCase]);
    S := StringReplace(S, '%4h', IntToHex(N, 4), [RfReplaceAll, RfIgnoreCase]);
    S := StringReplace(S, '%5h', IntToHex(N, 5), [RfReplaceAll, RfIgnoreCase]);
    S := StringReplace(S, '%6h', IntToHex(N, 6), [RfReplaceAll, RfIgnoreCase]);
    if not CheckBox1.Checked then
    begin
      if GetExt(ValueListEditor1.Cells[0, I]) <> '' then
        S := S + '.' + AnsiLowerCase(GetExt(ValueListEditor1.Cells[0, I]));
    end;
    ValueListEditor1.Cells[1, I] := S;
  end;
end;

procedure TFormFastFileRenamer.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormFastFileRenamer.Edit1Change(Sender: TObject);
begin
  DoCalculateRename;
  WebLinkWarning.Visible := False;
end;

procedure TFormFastFileRenamer.DoRename;
var
  I: Integer;
  OldFile, NewFile: string;
begin
  for I := 1 to ValueListEditor1.Strings.Count do
    try
      OldFile := ExtractFilePath(FFiles[I - 1]) + ValueListEditor1.Cells[0, I];
      NewFile := ExtractFilePath(FFiles[I - 1]) + ValueListEditor1.Cells[1, I];
      RenamefileWithDB(KernelEventCallBack, OldFile, NewFile, FIDS[I - 1], False);
    except
      on E: Exception do
        MessageBoxDB(Handle, Format(L('An error occurred while renaming file "%s" to "%s"! Error message: %s'), [OldFile, NewFile, E.message]),
          L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
    end;
end;

procedure TFormFastFileRenamer.BtnOKClick(Sender: TObject);
begin
  ProgramStatistics.MassRenameUsed;

  if CheckConflictFileNames then
  begin
    WebLinkWarning.Visible := True;
    MessageBoxDB(Handle, L('Conflict in file names!'), L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
    Exit;
  end;

  DoRename;

  Close;
end;

procedure TFormFastFileRenamer.BtnHelpClick(Sender: TObject);
var
  Info : string;
begin
  info := L('File mask: replace %d to number, %date - current date, %fn - original file name (without extension)');
  MessageBoxDB(Handle, info, L('Info'), TD_BUTTON_OK, TD_ICON_INFORMATION);
end;

procedure TFormFastFileRenamer.SortbyFileName1Click(Sender: TObject);
var
  I, K: Integer;
  B: Boolean;
  S: string;
begin
  repeat
    B := False;
    for I := 1 to ValueListEditor1.Strings.Count - 1 do
    begin
      if AnsiCompareStr(FFiles[I - 1], FFiles[I]) > 0 then
      begin
        S := FFiles[I - 1];
        FFiles[I - 1] := FFiles[I];
        FFiles[I] := S;
        K := FIDS[I - 1];
        FIDS[I - 1] := FIDS[I];
        FIDS[I] := K;
        B := True;
      end;
    end;
  until not B;
  SetFilesA;
end;

procedure TFormFastFileRenamer.SetFilesA;
var
  I: Integer;
begin
  ValueListEditor1.Strings.Clear;
  for I := 1 to FFiles.Count do
  begin
    ValueListEditor1.Strings.Add(ExtractFileName(FFiles[I - 1]));
    ValueListEditor1.Keys[I] := ExtractFileName(FFiles[I - 1]);
  end;
  DoCalculateRename;
end;

procedure TFormFastFileRenamer.SortbyFileSize1Click(Sender: TObject);
var
  I, K: Integer;
  B: Boolean;
  S: string;
  X: array of Integer;
begin
  Setlength(X, ValueListEditor1.Strings.Count);
  for I := 1 to ValueListEditor1.Strings.Count - 1 do
    X[I - 1] := GetFileSizeByName(FFiles[I - 1]);
  repeat
    B := False;
    for I := 1 to ValueListEditor1.Strings.Count - 1 do
    begin
      if X[I - 1] < X[I] then
      begin
        S := FFiles[I - 1];
        FFiles[I - 1] := FFiles[I];
        FFiles[I] := S;
        K := X[I - 1];
        X[I - 1] := X[I];
        X[I] := K;
        K := FIDs[I - 1];
        FIDs[I - 1] := FIDs[I];
        FIDs[I] := K;
        B := True;
      end;
    end;
  until not B;
  SetFilesA;
end;

procedure TFormFastFileRenamer.SortbyFileNumber1Click(Sender: TObject);
var
  I, K: Integer;
  B: Boolean;
  S: string;
begin
  repeat
    B := False;
    for I := 1 to ValueListEditor1.Strings.Count - 1 do
    begin
      if AnsiCompareTextWithNum(FFiles[I - 1], FFiles[I]) > 0 then
      begin
        S := FFiles[I - 1];
        FFiles[I - 1] := FFiles[I];
        FFiles[I] := S;
        K := FIDS[I - 1];
        FIDS[I - 1] := FIDS[I];
        FIDS[I] := K;
        B := True;
      end;
    end;
  until not B;
  SetFilesA;
end;

procedure TFormFastFileRenamer.SortbyFileType1Click(Sender: TObject);
var
  I, K: Integer;
  B: Boolean;
  S: string;
begin
  repeat
    B := False;
    for I := 1 to ValueListEditor1.Strings.Count - 1 do
    begin
      if AnsiCompareStr(GetExt(FFiles[I - 1]), GetExt(FFiles[I])) > 0 then
      begin
        S := FFiles[I - 1];
        FFiles[I - 1] := FFiles[I];
        FFiles[I] := S;
        K := FIDS[I - 1];
        FIDS[I - 1] := FIDS[I];
        FIDS[I] := K;
        B := True;
      end;
    end;
  until not B;
  SetFilesA;
end;

procedure TFormFastFileRenamer.SortbyModified1Click(Sender: TObject);
var
  I, N: Integer;
  K: TDateTime;
  B: Boolean;
  S: string;
  X: array of TDateTime;
begin
  Setlength(X, ValueListEditor1.Strings.Count);
  for I := 1 to ValueListEditor1.Strings.Count - 1 do
    X[I - 1] := DateModify(FFiles[I - 1]);
  repeat
    B := False;
    for I := 1 to ValueListEditor1.Strings.Count - 1 do
    begin
      if X[I - 1] < X[I] then
      begin
        S := FFiles[I - 1];
        FFiles[I - 1] := FFiles[I];
        FFiles[I] := S;
        K := X[I - 1];
        X[I - 1] := X[I];
        X[I] := K;
        N := FIDs[I - 1];
        FIDs[I - 1] := FIDs[I];
        FIDs[I] := N;
        B := True;
      end;
    end;
  until not B;
  SetFilesA;
end;

procedure TFormFastFileRenamer.BtAddClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to CmMaskList.Items.Count - 1 do
    if AnsiLowerCase(CmMaskList.Items[I]) = AnsiLowerCase(CmMaskList.Text) then
      Exit;
  CmMaskList.Items.Add(CmMaskList.Text)
end;

procedure TFormFastFileRenamer.BtDeleteClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to CmMaskList.Items.Count - 1 do
    if AnsiLowerCase(CmMaskList.Items[I]) = AnsiLowerCase(CmMaskList.Text) then
    begin
      CmMaskList.Items.Delete(I);
      Exit;
    end;
end;

procedure TFormFastFileRenamer.WebLinkWarningClick(Sender: TObject);
begin
  if CheckConflictFileNames then
  begin
    MessageBoxDB(Handle, L('Conflict in file names!'), L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
    Exit;
  end;
  WebLinkWarning.Visible := False;
end;

function TFormFastFileRenamer.GetFormID: string;
begin
  Result := 'FileRenamer';
end;

procedure TFormFastFileRenamer.KernelEventCallBack(ID: Integer;
  Params: TEventFields; Value: TEventValues);
begin
  DBKernel.DoIDEvent(Self, ID, Params, Value);
end;

function TFormFastFileRenamer.CheckConflictFileNames: boolean;
var
  I, J: Integer;
  Dir: string;
  OldFiles: TArStrings;
  OldDirFiles: TArStrings;
  NewFiles: TArStrings;
begin
  Result := False;

  Dir := ExtractFilePath(FFiles[0]);
  OldDirFiles := TArStrings(GetDirListing(Dir, '||'));
  SetLength(OldFiles, ValueListEditor1.Strings.Count);
  for I := 1 to ValueListEditor1.Strings.Count do
    OldFiles[I - 1] := ExtractFilePath(FFiles[I - 1]) + ValueListEditor1.Cells[0, I];

  SetLength(NewFiles, ValueListEditor1.Strings.Count);
  for I := 1 to ValueListEditor1.Strings.Count do
    NewFiles[I - 1] := ExtractFilePath(FFiles[I - 1]) + ValueListEditor1.Cells[1, I];

  for I := 0 to Length(OldFiles) - 1 do
    for J := 0 to Length(NewFiles) - 1 do
      if AnsiLowerCase(OldFiles[I]) = AnsiLowerCase(NewFiles[J]) then
      begin
        Result := True;
        Break;
      end;

  for I := 0 to Length(OldDirFiles) - 1 do
    for J := 0 to Length(NewFiles) - 1 do
      if AnsiLowerCase(OldDirFiles[I]) = AnsiLowerCase(NewFiles[J]) then
      begin
        Result := True;
        Break;
      end;

  for I := 0 to Length(NewFiles) - 1 do
    for J := I + 1 to Length(NewFiles) - 1 do
      if AnsiLowerCase(NewFiles[I]) = AnsiLowerCase(NewFiles[J]) then
      begin
        Result := True;
        Break;
      end;
end;

end.
