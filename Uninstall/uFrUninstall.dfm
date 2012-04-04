inherited FrUninstall: TFrUninstall
  Width = 430
  Height = 330
  ParentFont = False
  ExplicitWidth = 430
  ExplicitHeight = 330
  object cbYesUninstall: TCheckBox
    Left = 3
    Top = 27
    Width = 424
    Height = 17
    Caption = 'cbYesUninstall'
    TabOrder = 0
  end
  object GbUninstallOptions: TGroupBox
    Left = 3
    Top = 72
    Width = 424
    Height = 169
    Caption = 'GbUninstallOptions'
    TabOrder = 1
    object CbDeleteAllRegisteredCollection: TCheckBox
      Left = 10
      Top = 97
      Width = 400
      Height = 17
      Caption = 'CbDeleteAllRegisteredCollection'
      Enabled = False
      TabOrder = 0
      OnClick = CbDeleteAllRegisteredCollectionClick
    end
    object CbUnInstallAllUserSettings: TCheckBox
      Left = 10
      Top = 26
      Width = 400
      Height = 17
      Caption = 'CbUnInstallAllUserSettings'
      Checked = True
      Enabled = False
      State = cbChecked
      TabOrder = 1
    end
  end
end
