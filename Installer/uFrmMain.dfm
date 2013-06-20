object FrmMain: TFrmMain
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'PhotoDB x.x Setup'
  ClientHeight = 379
  ClientWidth = 624
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clBlack
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    624
    379)
  PixelsPerInch = 96
  TextHeight = 13
  object ImMain: TImage
    Left = 1
    Top = 8
    Width = 185
    Height = 161
  end
  object LbWelcome: TLabel
    Left = 8
    Top = 176
    Width = 178
    Height = 139
    AutoSize = False
    Caption = 'Welcome to the Photo Database x.x'
    WordWrap = True
  end
  object Bevel1: TBevel
    Left = 8
    Top = 339
    Width = 608
    Height = 1
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsTopLine
    ExplicitTop = 321
    ExplicitWidth = 588
  end
  object BtnNext: TButton
    Left = 462
    Top = 346
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'BtnNext'
    TabOrder = 2
    OnClick = BtnNextClick
  end
  object BtnCancel: TButton
    Left = 381
    Top = 346
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'BtnCancel'
    TabOrder = 0
    OnClick = BtnCancelClick
  end
  object BtnInstall: TButton
    Left = 542
    Top = 346
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'BtnInstall'
    TabOrder = 3
    OnClick = BtnInstallClick
  end
  object BtnPrevious: TButton
    Left = 462
    Top = 346
    Width = 75
    Height = 25
    Caption = 'Previous'
    TabOrder = 1
    OnClick = BtnPreviousClick
  end
end
