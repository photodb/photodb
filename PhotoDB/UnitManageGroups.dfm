object FormManageGroups: TFormManageGroups
  Left = 388
  Top = 147
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSizeToolWin
  Caption = 'Manage Groups'
  ClientHeight = 406
  ClientWidth = 597
  Color = clBtnFace
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
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LvMain: TNoVSBListView1
    Left = 0
    Top = 42
    Width = 597
    Height = 364
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
    OnCustomDrawItem = LvMainCustomDrawItem
    OnDblClick = LvMainDblClick
    ExplicitHeight = 344
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
      ButtonWidth = 75
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
    end
  end
  object ImlGroups: TImageList
    ColorDepth = cd32Bit
    Height = 50
    Width = 50
    Left = 64
    Top = 176
  end
  object ToolBarImageList: TImageList
    ColorDepth = cd32Bit
    Height = 32
    Width = 32
    Left = 64
    Top = 232
  end
end
