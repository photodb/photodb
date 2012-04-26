object FormInternetUpdating: TFormInternetUpdating
  Left = 261
  Top = 130
  BorderStyle = bsToolWindow
  Caption = 'New version is avaliable'
  ClientHeight = 277
  ClientWidth = 367
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = [fsBold]
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    367
    277)
  PixelsPerInch = 96
  TextHeight = 13
  object RedInfo: TRichEdit
    Left = 8
    Top = 8
    Width = 352
    Height = 201
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Color = clBtnFace
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    PlainText = True
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object WlHomePage: TWebLink
    Left = 8
    Top = 233
    Width = 59
    Height = 13
    Cursor = crHandPoint
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Text = 'Home Page'
    OnClick = WlHomePageClick
    ImageIndex = 0
    IconWidth = 0
    IconHeight = 0
    UseEnterColor = True
    EnterColor = clBlack
    EnterBould = False
    TopIconIncrement = 0
    DisableStyles = False
    UseSpecIconSize = True
    HightliteImage = False
    StretchImage = True
    CanClick = True
  end
  object CbRemindMeLater: TCheckBox
    Left = 8
    Top = 252
    Width = 270
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Remaind me later'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
  end
  object BtnOk: TButton
    Left = 284
    Top = 244
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Ok'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    OnClick = BtnOkClick
  end
  object WlDownload: TWebLink
    Left = 8
    Top = 215
    Width = 86
    Height = 13
    Cursor = crHandPoint
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    Text = 'Download now'
    OnClick = WlDownloadClick
    ImageIndex = 0
    IconWidth = 0
    IconHeight = 0
    UseEnterColor = False
    EnterColor = clBlack
    EnterBould = False
    TopIconIncrement = 0
    DisableStyles = False
    UseSpecIconSize = True
    HightliteImage = False
    StretchImage = True
    CanClick = True
  end
end
