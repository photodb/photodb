object CMDForm: TCMDForm
  Left = 362
  Top = 379
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = 'CMDForm'
  ClientHeight = 352
  ClientWidth = 470
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
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 179
    Height = 13
    Caption = 'Please, waiting until program wirking...'
  end
  object InfoListBox: TListBox
    Left = 8
    Top = 24
    Width = 457
    Height = 321
    Style = lbOwnerDrawVariable
    ItemHeight = 13
    TabOrder = 0
    OnDrawItem = InfoListBoxDrawItem
    OnMeasureItem = InfoListBoxMeasureItem
  end
  object TempProgress: TDmProgress
    Left = 328
    Top = 48
    Width = 100
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
    Visible = False
    Inverse = False
  end
  object Timer1: TTimer
    Interval = 300
    OnTimer = Timer1Timer
    Left = 216
    Top = 8
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 248
    Top = 8
  end
  object PasswordTimer: TTimer
    Interval = 100
    OnTimer = PasswordTimerTimer
    Left = 272
    Top = 192
  end
end
