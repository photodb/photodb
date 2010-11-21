unit uInstallFrame;

interface

uses
  Classes, Forms, uTranslate;

type
  TInstallFrame = class(TFrame)
  private
    FOnChange : TNotifyEvent;
  protected
    procedure FrameChanged;
  public
    function L(TextToTranslate : string) : string;
    procedure Init; virtual;
    procedure LoadLanguage; virtual;
    procedure InitInstall; virtual;
    function ValidateFrame : Boolean; virtual;
    property OnChange : TNotifyEvent read FOnChange write FOnChange;
  end;

  TInstallFrameClass = class of TInstallFrame;

implementation

{$R *.dfm}

{ TInstallFrame }

procedure TInstallFrame.FrameChanged;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TInstallFrame.Init;
begin
  FOnChange := nil;

  LoadLanguage;
end;

procedure TInstallFrame.InitInstall;
begin
 //
end;

function TInstallFrame.L(TextToTranslate: string): string;
begin
  Result := TTranslateManager.Instance.Translate(TextToTranslate, 'Setup');
end;

procedure TInstallFrame.LoadLanguage;
begin
  //TODO:
end;

function TInstallFrame.ValidateFrame: Boolean;
begin
  Result := False;
end;

end.
