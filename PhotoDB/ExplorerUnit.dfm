object ExplorerForm: TExplorerForm
  Left = 221
  Top = 233
  VertScrollBar.Visible = False
  Caption = 'DB Explorer'
  ClientHeight = 721
  ClientWidth = 1008
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
  Position = poDesigned
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnDeactivate = FormDeactivate
  OnResize = FormResize
  OnShow = FormShow
  DesignSize = (
    1008
    721)
  PixelsPerInch = 96
  TextHeight = 13
  object SplLeftPanel: TSplitter
    Left = 140
    Top = 48
    Width = 5
    Height = 652
    Constraints.MaxWidth = 150
    ResizeStyle = rsUpdate
    OnCanResize = SplLeftPanelCanResize
    ExplicitLeft = 150
    ExplicitTop = 47
    ExplicitHeight = 546
  end
  object BvSeparatorLeftPanel: TBevel
    Left = 145
    Top = 48
    Width = 1
    Height = 652
    Align = alLeft
    Shape = bsRightLine
    Style = bsRaised
    ExplicitLeft = 140
    ExplicitHeight = 545
  end
  object MainPanel: TPanel
    Left = 0
    Top = 48
    Width = 140
    Height = 652
    Align = alLeft
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 0
    OnResize = MainPanelResize
    object PcTasks: TPageControl
      Left = 0
      Top = 0
      Width = 140
      Height = 623
      ActivePage = TsTasks
      Align = alClient
      MultiLine = True
      ParentShowHint = False
      ShowHint = False
      TabOrder = 0
      OnChange = PcTasksChange
      object TsTasks: TTabSheet
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Caption = 'Tasks'
        object PropertyPanel: TPanel
          Left = 0
          Top = 0
          Width = 132
          Height = 595
          Align = alClient
          BevelOuter = bvNone
          ParentColor = True
          TabOrder = 0
          OnResize = PropertyPanelResize
          object ScrollBox1: TScrollPanel
            Left = 0
            Top = 0
            Width = 132
            Height = 595
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
            TabOrder = 0
            OnResize = ScrollBox1Resize
            object TypeLabel: TLabel
              Left = 7
              Top = 137
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
              Top = 340
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
              Top = 160
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
              Top = 559
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
              Top = 124
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
            object ImPreview: TImage
              Left = 5
              Top = 3
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
            object ImageTasksLabel: TLabel
              Tag = 1
              Left = 8
              Top = 227
              Width = 73
              Height = 13
              Caption = 'Image Tasks'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = [fsBold]
              ParentFont = False
            end
            object SlideShowLink: TWebLink
              Left = 5
              Top = 355
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
              UseSpecIconSize = True
              HightliteImage = False
              StretchImage = False
              CanClick = True
            end
            object ShellLink: TWebLink
              Left = 5
              Top = 369
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
              UseSpecIconSize = True
              HightliteImage = False
              StretchImage = False
              CanClick = True
            end
            object RenameLink: TWebLink
              Left = 5
              Top = 430
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
              UseSpecIconSize = True
              HightliteImage = False
              StretchImage = False
              CanClick = True
            end
            object RefreshLink: TWebLink
              Left = 5
              Top = 460
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
              UseSpecIconSize = True
              HightliteImage = False
              StretchImage = False
              CanClick = True
            end
            object PropertiesLink: TWebLink
              Left = 5
              Top = 445
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
              UseSpecIconSize = True
              HightliteImage = False
              StretchImage = False
              CanClick = True
            end
            object PrintLink: TWebLink
              Left = 5
              Top = 293
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
              UseSpecIconSize = True
              HightliteImage = False
              StretchImage = False
              CanClick = True
            end
            object MyPicturesLink: TWebLink
              Left = 5
              Top = 588
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
              UseSpecIconSize = True
              HightliteImage = False
              StretchImage = True
              CanClick = True
            end
            object MyDocumentsLink: TWebLink
              Left = 5
              Top = 604
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
              UseSpecIconSize = True
              HightliteImage = False
              StretchImage = True
              CanClick = True
            end
            object MyComputerLink: TWebLink
              Left = 5
              Top = 572
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
              UseSpecIconSize = True
              HightliteImage = False
              StretchImage = True
              CanClick = True
            end
            object MoveToLink: TWebLink
              Left = 5
              Top = 415
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
              UseSpecIconSize = True
              HightliteImage = False
              StretchImage = False
              CanClick = True
            end
            object ImageEditorLink: TWebLink
              Left = 5
              Top = 306
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
              UseSpecIconSize = True
              HightliteImage = False
              StretchImage = False
              CanClick = True
            end
            object DesktopLink: TWebLink
              Left = 5
              Top = 620
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
              UseSpecIconSize = True
              HightliteImage = False
              StretchImage = True
              CanClick = True
            end
            object DeleteLink: TWebLink
              Left = 5
              Top = 474
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
              UseSpecIconSize = True
              HightliteImage = False
              StretchImage = False
              CanClick = True
            end
            object CopyToLink: TWebLink
              Left = 5
              Top = 398
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
              UseSpecIconSize = True
              HightliteImage = False
              StretchImage = False
              CanClick = True
            end
            object AddLink: TWebLink
              Left = 5
              Top = 505
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
              UseSpecIconSize = True
              HightliteImage = False
              StretchImage = False
              CanClick = True
            end
            object EncryptLink: TWebLink
              Left = 5
              Top = 238
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
              UseSpecIconSize = True
              HightliteImage = False
              StretchImage = False
              CanClick = True
            end
            object WlCreateObject: TWebLink
              Left = 5
              Top = 384
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
              UseSpecIconSize = True
              HightliteImage = False
              StretchImage = False
              CanClick = True
            end
            object WlResize: TWebLink
              Left = 5
              Top = 252
              Width = 52
              Height = 16
              Cursor = crHandPoint
              Text = 'Resize'
              OnClick = Resize1Click
              ImageIndex = 0
              IconWidth = 16
              IconHeight = 16
              UseEnterColor = False
              EnterColor = clBlack
              EnterBould = False
              TopIconIncrement = 0
              UseSpecIconSize = True
              HightliteImage = False
              StretchImage = False
              CanClick = True
            end
            object WlConvert: TWebLink
              Left = 5
              Top = 266
              Width = 60
              Height = 16
              Cursor = crHandPoint
              Text = 'Convert'
              OnClick = Convert1Click
              ImageIndex = 0
              IconWidth = 16
              IconHeight = 16
              UseEnterColor = False
              EnterColor = clBlack
              EnterBould = False
              TopIconIncrement = 0
              UseSpecIconSize = True
              HightliteImage = False
              StretchImage = False
              CanClick = True
            end
            object WlCrop: TWebLink
              Left = 5
              Top = 280
              Width = 44
              Height = 16
              Cursor = crHandPoint
              Text = 'Crop'
              OnClick = WlCropClick
              ImageIndex = 0
              IconWidth = 16
              IconHeight = 16
              UseEnterColor = False
              EnterColor = clBlack
              EnterBould = False
              TopIconIncrement = 0
              UseSpecIconSize = True
              HightliteImage = False
              StretchImage = False
              CanClick = True
            end
            object WlImportPictures: TWebLink
              Left = 5
              Top = 488
              Width = 94
              Height = 16
              Cursor = crHandPoint
              Text = 'Import pictures'
              OnClick = WlImportPicturesClick
              ImageIndex = 0
              IconWidth = 16
              IconHeight = 16
              UseEnterColor = False
              EnterColor = clBlack
              EnterBould = False
              TopIconIncrement = 0
              UseSpecIconSize = True
              HightliteImage = False
              StretchImage = False
              CanClick = True
            end
            object WlGeoLocation: TWebLink
              Left = 5
              Top = 320
              Width = 93
              Height = 16
              Cursor = crHandPoint
              Text = 'Display on map'
              OnClick = WlGeoLocationClick
              ImageIndex = 0
              IconWidth = 16
              IconHeight = 16
              UseEnterColor = False
              EnterColor = clBlack
              EnterBould = False
              TopIconIncrement = 0
              UseSpecIconSize = True
              HightliteImage = False
              StretchImage = False
              CanClick = True
            end
            object WlClear: TWebLink
              Left = 5
              Top = 521
              Width = 46
              Height = 16
              Cursor = crHandPoint
              Text = 'Clear'
              OnClick = WlClearClick
              ImageIndex = 0
              IconWidth = 16
              IconHeight = 16
              UseEnterColor = False
              EnterColor = clBlack
              EnterBould = False
              TopIconIncrement = 0
              UseSpecIconSize = True
              HightliteImage = False
              StretchImage = False
              CanClick = True
            end
            object WlShare: TWebLink
              Left = 5
              Top = 537
              Width = 49
              Height = 16
              Cursor = crHandPoint
              Text = 'Share'
              Visible = False
              OnClick = WlShareClick
              ImageIndex = 0
              IconWidth = 16
              IconHeight = 16
              UseEnterColor = False
              EnterColor = clBlack
              EnterBould = False
              TopIconIncrement = 0
              UseSpecIconSize = True
              HightliteImage = False
              StretchImage = False
              CanClick = True
            end
          end
        end
      end
      object TsExplorer: TTabSheet
        Caption = 'Explorer'
        ImageIndex = 1
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object PnResetFilter: TPanel
          Left = 0
          Top = 574
          Width = 132
          Height = 21
          Align = alBottom
          ParentBackground = False
          TabOrder = 0
          Visible = False
          OnResize = PnResetFilterResize
          object WlResetFilter: TWebLink
            Left = 31
            Top = 4
            Width = 64
            Height = 13
            Cursor = crHandPoint
            Text = 'WlResetFilter'
            OnClick = WlResetFilterClick
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
      end
      object TsInfo: TTabSheet
        Caption = 'Info'
        ImageIndex = 2
        TabVisible = False
        OnResize = TsInfoResize
        OnShow = TsInfoShow
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object PnInfoContainer: TPanel
          Left = 0
          Top = 0
          Width = 132
          Height = 595
          Align = alClient
          BevelOuter = bvNone
          ParentBackground = False
          TabOrder = 0
          DesignSize = (
            132
            595)
          object LbEditComments: TLabel
            Tag = 2
            Left = 5
            Top = 336
            Width = 54
            Height = 13
            Caption = 'Comments:'
          end
          object LbEditKeywords: TLabel
            Tag = 2
            Left = 5
            Top = 258
            Width = 53
            Height = 13
            Caption = 'KeyWords:'
          end
          object ImHistogramm: TImage
            Left = 2
            Top = 24
            Width = 130
            Height = 105
            Anchors = [akLeft, akTop, akRight]
            Center = True
            Proportional = True
            Stretch = True
          end
          object LbHistogramImage: TLabel
            Left = 3
            Top = 5
            Width = 91
            Height = 13
            Caption = 'Histogramm image:'
          end
          object BtnSaveInfo: TButton
            Left = 59
            Top = 411
            Width = 73
            Height = 24
            Anchors = [akTop, akRight]
            Caption = 'BtnSaveInfo'
            Enabled = False
            TabOrder = 0
            OnClick = BtnSaveInfoClick
          end
          object MemComments: TMemo
            Tag = 1
            Left = 2
            Top = 355
            Width = 130
            Height = 50
            Anchors = [akLeft, akTop, akRight]
            ParentColor = True
            ScrollBars = ssVertical
            TabOrder = 1
            OnChange = MemCommentsChange
            OnEnter = MemCommentsEnter
          end
          object MemKeyWords: TMemo
            Tag = 1
            Left = 2
            Top = 277
            Width = 130
            Height = 50
            Anchors = [akLeft, akTop, akRight]
            ParentColor = True
            ScrollBars = ssVertical
            TabOrder = 2
            OnChange = MemKeyWordsChange
            OnEnter = MemKeyWordsEnter
          end
          object WllGroups: TWebLinkList
            Left = 2
            Top = 211
            Width = 130
            Height = 42
            HorzScrollBar.Visible = False
            Anchors = [akLeft, akTop, akRight]
            BevelEdges = []
            BevelInner = bvNone
            BevelOuter = bvNone
            BorderStyle = bsNone
            ParentBackground = True
            TabOrder = 3
            VerticalIncrement = 5
            HorizontalIncrement = 5
            LineHeight = 0
            PaddingTop = 2
            PaddingLeft = 2
          end
          object DteTime: TDateTimePicker
            Left = 2
            Top = 184
            Width = 130
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            Date = 38544.841692523150000000
            Time = 38544.841692523150000000
            ShowCheckbox = True
            Checked = False
            Color = clBtnFace
            DateFormat = dfLong
            Kind = dtkTime
            TabOrder = 4
            OnChange = DteTimeChange
            OnEnter = DteTimeEnter
          end
          object DteDate: TDateTimePicker
            Left = 2
            Top = 157
            Width = 130
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            BevelEdges = []
            BevelInner = bvNone
            Date = 38153.564945740740000000
            Time = 38153.564945740740000000
            ShowCheckbox = True
            Checked = False
            Color = clBtnFace
            DateFormat = dfLong
            TabOrder = 5
            OnChange = DteDateChange
            OnEnter = DteTimeEnter
          end
          object ReRating: TRating
            Left = 3
            Top = 135
            Width = 96
            Height = 16
            Cursor = crHandPoint
            ParentColor = False
            Color = clWhite
            Rating = 0
            RatingRange = 0
            OnChange = ReRatingChange
            Islayered = False
            Layered = 100
            OnMouseDown = ReRatingMouseDown
            ImageCanRegenerate = True
            CanSelectRange = False
          end
        end
      end
      object TsEXIF: TTabSheet
        Caption = 'EXIF'
        ImageIndex = 3
        TabVisible = False
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object VleExif: TValueListEditor
          Left = 0
          Top = 0
          Width = 132
          Height = 595
          Align = alClient
          DefaultColWidth = 70
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected, goColSizing, goRowSelect, goThumbTracking, goFixedHotTrack]
          TabOrder = 0
          OnDrawCell = VleExifDrawCell
          ColWidths = (
            70
            56)
        end
      end
      object TsDetailedSearch: TTabSheet
        Caption = 'Search'
        ImageIndex = 4
        TabVisible = False
        OnResize = TsDetailedSearchResize
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object PnESContainer: TPanel
          Left = 0
          Top = 0
          Width = 132
          Height = 595
          Align = alClient
          BevelOuter = bvNone
          Ctl3D = True
          ParentBackground = False
          ParentCtl3D = False
          TabOrder = 0
          DesignSize = (
            132
            595)
          object BvRating: TBevel
            Left = 3
            Top = 75
            Width = 126
            Height = 2
            Anchors = [akLeft, akTop, akRight]
            Shape = bsBottomLine
          end
          object BvPersons: TBevel
            Left = 4
            Top = 130
            Width = 126
            Height = 2
            Anchors = [akLeft, akTop, akRight]
            Shape = bsBottomLine
          end
          object BvGroups: TBevel
            Left = 4
            Top = 185
            Width = 126
            Height = 2
            Anchors = [akLeft, akTop, akRight]
            Shape = bsBottomLine
          end
          object PnExtendedSearch: TPanel
            Left = 0
            Top = 3
            Width = 132
            Height = 25
            Anchors = [akLeft, akTop, akRight]
            BevelInner = bvLowered
            BevelOuter = bvSpace
            ParentBackground = False
            TabOrder = 0
            object SbExtendedSearchMode: TSpeedButton
              Left = 2
              Top = 2
              Width = 30
              Height = 21
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
            object SbExtendedSearchStart: TSpeedButton
              Left = 110
              Top = 2
              Width = 20
              Height = 21
              Align = alRight
              Flat = True
              OnClick = SbDoSearchClick
              ExplicitLeft = 160
              ExplicitTop = 1
              ExplicitHeight = 23
            end
            object PnExtendedSearchEditPlace: TPanel
              Left = 32
              Top = 2
              Width = 78
              Height = 21
              Align = alClient
              BevelOuter = bvNone
              ParentBackground = False
              TabOrder = 0
              DesignSize = (
                78
                21)
              object EdExtendedSearchText: TWatermarkedEdit
                Left = 2
                Top = 4
                Width = 73
                Height = 17
                Anchors = [akLeft, akTop, akRight]
                BevelEdges = []
                BevelInner = bvNone
                BevelOuter = bvNone
                BorderStyle = bsNone
                TabOrder = 0
                OnKeyPress = WedSearchKeyPress
                WatermarkText = 'Search in directory'
              end
            end
          end
          object WlSearchRatingFrom: TWebLink
            Left = 7
            Top = 31
            Width = 100
            Height = 16
            Cursor = crHandPoint
            Text = 'WlSearchRatingFrom'
            OnClick = WlSearchRatingFromClick
            ImageIndex = 0
            IconWidth = 0
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
          object WlSearchRatingFromValue: TWebLink
            Left = 111
            Top = 31
            Width = 21
            Height = 16
            Cursor = crHandPoint
            OnClick = WlSearchRatingFromClick
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
          object WlSearchRatingToValue: TWebLink
            Left = 102
            Top = 53
            Width = 21
            Height = 16
            Cursor = crHandPoint
            OnClick = WlSearchRatingToClick
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
          object WlSearchRatingTo: TWebLink
            Left = 8
            Top = 53
            Width = 88
            Height = 16
            Cursor = crHandPoint
            Text = 'WlSearchRatingTo'
            OnClick = WlSearchRatingToClick
            ImageIndex = 0
            IconWidth = 0
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
          object WllExtendedSearchPersons: TWebLinkList
            Left = 2
            Top = 83
            Width = 130
            Height = 41
            Anchors = [akLeft, akTop, akRight]
            BevelEdges = []
            BevelInner = bvNone
            BevelOuter = bvNone
            BorderStyle = bsNone
            ParentBackground = True
            TabOrder = 5
            VerticalIncrement = 5
            HorizontalIncrement = 5
            LineHeight = 0
            PaddingTop = 0
            PaddingLeft = 0
          end
          object WllExtendedSearchGroups: TWebLinkList
            Left = 2
            Top = 138
            Width = 130
            Height = 41
            Anchors = [akLeft, akTop, akRight]
            BevelEdges = []
            BevelInner = bvNone
            BevelOuter = bvNone
            BorderStyle = bsNone
            ParentBackground = True
            TabOrder = 6
            VerticalIncrement = 5
            HorizontalIncrement = 5
            LineHeight = 0
            PaddingTop = 0
            PaddingLeft = 0
          end
          object WlExtendedSearchDateFrom: TWebLink
            Left = 3
            Top = 193
            Width = 159
            Height = 16
            Cursor = crHandPoint
            Text = 'WlExtendedSearchDateFrom'
            OnClick = WlExtendedSearchDateFromClick
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
          object WlExtendedSearchDateTo: TWebLink
            Left = 3
            Top = 215
            Width = 147
            Height = 16
            Cursor = crHandPoint
            Text = 'WlExtendedSearchDateTo'
            OnClick = WlExtendedSearchDateFromClick
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
          object WlExtendedSearchSortDescending: TWebLink
            Left = 5
            Top = 237
            Width = 21
            Height = 16
            Cursor = crHandPoint
            OnClick = WlExtendedSearchSortDescendingClick
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
          object WlExtendedSearchSortBy: TWebLink
            Left = 26
            Top = 238
            Width = 123
            Height = 13
            Cursor = crHandPoint
            PopupMenu = PmESSorting
            Text = 'WlExtendedSearchSortBy'
            OnClick = WlExtendedSearchSortByClick
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
          object WlExtendedSearchOptions: TWebLink
            Left = 3
            Top = 259
            Width = 21
            Height = 16
            Cursor = crHandPoint
            OnContextPopup = WlExtendedSearchOptionsContextPopup
            PopupMenu = PmESOptions
            OnClick = WlExtendedSearchOptionsClick
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
          object BtnSearch: TButton
            Left = 45
            Top = 257
            Width = 87
            Height = 24
            Anchors = [akTop, akRight]
            Caption = 'BtnSearch'
            ImageMargins.Left = 3
            TabOrder = 12
            OnClick = SbDoSearchClick
          end
        end
      end
    end
    object PnShelf: TPanel
      Left = 0
      Top = 623
      Width = 140
      Height = 29
      Align = alBottom
      ParentBackground = False
      TabOrder = 1
      Visible = False
      object WlGoToShelf: TWebLink
        Left = 5
        Top = 6
        Width = 82
        Height = 16
        Cursor = crHandPoint
        Text = 'WlGoToShelf'
        OnClick = WlGoToShelfClick
        ImageIndex = 0
        IconWidth = 16
        IconHeight = 16
        UseEnterColor = False
        EnterColor = clBlack
        EnterBould = False
        TopIconIncrement = 0
        UseSpecIconSize = True
        HightliteImage = False
        StretchImage = False
        CanClick = True
      end
    end
  end
  object CoolBarTop: TCoolBar
    Left = 0
    Top = 0
    Width = 1008
    Height = 21
    AutoSize = True
    BandBorderStyle = bsNone
    BandMaximize = bmNone
    Bands = <
      item
        Control = ToolBarMain
        ImageIndex = -1
        MinHeight = 21
        Width = 1006
      end>
    EdgeBorders = []
    FixedOrder = True
    object ToolBarMain: TToolBar
      Left = 2
      Top = 0
      Width = 1006
      Height = 21
      ButtonHeight = 19
      ButtonWidth = 12
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
      OnMouseMove = ToolBarMainMouseMove
      object TbBack: TToolButton
        Left = 0
        Top = 0
        AutoSize = True
        DropdownMenu = PopupMenuBack
        ImageIndex = 0
        Style = tbsDropDown
        OnClick = SpeedButton1Click
        OnMouseDown = TbBackMouseDown
      end
      object TbForward: TToolButton
        Left = 33
        Top = 0
        AutoSize = True
        DropdownMenu = PopupMenuForward
        ImageIndex = 2
        Style = tbsDropDown
        OnClick = SpeedButton2Click
        OnMouseDown = TbForwardMouseDown
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
      object TbSearch: TToolButton
        Left = 183
        Top = 0
        AutoSize = True
        ImageIndex = 10
        OnClick = TbSearchClick
      end
      object TbPreview: TToolButton
        Tag = 1
        Left = 195
        Top = 0
        AutoSize = True
        ImageIndex = 12
        OnClick = TbPreviewClick
      end
      object ToolButton11: TToolButton
        Left = 207
        Top = 0
        Width = 8
        Caption = 'ToolButton11'
        ImageIndex = 7
        Style = tbsSeparator
      end
      object TbZoomOut: TToolButton
        Left = 215
        Top = 0
        AutoSize = True
        ImageIndex = 8
        OnClick = TbZoomOutClick
      end
      object TbZoomIn: TToolButton
        Left = 227
        Top = 0
        AutoSize = True
        DropdownMenu = PopupMenuZoomDropDown
        ImageIndex = 9
        Style = tbsDropDown
        OnClick = TbZoomInClick
      end
      object ToolButton20: TToolButton
        Left = 260
        Top = 0
        Width = 8
        Caption = 'ToolButton20'
        ImageIndex = 13
        Style = tbsSeparator
      end
      object TbOptions: TToolButton
        Left = 268
        Top = 0
        AutoSize = True
        Caption = 'Options'
        ImageIndex = 11
        OnClick = Options1Click
      end
    end
  end
  object LsMain: TLoadingSign
    Left = 983
    Top = 49
    Width = 20
    Height = 20
    DisableStyles = True
    Visible = False
    Active = True
    FillPercent = 70
    Anchors = [akTop, akRight]
    SignColor = clBlack
    MaxTransparencity = 255
  end
  object PnNavigation: TPanel
    Left = 0
    Top = 21
    Width = 1008
    Height = 27
    Align = alTop
    AutoSize = True
    BevelEdges = [beBottom]
    ParentColor = True
    TabOrder = 3
    object BvSeparatorAddress: TBevel
      Left = 817
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
      Left = 819
      Top = 1
      Height = 25
      Align = alRight
      Beveled = True
      ResizeStyle = rsUpdate
      OnCanResize = slSearchCanResize
      ExplicitLeft = 668
      ExplicitTop = 6
    end
    object PnSearch: TPanel
      Left = 822
      Top = 1
      Width = 185
      Height = 25
      Align = alRight
      BevelOuter = bvNone
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
          BevelEdges = []
          BevelInner = bvNone
          BevelOuter = bvNone
          BorderStyle = bsNone
          TabOrder = 0
          OnEnter = WedSearchEnter
          OnKeyPress = WedSearchKeyPress
          WatermarkText = 'Search in directory'
        end
      end
    end
    object StAddress: TStaticText
      AlignWithMargins = True
      Left = 4
      Top = 6
      Width = 53
      Height = 17
      Margins.Top = 5
      Align = alLeft
      Alignment = taCenter
      Caption = '  Address:'
      TabOrder = 1
    end
    object PePath: TPathEditor
      Left = 62
      Top = 1
      Width = 755
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
    Left = 146
    Top = 48
    Width = 862
    Height = 652
    Align = alClient
    BevelOuter = bvNone
    FullRepaint = False
    ParentColor = True
    TabOrder = 4
    object SplRightPanel: TSplitter
      Left = 507
      Top = 33
      Width = 5
      Height = 586
      ResizeStyle = rsUpdate
      Visible = False
      OnMoved = SplRightPanelMoved
      ExplicitLeft = 572
      ExplicitTop = 27
      ExplicitHeight = 564
    end
    object PnFilter: TPanel
      Left = 0
      Top = 619
      Width = 862
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
    object PnInfo: TPanel
      Left = 0
      Top = 0
      Width = 862
      Height = 33
      Align = alTop
      BevelEdges = [beBottom]
      Color = clYellow
      ParentBackground = False
      TabOrder = 1
      Visible = False
      OnResize = PnInfoResize
      DesignSize = (
        862
        33)
      object SbCloseHelp: TSpeedButton
        Left = 832
        Top = 5
        Width = 23
        Height = 22
        Anchors = [akTop, akRight]
        Flat = True
        Glyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          1800000000000003000000000000000000000000000000000000FFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF3F3DEDFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFF1E1CE2FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          4744EF4E4BF23F3DEDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF2321E4312F
          E81E1CE2FFFFFFFFFFFFFFFFFF4F4CF45754F66361F85754F63F3DEDFFFFFFFF
          FFFFFFFFFFFFFFFF2B29E64240EE4B49F6312FE81E1CE2FFFFFFFFFFFF5754F6
          5B59F66361F8706DFD5754F64240EEFFFFFFFFFFFF3533EB4744EF6666FF4B49
          F62F2CE72321E4FFFFFFFFFFFFFFFFFF5754F65B59F66361F87371FF5B59F642
          40EE3C39EC4F4CF46666FF4F4CF43533EB2B29E6FFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFF5B59F65B59F66361F87371FF7371FF706DFD6D6BFF5654F73F3DED312F
          E8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5B59F65B59F67875FF58
          55FF5855FF7371FF4744EF3C39ECFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFF5B59F67D7BFF5D5AFF5855FF7371FF4744EFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6361F8706DFD807DFF7D
          7BFF7D7BFF7875FF5B59F64744EFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFF6D6BFA7875FF8581FF7371FF6361F8605DF86D6BFA7875FF605DF84744
          EFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7371FF7D7BFF8986FF7D7BFF6D6BFA63
          61F8605DF8605DF86D6BFA7D7BFF605DF84744EFFFFFFFFFFFFFFFFFFF7875FF
          7875FF807DFF807DFF7371FF6D6BFAFFFFFFFFFFFF605DF8605DF86D6BFA7D7B
          FF605DF84744EFFFFFFFFFFFFFFFFFFF7875FF7875FF7875FF706DFDFFFFFFFF
          FFFFFFFFFFFFFFFF605DF86361F86D6BFA4F4CF44E4BF2FFFFFFFFFFFFFFFFFF
          FFFFFF7875FF7875FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF605DF85B59
          F65754F6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFF6361F8FFFFFFFFFFFFFFFFFF}
        OnClick = SbCloseHelpClick
        ExplicitLeft = 696
      end
      object WlLearnMoreLink: TWebLink
        Left = 240
        Top = 8
        Width = 189
        Height = 16
        Cursor = crHandPoint
        Text = 'Learn more about creating persons'
        OnClick = WlLearnMoreLinkClick
        ImageIndex = 0
        IconWidth = 16
        IconHeight = 16
        UseEnterColor = False
        EnterColor = clBlack
        EnterBould = False
        TopIconIncrement = 0
        Icon.Data = {
          0000010001001010000001002000680400001600000028000000100000002000
          0000010020000000000040040000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000D3690044D3690044D369
          0044D36900440000000000000000000000000000000000000000000000000000
          0000000000000000000000000000D3690044D76B00E6D97F20FFD98E37FFD88E
          37FFD87F20FFD76B00E6D3690044000000000000000000000000000000000000
          00000000000000000000D66A00CEE07C14FFE9B463FFF6C46DFFF6C56EFFF6C5
          6EFFF2C877FFE7B463FFDD801DFFD66A00CE0000000000000000000000000000
          000000000000D66A00CEE48924FFF2BA63FFF3BD66FFFCEFD9FFFFFFFFFFFCEF
          D9FFF3BE67FFF3BD66FFEEBF6DFFE48924FFD66A00CE00000000000000000000
          0000D3690044E07D16FFEFB15AFFF0B45DFFF0B65FFFFBEDD7FFFFFFFFFFFBED
          D7FFF1B861FFF0B65FFFF0B45DFFEFB15AFFDF7910FFD3690044000000000000
          0000D76B00E6E9A046FFECAB53FFEDAD56FFEEAF58FFF4CE98FFF7D8ACFFF5CF
          98FFEEB15AFFEEAF58FFEDAD56FFECAB53FFE7993CFFD76B00E600000000D369
          0044DE760DFFE8A048FFE9A34CFFEAA64EFFEBA851FFF9E4C9FFFFFFFFFFFBEF
          DFFFECAA52FFEBA851FFEAA64FFFEAA44CFFE8A049FFDD7309FFD3690044D369
          0044DF7C17FFE69941FFE79C44FFE89F47FFE8A149FFF0BF83FFFFFFFFFFFFFF
          FFFFF7DCBBFFE9A754FFE89F47FFE79C44FFE69941FFDE7710FFD3690044D369
          0044DF7E1BFFE39139FFE4943CFFE5963EFFE59840FFECB371FFECB371FFFDF9
          F3FFFFFFFFFFF8E5CFFFE5973EFFE4943CFFE39139FFDD760EFFD3690044D369
          0044DD730BFFDF8930FFE18C35FFEFC08FFFFFFFFFFFFFFFFFFFE9A863FFF3D0
          ABFFFFFFFFFFFFFFFFFFE39441FFE39340FFE08B35FFDD730CFFD36900440000
          0000D76C04E6DD822AFFE18F3EFFE4994EFFFDF8F3FFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFF7DFC7FFE4994EFFE3984EFFDF8835FFD76B00E6000000000000
          0000D3690044DC7615FFE2954DFFE29751FFE7A769FFF3D3B5FFF8E6D5FFF8E7
          D6FFF0C9A3FFE59F5CFFE49E5DFFE49E5DFFDC7717FFD3690070000000000000
          000000000000D66B03CEDE8330FFE5A063FFE5A264FFE6A366FFE6A468FFE6A5
          6AFFE6A66BFFE6A76DFFE7A86EFFE19043FFD66A00CE00000000000000000000
          00000000000000000000D66B03CEDF832BFFE6A76DFFE9AF7BFFE9B07CFFE9B1
          7EFFEAB280FFE7AB74FFDF852FFFD66A00CE0000000000000000000000000000
          0000000000000000000000000000D3690044D66D05E6DD791AFFDF822AFFDF82
          2AFFDD7A1BFFD66D05E6D3690044000000000000000000000000000000000000
          00000000000000000000000000000000000000000000D3690044D3690044D369
          0044D3690044000000000000000000000000000000000000000000000000FC3F
          0000F00F0000E0070000C0030000800100008001000000000000000000000000
          0000000000008001000080010000C0030000E0070000F00F0000FC3F0000}
        UseSpecIconSize = True
        HightliteImage = False
        StretchImage = True
        CanClick = True
      end
    end
    object PnRight: TPanel
      Left = 512
      Top = 33
      Width = 350
      Height = 586
      Align = alClient
      Constraints.MinWidth = 100
      TabOrder = 2
      Visible = False
      DesignSize = (
        350
        586)
      object SbCloseRightPanel: TSpeedButton
        Left = 325
        Top = 1
        Width = 20
        Height = 20
        Anchors = [akTop, akRight]
        Flat = True
        Glyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          1800000000000003000000000000000000000000000000000000FFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF3F3DEDFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFF1E1CE2FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          4744EF4E4BF23F3DEDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF2321E4312F
          E81E1CE2FFFFFFFFFFFFFFFFFF4F4CF45754F66361F85754F63F3DEDFFFFFFFF
          FFFFFFFFFFFFFFFF2B29E64240EE4B49F6312FE81E1CE2FFFFFFFFFFFF5754F6
          5B59F66361F8706DFD5754F64240EEFFFFFFFFFFFF3533EB4744EF6666FF4B49
          F62F2CE72321E4FFFFFFFFFFFFFFFFFF5754F65B59F66361F87371FF5B59F642
          40EE3C39EC4F4CF46666FF4F4CF43533EB2B29E6FFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFF5B59F65B59F66361F87371FF7371FF706DFD6D6BFF5654F73F3DED312F
          E8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5B59F65B59F67875FF58
          55FF5855FF7371FF4744EF3C39ECFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFF5B59F67D7BFF5D5AFF5855FF7371FF4744EFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6361F8706DFD807DFF7D
          7BFF7D7BFF7875FF5B59F64744EFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFF6D6BFA7875FF8581FF7371FF6361F8605DF86D6BFA7875FF605DF84744
          EFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7371FF7D7BFF8986FF7D7BFF6D6BFA63
          61F8605DF8605DF86D6BFA7D7BFF605DF84744EFFFFFFFFFFFFFFFFFFF7875FF
          7875FF807DFF807DFF7371FF6D6BFAFFFFFFFFFFFF605DF8605DF86D6BFA7D7B
          FF605DF84744EFFFFFFFFFFFFFFFFFFF7875FF7875FF7875FF706DFDFFFFFFFF
          FFFFFFFFFFFFFFFF605DF86361F86D6BFA4F4CF44E4BF2FFFFFFFFFFFFFFFFFF
          FFFFFF7875FF7875FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF605DF85B59
          F65754F6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFF6361F8FFFFFFFFFFFFFFFFFF}
        OnClick = SbCloseRightPanelClick
      end
      object PcRightPreview: TPageControl
        Left = 1
        Top = 1
        Width = 348
        Height = 584
        ActivePage = TsMediaPreview
        Align = alClient
        TabOrder = 0
        OnChange = PcRightPreviewChange
        object TsMediaPreview: TTabSheet
          Caption = 'TsMediaPreview'
          ImageIndex = 1
          OnResize = TsMediaPreviewResize
          object PnRightPreview: TPanel
            Left = 0
            Top = 0
            Width = 340
            Height = 556
            Align = alClient
            BevelOuter = bvNone
            DoubleBuffered = True
            FullRepaint = False
            ParentBackground = False
            ParentDoubleBuffered = False
            TabOrder = 0
            DesignSize = (
              340
              556)
            object ToolBarPreview: TToolBar
              Left = 110
              Top = 533
              Width = 222
              Height = 22
              Align = alNone
              Anchors = [akLeft, akBottom]
              AutoSize = True
              ButtonWidth = 33
              DoubleBuffered = True
              ParentDoubleBuffered = False
              TabOrder = 0
              Transparent = False
              Wrapable = False
              object TbPreviewPrevious: TToolButton
                Left = 0
                Top = 0
                Caption = 'TbPreviewPrevious'
                ImageIndex = 3
                OnClick = TbPreviewPreviousClick
              end
              object TbPreviewNext: TToolButton
                Left = 33
                Top = 0
                ImageIndex = 3
                OnClick = TbPreviewNextClick
              end
              object TbPreviewNavigationSeparator: TToolButton
                Left = 66
                Top = 0
                Width = 8
                Caption = 'TbPreviewNavigationSeparator'
                ImageIndex = 3
                Style = tbsSeparator
              end
              object TbPreviewRotateCCW: TToolButton
                Left = 74
                Top = 0
                ImageIndex = 0
                OnClick = TbPreviewRotateCCWClick
              end
              object TbPreviewRotateCW: TToolButton
                Left = 107
                Top = 0
                Caption = 'TbPreviewRotateCW'
                ImageIndex = 1
                OnClick = TbPreviewRotateCWClick
              end
              object TbPreviewRotateSeparator: TToolButton
                Left = 140
                Top = 0
                Width = 8
                ImageIndex = 2
                Style = tbsSeparator
              end
              object TbPreviewRating: TToolButton
                Left = 148
                Top = 0
                ImageIndex = 3
                OnClick = TbPreviewRatingClick
              end
              object TbPreviewRatingSeparator: TToolButton
                Left = 181
                Top = 0
                Width = 8
                ImageIndex = 3
                Style = tbsSeparator
              end
              object TbPreviewOpen: TToolButton
                Left = 189
                Top = 0
                ImageIndex = 2
                OnClick = SlideShowLinkClick
              end
            end
            object WlFaceCount: TWebLink
              Left = 24
              Top = 538
              Width = 41
              Height = 13
              Cursor = crHandPoint
              Anchors = [akLeft, akBottom]
              Text = 'Faces: 2'
              Visible = False
              ImageIndex = -1
              IconWidth = 0
              IconHeight = 0
              UseEnterColor = False
              EnterColor = clBlack
              EnterBould = False
              TopIconIncrement = 0
              UseSpecIconSize = True
              HightliteImage = True
              StretchImage = True
              CanClick = True
            end
            object WllPersonsPreview: TWebLinkList
              Left = 0
              Top = 494
              Width = 340
              Height = 33
              HorzScrollBar.Visible = False
              BevelEdges = []
              BevelInner = bvNone
              BevelOuter = bvNone
              BorderStyle = bsNone
              ParentBackground = True
              TabOrder = 2
              VerticalIncrement = 5
              HorizontalIncrement = 5
              LineHeight = 0
              PaddingTop = 2
              PaddingLeft = 2
              HorCenter = True
            end
            object LsDetectingFaces: TLoadingSign
              Left = 3
              Top = 536
              Width = 18
              Height = 18
              Visible = False
              Active = True
              FillPercent = 60
              Color = clBtnFace
              ParentColor = False
              Anchors = [akLeft, akBottom]
              SignColor = clBlack
              MaxTransparencity = 255
            end
          end
        end
        object TsGeoLocation: TTabSheet
          Caption = 'TsGeoLocation'
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object PnGeoSearch: TPanel
            Left = 0
            Top = 521
            Width = 340
            Height = 35
            Align = alBottom
            TabOrder = 0
            DesignSize = (
              340
              35)
            object SbDoSearchLocation: TSpeedButton
              Left = 313
              Top = 5
              Width = 23
              Height = 22
              Anchors = [akTop, akRight]
              Flat = True
              OnClick = SbDoSearchLocationClick
              ExplicitLeft = 25
            end
            object WedGeoSearch: TWatermarkedEdit
              Left = 5
              Top = 6
              Width = 304
              Height = 21
              Anchors = [akLeft, akTop, akRight]
              TabOrder = 0
              OnKeyDown = WedGeoSearchKeyDown
              WatermarkText = 'Search location'
            end
          end
          object PnGeoTop: TPanel
            Left = 0
            Top = 0
            Width = 340
            Height = 33
            Align = alTop
            BevelEdges = [beBottom]
            ParentBackground = False
            TabOrder = 1
            OnResize = PnInfoResize
            object WlSaveLocation: TWebLink
              Left = 5
              Top = 8
              Width = 97
              Height = 16
              Cursor = crHandPoint
              Enabled = False
              Text = 'WlSaveLocation'
              OnClick = WlSaveLocationClick
              ImageIndex = 0
              IconWidth = 16
              IconHeight = 16
              UseEnterColor = False
              EnterColor = clBlack
              EnterBould = False
              TopIconIncrement = 0
              UseSpecIconSize = True
              HightliteImage = True
              StretchImage = False
              CanClick = True
            end
            object WlPanoramio: TWebLink
              Left = 218
              Top = 8
              Width = 83
              Height = 16
              Cursor = crHandPoint
              Text = 'WlPanoramio'
              OnClick = WlPanoramioClick
              ImageIndex = 0
              IconWidth = 16
              IconHeight = 16
              UseEnterColor = False
              EnterColor = clBlack
              EnterBould = False
              TopIconIncrement = 0
              UseSpecIconSize = True
              HightliteImage = True
              StretchImage = False
              CanClick = True
            end
            object WlDeleteLocation: TWebLink
              Left = 108
              Top = 8
              Width = 104
              Height = 16
              Cursor = crHandPoint
              Enabled = False
              Text = 'WlDeleteLocation'
              OnClick = WlDeleteLocationClick
              ImageIndex = 0
              IconWidth = 16
              IconHeight = 16
              UseEnterColor = False
              EnterColor = clBlack
              EnterBould = False
              TopIconIncrement = 0
              UseSpecIconSize = True
              HightliteImage = True
              StretchImage = False
              CanClick = True
            end
          end
        end
      end
    end
    object PnListView: TPanel
      Left = 0
      Top = 33
      Width = 507
      Height = 586
      Align = alLeft
      BevelOuter = bvNone
      ParentBackground = False
      TabOrder = 3
      object StatusBarMain: TStatusBar
        Left = 0
        Top = 566
        Width = 507
        Height = 20
        Panels = <
          item
            Width = 200
          end
          item
            Width = 500
          end>
        Visible = False
      end
    end
  end
  object CoolBarBottom: TCoolBar
    Left = 0
    Top = 700
    Width = 1008
    Height = 21
    Align = alBottom
    BandBorderStyle = bsNone
    BandMaximize = bmNone
    Bands = <
      item
        Break = False
        Control = ToolBarBottom
        ImageIndex = -1
        MinHeight = 19
        Width = 1006
      end>
    EdgeBorders = [ebBottom]
    OnResize = CoolBarBottomResize
    object ToolBarBottom: TToolBar
      Left = 11
      Top = 0
      Width = 997
      Height = 19
      ButtonHeight = 19
      ButtonWidth = 100
      Color = clBtnFace
      EdgeInner = esNone
      List = True
      ParentColor = False
      ParentShowHint = False
      ShowCaptions = True
      ShowHint = True
      TabOrder = 0
      Wrapable = False
      object TbbPlay: TToolButton
        Left = 0
        Top = 0
        AutoSize = True
        Caption = 'TbbPlay'
        ImageIndex = 0
        OnClick = SlideShowLinkClick
      end
      object TbbEncrypt: TToolButton
        Left = 54
        Top = 0
        AutoSize = True
        Caption = 'TbbEncrypt'
        ImageIndex = 1
        OnClick = EncryptLinkClick
      end
      object TbbShare: TToolButton
        Left = 125
        Top = 0
        AutoSize = True
        Caption = 'TbbShare'
        ImageIndex = 9
        OnClick = WlShareClick
      end
      object TbbGeo: TToolButton
        Left = 187
        Top = 0
        AutoSize = True
        Caption = 'TbbGeo'
        ImageIndex = 6
        OnClick = WlGeoLocationClick
      end
      object TbbResize: TToolButton
        Left = 240
        Top = 0
        AutoSize = True
        Caption = 'TbbResize'
        ImageIndex = 2
        OnClick = Resize1Click
      end
      object TbbConvert: TToolButton
        Left = 305
        Top = 0
        AutoSize = True
        Caption = 'TbbConvert'
        ImageIndex = 10
        OnClick = Convert1Click
      end
      object TbbCrop: TToolButton
        Left = 378
        Top = 0
        AutoSize = True
        Caption = 'TbbCrop'
        ImageIndex = 3
        OnClick = WlCropClick
      end
      object TbbEditor: TToolButton
        Left = 435
        Top = 0
        AutoSize = True
        Caption = 'TbbEditor'
        ImageIndex = 5
        OnClick = ImageEditorLinkClick
      end
      object TbbPrint: TToolButton
        Left = 497
        Top = 0
        AutoSize = True
        Caption = 'TbbPrint'
        ImageIndex = 4
        OnClick = PrintLinkClick
      end
      object TbBottomFileActionsSeparator: TToolButton
        Left = 553
        Top = 0
        Width = 8
        ImageIndex = 9
        Style = tbsSeparator
      end
      object TbbOpenDirectory: TToolButton
        Left = 561
        Top = 0
        AutoSize = True
        Caption = 'TbbOpenDirectory'
        ImageIndex = 9
        OnClick = TbbOpenDirectoryClick
      end
      object TbbRename: TToolButton
        Left = 665
        Top = 0
        AutoSize = True
        Caption = 'TbbRename'
        ImageIndex = 7
        OnClick = Rename1Click
      end
      object TbbProperties: TToolButton
        Left = 738
        Top = 0
        AutoSize = True
        Caption = 'TbbProperties'
        ImageIndex = 8
        OnClick = PropertiesLinkClick
      end
    end
  end
  object PnSelectDatePopup: TPanel
    Left = 751
    Top = 365
    Width = 174
    Height = 204
    TabOrder = 6
    Visible = False
    object McDateSelectPopup: TMonthCalendar
      Left = 6
      Top = 8
      Width = 162
      Height = 160
      Date = 41177.894389629630000000
      TabOrder = 0
      OnKeyDown = McDateSelectPopupKeyDown
    end
    object BtnSelectDatePopup: TButton
      Left = 94
      Top = 174
      Width = 75
      Height = 25
      Caption = 'Select'
      TabOrder = 1
      OnClick = BtnSelectDatePopupClick
    end
    object BtnSelectDatePopupReset: TButton
      Left = 6
      Top = 174
      Width = 75
      Height = 25
      Caption = 'Reset'
      TabOrder = 2
      OnClick = BtnSelectDatePopupClick
    end
  end
  object RtPopupRating: TRating
    Left = 751
    Top = 343
    Width = 96
    Height = 16
    Cursor = crHandPoint
    Visible = False
    Rating = 0
    RatingRange = 0
    OnRating = RtPopupRatingRating
    Islayered = False
    Layered = 100
    ImageCanRegenerate = True
    CanSelectRange = False
  end
  object SizeImageList: TImageList
    Height = 102
    Width = 102
    Left = 200
    Top = 240
  end
  object PmItemPopup: TPopupActionBar
    OnPopup = PmItemPopupPopup
    Left = 360
    Top = 96
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
    object MiShare: TMenuItem
      Caption = 'Share'
      OnClick = WlShareClick
    end
    object MiDisplayOnMap: TMenuItem
      Caption = 'Display on map'
      OnClick = MiDisplayOnMapClick
    end
    object N12: TMenuItem
      Caption = '-'
    end
    object MiShelf: TMenuItem
      Caption = 'Add to shelf'
      OnClick = MiShelfClick
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
    object MiImportImages: TMenuItem
      Caption = 'Import Images'
      OnClick = WlImportPicturesClick
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
  object PmListPopup: TPopupActionBar
    OnPopup = PmListPopupPopup
    Left = 360
    Top = 512
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
    object Exit2: TMenuItem
      Caption = 'Exit'
      OnClick = Exit2Click
    end
  end
  object HintTimer: TTimer
    Enabled = False
    OnTimer = HintTimerTimer
    Left = 536
    Top = 200
  end
  object SaveWindowPos1: TSaveWindowPos
    SetOnlyPosition = False
    RootKey = HKEY_CURRENT_USER
    Key = 'Software\Positions\Noname'
    Left = 200
    Top = 96
  end
  object AeMain: TApplicationEvents
    OnMessage = AeMainMessage
    Left = 769
    Top = 112
  end
  object PmTreeView: TPopupActionBar
    Left = 361
    Top = 192
    object MiTreeViewOpenInNewWindow: TMenuItem
      Caption = 'Open in new window'
      OnClick = MiTreeViewOpenInNewWindowClick
    end
    object MiTreeViewRefresh: TMenuItem
      Caption = 'Refresh'
      OnClick = MiTreeViewRefreshClick
    end
  end
  object ToolBarNormalImageList: TImageList
    ColorDepth = cd32Bit
    Height = 32
    Width = 32
    Left = 200
    Top = 436
  end
  object PopupMenuBack: TPopupActionBar
    Images = ImPathDropDownMenu
    OnPopup = PopupMenuBackPopup
    Left = 360
    Top = 468
  end
  object PopupMenuForward: TPopupActionBar
    Images = ImPathDropDownMenu
    OnPopup = PopupMenuForwardPopup
    Left = 360
    Top = 420
  end
  object DragTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = DragTimerTimer
    Left = 536
    Top = 348
  end
  object ToolBarDisabledImageList: TImageList
    ColorDepth = cd32Bit
    Height = 32
    Width = 32
    Left = 201
    Top = 196
  end
  object DropFileTargetMain: TDropFileTarget
    DragTypes = [dtCopy, dtMove]
    OnEnter = DropFileTargetMainEnter
    OnLeave = DropFileTargetMainLeave
    OnDrop = DropFileTargetMainDrop
    MultiTarget = True
    AutoRegister = False
    OptimizedMove = True
    Left = 656
    Top = 200
  end
  object DropFileSourceMain: TDropFileSource
    DragTypes = [dtCopy, dtMove, dtLink]
    Images = DragImageList
    ShowImage = True
    Left = 656
    Top = 152
  end
  object DragImageList: TImageList
    ColorDepth = cd32Bit
    DrawingStyle = dsTransparent
    Height = 102
    Width = 102
    Left = 200
    Top = 288
  end
  object DropFileTargetFake: TDropFileTarget
    DragTypes = []
    OptimizedMove = True
    Left = 656
    Top = 104
  end
  object HelpTimer: TTimer
    Enabled = False
    Interval = 2000
    OnTimer = HelpTimerTimer
    Left = 536
    Top = 440
  end
  object PmLinkOptions: TPopupActionBar
    Left = 360
    Top = 144
    object Open2: TMenuItem
      Caption = 'Open'
      OnClick = Open2Click
    end
    object OpeninNewWindow2: TMenuItem
      Caption = 'Open in New Window'
      OnClick = OpeninNewWindow2Click
    end
  end
  object PmDragMode: TPopupActionBar
    Left = 360
    Top = 240
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
    Left = 537
    Top = 96
  end
  object CloseTimer: TTimer
    Enabled = False
    Interval = 1
    OnTimer = CloseTimerTimer
    Left = 536
    Top = 392
  end
  object RatingPopupMenu: TPopupActionBar
    Left = 361
    Top = 376
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
  object PmListViewType: TPopupActionBar
    Left = 360
    Top = 328
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
    Top = 336
  end
  object SmallIconsImageList: TImageList
    ColorDepth = cd32Bit
    Left = 200
    Top = 384
  end
  object BigImagesTimer: TTimer
    Enabled = False
    Interval = 200
    OnTimer = BigImagesTimerTimer
    Left = 538
    Top = 251
  end
  object PopupMenuZoomDropDown: TPopupActionBar
    OnPopup = PopupMenuZoomDropDownPopup
    Left = 362
    Top = 282
  end
  object SearchImageList: TImageList
    Height = 18
    Width = 18
    Left = 201
    Top = 144
  end
  object PmSearchMode: TPopupActionBar
    AutoPopup = False
    Images = ImSearchMode
    OnPopup = PmSearchModePopup
    Left = 360
    Top = 608
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
    Left = 200
    Top = 536
  end
  object ImPathDropDownMenu: TImageList
    ColorDepth = cd32Bit
    Left = 200
    Top = 488
  end
  object PmPathMenu: TPopupActionBar
    Left = 360
    Top = 560
    object MiCopyAddress: TMenuItem
      Caption = 'Copy Address'
      OnClick = MiCopyAddressClick
    end
    object MiEditAddress: TMenuItem
      Caption = 'Edit address'
      OnClick = MiEditAddressClick
    end
  end
  object TmrDelayedStart: TTimer
    Enabled = False
    OnTimer = TmrDelayedStartTimer
    Left = 536
    Top = 488
  end
  object TmrCheckItemVisibility: TTimer
    Enabled = False
    Interval = 250
    OnTimer = TmrCheckItemVisibilityTimer
    Left = 536
    Top = 536
  end
  object ImGroups: TImageList
    ColorDepth = cd32Bit
    Left = 201
    Top = 584
  end
  object ImlBottomToolBar: TImageList
    ColorDepth = cd32Bit
    Left = 280
    Top = 596
  end
  object ImExtendedSearchGroups: TImageList
    ColorDepth = cd32Bit
    Left = 288
    Top = 452
  end
  object PmSelectPerson: TPopupActionBar
    Images = ImFacePopup
    OnPopup = PmSelectPersonPopup
    Left = 448
    Top = 96
    object MiPreviousSelections: TMenuItem
      Caption = 'Previous selections:'
      Enabled = False
    end
    object MiPreviousSelectionsSeparator: TMenuItem
      Caption = '-'
    end
    object MiOtherPersons: TMenuItem
      Caption = 'Other Persons'
      ImageIndex = 1
      OnClick = MiOtherPersonsClick
    end
  end
  object ImFacePopup: TImageList
    ColorDepth = cd32Bit
    BkColor = 15790320
    Left = 280
    Top = 144
  end
  object ImExtendedSearchPersons: TImageList
    ColorDepth = cd32Bit
    Left = 288
    Top = 500
  end
  object PmESSorting: TPopupActionBar
    OnPopup = PmESSortingPopup
    Left = 449
    Top = 144
    object MiESSortByID: TMenuItem
      Caption = 'Sort by ID'
      Checked = True
      GroupIndex = 2
      RadioItem = True
      OnClick = MiESSortByImageSizeClick
    end
    object MiESSortByName: TMenuItem
      Tag = 1
      Caption = 'Sort by Name'
      GroupIndex = 2
      RadioItem = True
      OnClick = MiESSortByImageSizeClick
    end
    object MiESSortByDate: TMenuItem
      Tag = 2
      Caption = 'Sort by Date'
      GroupIndex = 2
      RadioItem = True
      OnClick = MiESSortByImageSizeClick
    end
    object MiESSortByRating: TMenuItem
      Tag = 3
      Caption = 'Sort by Rating'
      GroupIndex = 2
      RadioItem = True
      OnClick = MiESSortByImageSizeClick
    end
    object MiESSortByFileSize: TMenuItem
      Tag = 4
      Caption = 'Sort by FileSize'
      GroupIndex = 2
      RadioItem = True
      OnClick = MiESSortByImageSizeClick
    end
    object MiESSortByImageSize: TMenuItem
      Tag = 5
      Caption = 'Sort by Image Size'
      GroupIndex = 2
      RadioItem = True
      OnClick = MiESSortByImageSizeClick
    end
  end
  object PmESPerson: TPopupActionBar
    Left = 449
    Top = 192
    object MiESPersonFindPictures: TMenuItem
      Caption = 'Find pictures'
      OnClick = MiESPersonFindPicturesClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object MiESPersonRemoveFromList: TMenuItem
      Caption = 'Remove from list'
      OnClick = MiESPersonRemoveFromListClick
    end
    object N9: TMenuItem
      Caption = '-'
    end
    object MiESPersonProperties: TMenuItem
      Caption = 'Properties'
      OnClick = MiESPersonPropertiesClick
    end
  end
  object PmESGroup: TPopupActionBar
    Left = 449
    Top = 240
    object MiESGroupFindPictures: TMenuItem
      Caption = 'Find pictures'
      OnClick = MiESGroupFindPicturesClick
    end
    object MenuItem2: TMenuItem
      Caption = '-'
    end
    object MiESGroupRemove: TMenuItem
      Caption = 'Remove from list'
      OnClick = MiESGroupRemoveClick
    end
    object MenuItem4: TMenuItem
      Caption = '-'
    end
    object MiESGroupProperties: TMenuItem
      Caption = 'Properties'
      OnClick = MiESGroupPropertiesClick
    end
  end
  object PmESOptions: TPopupActionBar
    OnPopup = PmESOptionsPopup
    Left = 449
    Top = 288
    object MiESShowHidden: TMenuItem
      Caption = 'Show hidden images'
      OnClick = MiESShowHiddenClick
    end
    object MiESShowPrivate: TMenuItem
      Caption = 'Show private images'
      OnClick = MiESShowPrivateClick
    end
  end
  object TmrSearchResultsCount: TTimer
    Enabled = False
    OnTimer = TmrSearchResultsCountTimer
    Left = 537
    Top = 586
  end
  object TmHideStatusBar: TTimer
    Enabled = False
    OnTimer = TmHideStatusBarTimer
    Left = 536
    Top = 152
  end
  object PmInfoGroup: TPopupActionBar
    Left = 449
    Top = 336
    object MiInfoGroupFind: TMenuItem
      Caption = 'Find pictures'
      OnClick = MiInfoGroupFindClick
    end
    object MiInfoGroupSplitter1: TMenuItem
      Caption = '-'
    end
    object MiInfoGroupRemove: TMenuItem
      Caption = 'Remove from list'
      OnClick = MiInfoGroupRemoveClick
    end
    object MiInfoGroupSplitter2: TMenuItem
      Caption = '-'
    end
    object MiInfoGroupProperties: TMenuItem
      Caption = 'Properties'
      OnClick = MiInfoGroupPropertiesClick
    end
  end
  object PmPreviewPersonItem: TPopupActionBar
    Left = 449
    Top = 384
    object MiPreviewPersonFind: TMenuItem
      Caption = 'Find pictures'
      OnClick = MiPreviewPersonFindClick
    end
    object MenuItem3: TMenuItem
      Caption = '-'
    end
    object MiPreviewPersonUpdateAvatar: TMenuItem
      Caption = 'Update avatar'
      OnClick = MiPreviewPersonUpdateAvatarClick
    end
    object MenuItem6: TMenuItem
      Caption = '-'
    end
    object MiPreviewPersonProperties: TMenuItem
      Caption = 'Properties'
      OnClick = MiPreviewPersonPropertiesClick
    end
  end
end
