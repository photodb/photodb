object FormOperationProgress: TFormOperationProgress
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'FormOperationProgress'
  ClientHeight = 90
  ClientWidth = 394
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  DesignSize = (
    394
    90)
  PixelsPerInch = 96
  TextHeight = 13
  object LbInfo: TLabel
    Left = 8
    Top = 8
    Width = 377
    Height = 13
    Caption = 'LbInfo'
    Constraints.MaxWidth = 377
    Constraints.MinWidth = 377
  end
  object PrbProgress: TProgressBar
    Left = 8
    Top = 27
    Width = 377
    Height = 25
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 0
    ExplicitWidth = 387
  end
  object BtnCancel: TButton
    Left = 162
    Top = 58
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'BtnCancel'
    TabOrder = 1
    OnClick = BtnCancelClick
  end
end
