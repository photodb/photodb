unit uVCLStylesOneLoadSpeedUp;

interface

uses
  Winapi.Windows,
  System.UITypes,
  System.SysUtils,
  Winapi.UxTheme,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.Mask,
  Vcl.GraphUtil,
  Vcl.ImgList,
  Vcl.Menus,
  Vcl.Grids,
  Vcl.CategoryButtons,
  Vcl.ButtonGroup,
  Vcl.ExtCtrls,
  Vcl.Consts,
  Winapi.Messages,
  System.Classes,
  Winapi.CommCtrl,
  System.Generics.Collections,
  System.ZLib,
  Vcl.Graphics,
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  Controls;

implementation

{$I StyleUtils.inc}
{$I StyleAPI.inc}

type
  TCustomStyleEx = class(TCustomStyle)
  public
    class function LoadFromStream(Stream: TStream): TCustomStyleServices; override;
  end;

  {$HINTS OFF}
  TCustomStyleHack = class(TCustomStyleServices)
  private
    FCustomElements: array[TThemedElement] of TCustomElementServicesClass;
    FSource: TObject; { TseSkin }
  end;
  {$HINTS ON}

class function TCustomStyleEx.LoadFromStream(
  Stream: TStream): TCustomStyleServices;
var
  LResult: TCustomStyle;
  Se: TseStyle;
begin
  LResult := TCustomStyle.Create;

  Se := TseStyle(TCustomStyleHack(LResult).FSource);
  Se.FreeObjects;

  Se.FStyleSource.LoadFromStream(Stream);

  Se.ResetObjects;
  Se.ResetStyleColors;
  Se.ResetStyleFonts;

  Result := LResult
end;

initialization
  TStyleManager.UnRegisterStyleClass(TCustomStyle);
  TStyleManager.RegisterStyleClass(TStyleEngine.FileExtension, SStyleFileDescription, TStyleEngine.ResourceTypeName, TCustomStyleEx);

finalization
  TStyleManager.UnRegisterStyleClass(TCustomStyleEx);
  TStyleManager.RegisterStyleClass(TStyleEngine.FileExtension, SStyleFileDescription, TStyleEngine.ResourceTypeName, TCustomStyle);

end.
