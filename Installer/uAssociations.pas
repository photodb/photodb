unit uAssociations;

interface

uses
  Windows, Classes, StdCtrls, uMemory, SysUtils, Registry, uShellUtils,
  uTranslate, StrUtils;

type
  TAssociation = class(TObject)

  end;

  TAssociationState = (TAS_IGNORE, TAS_ADD_HANDLER, TAS_DEFAULT);

  TFileAssociation = class(TAssociation)
  public
    Extension : string;
    ExeParams : string;
    State : TAssociationState;
  end;

  TInstallAssociationCallBack = procedure(Total, Count : Integer; var Terminate : Boolean) of object;

  TFileAssociations = class(TObject)
  private
    FAssociations : TList;
    constructor Create;
    procedure AddFileExtension(Extension : string); overload;
    procedure AddFileExtension(Extension, ExeParams : string); overload;
    procedure FillList;
    function GetAssociations(Index: Integer): TFileAssociation;
    function GetCount: Integer;
    function GetAssociationByExt(Ext : string): TFileAssociation;
  public
    class function Instance : TFileAssociations;
    destructor Destroy; override;
    function GetCurrentAssociationState(Extension : string) : TAssociationState;
    property Associations[Index : Integer] : TFileAssociation read GetAssociations; default;
    property Exts[Ext : string] : TFileAssociation read GetAssociationByExt;
    property Count : Integer read GetCount;
  end;

const
  EXT_ASSOCIATION_PREFIX = 'PhotoDB';
  ASSOCIATION_PREVIOUS = 'PhotoDB_PreviousAssociation';
  ASSOCIATION_ADD_HANDLER_COMMAND = 'PhotoDBView';

function FileRegisteredOnInstalledApplication(Value: string): Boolean;
function InstallGraphicFileAssociations(FileName: string; CallBack : TInstallAssociationCallBack): Boolean;
function AssociationStateToCheckboxState(AssociationState : TAssociationState) : TCheckBoxState;
function CheckboxStateToAssociationState(CheckBoxState : TCheckBoxState) : TAssociationState;

implementation

var
  FInstance : TFileAssociations = nil;

function AssociationStateToCheckboxState(AssociationState : TAssociationState) : TCheckBoxState;
begin
  case AssociationState of
    TAS_IGNORE:
      Result := cbUnchecked;
    TAS_ADD_HANDLER:
      Result := cbGrayed;
    TAS_DEFAULT:
      Result := cbChecked;
    else
      raise Exception.Create('Invalid AssociationState');
  end;
end;

function CheckboxStateToAssociationState(CheckBoxState : TCheckBoxState) : TAssociationState;
begin
  case CheckBoxState of
    cbUnchecked:
      Result := TAS_IGNORE;
    cbGrayed:
      Result := TAS_ADD_HANDLER;
    cbChecked:
      Result := TAS_DEFAULT;
    else
      raise Exception.Create('Invalid CheckBoxState');
  end;
end;

