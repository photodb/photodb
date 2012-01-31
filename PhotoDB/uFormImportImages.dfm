object FormImportImages: TFormImportImages
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Import pictures'
  ClientHeight = 505
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
    505)
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
  object LbLabel: TLabel
    Left = 8
    Top = 725
    Width = 29
    Height = 13
    Caption = 'Label:'
  end
  object LbDate: TLabel
    Left = 8
    Top = 679
    Width = 27
    Height = 13
    Caption = 'Date:'
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
  object WedLabel: TWatermarkedEdit
    Left = 8
    Top = 744
    Width = 891
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 5
    WatermarkText = 'WatermarkedEdit1'
  end
  object DtpDate: TDateTimePicker
    Left = 8
    Top = 698
    Width = 233
    Height = 21
    Date = 40929.867802500000000000
    Time = 40929.867802500000000000
    TabOrder = 6
  end
  object CbOnlyImages: TCheckBox
    Left = 8
    Top = 154
    Width = 891
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Import only supported images'
    TabOrder = 7
  end
  object BtnOk: TButton
    Left = 825
    Top = 473
    Width = 74
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Ok'
    TabOrder = 8
    OnClick = BtnOkClick
  end
  object BtnCancel: TButton
    Left = 743
    Top = 473
    Width = 76
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Cancel'
    TabOrder = 9
    OnClick = BtnCancelClick
  end
  object CbDeleteAfterImport: TCheckBox
    Left = 8
    Top = 177
    Width = 891
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Delete files after import'
    TabOrder = 10
  end
  object WlExtendedMode: TWebLink
    Left = 8
    Top = 660
    Width = 80
    Height = 13
    Cursor = crHandPoint
    Text = 'Extended mode'
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
  object CbAddToCollection: TCheckBox
    Left = 8
    Top = 200
    Width = 891
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Add files to collection after copying files'
    TabOrder = 12
  end
  object GbSeries: TGroupBox
    Left = 8
    Top = 226
    Width = 891
    Height = 241
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Series of photos'
    TabOrder = 13
    DesignSize = (
      891
      241)
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
      Width = 868
      Height = 113
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
      TabOrder = 1
      View = elsFilmStrip
      WheelMouseDefaultScroll = edwsHorz
    end
  end
  object WebLink6: TWebLink
    Left = 8
    Top = 473
    Width = 64
    Height = 13
    Cursor = crHandPoint
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
    Top = 473
    Width = 22
    Height = 22
    Active = True
    FillPercent = 50
    SignColor = clBlack
    MaxTransparencity = 255
  end
end
