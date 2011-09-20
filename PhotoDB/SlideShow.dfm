object Viewer: TViewer
  Left = 303
  Top = 90
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  Caption = 'View'
  ClientHeight = 484
  ClientWidth = 645
  Color = clBtnFace
  Constraints.MinHeight = 100
  Constraints.MinWidth = 100
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  ShowHint = True
  OnClick = FormClick
  OnClose = FormClose
  OnContextPopup = FormContextPopup
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnMouseDown = FormMouseDown
  OnMouseMove = FormMouseMove
  OnMouseUp = FormMouseUp
  OnMouseWheelDown = FormMouseWheelDown
  OnMouseWheelUp = FormMouseWheelUp
  OnPaint = FormPaint
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object SbHorisontal: TScrollBar
    Left = 0
    Top = 433
    Width = 622
    Height = 17
    PageSize = 0
    TabOrder = 0
    Visible = False
    OnScroll = SbHorisontalScroll
  end
  object SbVertical: TScrollBar
    Left = 622
    Top = 0
    Width = 17
    Height = 441
    Kind = sbVertical
    PageSize = 0
    TabOrder = 1
    Visible = False
    OnScroll = SbHorisontalScroll
  end
  object Panel1: TPanel
    Left = 622
    Top = 440
    Width = 19
    Height = 17
    BevelOuter = bvNone
    TabOrder = 2
  end
  object BottomImage: TPanel
    Left = -4
    Top = 456
    Width = 641
    Height = 25
    BevelOuter = bvNone
    TabOrder = 3
    object ToolsBar: TPanel
      Left = 95
      Top = 0
      Width = 489
      Height = 25
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 0
      object TbrActions: TToolBar
        Left = 0
        Top = 0
        Width = 481
        Height = 25
        Align = alNone
        ButtonHeight = 23
        Color = clBtnFace
        DisabledImages = ImageList3
        HotImages = ImageList2
        Images = ImageList1
        ParentColor = False
        TabOrder = 0
        Transparent = True
        object TbBack: TToolButton
          Left = 0
          Top = 0
          Caption = 'Back'
          ImageIndex = 1
          OnClick = PreviousImageClick
        end
        object TbForward: TToolButton
          Left = 23
          Top = 0
          Caption = 'Forward'
          ImageIndex = 0
          OnClick = NextImageClick
        end
        object TbSeparator1: TToolButton
          Left = 46
          Top = 0
          Width = 8
          ImageIndex = 2
          Style = tbsSeparator
        end
        object TbFitToWindow: TToolButton
          Left = 54
          Top = 0
          Caption = 'FitToWindow'
          Grouped = True
          ImageIndex = 2
          Style = tbsCheck
          OnClick = FitToWindowClick
        end
        object TbRealSize: TToolButton
          Left = 77
          Top = 0
          Caption = 'RealSize'
          Grouped = True
          ImageIndex = 3
          Style = tbsCheck
          OnClick = RealSizeClick
        end
        object TbSlideShow: TToolButton
          Left = 100
          Top = 0
          Caption = 'SlideShow'
          ImageIndex = 4
          OnClick = TbSlideShowClick
        end
        object TbFullScreen: TToolButton
          Left = 123
          Top = 0
          Caption = 'FullScreen'
          ImageIndex = 7
          OnClick = FullScreen1Click
        end
        object TbSeparator2: TToolButton
          Left = 146
          Top = 0
          Width = 8
          ImageIndex = 5
          Style = tbsSeparator
        end
        object TbZoomOut: TToolButton
          Left = 154
          Top = 0
          Caption = 'ZoomOut'
          Grouped = True
          ImageIndex = 5
          Style = tbsCheck
          OnClick = TbZoomOutClick
        end
        object TbZoomIn: TToolButton
          Left = 177
          Top = 0
          Caption = 'ZoomIn'
          Grouped = True
          ImageIndex = 6
          Style = tbsCheck
          OnClick = TbZoomInClick
        end
        object TbSeparator3: TToolButton
          Left = 200
          Top = 0
          Width = 8
          ImageIndex = 7
          Style = tbsSeparator
        end
        object TbPageNumber: TToolButton
          Left = 208
          Top = 0
          Caption = 'PageNumber'
          DropdownMenu = PopupMenuPageSelecter
          EnableDropdown = True
          ImageIndex = 22
          Style = tbsDropDown
          Visible = False
          OnClick = TbPageNumberClick
        end
        object TbSeparatorPageNumber: TToolButton
          Left = 246
          Top = 0
          Width = 8
          ImageIndex = 11
          Style = tbsSeparator
          Visible = False
        end
        object TbRotateCCW: TToolButton
          Left = 254
          Top = 0
          Caption = 'RotateCCW'
          ImageIndex = 8
          OnClick = RotateCCW1Click
        end
        object TbRotateCW: TToolButton
          Left = 277
          Top = 0
          Caption = 'RotateCW'
          ImageIndex = 9
          OnClick = RotateCW1Click
        end
        object TbSeparator4: TToolButton
          Left = 300
          Top = 0
          Width = 8
          ImageIndex = 11
          Style = tbsSeparator
        end
        object TbDelete: TToolButton
          Left = 308
          Top = 0
          ImageIndex = 13
          OnClick = TbDeleteClick
        end
        object TbSeparator5: TToolButton
          Left = 331
          Top = 0
          Width = 8
          ImageIndex = 11
          Style = tbsSeparator
        end
        object TbPrint: TToolButton
          Left = 339
          Top = 0
          Caption = 'Print'
          ImageIndex = 12
          OnClick = Print1Click
        end
        object TbEncrypt: TToolButton
          Left = 362
          Top = 0
          Caption = 'Encrypt'
          ImageIndex = 23
          PopupMenu = PmSteganography
          OnClick = TbEncryptClick
          OnMouseDown = TbEncryptMouseDown
        end
        object TbSeparator6: TToolButton
          Left = 385
          Top = 0
          Width = 8
          ImageIndex = 11
          Style = tbsSeparator
        end
        object TbRating: TToolButton
          Left = 393
          Top = 0
          Caption = 'Rating'
          ImageIndex = 14
          OnClick = TbRatingClick
        end
        object TbSeparator7: TToolButton
          Left = 416
          Top = 0
          Width = 8
          ImageIndex = 12
          Style = tbsSeparator
        end
        object TbEditImage: TToolButton
          Left = 424
          Top = 0
          Caption = 'Edit Image'
          ImageIndex = 11
          OnClick = ImageEditor1Click
        end
        object TbInfo: TToolButton
          Left = 447
          Top = 0
          Caption = 'Info'
          ImageIndex = 10
          OnClick = Properties1Click
        end
      end
    end
    object LsDetectingFaces: TLoadingSign
      Left = 4
      Top = 2
      Width = 18
      Height = 18
      Visible = False
      Active = True
      FillPercent = 60
      Color = clBtnFace
      ParentColor = False
      SignColor = clBlack
      MaxTransparencity = 255
    end
    object WlFaceCount: TWebLink
      Left = 25
      Top = 4
      Width = 46
      Height = 13
      Cursor = crHandPoint
      PopupMenu = PmFaces
      Text = 'Faces: 2'
      Visible = False
      OnClick = WlFaceCountClick
      OnMouseEnter = WlFaceCountMouseEnter
      OnMouseLeave = WlFaceCountMouseLeave
      ImageIndex = -1
      IconWidth = 0
      IconHeight = 0
      UseEnterColor = False
      EnterColor = clBlack
      EnterBould = False
      TopIconIncrement = 0
      ImageCanRegenerate = True
      UseSpecIconSize = True
      HightliteImage = True
    end
  end
  object LsLoading: TLoadingSign
    Left = 297
    Top = 192
    Width = 33
    Height = 33
    Active = True
    FillPercent = 60
    Color = clBtnFace
    ParentColor = False
    SignColor = clBlack
    MaxTransparencity = 255
    GetBackGround = LsLoadingGetBackGround
  end
  object PmMain: TPopupMenu
    OnPopup = PmMainPopup
    Left = 48
    Top = 128
    object Next1: TMenuItem
      Caption = 'Next'
      Default = True
      OnClick = NextImageClick
    end
    object Previous1: TMenuItem
      Caption = 'Previous'
      OnClick = PreviousImageClick
    end
    object MTimer1: TMenuItem
      Caption = 'Timer'
      Visible = False
      OnClick = MTimer1Click
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object GoToSearchWindow1: TMenuItem
      Caption = 'Go To Search Window'
      OnClick = GoToSearchWindow1Click
    end
    object Explorer1: TMenuItem
      Caption = 'Explorer'
      OnClick = Explorer1Click
    end
    object ImageEditor1: TMenuItem
      Caption = 'Image Editor'
      OnClick = ImageEditor1Click
    end
    object Print1: TMenuItem
      Caption = 'Print'
      OnClick = Print1Click
    end
    object Rotate1: TMenuItem
      Caption = 'Rotate Image'
      object ByEXIF1: TMenuItem
        Caption = 'By EXIF'
        OnClick = ByEXIF1Click
      end
      object N5: TMenuItem
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
    object Resize1: TMenuItem
      Caption = 'Resize'
      OnClick = Resize1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object FullScreen1: TMenuItem
      Caption = 'Full Screen'
      OnClick = FullScreen1Click
    end
    object SlideShow1: TMenuItem
      Caption = 'Slide Show'
      OnClick = TbSlideShowClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object DBItem1: TMenuItem
      Caption = 'DBItem'
    end
    object AddToDB1: TMenuItem
      Caption = 'Add To DB'
      object Onlythisfile1: TMenuItem
        Caption = 'Only This File'
        OnClick = Onlythisfile1Click
      end
      object AllFolder1: TMenuItem
        Caption = 'All Files In Folder'
        OnClick = AllFolder1Click
      end
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object SendTo1: TMenuItem
      Caption = 'Send To'
      OnClick = SendTo1Click
      object N8: TMenuItem
        Caption = '-'
      end
    end
    object N7: TMenuItem
      Caption = '-'
    end
    object Copy1: TMenuItem
      Caption = 'Copy'
      OnClick = Copy1Click
    end
    object Properties1: TMenuItem
      Caption = 'Properties'
      OnClick = Properties1Click
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object Exit1: TMenuItem
      Caption = 'Exit'
      OnClick = Exit1Click
    end
  end
  object MouseTimer: TTimer
    Enabled = False
    Interval = 5000
    Left = 232
    Top = 272
  end
  object ApplicationEvents1: TApplicationEvents
    OnHint = ApplicationEvents1Hint
    OnMessage = ApplicationEvents1Message
    Left = 48
    Top = 8
  end
  object SaveWindowPos1: TSaveWindowPos
    SetOnlyPosition = False
    RootKey = HKEY_CURRENT_USER
    Key = 'Software\Positions\Noname'
    Left = 144
    Top = 8
  end
  object ImageList1: TImageList
    BlendColor = 12937777
    BkColor = 12937777
    Left = 152
    Top = 224
  end
  object ImageList2: TImageList
    BlendColor = 12937777
    BkColor = 12937777
    Left = 152
    Top = 272
  end
  object ImageList3: TImageList
    Left = 152
    Top = 320
  end
  object DropFileTarget1: TDropFileTarget
    DragTypes = [dtCopy, dtMove, dtLink]
    OnDrop = DropFileTarget1Drop
    OptimizedMove = True
    Left = 48
    Top = 64
  end
  object DropFileSource1: TDropFileSource
    DragTypes = [dtCopy, dtLink]
    Images = DragImageList
    ShowImage = True
    Left = 140
    Top = 64
  end
  object DragImageList: TImageList
    ColorDepth = cd32Bit
    Height = 200
    Width = 200
    Left = 152
    Top = 176
  end
  object ImageFrameTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = ImageFrameTimerTimer
    Left = 232
    Top = 320
  end
  object SlideTimer: TTimer
    Enabled = False
    Interval = 4000
    OnTimer = SlideTimerTimer
    Left = 232
    Top = 224
  end
  object RatingPopupMenu: TPopupMenu
    MenuAnimation = [maBottomToTop]
    Left = 48
    Top = 224
    object N01: TMenuItem
      Caption = '0'
      OnClick = N51Click
    end
    object N11: TMenuItem
      Caption = '1'
      OnClick = N51Click
    end
    object N21: TMenuItem
      Caption = '2'
      OnClick = N51Click
    end
    object N31: TMenuItem
      Caption = '3'
      OnClick = N51Click
    end
    object N41: TMenuItem
      Caption = '4'
      OnClick = N51Click
    end
    object N51: TMenuItem
      Caption = '5'
      OnClick = N51Click
    end
  end
  object TimerDBWork: TTimer
    Enabled = False
    Interval = 500
    OnTimer = TimerDBWorkTimer
    Left = 232
    Top = 176
  end
  object PopupMenuPageSelecter: TPopupMenu
    Left = 48
    Top = 176
  end
  object PmSteganography: TPopupMenu
    OnPopup = PmSteganographyPopup
    Left = 48
    Top = 272
    object AddHiddenInfo1: TMenuItem
      Caption = 'Add Hidden Info'
      OnClick = AddHiddenInfo1Click
    end
    object ExtractHiddenInfo1: TMenuItem
      Caption = 'Extract Hidden Info'
      OnClick = ExtractHiddenInfo1Click
    end
  end
  object PmFaces: TPopupMenu
    OnPopup = PmFacesPopup
    Left = 48
    Top = 368
    object MiRefreshFaces: TMenuItem
      Caption = 'Refresh Faces'
      OnClick = MiRefreshFacesClick
    end
    object N9: TMenuItem
      Caption = '-'
    end
    object MiDetectionMethod: TMenuItem
      Caption = 'Detection Method'
    end
    object MiFaceDetectionStatus: TMenuItem
      Caption = 'Face Detection Status'
      OnClick = MiFaceDetectionStatusClick
    end
  end
  object PmFace: TPopupMenu
    OnPopup = PmFacePopup
    Left = 48
    Top = 320
    object MiClearFaceZone: TMenuItem
      Caption = 'Clear face zone'
      OnClick = MiClearFaceZoneClick
    end
    object MiClearFaceZoneSeparatpr: TMenuItem
      Caption = '-'
    end
    object MiCurrentPerson: TMenuItem
      Caption = 'Current Person'
      Visible = False
      OnClick = MiCurrentPersonClick
    end
    object MiCurrentPersonSeparator: TMenuItem
      Caption = '-'
      Visible = False
    end
    object MiPreviousSelections: TMenuItem
      Caption = 'Previous selections:'
      Enabled = False
    end
    object MiPreviousSelectionsSeparator: TMenuItem
      Caption = '-'
    end
    object MiCreatePerson: TMenuItem
      Caption = 'Create Person'
      OnClick = MiCreatePersonClick
    end
    object MiOtherPersons: TMenuItem
      Caption = 'Other Persons'
      OnClick = MiOtherPersonsClick
    end
    object MiFindPhotosSeparator: TMenuItem
      Caption = '-'
    end
    object MiFindPhotos: TMenuItem
      Caption = 'Find photos'
      OnClick = MiFindPhotosClick
    end
  end
end
