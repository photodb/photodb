unit uActivationUtils;

interface

uses
  Windows, SysUtils, UnitDBCommon, uRuntime;

type
  TCIDProcedure = procedure(Buffferm: PChar; BuffesSize : Integer);

function ActivationID: string;
function GetIdeDiskSerialNumber: string;
function CodeToActivateCode(S: string): string;

implementation

function CodeToActivateCode(S: string): string;
var
  C, Intr, Sum, I: Integer;
  Hs: string;
begin
  Sum := 0;
  for I := 1 to Length(S) do
    Sum := Sum + Ord(S[I]);
  Result := '';
  for I := 1 to Length(S) div 2 do
  begin
    C := HexToIntDef(S[2 * (I - 1) + 1] + S[2 * (I - 1) + 2], 0);
    Intr := Round(Abs($FF * Cos($FF * C + Sum + Sin(I))));
    Hs := Inttohex(Intr, 2);
    Result := Result + Hs;
  end;
end;

function ActivationID: string;
var
  P: TCIDProcedure;
  PAddr: Pointer;
  Buffer : PChar;
  KernelHandle : THandle;

const
  MaxBufferSize = 255;

begin
  Result := '';
  KernelHandle := LoadLibrary(PChar(IncludeTrailingBackslash(ExtractFileDir(ParamStr(0))) + 'Kernel.dll'));
  try
    PAddr := GetProcAddress(KernelHandle, 'GetCIDA');
    if PAddr = nil then
      Exit;

    @P := PAddr;
    GetMem(Buffer, MaxBufferSize);
    try
      P(Buffer, MaxBufferSize);
      Result := Trim(Buffer);
    finally
      FreeMem(Buffer);
    end;

  finally
    FreeLibrary(KernelHandle);
  end;
end;

function GetIdeDiskSerialNumberW: string;
var
  VolumeName, FileSystemName: array [0 .. MAX_PATH - 1] of Char;
  VolumeSerialNo: DWord;
  MaxComponentLength, FileSystemFlags: Cardinal;
begin
  GetVolumeInformation(PWideChar(Copy(ParamStr(0), 1, 3)), VolumeName, MAX_PATH, @VolumeSerialNo,
    MaxComponentLength, FileSystemFlags, FileSystemName, MAX_PATH);
  Result := IntToHex(VolumeSerialNo, 8);
end;

function GetIdeDiskSerialNumber: string;
type
  TSrbIoControl = packed record
    HeaderLength: ULONG;
    Signature: array [0 .. 7] of Char;
    Timeout: ULONG;
    ControlCode: ULONG;
    ReturnCode: ULONG;
    Length: ULONG;
  end;

  SRB_IO_CONTROL = TSrbIoControl;
  PSrbIoControl = ^TSrbIoControl;

  TIDERegs = packed record
    BFeaturesReg: Byte; // Used for specifying SMART "commands".
    BSectorCountReg: Byte; // IDE sector count register
    BSectorNumberReg: Byte; // IDE sector number register
    BCylLowReg: Byte; // IDE low order cylinder value
    BCylHighReg: Byte; // IDE high order cylinder value
    BDriveHeadReg: Byte; // IDE drive/head register
    BCommandReg: Byte; // Actual IDE command.
    BReserved: Byte; // reserved for future use. Must be zero.
  end;

  IDEREGS = TIDERegs;
  PIDERegs = ^TIDERegs;

  TSendCmdInParams = packed record
    CBufferSize: DWORD; // Buffer size in bytes
    IrDriveRegs: TIDERegs; // Structure with drive register values.
    BDriveNumber: Byte; // Physical drive number to send command to (0,1,2,3).
    BReserved: array [0 .. 2] of Byte; // Reserved for future expansion.
    DwReserved: array [0 .. 3] of DWORD; // For future use.
    BBuffer: array [0 .. 0] of Byte; // Input buffer.
  end;

  SENDCMDINPARAMS = TSendCmdInParams;
  PSendCmdInParams = ^TSendCmdInParams;

  TIdSector = packed record
    WGenConfig: Word;
    WNumCyls: Word;
    WReserved: Word;
    WNumHeads: Word;
    WBytesPerTrack: Word;
    WBytesPerSector: Word;
    WSectorsPerTrack: Word;
    WVendorUnique: array [0 .. 2] of Word;
    SSerialNumber: array [0 .. 19] of Char;
    WBufferType: Word;
    WBufferSize: Word;
    WECCSize: Word;
    SFirmwareRev: array [0 .. 7] of Char;
    SModelNumber: array [0 .. 39] of Char;
    WMoreVendorUnique: Word;
    WDoubleWordIO: Word;
    WCapabilities: Word;
    WReserved1: Word;
    WPIOTiming: Word;
    WDMATiming: Word;
    WBS: Word;
    WNumCurrentCyls: Word;
    WNumCurrentHeads: Word;
    WNumCurrentSectorsPerTrack: Word;
    UlCurrentSectorCapacity: ULONG;
    WMultSectorStuff: Word;
    UlTotalAddressableSectors: ULONG;
    WSingleWordDMA: Word;
    WMultiWordDMA: Word;
    BReserved: array [0 .. 127] of Byte;
  end;

  PIdSector = ^TIdSector;

