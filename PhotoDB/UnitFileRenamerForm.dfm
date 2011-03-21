object FormFastFileRenamer: TFormFastFileRenamer
  Left = 201
  Top = 125
  Caption = 'FormFastFileRenamer'
  ClientHeight = 441
  ClientWidth = 424
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ValueListEditor1: TValueListEditor
    Left = 0
    Top = 73
    Width = 424
    Height = 337
    Align = alClient
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goRowSelect, goThumbTracking]
    PopupMenu = pmSort
    Strings.Strings = (
      '=')
    TabOrder = 0
    TitleCaptions.Strings = (
      'Original File Name'
      'New File Name')
    ExplicitWidth = 309
    ExplicitHeight = 247
    ColWidths = (
      188
      230)
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 424
    Height = 73
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = -6
    DesignSize = (
      424
      73)
    object LblTitle: TLabel
      Left = 8
      Top = 8
      Width = 29
      Height = 13
      Caption = 'Mask:'
    end
    object Label2: TLabel
      Left = 279
      Top = 8
      Width = 37
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'Begin #'
      ExplicitLeft = 240
    end
    object BtnHelp: TButton
      Left = 341
      Top = 24
      Width = 75
      Height = 22
      Anchors = [akTop, akRight]
      Caption = '???'
      TabOrder = 2
      OnClick = BtnHelpClick
      ExplicitLeft = 226
    end
    object CmMaskList: TComboBox
      Left = 8
      Top = 24
      Width = 264
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      OnChange = Edit1Change
      ExplicitWidth = 149
    end
    object BtAdd: TButton
      Left = 9
      Top = 51
      Width = 80
      Height = 17
      Caption = 'Add'
      TabOrder = 3
      OnClick = BtAddClick
    end
    object BtDelete: TButton
      Left = 95
      Top = 51
      Width = 82
      Height = 17
      Caption = 'Delete'
      TabOrder = 4
      OnClick = BtDeleteClick
    end
    object WebLinkWarning: TWebLink
      Tag = -1
      Left = 189
      Top = 52
      Width = 110
      Height = 16
      Cursor = crHandPoint
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      Color = clRed
      ParentColor = False
      Text = 'Conflict of FileNames! '
      OnClick = WebLinkWarningClick
      ImageIndex = 0
      IconWidth = 0
      IconHeight = 16
      UseEnterColor = False
      EnterColor = clBlack
      EnterBould = False
      TopIconIncrement = 0
      ImageCanRegenerate = True
      UseSpecIconSize = True
    end
    object SedStartN: TSpinEdit
      Left = 278
      Top = 24
      Width = 57
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 1
      Value = 0
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 410
    Width = 424
    Height = 31
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    ExplicitTop = 320
    ExplicitWidth = 309
    DesignSize = (
      424
      31)
    object Panel3: TPanel
      Left = 259
      Top = 0
      Width = 165
      Height = 31
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 1
      ExplicitLeft = 144
      object BtnOK: TButton
        Left = 86
        Top = 3
        Width = 75
        Height = 25
        Caption = 'Ok'
        TabOrder = 0
        OnClick = BtnOKClick
      end
      object BtnCancel: TButton
        Left = 4
        Top = 3
        Width = 75
        Height = 25
        Caption = 'Cancel'
        TabOrder = 1
        OnClick = BtnCancelClick
      end
    end
    object CheckBox1: TCheckBox
      Left = 8
      Top = 8
      Width = 248
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Change EXT'
      Constraints.MinWidth = 130
      TabOrder = 0
      OnClick = Edit1Change
      ExplicitWidth = 133
    end
  end
  object pmSort: TPopupMenu
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
