object FrmWatermarkOptions: TFrmWatermarkOptions
  Left = 0
  Top = 0
  Caption = 'FrmWatermarkOptions'
  ClientHeight = 426
  ClientWidth = 724
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object LbBlocksX: TLabel
    Left = 595
    Top = 8
    Width = 46
    Height = 13
    Caption = 'LbBlocksX'
  end
  object LbTextColor: TLabel
    Left = 595
    Top = 102
    Width = 58
    Height = 13
    Caption = 'LbTextColor'
  end
  object LbBlocksY: TLabel
    Left = 595
    Top = 55
    Width = 46
    Height = 13
    Caption = 'LbBlocksY'
  end
  object ColorBox1: TColorBox
    Left = 595
    Top = 121
    Width = 121
    Height = 22
    DefaultColorColor = clWhite
    Selected = clWhite
    TabOrder = 0
  end
  object SeBlocksX: TSpinEdit
    Left = 595
    Top = 27
    Width = 121
    Height = 22
    MaxValue = 10
    MinValue = 1
    TabOrder = 1
    Value = 1
  end
  object SeBlocksY: TSpinEdit
    Left = 595
    Top = 74
    Width = 121
    Height = 22
    MaxValue = 10
    MinValue = 1
    TabOrder = 2
    Value = 1
  end
end
