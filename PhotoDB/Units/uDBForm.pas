unit uDBForm;

interface

uses
  Forms, uTranslate;

type
  TDBForm = class(TForm)
  protected
    function GetFormID : string; virtual; abstract;
  public
    function L(StringToTranslate : string) : string;
  end;

implementation

{ TDBForm }

function TDBForm.L(StringToTranslate: string): string;
begin
  Result := TTranslateManager.Instance.Translate(StringToTranslate, GetFormID);
end;

end.
