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
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 146
    Height = 13
    Caption = 'Enter password for image here:'
  end
  object Label2: TLabel
    Left = 8
    Top = 56
    Width = 160
    Height = 13
    Caption = 'ReEnter password for image here:'
  end
  object Button1: TButton
    Left = 136
    Top = 174
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 6
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 216
    Top = 174
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 7
    OnClick = Button2Click
  end
  object CheckBox2: TCheckBox
    Left = 8
    Top = 120
    Width = 281
    Height = 17
    Caption = 'Save CRC for file'
    Enabled = False
    TabOrder = 3
  end
  object CheckBox3: TCheckBox
    Left = 8
    Top = 136
    Width = 281
    Height = 17
    Caption = 'Save Password for all session'
    Checked = True
    State = cbChecked
    TabOrder = 4
  end
  object CheckBox4: TCheckBox
    Left = 8
    Top = 152
    Width = 281
    Height = 17
    Caption = 'Save Password for in settings (NOT recommend)'
    TabOrder = 5
  end
  object Edit1: TEdit
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
    OnKeyPress = Edit1KeyPress
  end
  object Edit2: TEdit
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
    OnKeyPress = Edit1KeyPress
  end
  object CheckBox6: TCheckBox
    Left = 8
    Top = 104
    Width = 281
    Height = 17
    Caption = 'Show password'
    TabOrder = 2
    OnClick = CheckBox6Click
  end
end
