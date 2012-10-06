unit uXMLUtils;

interface

uses
  MSXML2_TLB,
  Winapi.ActiveX;

function CreateXMLDocument: IXMLDOMDocument;

implementation

function CreateXMLDocument: IXMLDOMDocument;
var
  ClassID: TGUID;
  HR: HRESULT;
begin
  Result := nil;

  HR := CLSIDFromProgID(PWideChar(WideString('Msxml2.DOMDocument.6.0')), ClassID);
  if Succeeded(HR) then
    HR := CoCreateInstance(ClassID, nil, CLSCTX_INPROC_SERVER or CLSCTX_LOCAL_SERVER, IDispatch, Result);

  if Failed(HR) then
  begin
    HR := CLSIDFromProgID(PWideChar(WideString('Msxml2.DOMDocument.3.0')), ClassID);
    if Succeeded(HR) then
      CoCreateInstance(ClassID, nil, CLSCTX_INPROC_SERVER or CLSCTX_LOCAL_SERVER, IDispatch, Result);
  end;

  if Failed(HR) then
  begin
    HR := CLSIDFromProgID(PWideChar(WideString('Msxml.DOMDocument')), ClassID);
    if Succeeded(HR) then
    //if this method failed - OS isn't supported
      CoCreateInstance(ClassID, nil, CLSCTX_INPROC_SERVER or CLSCTX_LOCAL_SERVER, IDispatch, Result);
  end;
end;

end.
