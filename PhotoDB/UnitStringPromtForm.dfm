object FormStringPromt: TFormStringPromt
  Left = 275
  Top = 178
  BorderStyle = bsSizeToolWin
  Caption = 'FormStringPromt'
  ClientHeight = 111
  ClientWidth = 255
  Color = clBtnFace
  Constraints.MaxHeight = 145
  Constraints.MinHeight = 145
  Constraints.MinWidth = 200
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    255
    111)
  PixelsPerInch = 96
  TextHeight = 13
  object LbInfo: TLabel
    Left = 8
    Top = 8
    Width = 238
    Height = 37
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'Info'
    WordWrap = True
  end
  object EdString: TWatermarkedEdit
    Left = 8
    Top = 51
    Width = 238
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    OnKeyPress = EdStringKeyPress
    WatermarkText = 'Enter your text here'
  end
  object BtnOK: TButton
    Left = 172
    Top = 78
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'BtnOK'
    TabOrder = 2
    OnClick = BtnOKClick
  end
  object BtnCancel: TButton
    Left = 91
    Top = 78
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'BtnCancel'
    TabOrder = 1
    OnClick = BtnCancelClick
  end
end
