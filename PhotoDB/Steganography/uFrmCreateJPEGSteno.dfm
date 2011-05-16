inherited FrmCreateJPEGSteno: TFrmCreateJPEGSteno
  Width = 487
  Height = 304
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  ExplicitWidth = 487
  ExplicitHeight = 304
  object ImJpegFile: TImage
    Left = 0
    Top = 19
    Width = 150
    Height = 150
    Center = True
    OnContextPopup = ImJpegFileContextPopup
  end
  object LbJpegFileInfo: TLabel
    Left = 0
    Top = 3
    Width = 43
    Height = 13
    Caption = 'JpegFile:'
  end
  object LbJpegFileSize: TLabel
    Left = 3
    Top = 175
    Width = 71
    Height = 13
    Caption = 'FileSize: 100kb'
  end
  object LbImageSize: TLabel
    Left = 3
    Top = 194
    Width = 110
    Height = 13
    Caption = 'ImageSize: 100x100px'
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
  object EdDataFileName: TWatermarkedEdit
    Left = 0
    Top = 237
    Width = 457
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = 11206655
    TabOrder = 0
    WatermarkText = 'Please select a file'
    ExplicitWidth = 417
  end
  object BtnChooseFile: TButton
    Left = 457
    Top = 237
    Width = 20
    Height = 21
    Anchors = [akTop, akRight]
    Caption = '...'
    TabOrder = 1
    OnClick = BtnChooseFileClick
    ExplicitLeft = 417
  end
  object GbOptions: TGroupBox
    Left = 168
    Top = 3
    Width = 309
    Height = 228
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Options:'
    TabOrder = 2
    ExplicitWidth = 269
    DesignSize = (
      309
      228)
    object LbPassword: TLabel
      Left = 12
      Top = 68
      Width = 50
      Height = 13
      Caption = 'Password:'
    end
    object LbPasswordConfirm: TLabel
      Left = 12
      Top = 114
      Width = 88
      Height = 13
      Caption = 'Password confirm:'
    end
    object CbEncryptdata: TCheckBox
      Left = 12
      Top = 45
      Width = 288
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Encrypt data'
      TabOrder = 0
      OnClick = CbEncryptdataClick
      ExplicitWidth = 260
    end
    object EdPassword: TWatermarkedEdit
      Left = 12
      Top = 87
      Width = 288
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Enabled = False
      TabOrder = 1
      WatermarkText = 'Password'
      ExplicitWidth = 260
    end
    object EdPasswordConfirm: TWatermarkedEdit
      Left = 12
      Top = 133
      Width = 288
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Enabled = False
      TabOrder = 2
      WatermarkText = 'Password confirm'
      ExplicitWidth = 260
    end
    object CbIncludeCRC: TCheckBox
      Left = 12
      Top = 22
      Width = 288
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Add control sum (CRC)'
      Checked = True
      State = cbChecked
      TabOrder = 3
      ExplicitWidth = 260
    end
    object WblMethod: TWebLink
      Left = 12
      Top = 160
      Width = 68
      Height = 13
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
      ImageCanRegenerate = True
      UseSpecIconSize = True
      HightliteImage = False
    end
  end
  object PmCryptMethod: TPopupMenu
    Left = 280
    Top = 168
  end
end
