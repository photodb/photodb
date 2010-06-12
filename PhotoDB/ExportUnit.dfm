object ExportForm: TExportForm
  Left = 486
  Top = 310
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsToolWindow
  Caption = 'Export Table'
  ClientHeight = 207
  ClientWidth = 320
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 128
    Width = 46
    Height = 13
    Caption = 'Record:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 8
    Top = 144
    Width = 56
    Height = 13
    Caption = '[no records]'
  end
  object Edit1: TEdit
    Left = 8
    Top = 8
    Width = 288
    Height = 21
    ReadOnly = True
    TabOrder = 0
    Text = '<no file>'
    OnChange = Edit1Change
    OnKeyPress = Edit1KeyPress
  end
  object Button1: TButton
    Left = 296
    Top = 8
    Width = 17
    Height = 19
    Caption = '...'
    TabOrder = 1
    OnClick = Button1Click
  end
  object CheckBox1: TCheckBox
    Left = 8
    Top = 32
    Width = 305
    Height = 17
    Caption = 'Export Private Records'
    TabOrder = 2
  end
  object CheckBox2: TCheckBox
    Left = 8
    Top = 48
    Width = 305
    Height = 17
    Caption = 'Export Only Rating Records'
    TabOrder = 3
  end
  object CheckBox3: TCheckBox
    Left = 8
    Top = 64
    Width = 305
    Height = 17
    Caption = 'Export Records Without Files'
    TabOrder = 4
  end
  object DmProgress1: TDmProgress
    Left = 8
    Top = 160
    Width = 305
    Height = 18
    MaxValue = 100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 16711808
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Text = 'Progress... (&%%)'
    BorderColor = 38400
    CoolColor = 38400
    Color = clBlack
    View = dm_pr_cool
    Inverse = False
  end
  object Button2: TButton
    Left = 208
    Top = 184
    Width = 107
    Height = 17
    Caption = 'Begin Export'
    TabOrder = 6
    OnClick = Button2Click
  end
  object CheckBox4: TCheckBox
    Left = 8
    Top = 80
    Width = 305
    Height = 17
    Caption = 'Export Groups'
    TabOrder = 7
  end
  object CheckBox5: TCheckBox
    Left = 7
    Top = 96
    Width = 305
    Height = 17
    Caption = 'Export Crypted'
    TabOrder = 8
    OnClick = CheckBox5Click
  end
  object CheckBox6: TCheckBox
    Left = 7
    Top = 112
    Width = 305
    Height = 17
    Caption = 'Export crypted if password exists'
    Enabled = False
    TabOrder = 9
  end
  object Button3: TButton
    Left = 96
    Top = 184
    Width = 105
    Height = 17
    Caption = 'Break'
    Enabled = False
    TabOrder = 10
    OnClick = Button3Click
  end
  object SaveDialog1: TSaveDialog
    Filter = 'PhotoDB Files (*.photodb)|*.photodb'
    Left = 224
    Top = 48
  end
  object DestroyTimer: TTimer
    Enabled = False
    Interval = 1
    OnTimer = DestroyTimerTimer
    Left = 256
    Top = 48
  end
end
