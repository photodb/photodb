object FormPersonSuggest: TFormPersonSuggest
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'FormPersonSuggest'
  ClientHeight = 117
  ClientWidth = 226
  Color = clWindow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDeactivate = FormDeactivate
  OnPaint = FormPaint
  DesignSize = (
    226
    117)
  PixelsPerInch = 96
  TextHeight = 13
  object LbInfo: TLabel
    Left = 2
    Top = 2
    Width = 98
    Height = 13
    Caption = 'Select other person:'
  end
  object BvSeparator: TBevel
    Left = 8
    Top = 108
    Width = 210
    Height = 1
    Anchors = [akLeft, akTop, akRight]
    Shape = bsTopLine
  end
end
