object ImportProgressForm: TImportProgressForm
  Left = 210
  Top = 193
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Importing database'
  ClientHeight = 134
  ClientWidth = 305
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label13: TLabel
    Left = 8
    Top = 56
    Width = 86
    Height = 13
    Caption = 'Current Action:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object ActionLabel: TLabel
    Left = 8
    Top = 72
    Width = 153
    Height = 13
    AutoSize = False
    Caption = '<Action>'
  end
  object Label14: TLabel
    Left = 8
    Top = 24
    Width = 41
    Height = 13
    Caption = 'Status:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object StatusLabel: TLabel
    Left = 8
    Top = 40
    Width = 42
    Height = 13
    Caption = '<Status>'
  end
  object Label1: TLabel
    Left = 168
    Top = 8
    Width = 92
    Height = 13
    Caption = 'Records Added:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 168
    Top = 48
    Width = 104
    Height = 13
    Caption = 'Records Updated:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 8
    Top = 8
    Width = 33
    Height = 13
    Caption = 'Status:'
  end
  object DmProgress1: TDmProgress
    Left = 8
    Top = 88
    Width = 289
    Height = 18
    Position = 57
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
  object Button1: TButton
    Left = 224
    Top = 112
    Width = 75
    Height = 17
    Caption = 'Stop!'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 144
    Top = 112
    Width = 73
    Height = 17
    Caption = 'Pause'
    TabOrder = 2
    OnClick = Button2Click
  end
  object DmProgress2: TDmProgress
    Left = 168
    Top = 24
    Width = 129
    Height = 18
    Position = 34
    MaxValue = 100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 16711808
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Text = '&%% (Added)'
    BorderColor = 38400
    CoolColor = clPurple
    Color = clBlack
    View = dm_pr_cool
    Inverse = False
  end
  object DmProgress3: TDmProgress
    Left = 168
    Top = 64
    Width = 129
    Height = 18
    Position = 56
    MaxValue = 100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 16711808
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Text = '&%% (Updated)'
    BorderColor = 38400
    CoolColor = clTeal
    Color = clBlack
    View = dm_pr_cool
    Inverse = False
  end
end
