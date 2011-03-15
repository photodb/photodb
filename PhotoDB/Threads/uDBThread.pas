unit uDBThread;

interface

uses
  Classes, uTranslate, uAssociations;

type
  TDBThread = class(TThread)
  private
    FSupportedExt: string;
    function GetSupportedExt: string;
  protected
    function L(TextToTranslate : string) : string; overload;
    function L(TextToTranslate, Scope : string) : string; overload;
    function GetThreadID: string; virtual;
    property SupportedExt: string read GetSupportedExt;
  end;

implementation

{ TThreadEx }

function TDBThread.L(TextToTranslate: string): string;
begin
  Result := TA(TextToTranslate, GetThreadID);
end;

function TDBThread.GetSupportedExt: string;
begin
  if FSupportedExt = '' then
    FSupportedExt := TFileAssociations.Instance.ExtensionList;

  Result := FSupportedExt;
end;

function TDBThread.GetThreadID: string;
begin
  Result := ClassName;
end;

function TDBThread.L(TextToTranslate, Scope: string): string;
begin
  Result := TA(TextToTranslate, Scope);
end;

end.
