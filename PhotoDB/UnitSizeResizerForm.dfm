object FormSizeResizer: TFormSizeResizer
  Left = 366
  Top = 205
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsToolWindow
  Caption = 'Change Image'
  ClientHeight = 500
  ClientWidth = 406
  Color = clBtnFace
  Constraints.MinWidth = 340
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    406
    500)
  PixelsPerInch = 96
  TextHeight = 13
  object LbInfo: TLabel
    Left = 8
    Top = 8
    Width = 410
    Height = 49
    AutoSize = False
    Caption = 
      'You can resize you image(s) and convert they in other graphic fo' +
      'rmat, which you can select in combobox follow:'
    WordWrap = True
  end
  object BtOk: TButton
    Left = 323
    Top = 469
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    Enabled = False
    TabOrder = 0
    OnClick = BtOkClick
  end
  object BtCancel: TButton
    Left = 242
    Top = 469
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = BtCancelClick
  end
  object BtSaveAsDefault: TButton
    Left = 8
    Top = 469
    Width = 153
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Save settings as default'
    TabOrder = 2
    OnClick = BtSaveAsDefaultClick
  end
  object EdImageName: TEdit
    Left = 8
    Top = 258
    Width = 390
    Height = 21
    Anchors = [akLeft, akRight, akBottom]
    Enabled = False
    ReadOnly = True
    TabOrder = 3
    Text = 'Image Name'
  end
  object LsMain: TLoadingSign
    Left = 370
    Top = 63
    Width = 16
    Height = 16
    Visible = False
    Active = True
    FillPercent = 0
    Anchors = [akTop, akRight]
  end
  object PrbMain: TDmProgress
    Left = 8
    Top = 234
    Width = 390
    Height = 18
    Visible = False
    Anchors = [akLeft, akRight, akBottom]
    MaxValue = 100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 16711808
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Text = 'Progress... (&%%)'
    BorderColor = 38400
    CoolColor = 38400
    Color = clBlack
    View = dm_pr_cool
    Inverse = False
  end
  object PnOptions: TPanel
    Left = 0
    Top = 285
    Width = 406
    Height = 178
    Anchors = [akLeft, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 6
    DesignSize = (
      406
      178)
    object LbSizeSeparator: TLabel
      Left = 341
      Top = 91
      Width = 7
      Height = 13
      Anchors = [akRight, akBottom]
      Caption = 'X'
      Enabled = False
      ExplicitLeft = 362
      ExplicitTop = 126
    end
    object CbWatermark: TCheckBox
      Left = 8
      Top = 7
      Width = 115
      Height = 17
      Anchors = [akLeft, akBottom]
      Caption = 'Add watermark'
      TabOrder = 0
      OnClick = CbWatermarkClick
    end
    object CbConvert: TCheckBox
      Left = 8
      Top = 35
      Width = 114
      Height = 17
      Anchors = [akLeft, akBottom]
      Caption = 'Convert:'
      TabOrder = 1
      OnClick = CbConvertClick
    end
    object DdConvert: TComboBox
      Left = 128
      Top = 34
      Width = 158
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akRight, akBottom]
      Enabled = False
      TabOrder = 2
      OnChange = DdConvertChange
    end
    object BtJPEGOptions: TButton
      Left = 292
      Top = 33
      Width = 106
      Height = 22
      Anchors = [akRight, akBottom]
      Caption = 'JPEG Optinons'
      DoubleBuffered = False
      Enabled = False
      ParentDoubleBuffered = False
      TabOrder = 3
      OnClick = BtJPEGOptionsClick
    end
    object DdRotate: TComboBox
      Left = 128
      Top = 61
      Width = 158
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akRight, akBottom]
      Enabled = False
      TabOrder = 4
    end
    object CbRotate: TCheckBox
      Left = 8
      Top = 63
      Width = 114
      Height = 17
      Anchors = [akLeft, akBottom]
      Caption = 'Rotate:'
      TabOrder = 5
      OnClick = CbRotateClick
    end
    object CbResize: TCheckBox
      Left = 8
      Top = 91
      Width = 114
      Height = 17
      Anchors = [akLeft, akBottom]
      Caption = 'Resize:'
      TabOrder = 6
      OnClick = CbResizeClick
    end
    object DdResizeAction: TComboBox
      Left = 128
      Top = 88
      Width = 158
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akRight, akBottom]
      DropDownCount = 20
      Enabled = False
      TabOrder = 7
      OnChange = DdResizeActionChange
    end
    object EdWidth: TEdit
      Left = 292
      Top = 88
      Width = 41
      Height = 21
      Anchors = [akRight, akBottom]
      Enabled = False
      TabOrder = 8
      Text = '1024'
      OnExit = EdWidthExit
      OnKeyPress = EdHeightKeyPress
    end
    object EdHeight: TEdit
      Left = 357
      Top = 88
      Width = 41
      Height = 21
      Anchors = [akRight, akBottom]
      Enabled = False
      TabOrder = 9
      Text = '768'
      OnExit = EdWidthExit
      OnKeyPress = EdHeightKeyPress
    end
    object CbAspectRatio: TCheckBox
      Left = 128
      Top = 117
      Width = 270
      Height = 17
      Anchors = [akLeft, akRight, akBottom]
      Caption = 'Preserve aspect ratio'
      Checked = True
      State = cbChecked
      TabOrder = 10
    end
    object CbAddSuffix: TCheckBox
      Left = 128
      Top = 135
      Width = 270
      Height = 17
      Anchors = [akLeft, akRight, akBottom]
      Caption = 'Add filename suffix'
      Checked = True
      State = cbChecked
      TabOrder = 11
    end
    object EdSavePath: TEdit
      Left = 8
      Top = 157
      Width = 365
      Height = 21
      Anchors = [akLeft, akRight, akBottom]
      ReadOnly = True
      TabOrder = 12
      Text = 'C:\'
    end
    object BtChangeDirectory: TButton
      Left = 379
      Top = 156
      Width = 19
      Height = 22
      Anchors = [akRight, akBottom]
      Caption = '...'
      TabOrder = 13
      OnClick = BtChangeDirectoryClick
    end
    object BtWatermarkOptions: TButton
      Left = 128
      Top = 7
      Width = 158
      Height = 22
      Anchors = [akRight, akBottom]
      Caption = 'Watermark Optinons'
      DoubleBuffered = False
      Enabled = False
      ParentDoubleBuffered = False
      TabOrder = 14
      OnClick = BtWatermarkOptionsClick
    end
  end
  object ImlWatermarkPatterns: TImageList
    Left = 8
    Top = 8
  end
end
