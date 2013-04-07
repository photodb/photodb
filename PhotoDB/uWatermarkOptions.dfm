object FrmWatermarkOptions: TFrmWatermarkOptions
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'FrmWatermarkOptions'
  ClientHeight = 363
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
    363)
  PixelsPerInch = 96
  TextHeight = 13
  object BtnOk: TButton
    Left = 224
    Top = 332
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnOk'
    TabOrder = 1
    OnClick = BtnOkClick
  end
  object BtnCancel: TButton
    Left = 143
    Top = 332
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnCancel'
    TabOrder = 0
    OnClick = BtnCancelClick
  end
  object PcWatermarkType: TPageControl
    Left = 0
    Top = 0
    Width = 304
    Height = 326
    ActivePage = TsImage
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
    OnChange = PcWatermarkTypeChange
    object TsImage: TTabSheet
      Caption = 'TsImage'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object PaintBox1: TPaintBox
        Left = 3
        Top = 3
        Width = 290
        Height = 254
      end
      object Label1: TLabel
        Left = 3
        Top = 271
        Width = 65
        Height = 13
        Caption = 'Minimum size:'
      end
      object Label2: TLabel
        Left = 135
        Top = 271
        Width = 6
        Height = 13
        Caption = 'X'
      end
      object Label3: TLabel
        Left = 210
        Top = 271
        Width = 16
        Height = 13
        Caption = 'px.'
      end
      object SpinEdit1: TSpinEdit
        Left = 74
        Top = 268
        Width = 55
        Height = 22
        MaxValue = 0
        MinValue = 0
        TabOrder = 0
        Value = 0
      end
      object SpinEdit2: TSpinEdit
        Left = 150
        Top = 268
        Width = 55
        Height = 22
        MaxValue = 0
        MinValue = 0
        TabOrder = 1
        Value = 0
      end
    end
    object TsText: TTabSheet
      Caption = 'TsText'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        296
        298)
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
        Left = 6
        Top = 167
        Width = 286
        Height = 22
        DefaultColorColor = clWhite
        Selected = clWhite
        Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames, cbCustomColors]
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
      end
      object SeBlocksX: TSpinEdit
        Left = 6
        Top = 73
        Width = 286
        Height = 22
        Anchors = [akLeft, akTop, akRight]
        MaxValue = 10
        MinValue = 1
        TabOrder = 1
        Value = 1
      end
      object SeBlocksY: TSpinEdit
        Left = 6
        Top = 120
        Width = 286
        Height = 22
        Anchors = [akLeft, akTop, akRight]
        MaxValue = 10
        MinValue = 1
        TabOrder = 2
        Value = 1
      end
      object SeTransparency: TSpinEdit
        Left = 6
        Top = 260
        Width = 286
        Height = 22
        Anchors = [akLeft, akTop, akRight]
        MaxValue = 100
        MinValue = 0
        TabOrder = 3
        Value = 25
      end
      object EdWatermarkText: TWatermarkedEdit
        Left = 8
        Top = 27
        Width = 285
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 4
        WatermarkText = 'Sample'
      end
      object CbFonts: TComboBox
        Left = 8
        Top = 214
        Width = 286
        Height = 21
        Style = csDropDownList
        TabOrder = 5
      end
    end
  end
end
