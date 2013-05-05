object FormDBPreviewSize: TFormDBPreviewSize
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'FormDBPreviewSize'
  ClientHeight = 177
  ClientWidth = 380
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
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  DesignSize = (
    380
    177)
  PixelsPerInch = 96
  TextHeight = 13
  object LbDatabaseSize: TLabel
    Left = 8
    Top = 121
    Width = 364
    Height = 18
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = '30 Mb'
    WordWrap = True
    ExplicitWidth = 276
  end
  object LbSingleImageSize: TLabel
    Left = 8
    Top = 100
    Width = 364
    Height = 18
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'Size: 30Kb'
    WordWrap = True
    ExplicitWidth = 276
  end
  object LbDBImageSize: TLabel
    Left = 8
    Top = 8
    Width = 71
    Height = 13
    Caption = 'DB Image size:'
  end
  object LbDBImageQuality: TLabel
    Left = 8
    Top = 54
    Width = 83
    Height = 13
    Caption = 'DB Image quaity:'
  end
  object WlPreviewDBSize: TWebLink
    Left = 127
    Top = 30
    Width = 103
    Height = 16
    Cursor = crHandPoint
    Text = 'WlPreviewDBSize'
    OnClick = WlPreviewDBSizeClick
    ImageIndex = 0
    UseEnterColor = False
    EnterColor = clBlack
    EnterBould = False
    TopIconIncrement = 0
    UseSpecIconSize = True
    HightliteImage = False
    StretchImage = True
    CanClick = True
  end
  object CbDBImageSize: TComboBox
    Left = 8
    Top = 27
    Width = 113
    Height = 21
    AutoComplete = False
    ItemIndex = 3
    TabOrder = 1
    Text = '150'
    OnChange = CbDBImageSizeChange
    Items.Strings = (
      '50'
      '75'
      '100'
      '150'
      '200'
      '300')
  end
  object CbDBJpegquality: TComboBox
    Left = 8
    Top = 73
    Width = 113
    Height = 21
    AutoComplete = False
    ItemIndex = 3
    TabOrder = 2
    Text = '150'
    OnChange = CbDBJpegqualityChange
    Items.Strings = (
      '50'
      '75'
      '100'
      '150'
      '200'
      '300')
  end
  object WlPreviewDBJpegQuality: TWebLink
    Left = 127
    Top = 76
    Width = 141
    Height = 16
    Cursor = crHandPoint
    Text = 'WlPreviewDBJpegQuality'
    OnClick = WlPreviewDBSizeClick
    ImageIndex = 0
    UseEnterColor = False
    EnterColor = clBlack
    EnterBould = False
    TopIconIncrement = 0
    UseSpecIconSize = True
    HightliteImage = False
    StretchImage = True
    CanClick = True
  end
  object BtnOk: TButton
    Left = 297
    Top = 144
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnOk'
    TabOrder = 4
    OnClick = BtnOkClick
  end
  object BtnCancel: TButton
    Left = 216
    Top = 144
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnCancel'
    TabOrder = 5
    OnClick = BtnCancelClick
  end
end
