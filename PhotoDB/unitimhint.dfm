object ImHint: TImHint
  Left = 192
  Top = 134
  BorderStyle = bsNone
  Caption = 'ImHint'
  ClientHeight = 224
  ClientWidth = 153
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  OnClick = FormClick
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnHide = FormHide
  OnKeyPress = FormKeyPress
  OnMouseMove = Label2MouseMove
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 3
    Top = 3
    Width = 145
    Height = 161
    OnClick = FormClick
    OnContextPopup = Image1ContextPopup
    OnMouseDown = Image1MouseDown
    OnMouseMove = Label2MouseMove
  end
  object Label1: TLabel
    Left = 3
    Top = 176
    Width = 150
    Height = 17
    BiDiMode = bdLeftToRight
    Caption = 'Name or Comment'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBiDiMode = False
    ParentFont = False
    WordWrap = True
    OnMouseMove = Label2MouseMove
  end
  object Label2: TLabel
    Left = 3
    Top = 192
    Width = 71
    Height = 13
    Caption = 'Width x Height'
    OnMouseMove = Label2MouseMove
  end
  object Label3: TLabel
    Left = 3
    Top = 208
    Width = 44
    Height = 13
    Caption = 'Size label'
    OnMouseMove = Label2MouseMove
  end
  object PaintBox1: TPaintBox
    Left = 3
    Top = 3
    Width = 105
    Height = 105
    Visible = False
    OnClick = FormClick
    OnContextPopup = Image1ContextPopup
    OnMouseDown = Image1MouseDown
    OnMouseMove = Label2MouseMove
    OnPaint = PaintBox1Paint
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 25
    OnTimer = Timer1Timer
    Left = 8
    Top = 8
  end
  object Timer2: TTimer
    Enabled = False
    Interval = 25
    OnTimer = Timer2Timer
    Left = 40
    Top = 8
  end
  object Timer3: TTimer
    Interval = 50
    OnTimer = Timer3Timer
    Left = 72
    Top = 8
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 104
    Top = 8
  end
  object DropFileSource1: TDropFileSource
    DragTypes = [dtCopy]
    Images = DragImageList
    ShowImage = True
    Left = 72
    Top = 72
  end
  object DragImageList: TImageList
    BlendColor = clFuchsia
    BkColor = clFuchsia
    Left = 40
    Top = 72
  end
  object DropFileTarget1: TDropFileTarget
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
  object DestroyTimer: TTimer
    Enabled = False
    Interval = 1
    OnTimer = DestroyTimerTimer
    Left = 8
    Top = 120
  end
end
