object Form1: TForm1
  Left = 192
  Top = 114
  Width = 696
  Height = 480
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object DBGrid1: TDBGrid
    Left = 137
    Top = 0
    Width = 551
    Height = 446
    Align = alClient
    DataSource = DataSource1
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 137
    Height = 446
    Align = alLeft
    TabOrder = 1
    object Button1: TButton
      Left = 6
      Top = 8
      Width = 75
      Height = 25
      Caption = #1055#1086#1089#1090#1086#1103#1085#1085#1099#1077
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 6
      Top = 40
      Width = 75
      Height = 25
      Caption = #1042#1089#1077
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 6
      Top = 72
      Width = 75
      Height = 25
      Caption = '1.6'
      TabOrder = 2
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 6
      Top = 104
      Width = 75
      Height = 25
      Caption = '1.7'
      TabOrder = 3
      OnClick = Button4Click
    end
    object Button5: TButton
      Left = 6
      Top = 136
      Width = 75
      Height = 25
      Caption = '1.8'
      TabOrder = 4
      OnClick = Button5Click
    end
    object Button6: TButton
      Left = 6
      Top = 168
      Width = 75
      Height = 25
      Caption = '1.9'
      TabOrder = 5
      OnClick = Button6Click
    end
    object Button7: TButton
      Left = 6
      Top = 200
      Width = 75
      Height = 25
      Caption = '2.0'
      TabOrder = 6
      OnClick = Button7Click
    end
    object Button8: TButton
      Left = 88
      Top = 72
      Width = 9
      Height = 25
      Caption = '+'
      TabOrder = 7
      OnClick = Button8Click
    end
    object Button9: TButton
      Left = 88
      Top = 104
      Width = 9
      Height = 25
      Caption = '+'
      TabOrder = 8
      OnClick = Button9Click
    end
    object Button10: TButton
      Left = 88
      Top = 136
      Width = 9
      Height = 25
      Caption = '+'
      TabOrder = 9
      OnClick = Button10Click
    end
    object Button11: TButton
      Left = 88
      Top = 168
      Width = 9
      Height = 25
      Caption = '+'
      TabOrder = 10
      OnClick = Button11Click
    end
    object Button12: TButton
      Left = 88
      Top = 200
      Width = 9
      Height = 25
      Caption = '+'
      TabOrder = 11
      OnClick = Button12Click
    end
  end
  object Table1: TTable
    Left = 144
    Top = 176
  end
  object DataSource1: TDataSource
    DataSet = Query1
    Left = 128
    Top = 96
  end
  object Query1: TQuery
    Left = 152
    Top = 176
  end
end
