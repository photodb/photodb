inherited FrmCreatePNGSteno: TFrmCreatePNGSteno
  Width = 487
  Height = 304
  Anchors = [akLeft, akTop, akRight]
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  ExplicitWidth = 487
  ExplicitHeight = 304
  object LbImageSize: TLabel
    Left = 3
    Top = 194
    Width = 110
    Height = 13
    Caption = 'ImageSize: 100x100px'
    Visible = False
  end
  object LbImageFileSize: TLabel
    Left = 3
    Top = 175
    Width = 71
    Height = 13
    Caption = 'FileSize: 100kb'
  end
  object ImImageFile: TImage
    Left = 0
    Top = 19
    Width = 150
    Height = 150
    Center = True
    OnContextPopup = ImImageFileContextPopup
  end
  object LbImageFileInfo: TLabel
    Left = 0
    Top = 3
    Width = 50
    Height = 13
    Caption = 'ImageFile:'
  end
  object LbSelectFile: TLabel
    Left = 3
    Top = 218
    Width = 56
    Height = 13
    Caption = 'File to hide:'
  end
  object LbFileSize: TLabel
    Left = 3
    Top = 264
    Width = 73
    Height = 13
    Caption = 'File size: 100kb'
  end
  object GbOptions: TGroupBox
    Left = 168
    Top = 3
    Width = 309
    Height = 228
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Options'
    TabOrder = 0
    DesignSize = (
      309
      228)
    object LbPassword: TLabel
      Left = 12
      Top = 112
      Width = 50
      Height = 13
      Caption = 'Password:'
    end
    object LbPasswordConfirm: TLabel
      Left = 12
      Top = 158
      Width = 88
      Height = 13
      Caption = 'Password confirm:'
    end
    object LbFilter: TLabel
      Left = 12
      Top = 20
      Width = 28
      Height = 13
      Caption = 'Filter:'
    end
    object CbEncryptdata: TCheckBox
      Left = 12
      Top = 89
      Width = 288
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Encrypt data'
      TabOrder = 0
      OnClick = CbEncryptdataClick
    end
    object EdPassword: TWatermarkedEdit
      Left = 12
      Top = 131
      Width = 288
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Enabled = False
      PasswordChar = '*'
      TabOrder = 1
      WatermarkText = 'Password'
    end
    object EdPasswordConfirm: TWatermarkedEdit
      Left = 12
      Top = 177
      Width = 288
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Enabled = False
      PasswordChar = '*'
      TabOrder = 2
      WatermarkText = 'Password confirm'
    end
    object CbIncludeCRC: TCheckBox
      Left = 12
      Top = 66
      Width = 288
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Add control sum (CRC)'
      Checked = True
      State = cbChecked
      TabOrder = 3
    end
    object CbFilter: TComboBox
      Left = 12
      Top = 39
      Width = 290
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      ItemIndex = 1
      TabOrder = 4
      Text = 'Normal Size (Recomended)'
      Items.Strings = (
        'MaxSize (Minimal quality)'
        'Normal Size (Recomended)'
        'Good Size (Best)')
    end
    object WblMethod: TWebLink
      Left = 12
      Top = 204
      Width = 84
      Height = 16
      Cursor = crHandPoint
      Enabled = False
      Text = 'BlowFish - 56'
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
  object EdDataFileName: TWatermarkedEdit
    Left = 0
    Top = 237
    Width = 457
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = 11206655
    ReadOnly = True
    TabOrder = 1
    OnDblClick = BtnChooseFileClick
    WatermarkText = 'Please select a file'
  end
  object BtnChooseFile: TButton
    Left = 457
    Top = 237
    Width = 20
    Height = 21
    Anchors = [akTop, akRight]
    Caption = '...'
    TabOrder = 2
    OnClick = BtnChooseFileClick
  end
  object LsImage: TLoadingSign
    Left = 50
    Top = 65
    Width = 49
    Height = 49
    Active = True
    FillPercent = 70
    SignColor = clBlack
    MaxTransparencity = 255
  end
  object OpenDialog1: TOpenDialog
    Filter = 'All Files (*.*)|*?*'
    Options = [ofHideReadOnly, ofEnableIncludeNotify, ofEnableSizing]
    OnIncludeItem = OpenDialog1IncludeItem
    Left = 24
    Top = 32
  end
  object PmCryptMethod: TPopupActionBar
    Left = 280
    Top = 192
  end
end
