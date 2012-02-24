object FormHistory: TFormHistory
  Left = 250
  Top = 223
  BorderStyle = bsSizeToolWin
  Caption = 'FormHistory'
  ClientHeight = 287
  ClientWidth = 382
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
  OnDestroy = FormDestroy
  DesignSize = (
    382
    287)
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 382
    Height = 57
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      382
      57)
    object InfoLabel: TLabel
      Left = 8
      Top = 8
      Width = 366
      Height = 41
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'InfoLabel'
      WordWrap = True
      ExplicitWidth = 368
    end
  end
  object InfoListBox: TListBox
    Left = 0
    Top = 57
    Width = 382
    Height = 191
    Style = lbOwnerDrawVariable
    Anchors = [akLeft, akTop, akRight, akBottom]
    ItemHeight = 13
    TabOrder = 1
    OnContextPopup = InfoListBoxContextPopup
    OnDblClick = InfoListBoxDblClick
    OnDrawItem = InfoListBoxDrawItem
    OnMeasureItem = InfoListBoxMeasureItem
  end
  object BtnOk: TButton
    Left = 299
    Top = 254
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    TabOrder = 2
    OnClick = BtnOkClick
  end
  object PmActions: TPopupMenu
    Left = 112
    Top = 152
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
