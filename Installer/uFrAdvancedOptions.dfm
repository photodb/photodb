object FrmAdvancedOptions: TFrmAdvancedOptions
  Left = 0
  Top = 0
  Width = 425
  Height = 324
  TabOrder = 0
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
  object CheckListBox1: TCheckListBox
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
    Width = 414
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
end
