object Form4: TForm4
  Left = 138
  Top = 133
  Width = 550
  Height = 429
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Add to DataBase'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDblClick = FormDblClick
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object ShellTreeView1: TShellTreeView
    Left = 0
    Top = 0
    Width = 309
    Height = 298
    ObjectTypes = [otFolders, otNonFolders, otHidden]
    Root = 'rfDesktop'
    UseShellImages = True
    Align = alClient
    AutoRefresh = False
    HideSelection = False
    Indent = 19
    ParentColor = False
    RightClickSelect = True
    ShowRoot = False
    TabOrder = 0
    OnMouseDown = Image1MouseDown
    OnChange = ShellTreeView1Change
  end
  object Panel1: TPanel
    Left = 309
    Top = 0
    Width = 233
    Height = 298
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 1
    object Label1: TLabel
      Left = 154
      Top = 120
      Width = 31
      Height = 13
      Caption = 'Owner'
    end
    object Label2: TLabel
      Left = 15
      Top = 168
      Width = 82
      Height = 13
      Caption = 'Shared keywords'
    end
    object Image1: TImage
      Left = 13
      Top = 8
      Width = 100
      Height = 100
      PopupMenu = PopupMenu1
      Proportional = True
      Stretch = True
      OnMouseDown = Image1MouseDown
    end
    object Label_type: TLabel
      Left = 120
      Top = 40
      Width = 24
      Height = 13
      Caption = 'Type'
    end
    object Label_width: TLabel
      Left = 120
      Top = 56
      Width = 28
      Height = 13
      Caption = 'Width'
    end
    object Label3: TLabel
      Left = 19
      Top = 120
      Width = 46
      Height = 13
      Caption = 'Collection'
    end
    object Label_height: TLabel
      Left = 120
      Top = 72
      Width = 31
      Height = 13
      Caption = 'Hieght'
    end
    object Label4: TLabel
      Left = 120
      Top = 8
      Width = 55
      Height = 13
      Caption = 'Information:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsUnderline]
      ParentFont = False
    end
    object Name_label: TLabel
      Left = 120
      Top = 24
      Width = 105
      Height = 13
      AutoSize = False
      Caption = 'Name'
    end
    object Label5: TLabel
      Left = 120
      Top = 88
      Width = 70
      Height = 13
      Caption = 'Database Info:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsUnderline]
      ParentFont = False
      Visible = False
    end
    object id_label: TLabel
      Left = 120
      Top = 104
      Width = 11
      Height = 13
      Caption = 'ID'
      Visible = False
    end
    object Edit1: TEdit
      Left = 152
      Top = 136
      Width = 73
      Height = 21
      TabOrder = 0
      Text = 'Dolphin'
    end
    object Memo1: TMemo
      Left = 16
      Top = 184
      Width = 209
      Height = 73
      ScrollBars = ssVertical
      TabOrder = 1
    end
    object Edit2: TEdit
      Left = 16
      Top = 136
      Width = 89
      Height = 21
      TabOrder = 2
      Text = 'PhotoAlbum'
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 298
    Width = 542
    Height = 97
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object LabelFolder: TLabel
      Left = 8
      Top = 56
      Width = 521
      Height = 41
      AutoSize = False
      Caption = 'LabelFolder'
      WordWrap = True
    end
    object LabelFileName: TLabel
      Left = 8
      Top = 32
      Width = 441
      Height = 17
      AutoSize = False
      Caption = 'Current File'
    end
    object DmProgress1: TDmProgress
      Left = 8
      Top = 7
      Width = 225
      Height = 18
      Position = 0
      MinValue = 0
      MaxValue = 100
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 16711808
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      Text = 'Progress... (&%%)'
      BorderColor = 38400
      CoolColor = 38400
      Color = clBlack
      View = dm_pr_cool
    end
    object Button1: TButton
      Left = 240
      Top = 8
      Width = 75
      Height = 17
      Caption = 'Ok'
      TabOrder = 1
    end
    object CheckBox1: TCheckBox
      Left = 344
      Top = 8
      Width = 97
      Height = 17
      Caption = 'SubFolders'
      TabOrder = 2
      Visible = False
    end
    object CheckBox2: TCheckBox
      Left = 344
      Top = 24
      Width = 97
      Height = 17
      Caption = 'MaxScaning'
      TabOrder = 3
      Visible = False
    end
  end
  object SaveWindowPos1: TSaveWindowPos
    SetOnlyPosition = False
    RootKey = HKEY_CURRENT_USER
    Key = 'Software\DolphinImagesDB\AddForm'
    Left = 256
    Top = 16
  end
  object PopupMenu1: TPopupMenu
    OnPopup = PopupMenu1Popup
    Left = 288
    Top = 16
    object Shell1: TMenuItem
      Caption = 'Shell'
      ImageIndex = 0
      OnClick = Shell1Click
    end
    object Show1: TMenuItem
      Caption = 'Show'
      ImageIndex = 1
      OnClick = Show1Click
    end
    object Copy1: TMenuItem
      Caption = 'Copy'
      ImageIndex = 4
      OnClick = Copy1Click
    end
    object Private1: TMenuItem
      Caption = 'Private'
      ImageIndex = 6
      Visible = False
      OnClick = Private1Click
    end
    object Rating1: TMenuItem
      Caption = 'Rating'
      Visible = False
      object N01: TMenuItem
        Caption = '0'
        OnClick = N01Click
      end
      object N11: TMenuItem
        Caption = '1'
        OnClick = N01Click
      end
      object N21: TMenuItem
        Caption = '2'
        OnClick = N01Click
      end
      object N31: TMenuItem
        Caption = '3'
        OnClick = N01Click
      end
      object N41: TMenuItem
        Caption = '4'
        OnClick = N01Click
      end
      object N51: TMenuItem
        Caption = '5'
        OnClick = N01Click
      end
    end
    object Rotate1: TMenuItem
      Caption = 'Rotate'
      Visible = False
      object None1: TMenuItem
        Caption = 'None'
        OnClick = None1Click
      end
      object N90CW1: TMenuItem
        Tag = 1
        Caption = '90* CW'
        OnClick = None1Click
      end
      object N1801: TMenuItem
        Tag = 2
        Caption = '180*'
        OnClick = None1Click
      end
      object N90CCW1: TMenuItem
        Tag = 3
        Caption = '90* CCW'
        OnClick = None1Click
      end
    end
    object SearchForIt1: TMenuItem
      Caption = 'Search For It'
      ImageIndex = 2
      Visible = False
      OnClick = SearchForIt1Click
    end
    object Property1: TMenuItem
      Caption = 'Property'
      ImageIndex = 5
      OnClick = Property1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object AddFile1: TMenuItem
      Caption = 'Add File'
      ImageIndex = 3
      Visible = False
    end
  end
  object ShellChangeNotifier1: TShellChangeNotifier
    NotifyFilters = [nfFileNameChange, nfDirNameChange]
    Root = 'D:\Dmitry\'
    WatchSubTree = False
    OnChange = ShellChangeNotifier1Change
    Left = 360
    Top = 16
  end
end
