object FormImportImages: TFormImportImages
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Import pictures'
  ClientHeight = 531
  ClientWidth = 907
  Color = clBtnFace
  Constraints.MinWidth = 400
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    907
    531)
  PixelsPerInch = 96
  TextHeight = 13
  object LbImportFrom: TLabel
    Left = 8
    Top = 8
    Width = 102
    Height = 13
    Caption = 'Import pictures from:'
  end
  object LbDirectoryFormat: TLabel
    Left = 8
    Top = 104
    Width = 83
    Height = 13
    Caption = 'Directory format:'
  end
  object LbImportTo: TLabel
    Left = 8
    Top = 58
    Width = 90
    Height = 13
    Caption = 'Import pictures to:'
  end
  object PeImportFromPath: TPathEditor
    Left = 8
    Top = 27
    Width = 866
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    OnChange = PeImportFromPathChange
    LoadingText = 'Loading...'
    CanBreakLoading = False
    OnlyFileSystem = False
  end
  object CbFormatCombo: TComboBox
    Left = 8
    Top = 123
    Width = 233
    Height = 21
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 1
    Text = 'YYYY/MM/DD (LABEL)'
    Items.Strings = (
      'YYYY/MM/DD (LABEL)'
      'DD/MM/YYYY')
  end
  object BtnSelectPathFrom: TButton
    Left = 880
    Top = 27
    Width = 19
    Height = 25
    Anchors = [akTop, akRight]
    Caption = '...'
    TabOrder = 2
    OnClick = BtnSelectPathFromClick
  end
  object PeImportToPath: TPathEditor
    Left = 8
    Top = 73
    Width = 866
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    LoadingText = 'Loading...'
    CanBreakLoading = False
    OnlyFileSystem = True
  end
  object BtnSelectPathTo: TButton
    Left = 880
    Top = 73
    Width = 19
    Height = 25
    Anchors = [akTop, akRight]
    Caption = '...'
    TabOrder = 4
    OnClick = BtnSelectPathToClick
  end
  object CbOnlyImages: TCheckBox
    Left = 8
    Top = 154
    Width = 891
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Import only supported images'
    TabOrder = 5
  end
  object BtnOk: TButton
    Left = 825
    Top = 498
    Width = 74
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    TabOrder = 6
    OnClick = BtnOkClick
  end
  object BtnCancel: TButton
    Left = 743
    Top = 498
    Width = 76
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 7
    OnClick = BtnCancelClick
  end
  object CbDeleteAfterImport: TCheckBox
    Left = 8
    Top = 177
    Width = 891
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Delete files after import'
    TabOrder = 8
  end
  object CbAddToCollection: TCheckBox
    Left = 8
    Top = 200
    Width = 891
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Add files to collection after copying files'
    TabOrder = 9
  end
  object GbSeries: TGroupBox
    Left = 8
    Top = 226
    Width = 891
    Height = 266
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'Series of photos'
    TabOrder = 10
    DesignSize = (
      891
      266)
    object SbSeries: TScrollBox
      Left = 10
      Top = 16
      Width = 868
      Height = 98
      HorzScrollBar.Smooth = True
      HorzScrollBar.Tracking = True
      Anchors = [akLeft, akTop, akRight]
      BorderStyle = bsNone
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 0
    end
    object ElvPreview: TEasyListview
      Left = 10
      Top = 120
      Width = 872
      Height = 137
      Anchors = [akLeft, akTop, akRight, akBottom]
      BorderStyle = bsNone
      EditManager.Font.Charset = DEFAULT_CHARSET
      EditManager.Font.Color = clWindowText
      EditManager.Font.Height = -11
      EditManager.Font.Name = 'Tahoma'
      EditManager.Font.Style = []
      Header.Columns.Items = {
        0600000001000000110000005445617379436F6C756D6E53746F726564FFFECE
        0006000000800800010100010000000000000161000000FFFFFF1F0001000000
        00000000000000000000000000000000}
      PaintInfoGroup.MarginBottom.CaptionIndent = 4
      PaintInfoItem.ShowBorder = False
      Scrollbars.VertEnabled = False
      Selection.AlphaBlend = True
      Selection.AlphaBlendSelRect = True
      Selection.EnableDragSelect = True
      Selection.FullItemPaint = True
      Selection.Gradient = True
      Selection.GradientColorBottom = clGradientActiveCaption
      Selection.GradientColorTop = clGradientInactiveCaption
      Selection.RectSelect = True
      Selection.RoundRect = True
      Selection.TextColor = clWindowText
      Selection.UseFocusRect = False
      TabOrder = 1
      View = elsFilmStrip
      WheelMouseDefaultScroll = edwsHorz
      OnItemDblClick = ElvPreviewItemDblClick
      OnItemThumbnailDraw = ElvPreviewItemThumbnailDraw
    end
  end
  object WebLink6: TWebLink
    Left = 8
    Top = 510
    Width = 64
    Height = 13
    Cursor = crHandPoint
    Anchors = [akLeft, akBottom]
    Text = 'Simple mode'
    ImageIndex = 0
    IconWidth = 0
    IconHeight = 0
    UseEnterColor = False
    EnterColor = clBlack
    EnterBould = False
    TopIconIncrement = 0
    ImageCanRegenerate = True
    UseSpecIconSize = True
    HightliteImage = False
    StretchImage = True
    CanClick = True
  end
  object LsMain: TLoadingSign
    Left = 715
    Top = 498
    Width = 22
    Height = 22
    Active = True
    FillPercent = 50
    Anchors = [akRight, akBottom]
    SignColor = clBlack
    MaxTransparencity = 255
  end
end
