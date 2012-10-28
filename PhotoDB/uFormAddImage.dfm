object FormAddingImage: TFormAddingImage
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'Please wait...'
  ClientHeight = 66
  ClientWidth = 484
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -33
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 40
  object LbMessage: TLabel
    Left = 63
    Top = 12
    Width = 297
    Height = 42
    AutoSize = False
    Caption = 'Please wait...'
    Transparent = True
    Visible = False
    WordWrap = True
  end
  object LsMain: TLoadingSign
    Left = 8
    Top = 8
    Width = 49
    Height = 49
    Visible = False
    Active = True
    FillPercent = 70
    SignColor = clBlack
    MaxTransparencity = 255
  end
  object TmrRedraw: TTimer
    Interval = 50
    OnTimer = TmrRedrawTimer
    Left = 384
    Top = 16
  end
  object TmrCheck: TTimer
    Enabled = False
    OnTimer = TmrCheckTimer
    Left = 440
    Top = 16
  end
end
