unit UnitFormLoginModeChooser;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Language, Dolphin_DB, JPEG, uVistaFuncs,
  UnitDBKernel;

type
  TFormLoginModeChooser = class(TForm)
    ButtonUseLogin: TButton;
    ButtonNOLoginMode: TButton;
    procedure ButtonNOLoginModeClick(Sender: TObject);
    procedure ButtonUseLoginClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
   NoUserMode : boolean;
    { Public declarations }
  end;

function DoSelectLoginMode : boolean;

implementation

function DoSelectLoginMode : boolean;
var
  FormLoginModeChooser: TFormLoginModeChooser;
begin
  Result:=false;
  Application.CreateForm(TFormLoginModeChooser, FormLoginModeChooser);
  FormLoginModeChooser.ShowModal;
  Result:=FormLoginModeChooser.NoUserMode;
  FormLoginModeChooser.Free;
end;

{$R *.dfm}

procedure TFormLoginModeChooser.ButtonNOLoginModeClick(Sender: TObject);
var
  Logo : TBitmap;
  Jpg : TJpegImage;
  r : TRect;
  LoginResult : integer;
Const
  DrawTextOpt = DT_NOPREFIX+DT_WORDBREAK+DT_CENTER+DT_VCENTER;
begin
 Logo:=TBitmap.Create;
 Logo.PixelFormat:=pf24Bit;
 Logo.Width:=48;
 Logo.Height:=48;
 Logo.Canvas.Brush.Color:=ClWhite;  
 Logo.Canvas.Pen.Color:=ClBlack;
 Logo.Canvas.Rectangle(0,0,48,48);
 Logo.Canvas.Pen.Color:=ClBlack;
 Logo.Canvas.Font.Color:=ClBlack;
 r:=Rect(5,10,40,48);
 DrawTextA(Logo.Canvas.Handle, PChar(TEXT_MES_NO_LOGO), Length(TEXT_MES_NO_LOGO), r , DrawTextOpt);
 Jpg:=TJpegImage.Create;
 Jpg.Assign(Logo);
 Logo.Free;               
 Jpg.CompressionQuality:=100;
 Jpg.ProgressiveEncoding:=false;
 Jpg.JPEGNeeded;
 LoginResult:=DBKernel.CreateNewUser(Language.TEXT_MES_ADMIN,'',Jpg);
 if LOG_IN_OK<>LoginResult then
 begin
  MessageBoxDB(Handle,Format(TEXT_MES_ERROR_CREATING_DEFAULT_USER_F,[LoginResult]),TEXT_MES_ERROR,uVistaFuncs.TD_BUTTON_OK,uVistaFuncs.TD_ICON_ERROR);
 end else
 begin
  NoUserMode:=true;
  Close;
 end;
 Jpg.Free;
end;

procedure TFormLoginModeChooser.ButtonUseLoginClick(Sender: TObject);
begin
 Close;
end;

procedure TFormLoginModeChooser.FormCreate(Sender: TObject);
begin
 NoUserMode:=false;
 Caption:=TEXT_MES_LOGIN_MODE_CAPTION;
 ButtonUseLogin.Caption:=TEXT_MES_LOGIN_MODE_USE_LOGIN;
 ButtonNOLoginMode.Caption:=TEXT_MES_LOGIN_MODE_NO_LOGIN;
end;

end.
