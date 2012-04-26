inherited FrmConvertationLanding: TFrmConvertationLanding
  Width = 433
  Height = 361
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  ExplicitWidth = 433
  ExplicitHeight = 361
  object LbInfo: TLabel
    Left = 8
    Top = 8
    Width = 417
    Height = 73
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'Info'
    WordWrap = True
  end
  object LbCurrentDB: TLabel
    Left = 8
    Top = 88
    Width = 57
    Height = 13
    Caption = 'Current DB:'
  end
  object EdDBPath: TEdit
    Left = 8
    Top = 112
    Width = 417
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ParentColor = True
    ReadOnly = True
    TabOrder = 0
    Text = 'C:\'
  end
  object EdDBVersion: TEdit
    Left = 8
    Top = 144
    Width = 417
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ParentColor = True
    ReadOnly = True
    TabOrder = 1
    Text = 'DB v2.3'
  end
  object RbConvertParadox: TRadioButton
    Left = 8
    Top = 208
    Width = 420
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Convert to DB (Paradox)'
    TabOrder = 2
  end
  object RbConvertMDB: TRadioButton
    Left = 8
    Top = 264
    Width = 420
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Convert to MDB (Access)'
    Checked = True
    TabOrder = 3
    TabStop = True
  end
end
