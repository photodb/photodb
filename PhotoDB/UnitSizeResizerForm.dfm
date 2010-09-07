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
    ExplicitLeft = 344
    ExplicitTop = 470
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
    ExplicitLeft = 263
    ExplicitTop = 470
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
    ExplicitTop = 470
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
    ExplicitTop = 259
    ExplicitWidth = 411
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
    ExplicitLeft = 391
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
    ExplicitTop = 286
    ExplicitWidth = 427
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
    object DdeWatermarkPattern: TComboBoxEx
      Left = 129
      Top = 5
      Width = 267
      Height = 22
      ItemsEx = <>
      Style = csExDropDownList
      Anchors = [akLeft, akRight, akBottom]
      TabOrder = 1
      Images = ImlWatermarkPatterns
      ExplicitTop = 40
      ExplicitWidth = 290
    end
    object CbConvert: TCheckBox
      Left = 8
      Top = 35
      Width = 114
      Height = 17
      Anchors = [akLeft, akBottom]
      Caption = 'Convert:'
      TabOrder = 2
      OnClick = CbConvertClick
      ExplicitTop = 70
    end
    object DdConvert: TComboBox
      Left = 128
      Top = 34
      Width = 158
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akRight, akBottom]
      Enabled = False
      TabOrder = 3
      OnChange = DdConvertChange
      ExplicitTop = 69
      ExplicitWidth = 179
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
      TabOrder = 4
      OnClick = BtJPEGOptionsClick
      ExplicitLeft = 313
      ExplicitTop = 68
    end
    object DdRotate: TComboBox
      Left = 128
      Top = 61
      Width = 158
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akRight, akBottom]
      Enabled = False
      TabOrder = 5
      ExplicitTop = 96
      ExplicitWidth = 179
    end
    object CbRotate: TCheckBox
      Left = 8
      Top = 63
      Width = 114
      Height = 17
      Anchors = [akLeft, akBottom]
      Caption = 'Rotate:'
      TabOrder = 6
      OnClick = CbRotateClick
      ExplicitTop = 98
    end
    object CbResize: TCheckBox
      Left = 8
      Top = 91
      Width = 114
      Height = 17
      Anchors = [akLeft, akBottom]
      Caption = 'Resize:'
      TabOrder = 7
      OnClick = CbResizeClick
      ExplicitTop = 126
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
      TabOrder = 8
      OnChange = DdResizeActionChange
      ExplicitTop = 123
      ExplicitWidth = 179
    end
    object EdWidth: TEdit
      Left = 292
      Top = 88
      Width = 41
      Height = 21
      Anchors = [akRight, akBottom]
      Enabled = False
      TabOrder = 9
      Text = '1024'
      OnExit = EdWidthExit
      OnKeyPress = EdHeightKeyPress
      ExplicitLeft = 313
      ExplicitTop = 123
    end
    object EdHeight: TEdit
      Left = 357
      Top = 88
      Width = 41
      Height = 21
      Anchors = [akRight, akBottom]
      Enabled = False
      TabOrder = 10
      Text = '768'
      OnExit = EdWidthExit
      OnKeyPress = EdHeightKeyPress
      ExplicitLeft = 378
      ExplicitTop = 123
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
      TabOrder = 11
      ExplicitTop = 152
      ExplicitWidth = 291
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
      TabOrder = 12
      ExplicitTop = 170
      ExplicitWidth = 291
    end
    object EdSavePath: TEdit
      Left = 8
      Top = 157
      Width = 365
      Height = 21
      Anchors = [akLeft, akRight, akBottom]
      ReadOnly = True
      TabOrder = 13
      Text = 'C:\'
      ExplicitTop = 192
      ExplicitWidth = 386
    end
    object BtChangeDirectory: TButton
      Left = 379
      Top = 156
      Width = 19
      Height = 22
      Anchors = [akRight, akBottom]
      Caption = '...'
      TabOrder = 14
      OnClick = BtChangeDirectoryClick
      ExplicitLeft = 400
      ExplicitTop = 191
    end
  end
  object ImlWatermarkPatterns: TImageList
    Left = 8
    Top = 8
  end
end
