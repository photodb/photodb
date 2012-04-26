unit UnitFormCDMapInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Dolphin_DB, UnitDBKernel, uCDMappingTypes,
  UnitCDMappingSupport, uShellIntegration, uConstants, uDBForm, pngimage;

type
  TFormCDMapInfo = class(TDBForm)
    Image1: TImage;
    LabelInfo: TLabel;
    BtnCancel: TButton;
    LabelDisk: TLabel;
    EditCDName: TEdit;
    BtnSelectDrive: TButton;
    BtnDontAskAgain: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BtnSelectDriveClick(Sender: TObject);
    procedure BtnDontAskAgainClick(Sender: TObject);
  private
    { Private declarations }
    FCDName: string;
    MapResult: Boolean;
    procedure LoadLanguage;
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    function Execute(CDName: string): Boolean;
  end;

function CheckCD(CDName : string) : Boolean;

implementation

function CheckCD(CDName : string) : Boolean;
var
  FormCDMapInfo: TFormCDMapInfo;
begin
  Application.CreateForm(TFormCDMapInfo, FormCDMapInfo);
  Result := FormCDMapInfo.Execute(CDName);
end;

{$R *.dfm}

function TFormCDMapInfo.Execute(CDName : string) : Boolean;
begin
  FCDName := CDName;
  EditCDName.Text := CDName;
  MapResult := False;
  LoadLanguage;
  ShowModal;
  Result := MapResult;
end;

procedure TFormCDMapInfo.LoadLanguage;
var
  SelectDriveLabel : string;
begin
  BeginTranslate;
  try
    Caption := L('Map CD/DVD');
    SelectDriveLabel := L('Select drive');
    LabelInfo.Caption := Format(L('You try to open file, which placed on removable drive (CD or DVD)') + #13 + L
        ('Enter, please, drive with label "%s" and choose "%s" to find this drive.') + #13 + L
        ('You can select a directory with files or file "%s" on the drive.'), [FCDName, SelectDriveLabel, C_CD_MAP_FILE]);
    BtnDontAskAgain.Caption := L('Don''t ask me again');
    BtnSelectDrive.Caption := SelectDriveLabel;
    BtnCancel.Caption := L('Cancel');
    LabelDisk.Caption := L('Disk') + ':';
  finally
    EndTranslate;
  end;
end;

procedure TFormCDMapInfo.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Release;
end;

procedure TFormCDMapInfo.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormCDMapInfo.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

function TFormCDMapInfo.GetFormID: string;
begin
  Result := 'MapCDInfo';
end;

procedure TFormCDMapInfo.BtnSelectDriveClick(Sender: TObject);
var
  CDLabel: string;
begin
  CDLabel := AddCDLocation(Handle, FCDName);
  if CDLabel = '' then
    Exit;
  if AnsiLowerCase(CDLabel) <> AnsiLowerCase(EditCDName.Text) then
  begin
    if ID_YES = MessageBoxDB(Handle,
      Format(L('Was loaded disc labeled "%s", but required the disc labeled "%s"! Do you want to close this dialog?'), [CDLabel, EditCDName.Text]),
      L('Warning'), TD_BUTTON_YESNO, TD_ICON_QUESTION) then
      Close;

    Exit;
  end;
  MapResult := True;
  Close;
end;

procedure TFormCDMapInfo.BtnDontAskAgainClick(Sender: TObject);
begin
  CDMapper.SetCDWithNOQuestion(EditCDName.Text);
  Close;
end;

initialization
  CheckCDFunction := CheckCD;

end.
