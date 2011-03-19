unit Options;

interface

uses
  Registry, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, TabNotBk, DmProgress, ExtCtrls, CheckLst,
  Menus, ShellCtrls, Dolphin_DB, ImgList, Math, Mask, uFileUtils,
  acDlgSelect, UnitDBKernel, SaveWindowPos, UnitINI, uVistaFuncs, UnitDBDeclare,
  UnitDBFileDialogs, uAssociatedIcons, uLogger, uConstants, uShellIntegration,
  UnitDBCommon, UnitDBCommonGraphics, uTranslate, uShellUtils, uDBForm,
  uRuntime, uMemory, uSettings, WebLink, uAssociations, AppEvnts;

type
  TOptionsForm = class(TDBForm)
    CancelButton: TButton;
    OkButton: TButton;
    PmExtensionStatus: TPopupMenu;
    Usethisprogramasdefault1: TMenuItem;
    Usemenuitem1: TMenuItem;
    Dontusethisextension1: TMenuItem;
    PopupMenu2: TPopupMenu;
    Addnewcommand1: TMenuItem;
    Remore1: TMenuItem;
    ImageList1: TImageList;
    PopupMenu3: TPopupMenu;
    Additem1: TMenuItem;
    DeleteItem1: TMenuItem;
    N1: TMenuItem;
    Up1: TMenuItem;
    Down1: TMenuItem;
    PlacesImageList: TImageList;
    Rename1: TMenuItem;
    N2: TMenuItem;
    SaveWindowPos1: TSaveWindowPos;
    N3: TMenuItem;
    Default1: TMenuItem;
    PcMain: TPageControl;
    TsGeneral: TTabSheet;
    TsExplorer: TTabSheet;
    BtnClearIconCache: TButton;
    BtnClearThumbnailCache: TButton;
    BtnChooseNewPlace: TButton;
    BtnChoosePlaceIcon: TButton;
    PlacesListView: TListView;
    CblPlacesDisplayIn: TCheckListBox;
    LbDisplayPlacesIn: TLabel;
    LbPlacesList: TLabel;
    CbExplorerShowPlaces: TCheckBox;
    CbExplorerShowEXIF: TCheckBox;
    CbExplorerShowThumbsForImages: TCheckBox;
    CbExplorerSaveThumbsForFolders: TCheckBox;
    CbExplorerShowThumbsForFolders: TCheckBox;
    CbExplorerShowAttributes: TCheckBox;
    Label13: TStaticText;
    Label12: TStaticText;
    CbExplorerShowFolders: TCheckBox;
    CbExplorerShowSimpleFiles: TCheckBox;
    CbExplorerShowImages: TCheckBox;
    CbExplorerShowHidden: TCheckBox;
    Bevel1: TBevel;
    TsView: TTabSheet;
    TrackBar1: TTrackBar;
    Label15: TLabel;
    Label22: TLabel;
    TrackBar2: TTrackBar;
    Label16: TLabel;
    TrackBar3: TTrackBar;
    TrackBar4: TTrackBar;
    Label26: TLabel;
    CheckBox24: TCheckBox;
    CheckBox25: TCheckBox;
    CheckBox37: TCheckBox;
    CheckBox22: TCheckBox;
    CheckBox2: TCheckBox;
    TsUserMenu: TTabSheet;
    Button16: TButton;
    GroupBox3: TGroupBox;
    CheckBox17: TCheckBox;
    CheckBox18: TCheckBox;
    CheckBox19: TCheckBox;
    Button13: TButton;
    Button14: TButton;
    Button18: TButton;
    Button17: TButton;
    ListView1: TListView;
    Button15: TButton;
    Edit8: TEdit;
    Label23: TLabel;
    Edit7: TEdit;
    Label21: TLabel;
    Label24: TLabel;
    Image2: TImage;
    CheckBox16: TCheckBox;
    Edit5: TEdit;
    Button7: TButton;
    Label19: TLabel;
    Edit9: TEdit;
    Label25: TLabel;
    Edit4: TEdit;
    Button5: TButton;
    Label18: TLabel;
    Edit6: TEdit;
    Label20: TLabel;
    TsSecurity: TTabSheet;
    GroupBox2: TGroupBox;
    Label30: TLabel;
    Label29: TLabel;
    Edit10: TEdit;
    GroupBox4: TGroupBox;
    LbSecureInfo: TLabel;
    ImSecureInfo: TImage;
    Button4: TButton;
    Button3: TButton;
    CheckBox15: TCheckBox;
    CheckBox14: TCheckBox;
    TsGlobal: TTabSheet;
    Label32: TLabel;
    Edit13: TEdit;
    Label31: TLabel;
    Edit12: TEdit;
    CheckBox34: TCheckBox;
    Edit11: TEdit;
    Button25: TButton;
    CheckBox33: TCheckBox;
    CheckBox32: TCheckBox;
    CheckBox31: TCheckBox;
    Edit2: TEdit;
    Label35: TLabel;
    CheckBox5: TCheckBox;
    CheckBox38: TCheckBox;
    CheckBox30: TCheckBox;
    CheckBox28: TCheckBox;
    CheckBox35: TCheckBox;
    CheckBox26: TCheckBox;
    CheckBox23: TCheckBox;
    Label34: TLabel;
    LbShellExtensions: TStaticText;
    CbExtensionList: TCheckListBox;
    BtnInstallExtensions: TButton;
    CheckBox4: TCheckBox;
    LblSkipExt: TLabel;
    LblAddSubmenuItem: TLabel;
    LblUseExt: TLabel;
    CbInstallTypeChecked: TCheckBox;
    CbInstallTypeGrayed: TCheckBox;
    CbInstallTypeNone: TCheckBox;
    Bevel2: TBevel;
    WlDefaultJPEGOptions: TWebLink;
    AeMain: TApplicationEvents;
    WlViewerJPEGOptions: TWebLink;
    procedure TabbedNotebook1Change(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure CbExtensionListContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Usethisprogramasdefault1Click(Sender: TObject);
    procedure Usemenuitem1Click(Sender: TObject);
    procedure Dontusethisextension1Click(Sender: TObject);
    procedure BtnInstallExtensionsClick(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure TrackBar3Change(Sender: TObject);
    procedure LoadDefaultExtStates;
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure ListView1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Addnewcommand1Click(Sender: TObject);
    procedure Remore1Click(Sender: TObject);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure Button13Click(Sender: TObject);
    procedure Edit6KeyPress(Sender: TObject; var Key: Char);
    procedure Button16Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Button17Click(Sender: TObject);
    procedure Button18Click(Sender: TObject);
    procedure BtnClearIconCacheClick(Sender: TObject);
    procedure BtnClearThumbnailCacheClick(Sender: TObject);
    procedure TrackBar4Change(Sender: TObject);
    procedure PlacesListViewContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure BtnChooseNewPlaceClick(Sender: TObject);
    procedure ReadPlaces;
    procedure WritePlaces;
    procedure PlacesListViewSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure CblPlacesDisplayInClickCheck(Sender: TObject);
    procedure BtnChoosePlaceIconClick(Sender: TObject);
    procedure DeleteItem1Click(Sender: TObject);
    procedure Up1Click(Sender: TObject);
    procedure Down1Click(Sender: TObject);
    procedure Rename1Click(Sender: TObject);
    procedure PlacesListViewEdited(Sender: TObject; Item: TListItem;
      var S: String);
    procedure Default1Click(Sender: TObject);
    procedure CheckBox32Click(Sender: TObject);
    procedure Button25Click(Sender: TObject);
    procedure CheckBox33Click(Sender: TObject);
    procedure CheckBox34Click(Sender: TObject);
    procedure PcMainChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure WlDefaultJPEGOptionsClick(Sender: TObject);
    procedure AeMainMessage(var Msg: tagMSG; var Handled: Boolean);
    procedure WlViewerJPEGOptionsClick(Sender: TObject);
  private
    FThemeList : TStringList;
    FUserMenu : TUserMenuItemArray;
    FLoadedPages : array[0..5] of boolean;
    FPlaces : TPlaceFolderArray;
    ReloadData : boolean;
  protected
    { Protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
    function GetFormID : string; override;
  public
    { Public declarations }
    procedure LoadLanguage;
  end;

var
  OptionsForm: TOptionsForm;

implementation

uses 
  CleaningForm, SlideShow, ExplorerThreadUnit,
  ExplorerUnit, UnitJPEGOptions;

{$R *.dfm}

procedure TOptionsForm.TabbedNotebook1Change(Sender: TObject; NewTab: Integer; var AllowChange: Boolean);
var
  I: Integer;
  Reg: TBDRegistry;
  S: TStrings;
  FCaption, EXEFile, Params, Icon: string;
  UseSubMenu: Boolean;
  RegIni: TRegIniFile;
begin
  if FLoadedPages[NewTab] then
    Exit;
  FLoadedPages[NewTab] := True;

  if NewTab = 0 then
  begin
    CheckBox4.Checked := Settings.Readbool('Options', 'AllowPreview', True);
    CbExtensionList.Items.Clear;
    for I := 0 to TFileAssociations.Instance.Count - 1 do
      CbExtensionList.Items.AddObject(Format('%s   (%s)', [TFileAssociations.Instance[I].Extension, TFileAssociations.Instance[I].Description]), TFileAssociations.Instance[I]);

    LoadDefaultExtStates;
  end;
  if NewTab = 1 then
  begin
    CbExplorerShowFolders.Checked := Settings.Readbool('Options', 'Explorer_ShowFolders', True);
    CbExplorerShowSimpleFiles.Checked := Settings.Readbool('Options', 'Explorer_ShowSimpleFiles', True);
    CbExplorerShowImages.Checked := Settings.Readbool('Options', 'Explorer_ShowImageFiles', True);
    CbExplorerShowHidden.Checked := Settings.Readbool('Options', 'Explorer_ShowHiddenFiles', False);
    CbExplorerShowAttributes.Checked := Settings.Readbool('Options', 'Explorer_ShowAttributes', True);
    CbExplorerShowThumbsForFolders.Checked := Settings.Readbool('Options', 'Explorer_ShowThumbnailsForFolders', True);
    CbExplorerSaveThumbsForFolders.Checked := Settings.Readbool('Options', 'Explorer_SaveThumbnailsForFolders', True);
    CbExplorerShowThumbsForImages.Checked := Settings.Readbool('Options', 'Explorer_ShowThumbnailsForImages', True);
    CbExplorerShowEXIF.Checked := Settings.ReadBool('Options', 'ShowEXIFMarker', False);
    CbExplorerShowPlaces.Checked := Settings.ReadBool('Options', 'ShowOtherPlaces', True);

    ReadPlaces;
  end;
  if NewTab = 2 then
  begin
    CheckBox37.Checked := Settings.ReadBool('SlideShow', 'UseFastSlideShowImageLiading', True);

    CheckBox22.Checked := Settings.Readbool('Options', 'NextOnClick', False);
    CheckBox24.Checked := Settings.Readbool('Options', 'RotateWithoutPromt', True);
    CheckBox25.Checked := Settings.Readbool('Options', 'RotateEvenIfFileInDB', True);

    TrackBar1.Position := Min(Max(Settings.ReadInteger('Options', 'SlideShow_SlideSteps', 25), 1), 100);
    TrackBar2.Position := Min(Max(Settings.ReadInteger('Options', 'SlideShow_SlideDelay', 40), 1), 100);
    TrackBar3.Position := Min(Max(Settings.ReadInteger('Options', 'SlideShow_GrayScale', 20), 1), 100);
    TrackBar4.Position := Min(Max(Settings.ReadInteger('Options', 'FullScreen_SlideDelay', 40), 1), 100);
    CheckBox2.Checked := Settings.ReadboolW('Options', 'SlideShow_UseCoolStretch', True);
    TrackBar1Change(Sender);
    TrackBar2Change(Sender);
    TrackBar3Change(Sender);
    TrackBar4Change(Sender);
  end;
  if NewTab = 4 then
  begin
    CheckBox14.Checked := Settings.Readbool('Options', 'AutoSaveSessionPasswords', True);
    CheckBox15.Checked := Settings.Readbool('Options', 'AutoSaveINIPasswords', False);
    Edit10.Text := IntToStr(Settings.ReadInteger('Options', 'BackUpdays', 7));
  end;

  if NewTab = 5 then
  begin

    CheckBox38.Checked := Settings.Readbool('Options', 'UseSmallToolBarButtons', False);
    CheckBox5.Checked := Settings.Readbool('Options', 'UseListViewFullRectSelect', False);
    Edit2.Text := IntToStr(Settings.ReadInteger('Options', 'UseListViewRoundRectSize', 3));

    CheckBox26.Checked := Settings.Readbool('Options', 'SortGroupsByName', True);
    CheckBox23.Checked := Settings.Readbool('Options', 'UseHotSelect', True);
    CheckBox28.Checked := Settings.Readbool('Options', 'AllowManyInstancesOfProperty', True);
    CheckBox30.Checked := Settings.ReadBool('Editor', 'VirtualCursor', False);
    CheckBox31.Checked := Settings.ReadBool('Options', 'CheckUpdateLinks', False);

    CheckBox32.Checked := Settings.ReadBool('Options', 'RunExplorerAtStartUp', False);
    CheckBox33.Checked := Settings.ReadBool('Options', 'UseSpecialStartUpFolder', False);
    Edit11.Text := Settings.ReadString('Options', 'SpecialStartUpFolder');

    CheckBox35.Checked := Settings.Readbool('Options', 'UseGroupsInSearch', True);
    if not DirectoryExists(Edit11.Text) then
    begin
      RegIni := TRegIniFile.Create(SHELL_FOLDERS_ROOT);
      Edit11.Text := RegIni.ReadString('Shell Folders', 'My Pictures', '');
      RegIni.Free;
    end;
    CheckBox33.Enabled := CheckBox32.Checked;
    Edit11.Enabled := CheckBox33.Checked and CheckBox33.Enabled;

    CheckBox34.Checked := Settings.ReadBool('Options', 'NoAddSmallImages', True);
    Edit12.Text := IntToStr(Settings.ReadInteger('Options', 'NoAddSmallImagesWidth', 64));
    Edit13.Text := IntToStr(Settings.ReadInteger('Options', 'NoAddSmallImagesHeight', 64));
    Edit12.Enabled := CheckBox34.Checked;
    Edit13.Enabled := CheckBox34.Checked;
  end;

  if NewTab = 3 then
  begin
    ImageList1.Clear;
    ImageList1.Width := 16;
    ImageList1.Height := 16;
    ImageList1.BkColor := Clmenu;
    Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
    try
      Reg.OpenKey(GetRegRootKey + '\Menu', True);
      S := TStringList.Create;
      try
        Reg.GetKeyNames(S);
        SetLength(FUserMenu, 0);
        ListView1.Clear;
        for I := 0 to S.Count - 1 do
        begin
          Reg.CloseKey;
          Reg.OpenKey(GetRegRootKey + '\Menu' + S[I], True);
          UseSubMenu := True;
      
          if Reg.ValueExists('Caption') then
            FCaption := Reg.ReadString('Caption');
          if Reg.ValueExists('EXEFile') then
            EXEFile := Reg.ReadString('EXEFile');
          if Reg.ValueExists('Params') then
            Params := Reg.ReadString('Params');
          if Reg.ValueExists('Icon') then
            Icon := Reg.ReadString('Icon');
          if Reg.ValueExists('UseSubMenu') then
            UseSubMenu := Reg.ReadBool('UseSubMenu');

          if (FCaption <> '') and (EXEFile <> '') then
          begin
            SetLength(FUserMenu, Length(FUserMenu) + 1);
            FUserMenu[Length(FUserMenu) - 1].Caption := FCaption;
            FUserMenu[Length(FUserMenu) - 1].EXEFile := EXEFile;
            FUserMenu[Length(FUserMenu) - 1].Params := Params;
            FUserMenu[Length(FUserMenu) - 1].Icon := Icon;
            FUserMenu[Length(FUserMenu) - 1].UseSubMenu := UseSubMenu;

            AddIconToListFromPath(ImageList1, Icon);

            with ListView1.Items.Add do
            begin
              ImageIndex := ImageList1.Count - 1;
              Caption := FCaption;
            end;
          end;
        end;
      finally
        F(S);
      end;
    finally
      F(Reg);
    end;
    CheckBox17.Checked := Settings.ReadBool('Options', 'UseUserMenuForIDmenu', True);
    CheckBox19.Checked := Settings.ReadBool('Options', 'UseUserMenuForViewer', True);
    CheckBox18.Checked := Settings.ReadBool('Options', 'UseUserMenuForExplorer', True);
    Edit7.Text := Settings.ReadString('', 'UserMenuName');
    if Edit7.Text = '' then
      Edit7.Text := L('Additional');
    Edit8.Text := Settings.ReadString('', 'UserMenuIcon');
    if Edit8.Text = '' then
      Edit8.Text := '%SystemRoot%\system32\shell32.dll,126';

    SetIconToPictureFromPath(Image2.Picture, Edit8.Text);
  end;

end;

procedure TOptionsForm.FormShow(Sender: TObject);
var
  B: Boolean;
begin
  TabbedNotebook1Change(Sender, 0, B);
end;

function TOptionsForm.GetFormID: string;
begin
  Result := 'Options';
end;

procedure TOptionsForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Release;
end;

procedure TOptionsForm.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  ReloadData := False;
  ClientHeight := OkButton.Top + OkButton.Height + 3;

  SaveWindowPos1.Key := GetRegRootKey + 'Options';
  SaveWindowPos1.SetPosition;
  for I := 0 to 5 do
    FLoadedPages[I] := False;
  LoadLanguage;
  FThemeList := nil;
  PopupMenu3.Images := DBKernel.ImageList;
  PopupMenu2.Images := DBKernel.ImageList;
  Up1.ImageIndex := DB_IC_UP;
  Down1.ImageIndex := DB_IC_DOWN;
  DeleteItem1.ImageIndex := DB_IC_DELETE_INFO;
  Additem1.ImageIndex := DB_IC_EXPLORER;
  Rename1.ImageIndex := DB_IC_RENAME;
  Addnewcommand1.ImageIndex := DB_IC_EXPLORER;
  Remore1.ImageIndex := DB_IC_DELETE_INFO;
  CheckBox31.Enabled := not FolderView;
  ClientHeight := 484;
  PcMainChange(Self);
  WlDefaultJPEGOptions.Color := clWindow;
  WlViewerJPEGOptions.Color := clWindow;
end;

procedure TOptionsForm.FormDestroy(Sender: TObject);
begin
  OptionsForm := nil;
end;

procedure TOptionsForm.OkButtonClick(Sender: TObject);
var
  I: Integer;
  Reg: TBDRegistry;
  S: TStrings;
  EventInfo: TEventValues;
begin
  if ReloadData then
  begin
    if MessageBoxDB(Handle, L('Refresh data in windows?'), L('Information'), TD_BUTTON_OKCANCEL, TD_ICON_QUESTION) = ID_OK then
      DBKernel.DoIDEvent(Self, 0, [EventID_Param_Refresh_Window], EventInfo);

  end;
  // Case TabbedNotebook1.PageIndex of 
  // 0: 
  if FLoadedPages[0] then
  begin
    //TODO:
  end;
  // 1: 
  if FLoadedPages[1] then
  begin
    Settings.WriteBool('Options', 'Explorer_ShowFolders', CbExplorerShowFolders.Checked);
    Settings.WriteBool('Options', 'Explorer_ShowSimpleFiles', CbExplorerShowSimpleFiles.Checked);
    Settings.WriteBool('Options', 'Explorer_ShowImageFiles', CbExplorerShowImages.Checked);
    Settings.WriteBool('Options', 'Explorer_ShowHiddenFiles', CbExplorerShowHidden.Checked);
    Settings.WriteBool('Options', 'Explorer_ShowAttributes', CbExplorerShowAttributes.Checked);
    Settings.WriteBool('Options', 'Explorer_ShowThumbnailsForFolders', CbExplorerShowThumbsForFolders.Checked);
    Settings.WriteBool('Options', 'Explorer_SaveThumbnailsForFolders', CbExplorerSaveThumbsForFolders.Checked);
    Settings.WriteBool('Options', 'Explorer_ShowThumbnailsForImages', CbExplorerShowThumbsForImages.Checked);
    Settings.WriteBool('Options', 'ShowEXIFMarker', CbExplorerShowEXIF.Checked);
    Settings.WriteBool('Options', 'ShowOtherPlaces', CbExplorerShowPlaces.Checked);

    ExplorerManager.ShowEXIF := CbExplorerShowEXIF.Checked;
    ExplorerManager.ShowQuickLinks := CbExplorerShowPlaces.Checked;
    WritePlaces;
  end;
  // 3 : 
  if FLoadedPages[3] then
  begin
    Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
    try
      Reg.OpenKey(GetRegRootKey + '\Menu', True);
      S := TStringList.Create;
      try
        Reg.GetKeyNames(S);
        Reg.CloseKey;
        for I := 1 to S.Count do
          Reg.DeleteKey(GetRegRootKey + '\Menu\.' + IntToStr(I));
      finally
        F(S);
      end;
      for I := 0 to Length(FUserMenu) - 1 do
      begin
        Reg.OpenKey(GetRegRootKey + '\Menu\.' + IntToStr(I), True);
        Reg.WriteString('Caption', FUserMenu[I].Caption);
        Reg.WriteString('EXEFile', FUserMenu[I].EXEFile);
        Reg.WriteString('Params', FUserMenu[I].Params);
        Reg.WriteString('Icon', FUserMenu[I].Icon);
        Reg.WriteBool('UseSubMenu', FUserMenu[I].UseSubMenu);
        Reg.CloseKey;
      end;
    finally
      F(Reg);
    end;
    Settings.WriteBool('Options', 'UseUserMenuForIDmenu', CheckBox17.Checked);
    Settings.WriteBool('Options', 'UseUserMenuForViewer', CheckBox19.Checked);
    Settings.WriteBool('Options', 'UseUserMenuForExplorer', CheckBox18.Checked);
  end;
  // 4 : 
  if FLoadedPages[4] then
  begin
    Settings.WriteBool('Options', 'AutoSaveSessionPasswords', CheckBox14.Checked);
    Settings.WriteBool('Options', 'AutoSaveINIPasswords', CheckBox15.Checked);
    Settings.WriteInteger('Options', 'BackUpdays', StrToIntDef(Edit10.Text, 7));
  end;
  // 5 : 
  if FLoadedPages[5] then
  begin
    Settings.WriteBool('Options', 'AllowPreview', CheckBox4.Checked);
    Settings.WriteBool('Options', 'UseSmallToolBarButtons', CheckBox38.Checked);
    Settings.WriteBool('Options', 'UseListViewFullRectSelect', CheckBox5.Checked);
    Settings.WriteInteger('Options', 'UseListViewRoundRectSize', StrToIntDef(Edit2.Text, 0));

    Settings.WriteBool('Options', 'UseGroupsInSearch', CheckBox35.Checked);
    Settings.WriteBool('Options', 'SortGroupsByName', CheckBox26.Checked);
    Settings.WriteBool('Options', 'UseHotSelect', CheckBox23.Checked);
    Settings.WriteBool('Options', 'AllowManyInstancesOfProperty', CheckBox28.Checked);
    Settings.WriteBool('Editor', 'VirtualCursor', CheckBox30.Checked);
    Settings.WriteBool('Options', 'CheckUpdateLinks', CheckBox31.Checked);

    Settings.WriteBool('Options', 'RunExplorerAtStartUp', CheckBox32.Checked);
    Settings.WriteBool('Options', 'UseSpecialStartUpFolder', CheckBox33.Checked);
    Settings.WriteString('Options', 'SpecialStartUpFolder', Edit11.Text);

    Settings.WriteBool('Options', 'NoAddSmallImages', CheckBox34.Checked);
    Settings.WriteString('Options', 'NoAddSmallImagesWidth', Edit12.Text);
    Settings.WriteString('Options', 'NoAddSmallImagesHeight', Edit13.Text);

  end;
  // 2 : 
  if FLoadedPages[2] then
  begin
    Settings.WriteBool('SlideShow', 'UseFastSlideShowImageLiading', CheckBox37.Checked);
    Settings.WriteBool('Options', 'RotateWithoutPromt', CheckBox24.Checked);
    Settings.WriteBool('Options', 'RotateEvenIfFileInDB', CheckBox25.Checked);
    Settings.WriteBool('Options', 'NextOnClick', CheckBox22.Checked);
    Settings.WriteBoolW('Options', 'SlideShow_UseCoolStretch', CheckBox2.Checked);
    Settings.WriteInteger('Options', 'SlideShow_SlideSteps', TrackBar1.Position);
    Settings.WriteInteger('Options', 'SlideShow_SlideDelay', TrackBar2.Position);
    Settings.WriteInteger('Options', 'SlideShow_GrayScale', TrackBar3.Position);
    Settings.WriteInteger('Options', 'FullScreen_SlideDelay', TrackBar4.Position);
  end;
  // end; 
  Close;
end;

procedure TOptionsForm.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TOptionsForm.CbExtensionListContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
var
  Item: Integer;
begin
  Item := CbExtensionList.ItemAtPos(MousePos, True);
  if Item <> -1 then
  begin
    CbExtensionList.Selected[Item] := True;
    PmExtensionStatus.Tag := Item;
    Usethisprogramasdefault1.Checked := False;
    Usemenuitem1.Checked := False;
    Dontusethisextension1.Checked := False;
    case CbExtensionList.State[Item] of
      CbUnchecked:
        Dontusethisextension1.Checked := True;
      CbChecked:
        Usethisprogramasdefault1.Checked := True;
      CbGrayed:
        Usemenuitem1.Checked := True;
    end;
  end;
  PmExtensionStatus.PopUp(CbExtensionList.CLientToScreen(MousePos).X, CbExtensionList.CLientToScreen(MousePos).Y);
end;

procedure TOptionsForm.Usethisprogramasdefault1Click(Sender: TObject);
begin
  CbExtensionList.State[PmExtensionStatus.Tag] := CbChecked;
end;

procedure TOptionsForm.Usemenuitem1Click(Sender: TObject);
begin
  CbExtensionList.State[PmExtensionStatus.Tag] := CbGrayed;
end;

procedure TOptionsForm.Dontusethisextension1Click(Sender: TObject);
begin
  CbExtensionList.State[PmExtensionStatus.Tag] := CbUnchecked;
end;

procedure TOptionsForm.AeMainMessage(var Msg: tagMSG; var Handled: Boolean);
begin
  if (Msg.message = WM_LBUTTONDOWN)
  or (Msg.message = WM_LBUTTONDBLCLK)
  or (Msg.message = WM_MOUSEMOVE) then
  begin
    if (Msg.hwnd = CbInstallTypeChecked.Handle)
      or (Msg.hwnd = CbInstallTypeGrayed.Handle)
      or (Msg.hwnd = CbInstallTypeNone.Handle) then
        Msg.message := 0;
  end;
end;

procedure TOptionsForm.BtnInstallExtensionsClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to CbExtensionList.Items.Count - 1 do
    TFileAssociations.Instance.Exts[TFileAssociation(CbExtensionList.Items.Objects[I]).Extension].State := CheckboxStateToAssociationState(CbExtensionList.State[I]);

  InstallGraphicFileAssociations(Application.ExeName, nil);
  RefreshSystemIconCache;
  LoadDefaultExtStates;
end;

procedure TOptionsForm.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Options');
    TsGeneral.Caption := L('General');
    TsExplorer.Caption := L('Explorer'); ;
    TsView.Caption := L('Slide show'); ;
    TsUserMenu.Caption := L('User menu');
    TsSecurity.Caption := L('Security');
    TsGlobal.Caption := L('Global');
    GroupBox2.Caption := L('Backups');
    Dontusethisextension1.Caption := L('Don''t use this extension');
    Usethisprogramasdefault1.Caption := L('Use PhotoDB as default association');
    Usemenuitem1.Caption := L('Add menu item');
    CheckBox4.Caption := L('Show previews');
    Label12.Caption := L('Show object types') + ':';
    CbExplorerShowFolders.Caption := L('Folders');
    CbExplorerShowSimpleFiles.Caption := L('Simple files');
    CbExplorerShowImages.Caption := L('Images');
    CbExplorerShowHidden.Caption := L('Hidden files');
    Label13.Caption := L('Preview options') + ':';
    CbExplorerShowAttributes.Caption := L('Display attributes');
    CbExplorerShowThumbsForFolders.Caption := L('Display previews for folders');
    CbExplorerSaveThumbsForFolders.Caption := L('Save preview for folders');
    CbExplorerShowThumbsForImages.Caption := L('Show previews for images');
    BtnInstallExtensions.Caption := L('Set');
    OkButton.Caption := L('Ok');
    CancelButton.Caption := L('Cancel');
    CheckBox2.Caption := L('Use high-quality rendering');
    LbShellExtensions.Caption := L('Extensions') + ':';
    TrackBar4Change(Self);
    TrackBar3Change(Self);
    TrackBar2Change(Self);
    TrackBar1Change(Self);
    LbSecureInfo.Caption := L('WARNING: Use encryption carefully. If you have forgotten the password to any images, they can not be restored!');
    CheckBox14.Caption := L('Automatically save passwords for the current session');
    CheckBox15.Caption := L('Automatically save passwords in the settings (NOT RECOMMENDED)');
    Button3.Caption := L('Clear current passwords in session');
    Button4.Caption := L('Clear the current password in settings');
    ListView1.Columns[0].Caption := L('Menu item');
    Label20.Caption := L('Caption');
    Label18.Caption := L('Executable file');
    Label25.Caption := L('Parameters');
    Label19.Caption := L('Icon');
    CheckBox16.Caption := L('Add to submenu');
    Button14.Caption := L('Add');
    Button13.Caption := L('Save');
    Button16.Caption := L('Save');
    Label24.Caption := L('Preview') + ':';
    Label21.Caption := L('Submenu caption');
    Label23.Caption := L('Submenu icon');
    Addnewcommand1.Caption := L('Add new item');
    Remore1.Caption := L('Remove');
    Button17.Caption := L('Up');
    Button18.Caption := L('Down');
    GroupBox3.Caption := L('Display menu for') + ':';
    CheckBox17.Caption := L('ID Menu');
    CheckBox19.Caption := L('Viewer');
    CheckBox18.Caption := L('Explorer');
    BtnClearThumbnailCache.Caption := L('Clear previews cache');
    BtnClearIconCache.Caption := L('Clear icons cache');
    CbExplorerShowEXIF.Caption := L('Show EXIF marker');
    CbExplorerShowPlaces.Caption := L('Display links "Other places"');
    CheckBox22.Caption := L('"Next" by click');
    CheckBox23.Caption := L('Use the selection by hover on the list');
    CheckBox24.Caption := L('Rotate the image on the disk without asking for confirmation');
    CheckBox25.Caption := L('Even if the file in the database, rotate on drive');
    WlViewerJPEGOptions.Text := L('JPEG Options');
    WlDefaultJPEGOptions.Text := L('Change default JPEG Options');
    CheckBox26.Caption := L('Sort groups');
    Label29.Caption := L('Create backup every') + ':';
    Label30.Caption := L('days');
    CheckBox28.Caption := L('Allow multiple instances of properties window');
    CblPlacesDisplayIn.Clear;
    CblPlacesDisplayIn.Items.Add(L('My computer'));
    CblPlacesDisplayIn.Items.Add(L('My documents'));
    CblPlacesDisplayIn.Items.Add(L('My pictures'));
    CblPlacesDisplayIn.Items.Add(L('Other places'));
    BtnChooseNewPlace.Caption := L('New place');
    LbDisplayPlacesIn.Caption := L('Display in') + ':';
    LbPlacesList.Caption := L('User defined places') + ':';
    PlacesListView.Columns[0].Caption := L('Places') + ':';

    Additem1.Caption := L('New place');
    DeleteItem1.Caption := L('Delete');
    Up1.Caption := L('Up');
    Down1.Caption := L('Down');
    BtnChoosePlaceIcon.Caption := L('Icon');
    Rename1.Caption := L('Rename');
    CheckBox30.Caption := L('Virtual cursor to the Editor');
    Default1.Caption := L('Default');
    CheckBox31.Caption := L('Check changes of files and update links (may slow down program)');
    CheckBox32.Caption := L('Start Explorer at startup');
    CheckBox33.Caption := L('Use folder');
    CheckBox34.Caption := L('Do not add files to collection if size less than') + ':';
    Label31.Caption := L('Width');
    Label32.Caption := L('Height');
    CheckBox35.Caption := L('Group photos in search window');
    GroupBox4.Caption := L('Passwords');
    CheckBox5.Caption := L('Use full selection in lists');
    Label34.Caption := L('Round size') + ':';
    CheckBox37.Caption := L('Use a faster boot files (DB in the background)');
    CheckBox38.Caption := L('Use small icons for toolbars');
  finally
    EndTranslate;
  end;
end;

procedure TOptionsForm.TrackBar1Change(Sender: TObject);
begin
  Label15.Caption := Format(L('Number of steps for slide show: %d'), [TrackBar1.Position]);
end;

procedure TOptionsForm.TrackBar2Change(Sender: TObject);
begin
  Label22.Caption := Format(L('Slide show delay: %d ms.'), [TrackBar2.Position * 50]);
end;

procedure TOptionsForm.TrackBar3Change(Sender: TObject);
begin
  Label16.Caption := Format(L('Grayscale effect speed: %d.'), [TrackBar3.Position]);
end;

procedure TOptionsForm.TrackBar4Change(Sender: TObject);
begin
  Label26.Caption := Format(L('Speed of displaying images for fullscreen: %d ms.'), [TrackBar4.Position * 100]);
end;

procedure TOptionsForm.LoadDefaultExtStates;
var
  I: Integer;
begin
  for I := 0 to CbExtensionList.Items.Count - 1 do
    CbExtensionList.State[I] := AssociationStateToCheckboxState(TFileAssociations.Instance.GetCurrentAssociationState(TFileAssociation(CbExtensionList.Items.Objects[I]).Extension));
end;

procedure TOptionsForm.Button3Click(Sender: TObject);
begin
  DBKernel.ClearTemporaryPasswordsInSession;
end;

procedure TOptionsForm.Button4Click(Sender: TObject);
begin
  DBKernel.ClearINIPasswords;
end;

procedure TOptionsForm.Button7Click(Sender: TObject);
var
  FileName: string;
  IconIndex: Integer;

  S, Icon: string;
  I: Integer;
begin
  S := Edit5.Text;
  I := Pos(',', S);
  FileName := Copy(S, 1, I - 1);
  Icon := Copy(S, I + 1, Length(S) - I);
  IconIndex := StrToIntDef(Icon, 0);
  ChangeIconDialog(Handle, FileName, IconIndex);
  if FileName <> '' then
    Edit5.Text := FileName + ',' + IntToStr(IconIndex);
end;

procedure TOptionsForm.Button5Click(Sender: TObject);
var
  OpenDialog: DBOpenDialog;
begin

  OpenDialog := DBOpenDialog.Create;
  try
    OpenDialog.Filter := L('Programs (*.exe)|*.exe|All Files (*.*)|*.*');
    OpenDialog.FilterIndex := 1;
    if OpenDialog.Execute then
      Edit4.Text := OpenDialog.FileName;

  finally
    F(OpenDialog);
  end;
end;

procedure TOptionsForm.ListView1ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  Item: TListItem;
begin
  Item := ListView1.GetItemAt(MousePos.X, MousePos.Y);
  if Item = nil then
  begin
    Addnewcommand1.Visible := True;
    Remore1.Visible := False;
    PopupMenu2.Tag := -1;
  end else
  begin
    Addnewcommand1.Visible := False;
    Remore1.Visible := True;
    PopupMenu2.Tag := Item.index;
  end;
  PopupMenu2.Popup(ListView1.ClientToScreen(MousePos).X, ListView1.ClientToScreen(MousePos).Y);
end;

procedure TOptionsForm.Addnewcommand1Click(Sender: TObject);
var
  OpenDialog : DBOpenDialog;
const
  DefaultIcon = '%SystemRoot%\system32\shell32.dll,0';
begin

  OpenDialog := DBOpenDialog.Create;
  try
    OpenDialog.Filter := L('Programs (*.exe)|*.exe|All Files (*.*)|*.*');
    OpenDialog.FilterIndex := 1;
    if OpenDialog.Execute then
    begin
      SetLength(FUserMenu, Length(FUserMenu) + 1);
      FUserMenu[Length(FUserMenu) - 1].Caption := GetFileNameWithoutExt(OpenDialog.FileName);
      FUserMenu[Length(FUserMenu) - 1].EXEFile := OpenDialog.FileName;
      FUserMenu[Length(FUserMenu) - 1].Params := '%1';
      if AnsiLowerCase(ExtractFileExt(OpenDialog.FileName)) = '.exe' then
        FUserMenu[Length(FUserMenu) - 1].Icon := OpenDialog.FileName + ',0'
      else
        FUserMenu[Length(FUserMenu) - 1].Icon := DefaultIcon;
      FUserMenu[Length(FUserMenu) - 1].UseSubMenu := True;

      AddIconToListFromPath(ImageList1, FUserMenu[Length(FUserMenu) - 1].Icon);

      with ListView1.Items.Add do
      begin
        ImageIndex := ImageList1.Count - 1;
        Caption := GetFileNameWithoutExt(OpenDialog.FileName);
      end;
    end;
  finally
    F(OpenDialog);
  end;
end;

procedure TOptionsForm.Remore1Click(Sender: TObject);
var
  I: Integer;
begin
  if PopupMenu2.Tag <> -1 then
  begin
    for I := PopupMenu2.Tag to Length(FUserMenu) - 2 do
      FUserMenu[I] := FUserMenu[I + 1];
    SetLength(FUserMenu, Length(FUserMenu) - 1);
    ListView1.Items.Delete(PopupMenu2.Tag);
    ImageList1.Delete(PopupMenu2.Tag);
    for I := PopupMenu2.Tag to Length(FUserMenu) - 1 do
      ListView1.Items[I].ImageIndex := ListView1.Items[I].ImageIndex - 1;
  end;
end;

procedure TOptionsForm.ListView1SelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if (Item = nil) or (Selected = False) then
  begin
    Button17.Enabled := False;
    Button18.Enabled := False;
    Edit6.Enabled := False;
    Edit5.Enabled := False;
    Edit4.Enabled := False;
    Edit9.Enabled := False;
    Button5.Enabled := False;
    Button7.Enabled := False;
    Button13.Enabled := False;
    CheckBox16.Checked := False;
    CheckBox16.Enabled := False;
    Edit6.Text := '';
    Edit5.Text := '';
    Edit4.Text := '';
    Edit9.Text := '';
  end
  else
  begin
    Button17.Enabled := Item.index <> 0;
    Button18.Enabled := Item.index <> ListView1.Items.Count - 1;
    Edit6.Text := FUserMenu[Item.index].Caption;
    Edit5.Text := FUserMenu[Item.index].Icon;
    Edit4.Text := FUserMenu[Item.index].EXEFile;
    Edit9.Text := FUserMenu[Item.index].Params;
    CheckBox16.Checked := FUserMenu[Item.index].UseSubMenu;
    CheckBox16.Enabled := True;
    Edit6.Enabled := True;
    Edit5.Enabled := True;
    Edit4.Enabled := True;
    Edit9.Enabled := True;
    Button5.Enabled := True;
    Button7.Enabled := True;
    Button13.Enabled := True;
  end;
end;

procedure TOptionsForm.Button13Click(Sender: TObject);
var
  Ico: TIcon;
begin
  if ListView1.Selected = nil then
    Exit;

  FUserMenu[ListView1.Selected.index].Caption := Edit6.Text;
  FUserMenu[ListView1.Selected.index].Icon := Edit5.Text;
  FUserMenu[ListView1.Selected.index].EXEFile := Edit4.Text;
  FUserMenu[ListView1.Selected.index].Params := Edit9.Text;
  FUserMenu[ListView1.Selected.index].UseSubMenu := CheckBox16.Checked;
  ListView1.Selected.Caption := Edit6.Text;

  Ico := TIcon.Create;
  try
    Ico.Handle := ExtractSmallIconByPath(Edit5.Text);
    ImageList1.ReplaceIcon(ListView1.Selected.index, Ico);
  finally
    F(Ico);
  end;
end;

procedure TOptionsForm.Edit6KeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = VK_RETURN then
    Button13Click(Sender);
end;

procedure TOptionsForm.Button16Click(Sender: TObject);
begin
  Settings.WriteString('', 'UserMenuName', Edit7.Text);
  Settings.WriteString('', 'UserMenuIcon', Edit8.Text);
end;

procedure TOptionsForm.Button15Click(Sender: TObject);
var
  FileName: string;
  IconIndex: Integer;
  S, Icon: string;
  I: Integer;
begin
  S := Edit8.Text;
  I := Pos(',', S);
  FileName := Copy(S, 1, I - 1);
  Icon := Copy(S, I + 1, Length(S) - I);
  IconIndex := StrToIntDef(Icon, 0);
  ChangeIconDialog(Handle, FileName, IconIndex);
  if FileName <> '' then
    Edit8.Text := FileName + ',' + IntToStr(IconIndex);

  SetIconToPictureFromPath(Image2.Picture, Icon);
end;

procedure TOptionsForm.Button17Click(Sender: TObject);
var
  Info: TUserMenuItem;
  Icon1, Icon2: TIcon;
begin
  Info := FUserMenu[ListView1.Selected.index];
  FUserMenu[ListView1.Selected.index] := FUserMenu[ListView1.Selected.index - 1];
  FUserMenu[ListView1.Selected.index - 1] := Info;
  Icon1 := TIcon.Create;
  Icon2 := TIcon.Create;
  try
    ImageList1.GetIcon(ListView1.Selected.index, Icon1);
    ImageList1.GetIcon(ListView1.Selected.index - 1, Icon2);
    ImageList1.ReplaceIcon(ListView1.Selected.index, Icon2);
    ImageList1.ReplaceIcon(ListView1.Selected.index - 1, Icon1);
    ListView1.Items[ListView1.Selected.index].Caption := FUserMenu[ListView1.Selected.index].Caption;
    ListView1.Items[ListView1.Selected.index - 1].Caption := FUserMenu[ListView1.Selected.index - 1].Caption;
    ListView1.Selected := ListView1.Items[ListView1.Selected.index - 1];
    ListView1.SetFocus;
  finally
    F(Icon1);
    F(Icon2);
  end;
end;

procedure TOptionsForm.Button18Click(Sender: TObject);
var
  Info: TUserMenuItem;
  Icon1, Icon2: TIcon;
begin
  Info := FUserMenu[ListView1.Selected.index];
  FUserMenu[ListView1.Selected.index] := FUserMenu[ListView1.Selected.index + 1];
  FUserMenu[ListView1.Selected.index + 1] := Info;
  Icon1 := TIcon.Create;
  Icon2 := TIcon.Create;
  try
    ImageList1.GetIcon(ListView1.Selected.index, Icon1);
    ImageList1.GetIcon(ListView1.Selected.index + 1, Icon2);
    ImageList1.ReplaceIcon(ListView1.Selected.index, Icon2);
    ImageList1.ReplaceIcon(ListView1.Selected.index + 1, Icon1);
    ListView1.Items[ListView1.Selected.index].Caption := FUserMenu[ListView1.Selected.index].Caption;
    ListView1.Items[ListView1.Selected.index + 1].Caption := FUserMenu[ListView1.Selected.index + 1].Caption;
    ListView1.Selected := ListView1.Items[ListView1.Selected.index + 1];
    ListView1.SetFocus;
  finally
    F(Icon1);
    F(Icon2);
  end;
end;

procedure TOptionsForm.BtnClearIconCacheClick(Sender: TObject);
begin
  TAIcons.Instance.Clear;
end;

procedure TOptionsForm.BtnClearThumbnailCacheClick(Sender: TObject);
begin
  AExplorerFolders.Clear;
end;

procedure TOptionsForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WndParent := GetDesktopWindow;
  with Params do
    ExStyle := ExStyle or WS_EX_APPWINDOW;
end;

procedure TOptionsForm.PcMainChange(Sender: TObject);
var
  AllowChange: Boolean;
begin
  TabbedNotebook1Change(Sender, PcMain.ActivePageIndex, AllowChange);
end;

procedure TOptionsForm.PlacesListViewContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  Item: TListItem;
begin
  Item := PlacesListView.GetItemAt(MousePos.X, MousePos.Y);
  if Item = nil then
  begin
    Up1.Visible := False;
    Down1.Visible := False;
    DeleteItem1.Visible := False;
    Rename1.Visible := False;
  end else
  begin
    Up1.Visible := Item.index <> 0;
    Down1.Visible := Item.index <> PlacesListView.Items.Count - 1;
    PopupMenu3.Tag := Item.index;
    Rename1.Visible := True;
    DeleteItem1.Visible := True;
  end;
  PopupMenu3.Popup(PlacesListView.ClientToScreen(MousePos).X, PlacesListView.ClientToScreen(MousePos).Y);
end;

procedure TOptionsForm.BtnChooseNewPlaceClick(Sender: TObject);
var
  NewPlace: String;
const
  DefaultIcon = '%SystemRoot%\system32\shell32.dll,3';
begin
  if PlacesListView.Selected = nil then
  begin
    NewPlace := UnitDBFileDialogs.DBSelectDir(Handle,
      L('Please, select a folder'), UseSimpleSelectFolderDialog);
    if DirectoryExists(NewPlace) then
    begin
      SetLength(FPlaces, Length(FPlaces) + 1);
      FPlaces[Length(FPlaces) - 1].Name := GetFileNameWithoutExt(NewPlace);
      FPlaces[Length(FPlaces) - 1].FolderName := NewPlace;
      FPlaces[Length(FPlaces) - 1].Icon := DefaultIcon;
      FPlaces[Length(FPlaces) - 1].MyComputer := true;
      FPlaces[Length(FPlaces) - 1].MyDocuments := true;
      FPlaces[Length(FPlaces) - 1].MyPictures := true;
      FPlaces[Length(FPlaces) - 1].OtherFolder := true;
      AddIconToListFromPath(PlacesImageList, DefaultIcon);
      with PlacesListView.Items.AddItem(nil) do
      begin
        ImageIndex := PlacesImageList.Count - 1;
        Caption := GetFileNameWithoutExt(NewPlace);
      end;
    end;
  end else
  begin
    NewPlace := UnitDBFileDialogs.DBSelectDir(Handle,
      L('Please, select a folder'),
      FPlaces[PlacesListView.Selected.Index].FolderName,
      UseSimpleSelectFolderDialog);
    if DirectoryExists(NewPlace) then
      FPlaces[PlacesListView.Selected.Index].FolderName := NewPlace;
    FPlaces[PlacesListView.Selected.Index].Name := GetFileNameWithoutExt
      (NewPlace);
    PlacesListView.Selected.Caption := GetFileNameWithoutExt(NewPlace);
  end;
end;

procedure TOptionsForm.ReadPlaces;
var
  Reg: TBDRegistry;
  S: TStrings;
  FName, FFolderName, FIcon: string;
  FMyComputer, FMyDocuments, FMyPictures, FOtherFolder: Boolean;
  I: Integer;
begin
  PlacesImageList.Clear;
  PlacesImageList.Width := 16;
  PlacesImageList.Height := 16;
  PlacesImageList.BkColor := Clmenu;
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(GetRegRootKey + '\Places', True);
    S := TStringList.Create;
    try
      Reg.GetKeyNames(S);
      SetLength(FPlaces, 0);
      PlacesListView.Clear;
      for I := 0 to S.Count - 1 do
      begin
        Reg.CloseKey;
        Reg.OpenKey(GetRegRootKey + '\Places\' + S[I], True);
        FMyComputer := False;
        FMyDocuments := False;
        FMyPictures := False;
        FOtherFolder := False;

        if Reg.ValueExists('Name') then
          FName := Reg.ReadString('Name');
        if Reg.ValueExists('FolderName') then
          FFolderName := Reg.ReadString('FolderName');
        if Reg.ValueExists('Icon') then
          FIcon := Reg.ReadString('Icon');
        if Reg.ValueExists('MyComputer') then
          FMyComputer := Reg.Readbool('MyComputer');
        if Reg.ValueExists('MyDocuments') then
          FMyDocuments := Reg.Readbool('MyDocuments');
        if Reg.ValueExists('MyPictures') then
          FMyPictures := Reg.Readbool('MyPictures');
        if Reg.ValueExists('OtherFolder') then
          FOtherFolder := Reg.Readbool('OtherFolder');

        if (FName <> '') and (FFolderName <> '') then
        begin
          SetLength(FPlaces, Length(FPlaces) + 1);
          FPlaces[Length(FPlaces) - 1].name := FName;
          FPlaces[Length(FPlaces) - 1].FolderName := FFolderName;
          FPlaces[Length(FPlaces) - 1].Icon := FIcon;
          FPlaces[Length(FPlaces) - 1].MyComputer := FMyComputer;
          FPlaces[Length(FPlaces) - 1].MyDocuments := FMyDocuments;
          FPlaces[Length(FPlaces) - 1].MyPictures := FMyPictures;
          FPlaces[Length(FPlaces) - 1].OtherFolder := FOtherFolder;

          AddIconToListFromPath(PlacesImageList, fIcon);

          with PlacesListView.Items.Add do
          begin
            ImageIndex := PlacesImageList.Count - 1;
            Caption := FName;
          end;
        end;
      end;
    finally
      F(S);
    end;
  finally
    F(Reg);
  end;
end;

procedure TOptionsForm.WlDefaultJPEGOptionsClick(Sender: TObject);
begin
  SetJPEGOptions;
end;

procedure TOptionsForm.WlViewerJPEGOptionsClick(Sender: TObject);
begin
  SetJPEGOptions('Viewer');
end;

procedure TOptionsForm.WritePlaces;
var
  I: Integer;
  Reg: TBDRegistry;
  S: TStrings;
begin
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(GetRegRootKey + '\Places', true);
    S := TStringList.Create;
    try
      Reg.GetKeyNames(S);
      Reg.CloseKey;
      for i := 1 to S.Count do
        Reg.DeleteKey(GetRegRootKey + '\Places\.' + IntToStr(i));
    finally
      F(S);
    end;

    for I := 0 to Length(FPlaces) - 1 do
    begin
      Reg.OpenKey(GetRegRootKey + '\Places\.' + IntToStr(I), true);
      Reg.WriteString('Name', FPlaces[I].Name);
      Reg.WriteString('FolderName', FPlaces[I].FolderName);
      Reg.WriteString('Icon', FPlaces[I].Icon);
      Reg.WriteBool('MyComputer', FPlaces[I].MyComputer);
      Reg.WriteBool('MyDocuments', FPlaces[I].MyDocuments);
      Reg.WriteBool('MyPictures', FPlaces[I].MyPictures);
      Reg.WriteBool('OtherFolder', FPlaces[I].OtherFolder);
      Reg.CloseKey;
    end;
  finally
    F(Reg);
  end;
end;

procedure TOptionsForm.PlacesListViewSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  I: Integer;
begin
  if not Selected then
  begin
    for I := 0 to 3 do
      CblPlacesDisplayIn.Checked[I] := False;
    CblPlacesDisplayIn.Enabled := False;
    BtnChoosePlaceIcon.Enabled := False;
  end else
  begin
    CblPlacesDisplayIn.Checked[0] := FPlaces[Item.Index].MyComputer;
    CblPlacesDisplayIn.Checked[1] := FPlaces[Item.Index].MyDocuments;
    CblPlacesDisplayIn.Checked[2] := FPlaces[Item.Index].MyPictures;
    CblPlacesDisplayIn.Checked[3] := FPlaces[Item.Index].OtherFolder;
    CblPlacesDisplayIn.Enabled := True;
    BtnChoosePlaceIcon.Enabled := True;
  end;
end;

procedure TOptionsForm.CblPlacesDisplayInClickCheck(Sender: TObject);
var
  I: Integer;
begin
  if PlacesListView.Selected <> nil then
  begin
    I := PlacesListView.Selected.Index;
    FPlaces[I].MyComputer := CblPlacesDisplayIn.Checked[0];
    FPlaces[I].MyDocuments := CblPlacesDisplayIn.Checked[1];
    FPlaces[I].MyPictures := CblPlacesDisplayIn.Checked[2];
    FPlaces[I].OtherFolder := CblPlacesDisplayIn.Checked[3];
  end;
end;

procedure TOptionsForm.BtnChoosePlaceIconClick(Sender: TObject);
var
  FileName: string;
  IconIndex: Integer;
  S, Icon: string;
  I, index: Integer;
  Ico: TIcon;
begin
  if PlacesListView.Selected = nil then
    Exit;
  index := PlacesListView.Selected.index;
  S := FPlaces[index].Icon;
  I := Pos(',', S);
  FileName := Copy(S, 1, I - 1);
  Icon := Copy(S, I + 1, Length(S) - I);
  IconIndex := StrToIntDef(Icon, 0);
  ChangeIconDialog(Handle, FileName, IconIndex);
  if FileName <> '' then
    FPlaces[index].Icon := FileName + ',' + IntToStr(IconIndex);
  Ico := TIcon.Create;
  try
    Ico.Handle := ExtractSmallIconByPath(FPlaces[index].Icon);
    PlacesImageList.ReplaceIcon(index, Ico);
  finally
    F(Ico);
  end;
end;

procedure TOptionsForm.DeleteItem1Click(Sender: TObject);
var
  I: Integer;
begin
  if PopupMenu3.Tag <> -1 then
  begin
    for I := PopupMenu3.Tag to Length(FPlaces) - 2 do
      FPlaces[i] := FPlaces[I + 1];
    SetLength(FPlaces, Length(FPlaces) - 1);
    PlacesListView.Items.Delete(PopupMenu3.Tag);
    PlacesImageList.Delete(PopupMenu3.Tag);
    for I := PopupMenu3.Tag to Length(FPlaces) - 1 do
      PlacesListView.Items[I].ImageIndex := PlacesListView.Items[I].ImageIndex - 1;
  end;
end;

procedure TOptionsForm.Up1Click(Sender: TObject);
var
  Info: TPlaceFolder;
  Icon1, Icon2: Ticon;
begin
  if PlacesListView.Selected = nil then
    Exit;
  Info := FPlaces[PlacesListView.Selected.index];
  FPlaces[PlacesListView.Selected.index] := FPlaces
    [PlacesListView.Selected.index - 1];
  FPlaces[PlacesListView.Selected.index - 1] := Info;
  Icon1 := Ticon.Create;
  Icon2 := Ticon.Create;
  try
    PlacesImageList.GetIcon(PlacesListView.Selected.index, Icon1);
    PlacesImageList.GetIcon(PlacesListView.Selected.index - 1, Icon2);
    PlacesImageList.ReplaceIcon(PlacesListView.Selected.index, Icon2);
    PlacesImageList.ReplaceIcon(PlacesListView.Selected.index - 1, Icon1);
    PlacesListView.Items[PlacesListView.Selected.index].Caption := FPlaces
      [PlacesListView.Selected.index].Name;
    PlacesListView.Items[PlacesListView.Selected.index - 1].Caption := FPlaces
      [PlacesListView.Selected.index - 1].Name;
    PlacesListView.Selected := PlacesListView.Items
      [PlacesListView.Selected.index - 1];
    PlacesListView.SetFocus;
  finally
    F(Icon1);
    F(Icon2);
  end;
end;

procedure TOptionsForm.Down1Click(Sender: TObject);
var
  info: TPlaceFolder;
  Icon1, Icon2: Ticon;
begin
  if PlacesListView.Selected = nil then
    Exit;

  Info := FPlaces[PlacesListView.Selected.index];
  FPlaces[PlacesListView.Selected.index] := FPlaces
    [PlacesListView.Selected.index + 1];
  FPlaces[PlacesListView.Selected.index + 1] := info;
  Icon1 := TIcon.Create;
  Icon2 := TIcon.Create;
  try
    PlacesImageList.GetIcon(PlacesListView.Selected.index, Icon1);
    PlacesImageList.GetIcon(PlacesListView.Selected.index + 1, Icon2);
    PlacesImageList.ReplaceIcon(PlacesListView.Selected.index, Icon2);
    PlacesImageList.ReplaceIcon(PlacesListView.Selected.index + 1, Icon1);
    PlacesListView.Items[PlacesListView.Selected.index].Caption := FPlaces
      [PlacesListView.Selected.index].Name;
    PlacesListView.Items[PlacesListView.Selected.index + 1].Caption := FPlaces
      [PlacesListView.Selected.index + 1].Name;
    PlacesListView.Selected := PlacesListView.Items
      [PlacesListView.Selected.index + 1];
    PlacesListView.SetFocus;
  finally
    F(Icon1);
    F(Icon2);
  end;
end;

procedure TOptionsForm.Rename1Click(Sender: TObject);
begin
  if PlacesListView.Selected = nil then
    exit;
  PlacesListView.Selected.EditCaption;
end;

procedure TOptionsForm.PlacesListViewEdited(Sender: TObject; Item: TListItem;
  var S: String);
begin
  FPlaces[Item.Index].Name := S;
end;

procedure TOptionsForm.Default1Click(Sender: TObject);
{Var
  i : Integer;
  Reg : TRegistry;
  S : String; }
begin
{ Reg:=TRegistry.Create;
 Reg.RootKey:=Windows.HKEY_CLASSES_ROOT;
 For i:=1 to CheckListBox1.Items.Count do
 begin
  Reg.OpenKey('\.'+CheckListBox1.Items[i-1],false);
  S:=Reg.ReadString('');
  Reg.CloseKey;
  Reg.OpenKey('\'+S+'\shell\open\command',false);
  If reg.ReadString('')='' then
  CheckListBox1.State[i-1]:=cbChecked else
  begin
   if FileRegisteredOnInstalledApplication(reg.ReadString('')) then
   CheckListBox1.State[i-1]:=cbChecked else
   CheckListBox1.State[i-1]:=cbGrayed;
  end;
  Reg.CloseKey;
 end;
 Reg.Free; }
end;

procedure TOptionsForm.CheckBox32Click(Sender: TObject);
begin
  CheckBox33.Enabled := CheckBox32.Checked;
  Edit11.Enabled := CheckBox33.Checked;
end;

procedure TOptionsForm.Button25Click(Sender: TObject);
var
  Dir: string;
begin
  Dir := UnitDBFileDialogs.DBSelectDir(Handle, L('Please select folder'), UseSimpleSelectFolderDialog);
  if DirectoryExists(Dir) then
    Edit11.Text := IncludeTrailingBackslash(Dir);
end;

procedure TOptionsForm.CheckBox33Click(Sender: TObject);
begin
  Edit11.Enabled := CheckBox33.Checked;
end;

procedure TOptionsForm.CheckBox34Click(Sender: TObject);
begin
  Edit12.Enabled := CheckBox34.Checked;
  Edit13.Enabled := CheckBox34.Checked;
end;

end.
