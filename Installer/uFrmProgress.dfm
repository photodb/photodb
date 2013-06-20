object FrmProgress: TFrmProgress
  Left = 0
  Top = 0
  Caption = 'FrmProgress'
  ClientHeight = 131
  ClientWidth = 496
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object AeMain: TApplicationEvents
    OnMessage = AeMainMessage
    Left = 184
    Top = 64
  end
end
