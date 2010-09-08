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
    Top = 80
    Width = 46
    Height = 13
    Caption = 'LbBlocksX'
  end
  object ColorBox1: TColorBox
    Left = 595
    Top = 156
    Width = 121
    Height = 22
    TabOrder = 0
  end
  object SeBlocksX: TSpinEdit
    Left = 595
    Top = 99
    Width = 121
    Height = 22
    MaxValue = 10
    MinValue = 1
    TabOrder = 1
    Value = 1
  end
end
