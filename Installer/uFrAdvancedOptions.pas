unit uFrAdvancedOptions;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst, uInstallFrame, UnitDBFileDialogs,
  uShellUtils, uInstallScope;

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
    procedure BtnSelectDirectoryClick(Sender: TObject);
  private
    { Private declarations }
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
  EdPath.Text := IncludeTrailingBackslash(GetProgramFilesPath) + 'Photo DataBase';
end;

procedure TFrAdvancedOptions.InitInstall;
begin
  inherited;
  CurrentInstall.DestinationPath := EdPath.Text;
end;

procedure TFrAdvancedOptions.LoadLanguage;
begin
  inherited;
  LbInstallPath.Caption := L('Install path') + ':';
end;

function TFrAdvancedOptions.ValidateFrame: Boolean;
begin
  Result := True;
end;

end.
