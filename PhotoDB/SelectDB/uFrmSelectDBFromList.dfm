inherited FrmSelectDBFromList: TFrmSelectDBFromList
  Width = 480
  Height = 361
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  ExplicitWidth = 480
  ExplicitHeight = 361
  object GbMain: TGroupBox
    Left = 0
    Top = 0
    Width = 480
    Height = 121
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Select DB'
    TabOrder = 0
    DesignSize = (
      480
      121)
    object LbSelectFromList: TLabel
      Left = 8
      Top = 24
      Width = 90
      Height = 13
      Caption = 'Select DB from list:'
    end
    object LbFileName: TLabel
      Left = 8
      Top = 72
      Width = 47
      Height = 13
      Caption = 'FileName:'
    end
    object CbDBList: TComboBoxExDB
      Left = 8
      Top = 40
      Width = 464
      Height = 22
      ItemsEx = <>
      Style = csExDropDownList
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      OnChange = CbDBListChange
      ShowDropDownMenu = True
      LastItemIndex = 0
      ShowEditIndex = -1
      HideItemIcons = False
      CanClickIcon = False
    end
    object SelectDBFileNameEdit: TEdit
      Left = 8
      Top = 88
      Width = 464
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      ReadOnly = True
      TabOrder = 1
    end
  end
  object CbDefaultDB: TCheckBox
    Left = 8
    Top = 128
    Width = 469
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Use as DB by default'
    TabOrder = 1
  end
  object DBImageList: TImageList
    Left = 40
    Top = 200
  end
end
