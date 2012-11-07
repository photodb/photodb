inherited FrmImportImagesOptions: TFrmImportImagesOptions
  Width = 300
  Height = 273
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  ExplicitWidth = 300
  ExplicitHeight = 273
  object LbStepInfo: TLabel
    Left = 8
    Top = 8
    Width = 284
    Height = 65
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'Info'
    WordWrap = True
    ExplicitWidth = 257
  end
  object Label3: TLabel
    Left = 64
    Top = 108
    Width = 28
    Height = 13
    Caption = 'Width'
  end
  object Label5: TLabel
    Left = 179
    Top = 108
    Width = 31
    Height = 13
    Caption = 'Height'
  end
  object Label9: TLabel
    Left = 8
    Top = 133
    Width = 118
    Height = 13
    Caption = 'If conflict default action:'
  end
  object CbDontAddSmallImages: TCheckBox
    Left = 8
    Top = 80
    Width = 284
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Don'#39't Add Images smaller than:'
    Checked = True
    State = cbChecked
    TabOrder = 0
    OnClick = CbDontAddSmallImagesClick
  end
  object EdMinWidth: TEdit
    Left = 8
    Top = 104
    Width = 49
    Height = 21
    TabOrder = 1
    Text = '64'
  end
  object EdMinHeight: TEdit
    Left = 124
    Top = 104
    Width = 49
    Height = 21
    TabOrder = 2
    Text = '64'
  end
  object CbDefaultAction: TComboBox
    Left = 8
    Top = 152
    Width = 284
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemIndex = 1
    TabOrder = 3
    Text = 'Add All'
    Items.Strings = (
      'Ask me'
      'Add All'
      'Skip All'
      'Replace All')
  end
end
