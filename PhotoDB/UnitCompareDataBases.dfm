object ImportDataBaseForm: TImportDataBaseForm
  Left = 238
  Top = 152
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsToolWindow
  Caption = 'Importing options'
  ClientHeight = 324
  ClientWidth = 428
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    428
    324)
  PixelsPerInch = 96
  TextHeight = 13
  object LbDatabase: TLabel
    Left = 8
    Top = 8
    Width = 96
    Height = 13
    Caption = 'Additianal Database'
  end
  object Label5: TLabel
    Left = 248
    Top = 51
    Width = 98
    Height = 13
    Caption = 'List of ignore words:'
  end
  object Label4: TLabel
    Left = 248
    Top = 8
    Width = 48
    Height = 13
    Caption = 'By Author'
  end
  object EdDatabase: TWatermarkedEdit
    Left = 8
    Top = 24
    Width = 225
    Height = 21
    ReadOnly = True
    TabOrder = 0
    WatermarkText = 'Please, choose collection'
  end
  object Button2: TButton
    Left = 225
    Top = 24
    Width = 17
    Height = 21
    Caption = '...'
    TabOrder = 1
    OnClick = Button2Click
  end
  object ClbOptions: TCheckListBox
    Tag = 1
    Left = 8
    Top = 48
    Width = 234
    Height = 225
    Color = clBtnFace
    ItemHeight = 13
    Items.Strings = (
      'Add New Records'
      'Add Records Without Files'
      'Add Rating'
      'Add Rotate'
      'Add Private'
      'Add KeyWords'
      'Add Groups'
      'Add Nil Comments'
      'Add Comments'
      'Add Named Comments'
      'Add Date'
      'Add Links'
      'Ignore Words')
    TabOrder = 2
  end
  object GroupBox1: TGroupBox
    Left = 248
    Top = 155
    Width = 175
    Height = 121
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Replace'
    TabOrder = 3
    DesignSize = (
      175
      121)
    object Label9: TLabel
      Left = 72
      Top = 24
      Width = 33
      Height = 13
      Alignment = taCenter
      AutoSize = False
      Caption = 'On'
    end
    object Label10: TLabel
      Left = 72
      Top = 48
      Width = 33
      Height = 13
      Alignment = taCenter
      AutoSize = False
      Caption = 'On'
    end
    object Label11: TLabel
      Left = 72
      Top = 72
      Width = 33
      Height = 13
      Alignment = taCenter
      AutoSize = False
      Caption = 'On'
    end
    object Label12: TLabel
      Left = 72
      Top = 96
      Width = 33
      Height = 13
      Alignment = taCenter
      AutoSize = False
      Caption = 'On'
    end
    object Edit5: TEdit
      Left = 8
      Top = 16
      Width = 65
      Height = 21
      TabOrder = 0
      Text = '-'
    end
    object Edit6: TEdit
      Left = 104
      Top = 16
      Width = 63
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
      Text = '-'
    end
    object Edit7: TEdit
      Left = 104
      Top = 40
      Width = 63
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
      Text = '-'
    end
    object Edit8: TEdit
      Left = 8
      Top = 40
      Width = 65
      Height = 21
      TabOrder = 3
      Text = '-'
    end
    object Edit9: TEdit
      Left = 104
      Top = 64
      Width = 63
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 4
      Text = '-'
    end
    object Edit10: TEdit
      Left = 8
      Top = 64
      Width = 65
      Height = 21
      TabOrder = 5
      Text = '-'
    end
    object Edit11: TEdit
      Left = 104
      Top = 88
      Width = 63
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 6
      Text = '-'
    end
    object Edit12: TEdit
      Left = 8
      Top = 88
      Width = 65
      Height = 21
      TabOrder = 7
      Text = '-'
    end
  end
  object BtnOk: TButton
    Left = 333
    Top = 299
    Width = 89
    Height = 22
    Anchors = [akTop, akRight]
    Caption = 'Ok'
    TabOrder = 4
    OnClick = BtnOkClick
  end
  object BtnCancel: TButton
    Left = 238
    Top = 299
    Width = 89
    Height = 22
    Anchors = [akTop, akRight]
    Caption = 'Cancel'
    TabOrder = 5
    OnClick = BtnCancelClick
  end
  object MemIgnoreKeywords: TMemo
    Left = 248
    Top = 70
    Width = 175
    Height = 83
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 6
  end
  object EdAuthor: TEdit
    Left = 248
    Top = 24
    Width = 175
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 7
    Text = 'Autor'
  end
  object CbScanByName: TCheckBox
    Left = 8
    Top = 279
    Width = 415
    Height = 16
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Use Scaning By Filename'
    TabOrder = 8
  end
  object OpenDialog1: TOpenDialog
    Filter = 'DataBase Files (*.db)|*.db'
    Left = 200
    Top = 56
  end
end
