object FormImportSource: TFormImportSource
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'FormImportSource'
  ClientHeight = 165
  ClientWidth = 526
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object LbLoadingMessage: TLabel
    Left = 416
    Top = 56
    Width = 99
    Height = 101
    Alignment = taCenter
    AutoSize = False
    Caption = 'Please wait until program searches for sources with images'
    EllipsisPosition = epWordEllipsis
    WordWrap = True
  end
  object LsLoading: TLoadingSign
    Left = 448
    Top = 16
    Width = 34
    Height = 34
    Active = True
    FillPercent = 70
    SignColor = clBlack
    MaxTransparencity = 255
  end
end
