unit uErrors;

interface

uses
  System.SysUtils,
  uSysUtils
{$IFDEF PHOTODB}
  ,uTranslate
{$ENDIF}
  ;

const
  CRYPT_RESULT_UNDEFINED            = 0;
  CRYPT_RESULT_OK                   = 1;
  CRYPT_RESULT_FAILED_CRYPT         = 2;
  CRYPT_RESULT_FAILED_CRYPT_FILE    = 3;
  CRYPT_RESULT_FAILED_CRYPT_DB      = 4;
  CRYPT_RESULT_PASS_INCORRECT       = 5;
  CRYPT_RESULT_PASS_DIFFERENT       = 6;
  CRYPT_RESULT_ALREADY_CRYPT        = 7;
  CRYPT_RESULT_ALREADY_DECRYPTED    = 8;
  CRYPT_RESULT_ERROR_READING_FILE   = 9;
  CRYPT_RESULT_ERROR_WRITING_FILE   = 10;
  CRYPT_RESULT_FAILED_GENERAL_ERROR = 11;
  CRYPT_RESULT_UNSUPORTED_VERSION   = 12;


function DBErrorToString(ErrorCode: Integer): string;

implementation

function DBErrorToString(ErrorCode: Integer): string;
begin
  {$IFnDEF PHOTODB}
  Result := 'Error code is ' + IntToStr(ErrorCode);
  {$ENDIF}
  {$IFDEF PHOTODB}
  case ErrorCode of
    CRYPT_RESULT_UNDEFINED:
      Result := TA('Result is undefined!', 'Errors');
    CRYPT_RESULT_OK:
      Result := TA('No errors', 'Errors');
    CRYPT_RESULT_FAILED_CRYPT:
      Result := TA('Failed to encrypt object!', 'Errors');
    CRYPT_RESULT_FAILED_CRYPT_FILE:
      Result := TA('Failed to encrypt file!', 'Errors');
    CRYPT_RESULT_FAILED_CRYPT_DB:
      Result := TA('Failed to encrypt collection item!', 'Errors');
    CRYPT_RESULT_PASS_INCORRECT:
      Result := TA('Password is incorrect!', 'Errors');
    CRYPT_RESULT_PASS_DIFFERENT:
      Result := TA('Passwords are different!', 'Errors');
    CRYPT_RESULT_ALREADY_CRYPT:
      Result := TA('Object is already encrypted!', 'Errors');
    CRYPT_RESULT_ALREADY_DECRYPTED:
      Result := TA('Object is already decrypted!', 'Errors');
    CRYPT_RESULT_ERROR_READING_FILE:
      Result := TA('Error reading from file!', 'Errors');
    CRYPT_RESULT_ERROR_WRITING_FILE:
      Result := TA('Error writing to file!', 'Errors');
    CRYPT_RESULT_UNSUPORTED_VERSION:
      Result := TA('Unsupported version of file!', 'Errors');
    else
      Result := FormatEx(TA('Error code is: {0}' , 'Errors'), [ErrorCode]);
  end;
  {$ENDIF}
end;

end.
