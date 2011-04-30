object FormSteno: TFormSteno
  Left = 198
  Top = 127
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'StenoGraphia'
  ClientHeight = 241
  ClientWidth = 516
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 168
    Top = 24
    Width = 89
    Height = 13
    Caption = 'Max Size = 0 bytes'
  end
  object Label2: TLabel
    Left = 168
    Top = 8
    Width = 66
    Height = 13
    Caption = 'File Name = "'#39
  end
  object Label3: TLabel
    Left = 168
    Top = 40
    Width = 100
    Height = 13
    Caption = 'Nornal Size = 0 bytes'
  end
  object Label4: TLabel
    Left = 168
    Top = 72
    Width = 102
    Height = 13
    Caption = 'Information FileName:'
  end
  object Label5: TLabel
    Left = 168
    Top = 144
    Width = 85
    Height = 13
    Caption = 'File Size = 0 bytes'
  end
  object Label6: TLabel
    Left = 168
    Top = 160
    Width = 44
    Height = 13
    Caption = 'Use filter:'
  end
  object Label7: TLabel
    Left = 168
    Top = 56
    Width = 95
    Height = 13
    Caption = 'Good Size = 0 bytes'
  end
  object Panel1: TPanel
    Left = 8
    Top = 15
    Width = 153
    Height = 161
    BevelInner = bvLowered
    TabOrder = 0
    object ImPreview: TImage
      Left = 2
      Top = 2
      Width = 149
      Height = 157
      Align = alClient
      Center = True
      PopupMenu = PopupMenu1
      Proportional = True
    end
  end
  object Memo1: TMemo
    Tag = 1
    Left = 168
    Top = 88
    Width = 337
    Height = 49
    Lines.Strings = (
      '')
    ParentColor = True
    ReadOnly = True
    TabOrder = 1
  end
  object BtnOpenImage: TButton
    Left = 8
    Top = 208
    Width = 137
    Height = 25
    Caption = 'Open Image'
    TabOrder = 2
    OnClick = BtnOpenImageClick
  end
  object BtnAddInfo: TButton
    Left = 152
    Top = 208
    Width = 185
    Height = 25
    Caption = 'Add Info and Save'
    TabOrder = 3
    OnClick = BtnAddInfoClick
  end
  object BtnExtractData: TButton
    Left = 344
    Top = 208
    Width = 169
    Height = 25
    Caption = 'Decrypt Image'
    TabOrder = 4
    OnClick = BtnExtractDataClick
  end
  object ComboBox1: TComboBox
    Left = 167
    Top = 179
    Width = 345
    Height = 21
    Style = csDropDownList
    ItemIndex = 1
    TabOrder = 5
    Text = 'Normal Size (Recomended)'
    Items.Strings = (
      'MaxSize (Minimal quality)'
      'Normal Size (Recomended)'
      'Good Size (Best)')
  end
  object PopupMenu1: TPopupMenu
    Left = 120
    Top = 56
    object LoadFromFile1: TMenuItem
      Caption = 'Load From File'
      OnClick = BtnOpenImageClick
    end
    object AddInfo1: TMenuItem
      Caption = 'Add Info'
      OnClick = BtnAddInfoClick
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 'All Files (*.*)|*?*'
    Options = [ofHideReadOnly, ofEnableIncludeNotify, ofEnableSizing]
    OnIncludeItem = OpenDialog1IncludeItem
    Left = 56
    Top = 56
  end
end
