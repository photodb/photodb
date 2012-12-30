object FormImportPicturesSettings: TFormImportPicturesSettings
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'FormImportPicturesSettings'
  ClientHeight = 183
  ClientWidth = 429
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  DesignSize = (
    429
    183)
  PixelsPerInch = 96
  TextHeight = 13
  object LbDirectoryFormat: TLabel
    Left = 8
    Top = 8
    Width = 83
    Height = 13
    Caption = 'Directory format:'
  end
  object CbFormatCombo: TComboBox
    Left = 8
    Top = 27
    Width = 384
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemIndex = 0
    TabOrder = 0
    Text = 'YYYY\MMM\YY.MM.DD = DDD, D MMMM, YYYY (LABEL)'
    Items.Strings = (
      'YYYY\MMM\YY.MM.DD = DDD, D MMMM, YYYY (LABEL)'
      'YYYY\YY.MM.DD = DDD, D MMMM, YYYY (LABEL)'
      'YYYY\YY.MM.DD (LABEL)'
      'YYYY.MM.DD (LABEL)')
  end
  object CbOnlyImages: TCheckBox
    Left = 8
    Top = 58
    Width = 161
    Height = 17
    Caption = 'Import only supported images'
    TabOrder = 1
  end
  object CbDeleteAfterImport: TCheckBox
    Left = 8
    Top = 81
    Width = 415
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Delete files after import'
    TabOrder = 2
  end
  object CbAddToCollection: TCheckBox
    Left = 8
    Top = 104
    Width = 415
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Add files to collection after copying files'
    TabOrder = 3
  end
  object BtnOk: TButton
    Left = 346
    Top = 150
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnOk'
    TabOrder = 4
    OnClick = BtnOkClick
  end
  object BtnCancel: TButton
    Left = 265
    Top = 150
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnCancel'
    TabOrder = 5
    OnClick = BtnCancelClick
  end
  object WlFilter: TWebLink
    Left = 175
    Top = 61
    Width = 53
    Height = 13
    Cursor = crHandPoint
    Text = '(filter: *.*)'
    Visible = False
    ImageIndex = 0
    IconWidth = 0
    IconHeight = 0
    UseEnterColor = False
    EnterColor = clBlack
    EnterBould = False
    TopIconIncrement = 0
    UseSpecIconSize = True
    HightliteImage = False
    StretchImage = True
    CanClick = True
  end
  object BtnChangePatterns: TButton
    Left = 398
    Top = 27
    Width = 23
    Height = 23
    Anchors = [akTop, akRight]
    Caption = '...'
    TabOrder = 7
    OnClick = BtnChangePatternsClick
  end
  object CbOpenDestination: TCheckBox
    Left = 8
    Top = 127
    Width = 415
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Open destination directory after import'
    TabOrder = 8
  end
end
