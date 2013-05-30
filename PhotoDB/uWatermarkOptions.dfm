object FrmWatermarkOptions: TFrmWatermarkOptions
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'FrmWatermarkOptions'
  ClientHeight = 512
  ClientWidth = 412
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  DesignSize = (
    412
    512)
  PixelsPerInch = 96
  TextHeight = 13
  object BtnOk: TButton
    Left = 332
    Top = 481
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnOk'
    TabOrder = 1
    OnClick = BtnOkClick
  end
  object BtnCancel: TButton
    Left = 251
    Top = 481
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
    Width = 412
    Height = 475
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
      object PnImageSettings: TPanel
        Left = 0
        Top = 0
        Width = 404
        Height = 447
        Align = alClient
        BevelOuter = bvNone
        FullRepaint = False
        ParentBackground = False
        TabOrder = 0
        DesignSize = (
          404
          447)
        object PbImage: TPaintBox
          Left = 2
          Top = 40
          Width = 401
          Height = 329
          OnMouseDown = PbImageMouseDown
          OnMouseMove = PbImageMouseMove
          OnMouseUp = PbImageMouseUp
          OnPaint = PbImagePaint
        end
        object LbInfo: TLabel
          Left = 3
          Top = 3
          Width = 398
          Height = 31
          AutoSize = False
          Caption = 'LbInfo'
          WordWrap = True
        end
        object LbImageTransparency: TLabel
          Left = 63
          Top = 423
          Width = 107
          Height = 13
          Caption = 'LbImageTransparency'
        end
        object CbKeepProportions: TCheckBox
          Left = 3
          Top = 397
          Width = 398
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'CbKeepProportions'
          TabOrder = 0
        end
        object WlWatermarkedImage: TWebLink
          Left = 3
          Top = 375
          Width = 398
          Height = 16
          Cursor = crHandPoint
          Anchors = [akLeft, akTop, akRight]
          Text = 'WlWatermarkedImage'
          OnClick = WlWatermarkedImageClick
          ImageIndex = 0
          IconWidth = 0
          UseEnterColor = False
          EnterColor = clBlack
          EnterBould = False
          TopIconIncrement = 0
          UseSpecIconSize = True
          HightliteImage = False
          StretchImage = True
          CanClick = True
          UseEndEllipsis = True
        end
        object SeImageTransparency: TSpinEdit
          Left = 3
          Top = 420
          Width = 54
          Height = 22
          MaxValue = 100
          MinValue = 0
          TabOrder = 2
          Value = 0
          OnChange = SeImageTransparencyChange
        end
      end
    end
    object TsText: TTabSheet
      Caption = 'TsText'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        404
        447)
      object LbBlocksX: TLabel
        Left = 3
        Top = 54
        Width = 46
        Height = 13
        Caption = 'LbBlocksX'
      end
      object LbTextColor: TLabel
        Left = 3
        Top = 148
        Width = 58
        Height = 13
        Caption = 'LbTextColor'
      end
      object LbBlocksY: TLabel
        Left = 3
        Top = 101
        Width = 46
        Height = 13
        Caption = 'LbBlocksY'
      end
      object LbTextTransparency: TLabel
        Left = 3
        Top = 241
        Width = 99
        Height = 13
        Caption = 'LbTextTransparency'
      end
      object LbWatermarkText: TLabel
        Left = 3
        Top = 8
        Width = 86
        Height = 13
        Caption = 'LbWatermarkText'
      end
      object LbFontName: TLabel
        Left = 3
        Top = 195
        Width = 60
        Height = 13
        Caption = 'LbFontName'
      end
      object CbColor: TColorBox
        Left = 3
        Top = 167
        Width = 394
        Height = 22
        DefaultColorColor = clWhite
        Selected = clWhite
        Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames, cbCustomColors]
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
      end
      object SeBlocksX: TSpinEdit
        Left = 3
        Top = 73
        Width = 394
        Height = 22
        Anchors = [akLeft, akTop, akRight]
        MaxValue = 10
        MinValue = 1
        TabOrder = 1
        Value = 1
      end
      object SeBlocksY: TSpinEdit
        Left = 3
        Top = 120
        Width = 394
        Height = 22
        Anchors = [akLeft, akTop, akRight]
        MaxValue = 10
        MinValue = 1
        TabOrder = 2
        Value = 1
      end
      object SeTextTransparency: TSpinEdit
        Left = 3
        Top = 260
        Width = 394
        Height = 22
        Anchors = [akLeft, akTop, akRight]
        MaxValue = 100
        MinValue = 0
        TabOrder = 3
        Value = 25
      end
      object EdWatermarkText: TWatermarkedEdit
        Left = 3
        Top = 27
        Width = 393
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 4
        WatermarkText = 'Sample'
      end
      object CbFonts: TComboBox
        Left = 3
        Top = 214
        Width = 393
        Height = 21
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 5
      end
    end
  end
end
