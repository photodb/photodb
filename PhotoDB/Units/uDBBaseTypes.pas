unit uDBBaseTypes;

interface

type
  TStringFunction = function: string;
  TIntegerFunction = function: Integer;
  TBooleanFunction = function: Boolean;
  TPAnsiCharFunction = function: PAnsiChar;
  TDllRegisterServer = function: HResult; stdcall;

implementation

end.
