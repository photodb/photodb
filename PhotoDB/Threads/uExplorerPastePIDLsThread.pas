unit uExplorerPastePIDLsThread;

interface

uses
  Windows,
  System.Classes,
  uDBForm,
  uConstants,
  uPortableDeviceUtils,
  uShellNamespaceUtils,
  uDBThread;

type
  TExplorerPastePIDLsThread = class(TDBThread)
  private
    { Private declarations }
    FPath: string;
    Handle: HWND;
  protected
    procedure Execute; override;
  public
    constructor Create(OwnerForm: TDBForm; ToDirectory: string);
  end;

implementation

{ TExplorerPastePIDLsThread }

constructor TExplorerPastePIDLsThread.Create(OwnerForm: TDBForm;
  ToDirectory: string);
begin
  inherited Create(OwnerForm, False);
  FPath := ToDirectory;
  Handle := OwnerForm.Handle;
end;

procedure TExplorerPastePIDLsThread.Execute;
begin
  FreeOnTerminate := True;

  if IsDevicePath(FPath) then
  begin
    Delete(FPath, 1, Length(cDevicesPath) + 1);
    ExecuteShellPathRelativeToMyComputerMenuAction(Handle, FPath, nil, 'Paste');
  end else
    PastePIDListToFolder(Handle, FPath);
end;

end.
