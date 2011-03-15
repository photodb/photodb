unit Options;

interface

uses
  Registry, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, TabNotBk, DmProgress, ExtCtrls, CheckLst,
  Menus, ShellCtrls, Dolphin_DB, ImgList, Math, GDIPlusRotate, Mask, uFileUtils,
  acDlgSelect, UnitDBKernel, SaveWindowPos, UnitINI, uVistaFuncs, UnitDBDeclare,
  UnitDBFileDialogs, uAssociatedIcons, uLogger, uConstants, uShellIntegration,
  UnitDBCommon, UnitDBCommonGraphics, uTranslate, uShellUtils, uDBForm,
  uRuntime, uMemory, uSettings;

type
  TOptionsForm = class(TDBForm)
    CancelButton: TButton;
    OkButton: TButton;
    PopupMenu1: TPopupMenu;
    Usethisprogramasdefault1: TMenuItem;
    Usemenuitem1: TMenuItem;
    Dontusethisextension1: TMenuItem;
    PopupMenu2: TPopupMenu;
    Addnewcommand1: TMenuItem;
    Remore1: TMenuItem;
    ImageList1: TImageList;
    DestroyTimer: TTimer;
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
    Button20: TButton;
    Button12: TButton;
    Button19: TButton;
    Button24: TButton;
    Button23: TButton;
    CheckListBox1: TCheckListBox;
    PlacesListView: TListView;
    CheckListBox2: TCheckListBox;
    Label27: TLabel;
    Label11: TLabel;
    CheckBox21: TCheckBox;
    CheckBox20: TCheckBox;
    CheckBox12: TCheckBox;
    CheckBox11: TCheckBox;
    CheckBox10: TCheckBox;
    CheckBox9: TCheckBox;
    Label13: TStaticText;
    Label12: TStaticText;
    CheckBox1: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    Label14: TStaticText;
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
    Button21: TButton;
    CheckBox22: TCheckBox;
    CheckBox2: TCheckBox;
    TsUserMenu: TTabSheet;
    Button2: TButton;
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
    Label17: TLabel;
    Image1: TImage;
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
    Button22: TButton;
    CheckBox27: TCheckBox;
    CheckBox26: TCheckBox;
    CheckBox23: TCheckBox;
    Label34: TLabel;
    CheckBox4: TCheckBox;
    procedure TabbedNotebook1Change(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure CheckListBox1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Usethisprogramasdefault1Click(Sender: TObject);
    procedure Usemenuitem1Click(Sender: TObject);
    procedure Dontusethisextension1Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure TrackBar3Change(Sender: TObject);
    procedure LoadExts;
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
    procedure Button20Click(Sender: TObject);
    procedure Button19Click(Sender: TObject);
    procedure TrackBar4Change(Sender: TObject);
    procedure DestroyTimerTimer(Sender: TObject);
    procedure Button21Click(Sender: TObject);
    procedure Button22Click(Sender: TObject);
    procedure PlacesListViewContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Button24Click(Sender: TObject);
    procedure ReadPlaces;
    procedure WritePlaces;
    procedure PlacesListViewSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure CheckListBox2ClickCheck(Sender: TObject);
    procedure Button23Click(Sender: TObject);
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
  I, J: Integer;
  Reg: TBDRegistry;
  S: TStrings;
  FCaption, EXEFile, Params, Icon: string;
  UseSubMenu: Boolean;
  Ico: Ticon;
  RegIni: TRegIniFile;
begin
  if FLoadedPages[NewTab] then
    Exit;
  FLoadedPages[NewTab] := True;

  if NewTab = 0 then
  begin
    CheckBox4.Checked := Settings.Readbool('Options', 'AllowPreview', True);
  end;
  if NewTab = 1 then
  begin
    CheckBox1.Checked := Settings.Readbool('Options', 'Explorer_ShowFolders', True);
    CheckBox6.Checked := Settings.Readbool('Options', 'Explorer_ShowSimpleFiles', True);
    CheckBox7.Checked := Settings.Readbool('Options', 'Explorer_ShowImageFiles', True);
    CheckBox8.Checked := Settings.Readbool('Options', 'Explorer_ShowHiddenFiles', False);
    CheckBox9.Checked := Settings.Readbool('Options', 'Explorer_ShowAttributes', True);
    CheckBox10.Checked := Settings.Readbool('Options', 'Explorer_ShowThumbnailsForFolders', True);
    CheckBox11.Checked := Settings.Readbool('Options', 'Explorer_SaveThumbnailsForFolders', True);
    CheckBox12.Checked := Settings.Readbool('Options', 'Explorer_ShowThumbnailsForImages', True);
    CheckBox20.Checked := Settings.ReadBool('Options', 'ShowEXIFMarker', False);
    CheckBox21.Checked := Settings.ReadBool('Options', 'ShowOtherPlaces', True);
    CheckListBox1.Items.Clear;
    //TODO:!!!!
    {for I := 1 to Length(SupportedExt) do
    begin
      if SupportedExt[I] = '|' then
        for J := I to Length(SupportedExt) do
        begin
          if SupportedExt[J] = '|' then
            if (J - I - 1 > 0) and (I + 1 < Length(SupportedExt)) then
              if (Copy(SupportedExt, I + 1, J - I - 1)) <> '' then
              begin
                CheckListBox1.Items.Add(AnsiUppercase(Copy(SupportedExt, I + 1, J - I - 1)));
                Break;
              end;
        end;
    end; }
    LoadExts;
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
    CheckBox27.Checked := Settings.Readbool('Options', 'UseGDIPlus', GDIPlusPresent);
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
    Reg.OpenKey(GetRegRootKey + '\Menu', True);
    S := TStringList.Create;
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
    S.Free;
    Reg.Free;
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

procedure TOptionsForm.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  InitGDIPlus;
  ReloadData := False;
  ClientHeight := OkButton.Top + OkButton.Height + 3;

  SaveWindowPos1.Key := GetRegRootKey + 'Options';
  SaveWindowPos1.SetPosition;
  for I := 0 to 5 do
    FLoadedPages[I] := False;
  LoadLanguage;
  FThemeList := nil;
  CheckBox27.Enabled := GDIPlusPresent;
  if not GDIPlusPresent then
    CheckBox27.Caption := L('GDI+ is unavaliable');
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
end;

procedure TOptionsForm.OkButtonClick(Sender: TObject);
var
  Exts: TInstallExts;
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
    Settings.WriteBool('Options', 'AllowPreview', CheckBox4.Checked);
  end;
  // 1: 
  if FLoadedPages[1] then
  begin
    Settings.WriteBool('Options', 'Explorer_ShowFolders', CheckBox1.Checked);
    Settings.WriteBool('Options', 'Explorer_ShowSimpleFiles', CheckBox6.Checked);
    Settings.WriteBool('Options', 'Explorer_ShowImageFiles', CheckBox7.Checked);
    Settings.WriteBool('Options', 'Explorer_ShowHiddenFiles', CheckBox8.Checked);
    Settings.WriteBool('Options', 'Explorer_ShowAttributes', CheckBox9.Checked);
    Settings.WriteBool('Options', 'Explorer_ShowThumbnailsForFolders', CheckBox10.Checked);
    Settings.WriteBool('Options', 'Explorer_SaveThumbnailsForFolders', CheckBox11.Checked);
    Settings.WriteBool('Options', 'Explorer_ShowThumbnailsForImages', CheckBox12.Checked);
    Settings.WriteBool('Options', 'ShowEXIFMarker', CheckBox20.Checked);
    Settings.WriteBool('Options', 'ShowOtherPlaces', CheckBox21.Checked);

    ExplorerManager.ShowEXIF := CheckBox20.Checked;
    ExplorerManager.ShowQuickLinks := CheckBox21.Checked;
    SetLength(Exts, CheckListBox1.Items.Count);
    for I := 1 to CheckListBox1.Items.Count do
    begin
      Exts[I - 1].Ext := CheckListBox1.Items[I - 1];
      case CheckListBox1.State[I - 1] of
        CbUnchecked:
          Exts[I - 1].InstallType := InstallType_UnChecked;
        CbChecked:
          Exts[I - 1].InstallType := InstallType_Checked;
        CbGrayed:
          Exts[I - 1].InstallType := InstallType_Grayed;
      end;
    end;
    // TODO: ExtInstallApplicationW(Exts,InstalledFileName); 
    WritePlaces;
  end;
  // 3 : 
  if FLoadedPages[3] then
  begin
    Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
    Reg.OpenKey(GetRegRootKey + '\Menu', True);
    S := TStringList.Create;
    Reg.GetKeyNames(S);
    Reg.CloseKey;
    for I := 1 to S.Count do
    begin
      Reg.DeleteKey(GetRegRootKey + '\Menu\.' + IntToStr(I));
    end;
    S.Free;
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
    Reg.Free;
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
    Settings.WriteBool('Options', 'UseSmallToolBarButtons', CheckBox38.Checked);
    Settings.WriteBool('Options', 'UseListViewFullRectSelect', CheckBox5.Checked);
    Settings.WriteInteger('Options', 'UseListViewRoundRectSize', StrToIntDef(Edit2.Text, 0));

    Settings.WriteBool('Options', 'UseGroupsInSearch', CheckBox35.Checked);
    Settings.WriteBool('Options', 'SortGroupsByName', CheckBox26.Checked);
    Settings.WriteBool('Options', 'UseHotSelect', CheckBox23.Checked);
    Settings.WriteBool('Options', 'UseGDIPlus', CheckBox27.Checked);
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
  DestroyTimer.Enabled := True;
end;

procedure TOptionsForm.CancelButtonClick(Sender: TObject);
begin
  Close;
  DestroyTimer.Enabled := True;
end;

procedure TOptionsForm.CheckListBox1ContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
var
  Item: Integer;
begin
  Item := CheckListBox1.ItemAtPos(MousePos, True);
  if Item <> -1 then
  begin
    PopupMenu1.Tag := Item;
    Usethisprogramasdefault1.Checked := False;
    Usemenuitem1.Checked := False;
    Dontusethisextension1.Checked := False;
    case CheckListBox1.State[Item] of
      CbUnchecked:
        Dontusethisextension1.Checked := True;
      CbChecked:
        Usethisprogramasdefault1.Checked := True;
      CbGrayed:
        Usemenuitem1.Checked := True;
    end;
  end;
  PopupMenu1.PopUp(CheckListBox1.CLientToScreen(MousePos).X, CheckListBox1.CLientToScreen(MousePos).Y);
end;

procedure TOptionsForm.Usethisprogramasdefault1Click(Sender: TObject);
begin
  CheckListBox1.State[PopupMenu1.Tag] := CbChecked;
end;

procedure TOptionsForm.Usemenuitem1Click(Sender: TObject);
begin
  CheckListBox1.State[PopupMenu1.Tag] := CbGrayed;
end;

procedure TOptionsForm.Dontusethisextension1Click(Sender: TObject);
begin
  CheckListBox1.State[PopupMenu1.Tag] := CbUnchecked;
end;

procedure TOptionsForm.Button12Click(Sender: TObject);
var
  I: Integer;
  Exts: TInstallExts;
begin
  SetLength(Exts, CheckListBox1.Items.Count);
  for I := 1 to CheckListBox1.Items.Count do
  begin
    Exts[I - 1].Ext := CheckListBox1.Items[I - 1];
    case CheckListBox1.State[I - 1] of
      CbUnchecked:
        Exts[I - 1].InstallType := InstallType_UnChecked;
      CbChecked:
        Exts[I - 1].InstallType := InstallType_Checked;
      CbGrayed:
        Exts[I - 1].InstallType := InstallType_Grayed;
    end;
  end;
  // TODO: ExtInstallApplicationW(Exts,Application.ExeName); 
  LoadExts;
  try
    // TODO: RebuildIconCacheAndNotifyChanges; 
  except
  end;
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
    CheckBox1.Caption := L('Folders');
    CheckBox6.Caption := L('Simple files');
    CheckBox7.Caption := L('Images');
    CheckBox8.Caption := L('Hidden files');
    Label13.Caption := L('Preview options') + ':';
    CheckBox9.Caption := L('Display attributes');
    CheckBox10.Caption := L('Display previews for folders');
    CheckBox11.Caption := L('Save preview for folders');
    CheckBox12.Caption := L('Show previews for images');
    Button12.Caption := L('Set');
    OkButton.Caption := L('Ok');
    CancelButton.Caption := L('Cancel');
    CheckBox2.Caption := L('Use high-quality rendering');
    Label14.Caption := L('Extensions') + ':';
    TrackBar4Change(Self);
    TrackBar3Change(Self);
    TrackBar2Change(Self);
    TrackBar1Change(Self);
    Label17.Caption := L('WARNING: Use encryption carefully. If you have forgotten the password to any images, they can not be restored!');
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
    Button19.Caption := L('Clear previews cache');
    Button20.Caption := L('Clear icons cache');
    CheckBox20.Caption := L('Show EXIF marker');
    CheckBox21.Caption := L('Display links "Other places"');
    CheckBox22.Caption := L('"Next" by click');
    CheckBox23.Caption := L('Use the selection by hover on the list');
    CheckBox24.Caption := L('Rotate the image on the disk without asking for confirmation');
    CheckBox25.Caption := L('Even if the file in the database, rotate on drive');
    Button21.Caption := L('JPEG Options');
    Button22.Caption := L('JPEG Options');
    CheckBox26.Caption := L('Sort groups');
    CheckBox27.Caption := L('Use GDI+');
    Label29.Caption := L('Create backup every') + ':';
    Label30.Caption := L('days');
    CheckBox28.Caption := L('Allow multiple instances of properties window');
    CheckListBox2.Clear;
    CheckListBox2.Items.Add(L('My computer'));
    CheckListBox2.Items.Add(L('My documents'));
    CheckListBox2.Items.Add(L('My pictures'));
    CheckListBox2.Items.Add(L('Other places'));
    Button24.Caption := L('New place');
    Label27.Caption := L('Display in') + ':';
    Label11.Caption := L('User defined places') + ':';
    PlacesListView.Columns[0].Caption := L('Places') + ':';

    Additem1.Caption := L('New place');
    DeleteItem1.Caption := L('Delete');
    Up1.Caption := L('Up');
    Down1.Caption := L('Down');
    Button23.Caption := L('Icon');
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

procedure TOptionsForm.LoadExts;
{var
  i : integer;
  reg : TRegistry;
  s : string;   }
begin
 {Reg:=TRegistry.Create;
 Reg.RootKey:=Windows.HKEY_CLASSES_ROOT;
 For i:=1 to CheckListBox1.Items.Count do
 begin
  CheckListBox1.State[i-1]:=cbUnchecked;
  Reg.OpenKey('\.'+CheckListBox1.Items[i-1],false);
  S:=Reg.ReadString('');
  Reg.CloseKey;
  Reg.OpenKey('\'+S+'\shell\open\command',false);
  If reg.ReadString('')='' then
  CheckListBox1.State[i-1]:=cbUnchecked else
  begin
   if FileRegisteredOnInstalledApplication(reg.ReadString('')) then
   CheckListBox1.State[i-1]:=cbChecked else
   begin
    Reg.CloseKey;
    Reg.OpenKey('\'+S+'\Shell\PhotoDBView\command',false);
    if FileRegisteredOnInstalledApplication(reg.ReadString('')) then
    CheckListBox1.State[i-1]:=cbGrayed else
    CheckListBox1.State[i-1]:=cbUnchecked;
   end;
  end;
  Reg.CloseKey;
 end;
 Reg.Free;}
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

procedure TOptionsForm.Button20Click(Sender: TObject);
begin
  TAIcons.Instance.Clear;
end;

procedure TOptionsForm.Button19Click(Sender: TObject);
begin
  AExplorerFolders.Clear;
end;

procedure TOptionsForm.DestroyTimerTimer(Sender: TObject);
begin
  SaveWindowPos1.SavePosition;
  DestroyTimer.Enabled := False;
  Release;
  OptionsForm := nil;
end;

procedure TOptionsForm.Button21Click(Sender: TObject);
begin
  SetJPEGOptions('Viewer');
end;

procedure TOptionsForm.Button22Click(Sender: TObject);
begin
  SetJPEGOptions;
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

procedure TOptionsForm.Button24Click(Sender: TObject);
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
      CheckListBox2.Checked[I] := False;
    CheckListBox2.Enabled := False;
    Button23.Enabled := False;
  end else
  begin
    CheckListBox2.Checked[0] := FPlaces[Item.Index].MyComputer;
    CheckListBox2.Checked[1] := FPlaces[Item.Index].MyDocuments;
    CheckListBox2.Checked[2] := FPlaces[Item.Index].MyPictures;
    CheckListBox2.Checked[3] := FPlaces[Item.Index].OtherFolder;
    CheckListBox2.Enabled := True;
    Button23.Enabled := True;
  end;
end;

procedure TOptionsForm.CheckListBox2ClickCheck(Sender: TObject);
var
  I: Integer;
begin
  if PlacesListView.Selected <> nil then
  begin
    I := PlacesListView.Selected.Index;
    FPlaces[I].MyComputer := CheckListBox2.Checked[0];
    FPlaces[I].MyDocuments := CheckListBox2.Checked[1];
    FPlaces[I].MyPictures := CheckListBox2.Checked[2];
    FPlaces[I].OtherFolder := CheckListBox2.Checked[3];
  end;
end;

procedure TOptionsForm.Button23Click(Sender: TObject);
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
