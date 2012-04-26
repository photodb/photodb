object FormPicasaOAuth: TFormPicasaOAuth
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Picasa authorisation'
  ClientHeight = 434
  ClientWidth = 631
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object WbApplicationRequest: TWebBrowser
    Left = 0
    Top = 0
    Width = 631
    Height = 434
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 338
    ExplicitHeight = 594
    ControlData = {
      4C00000037410000DB2C00000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E12620A000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object TmrCheckCode: TTimer
    Interval = 100
    OnTimer = TmrCheckCodeTimer
    Left = 24
    Top = 8
  end
end