const
  IDE_ID_FUNCTION = $EC;
  IDENTIFY_BUFFER_SIZE = 512;
  DFP_RECEIVE_DRIVE_DATA = $0007C088;
  IOCTL_SCSI_MINIPORT = $0004D008;
  IOCTL_SCSI_MINIPORT_IDENTIFY = $001B0501;
  DataSize = Sizeof(TSendCmdInParams) - 1 + IDENTIFY_BUFFER_SIZE;
  BufferSize = SizeOf(SRB_IO_CONTROL) + DataSize;
  W9xBufferSize = IDENTIFY_BUFFER_SIZE + 16;
var
  HDevice: THandle;
  CbBytesReturned: DWORD;
  PInData: PSendCmdInParams;
  POutData: Pointer; // PSendCmdInParams;
  Buffer: array [0 .. BufferSize - 1] of Byte;
  SrbControl: TSrbIoControl absolute Buffer;

  procedure ChangeByteOrder(var Data; Size: Integer);
  var
    Ptr: PChar;
    I: Integer;
    C: Char;
  begin
    Ptr := @Data;
    for I := 0 to (Size shr 1) - 1 do
    begin
      C := Ptr^;
      Ptr^ := (Ptr + 1)^; (Ptr + 1)
      ^ := C;
      Inc(Ptr, 2);
    end;
  end;

begin
  if PortableWork then
  begin
    Result := GetIdeDiskSerialNumberW;
    Exit;
  end;
  Result := '';
  FillChar(Buffer, BufferSize, #0);
  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin // Windows NT, Windows 2000
    // Get SCSI port handle
    HDevice := CreateFile('\\.\Scsi0:', GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, nil,
      OPEN_EXISTING, 0, 0);
    if HDevice = INVALID_HANDLE_VALUE then
      Exit;
    try
      SrbControl.HeaderLength := SizeOf(SRB_IO_CONTROL);
      System.Move('SCSIDISK', SrbControl.Signature, 8);
      SrbControl.Timeout := 2;
      SrbControl.Length := DataSize;
      SrbControl.ControlCode := IOCTL_SCSI_MINIPORT_IDENTIFY;
      PInData := PSendCmdInParams(PChar(@Buffer) + SizeOf(SRB_IO_CONTROL));
      POutData := PInData;
      with PInData^ do
      begin
        CBufferSize := IDENTIFY_BUFFER_SIZE;
        BDriveNumber := 0;
        with IrDriveRegs do
        begin
          BFeaturesReg := 0;
          BSectorCountReg := 1;
          BSectorNumberReg := 1;
          BCylLowReg := 0;
          BCylHighReg := 0;
          BDriveHeadReg := $A0;
          BCommandReg := IDE_ID_FUNCTION;
        end;
      end;
      if not DeviceIoControl(HDevice, IOCTL_SCSI_MINIPORT, @Buffer, BufferSize, @Buffer, BufferSize, CbBytesReturned,
        nil) then
        Exit;
    finally
      CloseHandle(HDevice);
    end;
  end
  else
  begin // Windows 95 OSR2, Windows 98
    HDevice := CreateFile('\\.\SMARTVSD', 0, 0, nil, CREATE_NEW, 0, 0);
    if HDevice = INVALID_HANDLE_VALUE then
      Exit;
    try
      PInData := PSendCmdInParams(@Buffer);
      POutData := PChar(@PInData^.BBuffer);
      with PInData^ do
      begin
        CBufferSize := IDENTIFY_BUFFER_SIZE;
        BDriveNumber := 0;
        with IrDriveRegs do
        begin
          BFeaturesReg := 0;
          BSectorCountReg := 1;
          BSectorNumberReg := 1;
          BCylLowReg := 0;
          BCylHighReg := 0;
          BDriveHeadReg := $A0;
          BCommandReg := IDE_ID_FUNCTION;
        end;
      end;
      if not DeviceIoControl(HDevice, DFP_RECEIVE_DRIVE_DATA, PInData, SizeOf(TSendCmdInParams) - 1, POutData,
        W9xBufferSize, CbBytesReturned, nil) then
        Exit;
    finally
      CloseHandle(HDevice);
    end;
  end;
  with PIdSector(PChar(POutData) + 16)^ do
  begin
    ChangeByteOrder(SSerialNumber, SizeOf(SSerialNumber));
    SetString(Result, SSerialNumber, SizeOf(SSerialNumber));
  end;
end;

end.
