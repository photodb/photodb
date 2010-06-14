unit ActivationFunctions;

interface

uses Windows, Math,  SysUtils, win32crc;

const

  V_UNCNOWN              = 0;
  V_1_8_SMALLER          = 1;
  V_1_9                  = 2;
  V_2_0                  = 3;
  V_ENGL_UNCNOWN         = 4;

function hextointdef(hex:string;default:integer):integer;
function GetIdeDiskSerialNumber : String;
function chartoint(ch : char):Integer;
function inttochar(int : Integer):char;
function GetComputerID(Code : String) : String;
function GetCodeVersionStr(Code : String) : String;

implementation

function GetIdeDiskSerialNumber : String;
type
  TSrbIoControl = packed record
    HeaderLength : ULONG;
    Signature : Array[0..7] of Char;
    Timeout : ULONG; 
    ControlCode : ULONG; 
    ReturnCode : ULONG; 
    Length : ULONG; 
  end; 
  SRB_IO_CONTROL = TSrbIoControl; 
  PSrbIoControl = ^TSrbIoControl; 

  TIDERegs = packed record 
    bFeaturesReg : Byte; // Used for specifying SMART "commands". 
    bSectorCountReg : Byte; // IDE sector count register 
    bSectorNumberReg : Byte; // IDE sector number register 
    bCylLowReg : Byte; // IDE low order cylinder value 
    bCylHighReg : Byte; // IDE high order cylinder value 
    bDriveHeadReg : Byte; // IDE drive/head register 
    bCommandReg : Byte; // Actual IDE command. 
    bReserved : Byte; // reserved for future use. Must be zero. 
  end; 
  IDEREGS = TIDERegs; 
  PIDERegs = ^TIDERegs; 

  TSendCmdInParams = packed record 
    cBufferSize : DWORD; // Buffer size in bytes 
    irDriveRegs : TIDERegs; // Structure with drive register values. 
    bDriveNumber : Byte; // Physical drive number to send command to (0,1,2,3). 
    bReserved : Array[0..2] of Byte; // Reserved for future expansion. 
    dwReserved : Array[0..3] of DWORD; // For future use. 
    bBuffer : Array[0..0] of Byte; // Input buffer. 
  end; 
  SENDCMDINPARAMS = TSendCmdInParams; 
  PSendCmdInParams = ^TSendCmdInParams; 

  TIdSector = packed record 
    wGenConfig : Word; 
    wNumCyls : Word; 
    wReserved : Word; 
    wNumHeads : Word; 
    wBytesPerTrack : Word; 
    wBytesPerSector : Word; 
    wSectorsPerTrack : Word; 
    wVendorUnique : Array[0..2] of Word; 
    sSerialNumber : Array[0..19] of Char; 
    wBufferType : Word; 
    wBufferSize : Word; 
    wECCSize : Word; 
    sFirmwareRev : Array[0..7] of Char; 
    sModelNumber : Array[0..39] of Char; 
    wMoreVendorUnique : Word; 
    wDoubleWordIO : Word; 
    wCapabilities : Word; 
    wReserved1 : Word; 
    wPIOTiming : Word; 
    wDMATiming : Word; 
    wBS : Word; 
    wNumCurrentCyls : Word; 
    wNumCurrentHeads : Word; 
    wNumCurrentSectorsPerTrack : Word; 
    ulCurrentSectorCapacity : ULONG; 
    wMultSectorStuff : Word; 
    ulTotalAddressableSectors : ULONG; 
    wSingleWordDMA : Word; 
    wMultiWordDMA : Word; 
    bReserved : Array[0..127] of Byte; 
  end; 
  PIdSector = ^TIdSector; 

const 
  IDE_ID_FUNCTION = $EC; 
  IDENTIFY_BUFFER_SIZE = 512; 
  DFP_RECEIVE_DRIVE_DATA = $0007c088; 
  IOCTL_SCSI_MINIPORT = $0004d008; 
  IOCTL_SCSI_MINIPORT_IDENTIFY = $001b0501; 
  DataSize = sizeof(TSendCmdInParams)-1+IDENTIFY_BUFFER_SIZE; 
  BufferSize = SizeOf(SRB_IO_CONTROL)+DataSize; 
  W9xBufferSize = IDENTIFY_BUFFER_SIZE+16; 
