unit CleaningForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DmProgress;

type
  TCleaningForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    DmProgress1: TDmProgress;
    DmProgress2: TDmProgress;
    CheckBox1: TCheckBox;
//    DmProgress1: TDmProgress;
//    DmProgress2: TDmProgress;
//    Button1: TButton;
//    Button2: TButton;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private

    { Private declarations }
  public
    { Public declarations }
  end;

var
  CleaningForm1: TCleaningForm1;

implementation

uses EmptyDeletedThreadUnit, UnitCleanUpThread;

{$R *.dfm}

procedure TCleaningForm1.Button2Click(Sender: TObject);
begin
EmptyDeletedThread.create(false);
end;

procedure TCleaningForm1.Button1Click(Sender: TObject);
begin
CleanUpThread.create(false);
end;

end.
