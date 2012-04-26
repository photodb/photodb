object FrmWatermarkOptions: TFrmWatermarkOptions
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'FrmWatermarkOptions'
  ClientHeight = 318
  ClientWidth = 304
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  DesignSize = (
    304
    318)
  PixelsPerInch = 96
  TextHeight = 13
  object LbBlocksX: TLabel
    Left = 8
    Top = 54
    Width = 46
    Height = 13
    Caption = 'LbBlocksX'
  end
  object LbTextColor: TLabel
    Left = 8
    Top = 148
    Width = 58
    Height = 13
    Caption = 'LbTextColor'
  end
  object LbBlocksY: TLabel
    Left = 8
    Top = 101
    Width = 46
    Height = 13
    Caption = 'LbBlocksY'
  end
  object LbTransparency: TLabel
    Left = 8
    Top = 241
    Width = 77
    Height = 13
    Caption = 'LbTransparency'
  end
  object LbWatermarkText: TLabel
    Left = 8
    Top = 8
    Width = 86
    Height = 13
    Caption = 'LbWatermarkText'
  end
  object LbFontName: TLabel
    Left = 8
    Top = 195
    Width = 60
    Height = 13
    Caption = 'LbFontName'
  end
  object CbColor: TColorBox
    Left = 8
    Top = 167
    Width = 290
    Height = 22
    DefaultColorColor = clWhite
    Selected = clWhite
    Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames, cbCustomColors]
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 3
  end
  object SeBlocksX: TSpinEdit
    Left = 8
    Top = 73
    Width = 290
    Height = 22
    Anchors = [akLeft, akTop, akRight]
    MaxValue = 10
    MinValue = 1
    TabOrder = 1
    Value = 1
  end
  object SeBlocksY: TSpinEdit
    Left = 8
    Top = 120
    Width = 290
    Height = 22
    Anchors = [akLeft, akTop, akRight]
    MaxValue = 10
    MinValue = 1
    TabOrder = 2
    Value = 1
  end
  object SeTransparency: TSpinEdit
    Left = 8
    Top = 260
    Width = 290
    Height = 22
    Anchors = [akLeft, akTop, akRight]
    MaxValue = 100
    MinValue = 0
    TabOrder = 5
    Value = 25
  end
  object BtnOk: TButton
    Left = 224
    Top = 287
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnOk'
    TabOrder = 7
    OnClick = BtnOkClick
  end
  object BtnCancel: TButton
    Left = 143
    Top = 287
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnCancel'
    TabOrder = 6
    OnClick = BtnCancelClick
  end
  object EdWatermarkText: TWatermarkedEdit
    Left = 8
    Top = 27
    Width = 288
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    WatermarkText = 'Sample'
  end
  object CbFonts: TComboBox
    Left = 8
    Top = 214
    Width = 288
    Height = 21
    Style = csDropDownList
    TabOrder = 4
  end
end
