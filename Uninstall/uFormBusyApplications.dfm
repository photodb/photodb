object FormBusyApplications: TFormBusyApplications
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'FormBusyApplications'
  ClientHeight = 298
  ClientWidth = 428
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  DesignSize = (
    428
    298)
  PixelsPerInch = 96
  TextHeight = 13
  object LbInfo: TLabel
    Left = 8
    Top = 8
    Width = 412
    Height = 57
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'LbInfo'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    WordWrap = True
    ExplicitWidth = 402
  end
  object LstApplications: TListBox
    Left = 8
    Top = 68
    Width = 412
    Height = 191
    Style = lbOwnerDrawFixed
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = []
    ItemHeight = 36
    ParentFont = False
    TabOrder = 0
    OnDrawItem = LstApplicationsDrawItem
    ExplicitWidth = 402
    ExplicitHeight = 181
  end
  object BtnCancel: TButton
    Left = 264
    Top = 265
    Width = 75
    Height = 25
    Caption = 'BtnCancel'
    ModalResult = 2
    TabOrder = 1
    OnClick = BtnCancelClick
  end
  object BtnRetry: TButton
    Left = 345
    Top = 265
    Width = 75
    Height = 25
    Caption = 'BtnRetry'
    ModalResult = 4
    TabOrder = 2
    OnClick = BtnRetryClick
  end
  object ImApplications: TImageList
    ColorDepth = cd32Bit
    Height = 32
    Width = 32
    Left = 32
    Top = 80
  end
end
