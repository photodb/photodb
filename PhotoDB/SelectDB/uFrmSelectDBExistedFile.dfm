inherited FrmSelectDBExistedFile: TFrmSelectDBExistedFile
  Width = 480
  Height = 361
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  ExplicitWidth = 480
  ExplicitHeight = 361
  object GroupBox3: TGroupBox
    Left = 0
    Top = 0
    Width = 480
    Height = 297
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Select file on hard disk'
    TabOrder = 0
    DesignSize = (
      480
      297)
    object LbName: TLabel
      Left = 8
      Top = 24
      Width = 49
      Height = 13
      Caption = 'File name:'
    end
    object LbDBType: TLabel
      Left = 8
      Top = 72
      Width = 45
      Height = 13
      Caption = 'File type:'
    end
    object LbIconPreview: TLabel
      Left = 8
      Top = 120
      Width = 62
      Height = 13
      Caption = 'Icon preview'
    end
    object ImageIconPreview: TImage
      Left = 8
      Top = 136
      Width = 16
      Height = 16
    end
    object LbDisplayName: TLabel
      Left = 8
      Top = 200
      Width = 72
      Height = 13
      Caption = 'Internal Name:'
    end
    object EdFileName: TWatermarkedEdit
      Left = 8
      Top = 40
      Width = 368
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Color = 11206655
      ReadOnly = True
      TabOrder = 0
      OnDblClick = BtnSelectFileClick
    end
    object EdDBType: TWatermarkedEdit
      Left = 8
      Top = 88
      Width = 464
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      ReadOnly = True
      TabOrder = 1
    end
    object BtnChooseIcon: TButton
      Left = 8
      Top = 160
      Width = 225
      Height = 25
      Caption = 'Browse icon'
      TabOrder = 3
      OnClick = BtnChooseIconClick
    end
    object BtnChangeDBOptions: TButton
      Left = 8
      Top = 248
      Width = 225
      Height = 25
      Caption = 'Change DB Options'
      TabOrder = 5
      OnClick = BtnChangeDBOptionsClick
    end
    object BtnSelectFile: TButton
      Left = 383
      Top = 40
      Width = 89
      Height = 21
      Anchors = [akTop, akRight]
      Caption = 'Select'
      TabOrder = 2
      OnClick = BtnSelectFileClick
    end
    object WlDBOptions: TWebLink
      Left = 8
      Top = 276
      Width = 217
      Height = 13
      Cursor = crHandPoint
      Text = 'To convert DB to other format press this link'
      OnClick = WlDBOptionsClick
      ImageIndex = 0
      IconWidth = 0
      IconHeight = 0
      UseEnterColor = False
      EnterColor = clBlack
      EnterBould = False
      TopIconIncrement = 0
      ImageCanRegenerate = True
      UseSpecIconSize = True
      HightliteImage = False
      StretchImage = True
      CanClick = True
    end
    object EdInternalName: TWatermarkedEdit
      Left = 8
      Top = 216
      Width = 464
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 4
      Text = 'EdInternalName'
      OnChange = EdInternalNameChange
    end
  end
end
