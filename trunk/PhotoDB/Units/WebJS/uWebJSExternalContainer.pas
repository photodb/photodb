{
  This demo application accompanies the article
  "How to call Delphi code from scripts running in a TWebBrowser" at
  http://www.delphidabbler.com/articles?article=22.

  This unit defines the IDocHostUIHandler implementation that provides the
  external object to the TWebBrowser.

  This code is copyright (c) P D Johnson (www.delphidabbler.com), 2005-2006.

  v1.0 of 2005/05/09 - original version named UExternalUIHandler.pas
  v2.0 of 2006/02/11 - revised to descend from new TNulWBContainer class
}

{$A8,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}

unit uWebJSExternalContainer;

interface

uses
  // Delphi
  ActiveX,
  SHDocVw,
  // Project
  WebJS_TLB,
  IntfDocHostUIHandler,
  uWebNullContainer,
  uWebJSExternal;

type
  {
  TExternalContainer:
    UI handler that extends browser's external object.
  }
  TWebJSExternalContainer = class(TWebNullWBContainer, IDocHostUIHandler, IOleClientSite)
  private
    FExternalObj: IDispatch;  // external object implementation
  protected
    { Re-implemented IDocHostUIHandler method }
    function GetExternal(out ppDispatch: IDispatch): HResult; stdcall;
  public
    constructor Create(const HostedBrowser: TWebBrowser; ExternalObject: IWebJSExternal);
  end;

implementation

{ TExternalContainer }

constructor TWebJSExternalContainer.Create(const HostedBrowser: TWebBrowser; ExternalObject: IWebJSExternal);
begin
  inherited Create(HostedBrowser);
  FExternalObj := TWebJSExternal.Create(ExternalObject);
end;

function TWebJSExternalContainer.GetExternal(out ppDispatch: IDispatch): HResult;
begin
  ppDispatch := FExternalObj;
  Result := S_OK; // indicates we've provided script
end;

end.

