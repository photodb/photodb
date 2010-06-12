object FormManager: TFormManager
  Left = 248
  Top = 180
  Width = 237
  Height = 180
  Caption = 'FormManager'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object TerminateTimer: TTimer
    Enabled = False
    Interval = 10000
    OnTimer = TerminateTimerTimer
    Left = 8
    Top = 8
  end
  object CalledTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = CalledTimerTimer
    Left = 40
    Top = 8
  end
  object ApplicationEvents1: TApplicationEvents
    OnException = ApplicationEvents1Exception
    OnIdle = ApplicationEvents1Idle
    Left = 72
    Top = 8
  end
  object CheckTimer: TTimer
    OnTimer = CheckTimerTimer
    Left = 104
    Top = 8
  end
  object TimerCloseApplicationByDBTerminate: TTimer
    Enabled = False
    OnTimer = TimerCloseApplicationByDBTerminateTimer
    Left = 8
    Top = 104
  end
end
