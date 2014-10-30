unit Dmitry.Controls.SaveWindowPos;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Win.Registry,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs;

type
  TRootKeys = (HKEY_CLASSES_ROOT, HKEY_CURRENT_USER, HKEY_LOCAL_MACHINE, HKEY_USERS , HKEY_PERFORMANCE_DATA, HKEY_CURRENT_CONFIG, HKEY_DYN_DATA);

type
  TSaveWindowPos = class(TComponent)
  private
    { Private declarations }
    FWindowState: TWindowState;
    FReg: TRegistry;
    FRegname: string;
    FTop_: Integer;
    FLeft_: Integer;
    FWidth_: Integer;
    FHeight_: Integer;
    FOnlyPos: Boolean;
    FRootKey: TRootKeys;
    FRegRootKey: HKEY;
    Fkey: string;
    FEnabled: Boolean;
    procedure SetOnlyPos(const Value: Boolean);
    procedure SetRootKey(const Value: TRootKeys);
    procedure Setkey(const Value: string);
    procedure SetEnabled(const Value: Boolean);
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: Tcomponent); override;
    destructor Destroy; override;
    procedure Minset(Sender: TObject);
  published
    { Published declarations }
    procedure SavePosition;
    function SetPosition(SetOnlySize: Boolean = False; SetDefaultIfEmpty: Boolean = True): Boolean;
    property SetOnlyPosition: Boolean read FOnlyPos write SetOnlyPos;
    property RootKey: TRootKeys read FRootKey write SetRootKey;
    property Key: string read Fkey write Setkey;
    property Enabled: Boolean read FEnabled write SetEnabled default True;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Dm', [TSaveWindowPos]);
end;

{ TSaveWiddowPos }

constructor TSaveWindowPos.create(AOwner: Tcomponent);
begin
  inherited;
  FRegname := 'Noname';
  FEnabled := True;
  FKey := 'Software\Positions\' + FRegName;
  FRootKey := HKEY_CURRENT_USER;
end;

destructor TSaveWindowPos.destroy;
begin
  inherited;
end;

procedure TSaveWindowPos.minset(Sender: TObject);
begin
  with Owner as Tform do
  begin
    if (WindowState = WsMaximized) then
    begin
      Ftop_ := Top;
      FLeft_ := Left;
      FWidth_ := Width;
      FHeight_ := Height;
    end;
  end;
end;

procedure TSaveWindowPos.SetOnlyPos(const Value: Boolean);
begin
  FOnlyPos := Value;
end;

procedure TSaveWindowPos.SetRootKey(const Value: TRootKeys);
begin
  FRootKey := Value;
  case FRootKey of
    HKEY_CLASSES_ROOT:
      FRegRootKey := Winapi.Windows.HKEY_CLASSES_ROOT;
    HKEY_CURRENT_USER:
      FRegRootKey := Winapi.Windows.HKEY_CURRENT_USER;
    HKEY_LOCAL_MACHINE:
      FRegrootKey := Winapi.Windows.HKEY_LOCAL_MACHINE;
    HKEY_USERS:
      FRegRootKey := Winapi.Windows.HKEY_USERS;
    HKEY_PERFORMANCE_DATA:
      FRegRootKey := Winapi.Windows.HKEY_PERFORMANCE_DATA;
    HKEY_CURRENT_CONFIG:
      FRegRootKey := Winapi.Windows.HKEY_CURRENT_CONFIG;
    HKEY_DYN_DATA:
      FRegRootKey := Winapi.Windows.HKEY_DYN_DATA;
  end;
end;

procedure TSaveWindowPos.Setkey(const Value: string);
begin
  Fkey := Value;
  if Fkey = '' then
    FKey := 'Software\Positions\' + Fregname;
end;

procedure TSaveWindowPos.SetEnabled(const Value: Boolean);
begin
  FEnabled := Value;
end;

function TSaveWindowPos.SetPosition(SetOnlySize: Boolean = False; SetDefaultIfEmpty: Boolean = True): Boolean;
var
  HasPositionInfo: Boolean;
begin
  if FEnabled then
  begin
    FReg := TRegistry.Create;
    try
      FReg.RootKey := FRegRootKey;
      FReg.OpenKey(Fkey, True);

      HasPositionInfo := FReg.ValueExists('Top') and FReg.ValueExists('Left');
      if not HasPositionInfo and not SetDefaultIfEmpty then
        Exit(False);

      if not SetOnlySize then
      begin
        FTop_ := StrToIntDef(FReg.ReadString('Top'), Screen.Height div 2 - (Owner as TForm).Height div 2);
        FLeft_ := StrToIntDef(FReg.ReadString('Left'), Screen.Width div 2 - (Owner as TForm).Width div 2);
      end;
      FWidth_ := StrToIntDef(FReg.ReadString('Width'), (Owner as TForm).Width);
      FHeight_ := StrToIntDef(FReg.ReadString('Height'), (Owner as TForm).Height);
      if FReg.ReadString('Position') = 'Maximized' then
        FWindowState := wsMaximized
      else
        FWindowState := wsNormal;
      FReg.Closekey;
    finally
      FReg.Free;
    end;
    with Owner as TForm do
    begin
      Top := Ftop_;
      Left := FLeft_;
      if not FOnlyPos then
      begin
        Width := FWidth_;
        Height := FHeight_;
        WindowState := FWindowState;
      end;
    end;
  end;
  Result := True;
end;

procedure TSaveWindowPos.SavePosition;
begin
  if FEnabled then
  begin
    with Owner as TForm do
    begin
      if not(WindowState = wsMaximized) then
      begin
        Ftop_ := Top;
        FLeft_ := Left;
        FWidth_ := Width;
        FHeight_ := Height;
      end;
      FWindowState := WindowState;
    end;
    FReg := TRegistry.Create;
    try
      FReg.RootKey := FRegRootKey;
      FReg.OpenKey(Fkey, True);
      if not((Owner as TForm).WindowState = wsMaximized) then
      begin
        FReg.WriteString('Top', IntToStr(Ftop_));
        FReg.WriteString('Left', IntToStr(FLeft_));
        FReg.WriteString('Width', IntToStr(FWidth_));
        FReg.WriteString('Height', IntToStr(FHeight_));
      end;
      if FwindowState = wsMaximized then
        FReg.WriteString('Position', 'Maximized');
      if FwindowState = wsNormal then
        FReg.WriteString('Position', 'Normal');
      if FwindowState = WsMinimized then
        FReg.WriteString('Position', 'Minimized');
      FReg.Closekey;
    finally
      FReg.Free;
    end;
  end;
end;

end.
