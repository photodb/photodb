object TIFFOptionsForm: TTIFFOptionsForm
  Left = 301
  Top = 257
  Width = 214
  Height = 187
  Caption = 'TIFF Options'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 120
    Top = 120
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 0
  end
  object Button2: TButton
    Left = 40
    Top = 120
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 1
  end
  object RadioGroup1: TRadioGroup
    Left = 8
    Top = 8
    Width = 185
    Height = 105
    Caption = 'Tiff Optinos'
    ItemIndex = 1
    Items.Strings = (
      'Without Compression'
      'LWZ Compression'
      'JPEG Compressing')
    TabOrder = 2
  end
end
