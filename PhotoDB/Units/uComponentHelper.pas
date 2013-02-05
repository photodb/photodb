unit uComponentHelper;

interface

uses
  Generics.Collections,
  System.Classes;

type
  TComponentRewrite = class(TPersistent, IInterface, IInterfaceComponentReference)
  private
    [Weak] FOwner: TComponent;
    FName: TComponentName;
    FTag: NativeInt;
    FComponents: TList<TComponent>;
    FFreeNotifies: TList<TComponent>;
    FDesignInfo: Longint;
    FComponentState: TComponentState;
    { IInterfaceComponentReference }
    function IInterfaceComponentReference.GetComponent = IntfGetComponent;
    function IntfGetComponent: TComponent;
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    { IDispatch }
    function GetTypeInfoCount(out Count: Integer): HResult; stdcall;
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult; stdcall;
    function GetIDsOfNames(const IID: TGUID; Names: Pointer;
      NameCount, LocaleID: Integer; DispIDs: Pointer): HResult; stdcall;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
      Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult; stdcall;
  end;

  TComponenrHelper = class helper for TComponent
  public
    procedure SetReadingState;
    procedure SetLoadingState;
  end;

implementation

{ TComponenrHelper }

procedure TComponenrHelper.SetLoadingState;
begin
  Include(TComponentRewrite(Self).FComponentState, csLoading);
end;

procedure TComponenrHelper.SetReadingState;
begin
  Include(TComponentRewrite(Self).FComponentState, csReading);
end;

{ TComponentRewrite }

function TComponentRewrite.GetIDsOfNames(const IID: TGUID; Names: Pointer;
  NameCount, LocaleID: Integer; DispIDs: Pointer): HResult;
begin

end;

function TComponentRewrite.GetTypeInfo(Index, LocaleID: Integer;
  out TypeInfo): HResult;
begin

end;

function TComponentRewrite.GetTypeInfoCount(out Count: Integer): HResult;
begin

end;

function TComponentRewrite.IntfGetComponent: TComponent;
begin

end;

function TComponentRewrite.Invoke(DispID: Integer; const IID: TGUID;
  LocaleID: Integer; Flags: Word; var Params; VarResult, ExcepInfo,
  ArgErr: Pointer): HResult;
begin

end;

function TComponentRewrite.QueryInterface(const IID: TGUID; out Obj): HResult;
begin

end;

function TComponentRewrite._AddRef: Integer;
begin

end;

function TComponentRewrite._Release: Integer;
begin

end;

end.
