object FormSizeResizer: TFormSizeResizer
  Left = 320
  Top = 110
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsToolWindow
  Caption = 'Change image(s) size'
  ClientHeight = 464
  ClientWidth = 334
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
    334
    464)
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 8
    Top = 8
    Width = 318
    Height = 41
    AutoSize = False
    Caption = 
      'You can resize you image(s) and convert they in other graphic fo' +
      'rmat, which you can select in combobox follow:'
    WordWrap = True
  end
  object Label4: TLabel
    Left = 271
    Top = 336
    Width = 7
    Height = 13
    Anchors = [akRight, akBottom]
    Caption = 'X'
    ExplicitLeft = 290
  end
  object DdConvert: TComboBox
    Left = 88
    Top = 279
    Width = 135
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 0
    ExplicitWidth = 154
  end
  object BtJPEGOptions: TButton
    Left = 229
    Top = 278
    Width = 97
    Height = 22
    Anchors = [akRight, akBottom]
    Caption = 'JPEG Optinons'
    TabOrder = 1
    OnClick = BtJPEGOptionsClick
    ExplicitLeft = 248
  end
  object BtOk: TButton
    Left = 251
    Top = 433
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    TabOrder = 2
    OnClick = BtOkClick
    ExplicitLeft = 270
  end
  object BtCancel: TButton
    Left = 170
    Top = 433
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = BtCancelClick
    ExplicitLeft = 189
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
    Width = 293
    Height = 21
    Anchors = [akLeft, akRight, akBottom]
    Enabled = False
    ReadOnly = True
    TabOrder = 5
    Text = 'C:\'
    ExplicitWidth = 312
  end
  object BtChangeDirectory: TButton
    Left = 307
    Top = 406
    Width = 19
    Height = 22
    Anchors = [akRight, akBottom]
    Caption = '...'
    Enabled = False
    TabOrder = 6
    OnClick = BtChangeDirectoryClick
    ExplicitLeft = 326
  end
  object DdResizeAction: TComboBox
    Left = 88
    Top = 333
    Width = 126
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 7
    ExplicitWidth = 145
  end
  object EdWidth: TEdit
    Left = 224
    Top = 333
    Width = 41
    Height = 21
    Anchors = [akRight, akBottom]
    TabOrder = 8
    Text = '1024'
    OnExit = EdWidthExit
    OnKeyPress = EdHeightKeyPress
    ExplicitLeft = 243
  end
  object EdHeight: TEdit
    Left = 284
    Top = 333
    Width = 41
    Height = 21
    Anchors = [akRight, akBottom]
    TabOrder = 9
    Text = '768'
    OnExit = EdWidthExit
    OnKeyPress = EdHeightKeyPress
    ExplicitLeft = 303
  end
  object CbAspectRatio: TCheckBox
    Left = 88
    Top = 360
    Width = 237
    Height = 17
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'Preserve aspect ratio'
    Checked = True
    State = cbChecked
    TabOrder = 10
    ExplicitWidth = 256
  end
  object CbConvert: TCheckBox
    Left = 8
    Top = 280
    Width = 64
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Convert:'
    TabOrder = 11
  end
  object CbAddSuffix: TCheckBox
    Left = 88
    Top = 380
    Width = 238
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
    Width = 64
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Resize:'
    TabOrder = 13
  end
  object CbRotate: TCheckBox
    Left = 8
    Top = 308
    Width = 64
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Rotate:'
    TabOrder = 14
  end
  object DdRotate: TComboBox
    Left = 88
    Top = 306
    Width = 135
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 15
    ExplicitWidth = 154
  end
  object EdImageName: TEdit
    Left = 8
    Top = 251
    Width = 316
    Height = 21
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 16
    Text = 'EdImageName'
    ExplicitWidth = 336
  end
end
