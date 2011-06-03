unit uActivationUtils;

interface

uses
  Windows, SysUtils, uRuntime, Classes, Registry, uMemory,
  win32crc, uConstants, SyncObjs, uTranslate, uSysUtils;

type
  TCIDProcedure = procedure(Buffferm: PChar; BuffesSize : Integer);

const
  RegistrationUserName : string = 'UserName';
  RegistrationCode : string = 'AcivationCode';

type
  TActivationManager = class(TObject)
  private
    FSync: TCriticalSection;
    FRegistrationLoaded: Boolean;
    FIsDemoMode: Boolean;
    FIsFullMode: Boolean;
    constructor Create;
    function GetIsDemoMode: Boolean;
    function GetIsFullMode: Boolean;
    function GetApplicationCode: string;
    function GetActivationKey: string;
    function GetActivationUserName: string;
    procedure CheckActivationStatus;
    function GetCanUseFreeActivation: Boolean;
  public
    class function Instance: TActivationManager;
    destructor Destroy; override;
    function SaveActivateKey(Name, Key: string; RegisterForAllUsers: Boolean): Boolean;
    procedure CheckActivationCode(ApplicationCode, ActivationCode: string; out DemoMode: Boolean; out FullMode: Boolean);
    function GenerateProgramCode(HardwareString: string): string;
    function ReadActivationOption(OptionName: string): string;
    property IsDemoMode: Boolean read GetIsDemoMode;
    property IsFullMode: Boolean read GetIsFullMode;
    property ApplicationCode: string read GetApplicationCode;
    property ActivationKey: string read GetActivationKey;
    property ActivationUserName: string read GetActivationUserName;
    property CanUseFreeActivation: Boolean read GetCanUseFreeActivation;
  end;

function GenerateActivationKey(ApplicationCode: string; FullVersion: Boolean): string;

implementation

var
  ActivationManager : TActivationManager = nil;

function RegistrationRoot : string;
begin
  Result := RegRoot + 'Activation';
end;

