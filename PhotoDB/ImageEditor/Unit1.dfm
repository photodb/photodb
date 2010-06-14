object Editor: TEditor
  Left = 192
  Top = 114
  Width = 653
  Height = 489
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  Caption = 'Editor'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  OnMouseDown = FormMouseDown
  OnMouseMove = FormMouseMove
  OnMouseUp = FormMouseUp
  OnPaint = FormPaint
  OnResize = Panel2Resize
  PixelsPerInch = 96
  TextHeight = 13
  object ToolsPanel: TPanel
    Left = 0
    Top = 0
    Width = 121
    Height = 435
    Align = alLeft
    TabOrder = 0
    object Shape1: TShape
      Left = 8
      Top = 8
      Width = 65
      Height = 73
      OnMouseDown = Shape1MouseDown
    end
  end
  object ScrollBar1: TScrollBar
    Left = 120
    Top = 416
    Width = 521
    Height = 17
    PageSize = 0
    TabOrder = 1
    OnChange = ScrollBar2Change
  end
  object ScrollBar2: TScrollBar
    Left = 624
    Top = 0
    Width = 17
    Height = 409
    Kind = sbVertical
    PageSize = 0
    TabOrder = 2
    OnChange = ScrollBar2Change
  end
  object MainMenu1: TMainMenu
    Left = 176
    Top = 128
    object File1: TMenuItem
      Caption = 'File'
      object Open1: TMenuItem
        Caption = 'Open'
        OnClick = Open1Click
      end
    end
  end
  object OpenPictureDialog1: TOpenPictureDialog
    Filter = 
      'All (*.gif;*.jpg;*.jpeg;*.bmp;)|*.gif;*.jpg;*.jpeg;*.bmp;|GIF Im' +
      'age (*.gif)|*.gif|JPEG Image File (*.jpg)|*.jpg|JPEG Image File ' +
      '(*.jpeg)|*.jpeg|Bitmaps (*.bmp)|*.bmp'
    Left = 129
    Top = 8
  end
  object ColorDialog1: TColorDialog
    Left = 208
    Top = 40
  end
end
