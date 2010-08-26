object FormCont: TFormCont
  Left = 231
  Top = 193
  Caption = 'Panel'
  ClientHeight = 364
  ClientWidth = 468
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
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
    Width = 89
    Height = 334
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitTop = 26
    ExplicitHeight = 338
    object Panel3: TPanel
      Left = 0
      Top = 24
      Width = 89
      Height = 310
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      Visible = False
      ExplicitHeight = 314
      object Label2: TLabel
        Left = 8
        Top = 144
        Width = 21
        Height = 13
        Caption = 'Edit:'
      end
      object WebLink2: TWebLink
        Left = 9
        Top = 181
        Width = 45
        Height = 16
        Cursor = crHandPoint
        Text = 'Type'
        OnClick = WebLink2Click
        BkColor = clBtnFace
        ImageIndex = 0
        IconWidth = 16
        IconHeight = 16
        UseEnterColor = False
        EnterColor = clBlack
        EnterBould = False
        TopIconIncrement = 0
        ImageCanRegenerate = True
        UseSpecIconSize = True
      end
      object GroupBox1: TGroupBox
        Left = 8
        Top = 0
        Width = 73
        Height = 137
        Caption = 'Info'
        TabOrder = 1
        object Label1: TLabel
          Left = 8
          Top = 13
          Width = 52
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
          Width = 54
          Height = 13
          Caption = 'LabelName'
        end
        object LabelID: TLabel
          Left = 8
          Top = 101
          Width = 37
          Height = 13
          Caption = 'LabelID'
        end
        object LabelSize: TLabel
          Left = 8
          Top = 117
          Width = 46
          Height = 13
          Caption = 'LabelSize'
          Visible = False
        end
      end
      object ExportLink: TWebLink
        Left = 9
        Top = 204
        Width = 51
        Height = 16
        Cursor = crHandPoint
        Text = 'Export'
        OnClick = ExportLinkClick
        BkColor = clBtnFace
        ImageIndex = 0
        IconWidth = 16
        IconHeight = 16
        UseEnterColor = False
        EnterColor = clBlack
        EnterBould = False
        TopIconIncrement = 0
        ImageCanRegenerate = True
        UseSpecIconSize = True
      end
      object ExCopyLink: TWebLink
        Left = 9
        Top = 228
        Width = 45
        Height = 16
        Cursor = crHandPoint
        Text = 'Copy'
        OnClick = ExCopyLinkClick
        BkColor = clBtnFace
        ImageIndex = 0
        IconWidth = 16
        IconHeight = 16
        UseEnterColor = False
        EnterColor = clBlack
        EnterBould = False
        TopIconIncrement = 0
        ImageCanRegenerate = True
        UseSpecIconSize = True
      end
      object WebLink1: TWebLink
        Left = 8
        Top = 160
        Width = 41
        Height = 16
        Cursor = crHandPoint
        Text = 'Size'
        OnClick = WebLink1Click
        BkColor = clBtnFace
        ImageIndex = 0
        IconWidth = 16
        IconHeight = 16
        UseEnterColor = False
        EnterColor = clBlack
        EnterBould = False
        TopIconIncrement = 0
        ImageCanRegenerate = True
        UseSpecIconSize = True
      end
    end
    object Panel4: TPanel
      Left = 0
      Top = 0
      Width = 89
      Height = 24
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 1
      object SpeedButton2: TSpeedButton
        Left = 32
        Top = 5
        Width = 25
        Height = 14
        GroupIndex = 1
        OnClick = SpeedButton2Click
      end
      object SpeedButton1: TSpeedButton
        Left = 8
        Top = 5
        Width = 25
        Height = 14
        GroupIndex = 1
        Down = True
        OnClick = SpeedButton2Click
      end
    end
  end
  object CoolBar1: TCoolBar
    Left = 0
    Top = 0
    Width = 468
    Height = 30
    AutoSize = True
    BandBorderStyle = bsNone
    Bands = <
      item
        Control = ToolBar1
        ImageIndex = -1
        MinHeight = 30
        Width = 466
      end>
    EdgeInner = esNone
    EdgeOuter = esNone
    object ToolBar1: TToolBar
      Left = 11
      Top = 0
      Width = 457
      Height = 30
      AutoSize = True
      ButtonHeight = 30
      ButtonWidth = 70
      Caption = 'ToolBar1'
      Images = ToolBarImageList
      List = True
      ShowCaptions = True
      TabOrder = 0
      Transparent = True
      Wrapable = False
      object TbResize: TToolButton
        Left = 0
        Top = 0
        AutoSize = True
        Caption = 'Resize'
        ImageIndex = 0
        OnClick = WebLink1Click
      end
      object TbConvert: TToolButton
        Left = 63
        Top = 0
        AutoSize = True
        Caption = 'Convert'
        ImageIndex = 1
        OnClick = WebLink2Click
      end
      object TbExport: TToolButton
        Left = 131
        Top = 0
        AutoSize = True
        Caption = 'Export'
        ImageIndex = 2
        OnClick = ExportLinkClick
      end
      object TbCopy: TToolButton
        Left = 192
        Top = 0
        AutoSize = True
        Caption = 'Copy'
        ImageIndex = 3
        OnClick = ExCopyLinkClick
      end
      object TbSeparator: TToolButton
        Left = 247
        Top = 0
        Width = 8
        Caption = 'TbSeparator'
        ImageIndex = 5
        Style = tbsSeparator
      end
      object TbZoomIn: TToolButton
        Left = 255
        Top = 0
        AutoSize = True
        ImageIndex = 5
        OnClick = TbZoomInClick
      end
      object TbZoomOut: TToolButton
        Left = 289
        Top = 0
        AutoSize = True
        DropdownMenu = PopupMenuZoomDropDown
        ImageIndex = 6
        Style = tbsDropDown
        OnClick = TbZoomOutClick
      end
      object ToolButton11: TToolButton
        Left = 344
        Top = 0
        Width = 8
        Caption = 'ToolButton11'
        ImageIndex = 5
        Style = tbsSeparator
      end
      object TbStop: TToolButton
        Left = 352
        Top = 0
        AutoSize = True
        ImageIndex = 5
        OnClick = TbStopClick
      end
      object ToolButton5: TToolButton
        Left = 386
        Top = 0
        Width = 8
        Caption = 'ToolButton5'
        ImageIndex = 4
        Style = tbsSeparator
      end
      object ToolButton6: TToolButton
        Left = 394
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
    Left = 164
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
    Left = 321
    Top = 80
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
    Left = 232
    Top = 80
  end
  object ToolBarDisabledImageList: TImageList
    Left = 376
    Top = 168
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
end
