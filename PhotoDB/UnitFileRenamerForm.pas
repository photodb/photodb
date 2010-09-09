unit UnitFileRenamerForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Grids, ValEdit, StdCtrls, Menus, Dolphin_DB,
  Language, DB, WebLink, uVistaFuncs, UnitDBDeclare, uFileUtils;

type
  TFormFastFileRenamer = class(TForm)
    ValueListEditor1: TValueListEditor;
    Panel1: TPanel;
    Panel2: TPanel;
    Label1: TLabel;
    PopupMenu1: TPopupMenu;
    SortbyFileName1: TMenuItem;
    SortbyFileSize1: TMenuItem;
    Button3: TButton;
    Panel3: TPanel;
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    Edit2: TEdit;
    Label2: TLabel;
    ComboBox1: TComboBox;
    Button4: TButton;
    Button5: TButton;
    SortbyFileNumber1: TMenuItem;
    SortbyModified1: TMenuItem;
    SortbyFileType1: TMenuItem;
    WebLinkWarning: TWebLink;
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure SortbyFileName1Click(Sender: TObject);
    procedure SortbyFileSize1Click(Sender: TObject);
    procedure SortbyFileNumber1Click(Sender: TObject);
    procedure SortbyFileType1Click(Sender: TObject);
    procedure SortbyModified1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure WebLinkWarningClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
  FFiles : TStrings;
  fIDS : TArInteger;
  procedure SetFiles(Files : TStrings; IDS : TArInteger);
  procedure SetFilesA;
  procedure LoadLanguage;
  procedure DoCalculateRename;
  procedure DoRename;
  function CheckConflictFileNames : boolean;
    { Public declarations }
  end;

procedure FastRenameManyFiles(Files : TStrings; IDS : TArInteger);

implementation

uses UnitScriptsFunctions;

{$R *.dfm}

procedure FastRenameManyFiles(Files : TStrings; IDS : TArInteger);
var
  FormFastFileRenamer: TFormFastFileRenamer;
begin
 Application.CreateForm(TFormFastFileRenamer,FormFastFileRenamer);
 FormFastFileRenamer.SetFiles(Files,IDS);
 FormFastFileRenamer.ShowModal;
 FormFastFileRenamer.Release;
end;

{ TFormFastFileRenamer }

procedure TFormFastFileRenamer.SetFiles(Files: TStrings; IDS : TArInteger);
begin
 FFiles:=Files;
 FIDS:=IDS;
 SetFilesA;
end;

procedure TFormFastFileRenamer.FormCreate(Sender: TObject);
var
  List : TStrings;
  i : integer;
begin
 LoadLanguage;
 DBKernel.RecreateThemeToForm(Self);
 List:=DBKernel.ReadValues('Renamer');
 ComboBox1.Items.Clear;
 for i:=0 to List.Count-1 do
 ComboBox1.Items.Add(DBKernel.ReadString('Renamer',List[i]));

 ComboBox1.Text:=DBKernel.ReadString('Options','RenameText');
 List.Free;

 if ComboBox1.Text='' then
 ComboBox1.Text:=TEXT_MES_BEGIN_MASK;
 WebLinkWarning.Visible:=false;
 DBKernel.RegisterForm(Self);
end;

procedure TFormFastFileRenamer.LoadLanguage;
begin
 ValueListEditor1.TitleCaptions[0]:=TEXT_MES_ORIGINAL_FILE_NAME;
 ValueListEditor1.TitleCaptions[1]:=TEXT_MES_NEW_FILE_NAME;
 Button2.Caption:=TEXT_MES_CANCEL;
 Button1.Caption:=TEXT_MES_OK;
 Caption:=TEXT_MES_MASK_FOR_FILE_CAPTION;

 label1.Caption:=TEXT_MES_MASK_FOR_FILE;
 SortbyFileName1.Caption:=TEXT_MES_SORT_BY_FILE_NAME;
 SortbyFileSize1.Caption:=TEXT_MES_SORT_BY_FILE_SIZE;

 SortbyFileNumber1.Caption:=TEXT_MES_SORT_BY_FILE_NUMBER;
 SortbyModified1.Caption:=TEXT_MES_SORT_BY_MODIFIED;
 SortbyFileType1.Caption:=TEXT_MES_SORT_BY_FILE_TYPE;

 CheckBox1.Caption:=TEXT_MES_CAN_CHANGE_EXT;
 Label2.Caption:=TEXT_MES_BEGIN_NO;

 Button4.Caption:=TEXT_MES_ADD;
 Button5.Caption:=TEXT_MES_DELETE;

 WebLinkWarning.Text:= TEXT_MES_CONFLICT_FILE_NAMES;
