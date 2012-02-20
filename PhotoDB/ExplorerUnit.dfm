object ExplorerForm: TExplorerForm
  Left = 137
  Top = 225
  VertScrollBar.Visible = False
  Caption = 'DB Explorer'
  ClientHeight = 627
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
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnDeactivate = FormDeactivate
  OnShow = FormShow
  DesignSize = (
    867
    627)
  PixelsPerInch = 96
  TextHeight = 13
  object SplLeftPanel: TSplitter
    Left = 135
    Top = 48
    Width = 5
    Height = 559
    Constraints.MaxWidth = 150
    OnCanResize = SplLeftPanelCanResize
    ExplicitLeft = 150
    ExplicitTop = 47
    ExplicitHeight = 546
  end
  object BvSeparatorLeftPanel: TBevel
    Left = 140
    Top = 48
    Width = 1
    Height = 559
    Align = alLeft
    Shape = bsRightLine
    Style = bsRaised
    ExplicitHeight = 545
  end
  object MainPanel: TPanel
    Left = 0
    Top = 48
    Width = 135
    Height = 559
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
      Height = 538
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
        Height = 538
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
          WordWrap = True
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
          Top = 455
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
          Top = 5
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
          Width = 72
          Height = 16
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
          StretchImage = True
          CanClick = True
        end
        object ShellLink: TWebLink
          Left = 5
          Top = 284
          Width = 47
          Height = 16
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
          StretchImage = True
          CanClick = True
        end
        object RenameLink: TWebLink
          Left = 5
          Top = 365
          Width = 60
          Height = 16
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
          StretchImage = True
          CanClick = True
        end
        object RefreshLink: TWebLink
          Left = 5
          Top = 398
          Width = 59
          Height = 16
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
          StretchImage = True
          CanClick = True
        end
        object PropertiesLink: TWebLink
          Left = 5
          Top = 381
          Width = 70
          Height = 16
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
          StretchImage = True
          CanClick = True
        end
        object PrintLink: TWebLink
          Left = 5
          Top = 269
          Width = 43
          Height = 16
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
          StretchImage = True
          CanClick = True
        end
        object MyPicturesLink: TWebLink
          Left = 3
          Top = 484
          Width = 76
          Height = 16
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
          StretchImage = True
          CanClick = True
        end
        object MyDocumentsLink: TWebLink
          Left = 3
          Top = 500
          Width = 91
          Height = 16
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
          StretchImage = True
          CanClick = True
        end
        object MyComputerLink: TWebLink
          Left = 3
          Top = 468
          Width = 85
          Height = 16
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
          StretchImage = True
          CanClick = True
        end
        object MoveToLink: TWebLink
          Left = 5
          Top = 349
          Width = 62
          Height = 16
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
          StretchImage = True
          CanClick = True
        end
        object ImageEditorLink: TWebLink
          Left = 5
          Top = 253
          Width = 82
          Height = 16
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
          StretchImage = True
          CanClick = True
        end
        object DesktopLink: TWebLink
          Left = 3
          Top = 516
          Width = 60
          Height = 16
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
          StretchImage = True
          CanClick = True
        end
        object DeleteLink: TWebLink
          Left = 5
          Top = 414
          Width = 52
          Height = 16
          Cursor = crHandPoint
          Text = 'Delete'
          OnClick = Delete1Click
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
          StretchImage = True
          CanClick = True
        end
        object CopyToLink: TWebLink
          Left = 5
          Top = 333
          Width = 61
          Height = 16
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
          StretchImage = True
          CanClick = True
        end
        object AddLink: TWebLink
          Left = 5
          Top = 430
          Width = 75
          Height = 16
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
          StretchImage = True
          CanClick = True
        end
        object EncryptLink: TWebLink
          Left = 5
          Top = 300
          Width = 58
          Height = 16
          Cursor = crHandPoint
          Text = 'Encrypt'
          OnClick = EncryptLinkClick
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
          StretchImage = True
          CanClick = True
        end
        object WlCreateObject: TWebLink
          Left = 5
          Top = 315
          Width = 54
          Height = 16
          Cursor = crHandPoint
          Text = 'Create'
          Visible = False
          OnClick = WlCreateObjectClick
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
          StretchImage = True
          CanClick = True
        end
      end
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 607
    Width = 867
    Height = 20
    Panels = <
      item
        Width = 200
      end
      item
        Width = 500
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
        OnClick = CutClick
      end
      object TbCopy: TToolButton
        Left = 98
        Top = 0
        AutoSize = True
        ImageIndex = 4
        OnClick = CopyClick
      end
      object TbPaste: TToolButton
        Left = 110
        Top = 0
        AutoSize = True
        ImageIndex = 5
        OnClick = PasteClick
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
        OnClick = TbDeleteClick
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
      Left = 676
      Top = 1
      Width = 2
      Height = 25
      Align = alRight
      Shape = bsRightLine
      ExplicitLeft = 668
      ExplicitTop = 6
    end
    object BvSeparatorSearch: TBevel
      Left = 60
      Top = 1
      Width = 2
      Height = 25
      Align = alLeft
      Shape = bsRightLine
      ExplicitTop = 2
    end
    object slSearch: TSplitter
      Left = 678
      Top = 1
      Height = 25
      Align = alRight
      Beveled = True
      OnCanResize = slSearchCanResize
      ExplicitLeft = 668
      ExplicitTop = 6
    end
    object PnSearch: TPanel
      Left = 681
      Top = 1
      Width = 185
      Height = 25
      Align = alRight
      BevelOuter = bvNone
      DoubleBuffered = True
      FullRepaint = False
      ParentDoubleBuffered = False
      TabOrder = 0
      object SbSearchMode: TSpeedButton
        Left = 0
        Top = 0
        Width = 30
        Height = 25
        Align = alLeft
        Constraints.MaxWidth = 30
        Constraints.MinWidth = 30
        Flat = True
        PopupMenu = PmSearchMode
        OnClick = SbSearchModeClick
        ExplicitLeft = 699
        ExplicitTop = 1
        ExplicitHeight = 24
      end
      object SbDoSearch: TSpeedButton
        Left = 165
        Top = 0
        Width = 20
        Height = 25
        Align = alRight
        Flat = True
        OnClick = SbDoSearchClick
        ExplicitLeft = 160
        ExplicitTop = 1
        ExplicitHeight = 23
      end
      object PnSearchEditPlace: TPanel
        Left = 30
        Top = 0
        Width = 135
        Height = 25
        Align = alClient
        BevelOuter = bvNone
        Ctl3D = False
        ParentCtl3D = False
        TabOrder = 0
        DesignSize = (
          135
          25)
        object WedSearch: TWatermarkedEdit
          Left = 2
          Top = 4
          Width = 130
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          BorderStyle = bsNone
          TabOrder = 0
          OnKeyPress = WedSearchKeyPress
          WatermarkText = 'Search in directory'
        end
      end
    end
    object StAddress: TStaticText
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 53
      Height = 19
      Align = alLeft
      Alignment = taCenter
      Caption = '  Address:'
      TabOrder = 1
    end
    object PePath: TPathEditor
      Left = 62
      Top = 1
      Width = 614
      Height = 25
      DoubleBuffered = False
      ParentDoubleBuffered = False
      Align = alClient
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
      GetSystemIcon = PePathGetSystemIcon
      CanBreakLoading = False
      OnBreakLoading = TbStopClick
      OnImageContextPopup = PePathImageContextPopup
      OnContextPopup = PePathContextPopup
      GetItemIconEvent = PePathGetItemIconEvent
      OnlyFileSystem = False
      HideExtendedButton = False
      ShowBorder = False
    end
  end
  object PnContent: TPanel
    Left = 141
    Top = 48
    Width = 726
    Height = 559
    Align = alClient
    BevelOuter = bvNone
    FullRepaint = False
    TabOrder = 5
    object PnFilter: TPanel
      Left = 0
      Top = 526
      Width = 726
      Height = 33
      Align = alBottom
      TabOrder = 0
      Visible = False
      object LbFilter: TLabel
        Left = 38
        Top = 9
        Width = 28
        Height = 13
        Caption = 'Filter:'
      end
      object LbFilterInfo: TLabel
        Left = 400
        Top = 9
        Width = 139
        Height = 13
        Caption = 'Sorry, but phrase not found!'
        Visible = False
      end
      object ImFilterWarning: TImage
        Left = 380
        Top = 8
        Width = 16
        Height = 16
        Picture.Data = {
          055449636F6E0000010001001010000001002000680400001600000028000000
          1000000020000000010020000000000040040000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000001D1505146B842650C0D6
          4175D3F93969CFF21536A5BF0004505F00000E03000000000000000000000000
          0000000000000000000000000000000000002F3F2851C7EB7EB9FDFFA7D3FFFF
          BDDFFFFFBADBFFFF94C1FEFF568EF1FF0D229BC400000E110000000000000000
          00000000000000000000000000002C28204DCFF4619EFBFF73AEFDFF9EC9FEFF
          FFFFFFFFFFFFFFFF86B5FCFF5C96F9FF3C79F4FF061A9AC400000E0300000000
          000000000000000000000000041A9AB82469F4FF3A7FF7FF4B8EF9FF7FB1FCFF
          FFFFFFFFFFFFFFFF649BF9FF3476F5FF1E5FF2FF0E47E8FF0002506300000000
          0000000000000000AAAAD61A0A36D2FF1457F1FF1960F3FF216AF4FF6197F8FF
          FFFFFFFFFFFFFFFF4680F6FF1659F1FF114FF0FF0C44EDFF0215AEC400000000
          0000000000000000AAAAD64C0A3FE8FF0F4BEFFF205DF1FF356FF3FF6B97F7FF
          FFFFFFFFFFFFFFFF5987F5FF2E63F1FF134AEEFF083AEBFF021EC4F600000000
          0000000000000000AAAAD6550636EAFF1F4FEEFF4973F2FF4B77F3FF799BF7FF
          FFFFFFFFFFFFFFFF688CF5FF4871F2FF4167F0FF0934E9FF001BC6FF00000000
          0000000000000000AAAAD6330122D9FF4869F0FF5B7CF2FF5D7EF3FF87A1F7FF
          FFFFFFFFFFFFFFFF7893F5FF5B79F2FF5975F1FF2A4DECFF0118B9DD00000000
          0000000000000000AAAAB8030116B9E65F79F1FF6E86F3FF6F87F3FF7890F4FF
          94A7F8FF94A6F8FF758CF3FF6F86F3FF718BF4FF4776F3FF020E7C9400000000
          000000000000000000000000000351685178EBFF88A1F7FF869DF6FFA4B5F9FF
          FFFFFFFFFFFFFFFF9CB1F9FF8BA9F9FF90B6FBFF2D5FD2F200001D1F00000000
          00000000000000000000000000000E0109198D9D7BACF4FFA4C7FDFFAFCCFDFF
          D5E7FFFFD6E8FFFFAFD2FEFFA8D3FEFF568DDFF900055E4F0000000000000000
          0000000000000000000000000000000000000E01040E65713F6CCBED7FBCF5FF
          98D4FFFF95D3FFFF6DA5E9FF264AB8D100003D3A000000000000000000000000
          0000000000000000000000000000000000000000000000005555630855558145
          555BB6685558A461555581310000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000FFFF0000FFFF0000F00F0000E0070000C0030000C003000080030000
          80030000800300008003000080030000C0030000C0070000E00F0000F83F0000
          FFFF0000}
        Visible = False
      end
      object WedFilter: TWatermarkedEdit
        Left = 72
        Top = 6
        Width = 150
        Height = 21
        TabOrder = 0
        OnChange = WedFilterChange
        OnKeyPress = WedFilterKeyPress
        WatermarkText = 'Filter content'
      end
      object ImbCloseFilter: TImButton
        Left = 4
        Top = 6
        Width = 21
        Height = 21
        ImageNormal.Data = {
          07544269746D61701A070000424D1A0700000000000036000000280000001500
          0000150000000100200000000000E40600000000000000000000000000000000
          0000F1621A00EFC6B500FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FDF6F400EFC6B500ED591A00EFC6B500D0D6EE002844
          B5000D2BA6001130AC001231AB001432A9001230A9001332AC001332AD001031
          AE000D30B1000A2EB200082DB400062AB1000328B1000127B4000024AE001F3C
          AC00CFD4EA00EFC6B500FDF6F4002849CD001338CC001B3ECC002144CF002547
          CF002647CF002446CF002347D0002146D1001E45D2001B45D5001642D5001340
          D6000E3DD5000939D6000435D5000130D100002AC2001F3CAB00FFFFFF00FFFF
          FF000E37D8001C43DB00284CDD002F52DE003355DF003457E0003155E0003156
          E0002E56E1002A55E2002553E4001F50E400194CE5001348E5000D43E500073E
          E4000238E000002FD1000023AA00FFFFFF00FFFFFF00143CDD00254BE0003154
          E100395BE3003D5EE4003D5FE4003B5EE400395EE500375EE500325DE6002C5B
          E7002557E8001F54E9001950E900114AE9000B44E800053DE4000233D6000126
          AF00FFFFFF00FFFFFF001840DE002E51E1003A5CE3004262E400B5C1F500FFFF
          FF004365E6004165E6003D64E6003862E7003260E8002A5CE9002459EA00FFFF
          FF00A1B8F7000E48E9000940E5000536D7000227B000FFFFFF00FFFFFF001E45
          DF003658E2004262E4004967E500FFFFFF00FFFFFF00FFFFFF004568E6004167
          E7003B64E7003562E8002D5EEA00FFFFFF00FFFFFF00FFFFFF00114AE9000D44
          E6000B3BD700062BB100FFFFFF00FFFFFF00254BE0003D5EE3004867E5004E6C
          E600506DE600FFFFFF00FFFFFF00FFFFFF004268E7003C65E7003662E800FFFF
          FF00FFFFFF00FFFFFF001950E900164CE8001347E400103FD8000A2DB100FFFF
          FF00FFFFFF002B4FE1004463E4004E6BE600526FE700536FE700516EE600FFFF
          FF00FFFFFF00FFFFFF003D65E700FFFFFF00FFFFFF00F1F5FE002154E8001B50
          E800184DE700184AE4001642D7000F31B200FFFFFF00FFFFFF003254E2004B69
          E5005470E7005671E7005570E800526FE7004D6CE600FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF002655E7002152E7001C4EE6001C4DE6001C4CE3001C46
          D6001233B000FFFFFF00FFFFFF003759E300516DE7005772E8005973E8005771
          E700526EE6004D6AE6004767E500FFFFFF00FFFFFF00FFFFFF002C57E5002653
          E5002250E5001E4DE5001F4DE500214EE2002149D6001635AF00FFFFFF00FFFF
          FF003C5DE3005974E8005D77E8005D76E8005972E700536FE6004E6BE500FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF002751E400234FE400204CE300224D
          E300254FE100254AD5001937AF00FFFFFF00FFFFFF004665E500607AE800627C
          E800607AE8005B74E800546EE700FFFFFF00FFFFFF00FFFFFF003A5CE300FFFF
          FF00FFFFFF00FFFFFF00244DE200224BE200254DE2002950E000294CD4001B39
          AE00FFFFFF00FFFFFF004665E5006881E9006A83EA00657EE9005E77E800FFFF
          FF00FFFFFF00FFFFFF004361E4003D5DE4003658E300FFFFFF00FFFFFF00FFFF
          FF00274EE2002A50E2002C51E0002A4DD3001C39AD00FFFFFF00FFFFFF004D6A
          E6006E87EB00708AEB006A83EA00FFFFFF00FFFFFF00FFFFFF004D68E5004764
          E400405FE4003A5BE3003456E200FFFFFF00FFFFFF00FFFFFF002D52E2002E52
          DF002C4DD3001D3AAD00FFFFFF00FFFFFF00526FE7007991EC007C93EC00718A
          EB00C2CCF700FFFFFF005972E700536DE7004D68E5004664E400415FE4003A5B
          E3003859E300FFFFFF00ADBBF3003155E2003053DF002C4ED3001D3AAD00FFFF
          FF00FFFFFF005874E800899DEE008DA1EF007F95ED00718AEB006A83EA00647D
          E9005E78E8005973E700546FE700516DE6004B68E5004A68E5004463E4003F60
          E4003A5CE3003456E0002A4CD2001836AC00FFFFFF00FFFFFF00657FE90097A9
          F0009AACF100899DEE007A91EC00728BEB006D85EA006881E900657EE800627C
          E900617BE9005D77E8005974E800526FE6004C6AE5004363E4003759E100284A
          D2001533AA00FFFFFF00FFFFFF00768DEC0090A3EF0094A6F000859AEE00758D
          EB006E87EA006881EA00667FE900627CE9005F79E8005E79E8005975E8005672
          E700506EE6004968E5003F60E4003255E0002346D000304BB600FDF6F400EFC6
          B500DCE1FA00738BEB00607BE9005571E7004D6AE6004866E5004261E4004463
          E4003E5FE4003E5FE4003B5CE3003B5CE3003356E2003356E2003053E200284D
          E0001F45DC003453D000D2D8EF00EFC6B500E35F1A00EFC6B500FDF6F400FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00EFC6
          B500D24F1A00}
        ImageEnter.Data = {
          07544269746D61701A070000424D1A0700000000000036000000280000001500
          0000150000000100200000000000E40600000000000000000000000000000000
          0000F75E0500F1B19300FDF7F500FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FDF6F300F0B09300F24F0500F2B29300D6D9F6004453
          D2002B3CC9002F3FCA003141CA003343CA003243CC003444CF003649D2003649
          D300374BD800364CDA00364DDC003349D900324ADE002F48DD002A40D6004051
          CF00D5D8F100F0B09300FDF6F3004858E800374AED003D4FEC004354EE004657
          ED004859ED00485AEE004B5EEF004E64F0005067F100526CF400516DF600516E
          F6004E6CF6004A6AF8004363F7003A58F3003049E5004051CD00FDF7F500FFFF
          FF003549FA004154FB004A5CFC005061FB005465FC005667FC00586AFC005C71
          FC006177FC00647EFD006783FD006685FE006486FE006084FE005A7FFE005176
          FE00476BFC003A57F2002A40D400FFFFFF00FFFFFF003A4FFF00495CFF005264
          FF00596AFF005E6EFF005F70FF006274FF00687CFF006D84FF00718BFF007491
          FF007496FF007195FF006D94FF00668DFF005C85FF005076FE004161F6002F46
          DA00FFFFFF00FFFFFF003F52FF005062FF005A6BFF006071FF00C1C7FF00FFFF
          FF006879FF006F83FF00748BFF007993FF007C9AFF007C9EFF007AA0FF00FFFF
          FF00C5D5FF00628BFF00567CFE004565F7003149DB00FFFFFF00FFFFFF004457
          FF005768FF006171FF006676FF00FFFFFF00FFFFFF00FFFFFF007286FF00788F
          FF007C96FF007E9CFF007EA0FF00FFFFFF00FFFFFF00FFFFFF00668EFF005A7F
          FE004B6AF700334ADA00FFFFFF00FFFFFF004A5CFF005D6EFF006676FF006B7A
          FF006E7DFF00FFFFFF00FFFFFF00FFFFFF007A90FF007C95FF007E9AFF00FFFF
          FF00FFFFFF00FFFFFF007096FF00688EFF005E81FE004F6CF600364DDA00FFFF
          FF00FFFFFF004D5FFF006373FF006C7BFF00707FFF007281FF007080FF00FFFF
          FF00FFFFFF00FFFFFF007992FF00FFFFFF00FFFFFF00F6F8FF006F93FF006C90
          FF006789FF005F7FFE00526EF500394FD800FFFFFF00FFFFFF005365FF006A79
          FF007181FF007483FF007483FF007382FF007182FF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF006C8CFF006989FF006586FF006282FF005E7CFD00546D
          F4003B4FD600FFFFFF00FFFFFF00596AFF00707FFF007685FF007887FF007786
          FF007483FF007181FF007182FF00FFFFFF00FFFFFF00FFFFFF006983FF006581
          FF00617EFF005F7DFF005F7BFF005D77FD00536AF3003C4ED300FFFFFF00FFFF
          FF005D6DFF007785FF007D8BFF007C8BFF007A88FF007685FF007281FF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF005D77FF005A74FF005973FF005A73
          FF005A71FD005267F1003C4ED200FFFFFF00FFFFFF006575FF007E8CFF008390
          FF00818EFF007D8BFF007786FF00FFFFFF00FFFFFF00FFFFFF006476FF00FFFF
          FF00FFFFFF00FFFFFF00536AFF005369FF00556BFF00566BFD005063F0003B4C
          CF00FFFFFF00FFFFFF006676FF008592FF008A96FF008794FF00828FFF00FFFF
          FF00FFFFFF00FFFFFF006879FF006374FF005D6FFF00FFFFFF00FFFFFF00FFFF
          FF005064FF005265FF005366FD004E60F0003B4ACE00FFFFFF00FFFFFF006B7A
          FF008E99FF00929DFF008D99FF00FFFFFF00FFFFFF00FFFFFF007180FF006B7A
          FF006474FF005E6FFF00586AFF00FFFFFF00FFFFFF00FFFFFF005164FF005164
          FD004D5EEE003A4ACE00FFFFFF00FFFFFF00707FFF0095A0FF009BA5FF00949F
          FF00D1D5FF00FFFFFF007C8AFF007584FF006F7EFF006878FF006373FF005D6E
          FF005B6CFF00FFFFFF00BBC2FF005465FF005364FC004D5DEE003949CD00FFFF
          FF00FFFFFF007785FF00A0AAFF00A6B0FF009EA8FF00939EFF008D98FF008592
          FF007F8DFF007988FF007583FF007180FF006B7AFF006979FF006474FF006070
          FF005B6CFF005566FC004B5CEF003646CC00FFFFFF00FFFFFF00808DFF00ABB3
          FF00B0B8FF00A6B0FF009AA4FF00939EFF008D98FF008894FF008491FF00818E
          FF007E8CFF007A88FF007685FF00707FFF006A79FF006171FF005768FC004859
          ED003342CB00FFFFFF00FDF7F5008693FF00A5AEFF00A9B2FF009FA9FF00939E
          FF008D99FF008894FF008390FF00808EFF007D8BFF007A88FF007584FF007281
          FF006D7CFF006676FF005D6EFF005263FC004455EE004B59D300FDF6F300EBAF
          9300E1E4FF008592FF007F8CFF007583FF006C7BFF006878FF006273FF006373
          FF005F70FF005F6FFF005D6EFF005A6BFF005566FF005566FF005062FF004A5D
          FF004356FA005161EB00D7DAF500E8AA9300E0520500EBAF9300FDF6F300FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FDF7F500E8AA
          9300CC3B0500}
        ImageClick.Data = {
          07544269746D61701A070000424D1A0700000000000036000000280000001500
          0000150000000100200000000000E40600000000000000000000000000000000
          0000F75E0500F0BDA700FDF6F400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FDF6F400EFBCA700F24F0500F0BDA700D3D7EA00354E
          B3001B3BBA001C3DBF001C3DBF001C3DBF001C3DBF001C3EC0001D3FC1001D3F
          C1001D40C2001E41C3001E41C3001E42C4001E42C4001E42C4001E41C3003A58
          C900D4DBF300EFBCA700FDF6F40032479D001937AE001B3CBC001C3DBF001C3D
          BF001C3DBF001C3DBF001D3EC0001D40C2001E42C4001F43C5002045C7002045
          C8002047C9002147CA002147C9002045C7001F43C5003958C900FDF6F400FFFF
          FF00142D8D001937AD001B3CBC001C3DBF001C3DBF001D3EC0001D3EC0001D40
          C2001E42C4001F43C5002045C8002147CA002249CB002249CC00224ACD002249
          CC002148CA002045C7001E41C300FFFFFF00FFFFFF00142C8B001937AD001B3C
          BB001C3DBE001C3DBE001D3EBF001D3EC0001D40C2001E42C4001F44C6002046
          C9002148CB00224ACD00234BCD00234CCF00234CCE002249CC002046C9001E42
          C400FFFFFF00FFFFFF00142C8B001936AC001B3BBB001C3DBE00425DC8008799
          DD001D3FC0001E40C2001F43C5002045C7002147CA00224ACC00234BCE008BA1
          E600486BD700234CCF00224ACD002147C9001E42C400FFFFFF00FFFFFF00132B
          88001836AA001B3BBA001C3DBE008798DD008798DD008799DE001D40C2001F43
          C5002045C7002147CA00224ACC008BA0E5008BA0E6008BA1E600234BCE00224A
          CC002046C9001E42C400FFFFFF00FFFFFF00132A85001836A9001B3BBA001C3C
          BD001C3CBD008798DD008799DD00879ADF001E42C4001F44C6002146C9008A9F
          E3008B9FE5008BA0E500234CCE00224ACD002249CB002046C8001E41C300FFFF
          FF00FFFFFF00122880001834A5001B3AB8001C3BBC001B3BBC001C3CBD008798
          DD008799DE00889ADF001F43C500899DE100899EE3007C94E000224ACC00224A
          CD002249CB002147CA001F45C7001E41C300FFFFFF00FFFFFF0011277B001732
          A1001A39B7001B3ABA001B3ABA001B3BBC001C3CBE008798DD00879ADF00889A
          DF00889BE000899DE2002146C9002147CA002148CA002046C9002046C8001F43
          C5001D40C200FFFFFF00FFFFFF001125750017329E001A38B4001A39B8001B39
          BA001B3ABB001B3BBD001C3CBE008799DE00879ADF00889ADF001F43C5001F44
          C6002045C7002045C7001F45C7001F44C6001E42C4001D3FC100FFFFFF00FFFF
          FF001024700016309B001936B0001A38B5001A38B9001B39BA001B3ABC008697
          DC008798DD008799DE008799DE00889ADF001E42C4001E43C5001F43C5001E42
          C4001E42C4001E40C2001D3EC000FFFFFF00FFFFFF000F226A00152F95001835
          AC001937B2001937B6001A38B8008696DB008697DC008697DC001C3CBE008798
          DD008799DE008799DE001D40C2001E40C2001E40C2001D40C2001D3FC1001D3E
          C000FFFFFF00FFFFFF000E206500152D90001834A7001835AF001936B4008595
          D9008696DA008696DB001B3ABC001B3BBD001C3CBE008798DD008799DE008799
          DE001D3FC0001D3EC0001D3EC0001D3EC0001C3DBF00FFFFFF00FFFFFF000E1F
          6100142C8C001732A2001733AA008594D5008595D7008595D8001A37B8001A39
          BA001B3ABB001B3BBC001C3CBD008798DD008798DD008798DD001C3DBE001D3E
          C0001C3DBF001C3DBF00FFFFFF00FFFFFF000D1D5B00132A850016309C001732
          A4003E55B8008594D5001936B3001937B5001A38B8001B39B9001B39BA001B3B
          BC001C3CBD008798DC00425DC8001C3DBE001C3DBF001C3DBF001C3DBF00FFFF
          FF00FFFFFF000D1C590012288000152F960016309E001632A4001733AA001835
          AE001937B2001A38B5001A39B8001B3ABA001C3BBC001C3CBD001C3DBE001C3D
          BE001C3DBE001C3DBF001C3DBF001C3DBF00FFFFFF00FFFFFF000D1C59001127
          7900142C8D00152E9600162F9A001731A1001733A6001834AA001936AF001937
          B2001A39B5001B3AB7001B3BB9001B3BBA001B3BBA001B3BBB001B3BBB001B3B
          BB001B3BBA00FFFFFF00FDF6F400293564000F2269001126780012287E001229
          8200142B8A00142D8E00152E930016309A0016319C001732A0001834A4001835
          A7001836AA001836AB001937AD001836AC001937AD00354EB200FDF6F400EDBC
          A700D0D2DA00293564000D1D5A000D1E5D000E1E5F000E2063000F2168001023
          6F00112573001125750012277C0012298200132A8500132B8900142B8A00142D
          8E00142C8C0032479D00D3D8EB00ECBAA700E0520500EDBCA700FDF6F400FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FDF6F400ECBA
          A700CC3B0500}
        ImageDisabled.Data = {
          07544269746D61701A070000424D1A0700000000000036000000280000001500
          0000150000000100200000000000E40600000000000000000000000000000000
          0000F95C0000E1876200E1957700E3977A00E3977A00E3977A00E3977A00E397
          7A00E3977A00E3977A00E3977A00E3977A00E3977A00E3977A00E3977A00E397
          7A00E3977A00E3977A00E1957700E1866200F34C0000E2886200DA8F7700B973
          6B00B36E6900B46E6900B46F6900B56F6900B56F6900B46F6A00B46F6A00B46F
          6A00B36F6B00B36E6C00B26E6B00B26D6A00B16D6B00B16D6B00B16C6A00B771
          6A00D98F7600E1866200E1957700B9737000B5707000B6717000B7727100B873
          7100B8737100B8737100B8737100B7737100B7737100B6727200B5727200B472
          7200B3717200B2707200B16F7200B16F7100B16D6E00B7716900E1957700E397
          7A00B3707300B6727300B8747400BA757400BB767400BB767400BA767400BA76
          7400BA767400B9767400B8757500B7757500B6747500B5737500B3727500B271
          7500B1707400B16F7100B16C6900E3977A00E3977A00B5717400B8747400BA76
          7400BC777500BD787500BD787500BC787500BC787500BB787500BA777500B977
          7600B8767600B7767600B6757600B4747600B3727600B2717500B16F7200B16D
          6A00E3977A00E3977A00B6727400BA757400BC777500BE787500D3A4A100CD99
          9500BE797500BD797500BD797500BC797600BB787600B9777600B8777600C796
          9600CCA1A200B3737600B2727500B2707200B16D6B00E3977A00E3977A00B773
          7400BB777500BE787500BF797500CF999500CE999500CE999500BE797500BD79
          7600BC797600BB787600B9787600C9979600C8969600C6959600B4747600B372
          7500B3717200B26E6B00E3977A00E3977A00B8747400BD787500BF797500C07A
          7500C17B7500CF9A9500CF999500CE999600BE7A7600BD797600BB797600CA98
          9600C9979600C8969600B6757600B5747600B5737500B4717200B36E6B00E397
          7A00E3977A00B9757400BE797500C07A7500C17B7500C17B7600C17B7500CF99
          9500CE999500CD999600BD797600CB989600CA989600CB999900B7767600B675
          7600B6757600B6747500B5727200B46F6B00E3977A00E3977A00BA767500C07A
          7500C17B7600C27B7600C27B7600C17B7600C07A7500CE999500CD999500CD99
          9500CB989500CA979600B8767600B7757600B6757500B6757500B7747500B673
          7200B46F6B00E3977A00E3977A00BC777500C17B7600C27C7600C27C7600C27C
          7600C17B7600C07A7500BF797500CD999500CC989500CB979500B9767500B875
          7500B7757500B7747500B7757500B8757500B7737200B5706A00E3977A00E397
          7A00BC777500C27C7600C37D7600C37D7600C27C7600C17B7500C07A7500CE99
          9500CD999500CC989500CB979500CA969500B8757500B8747500B7747500B875
          7500B8757400B8747200B6706A00E3977A00E3977A00BE797500C47D7600C47E
          7600C47D7600C37C7600C27B7600CF999500CE999500CD989500BC777500CB96
          9500CA969500C9959500B8747500B8747500B8757500B9757400B9747200B670
          6A00E3977A00E3977A00BF797500C57E7600C67F7600C57E7600C37D7600D09A
          9600D0999500CE999500BE787500BD787500BB777500CA969500C9959500C995
          9500B9757500B9757500BA757400B9747200B6706A00E3977A00E3977A00C07A
          7500C7807600C7817600C67F7600D29C9600D19B9600D09A9600C07A7500BF79
          7500BE787500BC777500BB767500CA969500CA959500C9959500BA757500BA75
          7400B9747100B7706A00E3977A00E3977A00C17B7500C8827700C9827700C781
          7700D7A7A200D29C9600C27C7600C17B7600C07A7500BF797500BE787500BC77
          7500BC777500CB979500D1A2A100BB767500BA767400B9747100B6706A00E397
          7A00E3977A00C27C7600CB847700CD857700CA837700C7817600C67F7600C47E
          7600C37D7600C37C7600C27B7600C17B7600C07A7500C07A7500BE797500BD78
          7500BC777500BB767400B9747100B6706A00E3977A00E3977A00C47E7600CE86
          7700CF877800CD857700C9827700C7817600C6807600C57F7600C57E7600C47E
          7600C47E7600C37D7600C27C7600C17B7600C07A7500BE787500BB777400B973
          7100B56F6A00E3977A00E1957700C67F7600CD857700CE867700CB837700C881
          7600C6807600C67F7600C57E7600C47E7600C47D7600C37D7600C27C7600C27C
          7600C07B7500BF797500BD787500BA767400B7737100BA746C00E1957700DF86
          6200DC917900C67F7600C47E7600C27C7600C07A7500BF797500BE787500BE79
          7500BE787500BD787500BD787500BC777500BB767500BB767500BA757400B874
          7400B7737300BB757100DA8F7700DD846200E0500000DF866200E1957700E397
          7A00E3977A00E3977A00E3977A00E3977A00E3977A00E3977A00E3977A00E397
          7A00E3977A00E3977A00E3977A00E3977A00E3977A00E3977A00E1957700DD84
          6200CB370000}
        OnClick = ImbCloseFilterClick
        Transparent = False
        View = DmIm_Close
        Enabled = True
        ShowCaption = False
        Caption = 'Close'
        FontNormal.Charset = DEFAULT_CHARSET
        FontNormal.Color = clWindowText
        FontNormal.Height = -11
        FontNormal.Name = 'Tahoma'
        FontNormal.Style = []
        FontEnter.Charset = DEFAULT_CHARSET
        FontEnter.Color = clWindowText
        FontEnter.Height = -11
        FontEnter.Name = 'Tahoma'
        FontEnter.Style = []
        PixelsBetweenPictureAndText = 10
        FadeDelay = 10
        FadeSteps = 20
        Defaultcolor = clBtnFace
        Animations = [ImSt_Normal, ImSt_Enter, ImSt_Click, ImSt_Disabled]
        AnimatedShow = False
        Autosetimage = True
        Usecoolfont = False
        Coolcolor = clBlack
        CoolColorSize = 3
        VirtualDraw = False
      end
      object CbFilterMatchCase: TCheckBox
        Left = 230
        Top = 8
        Width = 140
        Height = 17
        Caption = 'Match case'
        TabOrder = 2
        OnClick = WedFilterChange
      end
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
    Top = 56
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
      OnClick = CopyClick
    end
    object Cut2: TMenuItem
      Caption = 'Cut'
      OnClick = CutClick
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
    Top = 472
    object OpenInNewWindow1: TMenuItem
      Caption = 'Open In New Window'
      OnClick = OpenInNewWindow1Click
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object Paste1: TMenuItem
      Caption = 'Paste'
      OnClick = PasteClick
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
    Top = 64
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 745
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
    Images = ImPathDropDownMenu
    OnPopup = PopupMenuBackPopup
    Left = 360
    Top = 428
  end
  object PopupMenuForward: TPopupMenu
    Images = ImPathDropDownMenu
    OnPopup = PopupMenuForwardPopup
    Left = 360
    Top = 380
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
    Top = 164
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
    Left = 529
    Top = 56
  end
  object CloseTimer: TTimer
    Enabled = False
    Interval = 1
    OnTimer = CloseTimerTimer
    Left = 536
    Top = 408
  end
  object RatingPopupMenu: TPopupMenu
    Left = 361
    Top = 336
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
    Top = 288
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
    ColorDepth = cd32Bit
    Height = 32
    Width = 32
    Left = 200
    Top = 304
  end
  object SmallIconsImageList: TImageList
    ColorDepth = cd32Bit
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
  object SearchImageList: TImageList
    Height = 18
    Width = 18
    Left = 201
    Top = 112
  end
  object PmSearchMode: TPopupMenu
    Images = ImSearchMode
    OnPopup = PmSearchModePopup
    Left = 656
    Top = 288
    object Searchfiles1: TMenuItem
      Caption = 'Search files'
      ImageIndex = 0
      OnClick = Searchfiles1Click
    end
    object SearchfileswithEXIF1: TMenuItem
      Caption = 'Search files (with EXIF)'
      ImageIndex = 1
      OnClick = SearchfileswithEXIF1Click
    end
    object Searchincollection1: TMenuItem
      Caption = 'Search in collection'
      ImageIndex = 2
      OnClick = Searchincollection1Click
    end
  end
  object ImSearchMode: TImageList
    ColorDepth = cd32Bit
    Left = 656
    Top = 344
  end
  object ImPathDropDownMenu: TImageList
    ColorDepth = cd32Bit
    Left = 200
    Top = 456
  end
  object PmPathMenu: TPopupMenu
    Left = 360
    Top = 520
    object MiCopyAddress: TMenuItem
      Caption = 'Copy Address'
      OnClick = MiCopyAddressClick
    end
    object MiEditAddress: TMenuItem
      Caption = 'Edit address'
      OnClick = MiEditAddressClick
    end
  end
end
