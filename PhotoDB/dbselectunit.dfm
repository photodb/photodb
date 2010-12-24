object DBSelect: TDBSelect
  Left = 176
  Top = 271
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Select DataBase'
  ClientHeight = 167
  ClientWidth = 311
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 104
    Top = 34
    Width = 16
    Height = 16
    OnClick = Image1Click
  end
  object Label1: TLabel
    Left = 8
    Top = 88
    Width = 98
    Height = 13
    Caption = 'Use another DB File:'
  end
  object Edit1: TEdit
    Left = 8
    Top = 8
    Width = 225
    Height = 21
    ReadOnly = True
    TabOrder = 0
    Text = '<no database>'
  end
  object Button1: TButton
    Left = 240
    Top = 8
    Width = 65
    Height = 21
    Caption = 'Open'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button3: TButton
    Left = 232
    Top = 136
    Width = 75
    Height = 25
    Caption = 'Ok'
    Enabled = False
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button2: TButton
    Left = 152
    Top = 136
    Width = 75
    Height = 25
    Caption = 'Exit'
    TabOrder = 3
  end
  object Button4: TButton
    Left = 8
    Top = 32
    Width = 89
    Height = 25
    Caption = 'Create New'
    TabOrder = 4
    OnClick = Button4Click
  end
  object CheckBox1: TCheckBox
    Left = 8
    Top = 64
    Width = 297
    Height = 17
    Caption = 'Use as default DataBase'
    Enabled = False
    TabOrder = 5
  end
  object Edit2: TEdit
    Left = 128
    Top = 35
    Width = 177
    Height = 21
    TabOrder = 6
    Text = 'Name'
  end
  object ComboBoxExDB1: TComboBoxExDB
    Left = 8
    Top = 104
    Width = 297
    Height = 22
    ItemsEx = <>
    Style = csExDropDownList
    TabOrder = 7
    OnSelect = ComboBoxExDB1Select
    Images = DBImageList
    ShowDropDownMenu = True
    LastItemIndex = 0
    ShowEditIndex = -1
  end
  object DBImageList: TImageList
    Left = 8
    Top = 128
  end
end