end;

procedure TFormFastFileRenamer.DoCalculateRename;
var
  i, n : integer;
  s : string;
begin
 try
  for i:=1 to ValueListEditor1.Strings.Count do
  begin
   n:=StrToIntDef(Edit2.Text,1)-1+i;
   s:=ComboBox1.Text;
   s:=StringReplace(s,'%fn',GetFileNameWithoutExt(ExtractFileName(ValueListEditor1.Cells[0,i])),[rfReplaceAll,rfIgnoreCase]);
   s:=StringReplace(s,'%date',DateToStr(Now),[rfReplaceAll,rfIgnoreCase]);
   s:=StringReplace(s,'%d',Format('%d',[n]),[rfReplaceAll,rfIgnoreCase]);
   s:=StringReplace(s,'%1d',Format('%.1d',[n]),[rfReplaceAll,rfIgnoreCase]);
   s:=StringReplace(s,'%2d',Format('%.2d',[n]),[rfReplaceAll,rfIgnoreCase]);
   s:=StringReplace(s,'%3d',Format('%.3d',[n]),[rfReplaceAll,rfIgnoreCase]);
   s:=StringReplace(s,'%4d',Format('%.4d',[n]),[rfReplaceAll,rfIgnoreCase]);
   s:=StringReplace(s,'%5d',Format('%.5d',[n]),[rfReplaceAll,rfIgnoreCase]);
   s:=StringReplace(s,'%6d',Format('%.6d',[n]),[rfReplaceAll,rfIgnoreCase]);
   s:=StringReplace(s,'%h',IntToHex(n,0),[rfReplaceAll,rfIgnoreCase]);
   s:=StringReplace(s,'%1h',IntToHex(n,1),[rfReplaceAll,rfIgnoreCase]);
   s:=StringReplace(s,'%2h',IntToHex(n,2),[rfReplaceAll,rfIgnoreCase]);
   s:=StringReplace(s,'%3h',IntToHex(n,3),[rfReplaceAll,rfIgnoreCase]);
   s:=StringReplace(s,'%4h',IntToHex(n,4),[rfReplaceAll,rfIgnoreCase]);
   s:=StringReplace(s,'%5h',IntToHex(n,5),[rfReplaceAll,rfIgnoreCase]);
   s:=StringReplace(s,'%6h',IntToHex(n,6),[rfReplaceAll,rfIgnoreCase]);
   if not CheckBox1.Checked then
   begin
    if GetExt(ValueListEditor1.Cells[0,i])<>'' then
    s:=s+'.'+AnsiLowerCase(GetExt(ValueListEditor1.Cells[0,i]));
   end;
   ValueListEditor1.Cells[1,i]:=s;
  end;
 except
 end;
end;

procedure TFormFastFileRenamer.Button2Click(Sender: TObject);
begin
 Close;
end;

procedure TFormFastFileRenamer.Edit1Change(Sender: TObject);
begin
 DoCalculateRename;
 WebLinkWarning.Visible:=false;
end;

procedure TFormFastFileRenamer.DoRename;
var
  i : integer;
  OldFile, NewFile : string;
