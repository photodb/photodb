object CleaningForm1: TCleaningForm1
  Left = 363
  Top = 114
  Width = 417
  Height = 308
  Caption = 'Cleaning DataBase'
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
    Left = 8
    Top = 48
    Width = 75
    Height = 17
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 8
    Top = 88
    Width = 75
    Height = 17
    Caption = 'Button2'
    TabOrder = 1
    OnClick = Button2Click
  end
  object DmProgress1: TDmProgress
    Left = 88
    Top = 48
    Width = 100
    Height = 18
    Position = 0
    MinValue = 0
    MaxValue = 100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 16711808
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Text = 'Progress... (&%%)'
    BorderColor = 38400
    CoolColor = 38400
    Color = clBlack
    View = dm_pr_cool
  end
  object DmProgress2: TDmProgress
    Left = 88
    Top = 88
    Width = 100
    Height = 18
    Position = 0
    MinValue = 0
    MaxValue = 100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 16711808
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Text = 'Progress... (&%%)'
    BorderColor = 38400
    CoolColor = 38400
    Color = clBlack
    View = dm_pr_cool
  end
  object CheckBox1: TCheckBox
    Left = 16
    Top = 16
    Width = 97
    Height = 17
    Caption = 'AllowBackGrou'
    TabOrder = 4
  end
end
