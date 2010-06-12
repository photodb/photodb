object FormManageGroups: TFormManageGroups
  Left = 388
  Top = 147
  Width = 613
  Height = 440
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSizeToolWin
  Caption = 'Manage Groups'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ListView1: TNoVSBListView1
    Left = 0
    Top = 44
    Width = 597
    Height = 340
    Align = alClient
    BorderStyle = bsNone
    Columns = <
      item
        AutoSize = True
        Caption = 'Groups:'
      end>
    FlatScrollBars = True
    HideSelection = False
    IconOptions.Arrangement = iaLeft
    IconOptions.WrapText = False
    OwnerDraw = True
    ReadOnly = True
    ParentShowHint = False
    ShowHint = False
    SmallImages = ImageList1
    TabOrder = 0
    ViewStyle = vsReport
    OnContextPopup = ImageContextPopup
    OnCustomDrawItem = ListView1CustomDrawItem
    OnDblClick = ListView1DblClick
  end
  object CoolBar1: TCoolBar
    Left = 0
    Top = 0
    Width = 597
    Height = 44
    AutoSize = True
    Bands = <
      item
        Control = ToolBar1
        ImageIndex = -1
        MinHeight = 40
        Width = 593
      end>
    object ToolBar1: TToolBar
      Left = 9
      Top = 0
      Width = 580
      Height = 40
      AutoSize = True
      ButtonHeight = 38
      ButtonWidth = 79
      Caption = 'ToolBar1'
      EdgeBorders = []
      Images = ToolBarImageList
      List = True
      ShowCaptions = True
      TabOrder = 0
      Wrapable = False
      object ToolButton5: TToolButton
        Left = 0
        Top = 2
        AutoSize = True
        Caption = 'Exit'
        ImageIndex = 3
        OnClick = ToolButton5Click
      end
      object ToolButton4: TToolButton
        Left = 64
        Top = 2
        Width = 8
        Caption = 'ToolButton4'
        ImageIndex = 3
        Style = tbsSeparator
      end
      object ToolButton1: TToolButton
        Left = 72
        Top = 2
        AutoSize = True
        Caption = 'Add'
        ImageIndex = 0
        OnClick = MenuActionAddGroup
      end
      object ToolButton2: TToolButton
        Left = 138
        Top = 2
        AutoSize = True
        Caption = 'Edit'
        ImageIndex = 1
        OnClick = ToolButton2Click
      end
      object ToolButton6: TToolButton
        Left = 203
        Top = 2
        Width = 8
        Caption = 'ToolButton6'
        ImageIndex = 3
        Style = tbsSeparator
      end
      object ToolButton3: TToolButton
        Left = 211
        Top = 2
        AutoSize = True
        Caption = 'Delete'
        ImageIndex = 2
        OnClick = ToolButton3Click
      end
      object ToolButton7: TToolButton
        Left = 289
        Top = 2
        Width = 8
        Caption = 'ToolButton7'
        ImageIndex = 3
        Style = tbsSeparator
      end
      object ToolButton8: TToolButton
        Left = 297
        Top = 2
        AutoSize = True
        Caption = 'Options'
        ImageIndex = 3
        OnClick = SelectFont1Click
      end
    end
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 16
    Top = 48
  end
  object ImageList1: TImageList
    Height = 50
    Width = 50
    Left = 80
    Top = 168
  end
  object MainMenu1: TMainMenu
    Left = 184
    Top = 88
    object File1: TMenuItem
      Caption = 'File'
      object Exit1: TMenuItem
        Caption = 'Exit'
        OnClick = Exit1Click
      end
    end
    object Actions1: TMenuItem
      Caption = 'Actions'
      object AddGroup1: TMenuItem
        Caption = 'Add Group'
        OnClick = MenuActionAddGroup
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object ShowAll1: TMenuItem
        Caption = 'Show All'
        OnClick = ShowAll1Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object SelectFont1: TMenuItem
        Caption = 'Select Font'
        OnClick = SelectFont1Click
      end
    end
    object Help1: TMenuItem
      Caption = 'Help'
      object Contents1: TMenuItem
        Caption = 'Contents'
        OnClick = Contents1Click
      end
    end
  end
  object ToolBarImageList: TImageList
    Height = 32
    Width = 32
    Left = 272
    Top = 128
  end
end
