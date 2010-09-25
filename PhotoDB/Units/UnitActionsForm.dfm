object ActionsForm: TActionsForm
  Left = 241
  Top = 135
  BorderStyle = bsSizeToolWin
  Caption = 'Actions Form'
  ClientHeight = 229
  ClientWidth = 281
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object ActionList: TListBox
    Left = 0
    Top = 65
    Width = 281
    Height = 164
    Style = lbOwnerDrawFixed
    Align = alClient
    ItemHeight = 22
    TabOrder = 0
    OnDrawItem = ActionListDrawItem
  end
  object TopPanel: TPanel
    Left = 0
    Top = 0
    Width = 281
    Height = 65
    Align = alTop
    TabOrder = 1
    object SaveToFileLink: TWebLink
      Left = 8
      Top = 8
      Width = 81
      Height = 16
      Cursor = crHandPoint
      ParentColor = False
      Color = clWhite
      Text = 'Save To File'
      OnClick = SaveToFileLinkClick
      ImageIndex = 0
      IconWidth = 16
      IconHeight = 16
      UseEnterColor = False
      EnterColor = clBlack
      EnterBould = False
      TopIconIncrement = 0
      ImageCanRegenerate = False
      UseSpecIconSize = True
    end
    object LoadFromFileLink: TWebLink
      Left = 8
      Top = 24
      Width = 90
      Height = 16
      Cursor = crHandPoint
      ParentColor = False
      Color = clWhite
      Text = 'Load From File'
      OnClick = LoadFromFileLinkClick
      ImageIndex = 0
      IconWidth = 16
      IconHeight = 16
      UseEnterColor = False
      EnterColor = clBlack
      EnterBould = False
      TopIconIncrement = 0
      ImageCanRegenerate = False
      UseSpecIconSize = True
    end
    object CloseLink: TWebLink
      Left = 8
      Top = 40
      Width = 47
      Height = 16
      Cursor = crHandPoint
      ParentColor = False
      Color = clWhite
      Text = 'Close'
      OnClick = CloseLinkClick
      ImageIndex = 0
      IconWidth = 16
      IconHeight = 16
      UseEnterColor = False
      EnterColor = clBlack
      EnterBould = False
      TopIconIncrement = 0
      ImageCanRegenerate = False
      UseSpecIconSize = True
    end
  end
  object ActionsImageList: TImageList
    Left = 120
    Top = 16
  end
  object OpenDialog1: TOpenDialog
    Filter = 'PhotoDB Actions (*.dbact)|*.dbact'
    Left = 128
    Top = 152
  end
end
