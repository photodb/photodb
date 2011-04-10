object DBReplaceForm: TDBReplaceForm
  Left = 139
  Top = 91
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Replace'
  ClientHeight = 396
  ClientWidth = 502
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    502
    396)
  PixelsPerInch = 96
  TextHeight = 13
  object PnDBInfo: TPanel
    Left = 325
    Top = 8
    Width = 169
    Height = 293
    Anchors = [akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitLeft = 344
    DesignSize = (
      169
      293)
    object LabelDBRating: TLabel
      Left = -1
      Top = 164
      Width = 31
      Height = 13
      Caption = 'Rating'
    end
    object LabelDBWidth: TLabel
      Left = -1
      Top = 182
      Width = 28
      Height = 13
      Caption = 'Width'
    end
    object LabelDBHeight: TLabel
      Left = -1
      Top = 200
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
    end
    object DbLabel_id: TLabel
      Left = 0
      Top = 128
      Width = 11
      Height = 13
      Caption = 'ID'
    end
    object LabelDBName: TLabel
      Left = -1
      Top = 146
      Width = 28
      Height = 13
      Caption = 'Name'
    end
    object LabelDBSize: TLabel
      Left = -1
      Top = 218
      Width = 20
      Height = 13
      Caption = 'Size'
    end
    object LabelDBPath: TLabel
      Left = -1
      Top = 236
      Width = 25
      Height = 13
      Caption = 'Path:'
    end
    object DB_ID: TEdit
      Tag = 1
      Left = 48
      Top = 128
      Width = 120
      Height = 18
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
      Left = 47
      Top = 146
      Width = 120
      Height = 18
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
      Left = 47
      Top = 164
      Width = 120
      Height = 18
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
      Left = 47
      Top = 182
      Width = 120
      Height = 18
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
      Left = 47
      Top = 200
      Width = 120
      Height = 18
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
      Left = 47
      Top = 218
      Width = 120
      Height = 18
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      BorderStyle = bsNone
      ParentColor = True
      ReadOnly = True
      TabOrder = 5
      Text = '<data>'
    end
    object DB_PATH: TEdit
      Tag = 1
      Left = 0
      Top = 255
      Width = 169
      Height = 38
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoSize = False
      BorderStyle = bsNone
      ParentColor = True
      ReadOnly = True
      TabOrder = 6
      Text = '<data>'
    end
  end
  object PnFileInfo: TPanel
    Left = 0
    Top = 0
    Width = 180
    Height = 301
    Anchors = [akLeft, akTop, akBottom]
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      180
      301)
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
      Top = 154
      Width = 20
      Height = 13
      Caption = 'Size'
    end
    object LabelFWidth: TLabel
      Left = 8
      Top = 172
      Width = 28
      Height = 13
      Caption = 'Width'
    end
    object LabelFHeight: TLabel
      Left = 8
      Top = 190
      Width = 31
      Height = 13
      Caption = 'Height'
    end
    object LabelFPath: TLabel
      Left = 8
      Top = 209
      Width = 25
      Height = 13
      Caption = 'Path:'
    end
    object F_NAME: TEdit
      Tag = 1
      Left = 56
      Top = 136
      Width = 121
      Height = 18
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
      Top = 154
      Width = 121
      Height = 18
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
      Top = 172
      Width = 121
      Height = 18
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
      Top = 190
      Width = 121
      Height = 18
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
      Top = 227
      Width = 170
      Height = 73
      Anchors = [akLeft, akTop, akRight, akBottom]
      BorderStyle = bsNone
      Color = clBtnFace
      Lines.Strings = (
        '<data>')
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 4
    end
  end
  object BtnReplaceAndDeleteDuplicates: TButton
    Left = 150
    Top = 307
    Width = 230
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Replace and Delete Dubplicates'
    TabOrder = 2
    OnClick = BtnReplaceAndDeleteDuplicatesClick
    ExplicitLeft = 169
  end
  object BtnAdd: TButton
    Left = 150
    Top = 340
    Width = 112
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Add'
    TabOrder = 3
    OnClick = BtnAddClick
    ExplicitLeft = 169
  end
  object BtnReplace: TButton
    Left = 268
    Top = 340
    Width = 112
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Replace'
    TabOrder = 4
    OnClick = BtnReplaceClick
    ExplicitLeft = 287
  end
  object BtnSkip: TButton
    Left = 386
    Top = 339
    Width = 112
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Skip'
    TabOrder = 5
    OnClick = BtnSkipClick
    ExplicitLeft = 405
  end
  object BtnDeleteFile: TButton
    Left = 386
    Top = 307
    Width = 112
    Height = 24
    Anchors = [akRight, akBottom]
    Caption = 'Delete File'
    TabOrder = 6
    OnClick = BtnDeleteFileClick
    ExplicitLeft = 405
  end
  object CbForAll: TCheckBox
    Left = 150
    Top = 371
    Width = 347
    Height = 17
    Anchors = [akTop, akRight]
    Caption = 'Do this action for all conflicts'
    TabOrder = 7
    ExplicitLeft = 169
  end
  object LvMain: TEasyListview
    Left = 186
    Top = 8
    Width = 133
    Height = 293
    Anchors = [akLeft, akTop, akRight, akBottom]
    EditManager.Font.Charset = DEFAULT_CHARSET
    EditManager.Font.Color = clWindowText
    EditManager.Font.Height = -11
    EditManager.Font.Name = 'MS Sans Serif'
    EditManager.Font.Style = []
    Header.Columns.Items = {
      0600000001000000110000005445617379436F6C756D6E53746F726564FFFECE
      0006000000800800010100010000000000000161000000FFFFFF1F0001000000
      00000000000000000000000000000000}
    PaintInfoGroup.MarginBottom.CaptionIndent = 4
    Scrollbars.HorzEnabled = False
    TabOrder = 8
    View = elsThumbnail
    OnContextPopup = LvMainContextPopup
    OnItemSelectionChanged = LvMainItemSelectionChanged
    OnItemThumbnailDraw = LvMainItemThumbnailDraw
    OnMouseDown = LvMainMouseDown
    OnMouseMove = LvMainMouseMove
    OnMouseUp = LvMainMouseUp
  end
  object SizeImageList: TImageList
    Height = 102
    Width = 102
    Left = 16
    Top = 16
  end
  object PmListView: TPopupMenu
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
    Left = 74
    Top = 321
  end
  object DropFileTarget1: TDropFileTarget
    DragTypes = []
    OptimizedMove = True
    Left = 122
    Top = 321
  end
  object DragImageList: TImageList
    Left = 24
    Top = 320
  end
end
