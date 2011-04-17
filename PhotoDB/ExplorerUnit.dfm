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
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
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
    Top = 47
    Width = 5
    Height = 546
    Constraints.MaxWidth = 150
    OnCanResize = Splitter1CanResize
    ExplicitLeft = 150
  end
  object MainPanel: TPanel
    Left = 0
    Top = 47
    Width = 135
    Height = 546
    Align = alLeft
    ParentColor = True
    TabOrder = 0
    object CloseButtonPanel: TPanel
      Left = 1
      Top = 1
      Width = 133
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
      object Button1: TButton
        Left = 101
        Top = 3
        Width = 15
        Height = 15
        Caption = 'x'
        TabOrder = 0
        OnClick = Button1Click
      end
    end
    object PropertyPanel: TPanel
      Left = 1
      Top = 22
      Width = 133
      Height = 523
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
        Width = 133
        Height = 523
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
          Width = 35
          Height = 13
          Caption = 'Tasks'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
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
          Width = 74
          Height = 13
          Caption = 'Other Places'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
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
          Width = 58
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
          Width = 45
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
          Width = 42
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
          Width = 52
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
          Width = 26
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
          Width = 76
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
          Width = 67
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
          Width = 48
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
          Width = 64
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
          Width = 45
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
          Width = 58
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
    ExplicitWidth = 870
  end
  object CoolBar1: TCoolBar
    Left = 0
    Top = 25
    Width = 867
    Height = 22
    AutoSize = True
    Bands = <
      item
        Control = ToolBar2
        ImageIndex = -1
        MinHeight = 20
        Width = 861
      end>
    EdgeBorders = [ebLeft, ebRight, ebBottom]
    ParentShowHint = False
    ShowHint = True
    OnResize = PageScroller2Resize
    ExplicitWidth = 870
    object ToolBar2: TToolBar
      Left = 11
      Top = 0
      Width = 852
      Height = 20
      AutoSize = True
      ButtonHeight = 20
      Caption = 'ToolBar2'
      DockSite = True
      TabOrder = 0
      Wrapable = False
      object Label2: TLabel
        Left = 0
        Top = 0
        Width = 41
        Height = 20
        Alignment = taCenter
        Caption = 'Address '
        Enabled = False
        Layout = tlCenter
      end
      object ToolButton9: TToolButton
        Left = 41
        Top = 0
        Width = 8
        Caption = 'ToolButton9'
        Style = tbsSeparator
      end
      object CbPathEdit: TComboBoxEx
        Left = 49
        Top = 0
        Width = 568
        Height = 22
        AutoCompleteOptions = [acoAutoSuggest]
        ItemsEx = <>
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        OnKeyDown = CbPathEditKeyDown
        OnKeyPress = CbPathEditKeyPress
      end
      object ImButton1: TImButton
        Left = 617
        Top = 0
        Width = 20
        Height = 20
        ImageNormal.Data = {
          07544269746D6170E6040000424DE60400000000000036000000280000001400
          0000140000000100180000000000B00400000000000000000000000000000000
          00003F3F3FF0F5F0C8DCC8C2D7C2C3D8C3C3D8C3C3D8C3C3D8C3C3D9C3C3D9C3
          C2D9C2C1DAC1C1DAC1C0D9C0BFD9BFBFD9BFBFD7BFDAE6DA9D9E9D6E6E6E7F7F
          7FE1ECE192BA9285B08587B28788B28888B28888B28887B48787B48785B48583
          B58383B58381B38180B4807FB37F7FAF7FB5CEB5BBBCBB9D9E9DFFFFFF599F59
          1678161476141B7A1B1D7B1D1C7B1C1B7C1B197E191780171483140F850F0D84
          0D098209058205017F01007500267C26B5CEB5DAE6DAFFFFFF0C800C19881924
          8E242C922C2E932E2D932D2B942B2A982A269A26219E211CA21C17A41710A410
          0AA30A049D040091000075007FAF7FBFD7BFFFFFFF1288122391232E972E379B
          373A9D3A399D39369E363DA63D5FB95F42B24223AC231CAE1C15AF150EAE0E07
          AA07029D02017F017FB27FBFD8BFFFFFFF188C182D962D389C3841A14143A243
          42A34240A3407EC47EF8FCF8C3E8C341BA4121B4211AB41A12B3120BAE0B05A1
          0503820380B380BFD9BFFFFFFF1F8F1F359A3541A04149A4494AA54A48A64845
          A64559B259F8FCF8FDFEFDCEEDCE23B3231DB41D15B3150FAE0F0AA30A078407
          81B481C0D9C0FFFFFF2693263E9E3E48A34850A7504FA84F4CA74C48A74844A9
          446CBE6CF9FCF9FFFFFFF1FAF11EB31E18B21814AD1411A3110D850D83B583C1
          DAC1FFFFFF2C952C45A1454EA64E52A85252A8524EA84E4AA74A44A7443DA83D
          7EC77EEDF7EDFFFFFFCBEDCB35B73518AA1818A21813861385B685C2DAC2FFFF
          FF3499344CA54C93C993AAD4AAA9D4A9A7D3A7A4D2A4A1D3A19ED39E9AD39AE0
          F2E0FFFFFFFDFEFDBFE6BF37AF371D9F1D18861887B687C3DAC3FFFFFF399C39
          53A853D5E9D5FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFDFEFDCCE9CC239B231C841C89B689C4DAC4FFFFFF409F405AAD5AD6
          EBD6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFF5BB45B2898282083208BB68BC5DAC5FFFFFF46A24662B06264B16461AE
          6159AA5951A6514AA24A43A0433C9D3C49A549BFE0BFFFFFFFF1F8F177BE7728
          98282B962B2382238CB68CC5DAC5FFFFFF4BA54B6AB56A6CB56C66B2665DAC5D
          55A8554EA44E47A14753A853BBDDBBFAFCFAFFFFFF7ABE7A2A972A2B982B2D95
          2D2481248CB68CC5DAC5FFFFFF51A85174BA7474BA746BB56B61AF615AAB5A53
          A7534BA34BC5E1C5FAFCFAFFFFFF67B3673198312F982F2F982F2F952F258125
          8CB58CC5DAC5FFFFFF5AAD5A84C28484C28477BC776AB56A64B0645DAC5D81BF
          81FFFFFFFFFFFF73B97344A1443F9E3F3A9D3A359A35309530237F238BB58BC5
          DAC5FFFFFF64B16493C99393C99382C08274B9746DB66D68B3686AB46AC0DFC0
          96CA9659AC5954AA544EA74E46A3463C9E3C2F942F1E7D1E88B388C3D9C3FFFF
          FF6FB76F8FC78F90C8907EBF7E70B8706BB56B66B26662B0625FAE5F5DAE5D58
          AC5855AA554EA74E45A3453A9C3A2B922B217F2196BC96CADDCAFFFFFFBBDDBB
          6EB66E60AF6056A9564FA74F49A34944A14444A14442A0423F9F3F3B9D3B369B
          363499342E972E2592251C881C62A562E2ECE2F0F5F0000000FFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFF7F7F7F3F3F3F}
        ImageEnter.Data = {
          07544269746D6170E6040000424DE60400000000000036000000280000001400
          0000140000000100180000000000B00400000000000000000000000000000000
          00003F3F3FF0F7F0C8E2C8C2DEC2C3DFC3C3DFC3C3DFC3C3E0C3C3E1C3C3E2C3
          C2E3C2C1E3C1C1E5C1C0E4C0C0E4C0BFE4BFBFE0BFDAEBDA9D9E9D6E6F6E7F7F
          7FE1EFE192C59285BE8587BF8788BF8888C08888C18888C48887C58785C78584
          C88483CB8382C98281CA817FC97F7FC17FB5D7B5BBBDBB9D9E9DFFFFFF59B459
          1695161493141B971B1D971D1D981D1C9B1C1BA01B19A41916AA1612AE120FB2
          0F0AB30A06B50602B10200A200269D26B5D7B5DAEBDAFFFFFF0CA20C19A91924
          AD242CB02C2EB22E2EB22E2EB62E2DBB2D29BF2926C62620CC201BD21B14D514
          0CD40C05CF0500C30000A3007FC27FBFE0BFFFFFFF12AB1223B1232EB62E37B8
          373ABA3A3ABB3A39BE3941C64163D56347D6472AD72A22DC221AE01A11E01109
          DB0903CF0301AF017FC77FBFE3BFFFFFFF18AE182DB52D38B93841BC4144BE44
          43BF4343C24382DA82F9FDF9C6F3C648E14829E22920E62017E6170DE00D07D4
          0703B40380CA80BFE4BFFFFFFF1FB01F35B83541BC4149BF494AC04A49C14949
          C4495ED05EF8FDF8FDFEFDD0F7D02CE42C24E6241AE61A13E0130DD50D09B509
          82CA82C0E4C0FFFFFF26B3263EBC3E48BF4850C25050C3504EC34E4CC54C4ACA
          4A72D872F9FDF9FFFFFFF2FDF226E3261EE21E19DE1915D3150FB30F84C984C1
          E4C1FFFFFF2CB52C45BE454FC24F54C35454C45451C4514EC54E4AC84A45CC45
          83DF83EEFAEEFFFFFFCDF7CD3ADF3A1DD71D1CCD1C15B01586CA86C2E4C2FFFF
          FF34B8344EC14E94D994ABE1ABAAE1AAA8E1A8A6E1A6A4E3A4A1E4A19EE69EE1
          F7E1FFFFFFFDFEFDC0F3C03BD53B22C7221AAC1A88C888C3E3C3FFFFFF3ABA3A
          55C455D5F0D5FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFDFEFDCDF3CD27C1271FA71F8AC78AC4E3C4FFFFFF42BC425EC75ED8
          F1D8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFF5ECF5E2BBC2B22A3228BC58BC5E2C5FFFFFF48BF4867CA676BCB6B67CA
          6761C8615AC65A52C35249C14941BF414CC44CC0EAC0FFFFFFF1FAF178D37829
          BA292DB72D24A0248CC38CC5E1C5FFFFFF4DC14D70CD7074CE746ECD6E66CA66
          5EC75E56C5564DC24D57C557BCE8BCFAFDFAFFFFFF7BD27B2AB72A2CB72C2EB4
          2E259D258CC38CC5E1C5FFFFFF54C3547BD17B7ED17E75CF756BCB6B62C8625A
          C55A51C251C7EBC7FAFDFAFFFFFF68CA6831B7312FB62F2FB72F2FB22F259C25
          8CC28CC5E0C5FFFFFF5EC65E8AD68A8CD68C82D38274CE746CCC6C63C86385D4
          85FFFFFFFFFFFF74CF7444BE443FBB3F3ABA3A35B83530B230239B238BC18BC5
          E0C5FFFFFF66CA6698DB9899DB998AD68A7ED17E75CF756ECC6E70CC70C1E9C1
          97DB975AC55A55C3554EC14E46BE463CBB3C2FB22F1E991E88C088C3DFC3FFFF
          FF71CD7193D99395D99584D48478CF7871CD716ACB6A66C96662C8625EC75E59
          C55955C4554EC14E45BE453ABA3A2BB12B219B2196C796CAE3CAFFFFFFBCE7BC
          6FCD6F62C86258C55851C2514BBF4B46BE4645BE4543BD433FBC3F3CBB3C36B9
          3634B8342EB62E25B2251CA91C62B962E2F0E2F0F7F0000000FFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFF7F7F7F3F3F3F}
        ImageClick.Data = {
          07544269746D6170E6040000424DE60400000000000036000000280000001400
          0000140000000100180000000000B00400000000000000000000000000000000
          00003F3F3FF0F6F0C7E0C7BFDEBFBFDFBFBFDFBFBFDFBFBFDFBFBFDFBFBFE0BF
          BFE0BFBFE0BFBFE1BFBFE1BFBFE1BFBFE1BFBFE1BFDAEDDA9D9E9D6E6F6E7F7F
          7FE1EDE18FC18F7FBD7F7FBF7F7FBF7F7FBF7F7FBF7F7FC07F7FC17F7FC27F7F
          C27F7FC37F7FC47F7FC47F7FC47F7FC37FB5DBB5BBBDBB9D9E9DFFFFFF549654
          077807007D00008000008000008000008100008400008600008800008B00008D
          00008E00009000008F00008C00269A26B5DBB5DAEDDAFFFFFF00600000740000
          7D00008000008000008000008200008700008B00008F00009400009700009800
          009900009600009300008B007FC37FBFE1BFFFFFFF005F00007400007C00007E
          00007F00008000008300058A051C991C0E980E009600009A00009C00009D0000
          9C00009700008E007FC37FBFE1BFFFFFFF005F00007300007C00007E00007E00
          008100008400299C2974C17456B8560E9F0E009D00009F0000A000009E000099
          000090007FC47FBFE1BFFFFFFF005C00007200007B00007D00007D0000800000
          84000F910F73C17377C6775CBF5C009E00009F0000A000009C00009900008F00
          7FC47FBFE1BFFFFFFF005B00007100007B00007C00007C00007E000083000089
          001C9A1C74C47478C97870C770009D00009D00009A00009700008E007FC37FBF
          E1BFFFFFFF005700006E00007900007A00007A00007D00008000008600008B00
          2AA12A6DC26D78C8785CBF5C0E9F0E009700009400008C007FC27FBFE0BFFFFF
          FF005400006C002D8E2D3C983C3C983C3C9A3C3C9D3C3CA13C3CA33C3CA73C66
          BC6678C67877C67756B8560E980E0090000089007FC27FBFE0BFFFFFFF005000
          0068005AA45A78B67878B77878B87878BA7878BC7878BD7878BF7878C27878C3
          7878C37877C3775CB75C008B000086007FC17FBFE0BFFFFFFF004D000066005A
          A25A78B57878B67878B77878B87878BA7878BB7878BD7878BE7878C07878C178
          78C1781E961E0088000084007FC07FBFDFBFFFFFFF004900006100006D000070
          00007300007600007800007900007C000C850C53AA5378BD7870BA702D9A2D00
          84000083000082007FBF7FBFDFBFFFFFFF004500005E00006A00006D00007000
          0072000074000077000C7F0C4EA44E75B97578BB782D962D0080000080000081
          000080007FBF7FBFDFBFFFFFFF004100005A00006500006900006C00006F0000
          710000740053A35375B67578B9781E8B1E007D00007E00007F00008000008000
          7FBF7FBFDFBFFFFFFF003F00005800006200006600006900006D000070001E83
          1E78B67878B7781E8A1E007C00007D00007E00007E000080000080007FBF7FBF
          DFBFFFFFFF003D00005400005F00006200006500006900006D00057305479A47
          2A8C2A007800007A00007B00007C00007C00007D00007D007FBD7FBFDEBFFFFF
          FF174917004A00005300005600005900005D00006000006500006700006A0000
          6C00006F0000710000730000730000730009790993C393C9E1C9FFFFFF9EB09E
          174A17003E00003E00004100004500004900004D00005000005300005600005A
          00005C00005E00005F00005F005E9C5EE3EEE3F1F6F1000000FFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFF7F7F7F3F3F3F}
        ImageDisabled.Data = {
          07544269746D6170E6040000424DE60400000000000036000000280000001400
          0000140000000100180000000000B00400000000000000000000000000000000
          0000DC805DDD8C6BD88F6ED78F6ED78F6ED78F6ED78F6ED78F6ED78F6ED78F6E
          D78F6ED68F6ED68F6ED68F6DD68F6DD68F6DD68F6DDA8D6CDE8563DD8360DD83
          60DB8D6CCD8964CB8862CB8862CB8863CB8863CB8863CB8862CB8862CB8862CA
          8862CA8862CA8861CA8861CA8861CA8761D38A67DE8867DE8563E19172C2845A
          B57C4CB57C4CB67D4DB67D4EB67D4EB67D4DB67E4DB57E4DB47F4CB37F4BB37F
          4AB27F4AB17E49B17E48B17C48B87D4FD38A67DA8D6CE3977AB37E4AB6804DB7
          814FB98251BA8251B98251B98251B98351B8834FB7844EB6854EB5854DB3854B
          B2854AB18449B18248B17C48CA8761D68F6DE3977AB4804CB7814FB98351BB83
          53BC8453BB8453BB8453BC8654BD8C5BBA8955B7874FB6874EB5874CB3874AB2
          864AB18449B17E48CA8861D68F6DE3977AB5814DB98351BB8353BD8455BE8555
          BD8555BD8554C28F62CAA27AC59B6FBA8B55B7884FB6884DB4884CB2874AB285
          49B17E49CA8861D68F6DE3977AB6814EBB8352BD8455BF8556BF8556BE8556BE
          8655BF895ACBA17ACBA37AC59D70B8884FB6894DB5884CB4874BB2854AB27F49
          CA8861D68F6DE3977AB88250BD8454BE8556C18658C08658C08657BF8656BE86
          56C08D5ECBA27AC9A47AC8A276B6884EB5884DB5874CB4854CB37F4ACA8862D6
          8F6EE3977AB98250BE8456C08558C18658C18658C08657BF8657BE8656BC8654
          C19061C8A176C9A379C49D6EB88A52B6864DB5854DB47F4BCB8962D7906EE397
          7ABA8352BF8557C69067C9956CC8946CC8946BC6946BC5946AC49468C39467C7
          9E74C9A279C8A277C39A6CB88852B6844EB57F4DCB8962D7906EE3977ABC8353
          C18658CD9B77D0A380D0A27FCFA27FCEA27FCDA27DCCA27CCBA27BC9A27AC9A2
          79C8A278C7A177C49A6EB7844FB67F4ECB8963D7906EE3977ABD8455C2875ACD
          9D78D1A382D0A280CFA27FCEA27FCDA27DCCA17BCBA17BC9A17AC9A179C8A178
          C8A178BC8B5AB98350B77F4ECC8963D7906EE3977ABE8456C3875BC4885CC487
          5BC28659C08558BF8557BE8555BC8454BC8756C4976DC9A079C89E75BE8D5FB8
          8350B98351B87E4FCC8963D7906EE3977ABF8557C5895DC5895DC4885CC3865A
          C18659C08557BF8556BE8758C6976ECA9F7AC9A07ABF8D5FB98350B98351BA83
          51B87E4FCC8963D7906EE3977AC08658C78A5FC78A5FC5885DC3875BC2865AC1
          8659BF8556C89871CCA07BCCA07BBE8A5DBA8351B98351BA8351BA8351B87E4F
          CC8863D78F6EE3977AC2875ACA8B62CB8B62C88A60C5885DC4885CC3875AC68E
          64CFA27FCEA27FC28C60BE8556BD8454BC8454BB8353BA8352B87E4FCC8863D7
          8F6EE3977AC4885CCD8C65CD8C65CA8B62C7895FC6895DC5885CC5895ECC9772
          C89168C28759C18659C08657BE8555BC8454BA8252B77D4ECB8862D78F6EE295
          78C6895ECC8C64CD8C64C98B61C7895EC5885DC5885CC4875CC3875BC3875AC2
          8759C28659C08657BE8556BC8353B98251B77E4FCE8965D88F6EDF8B6AD5906D
          C6895DC3875BC28659C08557BF8556BE8555BD8455BD8455BD8455BC8354BB83
          52BB8352B98351B8814FB6804DC5865DDC8D6CDD8C6BDC7E5ADF8B6AE29578E3
          977AE3977AE3977AE3977AE3977AE3977AE3977AE3977AE3977AE3977AE3977A
          E3977AE3977AE3977AE19172DD8360DC805D}
        OnClick = ImButton1Click
        Transparent = False
        View = DmIm_None
        Enabled = True
        ShowCaption = False
        Caption = 'ImButton1'
        FontNormal.Charset = DEFAULT_CHARSET
        FontNormal.Color = clWindowText
        FontNormal.Height = -11
        FontNormal.Name = 'MS Sans Serif'
        FontNormal.Style = []
        FontEnter.Charset = DEFAULT_CHARSET
        FontEnter.Color = clWindowText
        FontEnter.Height = -11
        FontEnter.Name = 'MS Sans Serif'
        FontEnter.Style = []
        PixelsBetweenPictureAndText = 10
        FadeDelay = 10
        FadeSteps = 20
        defaultcolor = clBtnFace
        Animations = [ImSt_Normal, ImSt_Enter, ImSt_Click, ImSt_Disabled]
        AnimatedShow = False
        autosetimage = True
        usecoolfont = False
        coolcolor = clBlack
        CoolColorSize = 3
        VirtualDraw = False
      end
    end
  end
  object CoolBar2: TCoolBar
    Left = 0
    Top = 0
    Width = 867
    Height = 25
    AutoSize = True
    Bands = <
      item
        Control = ToolBar1
        ImageIndex = -1
        MinHeight = 21
        Width = 861
      end>
    ExplicitWidth = 870
    object ToolBar1: TToolBar
      Left = 11
      Top = 0
      Width = 852
      Height = 21
      ButtonHeight = 19
      ButtonWidth = 48
      Color = clInactiveCaption
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
        Caption = 'Cut'
        ImageIndex = 3
        OnClick = Cut3Click
      end
      object TbCopy: TToolButton
        Left = 98
        Top = 0
        AutoSize = True
        Caption = 'Copy'
        ImageIndex = 4
        OnClick = Copy3Click
      end
      object TbPaste: TToolButton
        Left = 110
        Top = 0
        AutoSize = True
        Caption = 'Paste'
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
      object TbStop: TToolButton
        Left = 244
        Top = 0
        AutoSize = True
        ImageIndex = 12
        OnClick = TbStopClick
      end
      object ToolButton12: TToolButton
        Left = 256
        Top = 0
        Width = 8
        Caption = 'ToolButton12'
        ImageIndex = 7
        Style = tbsSeparator
      end
      object TbSearch: TToolButton
        Left = 264
        Top = 0
        AutoSize = True
        ImageIndex = 10
        OnClick = GoToSearchWindow1Click
      end
      object ToolButton16: TToolButton
        Left = 276
        Top = 0
        Width = 8
        Caption = 'ToolButton16'
        ImageIndex = 8
        Style = tbsSeparator
      end
      object TbOptions: TToolButton
        Left = 284
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
    ExplicitLeft = 845
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
    Top = 136
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
  object AutoCompliteTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = AutoCompliteTimerTimer
    Left = 536
    Top = 184
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
    Top = 243
  end
  object PopupMenuZoomDropDown: TPopupMenu
    OnPopup = PopupMenuZoomDropDownPopup
    Left = 362
    Top = 242
  end
end
