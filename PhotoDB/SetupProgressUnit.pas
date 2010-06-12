unit SetupProgressUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DmProgress, StdCtrls, uVistaFuncs, Dolphin_DB;

type
  TSetupProgressForm = class(TForm)
    DmProgress1: TDmProgress;
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
  Procedure Done(Sender : TObject);
    { Public declarations }
  end;

var
  SetupProgressForm: TSetupProgressForm;
  FPause : PBoolean;
  fInstallDone : PBoolean;

implementation

uses Language, UnitInstallThread, UnitUnInstallThread;

{$R *.dfm}

{ TSetupProgressForm }

procedure TSetupProgressForm.Done(Sender: TObject);
begin
//
end;

procedure TSetupProgressForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 Button1Click(Sender);
//
end;

procedure TSetupProgressForm.Button1Click(Sender: TObject);
begin
 if fInstallDone^ then exit;
 FPause^:=true;
 If ID_OK=MessageBoxDB(Handle,TEXT_MES_SETUP_EXIT,TEXT_MES_SETUP,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then
 begin
  OnClose:=nil;
  OnCloseQuery:=nil;
  Close;
  UnitInstallThread.terminate_:=true;
  UnitInstallThread.InstallDone:=true;
 end else
 FPause^:=false;
end;

procedure TSetupProgressForm.FormCreate(Sender: TObject);
begin
 Button1.Caption:=TEXT_MES_EXIS_SETUP;
 Caption := TEXT_MES_INSTALL_CAPTION;
 Label1.Caption := TEXT_MES_CURRENT_ACTION;
end;

procedure TSetupProgressForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
 UnitInstallThread.pause:=True;
 UnitUnInstallThread.pause:=True;
 If ID_OK=MessageBoxDB(Handle,TEXT_MES_SETUP_EXIT,TEXT_MES_SETUP,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then
 begin
  CanClose:=false;
  if UnitInstallThread.terminate_ then Close;
  UnitInstallThread.terminate_:=true;
 end else
 begin
  CanClose:=false;
 end;
end;

end.
