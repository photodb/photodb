unit Unit1;

interface

uses
  math, win32crc, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, jpeg, ExtCtrls, XPMan, shellapi, uSysUtils,
  uActivationUtils, UnitDBCommon, TwButton;

type
  TManualActivation = class(TForm)
    EdProgramCode: TEdit;
    BtnGenerate: TButton;
    EdActivationCode: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    EdUserName: TEdit;
    TwbFullVersion: TTwButton;
    procedure BtnGenerateClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure SelfCheck;
    procedure WMMouseDown(var S: Tmessage); message WM_LBUTTONDOWN;
  public
    { Public declarations }
  end;

var
  ManualActivation: TManualActivation;

implementation

{$R *.dfm}

procedure TManualActivation.BtnGenerateClick(Sender: TObject);
var
  I: Integer;
  Hs, Cs, Csold: string;
  N: Cardinal;
  B: Boolean;

  procedure CheckVersion(VersionCode: Integer; VersionText: string);
  begin
    I := HexToIntDef(Cs, 0) xor VersionCode;
    Csold := IntToHex(I, 8);
    if Copy(Csold, 1, 8) = 'FFFFFFFF' then
      Delete(Csold, 1, 8);
    if (Csold = Hs) and not B then
    begin
      Cs := Csold;
      Label2.Caption := VersionText;
      B := True;
    end;
  end;

begin
  Hs := Copy(EdProgramCode.Text, 1, 8);
  Cs := Copy(EdProgramCode.Text, 9, 8);
  CalcStringCRC32(Hs, N);
  Hs := Inttohex(N, 8);

  if Cs <> Hs then
  begin
    B := False;
    Csold := IntToHex(HexToIntDef(Cs, 0) xor $4D69F789, 8);
    if (Csold = Hs) and not B then
    begin
      Cs := Csold;
      Label2.Caption := 'Activation Key (v1.9)';
      B := True;
    end;

    CheckVersion($E445CF12, 'Activation Key (v2.0)');
    CheckVersion($56C987F3, 'Activation Key (v2.1)');
    CheckVersion($762C90CA, 'Activation Key (v2.2)');
    CheckVersion($162C90CA, 'Activation Key (v2.3)');

    if not B then
    begin
      Application.MessageBox('Code is not valid!', 'Warning', MB_OK + MB_ICONHAND);
      EdProgramCode.SetFocus;
      Exit;
    end
  end else
  begin
    Label2.Caption := 'Activation Key (v1.8 or smaller)';
  end;

  EdActivationCode.Text := GenerateActivationKey(EdProgramCode.Text, TwbFullVersion.Pushed);
end;

procedure TManualActivation.WMMouseDown(var s: Tmessage);
begin
  Perform(WM_NCLBUTTONDOWN, HTCaption, S.Lparam);
end;

procedure TManualActivation.FormCreate(Sender: TObject);
begin
  SelfCheck;
  EdProgramCode.Text := TActivationManager.Instance.ApplicationCode;
  EdUserName.Text := TActivationManager.Instance.ActivationUserName;
end;

procedure TManualActivation.SelfCheck;
var
  I: Integer;
  HString, PCode, ACode: string;
  Full, Demo: Boolean;
begin
  for I := -10000 to 10000 do
  begin
    HString := IntToStr(I);
    PCode := TActivationManager.Instance.GenerateProgramCode(HString);

    ACode := GenerateActivationKey(PCode, Odd(I));

    if I < 0 then
      ACode := IntToStr(I);

    TActivationManager.Instance.CheckActivationCode(PCode, ACode, Demo, Full);

    if (I < 0) xor Demo then
      raise Exception.Create('Demo move system check fail' + IntToStr(I));

    if ((I > 0) and (Odd(I) <> Full)) or ((I < 0) and Full) or (Demo and Full) then
      raise Exception.Create('Full mode check fail' + IntToStr(I));
  end;
end;

end.
