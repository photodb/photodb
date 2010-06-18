unit unitid;

interface

uses
  UnitLoadFilesToPanel, Dolphin_DB, Windows, Messages, SysUtils, Classes,
  Graphics, Controls, Forms, Dialogs, UnitDBDeclare, UnitDBCommon,
  UnitFileExistsThread;

type
  TIDForm = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
      procedure WMCopyData(var m : TMessage); message WM_COPYDATA;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  IDForm: TIDForm;
	
implementation

uses UnitFormCont, Searching, SlideShow, ExplorerUnit, UnitGetPhotosForm;

{$R *.dfm}

procedure TIDForm.FormCreate(Sender: TObject);
begin
 Caption:=DBID;
end;

procedure TIDForm.WMCopyData(var m: TMessage);
var
  Param : TArStrings;
  fids_ : TArInteger;
  FileNameA, FileNameB, S : string;
  n, i : integer;
  FormCont : TFormCont;
  B : TArBoolean;
  Info : TRecordsInfo;
begin
 S :=PRecToPass(PCopyDataStruct(m.LParam)^.lpData)^.s;
 For i:=1 to Length(s) do
 If s[i]=#0 then
 begin
  FileNameA:=Copy(S,1,i-1);
  FileNameB:=Copy(S,i+1,Length(S)-i);
 end;
 if not CheckFileExistsWithMessageEx(FileNameA,false) then
 begin
  If AnsiUpperCase(FileNameA)='/EXPLORER' then
  begin
   If CheckFileExistsWithMessageEx(LongFileName(filenameB),true) then
   begin
    With ExplorerManager.NewExplorer(False) do
    begin
     SetPath(LongFileName(FileNameB));
     Show;                           
     ActivateApplication(Handle);
    end;
   end;
  end else
  begin
   if AnsiUpperCase(filenameA)='/GETPHOTOS' then
   if FileNameB<>'' then
   begin
    GetPhotosFromDrive(FileNameB[1]);
    Exit;
   end;
   With SearchManager.GetAnySearch do
   begin
    Show;
    ActivateApplication(Handle);
   end;
   Exit;
  end;
 end;
 If ExtInMask(SupportedExt,GetExt(FileNameA)) then
 begin
  if Viewer=nil then Application.CreateForm(TViewer, Viewer);
  FileNameA:=LongFileName(FileNameA);
  GetFileListByMask(FileNameA,SupportedExt,info,n,True);
  SlideShow.UseOnlySelf:=true;
  ShowWindow(Viewer.Handle,SW_RESTORE);
  Viewer.Execute(Self,info);
  Viewer.Show;
  ActivateApplication(Viewer.Handle);
 end else
 If (AnsiUpperCase(FileNameA)<>'/EXPLORER') and CheckFileExistsWithMessageEx(FileNameA,false) then
 begin
  if GetExt(FileNameA)='DBL' then
  begin
   Dolphin_DB.LoadDblFromfile(FileNameA,fids_,param);
   FormCont:=ManagerPanels.NewPanel;
   SetLength(B,0);
   LoadFilesToPanel.Create(false,param,fids_,B,false,true,FormCont);
   LoadFilesToPanel.Create(false,param,fids_,B,false,false,FormCont);     
   FormCont.Show;
   ActivateApplication(FormCont.Handle);
   exit;
  end;
  if GetExt(filenameA)='IDS' then
  begin
   fids_:=LoadIDsFromfileA(FileNameA);
   setlength(param,1);
   FormCont:=ManagerPanels.NewPanel;
   LoadFilesToPanel.Create(false,param,fids_,B,false,true,FormCont);
   FormCont.Show;
   ActivateApplication(FormCont.Handle);
  end else
  begin
   if GetExt(FileNameA)='ITH' then
   begin
    With SearchManager.NewSearch do
    begin
      SearchEdit.Text:=':ThFile('+filenameA+'):';
      DoSearchNow(Self);
      Show;                    
      ActivateApplication(Handle);
    end;
    exit;
   end else
   begin
    With SearchManager.GetAnySearch do
    begin
     Show;     
     ActivateApplication(Handle);
    end;
   end;
  end;
 end;
end;

end.
