unit uInstallFrame;

interface

uses
  Classes, Forms, uTranslate;

type
  TInstallFrame = class(TFrame)
  public
    function L(TextToTranslate : string) : string;
  end;

implementation

{ TInstallFrame }

function TInstallFrame.L(TextToTranslate: string): string;
begin
  TTranslateManager.Instance.Translate(TextToTranslate, 'Setup');
end;

end.
