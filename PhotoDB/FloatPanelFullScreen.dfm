object FloatPanel: TFloatPanel
  Left = 685
  Top = 79
  BorderStyle = bsNone
  ClientHeight = 25
  ClientWidth = 153
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 153
    Height = 25
    ButtonWidth = 27
    Caption = 'ToolBar1'
    DisabledImages = DisabledImageList
    EdgeBorders = []
    HotImages = HotImageList
    Images = NormalImageList
    TabOrder = 0
    object ToolButton1: TToolButton
      Left = 0
      Top = 2
      Caption = 'ToolButton1'
      Down = True
      Grouped = True
      ImageIndex = 0
      Style = tbsCheck
      OnClick = ToolButton1Click
    end
    object ToolButton2: TToolButton
      Left = 27
      Top = 2
      Caption = 'ToolButton2'
      Grouped = True
      ImageIndex = 1
      Style = tbsCheck
      OnClick = ToolButton1Click
    end
    object ToolButton3: TToolButton
      Left = 54
      Top = 2
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 2
      Style = tbsSeparator
    end
    object ToolButton4: TToolButton
      Left = 62
      Top = 2
      Caption = 'ToolButton4'
      ImageIndex = 2
      OnClick = ToolButton4Click
    end
    object ToolButton5: TToolButton
      Left = 89
      Top = 2
      Caption = 'ToolButton5'
      ImageIndex = 3
      OnClick = ToolButton5Click
    end
    object ToolButton6: TToolButton
      Left = 116
      Top = 2
      Width = 8
      Caption = 'ToolButton6'
      ImageIndex = 4
      Style = tbsSeparator
    end
    object ToolButton7: TToolButton
      Left = 124
      Top = 2
      Caption = 'ToolButton7'
      ImageIndex = 4
      OnClick = ToolButton7Click
    end
  end
  object NormalImageList: TImageList
    Left = 8
    Top = 32
  end
  object HotImageList: TImageList
    Left = 40
    Top = 32
  end
  object DisabledImageList: TImageList
    Left = 72
    Top = 32
  end
  object DestroyTimer: TTimer
    Enabled = False
    Interval = 1
    OnTimer = DestroyTimerTimer
    Left = 40
    Top = 16
  end
end
