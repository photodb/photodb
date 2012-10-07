object OptionsForm: TOptionsForm
  Left = 231
  Top = 219
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Options'
  ClientHeight = 488
  ClientWidth = 563
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PrintScale = poNone
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    563
    488)
  PixelsPerInch = 96
  TextHeight = 13
  object CancelButton: TButton
    Left = 399
    Top = 455
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 0
    OnClick = CancelButtonClick
  end
  object OkButton: TButton
    Left = 480
    Top = 455
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    TabOrder = 1
    OnClick = OkButtonClick
  end
  object PcMain: TPageControl
    Left = 8
    Top = 8
    Width = 548
    Height = 441
    ActivePage = TsStyle
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
    OnChange = PcMainChange
    object TsStyle: TTabSheet
      Caption = 'Style'
      ImageIndex = 6
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        540
        413)
      object LbAvailableTemes: TLabel
        Left = 3
        Top = 13
        Width = 85
        Height = 13
        Caption = 'LbAvailableTemes'
      end
      object ImStylePreview: TImage
        Left = 176
        Top = 32
        Width = 361
        Height = 297
        Anchors = [akLeft, akTop, akRight, akBottom]
        Transparent = True
        ExplicitWidth = 318
      end
      object LbThemePreview: TLabel
        Left = 176
        Top = 13
        Width = 81
        Height = 13
        Caption = 'LbThemePreview'
      end
      object LbStyles: TListBox
        Left = 3
        Top = 32
        Width = 167
        Height = 297
        Anchors = [akLeft, akTop, akBottom]
        ItemHeight = 13
        TabOrder = 0
        OnClick = LbStylesClick
      end
      object BtnApplyTheme: TButton
        Left = 3
        Top = 335
        Width = 167
        Height = 25
        Anchors = [akLeft, akBottom]
        Caption = 'BtnApplyTheme'
        TabOrder = 1
        OnClick = BtnApplyThemeClick
      end
      object WlGetMoreStyles: TWebLink
        Left = 450
        Top = 397
        Width = 82
        Height = 13
        Cursor = crHandPoint
        Anchors = [akRight, akBottom]
        Text = 'WlGetMoreStyles'
        OnClick = WlGetMoreStylesClick
        ImageIndex = 0
        IconWidth = 0
        IconHeight = 0
        UseEnterColor = False
        EnterColor = clBlack
        EnterBould = False
        TopIconIncrement = 0
        UseSpecIconSize = True
        HightliteImage = False
        StretchImage = False
        CanClick = True
      end
      object BtnShowThemesFolder: TButton
        Left = 176
        Top = 335
        Width = 361
        Height = 25
        Anchors = [akLeft, akRight, akBottom]
        Caption = 'BtnShowThemesFolder'
        TabOrder = 3
        OnClick = BtnShowThemesFolderClick
      end
    end
    object TsAssociations: TTabSheet
      Caption = 'Associations'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        540
        413)
      object LblSkipExt: TLabel
        Left = 282
        Top = 121
        Width = 251
        Height = 40
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = '- File extension ignored'
        WordWrap = True
        ExplicitWidth = 174
      end
      object LblAddSubmenuItem: TLabel
        Left = 282
        Top = 77
        Width = 251
        Height = 38
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = '- File option will added for this file type'
        WordWrap = True
        ExplicitWidth = 174
      end
      object LblUseExt: TLabel
        Left = 282
        Top = 34
        Width = 251
        Height = 40
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = '- File will open with this Program'
        WordWrap = True
        ExplicitWidth = 174
      end
      object Bevel2: TBevel
        Left = 6
        Top = 382
        Width = 426
        Height = 9
        Anchors = [akLeft, akBottom]
        Shape = bsTopLine
      end
      object LbShellExtensions: TStaticText
        Left = 3
        Top = 11
        Width = 85
        Height = 17
        Caption = 'Shell Extensions:'
        TabOrder = 0
      end
      object CbExtensionList: TCheckListBox
        Left = 3
        Top = 34
        Width = 250
        Height = 342
        AllowGrayed = True
        Anchors = [akLeft, akTop, akBottom]
        ItemHeight = 13
        TabOrder = 1
        OnContextPopup = CbExtensionListContextPopup
      end
      object BtnInstallExtensions: TButton
        Left = 259
        Top = 351
        Width = 173
        Height = 25
        Anchors = [akLeft, akBottom]
        Caption = 'Set'
        ElevationRequired = True
        TabOrder = 2
        OnClick = BtnInstallExtensionsClick
      end
      object CbInstallTypeChecked: TCheckBox
        Left = 259
        Top = 33
        Width = 17
        Height = 17
        Checked = True
        State = cbChecked
        TabOrder = 3
      end
      object CbInstallTypeGrayed: TCheckBox
        Left = 259
        Top = 76
        Width = 17
        Height = 17
        AllowGrayed = True
        State = cbGrayed
        TabOrder = 4
      end
      object CbInstallTypeNone: TCheckBox
        Left = 259
        Top = 119
        Width = 17
        Height = 17
        TabOrder = 5
      end
      object WlDefaultJPEGOptions: TWebLink
        Left = 3
        Top = 391
        Width = 147
        Height = 13
        Cursor = crHandPoint
        Anchors = [akLeft, akBottom]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        Color = clBtnFace
        ParentColor = False
        Text = 'Change default JPEG settings'
        OnClick = WlDefaultJPEGOptionsClick
        ImageIndex = 0
        IconWidth = 0
        IconHeight = 0
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
    object TsExplorer: TTabSheet
      Caption = 'Explorer'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        540
        413)
      object LbDisplayPlacesIn: TLabel
        Left = 223
        Top = 157
        Width = 41
        Height = 13
        Caption = 'Show in:'
      end
      object LbPlacesList: TLabel
        Left = 3
        Top = 157
        Width = 98
        Height = 13
        Caption = 'User defined places:'
      end
      object Bevel1: TBevel
        Left = 3
        Top = 344
        Width = 518
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsTopLine
        ExplicitWidth = 421
      end
      object BtnClearIconCache: TButton
        Left = 3
        Top = 382
        Width = 278
        Height = 24
        Caption = 'Clear Icon Cache'
        TabOrder = 18
        OnClick = BtnClearIconCacheClick
      end
      object BtnClearThumbnailCache: TButton
        Left = 3
        Top = 352
        Width = 278
        Height = 24
        Caption = 'Clear Folder Thumbnails Cache'
        TabOrder = 17
        OnClick = BtnClearThumbnailCacheClick
      end
      object BtnChooseNewPlace: TButton
        Left = 3
        Top = 312
        Width = 89
        Height = 25
        Caption = 'Select Folder'
        TabOrder = 15
        OnClick = BtnChooseNewPlaceClick
      end
      object BtnChoosePlaceIcon: TButton
        Left = 98
        Top = 312
        Width = 81
        Height = 25
        Caption = 'Icon'
        Enabled = False
        TabOrder = 16
        OnClick = BtnChoosePlaceIconClick
      end
      object PlacesListView: TListView
        Left = 3
        Top = 176
        Width = 214
        Height = 130
        Columns = <
          item
            Caption = 'Places'
            Width = 115
          end>
        HideSelection = False
        SmallImages = PlacesImageList
        TabOrder = 11
        ViewStyle = vsReport
        OnContextPopup = PlacesListViewContextPopup
        OnEdited = PlacesListViewEdited
        OnSelectItem = PlacesListViewSelectItem
      end
      object CblPlacesDisplayIn: TCheckListBox
        Left = 223
        Top = 176
        Width = 298
        Height = 132
        OnClickCheck = CblPlacesDisplayInClickCheck
        Anchors = [akLeft, akTop, akRight]
        Enabled = False
        ItemHeight = 13
        Items.Strings = (
          'My Computer'
          'My Picures'
          'My Documents'
          'Other folders')
        TabOrder = 12
      end
      object CbExplorerShowPlaces: TCheckBox
        Left = 7
        Top = 134
        Width = 241
        Height = 17
        Caption = 'Show "Other Places"'
        TabOrder = 5
      end
      object CbExplorerShowEXIF: TCheckBox
        Left = 7
        Top = 118
        Width = 241
        Height = 17
        Caption = 'Show EXIF marker'
        TabOrder = 4
      end
      object CbExplorerShowThumbsForImages: TCheckBox
        Left = 194
        Top = 72
        Width = 342
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Show Thumbnails For Images'
        TabOrder = 9
      end
      object CbExplorerSaveThumbsForFolders: TCheckBox
        Left = 194
        Top = 56
        Width = 342
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Save Thumbnails For Folders'
        TabOrder = 8
      end
      object CbExplorerShowThumbsForFolders: TCheckBox
        Left = 194
        Top = 40
        Width = 342
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Show Thumbnails For Folders'
        TabOrder = 7
      end
      object CbExplorerShowAttributes: TCheckBox
        Left = 194
        Top = 24
        Width = 342
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Show Attributes'
        TabOrder = 6
      end
      object Label13: TStaticText
        Left = 194
        Top = 3
        Width = 217
        Height = 17
        AutoSize = False
        Caption = 'Thumbnails options:'
        TabOrder = 13
      end
      object Label12: TStaticText
        Left = 3
        Top = 3
        Width = 185
        Height = 17
        AutoSize = False
        Caption = 'Show current objects:'
        TabOrder = 14
      end
      object CbExplorerShowFolders: TCheckBox
        Left = 7
        Top = 24
        Width = 171
        Height = 17
        Caption = 'Folders'
        TabOrder = 0
      end
      object CbExplorerShowSimpleFiles: TCheckBox
        Left = 7
        Top = 40
        Width = 171
        Height = 17
        Caption = 'Simple Files'
        TabOrder = 1
      end
      object CbExplorerShowImages: TCheckBox
        Left = 7
        Top = 56
        Width = 171
        Height = 17
        Caption = 'Image Files'
        TabOrder = 2
      end
      object CbExplorerShowHidden: TCheckBox
        Left = 7
        Top = 72
        Width = 171
        Height = 17
        Caption = 'Hidden Files'
        TabOrder = 3
      end
      object CbExplorerShowThumbsForVideo: TCheckBox
        Left = 194
        Top = 88
        Width = 342
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Show Thumbnails For Video'
        TabOrder = 10
      end
    end
    object TsView: TTabSheet
      Caption = 'View'
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        540
        413)
      object Label15: TLabel
        Left = 6
        Top = 4
        Width = 517
        Height = 13
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = 'Count of Steps for FullScreen mode (50)'
        ExplicitWidth = 420
      end
      object Label22: TLabel
        Left = 6
        Top = 56
        Width = 420
        Height = 13
        AutoSize = False
        Caption = 'Slide Show Speed (5000)'
      end
      object Label26: TLabel
        Left = 6
        Top = 111
        Width = 517
        Height = 13
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = 'Slide Speed (5000)'
        ExplicitWidth = 420
      end
      object lbDetectionSize: TLabel
        Left = 8
        Top = 237
        Width = 71
        Height = 13
        Caption = 'Detection size:'
      end
      object LbDisplayICCProfile: TLabel
        Left = 8
        Top = 345
        Width = 88
        Height = 13
        Caption = 'Display ICC Profile'
      end
      object TrackBar1: TTrackBar
        Left = 3
        Top = 19
        Width = 526
        Height = 25
        Anchors = [akLeft, akTop, akRight]
        Max = 100
        Min = 1
        Position = 50
        TabOrder = 0
        ThumbLength = 15
        OnChange = TrackBar1Change
      end
      object TrackBar2: TTrackBar
        Left = 3
        Top = 71
        Width = 526
        Height = 25
        Anchors = [akLeft, akTop, akRight]
        Max = 100
        Min = 1
        Position = 20
        TabOrder = 1
        ThumbLength = 15
        OnChange = TrackBar2Change
      end
      object TrackBar4: TTrackBar
        Left = 3
        Top = 124
        Width = 526
        Height = 29
        Anchors = [akLeft, akTop, akRight]
        Max = 100
        Min = 5
        Position = 50
        TabOrder = 2
        ThumbLength = 15
        OnChange = TrackBar4Change
      end
      object CbViewerNextOnClick: TCheckBox
        Left = 8
        Top = 168
        Width = 526
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Next on Click'
        TabOrder = 3
      end
      object CbViewerUseCoolStretch: TCheckBox
        Left = 8
        Top = 191
        Width = 526
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Use Cool Stretch'
        TabOrder = 4
      end
      object cbViewerFaceDetection: TCheckBox
        Left = 8
        Top = 214
        Width = 526
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Enable face detection'
        TabOrder = 5
      end
      object CbDetectionSize: TComboBox
        Left = 8
        Top = 256
        Width = 237
        Height = 21
        Style = csDropDownList
        TabOrder = 6
      end
      object BtnClearFaceDetectionCache: TButton
        Left = 8
        Top = 283
        Width = 237
        Height = 25
        Caption = 'Clear cache'
        TabOrder = 7
        OnClick = BtnClearFaceDetectionCacheClick
      end
      object LsFaceDetectionClearCache: TLoadingSign
        Left = 251
        Top = 283
        Width = 25
        Height = 25
        Visible = False
        Active = True
        FillPercent = 50
        Color = clBtnFace
        ParentColor = False
        SignColor = clBlack
        MaxTransparencity = 255
      end
      object CbRedCyanStereo: TCheckBox
        Left = 8
        Top = 314
        Width = 526
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Red-cyan glasses for stereo images'
        TabOrder = 9
      end
      object CbDisplayICCProfile: TComboBox
        Left = 8
        Top = 364
        Width = 237
        Height = 21
        Style = csDropDownList
        TabOrder = 10
      end
    end
    object TsUserMenu: TTabSheet
      Caption = 'User Menu'
      ImageIndex = 3
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        540
        413)
      object Label23: TLabel
        Left = 3
        Top = 278
        Width = 91
        Height = 13
        Caption = 'User Submenu icon'
      end
      object Label21: TLabel
        Left = 3
        Top = 238
        Width = 106
        Height = 13
        Caption = 'User submenu caption'
      end
      object Label24: TLabel
        Left = 3
        Top = 321
        Width = 42
        Height = 13
        Caption = 'Preview:'
      end
      object Image2: TImage
        Left = 5
        Top = 336
        Width = 25
        Height = 25
      end
      object Label19: TLabel
        Left = 135
        Top = 127
        Width = 21
        Height = 13
        Caption = 'Icon'
      end
      object Label25: TLabel
        Left = 135
        Top = 87
        Width = 39
        Height = 13
        Caption = 'Params:'
      end
      object Label18: TLabel
        Left = 135
        Top = 47
        Width = 74
        Height = 13
        Caption = 'Executable file:'
      end
      object Label20: TLabel
        Left = 135
        Top = 7
        Width = 41
        Height = 13
        Caption = 'Caption:'
      end
      object Bevel3: TBevel
        Left = 0
        Top = 223
        Width = 532
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsTopLine
        ExplicitWidth = 511
      end
      object GbUserMenuUseFor: TGroupBox
        Left = 179
        Top = 238
        Width = 354
        Height = 123
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Use Menu for'
        TabOrder = 15
        object CbUseUserMenuForIDMenu: TCheckBox
          Left = 13
          Top = 24
          Width = 308
          Height = 17
          Caption = 'Use for imagecontextmenu'
          TabOrder = 0
        end
        object CbUseUserMenuForExplorer: TCheckBox
          Left = 13
          Top = 70
          Width = 308
          Height = 17
          Caption = 'Use for explorer images'
          TabOrder = 2
        end
        object CbUseUserMenuForViewer: TCheckBox
          Left = 13
          Top = 47
          Width = 308
          Height = 17
          Caption = 'Use for viwer'
          TabOrder = 1
        end
      end
      object BtnSaveUserMenuItem: TButton
        Left = 135
        Top = 200
        Width = 397
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Save'
        Enabled = False
        TabOrder = 11
        OnClick = BtnSaveUserMenuItemClick
      end
      object BtnAddNewUserMenuItem: TButton
        Left = 0
        Top = 200
        Width = 129
        Height = 17
        Caption = 'Add'
        TabOrder = 3
        OnClick = Addnewcommand1Click
      end
      object BtnUserMenuItemDown: TButton
        Left = 64
        Top = 176
        Width = 57
        Height = 17
        Caption = 'Down'
        TabOrder = 2
        OnClick = BtnUserMenuItemDownClick
      end
      object BtnUserMenuItemUp: TButton
        Left = 0
        Top = 176
        Width = 57
        Height = 17
        Caption = 'Up'
        TabOrder = 1
        OnClick = BtnUserMenuItemUpClick
      end
      object LvUserMenuItems: TListView
        Left = 3
        Top = 8
        Width = 126
        Height = 161
        Columns = <
          item
            Caption = 'Menu item'
            Width = 115
          end>
        HideSelection = False
        ReadOnly = True
        SmallImages = ImageList1
        TabOrder = 0
        ViewStyle = vsReport
        OnContextPopup = LvUserMenuItemsContextPopup
        OnSelectItem = LvUserMenuItemsSelectItem
      end
      object BtnSelectUserMenuItemIcon: TButton
        Left = 158
        Top = 294
        Width = 15
        Height = 21
        Caption = '...'
        TabOrder = 9
        OnClick = BtnSelectUserMenuItemIconClick
      end
      object EdSubmenuIcon: TEdit
        Left = 3
        Top = 294
        Width = 153
        Height = 21
        ReadOnly = True
        TabOrder = 13
      end
      object EdSubmenuCaption: TEdit
        Left = 3
        Top = 254
        Width = 153
        Height = 21
        TabOrder = 12
      end
      object CbUserMenuItemIsSubmenu: TCheckBox
        Left = 135
        Top = 169
        Width = 381
        Height = 17
        Caption = 'Use "user submenu"'
        Checked = True
        State = cbChecked
        TabOrder = 10
      end
      object EdUserMenuItemIcon: TEdit
        Left = 135
        Top = 143
        Width = 377
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        Enabled = False
        ReadOnly = True
        TabOrder = 8
        OnKeyPress = EdUserMenuItemCaptionKeyPress
      end
      object BtnUserMenuChooseIcon: TButton
        Left = 518
        Top = 142
        Width = 15
        Height = 21
        Anchors = [akTop, akRight]
        Caption = '...'
        Enabled = False
        TabOrder = 14
        OnClick = BtnUserMenuChooseIconClick
      end
      object EdUserMenuItemParams: TEdit
        Left = 135
        Top = 103
        Width = 397
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        Enabled = False
        TabOrder = 7
        OnKeyPress = EdUserMenuItemCaptionKeyPress
      end
      object EdUserMenuItemExecutable: TEdit
        Left = 135
        Top = 63
        Width = 377
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        Enabled = False
        TabOrder = 5
        OnKeyPress = EdUserMenuItemCaptionKeyPress
      end
      object BtnUserMenuChooseExecutable: TButton
        Left = 518
        Top = 63
        Width = 15
        Height = 21
        Anchors = [akTop, akRight]
        Caption = '...'
        Enabled = False
        TabOrder = 6
        OnClick = BtnUserMenuChooseExecutableClick
      end
      object EdUserMenuItemCaption: TEdit
        Left = 135
        Top = 23
        Width = 376
        Height = 21
        Enabled = False
        TabOrder = 4
        OnKeyPress = EdUserMenuItemCaptionKeyPress
      end
    end
    object TsSecurity: TTabSheet
      Caption = 'Security'
      ImageIndex = 4
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        540
        413)
      object GbBackup: TGroupBox
        Left = 8
        Top = 247
        Width = 522
        Height = 74
        Anchors = [akLeft, akTop, akRight]
        Caption = 'BackUping'
        TabOrder = 0
        object Label30: TLabel
          Left = 134
          Top = 43
          Width = 24
          Height = 13
          Caption = 'Days'
        end
        object BlBackupInterval: TLabel
          Left = 8
          Top = 19
          Width = 128
          Height = 13
          Caption = 'Create backUp copy every'
        end
        object SedBackupDays: TSpinEdit
          Left = 7
          Top = 38
          Width = 121
          Height = 22
          MaxValue = 100
          MinValue = 0
          TabOrder = 0
          Value = 0
        end
      end
      object GbPasswords: TGroupBox
        Left = 11
        Top = 8
        Width = 519
        Height = 233
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Passwords'
        TabOrder = 1
        DesignSize = (
          519
          233)
        object LbSecureInfo: TLabel
          Left = 64
          Top = 16
          Width = 318
          Height = 57
          AutoSize = False
          Caption = 
            '  Warning: this option is still experemental. Use very carefull.' +
            ' Remember: if you forgot password for images, you can'#39't restore ' +
            'they!!!'
          WordWrap = True
        end
        object ImSecureInfo: TImage
          Left = 8
          Top = 16
          Width = 49
          Height = 49
          Picture.Data = {
            055449636F6E0000010001003030000001002000A82500001600000028000000
            3000000060000000010020000000000080250000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000002
            0000000B000000160000001B00000018000000130000000E0000000A00000004
            0000000100000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000200000012
            00000034000000530000005C000000560000004D00000044000000390000002C
            00000020000000170000000E0000000600000001000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000003000000140049736A
            0373AED40475AFDF02699FD8005785C5004871B6003453A30015218600070A74
            0000006300000053000000430000003100000020000000130000000900000002
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000400000019004872710887C9F4
            71DEF3FF44D0FCFF37C3F7FF34BDF1FF2AB2E9FF1DA6E3FF0F93D4F90478B6EA
            005D90D0004871B9001D2E9000060977000000620000004D0000003500000021
            0000001000000005000000010000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000040000001B00538287088ACFF62BBBF5FF
            94FDFFFF52D8FFFF53D9FFFF58DCFFFF58DDFFFF53DAFFFF4BD4FFFF45CEFCFF
            38BFF2FF26AEE7FF1498D8FB0578B5EA005483C8002C46A00004067900000061
            0000004600000029000000130000000600000001000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000060000001D005E949C1097DAFF31C2FCFF39CAFFFF
            8FF8FFFF5CDDFFFF5FDEFFFF63DFFFFF62DEFFFF60DEFFFF5EDDFFFF5CDCFFFF
            5ADCFFFF58DDFFFF51D8FFFF44CDFCFF30B8EEFF169CDBFD0373AFE7004A74C0
            00121C8900000068000000490000002B00000014000000050000000100000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000010000000800000023005D93A21299DBFF3DCAFDFF3ECDFFFF3DCAFFFF
            90F9FFFF64E1FFFF67E1FFFF6AE2FFFF68E1FFFF66E0FFFF65E0FFFF63DFFFFF
            61DEFFFF5EDBFEFF58D7FAFF5DDFFFFF5CE1FFFF51D9FFFF3EC8F8FF23ACE7FF
            0984C3F0004E7AC40016228E0000006A00000049000000270000000E00000002
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000001
            0000000A001D2E3100649DB319A0E0FF43CDFDFF4BD4FFFF45CFFFFF42CEFFFF
            90F9FFFF69E4FFFF6DE4FFFF6EE5FFFF6DE4FFFF6BE3FFFF69E2FFFF67E2FFFF
            6AE5FFFF4DC3E7FF147BABFF2491BDFF44BBE1FF58D6F9FF5FE1FFFF58DFFFFF
            48D0FDFF2AB2EBFF0A85C3F2004E7CC6000F1889000000630000003B00000019
            0000000500000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000007
            00283D350071B1CF21A9E5FF4CD5FFFF51D5FFFF51D4FFFF4BD1FFFF46CFFFFF
            90F9FFFF6EE7FFFF72E8FFFF73E8FFFF71E7FFFF6FE6FFFF6EE5FFFF6CE4FFFF
            6FE9FFFF49BCE0FF006598FF036B9FFF086C9FFF137CABFF2D9CC6FF4AC3E9FF
            5DDDFFFF57DDFFFF48D1FCFF23ABE6FF0377B5EB003351AD000000760000004D
            000000240000000A000000010000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000466D27
            0074B6CE23ABE6FF4DD6FFFF52D6FFFF54D6FFFF54D6FFFF4ED4FFFF47D1FFFF
            91FAFFFF73EAFFFF79EBFFFF78EBFFFF76EAFFFF74E9FFFF73E8FFFF71E7FFFF
            72E9FFFF5ED3F0FF066D9EFF0C76A8FF1684B3FF1988B8FF1583B4FF0B74A6FF
            3DAFD7FF66E4FFFF5CDCFFFF55DBFFFF3DC6F6FF1296D7FD005383CB000D1487
            0000005800000025000000060000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000000000000000007BBFA9
            23ABE6FF4DD6FFFF53D6FFFF55D7FFFF55D8FFFF55D8FFFF50D5FFFF4AD2FFFF
            91FAFFFF77EDFFFF7DEEFFFF7DEDFFFF7BECFFFF79ECFFFF77EAFFFF75EAFFFF
            76EAFFFF70E6FDFF147DABFF0972A5FF1582B2FF1F90BFFF2EA5D2FF1D90C1FF
            31A0C9FF6DE9FFFF64DFFFFF61DFFFFF5BDEFFFF4DD5FEFF20A9E4FF006BA7E3
            00182589000000410000000E0000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000000000384C8C4
            43CEFDFF54D8FFFF57D8FFFF57D8FFFF57D8FFFF58D8FFFF54D6FFFF4CD3FFFF
            92FAFFFF7BEFFFFF81F1FFFF81F0FFFF80EFFFFF7EEEFFFF7CEDFFFF7AECFFFF
            79EDFFFF7AEEFFFF218BB5FF0770A3FF1582B2FF1E8FBEFF2CA2D0FF1888B9FF
            3EADD2FF71EBFFFF69E2FFFF68E2FFFF65DFFFFF5DDEFFFF51DBFFFF21AAE5FF
            005381C00000004C000000130000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000000000483C6BF
            48CFFCFF58DAFFFF59DAFFFF59DAFFFF5ADAFFFF5BDAFFFF56D8FFFF4ED4FFFF
            92FAFFFF7FF1FFFF86F4FFFF86F3FFFF84F2FFFF82F1FFFF81F0FFFF7FEFFFFF
            83F4FFFF5BC9E3FF066C9EFF0B75A7FF1582B2FF1E8FBFFF299FCDFF127EAFFF
            57C8E6FF73EBFFFF6DE5FFFF6CE4FFFF6BE3FFFF67E1FFFF5EDFFFFF38C1F2FF
            005887C40000004D000000130000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000000000483C6BF
            4CD2FCFF5CDCFFFF5DDBFFFF5CDBFFFF5CDCFFFF5EDCFFFF59DAFFFF51D6FFFF
            92FBFFFF83F4FFFF8BF7FFFF8BF6FFFF89F5FFFF87F4FFFF86F3FFFF85F2FFFF
            8CFBFFFF3EA7C9FF006197FF0D78A9FF1582B2FF1E90BFFF279CCBFF137EADFF
            6EE0F5FF77EBFFFF73E8FFFF71E7FFFF70E6FFFF6EE5FFFF67E4FFFF3DC3F0FF
            005786C30000004C000000130000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000000000483C6BF
            50D4FCFF60DEFFFF5FDEFFFF5FDDFFFF60DDFFFF61DEFFFF5CDDFFFF54D9FFFF
            92FBFFFF86F7FFFF90F9FFFF90F9FFFF8EF7FFFF8CF6FFFF8BF5FFFF89F5FFFF
            91FDFFFF40A9CAFF006297FF0D78A9FF1582B2FF1E8FBFFF2BA1CFFF1584B6FF
            48B5D4FF7FF2FFFF77EBFFFF76EAFFFF75E9FFFF73E8FFFF6EE8FFFF43C5F0FF
            005686C30000004C000000130000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000000000583C6BF
            53D5FCFF64E0FFFF63DFFFFF63DFFFFF64DFFFFF65E0FFFF60DEFFFF56DAFFFF
            93FBFFFF89F9FFFF94FBFFFF94FBFFFF93FAFFFF91F9FFFF8FF8FFFF8EF8FFFF
            93FEFFFF59C0D9FF006397FF0C78A9FF1582B2FF1E8FBEFF2AA1CFFF279DCDFF
            228AB4FF7DEDFDFF7DEEFFFF7AEDFFFF79EBFFFF78EBFFFF74EBFFFF46C8F0FF
            005686C30000004C000000130000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000000000584C6BF
            57D7FCFF68E3FFFF67E1FFFF67E2FFFF68E2FFFF69E2FFFF64E0FFFF59DCFFFF
            94FBFFFF91FAFFFF9AFDFFFF99FEFFFF97FDFFFF95FCFFFF94FBFFFF93FAFFFF
            92FBFFFF8CF5FBFF1C81ABFF01699EFF1684B5FF1F90BFFF299FCDFF30A9D7FF
            1C85B0FF7EEDFBFF82F2FFFF7FEFFFFF7EEEFFFF7DEDFFFF79EEFFFF4ACAF0FF
            005686C30000004C000000130000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000000000584C6BF
            5BDAFCFF6DE6FFFF6CE4FFFF6CE5FFFF6DE5FFFF6DE5FFFF68E3FFFF5CDFFFFF
            94FBFFFF9DF9FFFFA9FDFFFFA8FFFFFFA1FFFFFF9CFFFFFF99FEFFFF97FDFFFF
            95FCFFFF98FFFFFF7BE0ECFF1777A5FF036CA1FF1A8BBBFF2AA2D0FF188ABEFF
            3297BDFF8BF8FFFF86F4FFFF84F2FFFF82F1FFFF81F0FFFF7EF1FFFF4DCBF0FF
            005686C30000004C000000130000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000000000584C6BF
            5FDDFCFF73E9FFFF71E7FFFF72E7FFFF72E8FFFF72E8FFFF6CE6FFFF5EE1FFFF
            94FBFFFFA4F6FFFFB7FCFFFFBBFFFFFFB5FFFFFFAFFFFFFFA8FFFFFFA2FFFFFF
            9DFFFFFF99FEFFFF9DFFFFFF88EDF4FF3A9CBEFF1275A5FF1073A7FF2286B0FF
            78E0EEFF91FBFFFF8AF6FFFF89F5FFFF88F4FFFF86F3FFFF82F4FFFF50CEF0FF
            005686C30000004C000000130000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000000000584C6BF
            63E0FCFF78ECFFFF77EAFFFF77EAFFFF78EBFFFF78EBFFFF6FE8FFFF5DE2FFFF
            94FBFFFF9DF2FFFFB3F6FFFFBEFBFFFFC0FBFFFFBDFCFFFFB8FEFFFFB4FEFFFF
            AEFEFFFFA8FFFFFFA2FFFFFFA1FFFFFF9DFFFFFF87EBF1FF7DDFEAFF8FF6FBFF
            96FEFFFF91F9FFFF8FF8FFFF8DF8FFFF8CF7FFFF8AF6FFFF88F7FFFF53D0F0FF
            005686C30000004C000000130000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000000000684C6BF
            68E3FCFF7DEFFFFF7DEEFFFF7EEEFFFF7FEFFFFF7CEEFFFF6BE8FFFF73ECFFFF
            9CFEFFFF9AFBFFFFA0FBFFFFA7FCFFFFB1FCFFFFB3FCFFFFB2FAFFFFAEF9FFFF
            B1FAFFFFB3FCFFFFB1FDFFFFACFEFFFFA8FFFFFFA6FFFFFFA2FFFFFF9BFFFFFF
            97FEFFFF95FCFFFF93FCFFFF93FAFFFF91FAFFFF90F9FFFF8DFAFFFF56D2F0FF
            005686C30000004C000000130000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000000000684C6BF
            6DE6FCFF84F3FFFF84F2FFFF85F3FFFF84F3FFFF78EDFFFF7DF2FFFF98FDFFFF
            6FE7FFFF61E1FFFF68E5FFFF69E5FFFF77EBFFFF84F2FFFF93F8FFFF9CFBFFFF
            A1FCFFFFA9FDFFFFACFBFFFFA8F9FFFFADFAFFFFAFFCFFFFADFEFFFFA8FFFFFF
            A2FFFFFF9DFFFFFF99FFFFFF97FDFFFF96FCFFFF95FBFFFF91FCFFFF59D3F0FF
            005686C30000004C000000130000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000000000685C6BF
            71E9FCFF8AF7FFFF8DF7FFFF8AF6FFFF80F2FFFF85F5FFFF99FEFFFF77F3FFFF
            66E9FFFF65E6FFFF69E9FFFF61E3FFFF57DAFFFF57DBFFFF58DBFFFF5CDDFFFF
            69E5FFFF79ECFFFF90F8FFFF9AFBFFFFA2FCFFFFAAFCFFFFAEFAFFFFB1FBFFFF
            B2FDFFFFAEFFFFFFA8FFFFFFA2FFFFFF9DFFFFFF99FEFFFF94FFFFFF5AD5F0FF
            005686C30000004C000000130000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000000000685C6BF
            73ECFCFF8DFAFFFF8EF9FFFF85F6FFFF90FAFFFF9EFFFFFF74EFFFFF48BCD9FF
            3DA2C1FF3A91B0FF41A9C9FF55CAE7FF77EEFFFF6EE6FFFF68E3FFFF62E0FFFF
            5ADBFFFF54D8FFFF56D8FFFF5DDDFFFF6FE7FFFF8DF6FFFF9EFDFFFFA8FDFFFF
            ACF9FFFFB1F9FFFFB5FCFFFFB4FEFFFFAEFFFFFFA7FFFFFF9CFFFFFF5DD6F0FF
            005686C30000004C000000130000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000000000685C6BF
            70EDFCFF85F9FFFF81F6FFFF92FCFFFF98FFFFFF64D9ECFF317C99FF586973FF
            717579FF797A7DFF686C71FF37677FFF4DBAD8FF7EF1FFFF77EAFFFF74E9FFFF
            71E7FFFF6CE4FFFF67E1FFFF60DEFFFF55D8FFFF53D8FFFF60DFFFFF7BEEFFFF
            99FDFFFFA3FDFFFFABF9FFFFB4F8FFFFB9FBFFFFB4FDFFFFA7FEFFFF64D5F0FF
            005686C30000004C000000130000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000000000685C6BF
            62E8FCFF74F4FFFF8CFBFFFF97FEFFFF7DF1FDFF307D9CFF7F7B7CFFC4BFBCFF
            AFAEADFFA4A3A2FFA19E9DFF837B79FF357490FF78EBFCFF83F2FFFF7DEFFFFF
            7BEDFFFF77EBFFFF74E8FFFF71E7FFFF6DE5FFFF66E2FFFF5BDBFFFF53D7FFFF
            5CDDFFFF7BEEFFFF97FDFFFFA5FBFFFFAEF7FFFFB1F6FFFFA9FAFFFF67D3F0FF
            005686C30000004C000000130000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000000000384C6BF
            5BE6FCFF92FDFFFF98FCFFFF93F7FFFF92EEF9FF4D7182FFC3BCBAFFDDDDDDFF
            B6B6B6FFA6A6A6FFA9A9A9FF9C9491FF4D7D91FF7FF0FDFF8CF7FFFF87F3FFFF
            84F2FFFF81F0FFFF7EEFFFFF7AECFFFF77EBFFFF74E8FFFF71E7FFFF6FE6FFFF
            66E3FFFF5ADDFFFF5EE0FFFF82F2FFFF9CFDFFFFA3F7FFFF9DF2FFFF64CFF0FF
            005686C30000004D000000130000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000000000384C7BD
            8BF8FEFF98FAFFFF98F3FFFFB2FBFFFFB4F6F9FF70868DFFCAC7C6FFDBDBDBFF
            B9B9B9FFABABABFFADADADFF989191FF7FB1B4FF98FFFFFF95FCFFFF91FAFFFF
            8EF8FFFF8CF5FFFF88F3FFFF84F2FFFF80EFFFFF81F2FFFF7CF1FFFF66DEF7FF
            5ED8F5FF5BD5F5FF58D7FAFF59DEFFFF65E3FFFF90F9FFFF9DFBFFFF5DCDF0FF
            035987C20000004C000000130000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000000001D99D3D8
            61D1EEFF97F5FFFFAFF6FFFFC5FDFFFFCBFEFEFF92A0A0FFD2D0D0FFDBDBDBFF
            BEBEBEFFB0B0B0FFB2B2B2FF9A9494FF8FBBBAFFA8FFFFFFA0FFFFFF9CFFFFFF
            98FDFFFF95FCFFFF91FAFFFF8EF8FFFF90FBFFFF75E4F5FF429EBBFF3A6F88FF
            456C7FFF436B80FF38758FFF38A6CBFF5ADEFFFF55DCFFFF89F8FFFF63D4EDFF
            3686A2C00000003C0000000D0000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000000007DDFEE52
            0B8BCDE052BDE6FFB0F6FFFFD2FFFFFFD6FDFDFF949F9FFFD2D0D0FFDEDEDEFF
            C2C2C2FFB5B5B5FFB7B7B7FF9C9797FF94B9B9FFB7FFFFFFADFFFFFFA9FFFFFF
            A5FFFFFFA0FFFFFF9CFFFFFF9CFEFFFF80EAF3FF337C99FF6F7277FF9B9491FF
            978F8BFF968D8AFF867E7BFF466577FF45B6D8FF5FE8FFFF47D4FBFF22A1D9FF
            4292A7990000001C000000040000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            3BAFDA2A2BA3D6C234A7DCFF9DE3F5FFDBFFFFFF98A0A0FFD4D3D3FFE0E0E0FF
            C6C6C6FFBABABAFFBDBDBDFF9F9B9BFF9BB9B9FFC5FFFFFFBBFFFFFFB7FFFFFF
            B3FFFFFFAEFFFFFFA9FFFFFFAEFFFFFF55B3CAFF5F6A74FFCBC6C3FFCBCBCBFF
            A5A5A5FFA3A3A4FF9D9B9AFF6D6D71FF3DA7C6FF55DCFAFF1A9BD8FF2584ABA9
            0408081E00000005000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000079E0F2071F9BD373249FD7EE65C1E5FF89989DFFDAD7D6FFE3E3E3FF
            CACACAFFBFBFBFFFC2C2C2FFA29E9EFFA1B9B9FFD2FFFFFFC8FFFFFFC4FFFFFF
            C0FFFFFFBBFFFFFFB6FFFFFFBBFFFFFF5EB2C6FF7E8388FFDCDADAFFCACACAFF
            A8A8A8FFA8A8A8FFA29F9FFF747A7CFF45B2D2FF209DDAFF439CB5A30000001B
            0000000500000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000006ED7EB2E29A7DBA4597F91FDE2DCD9FFE6E6E6FF
            CECECEFFC3C3C3FFC7C7C7FFA3A1A2FFA8B8B8FFE2FFFFFFD6FFFFFFD2FFFFFF
            CDFFFFFFC9FFFFFFC4FFFFFFC2FFFFFFA6E6EAFF8D9293FFD9D7D7FFCCCCCCFF
            ADADADFFACACACFFA6A4A3FF798083FF1586C4F6358AA5940000001600000004
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000006E7477C8E1DEDEFFE7E7E7FF
            D2D2D2FFC8C8C8FFCBCBCBFFA7A5A4FFADB9B9FFECFFFFFFE2FFFFFFDFFFFFFF
            DBFFFFFFD7FFFFFFD2FFFFFFCEFFFFFFC2F4F3FF949797FFD9D8D8FFCFCFCFFF
            B1B1B1FFB1B1B1FFAAA8A8FF818585FC184E65990000002B0000000400000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000716E6EBDE3E3E3FFEAEAEAFF
            D6D6D6FFCDCDCDFFD0D0D0FFADA9A7FF90AEB6FFD2FDFFFFE4FFFFFFE8FFFFFF
            E6FFFFFFE1FFFFFFDDFFFFFFDCFFFFFFCBF2F2FF949797FFDCDBDBFFD2D2D2FF
            B6B6B6FFB5B5B5FFADADADFF81827FF806090A74000000280000000200000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000737373C0E6E6E6FFEDEDEDFF
            DADADAFFD2D2D2FFD5D5D5FFBBB3AFFF437A95FA2CA6DEFB5FBDE5FF8FD7F0FF
            A6E5F6FFC7F6FDFFDBFEFFFFDEFFFFFFCFF3F4FF959898FFDEDEDEFFD5D5D5FF
            BABABAFFBABABAFFB3B3B3FF7A7A7AF90E0E0D78000000280000000200000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000006B6B6BA3D3D3D3FFF3F3F3FF
            E0E0E0FFD7D7D7FFD8D8D8FFCCCAC9FF636D72F0134153A33086A19D168FC7BA
            2DA4D6D72EA2D8F349B4E0FF5BBDE6FF77C6E1FF939798FFE3E1E1FFD9D9D9FF
            C0C0C0FFC0C0C0FFB8B8B8FF7B7B7BF90E0E0E78000000280000000200000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000069696984C7C7C7FFF7F7F7FF
            E8E8E8FFDCDCDCFFDBDBDBFFDEDEDEFFA19F9FFF404141C60000007500000040
            3D686D252696C5381690C84E52BDDC79108AC5998A9598FCE7E4E3FFDCDCDCFF
            C4C4C4FFC4C4C4FFBCBCBCFF7D7D7DF90E0E0E78000000280000000200000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000067676759ACACACFFFAFAFAFF
            F0F0F0FFE2E2E2FFDFDFDFFFE1E1E1FFD7D7D7FF7E7A79FD242322AC00000073
            00000047000000220000000E00000005235C750B919291F2E8E7E6FFDFDFDFFF
            C9C9C9FFC9C9C9FFC0C0C0FF7E7E7EF90E0E0E78000000280000000200000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000696969167F7F7FE6EDEDEDFF
            F7F7F7FFEDEDEDFFE3E3E3FFE2E2E2FFE6E6E6FFCDCDCDFF797878F8393635BF
            030303800000005F000000410000002E1818182F918F8EF3EAEAEAFFE2E2E2FF
            CDCDCDFFCDCDCDFFC5C5C5FF808080F90E0E0E77000000260000000200000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000000066666678B6B6B6FF
            FEFEFEFFF5F5F5FFEBEBEBFFE6E6E6FFE5E5E5FFE8E8E8FFDADADAFF979797FF
            5B5B5BE0323130B11717168F050505741616167A8D8D8DF8EBEBEBFFDDDDDDFF
            D2D2D2FFD3D3D3FFCACACAFF7E7E7EF91010106A0000001F0000000100000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000006B6B6B0D6F6F6FD6
            DCDCDCFFFFFFFFFFF5F5F5FFEDEDEDFFEAEAEAFFE8E8E8FFEAEAEAFFE9E9E9FF
            CECECEFFA6A6A6FF7F7F7FF46C6C6CEC717171EFB8B8B8FFE4E4E4FFD8D8D8FF
            D7D7D7FFD9D9D9FFC9C9C9FF676767E90909094A000000110000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000000006565653A
            808080F5E4E4E4FFFFFFFFFFF8F8F8FFF1F1F1FFEDEDEDFFECECECFFEBEBEBFF
            ECECECFFEDEDEDFFE3E3E3FFD8D8D8FFDADADAFFE4E4E4FFDEDEDEFFDDDDDDFF
            DCDCDCFFE1E1E1FFA9A9A9FF474747A800000026000000050000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            6767674D7C7C7CE3D1D1D1FFFFFFFFFFFDFDFDFFF5F5F5FFF1F1F1FFEEEEEEFF
            EDEDEDFFECECECFFECECECFFECECECFFE9E9E9FFE6E6E6FFE3E3E3FFE2E2E2FF
            E8E8E8FFC8C8C8FF696969E5141414410000000D000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000676767256D6D6DC4AFAFAFFFF2F2F2FFFFFFFFFFFDFDFDFFF6F6F6FF
            F3F3F3FFF0F0F0FFEFEFEFFFEEEEEEFFECECECFFEAEAEAFFEBEBEBFFF0F0F0FF
            CECECEFF757575F74040406B0000001300000002000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000006B6B6B0763636371808080E9BCBCBCFFF1F1F1FFFFFFFFFF
            FFFFFFFFFAFAFAFFF8F8F8FFF6F6F6FFF6F6F6FFF9F9F9FFEDEDEDFFB8B8B8FF
            737373E5474747610000000F0000000200000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000696969206464647B7D7D7DD7ACACACFF
            D2D2D2FFF5F5F5FFF5F5F5FFF4F4F4FFDDDDDDFFBEBEBEFF878787ED5C5C5C9B
            3E3E3E2F00000007000000010000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000006D6D6D0A64646459
            68686894767676BE767676BF767676C26A6A6AA65D5D5D724848482700000005
            0000000100000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000FFFC00FFFFFF0000FFF8000FFFFF0000FFF00001FFFF0000FFE00000
            3FFFBA7FFFC000000FFFFFFFFF80000003FFFFFFFE00000001FFFFFFFC000000
            00FF8CFFFC000000003FD5FFFC000000003FB0FFFC000000003FACFFFC000000
            003F8BFFFC000000003FFFFFFC000000003FFFFFFC000000003FFFFFFC000000
            003FFFFFFC000000003FFFFFFC000000003FFFFFFC000000003FFFFFFC000000
            003FEFFFFC000000003FE3FFFC000000003FFFFFFC000000003FFFFFFC000000
            003FFFFFFC000000003FEDFFFC000000003F0059FC000000003F0000FC000000
            003F0000FC000000003F0000FC000000003F0000FE000000007F0000FF000000
            00FF0000FFC0000001FF0000FFF0000003FF0000FFF0000003FF0000FFF00000
            03FFE6AAFFF0000003FFFFFFFFF0000003FFFFFFFFF0000003FFFFFFFFF00000
            03FFA4FFFFF8000003FFD7FFFFF8000007FFB3FFFFFC000007FFAFFFFFFE0000
            0FFF8EFFFFFF00000FFFFFFFFFFF80001FFFFFFFFFFFE0003FFFFFFFFFFFF800
            FFFFFFFF}
        end
        object LbDefaultPasswordMethod: TLabel
          Left = 8
          Top = 116
          Width = 127
          Height = 13
          Caption = 'Default Password Method:'
        end
        object BtnClearPasswordsInSettings: TButton
          Left = 8
          Top = 197
          Width = 241
          Height = 25
          Caption = 'Clear INI passwords'
          TabOrder = 4
          OnClick = BtnClearPasswordsInSettingsClick
        end
        object BtnClearSessionPasswords: TButton
          Left = 8
          Top = 165
          Width = 241
          Height = 25
          Caption = 'Clear current loaded passwords'
          TabOrder = 2
          OnClick = BtnClearSessionPasswordsClick
        end
        object CbAutoSavePasswordInSettings: TCheckBox
          Left = 8
          Top = 88
          Width = 508
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Use auto saving password in user'#39's settings'
          TabOrder = 0
        end
        object CbAutoSavePasswordForSession: TCheckBox
          Left = 8
          Top = 72
          Width = 508
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Use auto saving password in current session'
          TabOrder = 1
        end
        object WblMethod: TWebLink
          Left = 8
          Top = 135
          Width = 84
          Height = 16
          Cursor = crHandPoint
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
      object GbProxyAuthorisation: TGroupBox
        Left = 8
        Top = 327
        Width = 522
        Height = 74
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Proxy authorisation'
        TabOrder = 2
        object LbProxyUserName: TLabel
          Left = 8
          Top = 23
          Width = 56
          Height = 13
          Caption = 'User Name:'
        end
        object LbProxyPassword: TLabel
          Left = 208
          Top = 23
          Width = 50
          Height = 13
          Caption = 'Password:'
        end
        object WebProxyUserName: TWatermarkedEdit
          Left = 8
          Top = 42
          Width = 177
          Height = 21
          TabOrder = 0
          Text = 'WebProxyUserName'
        end
        object WebProxyPassword: TWatermarkedEdit
          Left = 208
          Top = 42
          Width = 177
          Height = 21
          PasswordChar = '*'
          TabOrder = 1
          Text = 'WebProxyUserName'
        end
      end
    end
    object TsGlobal: TTabSheet
      Caption = 'Global'
      ImageIndex = 5
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        540
        413)
      object LbAddHeight: TLabel
        Left = 173
        Top = 196
        Width = 31
        Height = 13
        Caption = 'Height'
      end
      object LbAddWidth: TLabel
        Left = 58
        Top = 196
        Width = 28
        Height = 13
        Caption = 'Width'
      end
      object CbDontAddSmallFiles: TCheckBox
        Left = 11
        Top = 170
        Width = 501
        Height = 17
        Caption = 'No add to BD files less then'
        TabOrder = 6
        OnClick = CbDontAddSmallFilesClick
      end
      object CbCheckLinksOnUpdate: TCheckBox
        Left = 11
        Top = 126
        Width = 522
        Height = 38
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Verify links on updation images (works slowly, read help)'
        TabOrder = 5
        WordWrap = True
      end
      object CbSmallToolBars: TCheckBox
        Left = 11
        Top = 103
        Width = 522
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Use small icons in toolbars'
        TabOrder = 4
      end
      object CblEditorVirtuaCursor: TCheckBox
        Left = 11
        Top = 80
        Width = 522
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Virtual Cursor in Editor'
        TabOrder = 3
      end
      object CbSortGroups: TCheckBox
        Left = 11
        Top = 57
        Width = 522
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Sort Groups by Name'
        TabOrder = 2
      end
      object CbListViewHotSelect: TCheckBox
        Left = 11
        Top = 11
        Width = 522
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Use "hot" select in listviews'
        TabOrder = 0
      end
      object CbListViewShowPreview: TCheckBox
        Left = 11
        Top = 34
        Width = 522
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Show Preview'
        TabOrder = 1
      end
      object SedMinHeight: TSpinEdit
        Left = 126
        Top = 193
        Width = 41
        Height = 22
        MaxValue = 10000
        MinValue = 1
        TabOrder = 8
        Value = 64
      end
      object SedMinWidth: TSpinEdit
        Left = 11
        Top = 193
        Width = 41
        Height = 22
        MaxValue = 10000
        MinValue = 1
        TabOrder = 7
        Value = 64
      end
      object GbEXIF: TGroupBox
        Left = 11
        Top = 229
        Width = 522
        Height = 86
        Anchors = [akLeft, akTop, akRight]
        Caption = 'EXIF'
        TabOrder = 9
        DesignSize = (
          522
          86)
        object CbReadInfoFromExif: TCheckBox
          Left = 11
          Top = 16
          Width = 503
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'CbReadInfoFromExif'
          TabOrder = 0
        end
        object CbSaveInfoToExif: TCheckBox
          Left = 11
          Top = 39
          Width = 503
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'CbSaveInfoToExif'
          TabOrder = 1
        end
        object CbUpdateExifInfoInBackground: TCheckBox
          Left = 11
          Top = 62
          Width = 507
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'CbUpdateExifInfoInBackground'
          TabOrder = 2
        end
      end
    end
    object TsPrograms: TTabSheet
      Caption = 'Programs'
      ImageIndex = 7
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        540
        413)
      object LbExtensionExecutable: TLabel
        Left = 259
        Top = 195
        Width = 74
        Height = 13
        Caption = 'Executable file:'
      end
      object CblExtensions: TListBox
        Left = 3
        Top = 34
        Width = 250
        Height = 351
        Style = lbOwnerDrawFixed
        Anchors = [akLeft, akTop, akBottom]
        ItemHeight = 18
        TabOrder = 0
        OnClick = CblExtensionsClick
        OnDrawItem = CblExtensionsDrawItem
      end
      object StPlayerExtensions: TStaticText
        Left = 3
        Top = 11
        Width = 60
        Height = 17
        Caption = 'Extensions:'
        TabOrder = 1
      end
      object RbPlayerInternal: TRadioButton
        Left = 259
        Top = 57
        Width = 276
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'RbVlcPlayer (internal)'
        Checked = True
        TabOrder = 2
        TabStop = True
        OnClick = RbPlayerInternalClick
      end
      object StUseProgram: TStaticText
        Left = 259
        Top = 11
        Width = 69
        Height = 17
        Caption = 'Use program:'
        TabOrder = 3
      end
      object RbVlcPlayer: TRadioButton
        Left = 259
        Top = 80
        Width = 276
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'RbVlcPlayer'
        TabOrder = 4
        OnClick = RbPlayerInternalClick
      end
      object RbKmPlayer: TRadioButton
        Left = 259
        Top = 103
        Width = 276
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'RbKmPlayer'
        TabOrder = 5
        OnClick = RbPlayerInternalClick
      end
      object RbMediaPlayerClassic: TRadioButton
        Left = 259
        Top = 126
        Width = 276
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'RbMediaPlayerClassic'
        TabOrder = 6
        OnClick = RbPlayerInternalClick
      end
      object RbOtherProgram: TRadioButton
        Left = 259
        Top = 172
        Width = 276
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'RbOtherProgram*'
        TabOrder = 7
        OnClick = RbPlayerInternalClick
      end
      object EdPlayerExecutable: TEdit
        Left = 259
        Top = 214
        Width = 249
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        Enabled = False
        TabOrder = 8
        OnChange = EdPlayerExecutableChange
      end
      object BtnSelectPlayerExecutable: TButton
        Left = 514
        Top = 214
        Width = 23
        Height = 21
        Anchors = [akTop, akRight]
        Caption = '...'
        Enabled = False
        TabOrder = 9
        OnClick = BtnSelectPlayerExecutableClick
      end
      object WlAddPlayerExtension: TWebLink
        Left = 3
        Top = 391
        Width = 40
        Height = 16
        Cursor = crHandPoint
        Anchors = [akLeft, akBottom]
        Color = clBtnFace
        ParentColor = False
        Text = 'Add'
        OnClick = WlAddPlayerExtensionClick
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
      object WlRemovePlayerExtension: TWebLink
        Left = 49
        Top = 391
        Width = 60
        Height = 16
        Cursor = crHandPoint
        Anchors = [akLeft, akBottom]
        Color = clBtnFace
        ParentColor = False
        Text = 'Remove'
        OnClick = WlRemovePlayerExtensionClick
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
      object WlSavePlayerChanges: TWebLink
        Left = 259
        Top = 241
        Width = 88
        Height = 16
        Cursor = crHandPoint
        Anchors = [akLeft, akBottom]
        Color = clBtnFace
        ParentColor = False
        Text = 'Save program'
        Visible = False
        OnClick = WlSavePlayerChangesClick
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
      object RbWindowsMediaPlayer: TRadioButton
        Left = 259
        Top = 149
        Width = 276
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'RbWindowsMediaPlayer'
        TabOrder = 13
        OnClick = RbPlayerInternalClick
      end
      object RbDefaultrogram: TRadioButton
        Left = 259
        Top = 34
        Width = 276
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'RbDefaultrogram'
        TabOrder = 14
        OnClick = RbPlayerInternalClick
      end
    end
  end
  object PmExtensionStatus: TPopupActionBar
    Left = 232
    Top = 440
    object Usethisprogramasdefault1: TMenuItem
      Caption = 'Use this program as default'
      OnClick = Usethisprogramasdefault1Click
    end
    object Usemenuitem1: TMenuItem
      Caption = 'Use menu item'
      OnClick = Usemenuitem1Click
    end
    object Dontusethisextension1: TMenuItem
      Caption = 'Don'#39't use this extension'
      OnClick = Dontusethisextension1Click
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object Default1: TMenuItem
      Caption = 'Default'
      OnClick = Default1Click
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object SelectAll1: TMenuItem
      Caption = 'Select All'
      OnClick = SelectAll1Click
    end
    object DeselectAll1: TMenuItem
      Caption = 'Deselect All'
      OnClick = DeselectAll1Click
    end
  end
  object PmUserMenu: TPopupActionBar
    Left = 121
    Top = 437
    object Addnewcommand1: TMenuItem
      Caption = 'Add new command'
      OnClick = Addnewcommand1Click
    end
    object Remove1: TMenuItem
      Caption = 'Remove'
      OnClick = Remove1Click
    end
  end
  object ImageList1: TImageList
    ColorDepth = cd32Bit
    Left = 9
    Top = 437
  end
  object PmPlaces: TPopupActionBar
    Left = 84
    Top = 440
    object Additem1: TMenuItem
      Caption = 'Add item'
      OnClick = BtnChooseNewPlaceClick
    end
    object DeleteItem1: TMenuItem
      Caption = 'Delete Item'
      OnClick = DeleteItem1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Rename1: TMenuItem
      Caption = 'Rename'
      OnClick = Rename1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object Up1: TMenuItem
      Caption = 'Up'
      OnClick = Up1Click
    end
    object Down1: TMenuItem
      Caption = 'Down'
      OnClick = Down1Click
    end
  end
  object PlacesImageList: TImageList
    ColorDepth = cd32Bit
    Left = 52
    Top = 440
  end
  object SaveWindowPos1: TSaveWindowPos
    SetOnlyPosition = True
    RootKey = HKEY_CURRENT_USER
    Key = 'Software\Positions\Noname'
    Left = 160
    Top = 437
  end
  object AeMain: TApplicationEvents
    OnMessage = AeMainMessage
    Left = 200
    Top = 440
  end
  object PmCryptMethod: TPopupActionBar
    Left = 272
    Top = 440
  end
  object SnStyles: TShellNotification
    Active = False
    WatchSubTree = False
    WatchEvents = [neFileCreate, neFileDelete]
    OnFileCreate = SnStylesFileCreate
    OnFileDelete = SnStylesFileCreate
    Left = 320
    Top = 440
  end
  object ImlMediaPlayers: TImageList
    ColorDepth = cd32Bit
    Left = 360
    Top = 440
  end
  object PmSelectExtensionMethod: TPopupActionBar
    Left = 480
    Top = 8
    object MiSelectFile: TMenuItem
      Caption = 'Select File'
      OnClick = MiSelectFileClick
    end
    object MiSelectextension: TMenuItem
      Caption = 'Select extension'
      OnClick = MiSelectextensionClick
    end
  end
end