function FileRegisteredOnInstalledApplication(Value: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Length(Value) downto 2 do
    if (Value[I - 1] = '%') and (Value[I] = '1') then
    begin
      Delete(Value, I - 1, 2);
    end;
  for I := Length(Value) downto 1 do
    if Value[I] = '"' then
      Delete(Value, I, 1);

  Value := Trim(Value);
  if AnsiLowerCase(Value) = AnsiLowerCase(InstalledFileName) then
    Result := True;
end;

function InstallGraphicFileAssociations(FileName: string; CallBack : TInstallAssociationCallBack): Boolean;
var
  Reg: TRegistry;
  I: Integer;
  S, Ext, ExtensionHandler, PreviousHandler: string;
  B, C: Boolean;
  Terminate : Boolean;

  procedure UnregisterPhotoDBAssociation(Ext : string);
  var
    Reg: TRegistry;
    ShellPath : string;
  begin   
    Reg := TRegistry.Create;
    try
      Reg.RootKey := Windows.HKEY_CURRENT_USER;
      Reg.DeleteKey('Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\' + Ext);
      Reg.RootKey := Windows.HKEY_LOCAL_MACHINE;
      Reg.DeleteKey('Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\' + Ext);
    finally
      Reg.Free;
    end;
     
    Reg := TRegistry.Create;
    try
      Reg.RootKey := Windows.HKEY_CLASSES_ROOT;
      Reg.OpenKey('\' + Ext, True);
      ExtensionHandler := Reg.ReadString('');
      PreviousHandler := Reg.ReadString(ASSOCIATION_PREVIOUS);
      Reg.CloseKey;

      if ExtensionHandler <> '' then
      begin
        ShellPath := '\' + ExtensionHandler + '\Shell\';
        //unregister view menu item
        if Reg.KeyExists(ShellPath + ASSOCIATION_ADD_HANDLER_COMMAND + '\Command') then
          Reg.DeleteKey(ShellPath + ASSOCIATION_ADD_HANDLER_COMMAND + '\Command');
        if Reg.KeyExists(ShellPath + ASSOCIATION_ADD_HANDLER_COMMAND) then
          Reg.DeleteKey(ShellPath + ASSOCIATION_ADD_HANDLER_COMMAND);  

        if StartsText(AnsiLowerCase(EXT_ASSOCIATION_PREFIX) + '.', AnsiLowerCase(ExtensionHandler)) then
        begin
          //if open with photodb then delete default association
          if Reg.KeyExists(ShellPath + 'Open\Command') then
            Reg.DeleteKey(ShellPath + 'Open\Command');
          if Reg.KeyExists(ShellPath + 'Open') then
            Reg.DeleteKey(ShellPath + 'Open');
        end;
      end;

      Reg.OpenKey('\' + Ext, True);
      if not StartsText(AnsiLowerCase(EXT_ASSOCIATION_PREFIX) + '.', AnsiLowerCase(PreviousHandler)) then
        Reg.WriteString('', PreviousHandler)
      else
        Reg.WriteString('', '');   
      Reg.CloseKey;
    finally
      F(Reg);
    end;
  end;

begin
  Terminate := False;

  Reg := TRegistry.Create;
  try
    Reg.RootKey := Windows.HKEY_CLASSES_ROOT;
    for I := 0 to TFileAssociations.Instance.Count - 1 do
    begin
      if Assigned(CallBack) then
        CallBack(TFileAssociations.Instance.Count, I, Terminate);

      if Terminate then
        Break;
      Ext := TFileAssociations.Instance[I].Extension;

      UnregisterPhotoDBAssociation(Ext);

      case TFileAssociations.Instance[I].State of
        TAS_DEFAULT:
          begin
            Reg.OpenKey('\' + Ext, True);
            S := Reg.ReadString('');
            Reg.CloseKey;
            B := False;
            if S = '' then
              B := True;
            if not B then
            begin
              Reg.OpenKey('\' + S + '\Shell\Open\Command', False);
              B := Reg.ReadString('') = '';
              Reg.CloseKey;
            end;
            if B then
            begin
              Reg.OpenKey('\' + Ext, True);
              Reg.WriteString('', 'PhotoDB' + Ext);
              Reg.CloseKey;
              Reg.OpenKey('\PhotoDB' + Ext + '\Shell\Open\Command', True);
              Reg.WriteString('', Format('"%s" "%%1"', [FileName]));
              Reg.CloseKey;
              Reg.OpenKey('\PhotoDB' + Ext + '\DefaultIcon', True);
              Reg.WriteString('', Filename + ',0');
              Reg.CloseKey;
            end else
            begin
              Reg.OpenKey('\' + Ext, True);
              S := Reg.ReadString('');
              Reg.WriteString('PhotoDB_PreviousAssociation', S);
              Reg.WriteString('', 'PhotoDB' + Ext);
              Reg.CloseKey;
              Reg.OpenKey('\PhotoDB' + Ext + '\Shell\Open\Command', True);
              Reg.WriteString('', Format('"%s" "%%1"', [Filename]));
              Reg.CloseKey;
              Reg.OpenKey('\PhotoDB' + Ext + '\DefaultIcon', True);
              Reg.WriteString('', Filename + ',0');
              Reg.CloseKey;
            end;
          end;
        TAS_ADD_HANDLER:
          begin
            Reg.OpenKey('\' + Ext, True);
            S := Reg.ReadString('');
            Reg.CloseKey;
            C := False;
            B := True;
            if S = '' then
              C := True;
            if not C then
            begin
              Reg.OpenKey('\' + S + '\Shell\Open\Command', False);
              B :=  Reg.ReadString('') = '';
              Reg.CloseKey;
            end;
            if B then
            begin
              Reg.OpenKey('\' + Ext, True);
              Reg.WriteString('', 'PhotoDB' + Ext);
              Reg.CloseKey;
            end;
            if B then
              Reg.OpenKey('\PhotoDB' + Ext + '\Shell\PhotoDBView', True)
            else
              Reg.OpenKey('\' + S + '\Shell\PhotoDBView', True);
            Reg.WriteString('', TA('View with PhotoDB', 'System'));
            Reg.CloseKey;
            if B then
              Reg.OpenKey('\PhotoDB' + Ext + '\Shell\PhotoDBView\Command', True)
            else
              Reg.OpenKey('\' + S + '\Shell\PhotoDBView\Command', True);
            Reg.WriteString('', Format('"%s" "%%1"', [Filename]));
            if B then
            begin
              Reg.OpenKey('\PhotoDB' + Ext + '\DefaultIcon', True);
              Reg.WriteString('', Filename + ',0');
            end;
            Reg.CloseKey;
          end;
      end;
    end;
  finally
    F(Reg);
  end;
  Result := True;
end;

{ TFileAssociations }

class function TFileAssociations.Instance: TFileAssociations;
begin
  if FInstance = nil then
    FInstance := TFileAssociations.Create;

  Result := FInstance;
end;

procedure TFileAssociations.AddFileExtension(Extension, ExeParams: string);
var
  Ext : TFileAssociation;
begin
  Ext := TFileAssociation.Create;
  Ext.Extension := Extension;
  Ext.ExeParams := ExeParams;
  FAssociations.Add(Ext);
end;

procedure TFileAssociations.AddFileExtension(Extension: string);
begin
  AddFileExtension(Extension, '');
end;

constructor TFileAssociations.Create;
begin
  FAssociations := TList.Create;
  FillList;
end;

destructor TFileAssociations.Destroy;
begin
  FreeList(FAssociations);
  inherited;
end;

procedure TFileAssociations.FillList;
begin
  AddFileExtension('.jfif');
  AddFileExtension('.jpg');
  AddFileExtension('.jpe');
  AddFileExtension('.jpeg');
  AddFileExtension('.tiff');
  AddFileExtension('.tif');
  AddFileExtension('.psd');
  AddFileExtension('.gif');
  AddFileExtension('.png');
  AddFileExtension('.bmp');
  AddFileExtension('.thm');

  AddFileExtension('.crw');
  AddFileExtension('.cr2');
  AddFileExtension('.nef');
  AddFileExtension('.raf');
  AddFileExtension('.dng');
  AddFileExtension('.mos');
  AddFileExtension('.kdc');
  AddFileExtension('.dcr');

  AddFileExtension('.pic');
  AddFileExtension('.pdd');
  AddFileExtension('.ppm');
  AddFileExtension('.pgm');
  AddFileExtension('.pbm');
  AddFileExtension('.fax');
  AddFileExtension('.rle');
  AddFileExtension('.rla');
  AddFileExtension('.tga');
  AddFileExtension('.dib');
  AddFileExtension('.win');
  AddFileExtension('.vst');
  AddFileExtension('.vda');
  AddFileExtension('.icb');
  AddFileExtension('.eps');
  AddFileExtension('.pcc');
  AddFileExtension('.pcx');
  AddFileExtension('.rpf');
  AddFileExtension('.sgi');
  AddFileExtension('.rgba');
  AddFileExtension('.rgb');
  AddFileExtension('.bw');
  AddFileExtension('.cel');
  AddFileExtension('.pcd');
  AddFileExtension('.psp');
  AddFileExtension('.cut');
end;

function TFileAssociations.GetAssociationByExt(
  Ext : string): TFileAssociation;
var
  I : Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    if Self[I].Extension = Ext then
    begin
      Result := Self[I];
      Exit;
    end;
  end;

  if Result = nil then
    raise Exception.Create('Can''t find association for ' + Ext);
end;

function TFileAssociations.GetAssociations(Index: Integer): TFileAssociation;
begin
  Result := FAssociations[Index];
end;

function TFileAssociations.GetCount: Integer;
begin
  Result := FAssociations.Count;
end;

function TFileAssociations.GetCurrentAssociationState(
  Extension: string): TAssociationState;
var
  Reg: TRegistry;
  S : string;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := Windows.HKEY_CLASSES_ROOT;

    Reg.OpenKey('\' + Extension, False);
    S := Reg.ReadString('');
    Reg.CloseKey;
    Reg.OpenKey('\' + S + '\shell\open\command', False);
    S := Reg.ReadString('');
    if S = '' then
      Result := TAS_DEFAULT
    else
    begin
      if FileRegisteredOnInstalledApplication(S) then
        Result := TAS_DEFAULT
      else
        Result := TAS_ADD_HANDLER;
    end;
    Reg.CloseKey;
  finally
    F(Reg);
  end;
end;

initialization

finalization

  F(FInstance);

end.
