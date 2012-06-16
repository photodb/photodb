inherited FrmSelectDBLanding: TFrmSelectDBLanding
  Width = 480
  Height = 361
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  ExplicitWidth = 480
  ExplicitHeight = 361
  DesignSize = (
    480
    361)
  object RgMode: TRadioGroup
    Left = 0
    Top = 0
    Width = 477
    Height = 361
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'Select option'
    Items.Strings = (
      'Create new DB file'
      'Use exists file on hard disk drive'
      'Select known DB '
      'Create Example DB')
    TabOrder = 0
    OnClick = RgModeClick
  end
end
