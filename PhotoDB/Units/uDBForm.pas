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
    function LA(StringToTranslate : string) : string;
  end;

implementation

{ TDBForm }

function TDBForm.L(StringToTranslate: string): string;
begin
  Result := TTranslateManager.Instance.Translate(StringToTranslate, GetFormID);
end;

function TDBForm.LA(StringToTranslate: string): string;
begin
  Result := TTranslateManager.Instance.TA(StringToTranslate, GetFormID);
end;

end.
