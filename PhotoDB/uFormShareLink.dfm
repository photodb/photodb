object FormShareLink: TFormShareLink
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'FormShareLink'
  ClientHeight = 141
  ClientWidth = 667
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    667
    141)
  PixelsPerInch = 96
  TextHeight = 13
  object SbCopy: TSpeedButton
    Left = 632
    Top = 8
    Width = 30
    Height = 27
    Anchors = [akTop, akRight]
    OnClick = SbCopyClick
    ExplicitLeft = 548
  end
  object EdPublicLink: TEdit
    Left = 8
    Top = 8
    Width = 618
    Height = 27
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 0
    Text = 'http://url.com'
    ExplicitWidth = 534
  end
  object CbShortUrl: TCheckBox
    Left = 8
    Top = 41
    Width = 651
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Make short url'
    TabOrder = 1
    OnClick = CbShortUrlClick
  end
  object BtnClose: TButton
    Left = 587
    Top = 109
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnClose'
    TabOrder = 2
    ExplicitLeft = 503
    ExplicitTop = 41
  end
  object LoadingSign1: TLoadingSign
    Left = 555
    Top = 107
    Width = 26
    Height = 26
    Active = True
    FillPercent = 70
    Anchors = [akRight, akBottom]
    SignColor = clBlack
    MaxTransparencity = 255
  end
  object PnPreview: TPanel
    Left = 8
    Top = 64
    Width = 97
    Height = 69
    BevelOuter = bvNone
    TabOrder = 4
  end
end
