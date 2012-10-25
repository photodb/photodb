unit uProgramCommunication;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  uConstants;

procedure NotifyEncryptionError(ErrorMessage: string);

implementation

var
  LastErrorMessage: Cardinal = 0;

procedure NotifyEncryptionError(ErrorMessage: string);
var
  WinHandle: THandle;
  MessageToSent: string;
  CD: TCopyDataStruct;
  Buf: Pointer;
  P: PByte;
begin
  if GetTickCount - LastErrorMessage < 500 then
    Exit;

  LastErrorMessage := GetTickCount;

  WinHandle := FindWindow(nil, PChar(DB_ID));
  if WinHandle <> 0 then
  begin
    MessageToSent := '::ENCRYPT_ERROR:' + ErrorMessage;

    cd.dwData := WM_COPYDATA_ID;
    cd.cbData := ((Length(MessageToSent) + 1) * SizeOf(Char));
    GetMem(Buf, cd.cbData);
    try
      P := PByte(Buf);

      StrPLCopy(PChar(P), MessageToSent, Length(MessageToSent));
      cd.lpData := Buf;

      SendMessage(WinHandle, WM_COPYDATA, 0, NativeInt(@cd));
    finally
      FreeMem(Buf);
    end;
  end;

end;

end.
