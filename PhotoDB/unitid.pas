unit unitid;

interface

uses
  UnitLoadFilesToPanel, Dolphin_DB, Windows, Messages, SysUtils, Classes,
  Graphics, Controls, Forms, Dialogs, UnitDBDeclare, UnitDBCommon,
  UnitFileExistsThread;

type
  TIDForm = class(TForm)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  IDForm: TIDForm;
	
implementation

uses UnitFormCont, Searching, SlideShow, ExplorerUnit, UnitGetPhotosForm;

{$R *.dfm}

end.
