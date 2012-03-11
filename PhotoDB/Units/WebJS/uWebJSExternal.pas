{
  This demo application accompanies the article
  "How to call Delphi code from scripts running in a TWebBrowser" at
  http://www.delphidabbler.com/articles?article=22.

  This unit defines a class that extends the TWebBrowser's external object.

  This code is copyright (c) P D Johnson (www.delphidabbler.com), 2005-2006.

  v1.0 of 2005/05/09 - original version
  v1.1 of 2006/02/11 - changed base URL of programs to reflect current use
}

{$A8,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$WARN UNSAFE_TYPE OFF}

unit uWebJSExternal;

interface

uses
  Classes,
  ComObj,
  WebJS_TLB,
  ActiveX;

type
  TWebJSExternal = class(TAutoIntfObject, IWebJSExternal, IDispatch)
  private
    FExternalObject: IWebJSExternal;
  protected
    { IWebJSExternal methods }
    function SaveLocation(Lat: Double; Lng: Double; const FileName: WideString): Shortint; safecall;
    procedure ZoomPan(Lat: Double; Lng: Double; Zoom: SYSINT); safecall;
    procedure UpdateEmbed(); safecall;
    procedure MapStarted(); safecall;
  public
    constructor Create(ExternalObject: IWebJSExternal);
    destructor Destroy; override;
  end;

implementation

uses
  SysUtils;

{ TWebJSExternal }

constructor TWebJSExternal.Create(ExternalObject: IWebJSExternal);
var
  TypeLib: ITypeLib;    // type library information
  ExeName: WideString;  // name of our program's exe file
begin
  FExternalObject := ExternalObject;
  // Get name of application
  ExeName := ParamStr(0);
  // Load type library from application's resources
  OleCheck(LoadTypeLib(PWideChar(ExeName), TypeLib));
  // Call inherited constructor
  inherited Create(TypeLib, IWebJSExternal);
end;

destructor TWebJSExternal.Destroy;
begin
  FExternalObject := nil;
  inherited;
end;

procedure TWebJSExternal.MapStarted();
begin
  FExternalObject.MapStarted();
end;

procedure TWebJSExternal.UpdateEmbed();
begin
  FExternalObject.UpdateEmbed();
end;

procedure TWebJSExternal.ZoomPan(Lat, Lng: Double; Zoom: SYSINT);
begin
  FExternalObject.ZoomPan(Lat, Lng, Zoom);
end;

function TWebJSExternal.SaveLocation(Lat, Lng: Double; const FileName: WideString): Shortint;
begin
  Result := FExternalObject.SaveLocation(Lat, Lng, FileName);
end;

end.
