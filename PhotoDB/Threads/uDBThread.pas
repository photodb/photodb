unit uDBThread;

interface

uses
  Classes, uTranslate;

type
  TDBThread = class(TThread)
  protected
    function L(TextToTranslate : string) : string; overload;
    function L(TextToTranslate, Scope : string) : string; overload;
    function GetThreadID : string; virtual; abstract;
  end;

implementation

{ TThreadEx }

function TDBThread.L(TextToTranslate: string): string;
begin
  Result := TA(TextToTranslate, GetThreadID);
end;

function TDBThread.L(TextToTranslate, Scope: string): string;
begin
  Result := TA(TextToTranslate, Scope);
end;

end.
