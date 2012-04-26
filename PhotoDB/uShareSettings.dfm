object FormShareSettings: TFormShareSettings
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'FormShareSettings'
  ClientHeight = 273
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
    273)
  PixelsPerInch = 96
  TextHeight = 13
  object LbOutputFormat: TLabel
    Left = 8
    Top = 8
    Width = 79
    Height = 13
    Caption = 'LbOutputFormat'
  end
  object LbWidth: TLabel
    Left = 8
    Top = 127
    Width = 39
    Height = 13
    Caption = 'LbWidth'
  end
  object LbHeight: TLabel
    Left = 144
    Top = 127
    Width = 42
    Height = 13
    Caption = 'LbHeight'
  end
  object LbAccess: TLabel
    Left = 8
    Top = 192
    Width = 105
    Height = 13
    Caption = 'Default album access:'
  end
  object BtnOk: TButton
    Left = 295
    Top = 240
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnOk'
    TabOrder = 0
    OnClick = BtnOkClick
    ExplicitTop = 184
  end
  object BtnCancel: TButton
    Left = 214
    Top = 240
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnCancel'
    TabOrder = 1
    OnClick = BtnCancelClick
    ExplicitTop = 184
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
    OnClick = WlJpegSettingsClick
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
    Top = 161
    Width = 362
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'CbPreviewForRAW'
    TabOrder = 4
  end
  object CbImageSize: TComboBox
    Left = 8
    Top = 97
    Width = 362
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 5
    OnChange = CbImageSizeChange
  end
  object SeWidth: TSpinEdit
    Left = 53
    Top = 124
    Width = 79
    Height = 22
    MaxValue = 9999
    MinValue = 400
    TabOrder = 6
    Value = 800
  end
  object SeHeight: TSpinEdit
    Left = 192
    Top = 124
    Width = 79
    Height = 22
    MaxValue = 9999
    MinValue = 400
    TabOrder = 7
    Value = 600
  end
  object CbResizeToSize: TCheckBox
    Left = 8
    Top = 78
    Width = 362
    Height = 17
    Caption = 'CbResizeToSize'
    TabOrder = 8
    OnClick = CbResizeToSizeClick
  end
  object CbDefaultAlbumAccess: TComboBox
    Left = 8
    Top = 211
    Width = 362
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 9
  end
end
