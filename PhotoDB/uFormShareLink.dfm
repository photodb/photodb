object FormShareLink: TFormShareLink
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'FormShareLink'
  ClientHeight = 141
  ClientWidth = 393
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    393
    141)
  PixelsPerInch = 96
  TextHeight = 13
  object SbCopyToClipboard: TSpeedButton
    Left = 8
    Top = 83
    Width = 23
    Height = 23
    Flat = True
    OnClick = SbCopyToClipboardClick
  end
  object CbShortUrl: TCheckBox
    Left = 8
    Top = 116
    Width = 249
    Height = 17
    Caption = 'Make short url'
    Checked = True
    State = cbChecked
    TabOrder = 0
    OnClick = CbShortUrlClick
  end
  object BtnClose: TButton
    Left = 310
    Top = 108
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnClose'
    TabOrder = 1
    OnClick = BtnCloseClick
  end
  object LsMain: TLoadingSign
    Left = 8
    Top = 83
    Width = 23
    Height = 23
    Active = True
    FillPercent = 70
    SignColor = clBlack
    MaxTransparencity = 255
  end
  object PnPreview: TPanel
    Left = 8
    Top = 8
    Width = 97
    Height = 69
    BevelOuter = bvNone
    TabOrder = 3
  end
  object LnkPublicLink: TWebLink
    Left = 37
    Top = 83
    Width = 348
    Height = 23
    Cursor = crHandPoint
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    Text = 'LnkPublicLink'
    OnClick = LnkPublicLinkClick
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
    UseEndEllipsis = True
  end
  object WlSettings: TWebLink
    Left = 327
    Top = 8
    Width = 58
    Height = 16
    Cursor = crHandPoint
    Anchors = [akTop, akRight]
    Text = 'Settngs'
    OnClick = WlSettingsClick
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
end
