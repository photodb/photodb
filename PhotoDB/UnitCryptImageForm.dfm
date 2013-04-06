object CryptImageForm: TCryptImageForm
  Left = 646
  Top = 352
  BorderIcons = [biSystemMenu, biMaximize]
  BorderStyle = bsToolWindow
  Caption = 'CryptImageForm'
  ClientHeight = 189
  ClientWidth = 324
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  DesignSize = (
    324
    189)
  PixelsPerInch = 96
  TextHeight = 13
  object LbPassword: TLabel
    Left = 8
    Top = 8
    Width = 152
    Height = 13
    Caption = 'Enter password for image here:'
  end
  object LbPasswordConfirm: TLabel
    Left = 8
    Top = 56
    Width = 165
    Height = 13
    Caption = 'ReEnter password for image here:'
  end
  object BtCancel: TButton
    Left = 164
    Top = 159
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Cancel'
    TabOrder = 5
    OnClick = BtCancelClick
  end
  object BtOk: TButton
    Left = 245
    Top = 159
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Ok'
    TabOrder = 7
    OnClick = BtOkClick
  end
  object CbSavePasswordForSession: TCheckBox
    Left = 8
    Top = 120
    Width = 310
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Save Password for all session'
    Checked = True
    State = cbChecked
    TabOrder = 3
  end
  object CbSavePasswordPermanent: TCheckBox
    Left = 8
    Top = 136
    Width = 310
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Save Password for in settings (NOT recommend)'
    TabOrder = 4
  end
  object EdPassword: TWatermarkedEdit
    Left = 8
    Top = 24
    Width = 310
    Height = 31
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
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
    Height = 31
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
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
    Top = 168
    Width = 84
    Height = 16
    Cursor = crHandPoint
    Text = 'BlowFish - 56'
    ImageIndex = 0
    UseEnterColor = False
    EnterColor = clBlack
    EnterBould = False
    TopIconIncrement = 0
    UseSpecIconSize = True
    HightliteImage = False
    StretchImage = True
    CanClick = True
  end
  object PmCryptMethod: TPopupActionBar
    Left = 272
    Top = 8
  end
end
