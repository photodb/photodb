inherited FrAdvancedOptions: TFrAdvancedOptions
  Width = 430
  Height = 330
  ParentFont = False
  ExplicitWidth = 430
  ExplicitHeight = 330
  object LbInstallPath: TLabel
    Left = 3
    Top = 281
    Width = 35
    Height = 13
    Caption = 'LblPath'
  end
  object LblUseExt: TLabel
    Left = 296
    Top = 3
    Width = 131
    Height = 40
    AutoSize = False
    Caption = '- File will open with this Program'
    WordWrap = True
  end
  object LblAddSubmenuItem: TLabel
    Left = 296
    Top = 44
    Width = 134
    Height = 42
    AutoSize = False
    Caption = '- File option will added for this file type'
    WordWrap = True
  end
  object LblSkipExt: TLabel
    Left = 296
    Top = 89
    Width = 131
    Height = 40
    AutoSize = False
    Caption = '- File extension ignored'
    WordWrap = True
  end
  object CbFileExtensions: TCheckListBox
    Left = 3
    Top = 3
    Width = 264
    Height = 270
    AllowGrayed = True
    ItemHeight = 13
    PopupMenu = PmAssociations
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
  object CbInstallTypeChecked: TCheckBox
    Left = 273
    Top = 2
    Width = 17
    Height = 17
    Checked = True
    State = cbChecked
    TabOrder = 2
  end
  object CbInstallTypeGrayed: TCheckBox
    Left = 273
    Top = 44
    Width = 17
    Height = 17
    AllowGrayed = True
    State = cbGrayed
    TabOrder = 3
  end
  object CbInstallTypeNone: TCheckBox
    Left = 273
    Top = 88
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
  object PmAssociations: TPopupMenu
    Left = 256
    Top = 168
    object SelectDefault1: TMenuItem
      Caption = 'Select Default'
      OnClick = SelectDefault1Click
    end
    object SelectAll1: TMenuItem
      Caption = 'Select All'
      OnClick = SelectAll1Click
    end
    object SelectNone1: TMenuItem
      Caption = 'Select None'
      OnClick = SelectNone1Click
    end
  end
  object AppEvents: TApplicationEvents
    OnMessage = AppEventsMessage
    Left = 272
    Top = 240
  end
end
