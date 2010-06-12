object FormFastFileRenamer: TFormFastFileRenamer
  Left = 201
  Top = 125
  Width = 393
  Height = 389
  Caption = 'FormFastFileRenamer'
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
  object ValueListEditor1: TValueListEditor
    Left = 0
    Top = 73
    Width = 377
    Height = 249
    Align = alClient
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goAlwaysShowEditor, goThumbTracking]
    PopupMenu = PopupMenu1
    Strings.Strings = (
      '=')
    TabOrder = 0
    TitleCaptions.Strings = (
      'Original File Name'
      'New File Name')
    ColWidths = (
      188
      183)
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 377
    Height = 73
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 8
      Width = 29
      Height = 13
      Caption = 'Mask:'
    end
    object Label2: TLabel
      Left = 240
      Top = 8
      Width = 37
      Height = 13
      Caption = 'Begin #'
    end
    object Button3: TButton
      Left = 302
      Top = 24
      Width = 75
      Height = 22
      Caption = '???'
      TabOrder = 0
      OnClick = Button3Click
    end
    object Edit2: TEdit
      Left = 240
      Top = 24
      Width = 57
      Height = 21
      TabOrder = 1
      Text = '1'
      OnChange = Edit1Change
    end
    object ComboBox1: TComboBox
      Left = 8
      Top = 24
      Width = 225
      Height = 21
      ItemHeight = 13
      TabOrder = 2
      OnChange = Edit1Change
    end
    object Button4: TButton
      Left = 9
      Top = 51
      Width = 80
      Height = 17
      Caption = 'Add'
      TabOrder = 3
      OnClick = Button4Click
    end
    object Button5: TButton
      Left = 95
      Top = 51
      Width = 82
      Height = 17
      Caption = 'Delete'
      TabOrder = 4
      OnClick = Button5Click
    end
    object WebLinkWarning: TWebLink
      Tag = -1
      Left = 189
      Top = 52
      Width = 110
      Height = 16
      Cursor = crHandPoint
      Text = 'Conflict of FileNames! '
      OnClick = WebLinkWarningClick
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      BkColor = clRed
      ImageIndex = 0
      IconWidth = 0
      IconHeight = 16
      UseEnterColor = False
      EnterColor = clBlack
      EnterBould = False
      TopIconIncrement = 0
      ImageCanRegenerate = False
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 322
    Width = 377
    Height = 31
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object Panel3: TPanel
      Left = 212
      Top = 0
      Width = 165
      Height = 31
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object Button1: TButton
        Left = 86
        Top = 3
        Width = 75
        Height = 25
        Caption = 'Ok'
        TabOrder = 0
        OnClick = Button1Click
      end
      object Button2: TButton
        Left = 4
        Top = 3
        Width = 75
        Height = 25
        Caption = 'Cancel'
        TabOrder = 1
        OnClick = Button2Click
      end
    end
    object CheckBox1: TCheckBox
      Left = 8
      Top = 8
      Width = 209
      Height = 17
      Caption = 'Change EXT'
      TabOrder = 1
      OnClick = Edit1Change
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 72
    Top = 104
    object SortbyFileName1: TMenuItem
      Caption = 'Sort by File Name'
      OnClick = SortbyFileName1Click
    end
    object SortbyFileSize1: TMenuItem
      Caption = 'Sort by File Size'
      OnClick = SortbyFileSize1Click
    end
    object SortbyFileNumber1: TMenuItem
      Caption = 'Sort by File Number'
      OnClick = SortbyFileNumber1Click
    end
    object SortbyModified1: TMenuItem
      Caption = 'Sort by Modified'
      OnClick = SortbyModified1Click
    end
    object SortbyFileType1: TMenuItem
      Caption = 'Sort by File Type'
      OnClick = SortbyFileType1Click
    end
  end
end
