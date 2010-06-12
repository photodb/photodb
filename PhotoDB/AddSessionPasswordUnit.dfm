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
  OnCreate = FormCreate
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
    Left = 140
    Top = 138
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 220
    Top = 138
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 4
    OnClick = Button2Click
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
