object ManagerDB: TManagerDB
  Left = 240
  Top = 328
  Caption = 'ManagerDB'
  ClientHeight = 616
  ClientWidth = 890
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 890
    Height = 616
    Align = alClient
    TabOrder = 0
    object PnTop: TPanel
      Left = 1
      Top = 1
      Width = 888
      Height = 216
      Align = alTop
      TabOrder = 0
      object Label7: TLabel
        Left = 656
        Top = 4
        Width = 79
        Height = 13
        Caption = 'GoToRecord ID:'
      end
      object Label9: TLabel
        Left = 360
        Top = 8
        Width = 6
        Height = 13
        Caption = '='
      end
      object Label10: TLabel
        Left = 212
        Top = 56
        Width = 32
        Height = 13
        Caption = 'Where'
      end
      object Label11: TLabel
        Left = 656
        Top = 45
        Width = 47
        Height = 13
        Caption = 'BackUps:'
      end
      object CbSetField: TComboBox
        Left = 296
        Top = 8
        Width = 65
        Height = 21
        Style = csDropDownList
        ParentColor = True
        TabOrder = 0
        OnChange = ComboBox1Change
        Items.Strings = (
          'Rating'
          'Rotate'
          'Access'
          'Width'
          'Height'
          'Attributes'
          'Name'
          'FFileName'
          'Comment'
          'KeyWords'
          'Owner'
          'Collection')
      end
      object Edit2: TEdit
        Left = 368
        Top = 8
        Width = 81
        Height = 21
        TabOrder = 1
        Text = '0'
      end
      object CbWhereField1: TComboBox
        Left = 212
        Top = 72
        Width = 89
        Height = 21
        Style = csDropDownList
        ParentColor = True
        TabOrder = 2
        OnChange = CbWhereField1Change
        Items.Strings = (
          'Rating'
          'Rotate'
          'Access'
          'Width'
          'Height'
          'Attributes'
          'Name'
          'FFileName'
          'Comment'
          'KeyWords'
          'Owner'
          'Collection')
      end
      object Edit3: TEdit
        Left = 360
        Top = 72
        Width = 89
        Height = 21
        TabOrder = 3
        Text = '0'
      end
      object BtnExecSQL: TButton
        Left = 212
        Top = 162
        Width = 237
        Height = 17
        Caption = 'Exes SQL'
        TabOrder = 4
        OnClick = BtnExecSQLClick
      end
      object CbWhereCombinator: TComboBox
        Left = 212
        Top = 96
        Width = 49
        Height = 21
        Style = csDropDownList
        ParentColor = True
        TabOrder = 5
        OnChange = CbWhereCombinatorChange
        Items.Strings = (
          'OR'
          'AND'
          ' ')
      end
      object Edit4: TEdit
        Left = 360
        Top = 128
        Width = 89
        Height = 21
        TabOrder = 6
        Text = '0'
      end
      object CbWhereField2: TComboBox
        Left = 212
        Top = 128
        Width = 89
        Height = 21
        Style = csDropDownList
        ParentColor = True
        TabOrder = 7
        OnChange = CbWhereField1Change
        Items.Strings = (
          'Rating'
          'Rotate'
          'Access'
          'Width'
          'Height'
          'Attributes'
          'Name'
          'FFileName'
          'Comment'
          'KeyWords'
          'Owner'
          'Collection')
      end
      object CbOperatorWhere1: TComboBox
        Left = 304
        Top = 72
        Width = 49
        Height = 21
        Style = csDropDownList
        ParentColor = True
        TabOrder = 8
        OnChange = CbOperatorWhere1Change
        Items.Strings = (
          '='
          '>'
          '<'
          '<>'
          'Like')
      end
      object CbOperatorWhere2: TComboBox
        Left = 304
        Top = 128
        Width = 49
        Height = 21
        Style = csDropDownList
        ParentColor = True
        TabOrder = 9
        OnChange = CbOperatorWhere1Change
        Items.Strings = (
          '='
          '>'
          '<'
          '<>'
          'Like')
      end
      object RbSQLSet: TRadioButton
        Left = 212
        Top = 8
        Width = 76
        Height = 17
        Caption = 'Set'
        Checked = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 10
        TabStop = True
        OnClick = RbSQLSetClick
      end
      object RbSQLDelete: TRadioButton
        Left = 212
        Top = 32
        Width = 237
        Height = 17
        Caption = 'Delete'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 11
        OnClick = RbSQLSetClick
      end
      object RecordNumberEdit: TEdit
        Left = 656
        Top = 19
        Width = 129
        Height = 21
        TabOrder = 12
        Text = '1'
        OnChange = RecordNumberEditChange
      end
      object LbBackups: TListBox
        Left = 656
        Top = 64
        Width = 129
        Height = 137
        Style = lbOwnerDrawFixed
        ItemHeight = 20
        TabOrder = 13
        OnContextPopup = LbBackupsContextPopup
        OnDrawItem = LbBackupsDrawItem
      end
      object PackTabelLink: TWebLink
        Left = 8
        Top = 8
        Width = 76
        Height = 16
        Cursor = crHandPoint
        Text = 'Pack Table'
        OnClick = PackTabelLinkClick
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
      object ExportTableLink: TWebLink
        Left = 8
        Top = 28
        Width = 81
        Height = 16
        Cursor = crHandPoint
        Text = 'Export Table'
        OnClick = ExportTableLinkClick
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
      object ImportTableLink: TWebLink
        Left = 8
        Top = 48
        Width = 80
        Height = 16
        Cursor = crHandPoint
        Text = 'Import Table'
        OnClick = ImportTableLinkClick
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
      object RecreateIDExLink: TWebLink
        Left = 8
        Top = 68
        Width = 91
        Height = 16
        Cursor = crHandPoint
        Text = 'Recreate IDEx'
        OnClick = RecreateIDExLinkClick
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
      object ScanforBadLinksLink: TWebLink
        Left = 8
        Top = 88
        Width = 111
        Height = 16
        Cursor = crHandPoint
        Text = 'Scan for Bad Links'
        OnClick = ScanforBadLinksLinkClick
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
      object BackUpDBLink: TWebLink
        Left = 8
        Top = 108
        Width = 78
        Height = 16
        Cursor = crHandPoint
        Text = 'BackUp DB'
        OnClick = BackUpDBLinkClick
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
      object CleaningLink: TWebLink
        Left = 8
        Top = 128
        Width = 62
        Height = 16
        Cursor = crHandPoint
        Text = 'Cleaning'
        OnClick = CleaningLinkClick
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
      object LbDatabases: TListBox
        Left = 456
        Top = 32
        Width = 193
        Height = 169
        Style = lbOwnerDrawFixed
        ItemHeight = 20
        TabOrder = 21
        OnContextPopup = LbDatabasesContextPopup
        OnDblClick = LbDatabasesDblClick
        OnDrawItem = LbDatabasesDrawItem
      end
      object BtnAddDB: TButton
        Left = 456
        Top = 8
        Width = 193
        Height = 17
        Caption = 'Add DB'
        TabOrder = 22
        OnClick = BtnAddDBClick
      end
      object DublicatesLink: TWebLink
        Left = 8
        Top = 168
        Width = 122
        Height = 16
        Cursor = crHandPoint
        Text = 'Optimizing Dublicates'
        OnClick = DublicatesLinkClick
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
      object ConvertLink: TWebLink
        Left = 8
        Top = 148
        Width = 76
        Height = 16
        Cursor = crHandPoint
        Text = 'Convert DB'
        OnClick = ConvertLinkClick
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
      object ChangePathLink: TWebLink
        Left = 8
        Top = 188
        Width = 204
        Height = 16
        Cursor = crHandPoint
        Text = 'Change Path in DB (if files was moved)'
        OnClick = ChangePathLinkClick
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
    object ElvMain: TListView
      Left = 1
      Top = 217
      Width = 888
      Height = 398
      Align = alClient
      Columns = <
        item
          Caption = 'ID'
          MinWidth = 10
        end
        item
          Caption = 'File'
          MinWidth = 10
          Width = 220
        end
        item
          Caption = 'KeyWords'
          MinWidth = 10
          Width = 100
        end
        item
          Caption = 'Comment'
          MinWidth = 10
          Width = 100
        end
        item
          Caption = 'Rating'
          MinWidth = 10
          Width = 60
        end
        item
          Caption = 'Rotate'
          MinWidth = 10
          Width = 60
        end
        item
          Caption = 'Access'
          MinWidth = 10
          Width = 60
        end
        item
          Caption = 'Groups'
          MaxWidth = 110
          MinWidth = 110
          Width = 110
        end
        item
          Caption = 'Date'
          MinWidth = 10
          Width = 70
        end
        item
          Caption = 'Time'
          MinWidth = 10
        end
        item
          Caption = 'Size'
          MinWidth = 10
          Width = 60
        end>
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      HideSelection = False
      LargeImages = ImlMain
      OwnerData = True
      ParentFont = False
      SmallImages = ImlMain
      StateImages = ImlMain
      TabOrder = 1
      ViewStyle = vsReport
      OnAdvancedCustomDrawSubItem = ElvMainAdvancedCustomDrawSubItem
      OnContextPopup = ElvMainContextPopup
      OnData = ElvMainData
      OnMouseMove = ElvMainMouseMove
      OnResize = ElvMainResize
      OnSelectItem = ElvMainSelectItem
    end
    object dblData: TDBLoading
      Left = 397
      Top = 368
      Width = 63
      Height = 64
      LineColor = clBlack
      Active = False
      OnDrawBackground = dblDataDrawBackground
    end
    object LsLoadingDB: TLoadingSign
      Left = 3
      Top = 240
      Width = 16
      Height = 16
      Visible = False
      Active = True
      FillPercent = 50
      Color = clBtnFace
      ParentColor = False
      SignColor = clBlack
      MaxTransparencity = 255
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 184
    Top = 232
  end
  object SaveWindowPos1: TSaveWindowPos
    SetOnlyPosition = False
    RootKey = HKEY_CURRENT_USER
    Key = 'Software\Positions\Noname'
    Left = 217
    Top = 232
  end
  object PopupMenu2: TPopupMenu
    Left = 249
    Top = 232
    object Dateexists1: TMenuItem
      Caption = 'Date not exists'
    end
  end
  object PmEdiGroups: TPopupMenu
    Left = 281
    Top = 232
    object EditGroups1: TMenuItem
      Caption = 'Edit Groups'
    end
    object GroupsManager1: TMenuItem
      Caption = 'Groups Manager'
      OnClick = GroupsManager1Click
    end
  end
  object PopupMenu4: TPopupMenu
    Left = 313
    Top = 232
    object DateExists2: TMenuItem
      Caption = 'DateExists'
    end
  end
  object DropFileSource1: TDropFileSource
    DragTypes = [dtCopy, dtLink]
    Images = DragImageList
    ShowImage = True
    Left = 153
    Top = 288
  end
  object DropFileTarget1: TDropFileTarget
    DragTypes = []
    OptimizedMove = True
    Left = 185
    Top = 288
  end
  object DragImageList: TImageList
    Left = 217
    Top = 288
  end
  object GroupsImageList: TImageList
    Left = 249
    Top = 288
  end
  object PopupMenu5: TPopupMenu
    Left = 722
    Top = 129
    object Restore1: TMenuItem
      Caption = 'Restore'
      OnClick = Restore1Click
    end
    object Rename1: TMenuItem
      Caption = 'Rename'
      OnClick = Rename1Click
    end
    object Delete1: TMenuItem
      Caption = 'Delete'
      OnClick = Delete1Click
    end
    object Refresh1: TMenuItem
      Caption = 'Refresh'
      OnClick = Refresh1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object Showfileinexplorer1: TMenuItem
      Caption = 'Show file in explorer'
      OnClick = Showfileinexplorer1Click
    end
  end
  object PopupMenu6: TPopupMenu
    Left = 329
    Top = 288
    object Timenotexists1: TMenuItem
      Caption = 'Time not exists'
    end
  end
  object PopupMenu7: TPopupMenu
    Left = 401
    Top = 288
    object TimeExists1: TMenuItem
      Caption = 'Time Exists'
    end
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 248
    Top = 416
  end
  object ImlMain: TImageList
    Height = 18
    Left = 280
    Top = 416
  end
  object PopupMenuRating: TPopupMenu
    Left = 400
    Top = 496
    object N01: TMenuItem
      Caption = '0'
      ImageIndex = 0
      OnClick = N51Click
    end
    object N11: TMenuItem
      Caption = '1'
      ImageIndex = 0
      OnClick = N51Click
    end
    object N21: TMenuItem
      Caption = '2'
      ImageIndex = 0
      OnClick = N51Click
    end
    object N31: TMenuItem
      Caption = '3'
      ImageIndex = 0
      OnClick = N51Click
    end
    object N41: TMenuItem
      Caption = '4'
      ImageIndex = 0
      OnClick = N51Click
    end
    object N51: TMenuItem
      Caption = '5'
      ImageIndex = 0
      OnClick = N51Click
    end
  end
  object PopupMenuKeyWords: TPopupMenu
    Left = 432
    Top = 496
  end
  object PopupMenuRotate: TPopupMenu
    Left = 464
    Top = 496
    object R01: TMenuItem
      Caption = '0*'
      ImageIndex = 0
      OnClick = R04Click
    end
    object R02: TMenuItem
      Tag = 1
      Caption = '90* CW'
      ImageIndex = 0
      OnClick = R04Click
    end
    object R03: TMenuItem
      Tag = 2
      Caption = '180*'
      ImageIndex = 0
      OnClick = R04Click
    end
    object R04: TMenuItem
      Tag = 3
      Caption = '90* CCW'
      ImageIndex = 0
      OnClick = R04Click
    end
  end
  object PopupMenuGroups: TPopupMenu
    Images = ImageListPopupGroups
    Left = 496
    Top = 496
  end
  object ImageListPopupGroups: TImageList
    Left = 536
    Top = 496
  end
  object PopupMenuDate: TPopupMenu
    Left = 569
    Top = 496
  end
  object PopupMenuFile: TPopupMenu
    Left = 601
    Top = 496
  end
  object DBImageList: TImageList
    BkColor = clWindow
    Left = 497
    Top = 129
  end
  object PmRestore: TPopupMenu
    Left = 561
    Top = 129
    object SelectDB1: TMenuItem
      Caption = 'SelectDB'
      OnClick = SelectDB1Click
    end
    object RenameDB1: TMenuItem
      Caption = 'Rename DB'
      OnClick = RenameDB1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object EditDB1: TMenuItem
      Caption = 'Edit DB'
      OnClick = EditDB1Click
    end
    object DeleteDB1: TMenuItem
      Caption = 'Delete DB'
      OnClick = DeleteDB1Click
    end
  end
end
