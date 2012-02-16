object FormImportPicturesSettings: TFormImportPicturesSettings
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'FormImportPicturesSettings'
  ClientHeight = 165
  ClientWidth = 420
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
    420
    165)
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
    Width = 393
    Height = 21
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 0
    Text = 'YYYY\MMM\YY.MM.DD = DDD, D MMMM, YYYY (LABEL)'
    Items.Strings = (
      'YYYY\MMM\YY.MM.DD = DDD, D MMMM, YYYY (LABEL)'
      'YYYY\YY.MM.DD (LABEL)'
      'YYYY.MM.DD (LABEL)')
  end
  object CbOnlyImages: TCheckBox
    Left = 8
    Top = 58
    Width = 406
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Import only supported images'
    TabOrder = 1
  end
  object CbDeleteAfterImport: TCheckBox
    Left = 8
    Top = 81
    Width = 406
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Delete files after import'
    TabOrder = 2
  end
  object CbAddToCollection: TCheckBox
    Left = 8
    Top = 104
    Width = 406
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Add files to collection after copying files'
    TabOrder = 3
  end
  object BtnOk: TButton
    Left = 337
    Top = 132
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnOk'
    TabOrder = 4
    OnClick = BtnOkClick
  end
  object BtnCancel: TButton
    Left = 256
    Top = 132
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Button1'
    TabOrder = 5
    OnClick = BtnCancelClick
  end
end
