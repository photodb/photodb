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
  object Button1: TButton
    Left = 296
    Top = 8
    Width = 17
    Height = 19
    Caption = '...'
    TabOrder = 0
    OnClick = Button1Click
  end
  object CbPrivate: TCheckBox
    Left = 8
    Top = 32
    Width = 305
    Height = 17
    Caption = 'Export Private Records'
    TabOrder = 1
  end
  object CbRating: TCheckBox
    Left = 8
    Top = 48
    Width = 305
    Height = 17
    Caption = 'Export Only Rating Records'
    TabOrder = 2
  end
  object CbWithoutFiles: TCheckBox
    Left = 8
    Top = 64
    Width = 305
    Height = 17
    Caption = 'Export Records Without Files'
    TabOrder = 3
  end
  object PbMain: TDmProgress
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
  object BtnStart: TButton
    Left = 208
    Top = 184
    Width = 107
    Height = 17
    Caption = 'Begin Export'
    TabOrder = 5
    OnClick = BtnStartClick
  end
  object CbGroups: TCheckBox
    Left = 8
    Top = 80
    Width = 305
    Height = 17
    Caption = 'Export Groups'
    TabOrder = 6
  end
  object CbCrypted: TCheckBox
    Left = 7
    Top = 96
    Width = 305
    Height = 17
    Caption = 'Export Crypted'
    TabOrder = 7
    OnClick = CbCryptedClick
  end
  object CbCryptedPass: TCheckBox
    Left = 7
    Top = 112
    Width = 305
    Height = 17
    Caption = 'Export crypted if password exists'
    Enabled = False
    TabOrder = 8
  end
  object BtnBreak: TButton
    Left = 96
    Top = 184
    Width = 105
    Height = 17
    Caption = 'Break'
    Enabled = False
    TabOrder = 9
    OnClick = BtnBreakClick
  end
  object EdName: TWatermarkedEdit
    Left = 8
    Top = 8
    Width = 289
    Height = 21
    TabOrder = 10
    WatermarkText = 'Please select a file'
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
    Left = 224
    Top = 96
  end
end
