inherited FrmImportImagesLanding: TFrmImportImagesLanding
  Width = 300
  Height = 273
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  ExplicitWidth = 300
  ExplicitHeight = 273
  object LbLandingInfo: TLabel
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
  object LvPlaces: TListView
    Left = 8
    Top = 112
    Width = 284
    Height = 150
    Anchors = [akLeft, akTop, akRight]
    Columns = <
      item
        Caption = 'Folders'
        Width = 250
      end>
    ReadOnly = True
    SmallImages = PlacesImageList
    TabOrder = 0
    ViewStyle = vsReport
    OnContextPopup = LvPlacesContextPopup
  end
  object BtnAddFolder: TButton
    Left = 8
    Top = 80
    Width = 97
    Height = 25
    Caption = 'Add Folder'
    TabOrder = 1
    OnClick = BtnAddFolderClick
  end
  object BtnRemoveFolder: TButton
    Left = 112
    Top = 80
    Width = 75
    Height = 25
    Caption = 'Remove'
    TabOrder = 2
    OnClick = BtnRemoveFolderClick
  end
  object PmDeleteItem: TPopupMenu
    Left = 128
    Top = 168
    object DeleteItem1: TMenuItem
      Caption = 'Delete Item'
      OnClick = BtnRemoveFolderClick
    end
  end
  object PlacesImageList: TImageList
    Left = 48
    Top = 168
  end
end
