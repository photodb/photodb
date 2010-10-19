unit UnitFormCDMapInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Dolphin_DB, UnitDBKernel, Language,
  UnitCDMappingSupport, uVistaFuncs;

type
  TFormCDMapInfo = class(TForm)
    Image1: TImage;
    LabelInfo: TLabel;
    Button1: TButton;
    LabelDisk: TLabel;
    EditCDName: TEdit;
    Button2: TButton;
    Button3: TButton;
    DestroyTimer: TTimer;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DestroyTimerTimer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
   fCDName : string;
   procedure LoadLanguage;
    { Private declarations }
  public
   function Execute(CDName : string) : integer;
    { Public declarations }
  end;

function CheckCD(CDName : string) : integer;

implementation

function CheckCD(CDName : string) : integer;
var
  FormCDMapInfo: TFormCDMapInfo;
begin
  Application.CreateForm(TFormCDMapInfo, FormCDMapInfo);
  Result:=FormCDMapInfo.Execute(CDName);
end;

{$R *.dfm}

function TFormCDMapInfo.Execute(CDName : string) : integer;
begin
 fCDName:=CDName;
 EditCDName.Text:=CDName; 
 LoadLanguage;
 ShowModal;
 Result:=0;
end;

procedure TFormCDMapInfo.LoadLanguage;
begin
 Caption:=TEXT_MES_CD_MAP_QUESTION_CAPTION;
 LabelInfo.Caption:=Format(TEXT_MES_CD_MAP_QUESTION_INFO_F,[fCDName]);
 Button3.Caption:=TEXT_MES_DONT_ASK_ME_AGAIN;
 Button2.Caption:=TEXT_MES_CD_DVD_SELECT;
 Button1.Caption:=TEXT_MES_CANCEL;
 LabelDisk.Caption:=TEXT_MES_DISK+':';
end;

procedure TFormCDMapInfo.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 DestroyTimer.Enabled:=true;
end;

procedure TFormCDMapInfo.DestroyTimerTimer(Sender: TObject);
begin
 DestroyTimer.Enabled:=false;
 Release;
end;

procedure TFormCDMapInfo.Button1Click(Sender: TObject);
begin
 Close;
end;

procedure TFormCDMapInfo.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 //ESC
 if Key = 27 then Close();
end;

procedure TFormCDMapInfo.Button2Click(Sender: TObject);
var
  CDLabel : string;
begin
 CDLabel:=AddCDLocation(fCDName);
 if CDLabel='' then exit;
 if AnsiLowerCase(CDLabel)<>AnsiLowerCase(EditCDName.Text) then
 begin
  if ID_YES=MessageBoxDB(Handle,Format(TEXT_MES_LOADED_DIFFERENT_DISK_F,[CDLabel,EditCDName.Text]),TEXT_MES_WARNING,TD_BUTTON_YESNO,TD_ICON_QUESTION) then
  begin
   Close;
  end else
  begin
   exit;
  end;
 end;
 Close;
end;

procedure TFormCDMapInfo.Button3Click(Sender: TObject);
begin
 CDMapper.SetCDWithNOQuestion(EditCDName.Text);
 Close;
end;

end.
