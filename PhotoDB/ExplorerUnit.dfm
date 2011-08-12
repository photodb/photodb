object ExplorerForm: TExplorerForm
  Left = 148
  Top = 101
  VertScrollBar.Visible = False
  Caption = 'DB Explorer'
  ClientHeight = 613
  ClientWidth = 867
  Color = clBtnFace
  Constraints.MinHeight = 200
  Constraints.MinWidth = 300
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnDeactivate = FormDeactivate
  OnShow = FormShow
  DesignSize = (
    867
    613)
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 135
    Top = 48
    Width = 5
    Height = 545
    Constraints.MaxWidth = 150
    OnCanResize = Splitter1CanResize
    ExplicitLeft = 150
    ExplicitTop = 47
    ExplicitHeight = 546
  end
  object BvSeparatorLeftPanel: TBevel
    Left = 140
    Top = 48
    Width = 2
    Height = 545
    Align = alLeft
    Shape = bsRightLine
    ExplicitLeft = 148
    ExplicitTop = 53
  end
  object MainPanel: TPanel
    Left = 0
    Top = 48
    Width = 135
    Height = 545
    Align = alLeft
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 0
    object CloseButtonPanel: TPanel
      Left = 0
      Top = 0
      Width = 135
      Height = 21
      Align = alTop
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = True
      ParentFont = False
      TabOrder = 0
      Visible = False
      OnResize = CloseButtonPanelResize
      object BtnCloseExplorer: TButton
        Left = 101
        Top = 3
        Width = 15
        Height = 15
        Caption = 'x'
        TabOrder = 0
        OnClick = BtnCloseExplorerClick
      end
    end
    object PropertyPanel: TPanel
      Left = 0
      Top = 21
      Width = 135
      Height = 524
      Align = alClient
      BevelOuter = bvNone
      Color = clInactiveCaption
      Ctl3D = True
      ParentCtl3D = False
      TabOrder = 1
      OnResize = PropertyPanelResize
      object ScrollBox1: TScrollPanel
        Left = 0
        Top = 0
        Width = 135
        Height = 524
        HorzScrollBar.Increment = 10
        HorzScrollBar.Visible = False
        VertScrollBar.Smooth = True
        VertScrollBar.Tracking = True
        DefaultDraw = True
        BackGroundTransparent = 0
        OnReallign = ScrollBox1Reallign
        BackgroundLeft = 0
        BackgroundTop = 0
        UpdatingPanel = False
        Align = alClient
        BevelOuter = bvNone
        FullRepaint = False
        Caption = 'ScrollBox1'
        TabOrder = 0
        OnResize = ScrollBox1Resize
        object TypeLabel: TLabel
          Left = 7
          Top = 141
          Width = 49
          Height = 13
          Caption = 'TypeLabel'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object TasksLabel: TLabel
          Tag = 1
          Left = 8
          Top = 224
          Width = 33
          Height = 13
          Caption = 'Tasks'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object SizeLabel: TLabel
          Left = 7
          Top = 157
          Width = 44
          Height = 13
          Caption = 'SizeLabel'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object RatingLabel: TLabel
          Left = 8
          Top = 192
          Width = 31
          Height = 13
          Caption = 'Rating'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object OtherPlacesLabel: TLabel
          Tag = 1
          Left = 8
          Top = 425
          Width = 71
          Height = 13
          Caption = 'Other Places'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object NameLabel: TLabel
          Tag = 1
          Left = 7
          Top = 148
          Width = 62
          Height = 13
          Caption = 'NameLabel'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          WordWrap = True
        end
        object Label1: TLabel
          Left = 10
          Top = 8
          Width = 97
          Height = 13
          AutoSize = False
          Caption = 'Image Preview:'
        end
        object ImPreview: TImage
          Left = 10
          Top = 24
          Width = 118
          Height = 118
          ParentCustomHint = False
          OnContextPopup = ImPreviewContextPopup
          OnDblClick = ImPreviewDblClick
        end
        object IDLabel: TLabel
          Left = 8
          Top = 176
          Width = 36
          Height = 13
          Caption = 'IDLabel'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object DimensionsLabel: TLabel
          Left = 7
          Top = 149
          Width = 78
          Height = 13
          Caption = 'DimensionsLabel'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object DBInfoLabel: TLabel
          Tag = 2
          Left = 8
          Top = 168
          Width = 73
          Height = 13
          Caption = 'DataBase Info:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object AccessLabel: TLabel
          Left = 8
          Top = 208
          Width = 58
          Height = 13
          Caption = 'AccessLabel'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object SlideShowLink: TWebLink
          Left = 5
          Top = 237
          Width = 56
          Height = 13
          Cursor = crHandPoint
          Text = 'Slide Show'
          OnClick = SlideShowLinkClick
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
        object ShellLink: TWebLink
          Left = 5
          Top = 285
          Width = 31
          Height = 13
          Cursor = crHandPoint
          Text = 'Open'
          OnClick = Open1Click
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
        object RenameLink: TWebLink
          Left = 5
          Top = 333
          Width = 44
          Height = 13
          Cursor = crHandPoint
          Text = 'Rename'
          OnClick = Rename1Click
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
        object RefreshLink: TWebLink
          Left = 5
          Top = 366
          Width = 43
          Height = 13
          Cursor = crHandPoint
          Text = 'Refresh'
          OnClick = RefreshLinkClick
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
        object PropertiesLink: TWebLink
          Left = 5
          Top = 349
          Width = 54
          Height = 13
          Cursor = crHandPoint
          Text = 'Properties'
          OnClick = PropertiesLinkClick
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
        object PrintLink: TWebLink
          Left = 5
          Top = 269
          Width = 27
          Height = 13
          Cursor = crHandPoint
          Text = 'Print'
          OnClick = PrintLinkClick
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
        object MyPicturesLink: TWebLink
          Left = 5
          Top = 454
          Width = 60
          Height = 13
          Cursor = crHandPoint
          OnContextPopup = MyPicturesLinkContextPopup
          Text = 'My Pictures'
          OnClick = MyPicturesLinkClick
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
        object MyDocumentsLink: TWebLink
          Left = 5
          Top = 470
          Width = 75
          Height = 13
          Cursor = crHandPoint
          OnContextPopup = MyPicturesLinkContextPopup
          Text = 'My Documents'
          OnClick = MyDocumentsLinkClick
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
        object MyComputerLink: TWebLink
          Left = 5
          Top = 438
          Width = 69
          Height = 13
          Cursor = crHandPoint
          OnContextPopup = MyPicturesLinkContextPopup
          Text = 'My Computer'
          OnClick = MyComputerLinkClick
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
        object MoveToLink: TWebLink
          Left = 5
          Top = 317
          Width = 46
          Height = 13
          Cursor = crHandPoint
          Text = 'Move To'
          OnClick = MoveToLinkClick
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
        object ImageEditorLink: TWebLink
          Left = 5
          Top = 253
          Width = 66
          Height = 13
          Cursor = crHandPoint
          Text = 'Image Editor'
          OnClick = ImageEditorLinkClick
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
        object DesktopLink: TWebLink
          Left = 5
          Top = 486
          Width = 44
          Height = 13
          Cursor = crHandPoint
          OnContextPopup = MyPicturesLinkContextPopup
          Text = 'Desktop'
          OnClick = DesktopLinkClick
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
        object DeleteLink: TWebLink
          Left = 5
          Top = 382
          Width = 36
          Height = 13
          Cursor = crHandPoint
          Text = 'Delete'
          OnClick = DeleteLinkClick
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
        object CopyToLink: TWebLink
          Left = 5
          Top = 301
          Width = 45
          Height = 13
          Cursor = crHandPoint
          Text = 'Copy To'
          OnClick = CopyToLinkClick
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
        object AddLink: TWebLink
          Left = 5
          Top = 398
          Width = 59
          Height = 13
          Cursor = crHandPoint
          Text = 'Add Object'
          OnClick = AddLinkClick
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
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 593
    Width = 867
    Height = 20
    Panels = <
      item
        Width = 200
      end
      item
        Width = 150
      end>
  end
  object CoolBarTop: TCoolBar
    Left = 0
    Top = 0
    Width = 867
    Height = 21
    AutoSize = True
    BandBorderStyle = bsNone
    Bands = <
      item
        Control = ToolBar1
        ImageIndex = -1
        MinHeight = 21
        Width = 865
      end>
    EdgeBorders = []
    object ToolBar1: TToolBar
      Left = 11
      Top = 0
      Width = 856
      Height = 21
      ButtonHeight = 19
      ButtonWidth = 48
      Color = clInactiveCaption
      EdgeInner = esNone
      EdgeOuter = esNone
      List = True
      ParentColor = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      Transparent = True
      Wrapable = False
      OnMouseMove = ToolBar1MouseMove
      object TbBack: TToolButton
        Left = 0
        Top = 0
        AutoSize = True
        DropdownMenu = PopupMenuBack
        ImageIndex = 0
        Style = tbsDropDown
        OnClick = SpeedButton1Click
      end
      object TbForward: TToolButton
        Left = 33
        Top = 0
        AutoSize = True
        DropdownMenu = PopupMenuForward
        ImageIndex = 2
        Style = tbsDropDown
        OnClick = SpeedButton2Click
      end
      object TbUp: TToolButton
        Left = 66
        Top = 0
        AutoSize = True
        ImageIndex = 1
        OnClick = SpeedButton3Click
      end
      object ToolButton4: TToolButton
        Left = 78
        Top = 0
        Width = 8
        Caption = 'ToolButton3'
        ImageIndex = 10
        Style = tbsSeparator
      end
      object TbCut: TToolButton
        Left = 86
        Top = 0
        AutoSize = True
        ImageIndex = 3
        OnClick = Cut3Click
      end
      object TbCopy: TToolButton
        Left = 98
        Top = 0
        AutoSize = True
        ImageIndex = 4
        OnClick = Copy3Click
      end
      object TbPaste: TToolButton
        Left = 110
        Top = 0
        AutoSize = True
        ImageIndex = 5
        OnClick = Paste3Click
      end
      object ToolButton17: TToolButton
        Left = 122
        Top = 0
        Width = 8
        Caption = 'ToolButton17'
        ImageIndex = 7
        Style = tbsSeparator
      end
      object TbDelete: TToolButton
        Left = 130
        Top = 0
        AutoSize = True
        ImageIndex = 6
        OnClick = DeleteLinkClick
      end
      object ToolButton10: TToolButton
        Left = 142
        Top = 0
        Width = 8
        Caption = 'ToolButton10'
        ImageIndex = 7
        Style = tbsSeparator
      end
      object ToolButtonView: TToolButton
        Left = 150
        Top = 0
        AutoSize = True
        DropdownMenu = PmListViewType
        ImageIndex = 7
        Style = tbsDropDown
        OnClick = ToolButtonViewClick
      end
      object ToolButton11: TToolButton
        Left = 183
        Top = 0
        Width = 8
        Caption = 'ToolButton11'
        ImageIndex = 7
        Style = tbsSeparator
      end
      object TbZoomOut: TToolButton
        Left = 191
        Top = 0
        AutoSize = True
        ImageIndex = 8
        OnClick = TbZoomOutClick
      end
      object TbZoomIn: TToolButton
        Left = 203
        Top = 0
        AutoSize = True
        DropdownMenu = PopupMenuZoomDropDown
        ImageIndex = 9
        Style = tbsDropDown
        OnClick = TbZoomInClick
      end
      object ToolButton20: TToolButton
        Left = 236
        Top = 0
        Width = 8
        Caption = 'ToolButton20'
        ImageIndex = 13
        Style = tbsSeparator
      end
      object TbSearch: TToolButton
        Left = 244
        Top = 0
        AutoSize = True
        ImageIndex = 10
        OnClick = GoToSearchWindow1Click
      end
      object ToolButton16: TToolButton
        Left = 256
        Top = 0
        Width = 8
        Caption = 'ToolButton16'
        ImageIndex = 8
        Style = tbsSeparator
      end
      object TbOptions: TToolButton
        Left = 264
        Top = 0
        AutoSize = True
        Caption = 'Options'
        ImageIndex = 11
        OnClick = Options1Click
      end
    end
  end
  object LsMain: TLoadingSign
    Left = 842
    Top = 49
    Width = 20
    Height = 20
    Visible = False
    Active = True
    FillPercent = 50
    Anchors = [akTop, akRight]
    SignColor = clBlack
    MaxTransparencity = 255
  end
  object PnNavigation: TPanel
    Left = 0
    Top = 21
    Width = 867
    Height = 27
    Align = alTop
    AutoSize = True
    BevelEdges = [beBottom]
    Color = clWindow
    ParentBackground = False
    TabOrder = 4
    object BvSeparatorAddress: TBevel
      Left = 59
      Top = 1
      Width = 2
      Height = 25
      Align = alRight
      Shape = bsRightLine
      ExplicitLeft = 46
      ExplicitTop = 0
    end
    object PePath: TPathEditor
      Left = 61
      Top = 1
      Width = 805
      Height = 25
      DoubleBuffered = False
      ParentDoubleBuffered = False
      Align = alRight
      Anchors = [akLeft, akTop, akRight, akBottom]
      SeparatorImage.Data = {
        9E020000424D9E0200000000000036000000280000000B0000000E0000000100
        2000000000006802000000000000000000000000000000000000000000000000
        0000898989058A8A890500000000000000000000000000000000000000000000
        000000000000000000008A8A8B058A8A8ACC8A8A89CC8A8A8B05000000000000
        0000000000000000000000000000000000000000000089898997898989FF8889
        89FF8A8A89CC8989890500000000000000000000000000000000000000000000
        00008A8A8A038A8A8ABC8A8B8BFF898989FF888989CC89898905000000000000
        000000000000000000000000000000000000888989038A8A89BC8A8A8AFF8A8A
        89FF8A8A89CC8A8A890500000000000000000000000000000000000000000000
        000089898903898989BC8A8A89FF8A8A8AFF8A8A8ACC8A8A8A05000000000000
        0000000000000000000000000000000000008A8A8A03898A8ADC898989FF8989
        89FF8A8A8ACC8989890100000000000000000000000000000000000000008989
        8947898989FF898989FF8A8B8BFF898989380000000000000000000000000000
        000000000000898989478A8A8AFF898989FF8A8A8AFF89898938000000000000
        00000000000000000000000000008A8A8A448A8A8AFF898A89FF8A8A8BFF8989
        893B00000000000000000000000000000000000000008A8A8A448A8A89FF8A8A
        8AFF8A8A8AFF8889893B00000000000000000000000000000000000000000000
        00008989893E898989FF8A8A8AFF8A8A8A3E0000000000000000000000000000
        0000000000000000000000000000000000008989893E8989893E000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000}
      OnUserChange = PePathChange
      OnUpdateItem = PePathUpdateItem
      LoadingText = 'Loading...'
      NetworksText = 'Networks'
      GetSystemIcon = PePathGetSystemIcon
      CanBreakLoading = False
      OnBreakLoading = TbStopClick
    end
    object StAddress: TStaticText
      Left = 9
      Top = 5
      Width = 47
      Height = 17
      Caption = 'Address:'
      TabOrder = 1
    end
  end
  object SizeImageList: TImageList
    Height = 102
    Width = 102
    Left = 200
    Top = 208
  end
  object PmItemPopup: TPopupMenu
    OnPopup = PmItemPopupPopup
    Left = 360
    Top = 552
    object Open1: TMenuItem
      Caption = 'Open'
      OnClick = Open1Click
    end
    object SlideShow1: TMenuItem
      Caption = 'Show'
      OnClick = SlideShow1Click
    end
    object NewWindow1: TMenuItem
      Caption = 'New Window'
      Visible = False
      OnClick = NewWindow1Click
    end
    object Shell1: TMenuItem
      Caption = 'Shell'
      OnClick = Shell1Click
    end
    object DBitem1: TMenuItem
      Caption = 'DBitem'
    end
    object N8: TMenuItem
      Caption = '-'
    end
    object Copy1: TMenuItem
      Caption = 'Copy'
      OnClick = Copy1Click
    end
    object Cut2: TMenuItem
      Caption = 'Cut'
      OnClick = Cut2Click
    end
    object Paste2: TMenuItem
      Caption = 'Paste'
      OnClick = Paste2Click
    end
    object Delete1: TMenuItem
      Caption = 'Delete'
      OnClick = Delete1Click
    end
    object N7: TMenuItem
      Caption = '-'
    end
    object Rename1: TMenuItem
      Caption = 'Rename'
      OnClick = Rename1Click
    end
    object New1: TMenuItem
      Caption = 'New'
      Visible = False
      object Directory1: TMenuItem
        Caption = 'Directory'
      end
      object TextFile1: TMenuItem
        Caption = 'Text File'
      end
    end
    object Refresh1: TMenuItem
      Caption = 'Refresh'
      OnClick = Refresh1Click
    end
    object RefreshID1: TMenuItem
      Caption = 'Refresh ID'
      OnClick = RefreshID1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object ImageEditor2: TMenuItem
      Caption = 'Image Editor'
      OnClick = ImageEditor2Click
    end
    object Print1: TMenuItem
      Caption = 'Print'
      OnClick = PrintLinkClick
    end
    object Resize1: TMenuItem
      Caption = 'Resize'
      OnClick = Resize1Click
    end
    object Rotate1: TMenuItem
      Caption = 'Rotate Image'
      object AsEXIF1: TMenuItem
        Caption = 'By EXIF'
        OnClick = AsEXIF1Click
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object RotateCCW1: TMenuItem
        Caption = 'Rotate CCW'
        OnClick = RotateCCW1Click
      end
      object RotateCW1: TMenuItem
        Caption = 'Rotate CW'
        OnClick = RotateCW1Click
      end
      object Rotateon1801: TMenuItem
        Caption = 'Rotate on 180*'
        OnClick = Rotateon1801Click
      end
    end
    object SetasDesktopWallpaper1: TMenuItem
      Caption = 'Set as Desktop Wallpaper'
      object Stretch1: TMenuItem
        Caption = 'Stretch'
        OnClick = Stretch1Click
      end
      object Center1: TMenuItem
        Caption = 'Center'
        OnClick = Center1Click
      end
      object Tile1: TMenuItem
        Caption = 'Tile'
        OnClick = Tile1Click
      end
    end
    object Othertasks1: TMenuItem
      Caption = 'Other tasks'
      object Convert1: TMenuItem
        Caption = 'Convert'
        OnClick = Convert1Click
      end
      object ExportImages1: TMenuItem
        Caption = 'Export Images'
        OnClick = ExportImages1Click
      end
      object Copywithfolder1: TMenuItem
        Caption = 'Copy with folder'
        OnClick = Copywithfolder1Click
      end
    end
    object MakeFolderViewer2: TMenuItem
      Caption = 'Make FolderViewer'
      OnClick = MakeFolderViewer2Click
    end
    object StenoGraphia1: TMenuItem
      Caption = 'StenoGraphia'
      object AddHiddenInfo1: TMenuItem
        Caption = 'Add Hidden Info'
        OnClick = AddHiddenInfo1Click
      end
      object ExtractHiddenInfo1: TMenuItem
        Caption = 'Extract Hidden Info'
        OnClick = ExtractHiddenInfo1Click
      end
    end
    object N12: TMenuItem
      Caption = '-'
    end
    object SendTo1: TMenuItem
      Caption = 'Send To'
      OnClick = SendTo1Click
      object N18: TMenuItem
        Caption = '-'
      end
    end
    object N17: TMenuItem
      Caption = '-'
    end
    object EnterPassword1: TMenuItem
      Caption = 'Enter Password'
      OnClick = EnterPassword1Click
    end
    object CryptFile1: TMenuItem
      Caption = 'Crypt File'
      OnClick = CryptFile1Click
    end
    object ResetPassword1: TMenuItem
      Caption = 'Reset Password'
      OnClick = ResetPassword1Click
    end
    object N10: TMenuItem
      Caption = '-'
    end
    object AddFile1: TMenuItem
      Caption = 'Add File'
      OnClick = AddFile1Click
    end
    object N13: TMenuItem
      Caption = '-'
    end
    object MapCD1: TMenuItem
      Caption = 'Map CD'
      Visible = False
      OnClick = MapCD1Click
    end
    object Properties1: TMenuItem
      Caption = 'Properties'
      OnClick = Properties1Click
    end
  end
  object PmListPopup: TPopupMenu
    OnPopup = PmListPopupPopup
    Left = 360
    Top = 504
    object OpenInNewWindow1: TMenuItem
      Caption = 'Open In New Window'
      OnClick = OpenInNewWindow1Click
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object Copy2: TMenuItem
      Caption = 'Copy'
      OnClick = Copy2Click
    end
    object Cut1: TMenuItem
      Caption = 'Cut'
      OnClick = Cut1Click
    end
    object Paste1: TMenuItem
      Caption = 'Paste'
      OnClick = Paste1Click
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object Addfolder1: TMenuItem
      Caption = 'Add Folder'
      OnClick = Addfolder1Click
    end
    object MakeNew1: TMenuItem
      Caption = 'Make New'
      object Directory2: TMenuItem
        Caption = 'Directory'
        OnClick = MakeNewFolder1Click
      end
      object TextFile2: TMenuItem
        Caption = 'Text File'
        OnClick = TextFile2Click
      end
    end
    object MakeFolderViewer1: TMenuItem
      Caption = 'Make FolderViewer'
      OnClick = MakeFolderViewer1Click
    end
    object ShowUpdater1: TMenuItem
      Caption = 'Show Updater'
      OnClick = ShowUpdater1Click
    end
    object OpeninSearchWindow1: TMenuItem
      Caption = 'Open in Search Window'
      OnClick = OpeninSearchWindow1Click
    end
    object Refresh2: TMenuItem
      Caption = 'Refresh'
      OnClick = Refresh2Click
    end
    object SelectAll1: TMenuItem
      Caption = 'Select All'
      OnClick = SelectAll1Click
    end
    object N19: TMenuItem
      Caption = '-'
    end
    object Sortby1: TMenuItem
      Caption = 'Sort by'
      object Nosorting1: TMenuItem
        Tag = -1
        Caption = 'No Sorting'
        OnClick = FileName1Click
      end
      object FileName1: TMenuItem
        Caption = 'File Name'
        OnClick = FileName1Click
      end
      object Rating1: TMenuItem
        Tag = 1
        Caption = 'Rating'
        OnClick = FileName1Click
      end
      object Size1: TMenuItem
        Tag = 2
        Caption = 'Size'
        OnClick = FileName1Click
      end
      object Type1: TMenuItem
        Tag = 3
        Caption = 'Type'
        OnClick = FileName1Click
      end
      object Modified1: TMenuItem
        Tag = 4
        Caption = 'Modified'
        OnClick = FileName1Click
      end
      object Number1: TMenuItem
        Tag = 5
        Caption = 'Number'
        OnClick = FileName1Click
      end
    end
    object SetFilter1: TMenuItem
      Caption = 'Set Filter'
      OnClick = SetFilter1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object GoToSearchWindow1: TMenuItem
      Caption = 'Go To Search Window'
      OnClick = GoToSearchWindow1Click
    end
    object Exit2: TMenuItem
      Caption = 'Exit'
      OnClick = Exit2Click
    end
  end
  object HintTimer: TTimer
    OnTimer = HintTimerTimer
    Left = 536
    Top = 200
  end
  object SaveWindowPos1: TSaveWindowPos
    SetOnlyPosition = False
    RootKey = HKEY_CURRENT_USER
    Key = 'Software\Positions\Noname'
    Left = 200
    Top = 56
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 753
    Top = 72
  end
  object PopupMenu8: TPopupMenu
    OnPopup = PopupMenu8Popup
    Left = 361
    Top = 152
    object OpeninExplorer1: TMenuItem
      Caption = 'Open in Explorer'
      OnClick = OpeninExplorer1Click
    end
    object AddFolder2: TMenuItem
      Caption = 'Add Folder'
      OnClick = AddFolder2Click
    end
    object View2: TMenuItem
      Caption = 'View'
      OnClick = View2Click
    end
  end
  object ToolBarNormalImageList: TImageList
    ColorDepth = cd32Bit
    Height = 32
    Width = 32
    Left = 200
    Top = 404
  end
  object PopupMenuBack: TPopupMenu
    Left = 360
    Top = 452
  end
  object PopupMenuForward: TPopupMenu
    Left = 360
    Top = 404
  end
  object DragTimer: TTimer
    Interval = 100
    OnTimer = DragTimerTimer
    Left = 536
    Top = 356
  end
  object ToolBarDisabledImageList: TImageList
    ColorDepth = cd32Bit
    Height = 32
    Width = 32
    Left = 201
    Top = 156
  end
  object DropFileTarget1: TDropFileTarget
    DragTypes = [dtCopy, dtMove]
    OnEnter = DropFileTarget1Enter
    OnLeave = DropFileTarget1Leave
    OnDrop = DropFileTarget1Drop
    MultiTarget = True
    AutoRegister = False
    OptimizedMove = True
    Left = 648
    Top = 168
  end
  object DropFileSourceMain: TDropFileSource
    DragTypes = [dtCopy, dtMove, dtLink]
    Images = DragImageList
    ShowImage = True
    Left = 648
    Top = 120
  end
  object DragImageList: TImageList
    ColorDepth = cd32Bit
    DrawingStyle = dsTransparent
    Height = 102
    Width = 102
    Left = 200
    Top = 256
  end
  object DropFileTarget2: TDropFileTarget
    DragTypes = []
    AutoRegister = False
    OptimizedMove = True
    Left = 648
    Top = 72
  end
  object HelpTimer: TTimer
    Interval = 2000
    OnTimer = HelpTimerTimer
    Left = 536
    Top = 456
  end
  object PmLinkOptions: TPopupMenu
    Left = 360
    Top = 104
    object Open2: TMenuItem
      Caption = 'Open'
      OnClick = Open2Click
    end
    object OpeninNewWindow2: TMenuItem
      Caption = 'Open in New Window'
      OnClick = OpeninNewWindow2Click
    end
  end
  object PmDragMode: TPopupMenu
    Left = 360
    Top = 200
    object Copy4: TMenuItem
      Caption = 'Copy'
      OnClick = Copy4Click
    end
    object Move1: TMenuItem
      Caption = 'Move'
      OnClick = Copy4Click
    end
    object N15: TMenuItem
      Caption = '-'
    end
    object Cancel1: TMenuItem
      Caption = 'Cancel'
    end
  end
  object SelectTimer: TTimer
    Enabled = False
    Interval = 55
    OnTimer = SelectTimerTimer
    Left = 535
    Top = 300
  end
  object ScriptMainMenu: TMainMenu
    Left = 361
    Top = 56
  end
  object CloseTimer: TTimer
    Enabled = False
    Interval = 1
    OnTimer = CloseTimerTimer
    Left = 536
    Top = 408
  end
  object RatingPopupMenu1: TPopupMenu
    Left = 361
    Top = 352
    object N00: TMenuItem
      Caption = '0'
      OnClick = N05Click
    end
    object N01: TMenuItem
      Tag = 1
      Caption = '1'
      OnClick = N05Click
    end
    object N02: TMenuItem
      Tag = 2
      Caption = '2'
      OnClick = N05Click
    end
    object N03: TMenuItem
      Tag = 3
      Caption = '3'
      OnClick = N05Click
    end
    object N04: TMenuItem
      Tag = 4
      Caption = '4'
      OnClick = N05Click
    end
    object N05: TMenuItem
      Tag = 5
      Caption = '5'
      OnClick = N05Click
    end
  end
  object PmListViewType: TPopupMenu
    Left = 360
    Top = 296
    object Thumbnails1: TMenuItem
      Caption = 'Thumbnails'
      Checked = True
      GroupIndex = 1
      RadioItem = True
      OnClick = Thumbnails1Click
    end
    object Tile2: TMenuItem
      Caption = 'Tile'
      GroupIndex = 1
      RadioItem = True
      OnClick = Tile2Click
    end
    object Icons1: TMenuItem
      Caption = 'Icons'
      GroupIndex = 1
      RadioItem = True
      OnClick = Icons1Click
    end
    object List1: TMenuItem
      Caption = 'List'
      GroupIndex = 1
      RadioItem = True
      OnClick = List1Click
    end
    object SmallIcons1: TMenuItem
      Caption = 'Small Icons'
      GroupIndex = 1
      RadioItem = True
      OnClick = SmallIcons1Click
    end
    object Grid1: TMenuItem
      Caption = 'Grid'
      GroupIndex = 1
      RadioItem = True
      Visible = False
      OnClick = Grid1Click
    end
  end
  object BigIconsImageList: TImageList
    Height = 32
    Width = 32
    Left = 200
    Top = 304
  end
  object SmallIconsImageList: TImageList
    Left = 200
    Top = 352
  end
  object BigImagesTimer: TTimer
    Enabled = False
    Interval = 200
    OnTimer = BigImagesTimerTimer
    Left = 538
    Top = 251
  end
  object PopupMenuZoomDropDown: TPopupMenu
    OnPopup = PopupMenuZoomDropDownPopup
    Left = 362
    Top = 242
  end
end
