object FormShareSettings: TFormShareSettings
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'FormShareSettings'
  ClientHeight = 246
  ClientWidth = 378
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  DesignSize = (
    378
    246)
  PixelsPerInch = 96
  TextHeight = 13
  object LbOutputFormat: TLabel
    Left = 8
    Top = 8
    Width = 79
    Height = 13
    Caption = 'LbOutputFormat'
  end
  object LbImageSize: TLabel
    Left = 8
    Top = 70
    Width = 60
    Height = 13
    Caption = 'LbImageSize'
  end
  object BtnOk: TButton
    Left = 295
    Top = 213
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnOk'
    TabOrder = 0
    OnClick = BtnOkClick
    ExplicitLeft = 401
    ExplicitTop = 282
  end
  object BtnCancel: TButton
    Left = 214
    Top = 213
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnCancel'
    TabOrder = 1
    OnClick = BtnCancelClick
    ExplicitLeft = 320
    ExplicitTop = 282
  end
  object CbOutputFormat: TComboBox
    Left = 8
    Top = 24
    Width = 362
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
  end
  object WlJpegSettings: TWebLink
    Left = 8
    Top = 51
    Width = 79
    Height = 13
    Cursor = crHandPoint
    Text = 'WlJpegSettings'
    ImageIndex = 0
    IconWidth = 0
    IconHeight = 0
    UseEnterColor = False
    EnterColor = clBlack
    EnterBould = False
    TopIconIncrement = 0
    UseSpecIconSize = True
    HightliteImage = False
    StretchImage = True
    CanClick = True
  end
  object CbPreviewForRAW: TCheckBox
    Left = 8
    Top = 190
    Width = 362
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'CbPreviewForRAW'
    TabOrder = 4
  end
  object ComboBox1: TComboBox
    Left = 8
    Top = 89
    Width = 362
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 5
  end
end
