object FormSizeResizer: TFormSizeResizer
  Left = 366
  Top = 205
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsToolWindow
  Caption = 'Change image(s) size'
  ClientHeight = 464
  ClientWidth = 426
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
    426
    464)
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 8
    Top = 8
    Width = 398
    Height = 49
    AutoSize = False
    Caption = 
      'You can resize you image(s) and convert they in other graphic fo' +
      'rmat, which you can select in combobox follow:'
    WordWrap = True
  end
  object LbSizeSeparator: TLabel
    Left = 362
    Top = 336
    Width = 7
    Height = 13
    Anchors = [akRight, akBottom]
    Caption = 'X'
    Enabled = False
    ExplicitLeft = 350
  end
  object DdConvert: TComboBox
    Left = 128
    Top = 279
    Width = 178
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akRight, akBottom]
    Enabled = False
    TabOrder = 0
    OnChange = DdConvertChange
  end
  object BtJPEGOptions: TButton
    Left = 312
    Top = 278
    Width = 106
    Height = 22
    Anchors = [akRight, akBottom]
    Caption = 'JPEG Optinons'
    DoubleBuffered = False
    Enabled = False
    ParentDoubleBuffered = False
    TabOrder = 1
    OnClick = BtJPEGOptionsClick
  end
  object BtOk: TButton
    Left = 343
    Top = 433
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    Enabled = False
    TabOrder = 2
    OnClick = BtOkClick
  end
  object BtCancel: TButton
    Left = 262
    Top = 433
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = BtCancelClick
  end
  object BtSaveAsDefault: TButton
    Left = 8
    Top = 433
    Width = 153
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Save settings as default'
    TabOrder = 4
    OnClick = BtSaveAsDefaultClick
  end
  object EdSavePath: TEdit
    Left = 8
    Top = 406
    Width = 385
    Height = 21
    Anchors = [akLeft, akRight, akBottom]
    ReadOnly = True
    TabOrder = 5
    Text = 'C:\'
  end
  object BtChangeDirectory: TButton
    Left = 399
    Top = 406
    Width = 19
    Height = 22
    Anchors = [akRight, akBottom]
    Caption = '...'
    TabOrder = 6
    OnClick = BtChangeDirectoryClick
  end
  object DdResizeAction: TComboBox
    Left = 128
    Top = 333
    Width = 178
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akRight, akBottom]
    DropDownCount = 20
    Enabled = False
    TabOrder = 7
    OnChange = DdResizeActionChange
  end
  object EdWidth: TEdit
    Left = 312
    Top = 333
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
    Left = 377
    Top = 333
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
    Top = 362
    Width = 290
    Height = 17
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'Preserve aspect ratio'
    Checked = True
    State = cbChecked
    TabOrder = 10
  end
  object CbConvert: TCheckBox
    Left = 8
    Top = 280
    Width = 114
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Convert:'
    TabOrder = 11
    OnClick = CbConvertClick
  end
  object CbAddSuffix: TCheckBox
    Left = 128
    Top = 383
    Width = 290
    Height = 17
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'Add filename suffix'
    Checked = True
    State = cbChecked
    TabOrder = 12
  end
  object CbResize: TCheckBox
    Left = 8
    Top = 336
    Width = 114
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Resize:'
    TabOrder = 13
    OnClick = CbResizeClick
  end
  object CbRotate: TCheckBox
    Left = 8
    Top = 308
    Width = 114
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Rotate:'
    TabOrder = 14
    OnClick = CbRotateClick
  end
  object DdRotate: TComboBox
    Left = 128
    Top = 306
    Width = 178
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akRight, akBottom]
    Enabled = False
    TabOrder = 15
  end
  object EdImageName: TEdit
    Left = 8
    Top = 221
    Width = 410
    Height = 21
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 16
    Text = 'Image Name'
  end
  object CbWatermark: TCheckBox
    Left = 8
    Top = 252
    Width = 114
    Height = 17
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'Add watermark'
    TabOrder = 17
    OnClick = CbWatermarkClick
  end
  object DdeWatermarkPattern: TComboBoxEx
    Left = 128
    Top = 251
    Width = 290
    Height = 22
    ItemsEx = <>
    Style = csExDropDownList
    TabOrder = 18
    Images = ImlWatermarkPatterns
  end
  object ImlWatermarkPatterns: TImageList
    Left = 352
    Top = 168
  end
end
