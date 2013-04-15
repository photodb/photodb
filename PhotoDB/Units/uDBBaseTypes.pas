unit uDBBaseTypes;

interface

uses
  Vcl.Menus;

type
  TStringFunction = function: string;
  TIntegerFunction = function: Integer;
  TBooleanFunction = function: Boolean;
  TPAnsiCharFunction = function: PAnsiChar;
  TDllRegisterServer = function: HResult; stdcall;

  //array types
type
  TArMenuItem   = array of TMenuItem;
  TArInteger    = array of Integer;
  TArStrings    = array of String;
  TArBoolean    = array of Boolean;
  TArDateTime   = array of TDateTime;
  TArTime       = array of TDateTime;
  TArInteger64  = array of int64;
  TArCardinal   = array of Cardinal;

type
  TBuffer = array of Char;

type

  TProgressCallBackInfo = record
    MaxValue : Int64;
    Position : Int64;
    Information : String;
    Terminate : Boolean;
  end;

  TCallBackProgressEvent = procedure(Sender: TObject; var Info: TProgressCallBackInfo) of object;

type
  TSimpleCallBackProgressRef = reference to procedure(Sender: TObject; Total, Value: Int64);

implementation

end.
