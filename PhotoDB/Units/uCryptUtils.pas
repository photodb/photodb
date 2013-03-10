unit uCryptUtils;

interface

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  Vcl.Menus,

  DECUtil,
  DECCipher,

  Dmitry.Controls.WebLink,

  uStrongCrypt,
  uActivationUtils,
  uSettings,
  uMemory,
  uThreadForm,
  uVCLHelpers,
  uTranslate,
  uFormInterfaces;

type
  TPasswordMethodChanger = class(TObject)
  private
    FIsChiperSelected: Boolean;
    FSelectedChiper: Integer;
    FWebLink: TWebLink;
    FPopupMenu: TPopupMenu;
    procedure FillChiperList;
    procedure OnChiperSelected(Sender: TObject);
    procedure WblMethodClick(Sender: TObject);
    procedure ActivationClick(Sender: TObject);
  public
    constructor Create(WebLink: TWebLink; PopupMenu: TPopupMenu);
  end;

  TPasswordSettingsDBForm = class(TThreadForm)
  private
    FMethodChanger: TPasswordMethodChanger;
  protected
    function GetPasswordSettingsPopupMenu: TPopupMenu; virtual; abstract;
    function GetPaswordLink: TWebLink; virtual; abstract;
  public
    constructor Create(AOwner: TComponent); override;
    procedure AfterConstruction; override;
    destructor Destroy; override;
  end;

implementation

uses
  uActivation;

procedure TPasswordSettingsDBForm.AfterConstruction;
begin
  inherited;
  FMethodChanger := TPasswordMethodChanger.Create(GetPaswordLink, GetPasswordSettingsPopupMenu);
end;

constructor TPasswordSettingsDBForm.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor TPasswordSettingsDBForm.Destroy;
begin
  F(FMethodChanger);
  inherited;
end;

{ TPasswordMethodChanger }

procedure TPasswordMethodChanger.ActivationClick(Sender: TObject);
begin
  ActivationForm.Execute;
end;

constructor TPasswordMethodChanger.Create(WebLink: TWebLink; PopupMenu: TPopupMenu);
begin
  FWebLink := WebLink;
  FPopupMenu := PopupMenu;
  FillChiperList;
end;

function GetChipperName(Chiper : TDECCipher) : string;
var
  ChipperName : string;
begin
  ChipperName := StringReplace(Chiper.ClassType.ClassName, 'TCipher_', '', [rfReplaceAll]);
  Result := ChipperName + ' - ' + IntToStr(Chiper.Context.KeySize * Chiper.Context.BlockSize );
end;

function DoEnumClasses(Data: Pointer; ClassType: TDECClass): Boolean;
var
  MenuItem: TMenuItem;
  Chiper: TDECCipher;
  ChiperLength: Integer;
  ChiperAvaliable: Boolean;
  Owner: TPasswordMethodChanger;
begin
  Result := False;
  Owner := TPasswordMethodChanger(Data);
  MenuItem := TMenuItem.Create(Owner.FPopupMenu);
  if ClassType.InheritsFrom(TDECCipher) then
  begin
    Chiper := CipherByIdentity(ClassType.Identity).Create;
    try
      ChiperLength := Chiper.Context.KeySize * Chiper.Context.BlockSize;
      ChiperAvaliable := not ((ChiperLength > 128) and TActivationManager.Instance.IsDemoMode);
      if ChiperLength > 16 then
      begin
        MenuItem.Caption := GetChipperName(Chiper);
        MenuItem.Tag := Integer(Chiper.Identity);
        MenuItem.OnClick := Owner.OnChiperSelected;
        if not ChiperAvaliable then
          MenuItem.Enabled := False;

        Owner.FPopupMenu.Items.Add(MenuItem);
      end;
      if (ChiperAvaliable and (not Owner.FIsChiperSelected or (Integer(ClassType.Identity) = Owner.FSelectedChiper))) then
      begin
        MenuItem.Click;
        Owner.FIsChiperSelected := True;
      end;
    finally
      F(Chiper);
    end;
  end;
end;

procedure TPasswordMethodChanger.FillChiperList;
var
  MenuItem: TMenuItem;
begin
  FWebLink.PopupMenu := FPopupMenu;
  FWebLink.OnClick := WblMethodClick;
  FIsChiperSelected := False;
  StrongCryptInit;
  FSelectedChiper := Settings.ReadInteger('Options', 'DefaultCryptClass', Integer(TCipher_Blowfish.Identity));

  DECEnumClasses(@DoEnumClasses, Self);

  if TActivationManager.Instance.IsDemoMode then
  begin
    MenuItem := TMenuItem.Create(FPopupMenu);
    MenuItem.Caption := '-';
    FPopupMenu.Items.Add(MenuItem);

    MenuItem := TMenuItem.Create(FPopupMenu);
    MenuItem.Caption := TA('Activate application to enable strong encryption!', 'System');
    MenuItem.OnClick := ActivationClick;
    FPopupMenu.Items.Add(MenuItem);
  end;

end;

procedure TPasswordMethodChanger.OnChiperSelected(Sender: TObject);
begin
  TMenuItem(Sender).ExSetDefault(True);
  FWebLink.Text := StringReplace(TMenuItem(Sender).Caption, '&', '', [rfReplaceAll]);
  FWebLink.Tag := TMenuItem(Sender).Tag;

  Settings.WriteInteger('Options', 'DefaultCryptClass', TMenuItem(Sender).Tag);
  SetDefaultCipherClass(CipherByIdentity(Cardinal(TMenuItem(Sender).Tag)));
end;

procedure TPasswordMethodChanger.WblMethodClick(Sender: TObject);
var
  P: TPoint;
begin
  GetCursorPos(P);
  FPopupMenu.Popup(P.X, P.Y);
end;

end.
