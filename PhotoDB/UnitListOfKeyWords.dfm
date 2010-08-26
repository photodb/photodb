object FormListOfKeyWords: TFormListOfKeyWords
  Left = 211
  Top = 171
  BorderStyle = bsSizeToolWin
  Caption = 'List of KeyWords'
  ClientHeight = 361
  ClientWidth = 304
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object ListBox1: TListBox
    Left = 0
    Top = 57
    Width = 304
    Height = 270
    Align = alClient
    ItemHeight = 13
    TabOrder = 0
    OnContextPopup = ListBox1ContextPopup
    OnDblClick = ListBox1DblClick
  end
  object Panel1: TPanel
    Left = 0
    Top = 327
    Width = 304
    Height = 34
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 323
    object Panel2: TPanel
      Left = 172
      Top = 0
      Width = 132
      Height = 34
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object Button1: TButton
        Left = 51
        Top = 3
        Width = 75
        Height = 25
        Caption = 'Ok'
        TabOrder = 0
        OnClick = Button1Click
      end
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 304
    Height = 57
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object Label1: TLabel
      Left = 4
      Top = 4
      Width = 310
      Height = 53
      AutoSize = False
      Caption = 
        'This list with all keywords used in applocation. DoubleClick of ' +
        'each and it will be copyed on clipboard.'
      WordWrap = True
    end
  end
  object DestroyTimer: TTimer
    Enabled = False
    Interval = 10
    OnTimer = DestroyTimerTimer
    Left = 176
    Top = 8
  end
  object PopupMenu1: TPopupMenu
    Left = 128
    Top = 8
    object Copy1: TMenuItem
      Caption = 'Copy'
      OnClick = Copy1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Search1: TMenuItem
      Caption = 'Search'
      OnClick = Search1Click
    end
  end
end
