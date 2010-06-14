object Form1: TForm1
  Left = 306
  Top = 210
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsToolWindow
  Caption = 'Tools'
  ClientHeight = 157
  ClientWidth = 208
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 4
    Top = 3
    Width = 201
    Height = 150
    Caption = 'Startup Options'
    TabOrder = 0
    object Button1: TButton
      Left = 8
      Top = 96
      Width = 185
      Height = 17
      Caption = 'Uninstall'
      TabOrder = 3
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 8
      Top = 72
      Width = 185
      Height = 17
      Caption = 'Safe Mode'
      TabOrder = 2
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 8
      Top = 24
      Width = 185
      Height = 17
      Caption = 'Pack Table'
      TabOrder = 0
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 8
      Top = 48
      Width = 185
      Height = 17
      Caption = 'Recreate Image Thumbs in Table'
      TabOrder = 1
      OnClick = Button4Click
    end
    object Button5: TButton
      Left = 8
      Top = 120
      Width = 185
      Height = 17
      Caption = 'Close'
      TabOrder = 4
      OnClick = Button5Click
    end
  end
end
