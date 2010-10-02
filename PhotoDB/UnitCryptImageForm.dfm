object CryptImageForm: TCryptImageForm
  Left = 646
  Top = 352
  BorderIcons = [biSystemMenu, biMaximize]
  BorderStyle = bsToolWindow
  Caption = 'CryptImageForm'
  ClientHeight = 202
  ClientWidth = 324
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  DesignSize = (
    324
    202)
  PixelsPerInch = 96
  TextHeight = 13
  object LbPassword: TLabel
    Left = 8
    Top = 8
    Width = 146
    Height = 13
    Caption = 'Enter password for image here:'
  end
  object LbPasswordConfirm: TLabel
    Left = 8
    Top = 56
    Width = 160
    Height = 13
    Caption = 'ReEnter password for image here:'
  end
  object BtCancel: TButton
    Left = 165
    Top = 174
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Cancel'
    TabOrder = 6
    OnClick = BtCancelClick
  end
  object BtOk: TButton
    Left = 245
    Top = 174
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Ok'
    TabOrder = 7
    OnClick = BtOkClick
  end
  object CbSaveCRC: TCheckBox
    Left = 8
    Top = 120
    Width = 310
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Save CRC for file'
    Enabled = False
    TabOrder = 3
  end
  object CbSavePasswordForSession: TCheckBox
    Left = 8
    Top = 136
    Width = 310
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Save Password for all session'
    Checked = True
    State = cbChecked
    TabOrder = 4
  end
  object CbSavePasswordPermanent: TCheckBox
    Left = 8
    Top = 152
    Width = 310
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Save Password for in settings (NOT recommend)'
    TabOrder = 5
  end
  object EdPassword: TWatermarkedEdit
    Left = 8
    Top = 24
    Width = 310
    Height = 32
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    PasswordChar = '*'
    TabOrder = 0
    OnKeyPress = EdPasswordKeyPress
    WatermarkText = 'Password'
  end
  object EdPasswordConfirm: TWatermarkedEdit
    Left = 8
    Top = 72
    Width = 310
    Height = 32
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    PasswordChar = '*'
    TabOrder = 1
    OnKeyPress = EdPasswordKeyPress
    WatermarkText = 'Password confirm'
  end
  object CbShowPassword: TCheckBox
    Left = 8
    Top = 104
    Width = 310
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Show password'
    TabOrder = 2
    OnClick = CbShowPasswordClick
  end
  object WblMethod: TWebLink
    Left = 8
    Top = 178
    Width = 84
    Height = 16
    Cursor = crHandPoint
    PopupMenu = PmCryptMethod
    Text = 'BlowFish - 56'
    OnClick = WblMethodClick
    ImageIndex = 0
    IconWidth = 16
    IconHeight = 16
    UseEnterColor = False
    EnterColor = clBlack
    EnterBould = True
    TopIconIncrement = 0
    ImageCanRegenerate = True
    UseSpecIconSize = True
  end
  object PmCryptMethod: TPopupMenu
    Left = 112
    Top = 168
  end
end
