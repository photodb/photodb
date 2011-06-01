object ActivateForm: TActivateForm
  Left = 439
  Top = 230
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Activation'
  ClientHeight = 377
  ClientWidth = 541
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  DesignSize = (
    541
    377)
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 8
    Top = 341
    Width = 525
    Height = 1
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsTopLine
    ExplicitTop = 330
    ExplicitWidth = 524
  end
  object ImActivationImage: TImage
    Left = 8
    Top = 8
    Width = 180
    Height = 186
  end
  object LbInfo: TLabel
    Left = 8
    Top = 200
    Width = 145
    Height = 135
    Anchors = [akLeft, akTop, akBottom]
    AutoSize = False
    Caption = 'LbInfo'
    WordWrap = True
  end
  object BtnNext: TButton
    Left = 459
    Top = 347
    Width = 77
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnNext'
    TabOrder = 2
    OnClick = BtnNextClick
  end
  object BtnCancel: TButton
    Left = 297
    Top = 347
    Width = 77
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnCancel'
    TabOrder = 0
    OnClick = BtnCancelClick
  end
  object BtnFinish: TButton
    Left = 459
    Top = 347
    Width = 77
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnFinish'
    TabOrder = 3
    OnClick = BtnFinishClick
  end
  object BtnPrevious: TButton
    Left = 378
    Top = 347
    Width = 77
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Previous'
    TabOrder = 1
    OnClick = BtnPreviousClick
  end
  object LsLoading: TLoadingSign
    Left = 270
    Top = 348
    Width = 21
    Height = 21
    Visible = False
    Active = True
    FillPercent = 50
    SignColor = clBlack
    MaxTransparencity = 255
  end
end
