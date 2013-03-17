unit ExportUnit;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,

  Dmitry.Controls.WatermarkedEdit,
  Dmitry.Controls.DmProgress,
  Dmitry.Utils.Files,

  uConstants,
  uShellIntegration,
  uProgramStatInfo,
  uDBForm;

type
  TExportForm = class(TDBForm)
    BtnSelectFile: TButton;
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
    EdName: TWatermarkedEdit;
    procedure BtnStartClick(Sender: TObject);
    procedure BtnSelectFileClick(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure Edit1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure CbCryptedClick(Sender: TObject);
    procedure BtnBreakClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure LoadLanguage;
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    procedure Execute;

    procedure SetRecordText(Value: string);
    procedure SetProgressMaxValue(Value: Integer);
    procedure SetProgressPosition(Value: Integer);
    procedure SetProgressText(Value: string);
    procedure DoFormExit(Sender: TObject);
  end;

var
  Working: Boolean = False;

implementation

uses
  UnitExportThread;

{$R *.dfm}

procedure TExportForm.BtnStartClick(Sender: TObject);
var
  Options: TExportOptions;
  F: TextFile;
begin
  ProgramStatistics.DBExportUsed;

  System.Assign(F, EdName.text);
{$I-}
  System.Rewrite(F);
{$I+}
  if IOResult <> 0 then
  begin
    MessageBoxDB(Handle, Format(L('Can not create file "%s"'), [EdName.text]),
      L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
    Exit;
  end;
  System.Close(F);
  BtnSelectFile.Enabled := False;
  BtnStart.Enabled := False;
  EdName.Enabled := False;
  Options.OwnerForm := Self;
  Options.ExportPrivate := CbPrivate.Checked;
  Options.ExportRatingOnly := CbRating.Checked;
  Options.ExportNoFiles := CbWithoutFiles.Checked;
  Options.ExportGroups := CbGroups.Checked;
  Options.ExportCrypt := CbCrypted.Checked;
  Options.ExportCryptIfPassFinded := CbCryptedPass.Checked and CbCrypted.Enabled;
  Options.FileName := EdName.text;
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

procedure TExportForm.BtnSelectFileClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    if AnsiUpperCase(ExtractFileExt(SaveDialog1.FileName)) <> '.PHOTODB' then
      SaveDialog1.FileName := SaveDialog1.FileName + '.photodb';

    if FileExistsSafe(SaveDialog1.FileName) then
      if ID_OK <> MessageBoxDB(Handle, Format(L('File "%s" already exists! $nl$Replace?'), [SaveDialog1.FileName]), L('Warning'),
        TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
        Exit;

    EdName.Text := SaveDialog1.FileName;
  end;
end;

procedure TExportForm.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #8 then
    if not Working then
      EdName.Text := '';
end;

procedure TExportForm.SetRecordText(Value: string);
begin
  Label2.Caption := Value;
end;

procedure TExportForm.Edit1Change(Sender: TObject);
begin
  BtnStart.Enabled := EdName.Text <> '';
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

procedure TExportForm.DoFormExit(Sender: TObject);
begin
  Working := False;
  Close;
end;

procedure TExportForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Release;
end;

procedure TExportForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if Working then
    CanClose := False;
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
    CbCrypted.Caption := L('Export encrypted items');
    CbCryptedPass.Caption := L('Export encrypted items if password has been found');
    BtnStart.Caption := L('Begin export');
    BtnBreak.Caption := L('Break!');
    Label1.Caption := L('Item') + ':';
    Label2.Caption := L('[no records]');
    PbMain.text := L('Executing... (&%%)');
    EdName.WatermarkText := L('Please select a file');
  finally
    EndTranslate;
  end;
end;

procedure TExportForm.CbCryptedClick(Sender: TObject);
begin
  CbCryptedPass.Enabled := CbCrypted.Checked;
end;

procedure TExportForm.BtnBreakClick(Sender: TObject);
begin
  UnitExportThread.StopExport := True;
end;

end.
