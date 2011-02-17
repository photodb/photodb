object ImportDataBaseForm: TImportDataBaseForm
  Left = 238
  Top = 152
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsToolWindow
  Caption = 'Importing options'
  ClientHeight = 318
  ClientWidth = 358
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label3: TLabel
    Left = 8
    Top = 8
    Width = 95
    Height = 13
    Caption = 'Additianal Database'
  end
  object Label5: TLabel
    Left = 168
    Top = 48
    Width = 94
    Height = 13
    Caption = 'List of ignore words:'
  end
  object Label4: TLabel
    Left = 168
    Top = 8
    Width = 46
    Height = 13
    Caption = 'By Author'
  end
  object Edit2: TEdit
    Left = 8
    Top = 24
    Width = 137
    Height = 21
    ReadOnly = True
    TabOrder = 0
    Text = '<no database>'
  end
  object Button2: TButton
    Left = 144
    Top = 24
    Width = 17
    Height = 21
    Caption = '...'
    TabOrder = 1
    OnClick = Button2Click
  end
  object CheckListBox1: TCheckListBox
    Tag = 1
    Left = 8
    Top = 48
    Width = 153
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
    Left = 168
    Top = 155
    Width = 185
    Height = 121
    Caption = 'Replace'
    TabOrder = 3
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
      Width = 73
      Height = 21
      TabOrder = 1
      Text = '-'
    end
    object Edit7: TEdit
      Left = 104
      Top = 40
      Width = 73
      Height = 21
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
      Width = 73
      Height = 21
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
      Width = 73
      Height = 21
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
  object Button4: TButton
    Left = 264
    Top = 298
    Width = 89
    Height = 17
    Caption = 'Ok'
    TabOrder = 4
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 168
    Top = 298
    Width = 89
    Height = 17
    Caption = 'Cancel'
    TabOrder = 5
    OnClick = Button5Click
  end
  object Memo1: TMemo
    Left = 168
    Top = 64
    Width = 185
    Height = 89
    TabOrder = 6
  end
  object Edit4: TEdit
    Left = 168
    Top = 24
    Width = 185
    Height = 21
    TabOrder = 7
    Text = 'Autor'
  end
  object CheckBox1: TCheckBox
    Left = 8
    Top = 280
    Width = 345
    Height = 16
    Caption = 'Use Scaning By Filename'
    Checked = True
    State = cbChecked
    TabOrder = 8
  end
  object OpenDialog1: TOpenDialog
    Filter = 'DataBase Files (*.db)|*.db'
    Left = 256
  end
  object DestroyTimer: TTimer
    Enabled = False
    Interval = 10
    OnTimer = DestroyTimerTimer
    Left = 288
  end
end
