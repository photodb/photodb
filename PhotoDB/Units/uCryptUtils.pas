unit uCryptUtils;

interface

uses
  Windows, Classes, SysUtils, DECUtil, DECCipher, uStrongCrypt, uStringUtils, Menus,
  uActivationUtils, uSettings, uMemory, uDBForm, WebLink;

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
  public
    constructor Create(WebLink: TWebLink; PopupMenu: TPopupMenu);
  end;

  TPasswordSettingsDBForm = class(TDBForm)
  private
    FMethodChanger: TPasswordMethodChanger;
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    function GetPasswordSettingsPopupMenu: TPopupMenu; virtual; abstract;
    function GetPaswordLink: TWebLink; virtual; abstract;
  end;

implementation

constructor TPasswordSettingsDBForm.Create(AOwner: TComponent);
begin
  inherited;
  FMethodChanger := TPasswordMethodChanger.Create(GetPaswordLink, GetPasswordSettingsPopupMenu);
end;

destructor TPasswordSettingsDBForm.Destroy;
begin
  F(FMethodChanger);
  inherited;
end;

{ TPasswordMethodChanger }

constructor TPasswordMethodChanger.Create(WebLink: TWebLink;
  PopupMenu: TPopupMenu);
begin
  FWebLink := WebLink;
  FPopupMenu := PopupMenu;
  FillChiperList;
end;

procedure TPasswordMethodChanger.FillChiperList;

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

begin
  FWebLink.PopupMenu := FPopupMenu;
  FWebLink.OnClick := WblMethodClick;
  FIsChiperSelected := False;
  StrongCryptInit;
  FSelectedChiper := Settings.ReadInteger('Options', 'DefaultCryptClass', Integer(TCipher_Blowfish.Identity));

  DECEnumClasses(@DoEnumClasses, Self);
end;

procedure TPasswordMethodChanger.OnChiperSelected(Sender: TObject);
begin
  TMenuItem(Sender).Default := True;
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
