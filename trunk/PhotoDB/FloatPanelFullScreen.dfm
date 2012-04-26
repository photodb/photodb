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
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnClose = FormClose
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
    HotImages = HotImageList
    Images = NormalImageList
    TabOrder = 0
    object TbPlay: TToolButton
      Left = 0
      Top = 0
      Caption = 'TbPlay'
      Down = True
      Grouped = True
      ImageIndex = 0
      Style = tbsCheck
      OnClick = TbPlayClick
    end
    object TbPause: TToolButton
      Left = 27
      Top = 0
      Caption = 'TbPause'
      Grouped = True
      ImageIndex = 1
      Style = tbsCheck
      OnClick = TbPlayClick
    end
    object ToolButton3: TToolButton
      Left = 54
      Top = 0
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 2
      Style = tbsSeparator
    end
    object TbPrev: TToolButton
      Left = 62
      Top = 0
      Caption = 'TbPrev'
      ImageIndex = 2
      OnClick = TbPrevClick
    end
    object TbNext: TToolButton
      Left = 89
      Top = 0
      Caption = 'TbNext'
      ImageIndex = 3
      OnClick = TbNextClick
    end
    object ToolButton6: TToolButton
      Left = 116
      Top = 0
      Width = 8
      Caption = 'ToolButton6'
      ImageIndex = 4
      Style = tbsSeparator
    end
    object TbClose: TToolButton
      Left = 124
      Top = 0
      Caption = 'TbClose'
      ImageIndex = 4
      OnClick = TbCloseClick
    end
  end
  object NormalImageList: TImageList
    ColorDepth = cd32Bit
    Left = 8
    Top = 32
  end
  object HotImageList: TImageList
    ColorDepth = cd32Bit
    Left = 40
    Top = 32
  end
  object DisabledImageList: TImageList
    ColorDepth = cd32Bit
    Left = 72
    Top = 32
  end
end
