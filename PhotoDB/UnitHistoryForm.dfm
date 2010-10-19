object FormHistory: TFormHistory
  Left = 250
  Top = 223
  BorderStyle = bsSizeToolWin
  Caption = 'FormHistory'
  ClientHeight = 295
  ClientWidth = 376
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 376
    Height = 57
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object InfoLabel: TLabel
      Left = 8
      Top = 8
      Width = 353
      Height = 41
      AutoSize = False
      Caption = 'InfoLabel'
      WordWrap = True
    end
  end
  object InfoListBox: TListBox
    Left = 0
    Top = 57
    Width = 376
    Height = 204
    Style = lbOwnerDrawVariable
    Align = alClient
    ItemHeight = 13
    TabOrder = 1
    OnContextPopup = InfoListBoxContextPopup
    OnDblClick = InfoListBoxDblClick
    OnDrawItem = InfoListBoxDrawItem
    OnMeasureItem = InfoListBoxMeasureItem
  end
  object Panel2: TPanel
    Left = 0
    Top = 261
    Width = 376
    Height = 34
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object Panel3: TPanel
      Left = 240
      Top = 0
      Width = 136
      Height = 34
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object Button1: TButton
        Left = 56
        Top = 5
        Width = 75
        Height = 25
        Caption = 'Ok'
        TabOrder = 0
        OnClick = Button1Click
      end
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 112
    Top = 16
    object View1: TMenuItem
      Caption = 'View'
      OnClick = View1Click
    end
    object Explorer1: TMenuItem
      Caption = 'Explorer'
      OnClick = Explorer1Click
    end
    object ReAddAll1: TMenuItem
      Caption = 'ReAdd All'
      OnClick = ReAddAll1Click
    end
  end
end
