unit uFormImportImages;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  WebLink,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  WatermarkedEdit,
  PathEditor,
  UnitDBFileDialogs,
  uMemory,
  uShellUtils,
  uRuntime,
  uResources,
  uSettings,
  uDBForm;

type
  TFormImportImages = class(TDBForm)
    LbImportFrom: TLabel;
    LbDirectoryFormat: TLabel;
    LbImportTo: TLabel;
    LbLabel: TLabel;
    PeImportFromPath: TPathEditor;
    CbFormatCombo: TComboBox;
    BtnSelectPathFrom: TButton;
    PeImportToPath: TPathEditor;
    BtnSelectPathTo: TButton;
    WedLabel: TWatermarkedEdit;
    DtpDate: TDateTimePicker;
    LbDate: TLabel;
    CbOnlyImages: TCheckBox;
    BtnOk: TButton;
    BtnCancel: TButton;
    CbDeleteAfterImport: TCheckBox;
    WlExtendedMode: TWebLink;
    CbAddToCollection: TCheckBox;
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnSelectPathToClick(Sender: TObject);
    procedure BtnSelectPathFromClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
  private
    { Private declarations }
    procedure LoadLanguage;
    procedure ReadOptions;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    function GetFormID: string; override;
  public
    { Public declarations }
  end;

var
  FormImportImages: TFormImportImages;

implementation

uses
  uThreadImportPictures;

{$R *.dfm}

procedure TFormImportImages.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormImportImages.BtnOkClick(Sender: TObject);
var
  Options: TImportPicturesOptions;
  Task: TImportPicturesTask;
  Operation: TFileOperationTask;
begin
  Options := TImportPicturesOptions.Create;
  Options.OnlySupportedImages := CbOnlyImages.Checked;
  Options.DeleteFilesAfterImport := CbDeleteAfterImport.Checked;
  Options.AddToCollection := CbAddToCollection.Checked;

  Task := TImportPicturesTask.Create;
  Options.AddTask(Task);

  Operation := TFileOperationTask.Create(PeImportFromPath.PathEx, PeImportToPath.PathEx);
  Task.AddOperation(Operation);
  TThreadImportPictures.Create(Options);

  Settings.WriteBool('ImportPictures', 'OnlyImages', CbOnlyImages.Checked);
  Settings.WriteBool('ImportPictures', 'DeleteFiles', CbDeleteAfterImport.Checked);
  Settings.WriteBool('ImportPictures', 'AddToCollection', CbAddToCollection.Checked);
  Settings.WriteString('ImportPictures', 'Source', PeImportFromPath.Path);
  Settings.WriteString('ImportPictures', 'Destination', PeImportToPath.Path);
  Close;
end;

procedure TFormImportImages.BtnSelectPathFromClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := UnitDBFileDialogs.DBSelectDir(Handle, L('Please select a folder or device with images'), '', UseSimpleSelectFolderDialog);

  if Dir <> '' then
     PeImportFromPath.Path := Dir;
end;

procedure TFormImportImages.BtnSelectPathToClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := UnitDBFileDialogs.DBSelectDir(Handle, L('Please select destination directory'), GetMyPicturesPath, UseSimpleSelectFolderDialog);

  if Dir <> '' then
     PeImportToPath.Path := Dir;
end;

procedure TFormImportImages.CreateParams(var Params: TCreateParams);
begin
  Inherited CreateParams(Params);
  Params.WndParent := GetDesktopWindow;
  with params do
    ExStyle := ExStyle or WS_EX_APPWINDOW;
end;

procedure TFormImportImages.FormCreate(Sender: TObject);
var
  PathImage: TBitmap;
begin
  LoadLanguage;

  PathImage := GetPathSeparatorImage;
  try
    PeImportFromPath.SeparatorImage := PathImage;
    PeImportToPath.SeparatorImage := PathImage;
  finally
    F(PathImage);
  end;

  ReadOptions;
end;

function TFormImportImages.GetFormID: string;
begin
  Result := 'ImportPictures';
end;

procedure TFormImportImages.LoadLanguage;
begin
  BeginTranslate;
  try

  finally
    EndTranslate;
  end;
end;

procedure TFormImportImages.ReadOptions;
begin
  CbOnlyImages.Checked := Settings.ReadBool('ImportPictures', 'OnlyImages', False);
  CbDeleteAfterImport.Checked := Settings.ReadBool('ImportPictures', 'DeleteFiles', True);
  CbAddToCollection.Checked := Settings.ReadBool('ImportPictures', 'AddToCollection', True);

  PeImportFromPath.Path := Settings.ReadString('ImportPictures', 'Source', '');
  PeImportToPath.Path := Settings.ReadString('ImportPictures', 'Destination', GetMyPicturesPath);
end;

end.
