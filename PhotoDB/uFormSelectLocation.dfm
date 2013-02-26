object FormSelectLocation: TFormSelectLocation
  Left = 0
  Top = 0
  Caption = 'FormSelectLocation'
  ClientHeight = 540
  ClientWidth = 508
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
  OnDestroy = FormDestroy
  DesignSize = (
    508
    540)
  PixelsPerInch = 96
  TextHeight = 13
  object PePath: TPathEditor
    Left = 0
    Top = 476
    Width = 508
    Height = 25
    Align = alTop
    OnChange = PePathChange
    LoadingText = 'Loading...'
    CanBreakLoading = False
    OnlyFileSystem = False
    HideExtendedButton = True
    ShowBorder = False
  end
  object PnExplorer: TPanel
    Left = 0
    Top = 0
    Width = 508
    Height = 476
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 1
  end
  object BtnCancel: TButton
    Left = 345
    Top = 507
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnCancel'
    TabOrder = 2
    OnClick = BtnCancelClick
  end
  object BtnOk: TButton
    Left = 426
    Top = 507
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnOk'
    TabOrder = 3
    OnClick = BtnOkClick
  end
end
