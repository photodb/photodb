object FormInternetUpdating: TFormInternetUpdating
  Left = 261
  Top = 130
  BorderStyle = bsToolWindow
  Caption = 'New updating avaliable'
  ClientHeight = 277
  ClientWidth = 352
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 239
    Width = 352
    Height = 38
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object Button1: TButton
      Left = 272
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Ok'
      TabOrder = 0
      OnClick = Button1Click
    end
    object CheckBox1: TCheckBox
      Left = 7
      Top = 13
      Width = 241
      Height = 17
      Caption = 'Remaind me later'
      TabOrder = 1
    end
  end
  object WebLink1: TWebLink
    Left = 160
    Top = 216
    Width = 88
    Height = 13
    Cursor = crHandPoint
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    Text = 'Download now'
    OnClick = WebLink1Click
    BkColor = clBtnFace
    ImageIndex = 0
    IconWidth = 0
    IconHeight = 0
    UseEnterColor = True
    EnterColor = clNavy
    EnterBould = True
    TopIconIncrement = 0
    ImageCanRegenerate = False
  end
  object RichEdit1: TRichEdit
    Left = 8
    Top = 8
    Width = 337
    Height = 201
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Color = clBtnFace
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    PlainText = True
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object WebLink2: TWebLink
    Left = 4
    Top = 216
    Width = 61
    Height = 13
    Cursor = crHandPoint
    Text = 'Home Page'
    OnClick = WebLink2Click
    BkColor = clBtnFace
    ImageIndex = 0
    IconWidth = 0
    IconHeight = 0
    UseEnterColor = True
    EnterColor = clNavy
    EnterBould = True
    TopIconIncrement = 0
    ImageCanRegenerate = False
  end
  object DestroyTimer: TTimer
    Enabled = False
    Interval = 10
    OnTimer = DestroyTimerTimer
    Left = 24
    Top = 168
  end
end
