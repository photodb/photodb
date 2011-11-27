object FormEditObject: TFormEditObject
  Left = 0
  Top = 0
  Caption = 'FormEditObject'
  ClientHeight = 276
  ClientWidth = 408
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    408
    276)
  PixelsPerInch = 96
  TextHeight = 13
  object LbColor: TLabel
    Left = 8
    Top = 117
    Width = 36
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'LbColor'
  end
  object LbNoteText: TLabel
    Left = 8
    Top = 8
    Width = 56
    Height = 13
    Caption = 'LbNoteText'
  end
  object CbColor: TColorBox
    Left = 8
    Top = 136
    Width = 392
    Height = 22
    NoneColorColor = clRed
    Selected = clScrollBar
    Style = [cbCustomColors]
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 0
    ExplicitTop = 118
    ExplicitWidth = 332
  end
  object BtnOk: TButton
    Left = 323
    Top = 244
    Width = 77
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnOk'
    TabOrder = 1
    ExplicitLeft = 260
    ExplicitTop = 192
  end
  object BtnCancel: TButton
    Left = 242
    Top = 244
    Width = 77
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnCancel'
    TabOrder = 2
    ExplicitLeft = 179
    ExplicitTop = 192
  end
  object RgType: TRadioGroup
    Left = 8
    Top = 164
    Width = 392
    Height = 74
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'RgType'
    Items.Strings = (
      'Object rect'
      'Text')
    TabOrder = 3
    ExplicitTop = 146
    ExplicitWidth = 332
  end
  object WemText: TWatermarkedMemo
    Left = 8
    Top = 27
    Width = 392
    Height = 84
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 4
    WatermarkText = 'Please enter any text'
    ExplicitWidth = 332
    ExplicitHeight = 61
  end
end
