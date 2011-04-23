object ImportProgressForm: TImportProgressForm
  Left = 210
  Top = 193
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Importing database'
  ClientHeight = 154
  ClientWidth = 354
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    354
    154)
  PixelsPerInch = 96
  TextHeight = 13
  object Label13: TLabel
    Left = 8
    Top = 43
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
    Left = 9
    Top = 62
    Width = 153
    Height = 33
    Anchors = [akLeft, akTop, akBottom]
    AutoSize = False
    Caption = '<Action>'
    WordWrap = True
    ExplicitHeight = 32
  end
  object Label14: TLabel
    Left = 8
    Top = 8
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
    Top = 24
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
  object PbMain: TDmProgress
    Left = 6
    Top = 101
    Width = 338
    Height = 18
    Anchors = [akLeft, akRight, akBottom]
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
    ExplicitTop = 100
  end
  object BtnStop: TButton
    Left = 271
    Top = 125
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = 'Stop!'
    TabOrder = 1
    OnClick = BtnStopClick
    ExplicitTop = 124
  end
  object BtnPause: TButton
    Left = 191
    Top = 125
    Width = 73
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = 'Pause'
    TabOrder = 2
    OnClick = BtnPauseClick
    ExplicitTop = 124
  end
  object PbItemsAdded: TDmProgress
    Left = 168
    Top = 24
    Width = 178
    Height = 18
    Anchors = [akLeft, akTop, akRight]
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
    ExplicitWidth = 129
  end
  object PbItemsUpdated: TDmProgress
    Left = 168
    Top = 64
    Width = 178
    Height = 18
    Anchors = [akLeft, akTop, akRight]
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
    ExplicitWidth = 129
  end
end
