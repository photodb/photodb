object EditorFullScreenForm: TEditorFullScreenForm
  Left = 199
  Top = 235
  BorderStyle = bsNone
  Caption = 'EditorFullScreenForm'
  ClientHeight = 446
  ClientWidth = 688
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  PopupMenu = PmMain
  WindowState = wsMaximized
  OnClose = FormClose
  OnCreate = FormCreate
  OnDblClick = Close1Click
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object PmMain: TPopupActionBar
    Left = 120
    Top = 56
    object SelectBackGroundColor1: TMenuItem
      Caption = 'SelectBackGroundColor'
      OnClick = SelectBackGroundColor1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Close1: TMenuItem
      Caption = 'Close'
      OnClick = Close1Click
    end
  end
  object ColorDialog1: TColorDialog
    Options = [cdAnyColor]
    Left = 216
    Top = 64
  end
end
