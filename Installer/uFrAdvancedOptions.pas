unit uFrAdvancedOptions;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  System.Win.Registry,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.CheckLst,
  Vcl.Menus,
  Vcl.AppEvnts,

  UnitDBFileDialogs,

  uInstallFrame,
  uShellUtils,
  uInstallScope,
  uInstallUtils,
  uAssociations,
  uMemory;

type
  TFrAdvancedOptions = class(TInstallFrame)
    CbFileExtensions: TCheckListBox;
    EdPath: TEdit;
    LbInstallPath: TLabel;
    CbInstallTypeChecked: TCheckBox;
    LblUseExt: TLabel;
    CbInstallTypeGrayed: TCheckBox;
    LblAddSubmenuItem: TLabel;
    CbInstallTypeNone: TCheckBox;
    LblSkipExt: TLabel;
    BtnSelectDirectory: TButton;
    PmAssociations: TPopupMenu;
    SelectDefault1: TMenuItem;
    SelectAll1: TMenuItem;
    SelectNone1: TMenuItem;
    AppEvents: TApplicationEvents;
    procedure BtnSelectDirectoryClick(Sender: TObject);
    procedure SelectDefault1Click(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure SelectNone1Click(Sender: TObject);
    procedure AppEventsMessage(var Msg: tagMSG; var Handled: Boolean);
  private
    { Private declarations }
    procedure LoadExtensionList;
    procedure LoadDefault;
    procedure LoadNone;
    procedure LoadAll;
  public
    { Public declarations }
    procedure Init; override;
    procedure LoadLanguage; override;
    function ValidateFrame : Boolean; override;
    procedure InitInstall; override;
  end;

implementation

{$R *.dfm}

procedure TFrAdvancedOptions.AppEventsMessage(var Msg: tagMSG;
  var Handled: Boolean);
begin
  inherited;
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

procedure TFrAdvancedOptions.BtnSelectDirectoryClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := DBSelectDir(Handle, L('Please, select directory to install Photo Database.'));
  if DirectoryExists(Dir) then
  begin
    Dir := IncludeTrailingBackslash(Dir);
    EdPath.Text := Dir + 'Photo DataBase';
  end;
end;

procedure TFrAdvancedOptions.Init;
begin
  inherited;
  LoadExtensionList;
  LoadDefault;
  EdPath.Enabled := not IsApplicationInstalled;
  BtnSelectDirectory.Enabled := not IsApplicationInstalled;
  if not EdPath.Enabled then
    EdPath.Text := ExtractFileDir(GetInstalledFileName)
  else
    EdPath.Text := IncludeTrailingBackslash(GetProgramFilesPath) + 'Photo DataBase';
end;

procedure TFrAdvancedOptions.InitInstall;
var
  I: Integer;
begin
  inherited;
  for I := 0 to CbFileExtensions.Items.Count - 1 do
    TFileAssociations.Instance.Exts[TFileAssociation(CbFileExtensions.Items.Objects[I]).Extension].State := CheckboxStateToAssociationState(CbFileExtensions.State[I]);
  CurrentInstall.DestinationPath := EdPath.Text;
end;

procedure TFrAdvancedOptions.LoadAll;
var
  I: Integer;
begin
  for I := 0 to CbFileExtensions.Items.Count - 1 do
    CbFileExtensions.State[I] := CbChecked;
end;

procedure TFrAdvancedOptions.LoadDefault;
var
  I: Integer;
begin
  for I := 0 to CbFileExtensions.Items.Count - 1 do
    CbFileExtensions.State[I] := AssociationStateToCheckboxState(TFileAssociations.Instance.GetCurrentAssociationState(TFileAssociation(CbFileExtensions.Items.Objects[I]).Extension), IsApplicationInstalled);
end;

procedure TFrAdvancedOptions.LoadExtensionList;
var
  I : Integer;
begin
  CbFileExtensions.Items.Clear;
  for I := 0 to TFileAssociations.Instance.Count - 1 do
    CbFileExtensions.Items.AddObject(Format('%s   (%s)', [TFileAssociations.Instance[I].Extension, TFileAssociations.Instance[I].Description]), TFileAssociations.Instance[I]);
end;

procedure TFrAdvancedOptions.LoadLanguage;
begin
  inherited;
  LbInstallPath.Caption := L('Install path') + ':';
  SelectDefault1.Caption := L('Select default associations');
  SelectAll1.Caption := L('Select all');
  SelectNone1.Caption := L('Select none');
  LblUseExt.Caption := L('Use PhotoDB as default association');
  LblAddSubmenuItem.Caption := L('Add menu item');
  LblSkipExt.Caption := L('Don''t use this extension');
end;

procedure TFrAdvancedOptions.LoadNone;
var
  I: Integer;
begin
  for I := 0 to CbFileExtensions.Items.Count - 1 do
    CbFileExtensions.State[I] := cbUnchecked;
end;

procedure TFrAdvancedOptions.SelectAll1Click(Sender: TObject);
begin
  inherited;
  LoadAll;
end;

procedure TFrAdvancedOptions.SelectDefault1Click(Sender: TObject);
begin
  inherited;
  LoadDefault;
end;

procedure TFrAdvancedOptions.SelectNone1Click(Sender: TObject);
begin
  inherited;
  LoadNone;
end;

function TFrAdvancedOptions.ValidateFrame: Boolean;
begin
  Result := True;
end;

end.
