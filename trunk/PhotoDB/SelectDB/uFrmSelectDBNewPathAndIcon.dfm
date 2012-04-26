inherited FrmSelectDBNewPathAndIcon: TFrmSelectDBNewPathAndIcon
  Width = 480
  Height = 361
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  OnDblClick = BtnSelectFileClick
  ExplicitWidth = 480
  ExplicitHeight = 361
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 480
    Height = 294
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Name and location'
    TabOrder = 0
    DesignSize = (
      480
      294)
    object ImageIconPreview: TImage
      Left = 8
      Top = 136
      Width = 16
      Height = 16
    end
    object LbIconPreview: TLabel
      Left = 8
      Top = 120
      Width = 62
      Height = 13
      Caption = 'Icon preview'
    end
    object LbNewDBFile: TLabel
      Left = 8
      Top = 72
      Width = 97
      Height = 13
      Caption = 'Select Path new DB:'
    end
    object LbNewDBName: TLabel
      Left = 8
      Top = 24
      Width = 112
      Height = 13
      Caption = 'Enter Name of new DB:'
    end
    object LbDBDescription: TLabel
      Left = 8
      Top = 192
      Width = 73
      Height = 13
      Caption = 'DB Description:'
    end
    object BtnChooseIcon: TButton
      Left = 3
      Top = 158
      Width = 113
      Height = 25
      Caption = 'Browse icon'
      TabOrder = 3
      OnClick = BtnChooseIconClick
    end
    object EdPath: TWatermarkedEdit
      Left = 8
      Top = 88
      Width = 360
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Color = 11206655
      TabOrder = 0
      OnChange = EdPathChange
      OnDblClick = BtnSelectFileClick
    end
    object EdName: TWatermarkedEdit
      Left = 8
      Top = 40
      Width = 464
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Color = 11206655
      TabOrder = 1
      OnChange = EdNameChange
    end
    object BtnSelectFile: TButton
      Left = 375
      Top = 88
      Width = 97
      Height = 21
      Anchors = [akTop, akRight]
      Caption = 'Select'
      TabOrder = 2
      OnClick = BtnSelectFileClick
    end
    object EdDBDescription: TWatermarkedEdit
      Left = 8
      Top = 208
      Width = 464
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 4
    end
    object CbSetAsDefaultDB: TCheckBox
      Left = 13
      Top = 235
      Width = 464
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Use as default DB'
      Checked = True
      State = cbChecked
      TabOrder = 5
    end
    object CbAddDefaultGroups: TCheckBox
      Left = 13
      Top = 258
      Width = 464
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Add default groups'
      Checked = True
      State = cbChecked
      TabOrder = 6
    end
  end
end
