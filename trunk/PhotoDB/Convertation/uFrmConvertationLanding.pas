unit uFrmConvertationLanding;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, uFrameWizardBase, StdCtrls, UnitDBKernel;

type
  TFrmConvertationLanding = class(TFrameWizardBase)
    LbInfo: TLabel;
    LbCurrentDB: TLabel;
    EdDBPath: TEdit;
    EdDBVersion: TEdit;
    RbConvertParadox: TRadioButton;
    RbConvertMDB: TRadioButton;
  private
    function GetFileName: string;
    { Private declarations }
  protected
    { Protected declarations }
    procedure LoadLanguage; override;
  public
    { Public declarations }
    procedure Init(Manager: TWizardManagerBase; FirstInitialization: Boolean); override;
    property FileName: string read GetFileName;
  end;

implementation

uses
  UnitConvertDBForm;

{$R *.dfm}

{ TFrmConvertationLanding }

function TFrmConvertationLanding.GetFileName: string;
begin
  Result := TFormConvertingDB(Manager.Owner).FileName;
end;

procedure TFrmConvertationLanding.Init(Manager: TWizardManagerBase;
  FirstInitialization: Boolean);
var
  DBVer: Integer;
begin
  inherited;
  if FirstInitialization then
  begin
    RbConvertParadox.Enabled := False;
    EdDBPath.Text := FileName;
    DBVer := DBKernel.TestDBEx(FileName);
    EdDBVersion.Text := DBKernel.StringDBVersion(DBVer);
  end;
end;

procedure TFrmConvertationLanding.LoadLanguage;
begin
  inherited;
  LbCurrentDB.Caption := L('Current collection') + ':';
  RbConvertMDB.Caption := L('Convert to *.photodb (PhotoDB)');
  RbConvertParadox.Caption := L('Convert to *.db (Paradox)');
  LbInfo.Caption := L('This wizard will help you convert your database from one format to another.');
end;

end.
