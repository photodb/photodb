object FormStringPromt: TFormStringPromt
  Left = 275
  Top = 178
  BorderStyle = bsSizeToolWin
  Caption = 'FormStringPromt'
  ClientHeight = 101
  ClientWidth = 255
  Color = clBtnFace
  Constraints.MaxHeight = 135
  Constraints.MinHeight = 135
  Constraints.MinWidth = 200
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    255
    101)
  PixelsPerInch = 96
  TextHeight = 13
  object LbInfo: TLabel
    Left = 8
    Top = 8
    Width = 238
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'Info'
    WordWrap = True
    ExplicitWidth = 209
  end
  object EdString: TWatermarkedEdit
    Left = 8
    Top = 40
    Width = 238
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    OnKeyPress = EdStringKeyPress
    WatermarkText = 'Enter your text here'
    ExplicitWidth = 224
  end
  object BtnOK: TButton
    Left = 172
    Top = 68
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'BtnOK'
    TabOrder = 1
    OnClick = BtnOKClick
  end
  object BtnCancel: TButton
    Left = 92
    Top = 68
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'BtnCancel'
    TabOrder = 2
    OnClick = BtnCancelClick
  end
end
