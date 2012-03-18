inherited FrmConvertationSettings: TFrmConvertationSettings
  Width = 433
  Height = 329
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  ExplicitWidth = 433
  ExplicitHeight = 329
  object LbInfo: TLabel
    Left = 5
    Top = 8
    Width = 420
    Height = 33
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'Step info'
    WordWrap = True
  end
  object LbDatabaseSize: TLabel
    Left = 5
    Top = 95
    Width = 420
    Height = 42
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = '30 Mb'
    WordWrap = True
  end
  object LbSingleImageSize: TLabel
    Left = 5
    Top = 47
    Width = 420
    Height = 42
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'Size: 30Kb'
    WordWrap = True
  end
  object LbDBImageSize: TLabel
    Left = 5
    Top = 143
    Width = 71
    Height = 13
    Caption = 'DB Image size:'
  end
  object LbDBImageQuality: TLabel
    Left = 5
    Top = 189
    Width = 83
    Height = 13
    Caption = 'DB Image quaity:'
  end
  object LbPanelImageSize: TLabel
    Left = 5
    Top = 238
    Width = 82
    Height = 13
    Caption = 'Panel image size:'
  end
  object LbPreviewImageSize: TLabel
    Left = 6
    Top = 284
    Width = 94
    Height = 13
    Caption = 'Preview image size:'
  end
  object WlPreviewDBSize: TWebLink
    Left = 124
    Top = 165
    Width = 103
    Height = 16
    Cursor = crHandPoint
    Text = 'WlPreviewDBSize'
    OnClick = WlPreviewDBSizeClick
    ImageIndex = 0
    IconWidth = 16
    IconHeight = 16
    UseEnterColor = False
    EnterColor = clBlack
    EnterBould = False
    TopIconIncrement = 0
    UseSpecIconSize = True
    HightliteImage = False
    StretchImage = True
    CanClick = True
  end
  object CbDBImageSize: TComboBox
    Left = 5
    Top = 162
    Width = 113
    Height = 21
    AutoComplete = False
    ItemIndex = 3
    TabOrder = 1
    Text = '150'
    OnChange = CbDBImageSizeChange
    Items.Strings = (
      '50'
      '75'
      '100'
      '150'
      '200'
      '300')
  end
  object CbDBJpegquality: TComboBox
    Left = 5
    Top = 208
    Width = 113
    Height = 21
    AutoComplete = False
    ItemIndex = 3
    TabOrder = 2
    Text = '150'
    OnChange = CbDBJpegqualityChange
    Items.Strings = (
      '50'
      '75'
      '100'
      '150'
      '200'
      '300')
  end
  object WlPreviewDBJpegQuality: TWebLink
    Left = 124
    Top = 211
    Width = 141
    Height = 16
    Cursor = crHandPoint
    Text = 'WlPreviewDBJpegQuality'
    OnClick = WlPreviewDBSizeClick
    ImageIndex = 0
    IconWidth = 16
    IconHeight = 16
    UseEnterColor = False
    EnterColor = clBlack
    EnterBould = False
    TopIconIncrement = 0
    UseSpecIconSize = True
    HightliteImage = False
    StretchImage = True
    CanClick = True
  end
  object WlPanelSize: TWebLink
    Left = 124
    Top = 260
    Width = 78
    Height = 16
    Cursor = crHandPoint
    Text = 'WlPanelSize'
    OnClick = WlPanelSizeClick
    ImageIndex = 0
    IconWidth = 16
    IconHeight = 16
    UseEnterColor = False
    EnterColor = clBlack
    EnterBould = False
    TopIconIncrement = 0
    UseSpecIconSize = True
    HightliteImage = False
    StretchImage = True
    CanClick = True
  end
  object CbPanelSize: TComboBox
    Left = 5
    Top = 257
    Width = 113
    Height = 21
    AutoComplete = False
    ItemIndex = 3
    TabOrder = 5
    Text = '150'
    OnChange = CbPanelSizeChange
    Items.Strings = (
      '50'
      '75'
      '100'
      '150'
      '200'
      '300')
  end
  object CbPreviewSize: TComboBox
    Left = 6
    Top = 303
    Width = 113
    Height = 21
    AutoComplete = False
    ItemIndex = 3
    TabOrder = 6
    Text = '150'
    OnChange = CbPreviewSizeChange
    Items.Strings = (
      '50'
      '75'
      '100'
      '150'
      '200'
      '300')
  end
  object WlPreviewSize: TWebLink
    Left = 124
    Top = 306
    Width = 90
    Height = 16
    Cursor = crHandPoint
    Text = 'WlPreviewSize'
    OnClick = WlPreviewSizeClick
    ImageIndex = 0
    IconWidth = 16
    IconHeight = 16
    UseEnterColor = False
    EnterColor = clBlack
    EnterBould = False
    TopIconIncrement = 0
    UseSpecIconSize = True
    HightliteImage = False
    StretchImage = True
    CanClick = True
  end
end
