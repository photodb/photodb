object DBReplaceForm: TDBReplaceForm
  Left = 139
  Top = 91
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Replace'
  ClientHeight = 380
  ClientWidth = 537
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object ListView1: TListView
    Left = 184
    Top = 8
    Width = 169
    Height = 263
    Columns = <>
    HideSelection = False
    HotTrack = True
    HotTrackStyles = [htHandPoint, htUnderlineHot]
    LargeImages = SizeImageList
    TabOrder = 0
    OnContextPopup = ListView1ContextPopup
    OnCustomDrawItem = ListView1CustomDrawItem
    OnMouseDown = ListView1MouseDown
    OnSelectItem = ListView1SelectItem
  end
  object Panel1: TPanel
    Left = 192
    Top = 272
    Width = 345
    Height = 105
    BevelOuter = bvNone
    TabOrder = 1
    object Button1: TButton
      Left = 8
      Top = 40
      Width = 105
      Height = 25
      Caption = 'Add'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 120
      Top = 72
      Width = 105
      Height = 25
      Caption = 'Replace for All'
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 232
      Top = 72
      Width = 105
      Height = 25
      Caption = 'Skip for All'
      TabOrder = 2
      OnClick = Button3Click
    end
    object Button5: TButton
      Left = 120
      Top = 40
      Width = 105
      Height = 25
      Caption = 'Replace'
      TabOrder = 3
      OnClick = Button5Click
    end
    object Button6: TButton
      Left = 232
      Top = 40
      Width = 105
      Height = 25
      Caption = 'Skip'
      TabOrder = 4
      OnClick = Button6Click
    end
    object Button4: TButton
      Left = 6
      Top = 72
      Width = 107
      Height = 25
      Caption = 'Add for All'
      TabOrder = 5
      OnClick = Button4Click
    end
    object Button7: TButton
      Left = 8
      Top = 8
      Width = 209
      Height = 25
      Caption = 'Replace and Delete Dublicates'
      TabOrder = 6
      OnClick = Button7Click
    end
    object Button8: TButton
      Left = 223
      Top = 8
      Width = 114
      Height = 24
      Caption = 'Delete File'
      TabOrder = 7
      OnClick = Button8Click
    end
  end
  object Panel2: TPanel
    Left = 360
    Top = 8
    Width = 169
    Height = 265
    BevelOuter = bvNone
    TabOrder = 2
    object LabelDBRating: TLabel
      Left = 0
      Top = 160
      Width = 31
      Height = 13
      Caption = 'Rating'
    end
    object LabelDBWidth: TLabel
      Left = 0
      Top = 176
      Width = 28
      Height = 13
      Caption = 'Width'
    end
    object LabelDBHeight: TLabel
      Left = 0
      Top = 192
      Width = 31
      Height = 13
      Caption = 'Height'
    end
    object Image2: TImage
      Left = 2
      Top = 2
      Width = 105
      Height = 105
      OnContextPopup = Image2ContextPopup
      OnMouseDown = Image2MouseDown
    end
    object LabelDBInfo: TLabel
      Left = 0
      Top = 112
      Width = 55
      Height = 13
      Caption = 'DB file Info:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsUnderline]
      ParentFont = False
      WordWrap = True
    end
    object DbLabel_id: TLabel
      Left = 0
      Top = 128
      Width = 11
      Height = 13
      Caption = 'ID'
    end
    object LabelDBName: TLabel
      Left = 0
      Top = 144
      Width = 28
      Height = 13
      Caption = 'Name'
    end
    object LabelDBSize: TLabel
      Left = 0
      Top = 208
      Width = 20
      Height = 13
      Caption = 'Size'
    end
    object LabelDBPath: TLabel
      Left = 0
      Top = 224
      Width = 28
      Height = 13
      Caption = 'Pach:'
    end
    object DB_ID: TEdit
      Tag = 1
      Left = 48
      Top = 128
      Width = 97
      Height = 13
      AutoSize = False
      BorderStyle = bsNone
      ParentColor = True
      ReadOnly = True
      TabOrder = 0
      Text = '<data>'
    end
    object DB_NAME: TEdit
      Tag = 1
      Left = 48
      Top = 144
      Width = 97
      Height = 13
      AutoSize = False
      BorderStyle = bsNone
      ParentColor = True
      ReadOnly = True
      TabOrder = 1
      Text = '<data>'
    end
    object DB_RATING: TEdit
      Tag = 1
      Left = 48
      Top = 160
      Width = 97
      Height = 13
      AutoSize = False
      BorderStyle = bsNone
      ParentColor = True
      ReadOnly = True
      TabOrder = 2
      Text = '<data>'
    end
    object DB_WIDTH: TEdit
      Tag = 1
      Left = 48
      Top = 176
      Width = 97
      Height = 13
      AutoSize = False
      BorderStyle = bsNone
      ParentColor = True
      ReadOnly = True
      TabOrder = 3
      Text = '<data>'
    end
    object DB_HEIGHT: TEdit
      Tag = 1
      Left = 48
      Top = 192
      Width = 97
      Height = 13
      AutoSize = False
      BorderStyle = bsNone
      ParentColor = True
      ReadOnly = True
      TabOrder = 4
      Text = '<data>'
    end
    object DB_SIZE: TEdit
      Tag = 1
      Left = 48
      Top = 208
      Width = 97
      Height = 13
      AutoSize = False
      BorderStyle = bsNone
      ParentColor = True
      ReadOnly = True
      TabOrder = 5
      Text = '<data>'
    end
    object DB_PATCH: TEdit
      Tag = 1
      Left = 0
      Top = 240
      Width = 145
      Height = 17
      AutoSize = False
      BorderStyle = bsNone
      ParentColor = True
      ReadOnly = True
      TabOrder = 6
      Text = '<data>'
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 180
    Height = 273
    BevelOuter = bvNone
    TabOrder = 3
    object Image1: TImage
      Left = 10
      Top = 10
      Width = 105
      Height = 105
      OnDblClick = Image1DblClick
      OnMouseDown = Image1MouseDown
    end
    object LabelCurrentInfo: TLabel
      Left = 8
      Top = 120
      Width = 80
      Height = 13
      Caption = 'Current File I nfo:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsUnderline]
      ParentFont = False
      WordWrap = True
    end
    object LabelFName: TLabel
      Left = 8
      Top = 136
      Width = 28
      Height = 13
      Caption = 'Name'
    end
    object LabelFSize: TLabel
      Left = 8
      Top = 152
      Width = 20
      Height = 13
      Caption = 'Size'
    end
    object LabelFWidth: TLabel
      Left = 8
      Top = 168
      Width = 28
      Height = 13
      Caption = 'Width'
    end
    object LabelFHeight: TLabel
      Left = 8
      Top = 184
      Width = 31
      Height = 13
      Caption = 'Height'
    end
    object LabelFPath: TLabel
      Left = 8
      Top = 200
      Width = 28
      Height = 13
      Caption = 'Pach:'
    end
    object F_NAME: TEdit
      Tag = 1
      Left = 56
      Top = 136
      Width = 121
      Height = 13
      AutoSize = False
      BorderStyle = bsNone
      ParentColor = True
      ReadOnly = True
      TabOrder = 0
      Text = '<data>'
    end
    object F_SIZE: TEdit
      Tag = 1
      Left = 56
      Top = 152
      Width = 121
      Height = 13
      AutoSize = False
      BorderStyle = bsNone
      ParentColor = True
      ReadOnly = True
      TabOrder = 1
      Text = '<data>'
    end
    object F_WIDTH: TEdit
      Tag = 1
      Left = 56
      Top = 168
      Width = 121
      Height = 13
      AutoSize = False
      BorderStyle = bsNone
      ParentColor = True
      ReadOnly = True
      TabOrder = 2
      Text = '<data>'
    end
    object F_HEIGHT: TEdit
      Tag = 1
      Left = 56
      Top = 184
      Width = 121
      Height = 13
      AutoSize = False
      BorderStyle = bsNone
      ParentColor = True
      ReadOnly = True
      TabOrder = 3
      Text = '<data>'
    end
    object F_PATCH: TMemo
      Tag = 1
      Left = 8
      Top = 216
      Width = 169
      Height = 57
      BorderStyle = bsNone
      Color = clBtnFace
      Lines.Strings = (
        '<data>')
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 4
    end
  end
  object SizeImageList: TImageList
    Height = 102
    Width = 102
    Left = 16
    Top = 16
  end
  object PopupMenu1: TPopupMenu
    Left = 48
    Top = 16
    object Delete1: TMenuItem
      Caption = 'Delete'
      OnClick = Delete1Click
    end
  end
  object DropFileSource1: TDropFileSource
    DragTypes = [dtCopy]
    Images = DragImageList
    ShowImage = True
    Left = 56
    Top = 320
  end
  object DropFileTarget1: TDropFileTarget
    DragTypes = []
    OptimizedMove = True
    Left = 88
    Top = 320
  end
  object DragImageList: TImageList
    Left = 24
    Top = 320
  end
end
