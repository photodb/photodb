object DBReplaceForm: TDBReplaceForm
  Left = 139
  Top = 91
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Replace'
  ClientHeight = 393
  ClientWidth = 524
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
  DesignSize = (
    524
    393)
  PixelsPerInch = 96
  TextHeight = 13
  object LvMain: TListView
    Left = 184
    Top = 8
    Width = 156
    Height = 282
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <>
    HideSelection = False
    HotTrack = True
    HotTrackStyles = [htHandPoint, htUnderlineHot]
    LargeImages = SizeImageList
    TabOrder = 0
    OnContextPopup = LvMainContextPopup
    OnCustomDrawItem = LvMainCustomDrawItem
    OnMouseDown = LvMainMouseDown
    OnSelectItem = LvMainSelectItem
    ExplicitWidth = 169
    ExplicitHeight = 269
  end
  object Panel2: TPanel
    Left = 347
    Top = 8
    Width = 169
    Height = 281
    Anchors = [akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitLeft = 360
    ExplicitHeight = 269
    DesignSize = (
      169
      281)
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
      Width = 120
      Height = 13
      Anchors = [akLeft, akTop, akRight]
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
      Width = 120
      Height = 13
      Anchors = [akLeft, akTop, akRight]
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
      Width = 120
      Height = 13
      Anchors = [akLeft, akTop, akRight]
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
      Width = 120
      Height = 13
      Anchors = [akLeft, akTop, akRight]
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
      Width = 120
      Height = 13
      Anchors = [akLeft, akTop, akRight]
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
      Width = 120
      Height = 13
      Anchors = [akLeft, akTop, akRight]
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
      Width = 169
      Height = 41
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoSize = False
      BorderStyle = bsNone
      ParentColor = True
      ReadOnly = True
      TabOrder = 6
      Text = '<data>'
      ExplicitHeight = 29
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 180
    Height = 289
    Anchors = [akLeft, akTop, akBottom]
    BevelOuter = bvNone
    TabOrder = 2
    ExplicitHeight = 277
    DesignSize = (
      180
      289)
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
      Width = 25
      Height = 13
      Caption = 'Path:'
    end
    object F_NAME: TEdit
      Tag = 1
      Left = 56
      Top = 136
      Width = 121
      Height = 13
      Anchors = [akLeft, akTop, akRight]
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
      Anchors = [akLeft, akTop, akRight]
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
      Anchors = [akLeft, akTop, akRight]
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
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      BorderStyle = bsNone
      ParentColor = True
      ReadOnly = True
      TabOrder = 3
      Text = '<data>'
    end
    object F_PATH: TMemo
      Tag = 1
      Left = 8
      Top = 216
      Width = 169
      Height = 69
      Anchors = [akLeft, akTop, akRight, akBottom]
      BorderStyle = bsNone
      Color = clBtnFace
      Lines.Strings = (
        '<data>')
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 4
      ExplicitHeight = 57
    end
  end
  object BtnReplaceAndDeleteDuplicates: TButton
    Left = 185
    Top = 295
    Width = 209
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Replace and Delete Dubplicates'
    TabOrder = 3
    OnClick = BtnReplaceAndDeleteDuplicatesClick
    ExplicitLeft = 198
    ExplicitTop = 283
  end
  object BtnAdd: TButton
    Left = 185
    Top = 327
    Width = 105
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Add'
    TabOrder = 4
    OnClick = BtnAddClick
    ExplicitLeft = 198
    ExplicitTop = 315
  end
  object BtnReplace: TButton
    Left = 297
    Top = 327
    Width = 105
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Replace'
    TabOrder = 5
    OnClick = BtnReplaceClick
    ExplicitLeft = 310
    ExplicitTop = 315
  end
  object BtnSkip: TButton
    Left = 409
    Top = 327
    Width = 105
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Skip'
    TabOrder = 6
    OnClick = BtnSkipClick
    ExplicitLeft = 422
    ExplicitTop = 315
  end
  object BtnDeleteFile: TButton
    Left = 400
    Top = 295
    Width = 114
    Height = 24
    Anchors = [akRight, akBottom]
    Caption = 'Delete File'
    TabOrder = 7
    OnClick = BtnDeleteFileClick
    ExplicitLeft = 413
    ExplicitTop = 283
  end
  object BtnSkipAll: TButton
    Left = 409
    Top = 359
    Width = 105
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Skip for All'
    TabOrder = 8
    OnClick = BtnSkipAllClick
    ExplicitLeft = 422
    ExplicitTop = 347
  end
  object BtnReplaceAll: TButton
    Left = 297
    Top = 359
    Width = 105
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Replace for All'
    TabOrder = 9
    OnClick = BtnReplaceAllClick
    ExplicitLeft = 310
    ExplicitTop = 347
  end
  object BtnAddAll: TButton
    Left = 185
    Top = 359
    Width = 105
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Add for All'
    TabOrder = 10
    OnClick = BtnAddAllClick
    ExplicitLeft = 198
    ExplicitTop = 347
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
