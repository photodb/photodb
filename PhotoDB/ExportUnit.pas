unit ExportUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DmProgress, Dolphin_db, ExtCtrls, uVistaFuncs,
  uShellIntegration, uDBForm;

type
  TExportForm = class(TDBForm)
    Edit1: TEdit;
    Button1: TButton;
    CbPrivate: TCheckBox;
    CbRating: TCheckBox;
    CbWithoutFiles: TCheckBox;
    PbMain: TDmProgress;
    BtnStart: TButton;
    Label1: TLabel;
    Label2: TLabel;
    SaveDialog1: TSaveDialog;
    CbGroups: TCheckBox;
    CbCrypted: TCheckBox;
    CbCryptedPass: TCheckBox;
    BtnBreak: TButton;
    DestroyTimer: TTimer;
    procedure BtnStartClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure SetRecordText(Value : String);
    procedure SetProgressMaxValue(Value : Integer);
    procedure SetProgressPosition(Value : Integer);
    procedure SetProgressText(Value : String);
    procedure Edit1Change(Sender: TObject);
    procedure DoExit(Sender: TObject);
    procedure Execute;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure CbCryptedClick(Sender: TObject);
    procedure DestroyTimerTimer(Sender: TObject);
    procedure BtnBreakClick(Sender: TObject);
  private
    { Private declarations }
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    procedure LoadLanguage;
  end;

var
  Working : Boolean = False;

implementation

uses UnitExportThread, Language;

{$R *.dfm}

procedure TExportForm.BtnStartClick(Sender: TObject);
var
  Options: TExportOptions;
  F: TextFile;
begin
  System.Assign(F, Edit1.text);
{$I-}
  System.Rewrite(F);
{$I+}
  if IOResult <> 0 then
  begin
    MessageBoxDB(Handle, Format(TEXT_MES_CANNOT_CREATE_FILE_F, [Edit1.text]),
      L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
    Exit;
  end;
  System.Close(F);
  Button1.Enabled := False;
  BtnStart.Enabled := False;
  Options.ExportPrivate := CbPrivate.Checked;
  Options.ExportRatingOnly := CbRating.Checked;
  Options.ExportNoFiles := CbWithoutFiles.Checked;
  Options.ExportGroups := CbGroups.Checked;
  Options.ExportCrypt := CbCrypted.Checked;
  Options.ExportCryptIfPassFinded := CbCryptedPass.Checked and CbCrypted.Enabled; ;
  Options.FileName := Edit1.text;
  CbPrivate.Enabled := False;
  CbRating.Enabled := False;
  CbWithoutFiles.Enabled := False;
  CbGroups.Enabled := False;
  CbCrypted.Enabled := False;
  CbCryptedPass.Enabled := False;
  Working := True;
  BtnBreak.Enabled := True;
  ExportThread.Create(Options);
end;

procedure TExportForm.Button1Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    if AnsiUpperCase(ExtractFileExt(SaveDialog1.FileName)) <> '.PHOTODB' then
      SaveDialog1.FileName := SaveDialog1.FileName + '.photodb';

    if FileExists(SaveDialog1.FileName) then
      if ID_OK <> MessageBoxDB(Handle, Format(L('File &quot;%s&quot; already exists! $nl$Replace?'), [SaveDialog1.FileName]), L('Warning'),
        TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
        Exit;

    Edit1.Text := SaveDialog1.FileName;
  end;
end;

procedure TExportForm.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #8 then
    if not Working then
    begin
      Edit1.Text := TEXT_MES_NO_FILEA;
    end;
end;

procedure TExportForm.SetRecordText(Value: string);
begin
  Label2.Caption := Value;
end;

procedure TExportForm.Edit1Change(Sender: TObject);
begin
  BtnStart.Enabled := Edit1.Text <> TEXT_MES_NO_FILEA
end;

procedure TExportForm.Execute;
begin
  Edit1Change(Self);
  ShowModal;
end;

procedure TExportForm.FormCreate(Sender: TObject);
begin
  LoadLanguage;
end;

function TExportForm.GetFormID: string;
begin
  Result := 'ExportDB';
end;

procedure TExportForm.SetProgressMaxValue(Value: Integer);
begin
  PbMain.MaxValue := Value;
end;

procedure TExportForm.SetProgressPosition(Value: Integer);
begin
  PbMain.Position := Value;
end;

procedure TExportForm.SetProgressText(Value: string);
begin
  PbMain.Text := Value;
end;

procedure TExportForm.DoExit(Sender: TObject);
begin
 Working:=false;
 Close;
end;

procedure TExportForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
 If Working then CanClose:=false;
end;

procedure TExportForm.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Export Collection');
    CbPrivate.Caption := L('Export private records');
    CbRating.Caption := L('Export items with rating');
    CbWithoutFiles.Caption := L('Export items without files');
    CbGroups.Caption := L('Export of groups');
    CbCrypted.Caption := L('Export crypted items');
    CbCryptedPass.Caption := L('Export crypted items if password has been found');
    BtnStart.Caption := L('Begin export');
    BtnBreak.Caption := L('Break!');
    Label1.Caption := L('Item') + ':';
    PbMain.text := L('Executing... (&%%)');
  finally
    EndTranslate;
  end;
end;

procedure TExportForm.CbCryptedClick(Sender: TObject);
begin
  CbCryptedPass.Enabled := CbCrypted.Checked;
end;

procedure TExportForm.DestroyTimerTimer(Sender: TObject);
begin
  DestroyTimer.Enabled := False;
  Release;
end;

procedure TExportForm.BtnBreakClick(Sender: TObject);
begin
  UnitExportThread.StopExport := True;
end;

end.
