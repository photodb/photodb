object CryptImageForm: TCryptImageForm
  Left = 646
  Top = 352
  BorderIcons = [biSystemMenu, biMaximize]
  BorderStyle = bsToolWindow
  Caption = 'CryptImageForm'
  ClientHeight = 202
  ClientWidth = 295
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
    Left = 136
    Top = 174
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 6
    OnClick = BtCancelClick
  end
  object BtOk: TButton
    Left = 216
    Top = 174
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 7
    OnClick = BtOkClick
  end
  object CbSaveCRC: TCheckBox
    Left = 8
    Top = 120
    Width = 281
    Height = 17
    Caption = 'Save CRC for file'
    Enabled = False
    TabOrder = 3
  end
  object CbSavePasswordForSession: TCheckBox
    Left = 8
    Top = 136
    Width = 281
    Height = 17
    Caption = 'Save Password for all session'
    Checked = True
    State = cbChecked
    TabOrder = 4
  end
  object CbSavePasswordPermanent: TCheckBox
    Left = 8
    Top = 152
    Width = 281
    Height = 17
    Caption = 'Save Password for in settings (NOT recommend)'
    TabOrder = 5
  end
  object EdPassword: TEdit
    Left = 8
    Top = 24
    Width = 281
    Height = 32
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    PasswordChar = '*'
    TabOrder = 0
    OnKeyPress = EdPasswordKeyPress
  end
  object EdPasswordConfirm: TEdit
    Left = 8
    Top = 72
    Width = 281
    Height = 32
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    PasswordChar = '*'
    TabOrder = 1
    OnKeyPress = EdPasswordKeyPress
  end
  object CbShowPassword: TCheckBox
    Left = 8
    Top = 104
    Width = 281
    Height = 17
    Caption = 'Show password'
    TabOrder = 2
    OnClick = CbShowPasswordClick
  end
end
