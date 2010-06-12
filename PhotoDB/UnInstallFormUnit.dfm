object UnInstallForm: TUnInstallForm
  Left = 290
  Top = 192
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'UnInstall'
  ClientHeight = 245
  ClientWidth = 208
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 193
    Height = 52
    Caption = 'UnInstall Photo DataBase vX.Y'
    Constraints.MaxHeight = 52
    Constraints.MaxWidth = 193
    Constraints.MinHeight = 52
    Constraints.MinWidth = 193
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Comic Sans MS'
    Font.Style = []
    ParentFont = False
    WordWrap = True
  end
  object Label2: TLabel
    Left = 8
    Top = 64
    Width = 59
    Height = 13
    Caption = 'UnInstall list:'
  end
  object Button1: TButton
    Left = 128
    Top = 216
    Width = 75
    Height = 25
    Caption = 'Uninstall'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 48
    Top = 216
    Width = 75
    Height = 25
    Caption = 'Exit'
    TabOrder = 1
    OnClick = Button2Click
  end
  object CheckListBox1: TCheckListBox
    Left = 8
    Top = 80
    Width = 193
    Height = 129
    ItemHeight = 13
    Items.Strings = (
      'Program files'
      'DataBase files'
      'Registry entries'
      'Chortcuts'
      'PlugIns'
      'Themes'
      'Scripts'
      'Actions')
    TabOrder = 2
  end
end
