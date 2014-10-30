unit NoVSBListView;

interface

uses
  SysUtils, Classes, Controls, ComCtrls, Windows;

type
  TNoVSBListView1 = class(TListView)
  private
    { Private declarations }
  protected
     procedure CreateParams(VAR Params: TCreateParams); override;
    { Protected declarations }
  public
    { Public declarations }
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Dm', [TNoVSBListView1]);
end;

{ TNoVSBListView1 }

procedure TNoVSBListView1.CreateParams(var Params: TCreateParams);
begin
 Inherited CreateParams(Params);
 Params.WindowClass.style:= Params.WindowClass.style and not WS_VSCROLL;
 Params.style:= Params.style and not WS_VSCROLL;
end;

end.
 