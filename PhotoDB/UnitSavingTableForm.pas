unit UnitSavingTableForm;

interface

uses
  DBtables, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DmProgress, DB, Dolphin_DB, UnitDBDeclare;

type
  TSavingTableForm = class(TForm)
    DmProgress1: TDmProgress;
    Label1: TLabel;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
  FTerminating : Boolean;
  Procedure LoadLanguage;
  Procedure Execute(Query : TDataSet; FileName : String; SubFolders : boolean; FileList : TArStrings);
  Procedure SetMaxValue(Value : Integer);
  Procedure SetProgress(value : Integer);
  Procedure SetText(Value : String);
    { Public declarations }
  end;

Procedure SaveQuery(Query : TDataSet; FileName : String; SubFolders : boolean; FileList : TArStrings);

implementation

uses Language, UnitSaveQueryThread;

{$R *.dfm}

Procedure SaveQuery(Query : TDataSet; FileName : String; SubFolders : boolean; FileList : TArStrings);
var
  SavingTableForm: TSavingTableForm;
begin
 if not DBkernel.UserRights.FileOperationsCritical then exit;
 Application.CreateForm(TSavingTableForm,SavingTableForm);
 SavingTableForm.Execute(Query,FileName,SubFolders,FileList);
 SavingTableForm.Release;
 if UseFreeAfterRelease then SavingTableForm.Free;
end;

Procedure TSavingTableForm.Execute(Query : TDataSet; FileName : String; SubFolders : boolean; FileList : TArStrings);
begin
 TSaveQueryThread.Create(False,Query,FileName,Self,SubFolders,FileList);
 ShowModal;
end;

Procedure TSavingTableForm.LoadLanguage;
begin
 DmProgress1.Text:=TEXT_MES_PROGRESS_PR;
 Button1.Caption:=TEXT_MES_ABORT;
 Label1.Caption:=TEXT_MES_SAVING_IN_PROGRESS;
 Caption:=TEXT_MES_SAVING_DATASET_CAPTION;
end;

procedure TSavingTableForm.FormCreate(Sender: TObject);
begin
 LoadLanguage;
 FTerminating:=false;
 DBkernel.RecreateThemeToForm(Self);
end;

procedure TSavingTableForm.SetMaxValue(Value: Integer);
begin
 DmProgress1.MinValue:=value;
end;

procedure TSavingTableForm.SetText(Value: String);
begin
 DmProgress1.Text:=Value;
end;

procedure TSavingTableForm.SetProgress(value: Integer);
begin
 DmProgress1.Position:=value;
end;

procedure TSavingTableForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
 CanClose:=False;
end;

procedure TSavingTableForm.Button1Click(Sender: TObject);
begin
 FTerminating:=True;
end;

end.
