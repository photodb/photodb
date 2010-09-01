object FormDBOptions: TFormDBOptions
  Left = 213
  Top = 252
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'FormDBOptions'
  ClientHeight = 336
  ClientWidth = 534
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 49
    Height = 13
    Caption = 'DB Name:'
  end
  object Label2: TLabel
    Left = 8
    Top = 56
    Width = 71
    Height = 13
    Caption = 'DB Description'
  end
  object Label3: TLabel
    Left = 8
    Top = 152
    Width = 98
    Height = 13
    Caption = 'ThSizePanelPreview'
  end
  object Label4: TLabel
    Left = 8
    Top = 200
    Width = 52
    Height = 13
    Caption = 'ThHintSize'
  end
  object Label5: TLabel
    Left = 8
    Top = 248
    Width = 88
    Height = 13
    Caption = 'DB Thumbnail size'
  end
  object Label6: TLabel
    Left = 184
    Top = 248
    Width = 111
    Height = 13
    Caption = 'Jpeg Thumbnail quality:'
  end
  object Label7: TLabel
    Left = 8
    Top = 104
    Width = 22
    Height = 13
    Caption = 'Path'
  end
  object Edit1: TEdit
    Left = 8
    Top = 24
    Width = 521
    Height = 21
    TabOrder = 0
  end
  object Edit2: TEdit
    Left = 8
    Top = 72
    Width = 521
    Height = 21
    TabOrder = 1
  end
  object ComboBox1: TComboBox
    Left = 8
    Top = 168
    Width = 145
    Height = 21
    ItemIndex = 2
    TabOrder = 2
    Text = '75'
    Items.Strings = (
      '30'
      '50'
      '75'
      '100'
      '150'
      '200'
      '300')
  end
  object Button1: TButton
    Left = 456
    Top = 304
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 3
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 376
    Top = 304
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 4
    OnClick = Button2Click
  end
  object ComboBox2: TComboBox
    Left = 8
    Top = 216
    Width = 145
    Height = 21
    ItemIndex = 3
    TabOrder = 5
    Text = '400'
    Items.Strings = (
      '100'
      '200'
      '300'
      '400'
      '500')
  end
  object Edit3: TEdit
    Left = 8
    Top = 264
    Width = 145
    Height = 21
    ReadOnly = True
    TabOrder = 6
  end
  object Edit4: TEdit
    Left = 184
    Top = 264
    Width = 145
    Height = 21
    ReadOnly = True
    TabOrder = 7
  end
  object WebLink1: TWebLink
    Left = 8
    Top = 288
    Width = 246
    Height = 13
    Cursor = crHandPoint
    Text = 'To change thumbnail size and quality press this link'
    OnClick = WebLink1Click
    BkColor = clBtnFace
    ImageIndex = 0
    IconWidth = 0
    IconHeight = 0
    UseEnterColor = False
    EnterColor = clBlack
    EnterBould = False
    TopIconIncrement = 0
    ImageCanRegenerate = False
    UseSpecIconSize = True
  end
  object Edit5: TEdit
    Left = 8
    Top = 120
    Width = 521
    Height = 21
    ReadOnly = True
    TabOrder = 9
  end
  object Button3: TButton
    Left = 312
    Top = 144
    Width = 217
    Height = 25
    Caption = 'Open file location'
    TabOrder = 10
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 312
    Top = 146
    Width = 217
    Height = 25
    Caption = 'Change file location'
    TabOrder = 11
    OnClick = Button4Click
  end
  object GroupBoxIcon: TGroupBox
    Left = 344
    Top = 184
    Width = 185
    Height = 105
    Caption = 'Icon options'
    TabOrder = 12
    Visible = False
    object ImageIconPreview: TImage
      Left = 8
      Top = 40
      Width = 16
      Height = 16
      OnClick = Button5Click
    end
    object Label8: TLabel
      Left = 8
      Top = 24
      Width = 64
      Height = 13
      Caption = 'Icon preview:'
    end
    object Button5: TButton
      Left = 8
      Top = 72
      Width = 169
      Height = 25
      Caption = 'Change icon'
      TabOrder = 0
      OnClick = Button5Click
    end
  end
end
