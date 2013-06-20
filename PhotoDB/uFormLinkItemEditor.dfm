object FormLinkItemEditor: TFormLinkItemEditor
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'FormLinkItemEditor'
  ClientHeight = 192
  ClientWidth = 430
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  DesignSize = (
    430
    192)
  PixelsPerInch = 96
  TextHeight = 18
  object PnEditorPanel: TPanel
    Left = 8
    Top = 76
    Width = 169
    Height = 50
    BevelOuter = bvNone
    DoubleBuffered = False
    FullRepaint = False
    ParentBackground = False
    ParentDoubleBuffered = False
    TabOrder = 0
  end
  object BtnSave: TButton
    Left = 327
    Top = 158
    Width = 95
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'BtnSave'
    TabOrder = 1
    OnClick = BtnSaveClick
  end
  object BtnClose: TButton
    Left = 242
    Top = 158
    Width = 79
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'BtnClose'
    TabOrder = 2
    OnClick = BtnCloseClick
  end
end
