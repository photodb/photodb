inherited FrmCreatePNGSteno: TFrmCreatePNGSteno
  Width = 447
  Height = 304
  Anchors = [akLeft, akTop, akRight]
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  ExplicitWidth = 447
  ExplicitHeight = 304
  object LbImageSize: TLabel
    Left = 3
    Top = 194
    Width = 110
    Height = 13
    Caption = 'ImageSize: 100x100px'
  end
  object LbJpegFileSize: TLabel
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
  object LbResultImageSize: TLabel
    Left = 3
    Top = 283
    Width = 104
    Height = 13
    Caption = 'Result file size: 200kb'
  end
  object Gbptions: TGroupBox
    Left = 156
    Top = 3
    Width = 281
    Height = 228
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Options:'
    TabOrder = 0
    DesignSize = (
      281
      228)
    object LbPassword: TLabel
      Left = 12
      Top = 112
      Width = 50
      Height = 13
      Caption = 'Password:'
    end
    object Label1: TLabel
      Left = 12
      Top = 158
      Width = 88
      Height = 13
      Caption = 'Password confirm:'
    end
    object Label2: TLabel
      Left = 12
      Top = 20
      Width = 50
      Height = 13
      Caption = 'Password:'
    end
    object CbEncryptdata: TCheckBox
      Left = 12
      Top = 89
      Width = 260
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Encrypt data'
      TabOrder = 0
    end
    object EdPassword: TWatermarkedEdit
      Left = 12
      Top = 131
      Width = 260
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
      WatermarkText = 'Password'
    end
    object EdPasswordConfirm: TWatermarkedEdit
      Left = 12
      Top = 177
      Width = 260
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
      WatermarkText = 'Password confirm'
    end
    object CbIncludeCRC: TCheckBox
      Left = 12
      Top = 66
      Width = 260
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
      Width = 262
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
      ExplicitWidth = 260
    end
  end
  object EdDataFileName: TWatermarkedEdit
    Left = 0
    Top = 237
    Width = 417
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = 11206655
    ReadOnly = True
    TabOrder = 1
    WatermarkText = 'Please select a file'
  end
  object BtnChooseFile: TButton
    Left = 417
    Top = 237
    Width = 20
    Height = 21
    Anchors = [akTop, akRight]
    Caption = '...'
    TabOrder = 2
    OnClick = BtnChooseFileClick
  end
  object OpenDialog1: TOpenDialog
    Filter = 'All Files (*.*)|*?*'
    Options = [ofHideReadOnly, ofEnableIncludeNotify, ofEnableSizing]
    OnIncludeItem = OpenDialog1IncludeItem
    Left = 24
    Top = 32
  end
end
