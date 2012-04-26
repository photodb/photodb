object NavigatorForm: TNavigatorForm
  Left = 427
  Top = 111
  Width = 228
  Height = 181
  BorderStyle = bsSizeToolWin
  Caption = #1053#1072#1074#1080#1075#1072#1090#1086#1088
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnCanResize = FormCanResize
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ScrollingImageNavigator: TScrollingImageNavigator
    Left = 0
    Top = 0
    Width = 220
    Height = 147
    ScrollingImage = MainForm.SI
    Shape.Left = 0
    Shape.Top = 0
    Shape.Width = 65
    Shape.Height = 65
    Shape.Brush.Style = bsClear
    Shape.Pen.Color = clRed
    Shape.Pen.Width = 2
    Align = alClient
  end
end
