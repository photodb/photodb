object DirectShowForm: TDirectShowForm
  Left = 328
  Top = 341
  BorderStyle = bsNone
  Caption = 'DirectX SlideShow'
  ClientHeight = 647
  ClientWidth = 869
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  WindowState = wsMaximized
  OnClick = FormClick
  OnClose = FormClose
  OnContextPopup = FormContextPopup
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnDeactivate = FormDeactivate
  OnMouseDown = FormMouseDown
  OnMouseMove = FormMouseMove
  OnMouseUp = FormMouseUp
  OnPaint = FormPaint
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object MouseTimer: TTimer
    Interval = 2000
    OnTimer = MouseTimerTimer
    Left = 8
    Top = 8
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 40
    Top = 8
  end
  object DelayTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = DelayTimerTimer
    Left = 8
    Top = 80
  end
  object FadeTimer: TTimer
    Enabled = False
    Interval = 10
    OnTimer = FadeTimerTimer
    Left = 40
    Top = 80
  end
end
