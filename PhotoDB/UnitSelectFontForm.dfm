object FormSelectFont: TFormSelectFont
  Left = 370
  Top = 167
  BorderStyle = bsToolWindow
  Caption = 'Select Font'
  ClientHeight = 311
  ClientWidth = 201
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 232
    Width = 61
    Height = 20
    Caption = 'Old Font'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 8
    Top = 256
    Width = 63
    Height = 20
    Caption = 'New font'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object LbInfo: TLabel
    Left = 8
    Top = 8
    Width = 185
    Height = 33
    AutoSize = False
    Caption = 'Select font and press Ok button:'
    WordWrap = True
  end
  object LstFonts: TListBox
    Left = 8
    Top = 40
    Width = 185
    Height = 185
    Style = lbOwnerDrawVariable
    TabOrder = 0
    OnClick = LstFontsClick
    OnDrawItem = LstFontsDrawItem
    OnMeasureItem = LstFontsMeasureItem
  end
  object BtnCancel: TButton
    Left = 40
    Top = 280
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = BtnCancelClick
  end
  object BntOk: TButton
    Left = 120
    Top = 280
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 2
    OnClick = BntOkClick
  end
end
