object BigImagesSizeForm: TBigImagesSizeForm
  Left = 192
  Top = 114
  BorderStyle = bsToolWindow
  Caption = 'BigImagesSizeForm'
  ClientHeight = 176
  ClientWidth = 158
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnDeactivate = FormDeactivate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object TrackBar1: TTrackBar
    Left = 0
    Top = 0
    Width = 45
    Height = 176
    Align = alLeft
    Max = 51
    Min = 1
    Orientation = trVertical
    Position = 1
    TabOrder = 0
    OnChange = TrackBar1Change
  end
  object Panel1: TPanel
    Left = 45
    Top = 0
    Width = 113
    Height = 176
    Align = alClient
    TabOrder = 1
    object RadioGroup1: TRadioGroup
      Left = 1
      Top = 1
      Width = 111
      Height = 144
      Align = alTop
      Caption = 'Big Images Size:'
      ItemIndex = 1
      Items.Strings = (
        '50x50'
        '100x100'
        '150x150'
        '200x200'
        '250x250'
        '300x300'
        'Other (215x215)')
      TabOrder = 0
      OnClick = RadioGroup1Click
    end
    object CloseLink: TWebLink
      Left = 40
      Top = 152
      Width = 47
      Height = 16
      Cursor = crHandPoint
      Text = 'Close'
      OnClick = CloseLinkClick
      BkColor = clWhite
      ImageIndex = 0
      IconWidth = 16
      IconHeight = 16
      UseEnterColor = False
      EnterColor = clBlack
      EnterBould = False
      TopIconIncrement = 0
      ImageCanRegenerate = True
    end
  end
  object TimerActivate: TTimer
    Interval = 200
    OnTimer = TimerActivateTimer
    Left = 32
    Top = 24
  end
end
