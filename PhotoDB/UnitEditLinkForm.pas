unit UnitEditLinkForm;

interface

uses
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Winapi.CommCtrl,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.ImgList,
  Vcl.Imaging.pngimage,

  DragDrop,
  DragDropFile,
  DropTarget,

  Dmitry.Utils.Dialogs,
  Dmitry.Controls.WatermarkedMemo,
  Dmitry.Controls.WatermarkedEdit,
  Dmitry.Controls.ComboBoxExDB,

  UnitLinksSupport,
  UnitDBFileDialogs,
  UnitDBDeclare,

  uConstants,
  uMemory,
  uMediaInfo,
  uDBForm,
  uDBContext,
  uDBEntities,
  uDBManager,
  uShellIntegration,
  uAssociations,
  uDBIcons,
  uProgramStatInfo,
  uThemesUtils;

type
  TFormEditLink = class(TDBForm)
    Image1: TImage;
    Label1: TLabel;
    EdName: TWatermarkedEdit;
    Label2: TLabel;
    Label3: TLabel;
    BtnChooseLinkValue: TButton;
    BtnOk: TButton;
    BtnCancel: TButton;
    LblInfo: TLabel;
    DropFileTarget1: TDropFileTarget;
    EdValue: TWatermarkedMemo;
    LinkImageList: TImageList;
    CbLinkType: TComboBoxExDB;
    procedure FormCreate(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnChooseLinkValueClick(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure DropFileTarget1Drop(Sender: TObject; ShiftState: TShiftState;
      Point: TPoint; var Effect: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EdNameChange(Sender: TObject);
    procedure CbLinkTypeKeyPress(Sender: TObject; var Key: Char);
    procedure EdValueKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FProc: TSetLinkProcedure;
    FOnClose: TRemoteCloseFormProc;
    FInfo: TLinksInfo;
    FN: Integer;
    FAdd: Boolean;
  protected
    function GetFormID : string; override;
    procedure CustomFormAfterDisplay; override;
  public
    { Public declarations }
    procedure Execute(Add: Boolean; var Info: TLinksInfo; Proc: TSetLinkProcedure; OnClose: TRemoteCloseFormProc);
    procedure LoadLanguage;
  end;

function AddNewLink(Add : Boolean; var info : TLinksInfo; Proc : TSetLinkProcedure; OnClose : TRemoteCloseFormProc) : TForm;

implementation

{$R *.dfm}

function AddNewLink(Add : Boolean; var info : TLinksInfo; Proc : TSetLinkProcedure; OnClose : TRemoteCloseFormProc) : TForm;
var
  FormEditLink: TFormEditLink;
begin
  Application.CreateForm(TFormEditLink, FormEditLink);
  FormEditLink.Execute(Add, Info, Proc, OnClose);
  Result := FormEditLink;
end;

{ TFormEditLink }

procedure TFormEditLink.Execute(Add: Boolean; var info: TLinksInfo; Proc : TSetLinkProcedure; OnClose : TRemoteCloseFormProc);
var
  I: Integer;
begin
  FOnClose := OnClose;
  FProc := Proc;
  FAdd := Add;
  FInfo := CopyLinksInfo(Info);
  if Add then
  begin
    Caption := L('Add link');
  end else
  begin
    FN := 0;
    for I := 0 to Length(FInfo) - 1 do
      if (FInfo[I].Tag and LINK_TAG_SELECTED) <> 0 then
      begin
        FN := I;
        Break;
      end;
    CbLinkType.ItemIndex := FInfo[FN].LinkType;
    EdName.Text := FInfo[FN].LinkName;
    if FInfo[FN].Tag and LINK_TAG_VALUE_VAR_NOT_SELECT = 0 then
      EdValue.Text := FInfo[FN].LinkValue
    else
      EdValue.Text := L('Different values');
    Caption := L('Edit link');
  end;
  Show;
end;

procedure TFormEditLink.FormCreate(Sender: TObject);
var
  Icon: THandle;
  I: Integer;
begin
  LoadLanguage;
  DropFileTarget1.Register(Self);
  LinkImageList.Clear;
  for I := LINK_TYPE_ID to LINK_TYPE_HREF do
  begin
    case I of
      LINK_TYPE_ID:
        Icon := Icons[DB_IC_SLIDE_SHOW];
      LINK_TYPE_ID_EXT:
        Icon := Icons[DB_IC_NOTES];
      LINK_TYPE_IMAGE:
        Icon := Icons[DB_IC_DESKTOP];
      LINK_TYPE_FILE:
        Icon := Icons[DB_IC_SHELL];
      LINK_TYPE_FOLDER:
        Icon := Icons[DB_IC_DIRECTORY];
      LINK_TYPE_TXT:
        Icon := Icons[DB_IC_TEXT_FILE];
      LINK_TYPE_HREF:
        Icon := Icons[DB_IC_LINK];
    else
      Icon := 0;
    end;
      ImageList_AddIcon(LinkImageList.Handle, Icon);
  end;

  CbLinkType.Items.Add(L(LINK_TEXT_TYPE_ID));
  CbLinkType.Items.Add(L(LINK_TEXT_TYPE_ID_EXT));
  CbLinkType.Items.Add(L(LINK_TEXT_TYPE_IMAGE));
  CbLinkType.Items.Add(L(LINK_TEXT_TYPE_FILE));
  CbLinkType.Items.Add(L(LINK_TEXT_TYPE_FOLDER));
  CbLinkType.Items.Add(L(LINK_TEXT_TYPE_TXT));
  CbLinkType.Items.Add(L(LINK_TEXT_TYPE_HTML));

  for I := LINK_TYPE_ID to LINK_TYPE_TXT do
    CbLinkType.ItemsEx[I].ImageIndex := I;
  CbLinkType.ItemIndex := 0;
end;

procedure TFormEditLink.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormEditLink.LoadLanguage;
begin
  BeginTranslate;
  try
    LblInfo.Caption := L('Create or edit link');
    Label1.Caption := L('Link type');
    Label2.Caption := L('Link name');
    Label3.Caption := L('Link value');
    EdName.WatermarkText := L('Link name');
    EdValue.WatermarkText := L('Link value');
    BtnCancel.Caption := L('Cancel');
    BtnOk.Caption := L('Ok');
  finally
    EndTranslate;
  end;
end;

procedure TFormEditLink.BtnChooseLinkValueClick(Sender: TObject);
var
  S: string;
  OpenDialog: DBOpenDialog;
  OpenPictureDialog: DBOpenPictureDialog;
  Context: IDBContext;
  MediaRepository: IMediaRepository;
begin
  Context := DBManager.DBContext;
  MediaRepository := Context.Media;

  case CbLinkType.ItemIndex of
    LINK_TYPE_ID:
      begin
        OpenPictureDialog := DBOpenPictureDialog.Create;
        try
          OpenPictureDialog.Filter := TFileAssociations.Instance.FullFilter;
          if OpenPictureDialog.Execute then
            EdValue.Text := IntToStr(MediaRepository.GetIdByFileName(OpenPictureDialog.FileName));

        finally
          F(OpenPictureDialog);
        end;
      end;
    LINK_TYPE_IMAGE:
      begin
        OpenPictureDialog := DBOpenPictureDialog.Create;
        try
          OpenPictureDialog.Filter := TFileAssociations.Instance.FullFilter;
          if OpenPictureDialog.Execute then
            EdValue.Text := OpenPictureDialog.FileName;
        finally
          F(OpenPictureDialog);
        end;
      end;
    LINK_TYPE_FILE:
      begin
        OpenDialog := DBOpenDialog.Create;
        try
          if OpenDialog.Execute then
            EdValue.Text := OpenDialog.FileName;
        finally
          F(OpenDialog);
        end;
      end;
    LINK_TYPE_FOLDER:
      begin
        S := SelectDir(Application.Handle, L('Please, select directory'));
        if S <> '' then
          EdValue.Text := S;
      end;
    LINK_TYPE_ID_EXT:
      begin
        OpenPictureDialog := DBOpenPictureDialog.Create;
        try
          OpenPictureDialog.Filter := TFileAssociations.Instance.FullFilter;
          if OpenPictureDialog.Execute then
            EdValue.Text := CodeExtID(GetImageIDW(Context, OpenPictureDialog.FileName, True).ImTh);

        finally
          F(OpenPictureDialog);
        end;
      end;
  end;
end;

procedure TFormEditLink.BtnOkClick(Sender: TObject);
var
  I: Integer;
  Link: TLinkInfo;
begin
  ProgramStatistics.PropertyLinksUsed;

  if FAdd then
  begin
    for I := 0 to Length(FInfo) - 1 do
      if (AnsiLowerCase(FInfo[I].LinkName) = AnsiLowerCase(EdName.Text)) and (FInfo[I].LinkType = CbLinkType.ItemIndex)
        then
      begin
        MessageBoxDB(Handle, L('Link with this name already exists! Please, select another name.'), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
        Exit;
      end;
    Link.LinkType := CbLinkType.ItemIndex;
    Link.LinkName := EdName.Text;
    Link.LinkValue := EdValue.Text;
    FProc(Self, '', Link, 0, LINK_PROC_ACTION_ADD);
  end else
  begin
    for I := 0 to Length(FInfo) - 1 do
      if I <> FN then
        if (AnsiLowerCase(FInfo[I].LinkName) = AnsiLowerCase(EdName.Text)) and (FInfo[I].LinkType = CbLinkType.ItemIndex) then
        begin
          MessageBoxDB(Handle, L('Link with this name already exists! Please, select another name.'), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
          Exit;
        end;
    Link.LinkType := CbLinkType.ItemIndex;
    Link.LinkName := EdName.Text;
    Link.LinkValue := EdValue.Text;
    FProc(Self, '', Link, FN, LINK_PROC_ACTION_MODIFY);
  end;
  Close;
end;

procedure TFormEditLink.DropFileTarget1Drop(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
var
  S: string;
  Context: IDBContext;
  MediaRepository: IMediaRepository;
begin
  Context := DBManager.DBContext;
  MediaRepository := Context.Media;

  case CbLinkType.ItemIndex of
    LINK_TYPE_ID:
      begin
        EdValue.Text := IntToStr(MediaRepository.GetIdByFileName(DropFileTarget1.Files[0]));
      end;
    LINK_TYPE_IMAGE:
      begin
        EdValue.Text := DropFileTarget1.Files[0];
      end;
    LINK_TYPE_FILE:
      begin
        EdValue.Text := DropFileTarget1.Files[0];
      end;
    LINK_TYPE_FOLDER:
      begin
        if DirectoryExists(DropFileTarget1.Files[0]) then
          S := DropFileTarget1.Files[0]
        else
          S := ExtractFileDir(DropFileTarget1.Files[0]);
        if S <> '' then
          EdValue.Text := S;
      end;
    LINK_TYPE_ID_EXT:
      begin
        EdValue.Text := CodeExtID(GetImageIDW(Context, DropFileTarget1.Files[0], True).ImTh);
      end;
  end;
end;

procedure TFormEditLink.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FOnClose(Self, '');
  Release;
end;

procedure TFormEditLink.EdNameChange(Sender: TObject);
var
  I: Integer;
  S, SOld: string;
begin
  SOld := '';
  if Sender is TEdit then
    SOld := TEdit(Sender).Text;
  if Sender is TMemo then
    SOld := TMemo(Sender).Text;
  if SOld = '' then
    Exit;
  S := SOld;
  if Sender is TEdit then
    for I := Length(S) downto 1 do
      if (S[I] = '[') or (S[I] = ']') or (S[I] = '{') or (S[I] = '}') then
        S[I] := '_';

  if Sender is TMemo then
    for I := Length(S) downto 1 do
      if (S[I] = ';') then
        S[I] := '_';

  if S <> SOld then
  begin
    if Sender is TEdit then
      TEdit(Sender).Text := S;
    if Sender is TMemo then
      TMemo(Sender).Text := S;
  end;
end;

procedure TFormEditLink.CbLinkTypeKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = '[') or (Key = ']') or (Key = '{') or (Key = '}') then
    Key := '_';
end;

procedure TFormEditLink.CustomFormAfterDisplay;
begin
  inherited;
  if EdName <> nil then
    EdName.Refresh;
  if EdValue <> nil then
  EdValue.Refresh;
end;

procedure TFormEditLink.EdValueKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = ';') then
    Key := '_';
end;

procedure TFormEditLink.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key = VK_ESCAPE then
   Close;
end;

function TFormEditLink.GetFormID: string;
begin
  Result := 'EditLinks';
end;

end.