var 
  hDevice : THandle; 
  cbBytesReturned : DWORD; 
  pInData : PSendCmdInParams; 
  pOutData : Pointer; // PSendCmdInParams; 
  Buffer : Array[0..BufferSize-1] of Byte; 
  srbControl : TSrbIoControl absolute Buffer; 

  procedure ChangeByteOrder( var Data; Size : Integer ); 
  var ptr : PChar; 
      i : Integer; 
      c : Char; 
  begin 
    ptr := @Data; 
    for i := 0 to (Size shr 1)-1 do 
    begin 
      c := ptr^; 
      ptr^ := (ptr+1)^; 
      (ptr+1)^ := c; 
      Inc(ptr,2); 
    end; 
  end; 

begin 
  Result := ''; 
  FillChar(Buffer,BufferSize,#0); 
  if Win32Platform=VER_PLATFORM_WIN32_NT then
    begin // Windows NT, Windows 2000 
      // Get SCSI port handle 
      hDevice := CreateFile( '\\.\Scsi0:', GENERIC_READ or GENERIC_WRITE, 
        FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0 ); 
      if hDevice=INVALID_HANDLE_VALUE then Exit; 
      try 
        srbControl.HeaderLength := SizeOf(SRB_IO_CONTROL); 
        System.Move('SCSIDISK',srbControl.Signature,8); 
        srbControl.Timeout := 2; 
        srbControl.Length := DataSize; 
        srbControl.ControlCode := IOCTL_SCSI_MINIPORT_IDENTIFY; 
        pInData := PSendCmdInParams(PChar(@Buffer)+SizeOf(SRB_IO_CONTROL)); 
        pOutData := pInData; 
        with pInData^ do 
        begin 
          cBufferSize := IDENTIFY_BUFFER_SIZE; 
          bDriveNumber := 0; 
          with irDriveRegs do 
          begin 
            bFeaturesReg := 0; 
            bSectorCountReg := 1; 
            bSectorNumberReg := 1; 
            bCylLowReg := 0; 
            bCylHighReg := 0; 
            bDriveHeadReg := $A0; 
            bCommandReg := IDE_ID_FUNCTION; 
          end; 
        end; 
        if not DeviceIoControl( hDevice, IOCTL_SCSI_MINIPORT, @Buffer, 
          BufferSize, @Buffer, BufferSize, cbBytesReturned, nil ) then Exit; 
      finally 
        CloseHandle(hDevice); 
      end; 
    end 
  else
    begin // Windows 95 OSR2, Windows 98
      hDevice := CreateFile( '\\.\SMARTVSD', 0, 0, nil, CREATE_NEW, 0, 0 );
      if hDevice=INVALID_HANDLE_VALUE then Exit; 
      try 
        pInData := PSendCmdInParams(@Buffer); 
        pOutData := PChar(@pInData^.bBuffer); 
        with pInData^ do 
        begin 
          cBufferSize := IDENTIFY_BUFFER_SIZE; 
          bDriveNumber := 0; 
          with irDriveRegs do 
          begin 
            bFeaturesReg := 0; 
            bSectorCountReg := 1; 
            bSectorNumberReg := 1; 
            bCylLowReg := 0; 
            bCylHighReg := 0; 
            bDriveHeadReg := $A0; 
            bCommandReg := IDE_ID_FUNCTION; 
          end; 
        end; 
        if not DeviceIoControl( hDevice, DFP_RECEIVE_DRIVE_DATA, pInData,  
           SizeOf(TSendCmdInParams)-1, pOutData, W9xBufferSize, 
           cbBytesReturned, nil ) then Exit; 
      finally 
        CloseHandle(hDevice); 
      end; 
    end; 
    with PIdSector(PChar(pOutData)+16)^ do 
    begin 
      ChangeByteOrder(sSerialNumber,SizeOf(sSerialNumber)); 
      SetString(Result,sSerialNumber,SizeOf(sSerialNumber)); 
    end; 
end;

Function hextointdef(hex:string;default:integer):integer;
var s:string;
int,i:integer;
begin
int:=0;
If length(hex)>0 then If hex[1]='$' then delete(hex,1,1);
If length(hex)>0 then begin
For i:=1 to length(hex) do begin
s:=s+' ';
s[i]:=hex[length(hex)+1-i];
end;
For i:=1 to length(hex) do
Case Upcase(s[i]) of
'0': int:=int;
'1': int:=int+round(intpower(16,i-1));
'2': int:=int+2*round(intpower(16,i-1));
'3': int:=int+3*round(intpower(16,i-1));
'4': int:=int+4*round(intpower(16,i-1));
'5': int:=int+5*round(intpower(16,i-1));
'6': int:=int+6*round(intpower(16,i-1));
'7': int:=int+7*round(intpower(16,i-1));
'8': int:=int+8*round(intpower(16,i-1));
'9': int:=int+9*round(intpower(16,i-1));
'A': int:=int+10*round(intpower(16,i-1));
'B': int:=int+11*round(intpower(16,i-1));
'C': int:=int+12*round(intpower(16,i-1));
'D': int:=int+13*round(intpower(16,i-1));
'E': int:=int+14*round(intpower(16,i-1));
'F': int:=int+15*round(intpower(16,i-1));
else begin int:=default; break; end;
end;
end else int:=default;
result:=int;
end;

function chartoint(ch : char):Integer;
begin
 Result:=HexToIntDef(ch,0);
end;

function inttochar(int : Integer):char;
begin
 result:=IntToHex(int,1)[1];
end;

 function GetCodeVersion(Code : String) : integer;
 var
   s : String;
   hs, cs, csold : string;
   n : Cardinal;
   b : boolean;
   i : integer;
 begin
 s:=Code;
 hs:=copy(s,1,8);
 CalcStringCRC32(hs,n);
 hs:=inttohex(n,8);
 cs:=copy(s,9,8);
 if cs<>hs then
 begin
  b:=false;
  csold:=IntToHex(HexToIntDef(cs,0) xor $1459EF12,8);
  if (csold=hs) and not b then
  begin
   cs:=csold;
   Result:=V_ENGL_UNCNOWN;
   b:=true;
  end;
  csold:=IntToHex(HexToIntDef(cs,0) xor $4D69F789,8);
  if (csold=hs) and not b then
  begin
   cs:=csold;
   Result:=V_1_9;
   b:=true;
  end;
  i:=HexToIntDef(cs,0) xor $E445CF12;
  csold:=IntToHex(i,8);
  if Copy(csold,1,8)='FFFFFFFF' then Delete(csold,1,8);
  if (csold=hs) and not b then
  begin
   cs:=csold;
   Result:=V_2_0;
   b:=true;
  end;
  if not b then
  begin
   Result:=V_UNCNOWN;
   exit;
  end
 end else
 begin
  Result:=V_1_8_SMALLER;
 end;
end;

 function GetCodeVersionStr(Code : String) : String;
 begin
  Case GetCodeVersion(Code) of
  V_UNCNOWN           : Result:='Unkwn';
  V_1_8_SMALLER       : Result:='1.8';
  V_1_9               : Result:='1.9';
  V_2_0               : Result:='2.0';
  V_ENGL_UNCNOWN      : Result:='eng';
  end;
 end;

function GetComputerID(Code : String) : String;
var
  s : string;
  v : integer;

  function Decode(hex : integer) : string;
  var
    x : integer;
  begin
   x:=HexToIntDef(s,0);
   x:=x xor hex;
   Result:=IntToHex(x,8);
  end;

begin
 Result:='00000000';
 v:=GetCodeVersion(Code);
 S:=Copy(Code,1,8);
 if (S='00000000') or (S='FA45B671') or (S='8C54AF5B') or (S='AC68DF35') or (S='B1534A4F') then exit;
 Case v of
  V_1_8_SMALLER   : Result:=Decode($8C54AF5B);
  V_1_9           : Result:=Decode($AC68DF35);
  V_2_0           : Result:=Decode($B1534A4F);
 end;
end;

end.
