unit activation;

interface

uses
  Registry, StdCtrls, Controls, jpeg, messages, XPMan, ExtCtrls, Classes , Windows,  SysUtils, Forms,
  Dialogs, win32crc, shellApi;

type
  TActivateForm = class(TForm)
    Edit1: TEdit;
    Label1: TLabel;
    Edit2: TEdit;
    Label2: TLabel;
    Button1: TButton;
    Button2: TButton;
    Edit3: TEdit;
    Label3: TLabel;
    Image1: TImage;
    Button3: TButton;
    XPManifest1: TXPManifest;
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
  procedure wmmousedown(var s : Tmessage); message wm_lbuttondown;
    { Private declarations }
  public
  Procedure LoadLanguage;
    { Public declarations }
  end;

var
  ActivateForm: TActivateForm;
  Hs, Nm : string;

const
  ProductName = 'PhotoDB v1.6';
  ActivationID = '{C13440D5-2FF3-134C-1243-74FB56DC2211}';

implementation

uses language;

{$R *.dfm}

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

function ReadActivateKey: String;
var
  reg : tregistry;
begin
 reg:=Tregistry.Create;
 reg.RootKey:=windows.HKEY_CLASSES_ROOT;
 try
  reg.OpenKey('\CLSID\'+ActivationID,true);
  Result:=reg.ReadString('DefaultHandle');
  except
 end;
 Reg.CloseKey;
 reg.Free;
end;

procedure SetActivateKey(Name,Key: String);
var
  reg : tregistry;
begin
 reg:=Tregistry.Create;
 reg.RootKey:=windows.HKEY_CLASSES_ROOT;
 try
  reg.OpenKey('\CLSID\'+ActivationID,true);
  reg.WriteString('DefaultHandle',Key);
  reg.WriteString('UserName',Name);
  reg.CloseKey;
  except
 end;
 reg.free;
end;

function ApplicationCode: String;
var
  s, Code : String;
  n : Cardinal;
begin
 s:=GetIdeDiskSerialNumber;
 CalcStringCRC32(s,n);
 s:=inttohex(n,8);
 CalcStringCRC32(s,n);
 Code:=s+inttohex(n,8);
 Result:=Code;
end;

Procedure DoGetCode(S : String);
begin
 ShellExecute(0, Nil,Pchar('mailto:illusdolphin@yandex.ru?subject="'+ProductName+'" REGISTRATION CODE = "'+s+'"'), Nil, Nil, SW_NORMAL);
end;

function ReadRegName: string;
var
  reg : tregistry;
begin
 reg:=Tregistry.Create;
 reg.RootKey:=windows.HKEY_CLASSES_ROOT;
 try
  reg.OpenKey('\CLSID\'+ActivationID,true);
  Result:=reg.ReadString('UserName');
  except
 end;
 reg.free;
end;

procedure TActivateForm.FormCreate(Sender: TObject);
begin
 if ReadActivateKey<>'' then
 Edit2.text:=ReadActivateKey;
 if ReadRegName<>'' then
 Edit3.text:=ReadRegName;
 Hs := ReadActivateKey;
 Nm := ReadRegName;
 Edit1.text:=ApplicationCode;
 LoadLanguage;
end;

procedure TActivateForm.Button2Click(Sender: TObject);
var
  Reg : TRegistry;
begin
 Nm:=Edit3.text;
 Hs:=Edit2.text;
 reg:=tregistry.Create;
 reg.RootKey:=windows.HKEY_CLASSES_ROOT;
 reg.OpenKey('CLSID\'+ActivationID,true);
 reg.WriteString('UserName',Nm);
 reg.WriteString('Code',Hs);
 reg.free;
 Application.MessageBox(TEXT_MES_KEY_SAVE,TEXT_MES_WARNING,mb_ok+mb_iconwarning);
 Close;
end;

procedure TActivateForm.FormDestroy(Sender: TObject);
begin
 SetActivateKey(Nm,Hs);
end;

procedure TActivateForm.Button1Click(Sender: TObject);
begin
 Close;
end;

procedure TActivateForm.wmmousedown(var s: Tmessage);
begin
 Perform(wm_nclbuttondown,HTcaption,s.lparam);
end;

procedure TActivateForm.LoadLanguage;
begin
 Label1.Caption:=TEXT_MES_PROGRAM_CODE;
 Label2.Caption:=TEXT_MES_ACTIVATION_KEY;
 Label3.Caption:=TEXT_MES_ACTIVATION_NAME;
 Button1.Caption:=TEXT_MES_CANCEL;
 Button2.Caption:=TEXT_MES_SET_CODE;
 Caption:=TEXT_MES_ACTIVATION_CAPTION;
 Button3.Caption:=TEXT_MES_GET_CODE;
end;

procedure TActivateForm.Button3Click(Sender: TObject);
begin
 DoGetCode(Edit1.Text);
end;

initialization

 ActivateForm:=nil;

end.
