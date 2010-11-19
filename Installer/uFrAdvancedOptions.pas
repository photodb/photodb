unit uFrAdvancedOptions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst, uInstallFrame, UnitDBFileDialogs;

type
  TFrmAdvancedOptions = class(TInstallFrame)
    CbFileExtensions: TCheckListBox;
    EdPath: TEdit;
    Label1: TLabel;
    CheckBox3: TCheckBox;
    Label7: TLabel;
    CheckBox4: TCheckBox;
    Label8: TLabel;
    CheckBox5: TCheckBox;
    Label9: TLabel;
    BtnSelectDirectory: TButton;
    procedure BtnSelectDirectoryClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TFrmAdvancedOptions.BtnSelectDirectoryClick(Sender: TObject);
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

end.
