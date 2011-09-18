object FormCreatePerson: TFormCreatePerson
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Person'
  ClientHeight = 322
  ClientWidth = 554
  Color = clBtnFace
  Constraints.MinHeight = 360
  Constraints.MinWidth = 570
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  DesignSize = (
    554
    322)
  PixelsPerInch = 96
  TextHeight = 13
  object PbPhoto: TPaintBox
    Left = 8
    Top = 8
    Width = 250
    Height = 300
    PopupMenu = PmImageOptions
    OnPaint = PbPhotoPaint
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
    Height = 302
    Anchors = [akLeft, akTop, akBottom]
    Shape = bsLeftLine
    ExplicitHeight = 300
  end
  object LbComments: TLabel
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
    Width = 274
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    OnKeyDown = WedNameKeyDown
    WatermarkText = 'Name of person'
  end
  object WmComments: TWatermarkedMemo
    Left = 272
    Top = 186
    Width = 274
    Height = 97
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
    WatermarkText = 'Comments'
  end
  object BtnOk: TButton
    Left = 471
    Top = 289
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnOk'
    TabOrder = 2
    OnClick = BtnOkClick
  end
  object BtnCancel: TButton
    Left = 390
    Top = 289
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnCancel'
    TabOrder = 3
    OnClick = BtnCancelClick
  end
  object WllGroups: TWebLinkList
    Left = 272
    Top = 119
    Width = 274
    Height = 42
    HorzScrollBar.Visible = False
    Anchors = [akLeft, akTop, akRight]
    BevelEdges = []
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    TabOrder = 4
    OnDblClick = WllGroupsDblClick
    VerticalIncrement = 5
    HorizontalIncrement = 5
    LineHeight = 0
    PaddingTop = 2
    PaddingLeft = 2
  end
  object DtpBirthDay: TDateTimePicker
    Left = 272
    Top = 73
    Width = 274
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Date = 40796.048069189810000000
    Time = 40796.048069189810000000
    TabOrder = 5
  end
  object LsExtracting: TLoadingSign
    Left = 272
    Top = 289
    Width = 25
    Height = 25
    Active = True
    FillPercent = 60
    SignColor = clBlack
    MaxTransparencity = 255
  end
  object LsAdding: TLoadingSign
    Left = 359
    Top = 289
    Width = 25
    Height = 25
    Visible = False
    Active = True
    FillPercent = 60
    SignColor = clBlack
    MaxTransparencity = 255
  end
  object PmImageOptions: TPopupMenu
    Left = 104
    Top = 48
    object Loadotherimage1: TMenuItem
      Caption = 'Load other image'
    end
  end
  object AeMain: TApplicationEvents
    OnMessage = AeMainMessage
    Left = 104
    Top = 144
  end
  object GroupsImageList: TImageList
    Left = 104
    Top = 96
  end
end
