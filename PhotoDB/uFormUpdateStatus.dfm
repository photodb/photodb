object FormUpdateStatus: TFormUpdateStatus
  Left = 0
  Top = 0
  AlphaBlend = True
  AlphaBlendValue = 0
  BorderStyle = bsToolWindow
  Caption = 'Collection update'
  ClientHeight = 128
  ClientWidth = 311
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poMainFormCenter
  ScreenSnap = True
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object PnMain: TPanel
    Left = 0
    Top = 0
    Width = 311
    Height = 128
    Align = alClient
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      311
      128)
    object ImCurrentPreview: TImage
      Left = 3
      Top = 3
      Width = 78
      Height = 78
      Cursor = crHandPoint
      Center = True
      OnClick = ImCurrentPreviewClick
    end
    object LbInfo: TLabel
      Left = 87
      Top = 3
      Width = 218
      Height = 73
      HelpType = htKeyword
      HelpKeyword = 'object ButtonBreak: TWebLink'
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      EllipsisPosition = epPathEllipsis
      Layout = tlCenter
      WordWrap = True
    end
    object PrbMain: TDmProgress
      Left = 3
      Top = 106
      Width = 278
      Height = 18
      Anchors = [akLeft, akRight, akBottom]
      Position = 1
      MinValue = 0
      MaxValue = 100
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 16711808
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Text = #1054#1089#1090#1072#1083#1086#1089#1100' 7 '#1084#1080#1085#1091#1090' '#1080' 30 '#1089#1077#1082#1091#1085#1076
      BorderColor = 38400
      CoolColor = 38400
      Color = clBlack
      View = dm_pr_cool
      Inverse = False
    end
    object WlStartStop: TWebLink
      Tag = -1
      Left = 3
      Top = 84
      Width = 78
      Height = 16
      Cursor = crHandPoint
      Enabled = False
      Color = clWhite
      ParentColor = False
      Text = 'Pause\Start'
      ImageIndex = 0
      UseEnterColor = False
      EnterColor = clBlack
      EnterBould = False
      TopIconIncrement = 0
      Icon.Data = {
        0000010001001010000001002000680400001600000028000000100000002000
        0000010020000000000040040000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000E1830036E98D239BF29F61DCF7B18AF0F7B1
        8AF0F29F61DCE98D239BE1830036000000000000000000000000000000000000
        00000000000000000000E4870A78F5A46BF6FDC4B0FFFFCBBDFFFEC9B9FFFEC9
        B9FFFFCBBDFFFDC4B1FFF5A46AF6E4870A760000000000000000000000000000
        000000000000E4890A77F7A66DFFFEBCA1FFFAB088FFF09543DFEA8E25A0EB8F
        25A0F19746D7F9AD81FFFEBFA5FFF8A770FFE4890A7400000000000000000000
        0000E1830033F39C43F8FDBB99FFFCB58EFFF9A465FFE78B0CC1DF8200090000
        0000E082000BE4850473F5A053FAFDB287FFF39C46F8E1830033000000000000
        0000E88B0D9DFAA45CFFF9B282FFFAB88EFFFCA96BFFF9A04FFFE98A11BAE582
        000F0000000000000000E3860074F7A14EFFFAA55EFFE8880D9D000000000000
        0000F19121DDFBA048FFF08F1BDFEC8D1DC1F9A863FFFBA048FFF89B39FFEC88
        0FBBEB820A1000000000E3840007F18F1DD9FB9D44FFF19121DD000000000000
        0000F5921FF2F99828FFF088139EEA81040FF08C1BB9F89730FFFA992AFFF897
        25FFF08913BBEF7E111000000000F08813A0F99828FFF5921FF2000000000000
        0000F68E15F2F89513FFF38715A000000000EE820D10F38715BBF89315FFF995
        13FFF79113FFF38715B9F2851B0FF389179EF89513FFF68E15F2000000000000
        0000F68713DDF89208FFF68913D9F686230700000000F2861910F58819BBF78F
        08FFF89204FFF78F08FFF58619C1F68913DFF89204FFF68913DD000000000000
        0000F7871D9DF8961DFFF88F0DFFF88421740000000000000000F584210FF787
        1DBAF88E04FFF89000FFF88E04FFF78D02FFF89617FFF7851F9D000000000000
        0000F9822533F98E26F8F9A341FFF88C11FAFA822173FB822C0B00000000F983
        2C09F98623C1F88C00FFF89000FFF99C2EFFF99232F8F9822533000000000000
        000000000000FB822677FA9844FFFAB170FFF99834FFFA8919D7FB8317A0FA83
        15A0FA8615DFF8941FFFF9AC5CFFFA9D53FFFB822A7400000000000000000000
        00000000000000000000FC832A78FB9A4FF6FBBE99FFFBBF99FFFBB685FFFAB5
        7FFFFBBC90FFFBBC99FFFCA163F6FC832E760000000000000000000000000000
        0000000000000000000000000000FE802E36FD86349BFD9B5FDCFDAE85F0FDAD
        85F0FD9E6BDCFD8A3F9BFE7D2C36000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        000000000000000000000000000000000000000000000000000000000000FFFF
        0000F00F0000E0070000C0030000808100008061000080210000801100008801
        0000840100008601000081010000C0030000E0070000F00F0000FFFF0000}
      UseSpecIconSize = True
      HightliteImage = False
      StretchImage = True
      CanClick = True
    end
    object LsLoading: TLoadingSign
      Left = 287
      Top = 106
      Width = 18
      Height = 18
      Active = True
      FillPercent = 50
      SignColor = clBlack
      MaxTransparencity = 255
    end
  end
  object AeMain: TApplicationEvents
    OnMessage = AeMainMessage
    Left = 264
    Top = 8
  end
  object TmrHide: TTimer
    Enabled = False
    Interval = 10
    OnTimer = TmrHideTimer
    Left = 216
    Top = 8
  end
  object TmrShow: TTimer
    Enabled = False
    Interval = 10
    OnTimer = TmrShowTimer
    Left = 168
    Top = 8
  end
  object TmrUpdateInfo: TTimer
    Interval = 5000
    OnTimer = TmrUpdateInfoTimer
    Left = 112
    Top = 8
  end
  object SwpWindow: TSaveWindowPos
    SetOnlyPosition = True
    RootKey = HKEY_CURRENT_USER
    Key = 'Software\Positions\UpdatePos'
    Left = 219
    Top = 60
  end
end
