unit UnitSavingTableForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DmProgress, DB, uDBBaseTypes, UnitDBDeclare,
  uDBForm;

type
  TSavingTableForm = class(TDBForm)
    DmProgress1: TDmProgress;
    Label1: TLabel;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    procedure LoadLanguage;
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    FTerminating: Boolean;
    procedure Execute(Query: TDataSet; FileName: String; SubFolders: Boolean;
      FileList: TArStrings);
    procedure SetMaxValue(Value: Integer);
    procedure SetProgress(Value: Integer);
    procedure SetText(Value: String);
  end;

procedure SaveQuery(Query: TDataSet; FileName: String; SubFolders: Boolean;
  FileList: TArStrings);

implementation

uses Language, UnitSaveQueryThread;

{$R *.dfm}

procedure SaveQuery(Query: TDataSet; FileName: String; SubFolders: Boolean;
  FileList: TArStrings);
var
  SavingTableForm: TSavingTableForm;
begin
  Application.CreateForm(TSavingTableForm, SavingTableForm);
  SavingTableForm.Execute(Query, FileName, SubFolders, FileList);
  SavingTableForm.Release;
end;

procedure TSavingTableForm.Execute(Query : TDataSet; FileName : String; SubFolders : boolean; FileList : TArStrings);
begin
 TSaveQueryThread.Create(False,Query,FileName,Self,SubFolders,FileList);
 ShowModal;
end;

procedure TSavingTableForm.LoadLanguage;
begin
  BeginTranslate;
  try
    DmProgress1.Text := L('Progress... (&amp;%%)');
    Button1.Caption := L('Abort');
    Label1.Caption := L('Saving in progress...');
    Caption := L('Saving items to file');
  finally
    EndTranslate;
  end;
end;

procedure TSavingTableForm.FormCreate(Sender: TObject);
begin
  LoadLanguage;
  FTerminating := False;
end;

function TSavingTableForm.GetFormID: string;
begin
  Result := 'SaveCollection'
end;

procedure TSavingTableForm.SetMaxValue(Value: Integer);
begin
  DmProgress1.MinValue := Value;
end;

procedure TSavingTableForm.SetText(Value: String);
begin
  DmProgress1.Text := Value;
end;

procedure TSavingTableForm.SetProgress(Value: Integer);
begin
  DmProgress1.Position := Value;
end;

procedure TSavingTableForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := False;
end;

procedure TSavingTableForm.Button1Click(Sender: TObject);
begin
  FTerminating := True;
end;

end.
