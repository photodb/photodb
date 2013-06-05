object FormLinkItemSelector: TFormLinkItemSelector
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'FormLinkItemSelector'
  ClientHeight = 192
  ClientWidth = 430
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'MyriadPro-Regular'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  DesignSize = (
    430
    192)
  PixelsPerInch = 96
  TextHeight = 18
  object PnMain: TPanel
    Left = 0
    Top = 10
    Width = 430
    Height = 157
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    DoubleBuffered = True
    FullRepaint = False
    ParentBackground = False
    ParentDoubleBuffered = False
    TabOrder = 0
    DesignSize = (
      430
      157)
    object BvActionSeparator: TBevel
      Left = 8
      Top = 126
      Width = 414
      Height = 2
      Anchors = [akLeft, akRight, akBottom]
    end
    object PnEditorPanel: TPanel
      Left = 8
      Top = 76
      Width = 169
      Height = 50
      BevelOuter = bvNone
      DoubleBuffered = True
      FullRepaint = False
      ParentBackground = False
      ParentDoubleBuffered = False
      TabOrder = 0
      DesignSize = (
        169
        50)
      object BvEditSeparator: TBevel
        Left = 0
        Top = 45
        Width = 165
        Height = 2
        Anchors = [akLeft, akTop, akRight]
      end
    end
  end
  object BtnClose: TButton
    Left = 242
    Top = 159
    Width = 79
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'BtnClose'
    TabOrder = 1
    OnClick = BtnCloseClick
  end
  object BtnSave: TButton
    Left = 327
    Top = 159
    Width = 95
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'BtnSave'
    TabOrder = 2
    OnClick = BtnSaveClick
  end
  object WlApplyChanges: TWebLink
    Tag = 2
    Left = 8
    Top = 166
    Width = 59
    Height = 18
    Cursor = crHandPoint
    Anchors = [akLeft, akBottom]
    Text = 'Apply'
    OnClick = WlApplyChangesClick
    ImageIndex = 0
    UseEnterColor = False
    EnterColor = clBlack
    EnterBould = False
    TopIconIncrement = 0
    UseSpecIconSize = True
    HightliteImage = False
    StretchImage = True
    CanClick = True
  end
  object WlCancelChanges: TWebLink
    Tag = 2
    Left = 73
    Top = 166
    Width = 64
    Height = 18
    Cursor = crHandPoint
    Anchors = [akLeft, akBottom]
    Text = 'Cancel'
    OnClick = WlCancelChangesClick
    ImageIndex = 0
    UseEnterColor = False
    EnterColor = clBlack
    EnterBould = False
    TopIconIncrement = 0
    UseSpecIconSize = True
    HightliteImage = False
    StretchImage = True
    CanClick = True
  end
  object WlRemove: TWebLink
    Tag = 2
    Left = 143
    Top = 166
    Width = 73
    Height = 18
    Cursor = crHandPoint
    Anchors = [akLeft, akBottom]
    Text = 'Remove'
    OnClick = WlRemoveClick
    ImageIndex = 0
    UseEnterColor = False
    EnterColor = clBlack
    EnterBould = False
    TopIconIncrement = 0
    UseSpecIconSize = True
    HightliteImage = False
    StretchImage = True
    CanClick = True
  end
  object PnTop: TPanel
    Left = 0
    Top = 0
    Width = 430
    Height = 10
    Align = alTop
    BevelOuter = bvNone
    FullRepaint = False
    ParentBackground = False
    TabOrder = 6
  end
  object AeMain: TApplicationEvents
    OnMessage = AeMainMessage
    Left = 8
    Top = 8
  end
  object TmrAnimation: TTimer
    Interval = 10
    OnTimer = TmrAnimationTimer
    Left = 64
    Top = 8
  end
end
