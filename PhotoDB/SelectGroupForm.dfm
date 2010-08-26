object FormSelectGroup: TFormSelectGroup
  Left = 377
  Top = 182
  BorderStyle = bsSingle
  Caption = 'FormSelectGroup'
  ClientHeight = 99
  ClientWidth = 214
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 201
    Height = 30
    AutoSize = False
    Caption = 'Please, select group:'
    WordWrap = True
  end
  object ComboBoxEx1: TComboBoxEx
    Left = 6
    Top = 41
    Width = 204
    Height = 24
    ItemsEx = <>
    ParentColor = True
    TabOrder = 0
    Text = 'ComboBoxEx1'
    Images = GroupsImageList
  end
  object Button1: TButton
    Left = 134
    Top = 68
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 53
    Top = 68
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = Button2Click
  end
  object GroupsImageList: TImageList
    Height = 18
    Left = 176
    Top = 8
  end
end
