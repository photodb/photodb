program Project1;

uses
  Forms,
  GIFImage in 'GIFImage.pas',
  ImEditor in 'ImEditor.pas' {ImageEditor},
  CropToolUnit in 'CropToolUnit.pas',
  ToolsUnit in 'ToolsUnit.pas',
  ImageHistoryUnit in 'ImageHistoryUnit.pas',
  RotateToolUnit in 'RotateToolUnit.pas',
  ResizeToolUnit in 'ResizeToolUnit.pas',
  EffectsToolUnit in 'EffectsToolUnit.pas',
  Effects in 'effects\Effects.pas',
  ColorToolUnit in 'ColorToolUnit.pas',
  RedEyeToolUnit in 'RedEyeToolUnit.pas',
  EffectsToolThreadUnit in 'EffectsToolThreadUnit.pas',
  RotateToolThreadUnit in 'RotateToolThreadUnit.pas',
  ExEffects in 'ExEffects.pas',
  ResizeToolThreadUnit in 'ResizeToolThreadUnit.pas',
  ExEffectFormUnit in 'ExEffectFormUnit.pas' {ExEffectForm},
  Language in '..\Units\Language.pas',
  ExEffectsUnit in 'ExEffectsUnit.pas',
  EffectsLanguage in 'EffectsLanguage.pas',
  GBlur2 in 'GBlur2.pas',
  GraphicsBaseTypes in 'GraphicsBaseTypes.pas',
  UnitEditorFullScreenForm in '..\UnitEditorFullScreenForm.pas' {EditorFullScreenForm},
  TextToolUnit in 'TextToolUnit.pas',
  BrushToolUnit in 'BrushToolUnit.pas',
  ExEffectsUnitW in 'ExEffectsUnitW.pas',
  Scanlines in 'effects\Scanlines.pas',
  ScanlinesFX in 'effects\ScanlinesFX.pas',
  InsertImageToolUnit in 'InsertImageToolUnit.pas',
  OptimizeImageUnit in 'OptimizeImageUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  EditorsManager.NewEditor;
  Application.CreateForm(TEditorFullScreenForm, EditorFullScreenForm);
  Application.Run;
end.
