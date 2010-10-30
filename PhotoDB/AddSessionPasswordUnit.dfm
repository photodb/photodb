object AddSessionPasswordForm: TAddSessionPasswordForm
  Left = 507
  Top = 446
  BorderStyle = bsToolWindow
  Caption = 'AddSessionPasswordForm'
  ClientHeight = 169
  ClientWidth = 300
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object LbInfoPassword: TLabel
    Left = 8
    Top = 8
    Width = 146
    Height = 13
    Caption = 'Enter password for image here:'
  end
  object LbPasswordConfirm: TLabel
    Left = 8
    Top = 62
    Width = 160
    Height = 13
    Caption = 'ReEnter password for image here:'
  end
  object BtnCancel: TButton
    Left = 140
    Top = 138
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = BtnCancelClick
  end
  object BtnOk: TButton
    Left = 220
    Top = 138
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 4
    OnClick = BtnOkClick
  end
  object EdPassword: TWatermarkedEdit
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
    WatermarkText = 'Enter password here'
  end
  object EdPasswordConfirm: TWatermarkedEdit
    Left = 8
    Top = 75
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
    WatermarkText = 'Password confirm'
  end
  object CbShowPassword: TCheckBox
    Left = 8
    Top = 110
    Width = 281
    Height = 17
    Caption = 'Show password'
    TabOrder = 2
    OnClick = CbShowPasswordClick
  end
end