begin
 for i:=1 to ValueListEditor1.Strings.Count do
 try
  OldFile:=GetDirectory(FFiles[i-1])+ValueListEditor1.Cells[0,i];
  NewFile:=GetDirectory(FFiles[i-1])+ValueListEditor1.Cells[1,i];
  Dolphin_DB.RenamefileWithDB(Self, OldFile,NewFile,fIDS[i-1],false);
 except
  on e : Exception do MessageBoxDB(Handle,Format(TEXT_MES_UNABLE_TO_RENAME_FILE_TO_FILE_F,[OldFile,NewFile,e.Message]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
 end;
end;

procedure TFormFastFileRenamer.Button1Click(Sender: TObject);
var
  i : integer;
begin
 if CheckConflictFileNames then
 begin
  WebLinkWarning.Visible:=true;
  MessageBoxDB(Handle,TEXT_MES_WARNING_CONFLICT_RENAME_FILE_NAMES,TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
  exit;
 end;

 DoRename;

 DBKernel.DeleteValues('Renamer');
 for i:=0 to ComboBox1.Items.Count-1 do
 begin
  DBKernel.WriteString('Renamer','val'+IntToStr(i+1),ComboBox1.Items[i]);
 end;
 DBKernel.WriteString('Options','RenameText',ComboBox1.Text);
 Close;
end;

procedure TFormFastFileRenamer.Button3Click(Sender: TObject);
begin
 MessageBoxDB(Handle,TEXT_MES_MASK_INFO,TEXT_MES_INFO,TD_BUTTON_OK,TD_ICON_INFORMATION);
end;

procedure TFormFastFileRenamer.SortbyFileName1Click(Sender: TObject);
var
  i, k : integer;
  b : boolean;
  S : string;
begin
 Repeat
  b:=false;
  for i:=1 to ValueListEditor1.Strings.Count-1 do
  begin
   if AnsiCompareStr(FFiles[i-1],FFiles[i])>0 then
   begin
    s:=FFiles[i-1];
    FFiles[i-1]:=FFiles[i];
    FFiles[i]:=s;
    k:=FIDS[i-1];
    FIDS[i-1]:=FIDS[i];
    FIDS[i]:=k;
    b:=true;
   end;
  end;
 Until not b;
 SetFilesA;
end;

procedure TFormFastFileRenamer.SetFilesA;
var
  i : integer;
begin
 ValueListEditor1.Strings.Clear;
 for i:=1 to FFiles.Count do
 begin
  ValueListEditor1.Strings.Add(ExtractFileName(FFiles[i-1]));
  ValueListEditor1.Keys[i]:=ExtractFileName(FFiles[i-1]);
 end;
 DoCalculateRename;
end;

procedure TFormFastFileRenamer.SortbyFileSize1Click(Sender: TObject);
var
  i, k : integer;
  b : boolean;
  S : string;
  X : array of integer;
begin
 Setlength(X,ValueListEditor1.Strings.Count);
 for i:=1 to ValueListEditor1.Strings.Count-1 do
 X[i-1]:=GetFileSizeByName(FFiles[i-1]);
 Repeat
  b:=false;
  for i:=1 to ValueListEditor1.Strings.Count-1 do
  begin
   if x[i-1]<x[i] then
   begin
    s:=FFiles[i-1];
    FFiles[i-1]:=FFiles[i];
    FFiles[i]:=s;
    k:=x[i-1];
    x[i-1]:=x[i];
    x[i]:=k;
    k:=FIDs[i-1];
    FIDs[i-1]:=FIDs[i];
    FIDs[i]:=k;
    b:=true;
   end;
  end;
 Until not b;
 SetFilesA;
end;

procedure TFormFastFileRenamer.SortbyFileNumber1Click(Sender: TObject);
var
  i, k : integer;
  b : boolean;
  S : string;
begin
 Repeat
  b:=false;
  for i:=1 to ValueListEditor1.Strings.Count-1 do
  begin
   if AnsiCompareTextWithNum(FFiles[i-1],FFiles[i])>0 then
   begin
    s:=FFiles[i-1];
    FFiles[i-1]:=FFiles[i];
    FFiles[i]:=s;
    k:=FIDS[i-1];
    FIDS[i-1]:=FIDS[i];
    FIDS[i]:=k;
    b:=true;
   end;
  end;
 Until not b;
 SetFilesA;
end;

procedure TFormFastFileRenamer.SortbyFileType1Click(Sender: TObject);
var
  i, k : integer;
  b : boolean;
  S : string;
begin
 Repeat
  b:=false;
  for i:=1 to ValueListEditor1.Strings.Count-1 do
  begin
   if AnsiCompareStr(GetExt(FFiles[i-1]),GetExt(FFiles[i]))>0 then
   begin
    s:=FFiles[i-1];
    FFiles[i-1]:=FFiles[i];
    FFiles[i]:=s;
    k:=FIDS[i-1];
    FIDS[i-1]:=FIDS[i];
    FIDS[i]:=k;
    b:=true;
   end;
  end;
 Until not b;
 SetFilesA;
end;

procedure TFormFastFileRenamer.SortbyModified1Click(Sender: TObject);
var
  i, n : integer;
  k : TDateTime;
  b : boolean;
  S : string;
  X : array of TDateTime;
begin
 Setlength(X,ValueListEditor1.Strings.Count);
 for i:=1 to ValueListEditor1.Strings.Count-1 do
 X[i-1]:=DateModify(FFiles[i-1]);
 Repeat
  b:=false;
  for i:=1 to ValueListEditor1.Strings.Count-1 do
  begin
   if x[i-1]<x[i] then
   begin
    s:=FFiles[i-1];
    FFiles[i-1]:=FFiles[i];
    FFiles[i]:=s;
    k:=x[i-1];
    x[i-1]:=x[i];
    x[i]:=k;
    n:=FIDs[i-1];
    FIDs[i-1]:=FIDs[i];
    FIDs[i]:=n;
    b:=true;
   end;
  end;
 Until not b;
 SetFilesA;
end;

procedure TFormFastFileRenamer.Button4Click(Sender: TObject);
var
  i : integer;
begin
 for i:=0 to ComboBox1.Items.Count-1 do
 if AnsiLowerCase(ComboBox1.Items[i])=AnsiLowerCase(ComboBox1.Text) then exit;
 ComboBox1.Items.Add(ComboBox1.Text)
end;

procedure TFormFastFileRenamer.Button5Click(Sender: TObject);
var
  i : integer;
begin
 for i:=0 to ComboBox1.Items.Count-1 do
 if AnsiLowerCase(ComboBox1.Items[i])=AnsiLowerCase(ComboBox1.Text) then
 begin
  ComboBox1.Items.Delete(i);
  Exit;
 end;
end;

procedure TFormFastFileRenamer.WebLinkWarningClick(Sender: TObject);
begin
 if CheckConflictFileNames then
 begin
  MessageBoxDB(Handle,TEXT_MES_WARNING_CONFLICT_RENAME_FILE_NAMES,TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
  exit;
 end;
 WebLinkWarning.Visible:=false;
end;

procedure TFormFastFileRenamer.FormDestroy(Sender: TObject);
begin
 DBKernel.UnRegisterForm(Self);
end;

function TFormFastFileRenamer.CheckConflictFileNames: boolean;
var
  i, j : integer;
  Dir : string;
  OldFiles : TArStrings;
  OldDirFiles : TArStrings;
  NewFiles : TArStrings;
begin
 Result:=false;
 
 Dir:=GetDirectory(FFiles[0]);
 OldDirFiles:=TArStrings(GetDirListing(Dir,'||'));
 SetLength(OldFiles,ValueListEditor1.Strings.Count);
 for i:=1 to ValueListEditor1.Strings.Count do
 OldFiles[i-1]:=GetDirectory(FFiles[i-1])+ValueListEditor1.Cells[0,i];

 SetLength(NewFiles,ValueListEditor1.Strings.Count);
 for i:=1 to ValueListEditor1.Strings.Count do
 NewFiles[i-1]:=GetDirectory(FFiles[i-1])+ValueListEditor1.Cells[1,i];

 for i:=0 to Length(OldFiles)-1 do
 for j:=0 to Length(NewFiles)-1 do
 if AnsiLowerCase(OldFiles[i])=AnsiLowerCase(NewFiles[j]) then begin Result:=true; break; end;

 for i:=0 to Length(OldDirFiles)-1 do
 for j:=0 to Length(NewFiles)-1 do
 if AnsiLowerCase(OldDirFiles[i])=AnsiLowerCase(NewFiles[j]) then begin Result:=true; break; end;

 for i:=0 to Length(NewFiles)-1 do
 for j:=i+1 to Length(NewFiles)-1 do
 if AnsiLowerCase(NewFiles[i])=AnsiLowerCase(NewFiles[j]) then begin Result:=true; break; end;
end;

end.
