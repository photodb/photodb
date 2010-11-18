object FormLanguage: TFormLanguage
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Select language'
  ClientHeight = 236
  ClientWidth = 225
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
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
    Top = 40
    Width = 209
    Height = 156
    ItemHeight = 13
    TabOrder = 0
    OnClick = LbLanguagesClick
  end
  object BtnOk: TButton
    Left = 142
    Top = 202
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 1
  end
end
