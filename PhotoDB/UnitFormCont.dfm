object FormCont: TFormCont
  Left = 231
  Top = 193
  Caption = 'Panel'
  ClientHeight = 364
  ClientWidth = 542
  Color = clBtnFace
  Constraints.MinWidth = 250
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnDeactivate = FormDeactivate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 30
    Width = 97
    Height = 334
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 0
    object Panel3: TPanel
      Left = 0
      Top = 0
      Width = 97
      Height = 334
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      Visible = False
      object Label2: TLabel
        Left = 8
        Top = 144
        Width = 22
        Height = 13
        Caption = 'Edit:'
      end
      object WlConvert: TWebLink
        Left = 9
        Top = 181
        Width = 45
        Height = 16
        Cursor = crHandPoint
        Text = 'Type'
        OnClick = WlConvertClick
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
      object GbImageInfo: TGroupBox
        Left = 8
        Top = 0
        Width = 86
        Height = 137
        Caption = 'Info'
        TabOrder = 1
        object Label1: TLabel
          Left = 8
          Top = 13
          Width = 53
          Height = 13
          Caption = 'Quick Info:'
        end
        object Image1: TImage
          Left = 8
          Top = 29
          Width = 50
          Height = 50
          Center = True
        end
        object LabelName: TLabel
          Left = 8
          Top = 85
          Width = 52
          Height = 13
          Caption = 'LabelName'
        end
        object LabelID: TLabel
          Left = 8
          Top = 101
          Width = 36
          Height = 13
          Caption = 'LabelID'
        end
        object LabelSize: TLabel
          Left = 8
          Top = 117
          Width = 44
          Height = 13
          Caption = 'LabelSize'
          Visible = False
        end
      end
      object ExportLink: TWebLink
        Left = 9
        Top = 204
        Width = 53
        Height = 16
        Cursor = crHandPoint
        Text = 'Export'
        OnClick = ExportLinkClick
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
      object ExCopyLink: TWebLink
        Left = 9
        Top = 228
        Width = 46
        Height = 16
        Cursor = crHandPoint
        Text = 'Copy'
        OnClick = ExCopyLinkClick
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
      object WlResize: TWebLink
        Left = 8
        Top = 160
        Width = 40
        Height = 16
        Cursor = crHandPoint
        Text = 'Size'
        OnClick = WlResizeClick
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
    object TwWindowsPos: TTwButton
      Left = 74
      Top = 10
      Width = 16
      Height = 16
      Cursor = crHandPoint
      Icon.Data = {
        0000010001001010000001002000680400001600000028000000100000002000
        0000010020000000000040040000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000005A5D5A7B5A595AE75A5D5ABD5A59
        5A52000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000005A5D5ADE8C8E8CF7848684E76361
        63D65A5D5A840000000000000000000000005A5D5A6B636163D65A5D5A6B0000
        000000000000000000000000000000000000636563DE9C9E9CFFA5A2A5FF9C9A
        9CFF636163D6636563DE636563DE636563DE636563DE8C8E8CFF636563BD7371
        732973717384737173DE737173FF737173FF6B696BFFC6C7C6FFC6C3C6FFA5A6
        A5FF949694FF9C9E9CFF9C9A9CFF9C9A9CFF9C9E9CFFADAAADFF636563CEEFEB
        EF21EFEBEF7BEFEBEFD6EFEBEFFFEFEBEFFF8C8E8CFFDEDFDEFFE7E3E7FFC6C3
        C6FFB5B2B5FFCECFCEFFCECFCEFFCECFCEFFD6D3D6FFC6C7C6FF6B696BBD0000
        0000000000000000000000000000000000006B6D6BADE7E3E7FFEFEFEFFFCECF
        CEFF6B6D6BAD6B6D6BAD6B6D6BAD6B6D6BAD6B6D6BADCECFCEFF6B6D6B940000
        00000000000000000000000000000000000073717394DEDBDEEFCECBCECE8482
        84A56B6D6B5A0000000000000000000000006B6D6B4A8C8A8CB57371734A0000
        0000000000000000000000000000000000007371734A7371738C737173737371
        7331000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        000000000000000000000000000000000000000000000000000000000000FFFF
        0000FFFF0000FFFF0000FFFF0000F87F0000F8380000F8000000000000000000
        0000F8000000F8380000F87F0000FFFF0000FFFF0000FFFF0000FFFF0000}
      PushIcon.Data = {
        0000010001001010000001002000680400001600000028000000100000002000
        0000010020000000000040040000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        000000000000A5A6A5735A5D5A940000000000000000734500426B3C007B6338
        0094633400520000000000000000000000000000000000000000000000000000
        000000000000E7E7E794B5B6B5BD635952C6844D00BD9C5900F7A55900FF9C4D
        00FF944D00FF6334004A00000000000000000000000000000000000000000000
        00000000000000000000DECFBDC69C6910F7BD8A29FFE7B24AFFE7A631FFDE92
        10FFB56900FF7B3C00D600000000000000000000000000000000000000000000
        00000000000000000000AD7100CECE9E4AFFEFD394FFEFC77BFFEFB65AFFE7A6
        31FFD68608FF844100F700000000000000000000000000000000000000000000
        000000000000C67D004ACE8E21FFF7E7C6FFFFF3E7FFF7E7C6FFEFC373FFDE9A
        21FFCE8210FF8C4500EF00000000000000000000000000000000000000000000
        000000000000CE820094DEAE52FFFFF3E7FFFFFFFFFFF7EFD6FFD69621FFC67D
        10FFBD6D08FFA55500FF00000000000000000000000000000000000000000000
        000000000000D68A00A5E7AE52FFF7E7C6FFFFF3E7FFE7B252FFD69218FFD68A
        18FFBD6D00FFAD5D08FFA55D08DE000000000000000000000000000000000000
        000000000000DE8E004ADE9610FFE7B252FFEFCB84FFDE9E29FFDE9A18FFE7A2
        29FFDE9A29FFAD5D00FF9C5100FFA55D00E79C5100D6944D008C000000000000
        00000000000000000000DE920039DE8E00BDD68600E7CE8600CED69618EFDE9A
        18F7E7A229FFB56908FFC67508FFBD7D10FFBD8608FFA56100FF945500840000
        000000000000000000000000000000000000000000000000000000000000DE96
        1894BD7910F7BD6D08FFEFBE94FFDEAE52FFD69621FFDE9A18FF9C5D00F70000
        0000000000000000000000000000000000000000000000000000000000000000
        0000BD7108B5EFAE7BFFFFCFBDFFDE9A29FFDE9A21FFDE9A18FFA56500C60000
        0000000000000000000000000000000000000000000000000000000000000000
        0000D67D08C6F7C3A5FFDE9E39FFDE9A21FFE7A229FFCE8618FFB56900520000
        0000000000000000000000000000000000000000000000000000000000000000
        0000D67D085ADE9239FFE7A64AFFEFA642FFDE8E21FFCE790894000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        000000000000D67D0852D67D08C6D68210C6D682107300000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        000000000000000000000000000000000000000000000000000000000000FFFF
        0000CC3F0000C01F0000E01F0000E01F0000C01F0000C01F0000C00F0000C001
        0000E0000000FF000000FF800000FF800000FF810000FFC30000FFFF0000}
      Color = clBtnFace
      ParentColor = False
      OnlyMainImage = False
      OnChange = TwWindowsPosChange
      IsLayered = False
      Layered = 255
      ImageCanRegenerate = True
    end
  end
  object CoolBar1: TCoolBar
    Left = 0
    Top = 0
    Width = 542
    Height = 30
    AutoSize = True
    BandBorderStyle = bsNone
    Bands = <
      item
        Control = ToolBar1
        ImageIndex = -1
        MinHeight = 30
        Width = 540
      end>
    EdgeInner = esNone
    EdgeOuter = esNone
    object ToolBar1: TToolBar
      Left = 11
      Top = 0
      Width = 531
      Height = 30
      AutoSize = True
      ButtonHeight = 30
      ButtonWidth = 72
      Caption = 'ToolBar1'
      Images = ToolBarImageList
      List = True
      ShowCaptions = True
      TabOrder = 0
      Transparent = True
      object TbResize: TToolButton
        Left = 0
        Top = 0
        AutoSize = True
        Caption = 'Resize'
        ImageIndex = 0
        OnClick = WlResizeClick
      end
      object TbConvert: TToolButton
        Left = 62
        Top = 0
        AutoSize = True
        Caption = 'Convert'
        ImageIndex = 1
        OnClick = WlConvertClick
      end
      object TbExport: TToolButton
        Left = 132
        Top = 0
        AutoSize = True
        Caption = 'Export'
        ImageIndex = 2
        OnClick = ExportLinkClick
      end
      object TbCopy: TToolButton
        Left = 195
        Top = 0
        AutoSize = True
        Caption = 'Copy'
        ImageIndex = 3
        OnClick = ExCopyLinkClick
      end
      object TbSeparator: TToolButton
        Left = 251
        Top = 0
        Width = 8
        Caption = 'TbSeparator'
        ImageIndex = 5
        Style = tbsSeparator
      end
      object TbZoomIn: TToolButton
        Left = 259
        Top = 0
        AutoSize = True
        ImageIndex = 5
        OnClick = TbZoomInClick
      end
      object TbZoomOut: TToolButton
        Left = 293
        Top = 0
        AutoSize = True
        DropdownMenu = PopupMenuZoomDropDown
        ImageIndex = 6
        Style = tbsDropDown
        OnClick = TbZoomOutClick
      end
      object ToolButton11: TToolButton
        Left = 348
        Top = 0
        Width = 8
        Caption = 'ToolButton11'
        ImageIndex = 5
        Style = tbsSeparator
      end
      object TbStop: TToolButton
        Left = 356
        Top = 0
        AutoSize = True
        ImageIndex = 5
        OnClick = TbStopClick
      end
      object ToolButton5: TToolButton
        Left = 390
        Top = 0
        Width = 8
        Caption = 'ToolButton5'
        ImageIndex = 4
        Style = tbsSeparator
      end
      object TbClose: TToolButton
        Left = 398
        Top = 0
        AutoSize = True
        Caption = 'Close'
        ImageIndex = 4
        OnClick = Close1Click
      end
    end
  end
  object PopupMenu1: TPopupMenu
    OnPopup = PopupMenu1Popup
    Left = 228
    Top = 34
    object SlideShow1: TMenuItem
      Caption = 'Slide Show'
      OnClick = SlideShow1Click
    end
    object SelectAll1: TMenuItem
      Caption = 'Select All'
      OnClick = SelectAll1Click
    end
    object Copy1: TMenuItem
      Caption = 'Copy'
      OnClick = Copy1Click
    end
    object Paste1: TMenuItem
      Caption = 'Paste'
      OnClick = Paste1Click
    end
    object LoadFromFile1: TMenuItem
      Caption = 'Load From File'
      OnClick = LoadFromFile1Click
    end
    object SaveToFile1: TMenuItem
      Caption = 'Save To File'
      OnClick = SaveToFile1Click
    end
    object Rename1: TMenuItem
      Caption = 'Rename'
      OnClick = Rename1Click
    end
    object Clear1: TMenuItem
      Caption = 'Clear'
      OnClick = Clear1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Close1: TMenuItem
      Caption = 'Close'
      OnClick = Close1Click
    end
  end
  object SaveDialog1: TSaveDialog
    Filter = 
      'DataDase Results (*.ids)|*.ids|DataDase FileList (*.dbl)|*.dbl|D' +
      'ataDase ImTh Results (*.ith)|*.ith'
    Left = 172
    Top = 32
  end
  object Hinttimer: TTimer
    Enabled = False
    OnTimer = HinttimerTimer
    Left = 296
    Top = 32
  end
  object ImageList1: TImageList
    Height = 51
    Width = 51
    Left = 128
    Top = 32
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 264
    Top = 32
  end
  object DropFileSource1: TDropFileSource
    DragTypes = [dtCopy]
    Images = DragImageList
    ShowImage = True
    AllowAsyncTransfer = True
    Left = 168
    Top = 112
  end
  object DragImageList: TImageList
    ColorDepth = cd32Bit
    Height = 51
    Width = 51
    Left = 200
    Top = 112
  end
  object DropFileTarget2: TDropFileTarget
    DragTypes = [dtCopy, dtMove, dtLink]
    OnDrop = DropFileTarget2Drop
    OptimizedMove = True
    Left = 136
    Top = 112
  end
  object ToolBarImageList: TImageList
    ColorDepth = cd32Bit
    Left = 209
    Top = 288
  end
  object BigImagesTimer: TTimer
    Enabled = False
    Interval = 200
    OnTimer = BigImagesTimerTimer
    Left = 144
    Top = 210
  end
  object RedrawTimer: TTimer
    Enabled = False
    Interval = 10
    Left = 248
    Top = 112
  end
  object ToolBarDisabledImageList: TImageList
    ColorDepth = cd32Bit
    Left = 304
    Top = 288
  end
  object TerminateTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = TerminateTimerTimer
    Left = 272
    Top = 160
  end
  object RatingPopupMenu1: TPopupMenu
    Left = 425
    Top = 128
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
  object PopupMenuZoomDropDown: TPopupMenu
    OnPopup = PopupMenuZoomDropDownPopup
    Left = 360
    Top = 232
  end
  object SaveWindowPos1: TSaveWindowPos
    SetOnlyPosition = False
    RootKey = HKEY_CURRENT_USER
    Key = 'Software\DolphinImagesDB\Search'
    Left = 336
    Top = 32
  end
end
