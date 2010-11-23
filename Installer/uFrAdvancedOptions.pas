unit uFrAdvancedOptions;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst, uInstallFrame, UnitDBFileDialogs, Registry,
  uShellUtils, uInstallScope, uInstallUtils, uAssociations, uMemory, Menus;

type
  TFrAdvancedOptions = class(TInstallFrame)
    CbFileExtensions: TCheckListBox;
    EdPath: TEdit;
    LbInstallPath: TLabel;
    CbInstallTypeChecked: TCheckBox;
    Label7: TLabel;
    CbInstallTypeGrayed: TCheckBox;
    Label8: TLabel;
    CbInstallTypeNone: TCheckBox;
    Label9: TLabel;
    BtnSelectDirectory: TButton;
    PmAssociations: TPopupMenu;
    SelectDefault1: TMenuItem;
    SelectAll1: TMenuItem;
    SelectNone1: TMenuItem;
    procedure BtnSelectDirectoryClick(Sender: TObject);
    procedure SelectDefault1Click(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure SelectNone1Click(Sender: TObject);
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

procedure TFrAdvancedOptions.BtnSelectDirectoryClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := DBSelectDir(Handle, L('Please, select directory to install Photo Database.'), False);
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
    TFileAssociations.Instance.Exts[CbFileExtensions.Items[I]].State := CheckboxStateToAssociationState(CbFileExtensions.State[I]);
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
    CbFileExtensions.State[I] := AssociationStateToCheckboxState(TFileAssociations.Instance.GetCurrentAssociationState(CbFileExtensions.Items[I]));
end;

procedure TFrAdvancedOptions.LoadExtensionList;
var
  I : Integer;
begin
  CbFileExtensions.Items.Clear;
  for I := 0 to TFileAssociations.Instance.Count - 1 do
    CbFileExtensions.Items.Add(TFileAssociations.Instance[I].Extension);
end;

procedure TFrAdvancedOptions.LoadLanguage;
begin
  inherited;
  LbInstallPath.Caption := L('Install path') + ':';
  SelectDefault1.Caption := L('Select default associations');
  SelectAll1.Caption := L('Select all');
  SelectNone1.Caption := L('Select none');
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
