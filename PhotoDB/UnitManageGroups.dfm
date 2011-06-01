object FormManageGroups: TFormManageGroups
  Left = 388
  Top = 147
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSizeToolWin
  Caption = 'Manage Groups'
  ClientHeight = 386
  ClientWidth = 597
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Menu = MmMain
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
    Top = 42
    Width = 597
    Height = 344
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
    SmallImages = ImlGroups
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
    Height = 42
    AutoSize = True
    Bands = <
      item
        Control = ToolBar1
        ImageIndex = -1
        MinHeight = 38
        Width = 591
      end>
    object ToolBar1: TToolBar
      Left = 11
      Top = 0
      Width = 582
      Height = 38
      AutoSize = True
      ButtonHeight = 38
      ButtonWidth = 80
      Caption = 'ToolBar1'
      Images = ToolBarImageList
      List = True
      ShowCaptions = True
      TabOrder = 0
      Wrapable = False
      object TbExit: TToolButton
        Left = 0
        Top = 0
        AutoSize = True
        Caption = 'Exit'
        ImageIndex = 3
        OnClick = TbExitClick
      end
      object ToolButton4: TToolButton
        Left = 65
        Top = 0
        Width = 8
        Caption = 'ToolButton4'
        ImageIndex = 3
        Style = tbsSeparator
      end
      object TbAdd: TToolButton
        Left = 73
        Top = 0
        AutoSize = True
        Caption = 'Add'
        ImageIndex = 0
        OnClick = MenuActionAddGroup
      end
      object TbEdit: TToolButton
        Left = 139
        Top = 0
        AutoSize = True
        Caption = 'Edit'
        ImageIndex = 1
        OnClick = TbEditClick
      end
      object ToolButton6: TToolButton
        Left = 204
        Top = 0
        Width = 8
        Caption = 'ToolButton6'
        ImageIndex = 3
        Style = tbsSeparator
      end
      object TbDelete: TToolButton
        Left = 212
        Top = 0
        AutoSize = True
        Caption = 'Delete'
        ImageIndex = 2
        OnClick = TbDeleteClick
      end
      object ToolButton7: TToolButton
        Left = 290
        Top = 0
        Width = 8
        Caption = 'ToolButton7'
        ImageIndex = 3
        Style = tbsSeparator
      end
      object TbOptions: TToolButton
        Left = 298
        Top = 0
        AutoSize = True
        Caption = 'Options'
        ImageIndex = 3
        OnClick = SelectFont1Click
      end
    end
  end
  object ImlGroups: TImageList
    Height = 50
    Width = 50
    Left = 64
    Top = 176
  end
  object MmMain: TMainMenu
    Left = 64
    Top = 224
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
    ColorDepth = cd32Bit
    Height = 32
    Width = 32
    Left = 64
    Top = 272
  end
end
