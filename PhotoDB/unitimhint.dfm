object ImHint: TImHint
  Left = 192
  Top = 134
  BorderStyle = bsNone
  Caption = 'ImHint'
  ClientHeight = 197
  ClientWidth = 211
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClick = FormClick
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnContextPopup = Image1ContextPopup
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnDeactivate = FormDeactivate
  OnKeyPress = FormKeyPress
  OnMouseDown = Image1MouseDown
  OnMouseMove = LbSizeMouseMove
  PixelsPerInch = 96
  TextHeight = 13
  object TimerShow: TTimer
    Enabled = False
    Interval = 25
    OnTimer = TimerShowTimer
    Left = 8
    Top = 8
  end
  object TimerHide: TTimer
    Enabled = False
    Interval = 25
    OnTimer = TimerHideTimer
    Left = 40
    Top = 8
  end
  object TimerHintCheck: TTimer
    Interval = 50
    OnTimer = TimerHintCheckTimer
    Left = 72
    Top = 8
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 104
    Top = 8
  end
  object DropFileSourceMain: TDropFileSource
    DragTypes = [dtCopy]
    Images = DragImageList
    ShowImage = True
    Left = 72
    Top = 72
  end
  object DragImageList: TImageList
    ColorDepth = cd32Bit
    DrawingStyle = dsTransparent
    Left = 40
    Top = 72
  end
  object DropFileTargetMain: TDropFileTarget
    DragTypes = []
    AutoRegister = False
    OptimizedMove = True
    Left = 104
    Top = 72
  end
  object ImageFrameTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = ImageFrameTimerTimer
    Left = 8
    Top = 72
  end
end
