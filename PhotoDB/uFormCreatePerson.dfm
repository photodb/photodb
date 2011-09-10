object TFormCreatePerson: TTFormCreatePerson
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Person'
  ClientHeight = 320
  ClientWidth = 556
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    556
    320)
  PixelsPerInch = 96
  TextHeight = 13
  object PbPhoto: TPaintBox
    Left = 8
    Top = 8
    Width = 250
    Height = 300
  end
  object LbName: TLabel
    Left = 272
    Top = 8
    Width = 31
    Height = 13
    Caption = 'Name:'
  end
  object BvSeparator: TBevel
    Left = 264
    Top = 8
    Width = 2
    Height = 300
    Anchors = [akLeft, akTop, akBottom]
    Shape = bsLeftLine
  end
  object Label1: TLabel
    Left = 272
    Top = 167
    Width = 54
    Height = 13
    Caption = 'Comments:'
  end
  object LbGroups: TLabel
    Tag = 2
    Left = 272
    Top = 100
    Width = 78
    Height = 13
    Caption = 'Related Groups:'
  end
  object LbBirthDate: TLabel
    Left = 272
    Top = 54
    Width = 60
    Height = 13
    Caption = 'LbBirthDate:'
  end
  object WedName: TWatermarkedEdit
    Left = 272
    Top = 27
    Width = 276
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    WatermarkText = 'Name of person'
  end
  object WmComments: TWatermarkedMemo
    Left = 272
    Top = 186
    Width = 276
    Height = 95
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
    WatermarkText = 'Comments'
  end
  object BtnOk: TButton
    Left = 473
    Top = 287
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnOk'
    TabOrder = 2
  end
  object BtnCancel: TButton
    Left = 392
    Top = 287
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnCancel'
    TabOrder = 3
  end
  object WllGroups: TWebLinkList
    Left = 272
    Top = 119
    Width = 276
    Height = 42
    HorzScrollBar.Visible = False
    Anchors = [akLeft, akTop, akRight]
    BevelEdges = []
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    TabOrder = 4
    VerticalIncrement = 5
    HorizontalIncrement = 5
    LineHeight = 0
    PaddingTop = 2
    PaddingLeft = 2
  end
  object DateTimePicker1: TDateTimePicker
    Left = 272
    Top = 73
    Width = 276
    Height = 21
    Date = 40796.048069189810000000
    Time = 40796.048069189810000000
    TabOrder = 5
  end
end