(*procedure GetPeripheralDiskIdentifiers(List: TStrings);
var
  Reg: TRegistry;
  DiskList,
  AdapterList,
  ControllerList: TStrings;
  I, J, K: Integer;
const
  HARDWARE_ROOT = 'HARDWARE\DESCRIPTION\System\MultifunctionAdapter';
begin
  List.Clear;
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey(HARDWARE_ROOT, False) then
    begin
      AdapterList := TStringList.Create;
      ControllerList := TStringList.Create;
      DiskList := TStringList.Create;
      try
        Reg.GetKeyNames(AdapterList);
        for I := 0 to AdapterList.Count - 1 do
        begin
          Reg.CloseKey;
          if Reg.OpenKey(HARDWARE_ROOT + '\' + AdapterList[I] + '\DiskController', False) then
          begin
            Reg.GetKeyNames(ControllerList);

            for J := 0 to ControllerList.Count - 1 do
            begin
              Reg.CloseKey;
              if Reg.OpenKey(HARDWARE_ROOT + '\' + AdapterList[I] + '\DiskController\' + ControllerList[J] + '\DiskPeripheral', False) then
              begin
                Reg.GetKeyNames(DiskList);
                for K := 0 to DiskList.Count - 1 do
                begin
                  Reg.CloseKey;
                  if Reg.OpenKey(HARDWARE_ROOT + '\' + AdapterList[I] + '\DiskController\' + ControllerList[J] + '\DiskPeripheral\' + DiskList[K], False) then
                  begin
                    if Reg.ValueExists('Identifier') then
                      List.Add(Reg.ReadString('Identifier'));
                  end;
                end;
              end;
            end;
         end;
        end;
      finally
        F(AdapterList);
        F(ControllerList);
        F(DiskList);
      end;
    end;
  finally
    F(Reg);
  end;
end;*)

function FindVolumeSerial(const Drive : string) : string;
var
   VolumeSerialNumber : DWORD;
   MaximumComponentLength : DWORD;
   FileSystemFlags : DWORD;
   SerialNumber : string;
begin
   Result:='';

   GetVolumeInformation(
        PChar(Drive),
        nil,
        0,
        @VolumeSerialNumber,
        MaximumComponentLength,
        FileSystemFlags,
        nil,
        0);

   SerialNumber :=
         IntToHex(HiWord(VolumeSerialNumber), 4) +
         ' - ' +
         IntToHex(LoWord(VolumeSerialNumber), 4) ;
   Result := SerialNumber;
end; (*FindVolumeSerial*)

function GetProcStringID: string;
var
  LpSystemInfo: TSystemInfo;
begin
  GetSystemInfo(LpSystemInfo);
  Result := IntToStr(LpSystemInfo.DwProcessorType) + IntToStr(LpSystemInfo.wProcessorLevel) + IntToStr(LpSystemInfo.wProcessorRevision);
end;

function GetSystemHardwareString: string;
begin
  Result := FindVolumeSerial(Copy(ParamStr(0), 1, Length('c:\')));
  Result := Result + GetProcStringID;
end;

function GenerateActivationKey(ApplicationCode: string; FullVersion: Boolean): string;
var
  I: Integer;
  SSS: string;
  Ar: array [1 .. 16] of Integer;
begin
  Result := '';
  for I := 1 to 8 do
  begin
    SSS := IntToHex(Abs(Round(Cos(Ord(ApplicationCode[I]) + 100 * I + 0.34) * 16)), 8);
    ApplicationCode[I] := SSS[8];
  end;
  for I := 1 to 16 do
    Ar[I] := 0;
  for I := 1 to 8 do
    Ar[(I - 1) * 2 + 1] := HexCharToInt(ApplicationCode[I]);

  if not FullVersion then
    Ar[2] := 15 - Ar[1]
  else
    Ar[2] := (Ar[1] + Ar[3] * Ar[7] * Ar[15]) mod 15;

  if not FullVersion and (Ar[2] = (Ar[1] + Ar[3] * Ar[7] * Ar[15]) mod 15) then
    Ar[2] := (Ar[2] + 1) mod 15;

  Ar[4] := Ar[2] * (Ar[3] + 1) * 123 mod 15;
  Ar[6] := Round(Sqrt(Ar[5]) * 100) mod 15;
  Ar[8] := (Ar[4] + Ar[6]) * 17 mod 15;
  Randomize;
  Ar[10] := Random(16);
  Ar[12] := Ar[10] * Ar[10] * Ar[10] mod 15;
  Ar[14] := Ar[7] * Ar[9] mod 15;
  Ar[16] := 0;
  for I := 1 to 15 do
    Ar[16] := Ar[16] + Ar[I];
  Ar[16] := Ar[16] mod 15;
  for I := 1 to 16 do
    Result := Result + IntToHexChar(Ar[I]);
end;

{ TActivationManager }

function TActivationManager.ReadActivationOption(OptionName: string): string;
var
  Reg: TRegistry;
  AppKey, ActCode: string;
  IsDemo, IsFull: Boolean;
  I : Integer;
const
  ActivetionModes: array [0 .. 1] of DWORD = (HKEY_CURRENT_USER, HKEY_LOCAL_MACHINE);
begin
  AppKey := ApplicationCode;
  IsDemo := True;
  IsFull := False;
  Result := '';
  for I := 0 to Length(ActivetionModes) - 1 do
  begin
    Reg := TRegistry.Create;
    Reg.RootKey := ActivetionModes[I];
    try
      if Reg.OpenKey(RegistrationRoot, True) then
      begin
        if Reg.ValueExists(RegistrationCode) and Reg.ValueExists(OptionName) then
        begin
          ActCode := Reg.ReadString(RegistrationCode);
          CheckActivationCode(AppKey, ActCode, IsDemo, IsFull);
          if not IsDemo then
            Result := Reg.ReadString(OptionName);

          if (Result <> '') and IsFull then
            Exit;
        end;
      end;
      Reg.CloseKey;
    finally
      F(Reg);
    end;
  end;
end;

procedure TActivationManager.CheckActivationCode(ApplicationCode,
  ActivationCode: string; out DemoMode, FullMode: Boolean);
var
  I, Sum: Integer;
  Str, ActCode, S: string;
begin
  DemoMode := True;
  FullMode := False;

  if FolderView then
    Exit;

  S := ApplicationCode;
  ActCode := ActivationCode;
  if Length(ActCode) < 16 then
    ActCode := '0000000000000000';
  for I := 1 to 8 do
  begin
    Str := Inttohex(Abs(Round(Cos(Ord(S[I]) + 100 * I + 0.34) * 16)), 8);
    if ActCode[(I - 1) * 2 + 1] <> Str[8] then
      Exit;
  end;

  Sum := 0;
  for I := 1 to 15 do
    Sum := Sum + HexCharToInt(ActCode[I]);
  if IntToHexChar(Sum mod 15) <> ActCode[16] then
    Exit;

  //2 checks passed, program works not in demo mode!
  DemoMode := False;
  //check full version
  FullMode := HexCharToInt(ActCode[2]) = (HexCharToInt(ActCode[1]) + (HexCharToInt(ActCode[3]) * HexCharToInt(ActCode[7]) * HexCharToInt(ActCode[15]))) mod 15;
end;

procedure TActivationManager.CheckActivationStatus;
begin
  if FRegistrationLoaded then
    Exit;

  CheckActivationCode(ApplicationCode, ActivationKey, FIsDemoMode, FIsFullMode);
  FRegistrationLoaded := True;
end;

constructor TActivationManager.Create;
begin
  FSync := TCriticalSection.Create;
  FRegistrationLoaded := False;
end;

destructor TActivationManager.Destroy;
begin
  F(FSync);
  inherited;
end;

function TActivationManager.GenerateProgramCode(HardwareString: string): string;
var
  S, Code: string;
  N: Cardinal;
begin
  S := HardwareString;
  CalcStringCRC32(S, N);
  N := N xor $6357A303; // v2.3
  S := IntToHex(N, 8);
  CalcStringCRC32(S, N);
  N := N xor $162C90CA; // v2.3
  Code := S + Inttohex(N, 8);
  Result := Code;
end;

function TActivationManager.GetActivationKey: string;
begin
  Result := ReadActivationOption(RegistrationCode);
end;

function TActivationManager.GetActivationUserName: string;
begin
  Result := ReadActivationOption(RegistrationUserName);
end;

function TActivationManager.GetApplicationCode: string;
begin
  Result := GenerateProgramCode(GetSystemHardwareString);
end;

function TActivationManager.GetCanUseFreeActivation: Boolean;
begin
  Result := TTranslateManager.Instance.Language = 'RU';
end;

function TActivationManager.GetIsDemoMode: Boolean;
begin
  CheckActivationStatus;
  Result := (FIsDemoMode and CanUseFreeActivation)
            or (not IsFullMode and not CanUseFreeActivation);
  Result := Result or FolderView;
end;

function TActivationManager.GetIsFullMode: Boolean;
begin
  Result := FIsFullMode;
end;

class function TActivationManager.Instance: TActivationManager;
begin
  if ActivationManager = nil then
    ActivationManager := TActivationManager.Create;

  Result := ActivationManager;
end;

function TActivationManager.SaveActivateKey(Name, Key: string;
  RegisterForAllUsers: Boolean): Boolean;
var
  Reg: TRegistry;
begin
  Result := False;

  Reg := TRegistry.Create;

  if RegisterForAllUsers then
    Reg.RootKey := Windows.HKEY_LOCAL_MACHINE
  else
    Reg.RootKey := Windows.HKEY_CURRENT_USER;
  try
    if Reg.OpenKey(RegistrationRoot, True) then
    begin
      Reg.WriteString(RegistrationCode, Key);
      Reg.WriteString(RegistrationUserName, Name);
      Reg.CloseKey;
      FRegistrationLoaded := False;
      Result := True;
    end;
  finally
    F(Reg);
  end;
end;

initialization

finalization

  F(ActivationManager);

end.
