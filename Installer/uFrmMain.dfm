object FrmMain: TFrmMain
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'PhotoDB 2.3 Setup'
  ClientHeight = 361
  ClientWidth = 604
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clBlack
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ImMain: TImage
    Left = 1
    Top = 8
    Width = 185
    Height = 161
  end
  object Label1: TLabel
    Left = 8
    Top = 176
    Width = 178
    Height = 139
    AutoSize = False
    Caption = 'Welcome to the Photo Database 2.3'
    WordWrap = True
  end
  object Bevel1: TBevel
    Left = 8
    Top = 321
    Width = 588
    Height = 1
    Shape = bsTopLine
  end
  object BtnNext: TButton
    Left = 441
    Top = 328
    Width = 75
    Height = 25
    Caption = 'BtnNext'
    Enabled = False
    TabOrder = 0
  end
  object BtnCancel: TButton
    Left = 360
    Top = 328
    Width = 75
    Height = 25
    Caption = 'BtnCancel'
    TabOrder = 1
    OnClick = BtnCancelClick
  end
  object BtnInstall: TButton
    Left = 521
    Top = 328
    Width = 75
    Height = 25
    Caption = 'BtnInstall'
    TabOrder = 2
    OnClick = BtnInstallClick
  end
end
