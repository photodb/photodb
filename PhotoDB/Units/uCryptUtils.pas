unit uCryptUtils;

interface

uses
  Windows, Classes, SysUtils, DECUtil, DECCipher, uStrongCrypt, uStringUtils, Menus,
  uActivationUtils, uSettings, uMemory, uDBForm, WebLink;

type
  TPasswordSettingsDBForm = class(TDBForm)
  private
    IsChiperSelected: Boolean;
    SelectedChiper: Integer;
  public
    function GetPopupMenu: TPopupMenu; virtual; abstract;
    function GetPaswordLink: TWebLink; virtual; abstract;
    procedure FillChiperList;
    procedure OnChiperSelected(Sender: TObject);
    procedure WblMethodClick(Sender: TObject);
  end;

implementation

procedure TPasswordSettingsDBForm.FillChiperList;

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
    FSelectedChiper,
    ChiperLength: Integer;
    ChiperAvaliable: Boolean;
    SettingsForm: TPasswordSettingsDBForm;
  begin
    Result := False;
    SettingsForm := TPasswordSettingsDBForm(Data);
    MenuItem := TMenuItem.Create(SettingsForm.GetPopupMenu);
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
          MenuItem.OnClick := SettingsForm.OnChiperSelected;
          if not ChiperAvaliable then
            MenuItem.Enabled := False;

          SettingsForm.GetPopupMenu.Items.Add(MenuItem);
        end;
        if (ChiperAvaliable and (not SettingsForm.IsChiperSelected or (Integer(ClassType.Identity) = SettingsForm.SelectedChiper))) then
        begin
          MenuItem.Click;
          SettingsForm.IsChiperSelected := True;
        end;
      finally
        F(Chiper);
      end;

    end;
  end;
begin
  GetPaswordLink.PopupMenu := GetPopupMenu;
  GetPaswordLink.OnClick := WblMethodClick;
  IsChiperSelected := False;
  StrongCryptInit;
  SelectedChiper := Settings.ReadInteger('Options', 'DefaultCryptClass', Integer(TCipher_Blowfish.Identity));

  DECEnumClasses(@DoEnumClasses, Self);
end;

procedure TPasswordSettingsDBForm.OnChiperSelected(Sender: TObject);
begin
  TMenuItem(Sender).Default := True;
  GetPaswordLink.Text := StringReplace(TMenuItem(Sender).Caption, '&', '', [rfReplaceAll]);
  GetPaswordLink.Tag := TMenuItem(Sender).Tag;

  Settings.WriteInteger('Options', 'DefaultCryptClass', TMenuItem(Sender).Tag);
  SetDefaultCipherClass(CipherByIdentity(TMenuItem(Sender).Tag));
end;

procedure TPasswordSettingsDBForm.WblMethodClick(Sender: TObject);
var
  P : TPoint;
begin
  GetCursorPos(P);
  GetPopupMenu.Popup(P.X, P.Y);
end;

end.
