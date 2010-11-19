object FrmAdvancedOptions: TFrmAdvancedOptions
  Left = 0
  Top = 0
  ClientHeight = 327
  ClientWidth = 428
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 3
    Top = 281
    Width = 35
    Height = 13
    Caption = 'LblPath'
  end
  object Label7: TLabel
    Left = 232
    Top = 3
    Width = 153
    Height = 13
    Caption = '- File will open with this Program'
  end
  object Label8: TLabel
    Left = 232
    Top = 34
    Width = 185
    Height = 13
    Caption = '- File option will added for this file type'
  end
  object Label9: TLabel
    Left = 232
    Top = 65
    Width = 112
    Height = 13
    Caption = '- File extension ignored'
  end
  object CbFileExtensions: TCheckListBox
    Left = 3
    Top = 3
    Width = 201
    Height = 270
    ItemHeight = 13
    TabOrder = 0
  end
  object EdPath: TEdit
    Left = 3
    Top = 300
    Width = 394
    Height = 21
    TabOrder = 1
    Text = 'EdPath'
  end
  object CheckBox3: TCheckBox
    Left = 216
    Top = 3
    Width = 17
    Height = 17
    Checked = True
    State = cbChecked
    TabOrder = 2
  end
  object CheckBox4: TCheckBox
    Left = 216
    Top = 34
    Width = 17
    Height = 17
    AllowGrayed = True
    State = cbGrayed
    TabOrder = 3
  end
  object CheckBox5: TCheckBox
    Left = 216
    Top = 65
    Width = 17
    Height = 17
    TabOrder = 4
  end
  object BtnSelectDirectory: TButton
    Left = 403
    Top = 300
    Width = 19
    Height = 21
    Caption = '...'
    TabOrder = 5
    OnClick = BtnSelectDirectoryClick
  end
end
