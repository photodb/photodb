object FormLoginModeChooser: TFormLoginModeChooser
  Left = 447
  Top = 442
  BorderIcons = [biSystemMenu, biMaximize]
  BorderStyle = bsSingle
  Caption = 'Login Mode'
  ClientHeight = 169
  ClientWidth = 257
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
  object ButtonUseLogin: TButton
    Left = 8
    Top = 8
    Width = 241
    Height = 73
    Caption = 'ButtonUseLogin'
    TabOrder = 0
    WordWrap = True
    OnClick = ButtonUseLoginClick
  end
  object ButtonNOLoginMode: TButton
    Left = 8
    Top = 88
    Width = 241
    Height = 73
    Caption = 'ButtonNOLoginMode'
    TabOrder = 1
    WordWrap = True
    OnClick = ButtonNOLoginModeClick
  end
end
