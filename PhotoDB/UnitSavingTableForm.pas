unit UnitSavingTableForm;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Data.DB,

  Dmitry.Controls.DmProgress,

  uDBContext,
  uThreadForm;

type
  TSavingTableForm = class(TThreadForm)
    DmProgress1: TDmProgress;
    Label1: TLabel;
    BtnAbort: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtnAbortClick(Sender: TObject);
  private
    { Private declarations }
    procedure LoadLanguage;
  protected
    function GetFormID: string; override;
  public
    { Public declarations }
    FTerminating: Boolean;
    procedure Execute(Context: IDBContext; DestinationPath: String; SubFolders: Boolean; FileList: TStrings);
    procedure SetMaxValue(Value: Integer);
    procedure SetProgress(Value: Integer);
    procedure SetText(Value: String);
  end;

procedure SaveQuery(Context: IDBContext; DestinationPath: String; SubFolders: Boolean; FileList: TStrings);

implementation

uses UnitSaveQueryThread;

{$R *.dfm}

procedure SaveQuery(Context: IDBContext; DestinationPath: String; SubFolders: Boolean; FileList: TStrings);
var
  SavingTableForm: TSavingTableForm;
begin
  Application.CreateForm(TSavingTableForm, SavingTableForm);
  try
    SavingTableForm.Execute(Context, DestinationPath, SubFolders, FileList);
  finally
    SavingTableForm.Release;
  end;
end;

procedure TSavingTableForm.Execute(Context: IDBContext; DestinationPath: string; SubFolders: Boolean; FileList: TStrings);
begin
  TSaveQueryThread.Create(Context, DestinationPath, Self, SubFolders, FileList, StateID);
  ShowModal;
end;

procedure TSavingTableForm.LoadLanguage;
begin
  BeginTranslate;
  try
    DmProgress1.Text := L('Progress... (&%%)');
    BtnAbort.Caption := L('Abort');
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

procedure TSavingTableForm.BtnAbortClick(Sender: TObject);
begin
  FTerminating := True;
end;

end.
