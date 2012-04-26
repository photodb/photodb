object SavingTableForm: TSavingTableForm
  Left = 192
  Top = 140
  BorderStyle = bsToolWindow
  Caption = 'SavingTableForm'
  ClientHeight = 69
  ClientWidth = 280
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 5
    Width = 89
    Height = 13
    Caption = 'Saving progress...'
  end
  object DmProgress1: TDmProgress
    Left = 8
    Top = 21
    Width = 265
    Height = 18
    MaxValue = 100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 16711808
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Text = 'Progress... (&%%)'
    BorderColor = 38400
    CoolColor = 38400
    Color = clBlack
    View = dm_pr_cool
    Inverse = False
  end
  object BtnAbort: TButton
    Left = 192
    Top = 48
    Width = 83
    Height = 17
    Caption = 'Abort'
    TabOrder = 1
    OnClick = BtnAbortClick
  end
end
