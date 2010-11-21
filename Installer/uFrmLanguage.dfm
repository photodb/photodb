object FormLanguage: TFormLanguage
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Select language'
  ClientHeight = 229
  ClientWidth = 225
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object LbInfo: TLabel
    Left = 8
    Top = 8
    Width = 204
    Height = 26
    AutoSize = False
    Caption = 'Please, select language of PhotoDB install:'
    WordWrap = True
  end
  object LbLanguages: TListBox
    Left = 8
    Top = 42
    Width = 209
    Height = 147
    Style = lbOwnerDrawFixed
    DoubleBuffered = True
    ItemHeight = 36
    ParentDoubleBuffered = False
    TabOrder = 0
    OnClick = LbLanguagesClick
    OnDrawItem = LbLanguagesDrawItem
    OnMouseDown = LbLanguagesMouseDown
  end
  object BtnOk: TButton
    Left = 142
    Top = 195
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 1
    OnClick = BtnOkClick
  end
  object XPManifest: TXPManifest
    Left = 168
    Top = 56
  end
end
