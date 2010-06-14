unit PrinterProgress;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DmProgress, Language;

type
  TFormPrinterProgress = class(TForm)
    DmProgress1: TDmProgress;
    Image1: TImage;
    Button1: TButton;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  protected
  procedure CreateParams(VAR Params: TCreateParams); override;
    { Private declarations }
  public
  PValue : PBoolean;
  FCanClose : boolean;
  procedure SetMaxValue(Value : integer);
  procedure SetValue(Value : integer);
  procedure SetText(Text : String);
  procedure SetLanguage;
    { Public declarations }
  end;

function GetFormPrinterProgress : TFormPrinterProgress;

implementation

{$R *.dfm}

procedure del_close_btn(handle:Thandle);
var
  hMenuHandle : HMENU;
begin
 if (Handle <> 0) then
 begin
  hMenuHandle := GetSystemMenu(Handle, FALSE);
  if (hMenuHandle <> 0) then
  DeleteMenu(hMenuHandle, SC_CLOSE, MF_BYCOMMAND);
 end;
end;

function GetFormPrinterProgress : TFormPrinterProgress;
begin
  Application.CreateForm(TFormPrinterProgress, Result);
end;

procedure TFormPrinterProgress.FormCreate(Sender: TObject);
begin
 icon:=Image1.Picture.Icon;
 SetLanguage;
 del_close_btn(Handle);
 FCanClose:=false;
end;

procedure TFormPrinterProgress.SetMaxValue(Value: integer);
begin
 DmProgress1.MaxValue:=Value;
end;

procedure TFormPrinterProgress.SetText(Text: String);
begin
 DmProgress1.Text:=Text;
end;

procedure TFormPrinterProgress.SetValue(Value: integer);
begin
 DmProgress1.Position:=Value;
end;

procedure TFormPrinterProgress.Button1Click(Sender: TObject);
begin
 Button1.Enabled:=false;
 PValue^:=True;
end;

procedure TFormPrinterProgress.SetLanguage;
begin
 Button1.Caption:=TEXT_MES_ABORT;
 Caption:=TEXT_MES_PRINTING;
 Label1.Caption:=TEXT_MES_WAIT_UNTIL_PRINTING;
end;

procedure TFormPrinterProgress.CreateParams(var Params: TCreateParams);
begin
  Inherited CreateParams(Params);
  Params.WndParent := GetDesktopWindow;
  with params do
  ExStyle := ExStyle or WS_EX_APPWINDOW;
end;

procedure TFormPrinterProgress.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
 CanClose:=FCanClose;
end;

end.
