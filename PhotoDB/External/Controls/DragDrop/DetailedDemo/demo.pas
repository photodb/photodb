unit demo;

// -----------------------------------------------------------------------------
// Project:         Drag and Drop Component Suite
// Authors:         Angus Johnson,   ajohnson@rpi.net.au
//                  Anders Melander, anders@melander.dk
//                                   http://www.melander.dk
// Copyright        © 1997-99 Angus Johnson & Anders Melander
// -----------------------------------------------------------------------------
// You are free to use this source but please give us credit for our work.
// If you make improvements or derive new components from this code,
// we would very much like to see your improvements. FEEDBACK IS WELCOME.
// -----------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ShellApi;

type
  TFormDemo = class(TForm)
    Panel1: TPanel;
    ButtonText: TBitBtn;
    ButtonExit: TBitBtn;
    ButtonFile: TBitBtn;
    Label3: TLabel;
    Panel2: TPanel;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Panel3: TPanel;
    ButtonURL: TBitBtn;
    procedure ButtonTextClick(Sender: TObject);
    procedure ButtonFileClick(Sender: TObject);
    procedure ButtonExitClick(Sender: TObject);
    procedure Label6Click(Sender: TObject);
    procedure ButtonURLClick(Sender: TObject);
    procedure Label1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormDemo: TFormDemo;

implementation

{$R *.DFM}

uses
  DropText,
  DropFile,
  DropURL;


//******************* TFormDemo.ButtonTextClick *************************
procedure TFormDemo.ButtonTextClick(Sender: TObject);
begin
  with TFormText.Create(self) do
    try
      ShowModal;
    finally
      Free;
    end;
end;

//******************* TFormDemo.ButtonFileClick *************************
procedure TFormDemo.ButtonFileClick(Sender: TObject);
begin
  with TFormFile.Create(self) do
    try
      ShowModal;
    finally
      Free;
    end;
end;

//******************* TFormDemo.ButtonURLClick *************************
procedure TFormDemo.ButtonURLClick(Sender: TObject);
begin
  with TFormURL.Create(self) do
    try
      ShowModal;
    finally
      Free;
    end;
end;


//******************* TFormDemo.ButtonExitClick *************************
procedure TFormDemo.ButtonExitClick(Sender: TObject);
begin
  Close;
end;

//******************* TFormDemo.Label6Click *************************
procedure TFormDemo.Label6Click(Sender: TObject);
begin
  Label6.cursor := crAppStart;
  application.processmessages; {otherwise cursor change will be missed}
  ShellExecute(0, Nil, PChar('mailto:'+Label6.caption), Nil, Nil, SW_NORMAL);
  Label6.cursor := crHandPoint;
end;

//******************* TFormDemo.Label1Click *************************
procedure TFormDemo.Label1Click(Sender: TObject);
begin
  with TLabel(Sender) do
  begin
    cursor := crAppStart;
    application.processmessages; {otherwise cursor change will be missed}
    ShellExecute(0, Nil, PChar(caption), Nil, Nil, SW_NORMAL);
    cursor := crHandPoint;
  end;
end;

end.
