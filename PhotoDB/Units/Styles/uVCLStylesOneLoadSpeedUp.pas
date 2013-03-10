unit uVCLStylesOneLoadSpeedUp;

interface

uses

  System.ZLib,
  System.Types,
  System.UITypes,
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Winapi.UxTheme,
  Winapi.Messages,


  Vcl.ComCtrls,

  Vcl.GraphUtil,
  Vcl.ImgList,


  Vcl.CategoryButtons,


  Vcl.Consts,
  Vcl.Graphics,
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  Vcl.Controls;

implementation

//local files should be copied from Delphi sources
{$I StyleUtils.inc}
{$I StyleAPI.inc}

type
  TCustomStyleEx = class(TCustomStyle)
  public
    class function LoadFromStream(Stream: TStream): TCustomStyleServices; override;
    constructor Create; override;
  end;

  {$HINTS OFF}
  TCustomStyleHack = class(TCustomStyleServices)
  private
    FCustomElements: array[TThemedElement] of TCustomElementServicesClass;
    FSource: TObject; { TseSkin }
  end;
  {$HINTS ON}

  TSeStyleSourceEx = class(TSeStyleSource)

  end;

constructor TCustomStyleEx.Create;
begin
  inherited;
  //free object from Vcl.Styles and create object from included units
  TCustomStyleHack(Self).FSource.Free;
  TCustomStyleHack(Self).FSource := TseStyle.Create;
end;

class function TCustomStyleEx.LoadFromStream(
  Stream: TStream): TCustomStyleServices;
var
  LResult: TCustomStyle;
  Se: TseStyle;
begin
  LResult := TCustomStyleEx.Create;

  Se := TseStyle(TCustomStyleHack(LResult).FSource);

  //free objects from Vcl.Styles and create objects from included units
  Se.FStyleSource.Free;
  Se.FStyleSource := TSeStyleSourceEx.Create(nil);
  Se.FCleanCopy.Free;
  Se.FCleanCopy := TSeStyleSourceEx.Create(nil);

  Se.FStyleSource.LoadFromStream(Stream);

  Se.ResetObjects;
  Se.ResetStyleColors;
  Se.ResetStyleFonts;

  Result := LResult;
end;

initialization
  InitStyleAPI;
  TStyleManager.UnRegisterStyleClass(TCustomStyle);
  TStyleManager.RegisterStyleClass(TStyleEngine.FileExtension, SStyleFileDescription, TStyleEngine.ResourceTypeName, TCustomStyleEx);

finalization
  TStyleManager.UnRegisterStyleClass(TCustomStyleEx);
  TStyleManager.RegisterStyleClass(TStyleEngine.FileExtension, SStyleFileDescription, TStyleEngine.ResourceTypeName, TCustomStyle);
  FinalizeStyleAPI;

end.
