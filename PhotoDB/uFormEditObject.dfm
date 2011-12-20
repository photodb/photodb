object FormEditObject: TFormEditObject
  Left = 0
  Top = 0
  Caption = 'FormEditObject'
  ClientHeight = 220
  ClientWidth = 345
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    345
    220)
  PixelsPerInch = 96
  TextHeight = 13
  object lbColor: TLabel
    Left = 8
    Top = 141
    Width = 33
    Height = 13
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'lbColor'
    ExplicitTop = 145
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
    Top = 160
    Width = 329
    Height = 22
    NoneColorColor = clRed
    Selected = clScrollBar
    Style = [cbCustomColors]
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 0
    ExplicitTop = 164
  end
  object MemText: TMemo
    Left = 8
    Top = 27
    Width = 329
    Height = 108
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      'MemText')
    TabOrder = 1
    ExplicitHeight = 112
  end
  object BtnOk: TButton
    Left = 260
    Top = 188
    Width = 77
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnOk'
    TabOrder = 2
    ExplicitTop = 192
  end
  object BtnCancel: TButton
    Left = 179
    Top = 188
    Width = 77
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnCancel'
    TabOrder = 3
    ExplicitTop = 192
  end
end
