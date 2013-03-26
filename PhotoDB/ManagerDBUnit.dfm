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
  Font.Name = 'Tahoma'
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
      Height = 168
      Align = alTop
      TabOrder = 0
      object Label7: TLabel
        Left = 256
        Top = 8
        Width = 77
        Height = 13
        Caption = 'GoToRecord ID:'
      end
      object Label11: TLabel
        Left = 448
        Top = 4
        Width = 44
        Height = 13
        Caption = 'BackUps:'
      end
      object RecordNumberEdit: TEdit
        Left = 256
        Top = 23
        Width = 177
        Height = 21
        TabOrder = 0
        Text = '1'
        OnChange = RecordNumberEditChange
      end
      object LbBackups: TListBox
        Left = 448
        Top = 23
        Width = 177
        Height = 137
        Style = lbOwnerDrawFixed
        ItemHeight = 20
        TabOrder = 1
        OnContextPopup = LbBackupsContextPopup
        OnDrawItem = LbBackupsDrawItem
      end
      object PackTabelLink: TWebLink
        Left = 8
        Top = 8
        Width = 72
        Height = 16
        Cursor = crHandPoint
        Text = 'Pack Table'
        OnClick = PackTabelLinkClick
        ImageIndex = 0
        UseEnterColor = False
        EnterColor = clBlack
        EnterBould = False
        TopIconIncrement = 0
        UseSpecIconSize = True
        HightliteImage = False
        StretchImage = True
        CanClick = True
      end
      object RecreateIDExLink: TWebLink
        Left = 8
        Top = 30
        Width = 91
        Height = 16
        Cursor = crHandPoint
        Text = 'Recreate IDEx'
        OnClick = RecreateIDExLinkClick
        ImageIndex = 0
        UseEnterColor = False
        EnterColor = clBlack
        EnterBould = False
        TopIconIncrement = 0
        UseSpecIconSize = True
        HightliteImage = False
        StretchImage = True
        CanClick = True
      end
      object ScanforBadLinksLink: TWebLink
        Left = 8
        Top = 52
        Width = 108
        Height = 16
        Cursor = crHandPoint
        Text = 'Scan for Bad Links'
        OnClick = ScanforBadLinksLinkClick
        ImageIndex = 0
        UseEnterColor = False
        EnterColor = clBlack
        EnterBould = False
        TopIconIncrement = 0
        UseSpecIconSize = True
        HightliteImage = False
        StretchImage = True
        CanClick = True
      end
      object BackUpDBLink: TWebLink
        Left = 8
        Top = 74
        Width = 72
        Height = 16
        Cursor = crHandPoint
        Text = 'BackUp DB'
        OnClick = BackUpDBLinkClick
        ImageIndex = 0
        UseEnterColor = False
        EnterColor = clBlack
        EnterBould = False
        TopIconIncrement = 0
        UseSpecIconSize = True
        HightliteImage = False
        StretchImage = True
        CanClick = True
      end
      object DuplicatesLink: TWebLink
        Left = 8
        Top = 118
        Width = 122
        Height = 16
        Cursor = crHandPoint
        Text = 'Optimizing Duplicates'
        OnClick = DuplicatesLinkClick
        ImageIndex = 0
        UseEnterColor = False
        EnterColor = clBlack
        EnterBould = False
        TopIconIncrement = 0
        UseSpecIconSize = True
        HightliteImage = False
        StretchImage = True
        CanClick = True
      end
      object ConvertLink: TWebLink
        Left = 8
        Top = 96
        Width = 76
        Height = 16
        Cursor = crHandPoint
        Text = 'Convert DB'
        OnClick = ConvertLinkClick
        ImageIndex = 0
        UseEnterColor = False
        EnterColor = clBlack
        EnterBould = False
        TopIconIncrement = 0
        UseSpecIconSize = True
        HightliteImage = False
        StretchImage = True
        CanClick = True
      end
      object ChangePathLink: TWebLink
        Left = 8
        Top = 140
        Width = 206
        Height = 16
        Cursor = crHandPoint
        Text = 'Change Path in DB (if files was moved)'
        OnClick = ChangePathLinkClick
        ImageIndex = 0
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
    object ElvMain: TListView
      Left = 1
      Top = 169
      Width = 888
      Height = 446
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
      ExplicitTop = 217
      ExplicitHeight = 398
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
  object PopupMenu1: TPopupActionBar
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
  object PopupMenu2: TPopupActionBar
    Left = 249
    Top = 232
    object Dateexists1: TMenuItem
      Caption = 'Date not exists'
    end
  end
  object PmEdiGroups: TPopupActionBar
    Left = 281
    Top = 232
    object EditGroups1: TMenuItem
      Caption = 'Edit Groups'
    end
    object GroupsManager1: TMenuItem
      Caption = 'Groups Manager'
    end
  end
  object PopupMenu4: TPopupActionBar
    Left = 361
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
    ColorDepth = cd32Bit
    Left = 217
    Top = 288
  end
  object GroupsImageList: TImageList
    ColorDepth = cd32Bit
    Left = 249
    Top = 288
  end
  object PmRestoreDB: TPopupActionBar
    Left = 682
    Top = 41
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
  object PopupMenu6: TPopupActionBar
    Left = 329
    Top = 288
    object Timenotexists1: TMenuItem
      Caption = 'Time not exists'
    end
  end
  object PopupMenu7: TPopupActionBar
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
    ColorDepth = cd32Bit
    Height = 18
    Left = 280
    Top = 416
  end
  object PopupMenuRating: TPopupActionBar
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
  object PopupMenuKeyWords: TPopupActionBar
    Left = 432
    Top = 496
  end
  object PopupMenuRotate: TPopupActionBar
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
  object PopupMenuGroups: TPopupActionBar
    Images = ImageListPopupGroups
    Left = 496
    Top = 496
  end
  object ImageListPopupGroups: TImageList
    ColorDepth = cd32Bit
    Left = 536
    Top = 496
  end
  object PopupMenuDate: TPopupActionBar
    Left = 569
    Top = 496
  end
  object PopupMenuFile: TPopupActionBar
    Left = 601
    Top = 496
  end
end
