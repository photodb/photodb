unit UnitGetPhotosForm;

interface

uses
  Registry, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Language, EXIF, Dolphin_DB,
  acDlgSelect, Math, UnitUpdateDBObject, UnitScanImportPhotosThread,
  DmProgress, ImgList, CommCtrl, UnitDBKernel, Menus, uVistaFuncs, uFileUtils,
  UnitDBDeclare, UnitDBFileDialogs;

type
  TGetImagesOptions = record
   Date : TDateTime;
   FolderMask : String;
   Comment : String;
   ToFolder : String;
   GetMultimediaFiles : boolean;
   MultimediaMask : String;
   Move : boolean;
   OpenFolder : Boolean;
   AddFolder : Boolean;
  end;

 TGetImagesOptionsArray = array of TGetImagesOptions;

type
  TGetToPersonalFolderForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    DateTimePicker1: TDateTimePicker;
    Edit1: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Edit2: TEdit;
    Button3: TButton;
    ComboBox2: TComboBox;
    Label6: TLabel;
    CheckBox1: TCheckBox;
    Memo2: TMemo;
    Button4: TButton;
    CheckBox2: TCheckBox;
    Edit3: TEdit;
    CheckBox3: TCheckBox;
    DestroyTimer: TTimer;
    ListView1: TListView;
    Label7: TLabel;
    Button5: TButton;
    ExtendedButton: TButton;
    ProgressBar: TDmProgress;
    OptionsImageList: TImageList;
    PopupMenu1: TPopupMenu;
    MoveUp1: TMenuItem;
    MoveDown1: TMenuItem;
    N1: TMenuItem;
    Remove1: TMenuItem;
    N2: TMenuItem;
    MergeUp1: TMenuItem;
    MergeDown1: TMenuItem;
    DontCopy1: TMenuItem;
    SimpleCopy1: TMenuItem;
    N3: TMenuItem;
    ShowImages1: TMenuItem;
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure DestroyTimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button5Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListView1Resize(Sender: TObject);
    procedure ExtendedButtonClick(Sender: TObject);
    procedure ListView1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure SimpleCopy1Click(Sender: TObject);
    procedure MergeUp1Click(Sender: TObject);
    procedure MergeDown1Click(Sender: TObject);
    procedure DontCopy1Click(Sender: TObject);
    procedure ListView1AdvancedCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; Stage: TCustomDrawStage;
      var DefaultDraw: Boolean);
    procedure ShowImages1Click(Sender: TObject);
    procedure Remove1Click(Sender: TObject);
    procedure MoveUp1Click(Sender: TObject);
    procedure MoveDown1Click(Sender: TObject);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
  private
  FPach : string;
  fDataList : TFileDateList;
  ExtendedMode : boolean;
  ThreadInProgress : boolean;
  DefaultOptions : TGetImagesOptions;
  OptionsArray : TGetImagesOptionsArray;
    { Private declarations }
  public
  Procedure Execute(Pach : string);
  Procedure LoadLanguage;
  procedure OnEndScanFolder(Sender: TObject);
  procedure OnLoadingFilesCallBackEvent(Sender : TObject; var Info : TProgressCallBackInfo);
  procedure SetDataList(DataList : TFileDateList);
  procedure RecountGroups;
  Function FormatFolderName(Mask, Comment : String; Date : TDateTime) : String;
    { Public declarations }
  end;

  TItemRecordOptions = record
   StringDate : string[240];   
   Date : TDateTime;
   Options : integer;
   Tag : integer;
  end;
  PItemRecordOptions = ^TItemRecordOptions;

Procedure GetPhotosFromDrive(DriveLetter : Char);
Procedure GetPhotosFromFolder(Folder : string);

implementation

uses ExplorerUnit, UnitUpdateDB, SlideShow;

Procedure GetPhotosFromDrive(DriveLetter : Char);
var
  GetToPersonalFolderForm: TGetToPersonalFolderForm;
begin
 Application.CreateForm(TGetToPersonalFolderForm,GetToPersonalFolderForm);
 GetToPersonalFolderForm.Execute(DriveLetter+':\');
end;

Procedure GetPhotosFromFolder(Folder : string);
var
  GetToPersonalFolderForm: TGetToPersonalFolderForm;
begin
 Application.CreateForm(TGetToPersonalFolderForm,GetToPersonalFolderForm);
 GetToPersonalFolderForm.Execute(Folder);
end;

{$R *.dfm}

{ TGetToPersonalFolderForm }

procedure CreateDirA(dir : string);
var
  i : integer;
begin
 if dir[length(dir)]<>'\' then dir:=dir+'\';
 if length(dir)<3 then exit;
 for i:=1 to length(dir) do
 try
  if (dir[i]='\') or (i=length(dir)) then
  createdir(copy(dir,1,i));
 except
  exit;
 end;
end;

Function GetPhotosDate(Mask : String; Pach : string) : TDateTime;
var
  Files : TStrings;
  FEXIF : TEXIF;
  Dates : array[1..4] of TDateTime;
  i, MaxFiles, FilesSearch : integer; 
begin
 Files := TStringList.Create;
 MaxFiles:=500;
 FilesSearch:=4;
 GetPhotosNamesFromDrive(Pach,SupportedExt,Files,MaxFiles,FilesSearch);
 if Files.Count=0 then
 begin
  MaxFiles:=500;
  FilesSearch:=4;
  GetPhotosNamesFromDrive(Pach,Mask,Files,MaxFiles,FilesSearch);
  if Files.Count=0 then
  begin
   if (Length(Pach)=3) and (Pach[2]=':') then
   MessageBoxDB(GetActiveFormHandle,Format(TEXT_MES_PHOTOS_NOT_FOUND_IN_DRIVE_F,[Pach]),TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING) else
   MessageBoxDB(GetActiveFormHandle,Format(TEXT_MES_PHOTOS_NOT_FOUND_IN_PACH_F,[Pach]),TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
   Result:=-1;
   Exit;
  end else
  begin
   Result:=Now;
   Exit;
  end;
 end;
 for i:=1 to Min(4,Files.Count) do
 begin
  FEXIF := TEXIF.Create;
  try
   FEXIF.ReadFromFile(Files[i-1]);
  except
  end;
  Dates[i]:=FEXIF.Date;
  FEXIF.Free;
 end;
 Result:=now;
 for i:=1 to Min(4,Files.Count)-1 do
 if Dates[i+1]<>Dates[1] then
 begin
  Result:=Now;
  Exit;
 end else Result:=Dates[1];
end;

procedure TGetToPersonalFolderForm.Execute(Pach: string);
var
  Date : TDateTime;
  Mask : String;
  i : Integer;
  oldMode: Cardinal;
begin
 oldMode:= SetErrorMode(SEM_FAILCRITICALERRORS);
 FPach:=Pach;
 if CheckBox2.Checked then
 begin
  Mask:=Edit3.Text;
  Mask:='|'+Mask+'|';
  For i:=Length(Mask) downto 2 do
  if (Mask[i]='|') and (Mask[i-1]='|') then Delete(Mask,i,1);
  if Length(Mask)>0 then Delete(Mask,1,1);
  Mask:=SupportedExt+Mask;
 end else Mask:=SupportedExt;
 Date:=GetPhotosDate(Mask,Pach);
 SetErrorMode(oldMode);
 if Date=-1 then
 begin
  Exit;
 end;
 DateTimePicker1.DateTime:=Date;
 Edit1Change(self);
 Show;
end;

procedure TGetToPersonalFolderForm.LoadLanguage;
begin
 Label1.Caption:=TEXT_MES_PHOTOS_DATE;
 CheckBox1.Caption:=TEXT_MES_OPEN_THIS_FOLDER;
 Caption:=TEXT_MES_GET_PHOTOS_CAPTION;
 Label2.Caption:=TEXT_MES_FOLDER_MASK;
 Label3.Caption:=TEXT_MES_COMMENT_FOR_FOLDER;
 Memo1.Text:=TEXT_MES_YOU_COMMENT;
 Label4.Caption:=TEXT_MES_FOLDER_NAME_A;
 Label5.Caption:=TEXT_MES_END_FOLDER_A;
 Label6.Caption:=TEXT_MES_METHOD_A;
 ComboBox2.Items.Clear;
 ComboBox2.Items.Add(TEXT_MES_MOVE);
 ComboBox2.Items.Add(TEXT_MES_COPY);
 Button2.Caption:=TEXT_MES_CANCEL;
 Button1.Caption:=TEXT_MES_OK;
 Button4.Caption:=TEXT_MES_SAVE;
 CheckBox2.Caption:=TEXT_MES_GET_MULTIMEDIA_FILES;
 CheckBox3.Caption:=TEXT_MES_ADD_FOLDER;
 Label7.Caption:=TEXT_MES_PHOTO_SERIES_DATES_;
 ListView1.Columns[0].Caption:=TEXT_MES_ACTION_DOWNLOAD_DATE;
 ListView1.Columns[1].Caption:=TEXT_MES_DATE;

 MoveUp1.Caption:=TEXT_MES_ITEM_UP;
 MoveDown1.Caption:=TEXT_MES_ITEM_DOWN;
 Remove1.Caption:=TEXT_MES_DELETE;

 SimpleCopy1.Caption:=TEXT_MES_SIMPLE_COPY_BY_DATE;
 MergeUp1.Caption:=TEXT_MES_MERGE_UP_BY_DATE;
 MergeDown1.Caption:=TEXT_MES_MERGE_DOWN_BY_DATE;
 DontCopy1.Caption:=TEXT_MES_DONT_COPY_BY_DATE;
 ShowImages1.Caption:=TEXT_MES_SHOW_IMAGES;

 Button5.Caption:=TEXT_MES_SCAN_IMAGES_DATES;
end;

procedure TGetToPersonalFolderForm.Button2Click(Sender: TObject);
begin
 Close;
end;

procedure TGetToPersonalFolderForm.FormCreate(Sender: TObject);
var
  Reg: TRegIniFile;
begin
 Width:=273;
 ExtendedButton.Left:=248;
 ExtendedMode:=false;
 GetPhotosFormSID:=GetGUID;
 ThreadInProgress:=false;
 DBKernel.RecreateThemeToForm(Self);
 LoadLanguage;
 if DirectoryExists(DBKernel.ReadString('GetPhotos','DFolder')) then
 Edit2.Text:=DBKernel.ReadString('GetPhotos','DFolder') else
 begin
  Reg := TRegIniFile.Create(SHELL_FOLDERS_ROOT);
  Edit2.Text:=Reg.ReadString('Shell Folders', 'My Pictures', '');
  Reg.Free;
 end;            
 OptionsImageList.BkColor:=Theme_ListColor;
 ImageList_ReplaceIcon(OptionsImageList.Handle, -1, icons[DB_IC_SENDTO+1]);
 ImageList_ReplaceIcon(OptionsImageList.Handle, -1, icons[DB_IC_UP+1]);
 ImageList_ReplaceIcon(OptionsImageList.Handle, -1, icons[DB_IC_DOWN+1]);  
 ImageList_ReplaceIcon(OptionsImageList.Handle, -1, icons[DB_IC_DELETE_INFO+1]);
 PopupMenu1.Images:=DBKernel.ImageList;

 MoveUp1.ImageIndex:=DB_IC_UP;
 MoveDown1.ImageIndex:=DB_IC_DOWN;
 Remove1.ImageIndex:=DB_IC_DELETE_INFO;
 SimpleCopy1.ImageIndex:=DB_IC_SENDTO;
 MergeUp1.ImageIndex:=DB_IC_UP;
 MergeDown1.ImageIndex:=DB_IC_DOWN;
 DontCopy1.ImageIndex:=DB_IC_DELETE_INFO;
 ShowImages1.ImageIndex:=DB_IC_SLIDE_SHOW;
 
 CheckBox1.Checked:=DBKernel.ReadBool('GetPhotos','OpenFolder',true);
 CheckBox3.Checked:=DBKernel.ReadBool('GetPhotos','AddPhotos',true);
 if DBKernel.ReadString('GetPhotos','MaskFolder')<>'' then
 Edit1.Text:=DBKernel.ReadString('GetPhotos','MaskFolder') else
 Edit1.Text:='%yy:mm:dd = %YMD (%coment)';

 if DBKernel.ReadString('GetPhotos','Comment')<>'' then
 Memo1.Text:=DBKernel.ReadString('GetPhotos','Comment') else
 Memo1.Text:=TEXT_MES_YOU_COMMENT;

 Case DBKernel.ReadInteger('GetPhotos','GetMethod',0) of
 0 : ComboBox2.ItemIndex:=0;
 1 : ComboBox2.ItemIndex:=1;
 else ComboBox2.ItemIndex:=0;
 end;
 Edit1Change(Sender);

 CheckBox2.Checked:=DBKernel.ReadBool('GetPhotos','UseMultimediaMask',true);
 if DBKernel.ReadString('GetPhotos','MultimediaMask')<>'' then
 Edit3.Text:=DBKernel.ReadString('GetPhotos','MultimediaMask') else
 Edit3.Text:=MultimediaBaseFiles;
end;

procedure TGetToPersonalFolderForm.Button3Click(Sender: TObject);
var
  Dir : string;
begin
 Dir:=UnitDBFileDialogs.DBSelectDir(Handle,TEXT_MES_SEL_FOLDER_FOR_IMAGES,Edit2.Text,Dolphin_DB.UseSimpleSelectFolderDialog);
 if DirectoryExists(dir) then
 Edit2.Text:=dir;
end;

procedure TGetToPersonalFolderForm.Edit1Change(Sender: TObject);
var
  Options : TGetImagesOptions;
  i,GroupTag : integer;
begin
 Memo2.Text:=FormatFolderName(Edit1.Text, Memo1.Text, DateTimePicker1.DateTime);
 if ExtendedMode then
 if ListView1.Selected<>nil then
 begin
  Options.Date:=DateTimePicker1.Date;
  Options.FolderMask:=Edit1.Text;
  Options.Comment:=Memo1.Text;
  Options.ToFolder:=Edit2.Text;
  Options.GetMultimediaFiles:=CheckBox2.Checked;
  Options.MultimediaMask:=Edit3.Text;
  Options.Move:=ComboBox2.ItemIndex=0;
  Options.OpenFolder:=CheckBox1.Checked;
  Options.AddFolder:=CheckBox3.Checked;
  OptionsArray[ListView1.Selected.Index]:=Options;
  GroupTag:=TItemRecordOptions(ListView1.Items[ListView1.Selected.Index].Data^).Tag;

  //look index-down
  for i:=ListView1.Selected.Index downto 0 do
  if TItemRecordOptions(ListView1.Items[i].Data^).Tag=GroupTag then
  OptionsArray[i]:=Options else Break;

  //look index-ip
  for i:=ListView1.Selected.Index to ListView1.Items.Count-1 do
  if TItemRecordOptions(ListView1.Items[i].Data^).Tag=GroupTag then
  OptionsArray[i]:=Options else Break;

 end;
end;

procedure TGetToPersonalFolderForm.Button4Click(Sender: TObject);
begin
 DBKernel.WriteBool('GetPhotos','OpenFolder',CheckBox1.Checked);
 DBKernel.WriteBool('GetPhotos','AddPhotos',CheckBox3.Checked);
 DBKernel.WriteString('GetPhotos','DFolder',Edit2.Text);
 DBKernel.WriteString('GetPhotos','MaskFolder',Edit1.Text);
 DBKernel.WriteString('GetPhotos','Comment',Memo1.Text);
 DBKernel.WriteInteger('GetPhotos','GetMethod',ComboBox2.ItemIndex);
 DBKernel.WriteString('GetPhotos','MultimediaMask',Edit3.Text);
 DBKernel.WriteBool('GetPhotos','UseMultimediaMask',CheckBox2.Checked);
end;

procedure TGetToPersonalFolderForm.Button1Click(Sender: TObject);
var
  Files : TStrings;
  FFiles : TArStrings;
  MaxFiles, FilesSearch, i, j : Integer;
  Folder, Mask : String;
  Options : TGetImagesOptions;
  ItemOptions : TItemRecordOptions;
  Date : TDateTime;
begin


 if ExtendedMode then
 begin

  DateTimePicker1.Enabled:=false;
  Edit1.Enabled:=false;
  Memo1.Enabled:=false;
  Edit2.Enabled:=false;
  CheckBox2.Enabled:=false;
  Edit3.Enabled:=false;
  ComboBox2.Enabled:=false;
  CheckBox1.Enabled:=false;
  CheckBox3.Enabled:=false;
  ListView1.Enabled:=false;
  Button1.Enabled:=false;    
  Button2.Enabled:=false; 
  Button3.Enabled:=false;  
  Button4.Enabled:=false;
  Button5.Enabled:=false;

  //EXTENDED LOADING FILES
  for i:=0 to ListView1.Items.Count-1 do
  begin
   ItemOptions:=TItemRecordOptions(ListView1.Items[i].Data^);
   if ItemOptions.Options=DIRECTORY_OPTION_DATE_EXCLUDE then continue;
   Options:=OptionsArray[i];
   
   Folder:=Options.ToFolder;
   FormatDir(Folder);
   Folder:=Folder+FormatFolderName(Options.FolderMask,Options.Comment,Options.Date);
   CreateDirA(Folder);
   if not DirectoryExists(Folder) then
   begin
    MessageBoxDB(Handle,Format(TEXT_MES_CANT_CREATE_DIRECTORY_F,[Folder]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
    exit;
   end;
   Files:=TStringList.Create;
   Date:=TItemRecordOptions(ListView1.Items[i].Data^).Date;
   TItemRecordOptions(ListView1.Items[i].Data^).Tag:=-1;
   ListView1.Refresh;
   for j:=0 to Length(fDataList)-1 do
   if fDataList[j].Date=Date then
   Files.Add(fDataList[j].FileName);

   if Options.OpenFolder then
   With ExplorerManager.NewExplorer(False) do
   begin
    SetPath(Folder);
    Show;
    SetFocus;
   end;    
   //TODO:
   //WHAT IT??????
   GetFileNameById(0);
   Delay(1500);
   //////////////////  
   SetLength(FFiles,Files.Count);
   for j:=0 to Files.Count-1 do
   FFiles[j]:=Files[j];
   try
    CopyFilesSynch(0,FFiles,Folder,Options.Move,true);
   except
    MessageBoxDB(Handle,TEXT_MES_UNABLE_GET_PHOTOS_COPY_MOVE_ERROR,TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
   end;
   if Options.AddFolder then
   begin
    If UpdaterDB=nil then
    UpdaterDB:=TUpdaterDB.Create;
    UpdaterDB.AddDirectory(Folder,nil);
   end;

   Files.Free;
  end;
  //END
 end else
 begin

  Folder:=Edit2.Text;
  FormatDir(Folder);
  Folder:=Folder+Memo2.Text;
  CreateDirA(Folder);
  if not DirectoryExists(Folder) then
  begin
   MessageBoxDB(Handle,Format(TEXT_MES_CANT_CREATE_DIRECTORY_F,[Folder]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
   exit;
  end;
  Files:=TStringList.Create;
  MaxFiles:=10000;
  FilesSearch:=100000;
  if CheckBox2.Checked then
  begin
   Mask:=Edit3.Text;
   Mask:='|'+Mask+'|';
   For i:=Length(Mask) downto 2 do
   if (Mask[i]='|') and (Mask[i-1]='|') then Delete(Mask,i,1);
   if Length(Mask)>0 then Delete(Mask,1,1);
   Mask:=SupportedExt+Mask;
  end else Mask:=SupportedExt;
  GetPhotosNamesFromDrive(FPach,Mask,Files,FilesSearch,MaxFiles);
  SetLength(FFiles,Files.Count);
  for i:=0 to Files.Count-1 do
  FFiles[i]:=Files[i];
  Hide;
  if CheckBox1.Checked then
  With ExplorerManager.NewExplorer(False) do
  begin
   SetPath(Folder);
   Show;
   SetFocus;
  end;
  //WHAT IT??????
  GetFileNameById(0);
  Delay(1500);
  //////////////////
  try
   CopyFilesSynch(0,FFiles,Folder,ComboBox2.ItemIndex<>1,true);
  except
   MessageBoxDB(Handle,TEXT_MES_UNABLE_GET_PHOTOS_COPY_MOVE_ERROR,TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
  end;
  if CheckBox3.Checked then
  begin
   If UpdaterDB=nil then
   UpdaterDB:=TUpdaterDB.Create;
   UpdaterDB.AddDirectory(Folder,nil);
  end;
  Files.Free;
 end;

 Close;
end;

procedure TGetToPersonalFolderForm.CheckBox2Click(Sender: TObject);
begin
 Edit3.Enabled:=CheckBox2.Checked;
 Edit1Change(Sender);
end;

procedure TGetToPersonalFolderForm.DestroyTimerTimer(Sender: TObject);
begin
 DestroyTimer.Enabled:=false;
 Release;
 if UseFreeAfterRelease then Free;
end;

procedure TGetToPersonalFolderForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 DestroyTimer.Enabled:=true;
end;

procedure TGetToPersonalFolderForm.Button5Click(Sender: TObject);
var
  Options : TScanImportPhotosThreadOptions;
begin
 ThreadInProgress:=true;
 Options.Directory:=FPach;
 Options.Mask:=Edit3.Text;
 Options.OnEnd:=OnEndScanFolder;
 Options.Owner:=self;
 Options.OnProgress:=OnLoadingFilesCallBackEvent;
 TScanImportPhotosThread.Create(false,Options); 
 ProgressBar.Visible:=true;
 Button5.Visible:=false;
end;

procedure TGetToPersonalFolderForm.OnEndScanFolder(Sender: TObject);
begin
 ThreadInProgress:=false;
 ProgressBar.Visible:=ThreadInProgress;
 Button5.Visible:=not ThreadInProgress;
 RecountGroups;
 ListView1.Refresh;
 if ExtendedMode then
 Button1.Enabled:=ListView1.Items.Count>0;
 //
end;

procedure TGetToPersonalFolderForm.FormDestroy(Sender: TObject);
begin
 GetPhotosFormSID:=GetGUID; // to prevent Thread AV
end;

procedure TGetToPersonalFolderForm.OnLoadingFilesCallBackEvent(
  Sender: TObject; var Info: TProgressCallBackInfo);
begin
 ProgressBar.MaxValue:=1;
 ProgressBar.Position:=0;
 ProgressBar.Text:=Mince(Info.Information,25);
end;

procedure TGetToPersonalFolderForm.SetDataList(DataList: TFileDateList);
var
  i : integer;
  LastDate : TDateTime;
  p : PItemRecordOptions;
  Options : TGetImagesOptions;
begin
 fDataList:=DataList;
 LastDate:=0;
 ListView1.Clear;
 SetLength(OptionsArray,0);
 for i:=0 to Length(fDataList)-1 do
 begin
  if (LastDate=0) or (LastDate<>fDataList[i].Date) then
  With ListView1.Items.Add do
  begin
   LastDate:=fDataList[i].Date;
   GetMem(p,SizeOf(TItemRecordOptions));
   p^.StringDate:=DateToStr(fDataList[i].Date);
   p^.Date:=fDataList[i].Date;
   p^.Options:=DIRECTORY_OPTION_DATE_SINGLE;
   p^.Tag:=0;
   Data:=p;

   Options.Date:=fDataList[i].Date;
   Options.FolderMask:=Edit1.Text;
   Options.Comment:=Memo1.Text;
   Options.ToFolder:=Edit2.Text;
   Options.GetMultimediaFiles:=CheckBox2.Checked;
   Options.MultimediaMask:=Edit3.Text;
   Options.Move:=ComboBox2.ItemIndex=0;
   Options.OpenFolder:=CheckBox1.Checked;
   Options.AddFolder:=CheckBox3.Checked;
   SetLength(OptionsArray,Length(OptionsArray)+1);
   OptionsArray[Length(OptionsArray)-1]:=Options;
  end;
 end;
end;

procedure TGetToPersonalFolderForm.ListView1Resize(Sender: TObject);
begin
 ListView1.Columns[1].Width:=ListView1.Width-ListView1.Columns[0].Width-5;
end;

procedure TGetToPersonalFolderForm.ListView1AdvancedCustomDrawItem(
  Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  Stage: TCustomDrawStage; var DefaultDraw: Boolean);
var
  aRect : TRect;
  i : integer;

  function MergeColors(Color1,Color2 : TColor) : TColor;
  var
    r,g,b: byte;
  begin
   Color1:=ColorToRGB(Color1) and $00FFFFFF;   
   Color2:=ColorToRGB(Color2) and $00FFFFFF;
   r:=(GetRValue(Color1)*2+GetRValue(Color2)) div 3;
   g:=(GetGValue(Color1)*2+GetGValue(Color2)) div 3;
   b:=(GetBValue(Color1)*2+GetBValue(Color2)) div 3;
   Result:=RGB(r,g,b);
  end;
  
begin
 for i:=0 to 1 do
 begin
  ListView_GetSubItemRect(ListView1.Handle,Item.Index,i,0,@aRect);

  if Item.Selected then
  begin                  
   Sender.Canvas.Brush.Color:=Theme_ListSelectColor;
   Sender.Canvas.Pen.Color:=Theme_ListSelectColor;
  end else
  begin
   if TItemRecordOptions(Item.Data^).Tag=1 then
   begin
    Sender.Canvas.Brush.Color:=MergeColors(Theme_ListColor,clRed);
    Sender.Canvas.Pen.Color:=MergeColors(Theme_ListColor,clRed);
   end;
   if TItemRecordOptions(Item.Data^).Tag=0 then
   begin
    Sender.Canvas.Brush.Color:=MergeColors(Theme_ListColor,clGreen);
    Sender.Canvas.Pen.Color:=MergeColors(Theme_ListColor,clGreen);
   end;  
   if TItemRecordOptions(Item.Data^).Tag=-1 then
   begin
    Sender.Canvas.Brush.Color:=MergeColors(Theme_ListColor,clBlue);
    Sender.Canvas.Pen.Color:=MergeColors(Theme_ListColor,clBlue);
   end;
  end;
  Sender.Canvas.Rectangle(aRect);
  if i=0 then
  OptionsImageList.Draw(Sender.Canvas,aRect.Left,Item.Top,TItemRecordOptions(Item.Data^).Options);
  if i=1 then
  Sender.Canvas.TextOut(aRect.Left, Item.Top,Mince(TItemRecordOptions(Item.Data^).StringDate,50));

  DefaultDraw:=true;
 end;
end;

procedure TGetToPersonalFolderForm.ExtendedButtonClick(Sender: TObject);
begin
 if ExtendedMode then
 begin      
  ExtendedMode:=false;
  DateTimePicker1.Enabled:=true;
  Edit1.Enabled:=true;
  Memo1.Enabled:=true;
  Edit2.Enabled:=true;
  CheckBox2.Enabled:=true;
  Edit3.Enabled:=true;
  ComboBox2.Enabled:=true;
  CheckBox1.Enabled:=true;
  CheckBox3.Enabled:=true;

  try
   DateTimePicker1.Date:=DefaultOptions.Date;
  except
  end;
  Edit1.Text:=DefaultOptions.FolderMask;
  Memo1.Text:=DefaultOptions.Comment;
  Edit2.Text:=DefaultOptions.ToFolder;
  CheckBox2.Checked:=DefaultOptions.GetMultimediaFiles;
  Edit3.Text:=DefaultOptions.MultimediaMask;
  if DefaultOptions.Move then
  ComboBox2.ItemIndex:=0 else ComboBox2.ItemIndex:=1;
  CheckBox1.Checked:=DefaultOptions.OpenFolder;
  CheckBox3.Checked:=DefaultOptions.AddFolder;

  Width:=273; 
  Button2.Left:=104;
  Button1.Left:=176;
  Button5.Visible:=false;
  ProgressBar.Visible:=false;
  Label7.Visible:=false;
  ListView1.Visible:=false;
  ExtendedButton.Caption:='>';
  ExtendedButton.Left:=248;
  Button1.Enabled:=true;
 end else
 begin

  DefaultOptions.Date:=DateTimePicker1.Date;
  DefaultOptions.FolderMask:=Edit1.Text;
  DefaultOptions.Comment:=Memo1.Text;
  DefaultOptions.ToFolder:=Edit2.Text;
  DefaultOptions.GetMultimediaFiles:=CheckBox2.Checked;
  DefaultOptions.MultimediaMask:=Edit3.Text;
  DefaultOptions.Move:=ComboBox2.ItemIndex=0;
  DefaultOptions.OpenFolder:=CheckBox1.Checked;
  DefaultOptions.AddFolder:=CheckBox3.Checked;

  if ListView1.Selected=nil then
  begin
   DateTimePicker1.Enabled:=false;
   Edit1.Enabled:=false;
   Memo1.Enabled:=false;
   Edit2.Enabled:=false;
   CheckBox2.Enabled:=false;
   Edit3.Enabled:=false;
   ComboBox2.Enabled:=false;
   CheckBox1.Enabled:=false;
   CheckBox3.Enabled:=false;
  end else
  ListView1SelectItem(ListView1,ListView1.Selected,true);

  Button2.Left:=344;
  Button1.Left:=416;
  Button1.Enabled:=ListView1.Items.Count>0;
  Label7.Visible:=true;
  ListView1.Visible:=true;
  ProgressBar.Visible:=ThreadInProgress;
  Button5.Visible:=not ThreadInProgress;
  Width:=513;
  ExtendedMode:=true;
  ExtendedButton.Caption:='<';
  ExtendedButton.Left:=488;
 end;
end;

procedure TGetToPersonalFolderForm.ListView1ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  item : TListItem;
begin
 item:=ListView1.GetItemAt(10,MousePos.y);
 if item<>nil then
 begin
  PopupMenu1.Tag:=item.Index;
  item.Selected:=true;
  MoveUp1.Visible:=item.Index>0;
  MoveDown1.Visible:=item.Index<ListView1.Items.Count-1;

  MergeUp1.Visible:=MoveUp1.Visible;
  MergeDown1.Visible:=MoveDown1.Visible;

  Case TItemRecordOptions(item.Data^).Options of
   DIRECTORY_OPTION_DATE_SINGLE    :  SimpleCopy1.Default:=true;
   DIRECTORY_OPTION_DATE_WITH_UP   :  MergeUp1.Default:=true;
   DIRECTORY_OPTION_DATE_WITH_DOWN :  MergeDown1.Default:=true;
   DIRECTORY_OPTION_DATE_EXCLUDE   :  DontCopy1.Default:=true;
  end;
  PopupMenu1.Popup(ListView1.ClientToScreen(MousePos).X,ListView1.ClientToScreen(MousePos).Y);
 end;
end;

procedure TGetToPersonalFolderForm.SimpleCopy1Click(Sender: TObject);
begin
 fDataList[PopupMenu1.Tag].Options:=DIRECTORY_OPTION_DATE_SINGLE;
 TItemRecordOptions(ListView1.Items[PopupMenu1.Tag].Data^).Options:=DIRECTORY_OPTION_DATE_SINGLE;
 RecountGroups;
 ListView1.Refresh;
end;

procedure TGetToPersonalFolderForm.MergeUp1Click(Sender: TObject);
begin
 fDataList[PopupMenu1.Tag].Options:=DIRECTORY_OPTION_DATE_WITH_UP;
 TItemRecordOptions(ListView1.Items[PopupMenu1.Tag].Data^).Options:=DIRECTORY_OPTION_DATE_WITH_UP;
 OptionsArray[PopupMenu1.Tag]:=OptionsArray[PopupMenu1.Tag-1];
 RecountGroups;
 ListView1.Refresh;
end;

procedure TGetToPersonalFolderForm.MergeDown1Click(Sender: TObject);
begin
 fDataList[PopupMenu1.Tag].Options:=DIRECTORY_OPTION_DATE_WITH_DOWN;
 TItemRecordOptions(ListView1.Items[PopupMenu1.Tag].Data^).Options:=DIRECTORY_OPTION_DATE_WITH_DOWN;  
 OptionsArray[PopupMenu1.Tag]:=OptionsArray[PopupMenu1.Tag+1];
 RecountGroups;
 ListView1.Refresh;
end;

procedure TGetToPersonalFolderForm.DontCopy1Click(Sender: TObject);
begin
 fDataList[PopupMenu1.Tag].Options:=DIRECTORY_OPTION_DATE_EXCLUDE;
 TItemRecordOptions(ListView1.Items[PopupMenu1.Tag].Data^).Options:=DIRECTORY_OPTION_DATE_EXCLUDE;
 RecountGroups;
 ListView1.Refresh;
end;

procedure TGetToPersonalFolderForm.RecountGroups;
var
  i : integer;
  LastGroup : boolean;
  CurrentRecord, NextRecord : TItemRecordOptions;
begin
 LastGroup:=false;
 for i:=0 to ListView1.Items.Count-2 do
 begin
  CurrentRecord:=TItemRecordOptions(ListView1.Items[i].Data^);
  NextRecord:=TItemRecordOptions(ListView1.Items[i+1].Data^);
  if LastGroup then TItemRecordOptions(ListView1.Items[i].Data^).Tag:=0 else TItemRecordOptions(ListView1.Items[i].Data^).Tag:=1;
  if (CurrentRecord.Options=DIRECTORY_OPTION_DATE_WITH_DOWN) and (NextRecord.Options=DIRECTORY_OPTION_DATE_EXCLUDE) then
  begin
   Continue;
  end;
  if (CurrentRecord.Options=DIRECTORY_OPTION_DATE_WITH_DOWN) and (NextRecord.Options=DIRECTORY_OPTION_DATE_SINGLE) then
  begin
   Continue;
  end;
  if (CurrentRecord.Options=DIRECTORY_OPTION_DATE_WITH_DOWN) and (NextRecord.Options=DIRECTORY_OPTION_DATE_WITH_DOWN) then
  begin
   Continue;
  end;
  if (CurrentRecord.Options=DIRECTORY_OPTION_DATE_EXCLUDE) and (NextRecord.Options=DIRECTORY_OPTION_DATE_WITH_UP) then
  begin
   Continue;
  end;
  if (CurrentRecord.Options=DIRECTORY_OPTION_DATE_SINGLE) and (NextRecord.Options=DIRECTORY_OPTION_DATE_WITH_UP) then
  begin
   Continue;
  end;    
  if (CurrentRecord.Options=DIRECTORY_OPTION_DATE_WITH_UP) and (NextRecord.Options=DIRECTORY_OPTION_DATE_WITH_UP) then
  begin
   Continue;
  end;
  LastGroup:=not LastGroup;
 end;
 i:=ListView1.Items.Count-1;
 if i>-1 then
 begin
  CurrentRecord:=TItemRecordOptions(ListView1.Items[i].Data^);
  if CurrentRecord.Options<>DIRECTORY_OPTION_DATE_WITH_UP then
  begin
   if LastGroup then TItemRecordOptions(ListView1.Items[i].Data^).Tag:=0 else TItemRecordOptions(ListView1.Items[i].Data^).Tag:=1;
  end else
  begin
   if LastGroup then TItemRecordOptions(ListView1.Items[i].Data^).Tag:=1 else TItemRecordOptions(ListView1.Items[i].Data^).Tag:=0;
  end;
 end else
 begin
  Hide;
  MessageBoxDB(Handle,TEXT_MES_IMAGES_NOT_FOUND_UPDATER_CLOSED,TEXT_MES_INFORMATION,TD_BUTTON_OK,TD_ICON_WARNING);
  Close;
 end;
end;

procedure TGetToPersonalFolderForm.ShowImages1Click(Sender: TObject);
var
  info : TRecordsInfo;
  i : integer;
  Date : TDateTime;

  function L_Less_Than_R(L,R:TFileDateRecord):boolean;
  begin
   Result:=SysUtils.CompareText(ExtractFileName(L.FileName),ExtractFileName(R.FileName))<0;
  end;

  procedure Swap(var X:TFileDateList;I,J:integer);
  var
    temp : TFileDateRecord;
  begin
   temp:=X[i];
   X[i]:=X[J];
   X[J]:=temp;
  end;

  procedure Qsort(var X:TFileDateList; Left,Right:integer);
  label
     Again;
  var
     Pivot:TFileDateRecord;
     P,Q:integer;
     m : integer;
   begin
      P:=Left;
      Q:=Right;
      m:=(Left+Right) div 2;
      Pivot:=X [m];

      while P<=Q do
      begin
         while L_Less_Than_R(X[P],Pivot) do
         begin
          if p=m then break;
          inc(P);
         end;
         while L_Less_Than_R(Pivot,X[Q]) do
         begin           
          if q=m then break;
          dec(Q);
         end;
         if P>Q then goto Again;
         Swap(X,P,Q);
         inc(P);dec(Q);
      end;

      Again:
      if Left<Q  then Qsort(X,Left,Q);
      if P<Right then Qsort(X,P,Right);
   end;

  procedure QuickSort(var X:TFileDateList; N:integer);
  begin
    Qsort(X,0,N-1);
  end;

begin
 Info:=RecordsInfoNil;
 If Viewer=nil then
 Application.CreateForm(TViewer,Viewer);
 Date:=TItemRecordOptions(ListView1.Items[PopupMenu1.Tag].Data^).Date;
 QuickSort(fDataList,Length(fDataList));
 for i:=0 to Length(fDataList)-1 do
 begin
  if Date=fDataList[i].Date then
  //                                                                                                 crypted
  AddRecordsInfoOne(info,fDataList[i].FileName,0,0,0,0,'','','','','',fDataList[i].Date,true,false,0,false        ,true,true,'');
 end;
 Viewer.Execute(Sender,Info);
end;

procedure TGetToPersonalFolderForm.Remove1Click(Sender: TObject);
var
  i : integer;
begin
 if ID_OK<>MessageBoxDB(Handle,TEXT_MES_DO_YOU_REALLY_WANT_TO_THIS_ITEM,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then exit;
 ListView1.Items.Delete(PopupMenu1.Tag);
 for i:=PopupMenu1.Tag to Length(OptionsArray)-2 do
 OptionsArray[i]:=OptionsArray[i+1];
 SetLength(OptionsArray,Length(OptionsArray)-1);
 RecountGroups;
 ListView1.Refresh;
end;

procedure TGetToPersonalFolderForm.MoveUp1Click(Sender: TObject);
var
  p : Pointer;
begin
 p:=ListView1.Items[PopupMenu1.Tag-1].Data;
 ListView1.Items[PopupMenu1.Tag-1].Data:=ListView1.Items[PopupMenu1.Tag].Data;
 ListView1.Items[PopupMenu1.Tag].Data:=p;
 RecountGroups;
 ListView1.Refresh;
end;

procedure TGetToPersonalFolderForm.MoveDown1Click(Sender: TObject);
var
  p : Pointer;
begin
 p:=ListView1.Items[PopupMenu1.Tag+1].Data;
 ListView1.Items[PopupMenu1.Tag+1].Data:=ListView1.Items[PopupMenu1.Tag].Data;
 ListView1.Items[PopupMenu1.Tag].Data:=p;
 RecountGroups;
 ListView1.Refresh;
end;

procedure TGetToPersonalFolderForm.ListView1SelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  Options : TGetImagesOptions;
begin
 if (Item<>nil) and Selected then
 begin        
  DateTimePicker1.Enabled:=true;
  Edit1.Enabled:=true;
  Memo1.Enabled:=true;
  Edit2.Enabled:=true;
  CheckBox2.Enabled:=true;
  Edit3.Enabled:=true;
  ComboBox2.Enabled:=true;
  CheckBox1.Enabled:=true;
  CheckBox3.Enabled:=true;

  Options:=OptionsArray[Item.index];
  try
   DateTimePicker1.Date:=Options.Date;
  except
  end;
  Edit1.Text:=Options.FolderMask;
  Memo1.Text:=Options.Comment;
  Edit2.Text:=Options.ToFolder;
  CheckBox2.Checked:=Options.GetMultimediaFiles;
  Edit3.Text:=Options.MultimediaMask;
  if Options.Move then
  ComboBox2.ItemIndex:=0 else ComboBox2.ItemIndex:=1;

  CheckBox1.Checked:=Options.OpenFolder;
  CheckBox3.Checked:=Options.AddFolder;
  Edit1Change(self);
 end else
 begin
  DateTimePicker1.Enabled:=false;
  Edit1.Enabled:=false;
  Memo1.Enabled:=false;
  Edit2.Enabled:=false;
  CheckBox2.Enabled:=false;
  Edit3.Enabled:=false;
  ComboBox2.Enabled:=false;
  CheckBox1.Enabled:=false;
  CheckBox3.Enabled:=false; 
 end;
end;

function TGetToPersonalFolderForm.FormatFolderName(Mask, Comment: String;
  Date: TDateTime): String;
var
  S : String;
  i : integer;
  TempSysTime: TSystemTime;
  FineDate: array[0..255] of Char;
begin
 S:=Mask;
 if S='' then S:='%yy:mm:dd';
 S:=StringReplace(S,'%yy:mm:dd',FormatDateTime('yy.mm.dd',Date),[rfReplaceAll,rfIgnoreCase]);
 DateTimeToSystemTime(Date,TempSysTime);
 GetDateFormat(LOCALE_USER_DEFAULT,  DATE_USE_ALT_CALENDAR,  @TempSysTime,  'dddd, d MMMM yyyy ', @FineDate,  255);
 S:=StringReplace(S,'%YMD',FineDate+TEXT_MES_YEAR_A,[rfReplaceAll,rfIgnoreCase]);
 S:=StringReplace(S,'%coment',Comment,[rfReplaceAll,rfIgnoreCase]);
 S:=StringReplace(S,'%yyyy',FormatDateTime('yyyy',Date),[rfReplaceAll,rfIgnoreCase]);
 S:=StringReplace(S,'%yy',FormatDateTime('yy',Date),[rfReplaceAll,rfIgnoreCase]);
 GetDateFormat(LOCALE_USER_DEFAULT,  DATE_USE_ALT_CALENDAR,  @TempSysTime,  'dd MMMM', @FineDate,  255);
 S:=StringReplace(S,'%mmmdd',FineDate,[rfReplaceAll,rfIgnoreCase]);
 GetDateFormat(LOCALE_USER_DEFAULT,  DATE_USE_ALT_CALENDAR,  @TempSysTime,  'd MMMM', @FineDate,  255);
 S:=StringReplace(S,'%mmmd',FineDate,[rfReplaceAll,rfIgnoreCase]);
 S:=StringReplace(S,'%mmm',FormatDateTime('mmm',Date),[rfReplaceAll,rfIgnoreCase]);
 S:=StringReplace(S,'%mm',FormatDateTime('mm',Date),[rfReplaceAll,rfIgnoreCase]);
 S:=StringReplace(S,'%m',FormatDateTime('m',Date),[rfReplaceAll,rfIgnoreCase]);
 GetDateFormat(LOCALE_USER_DEFAULT,  DATE_USE_ALT_CALENDAR,  @TempSysTime,  'dddd', @FineDate,  255);
 S:=StringReplace(S,'%dddd',FineDate,[rfReplaceAll,rfIgnoreCase]);
 S:=StringReplace(S,'%ddd',FormatDateTime('ddd',Date),[rfReplaceAll,rfIgnoreCase]);
 S:=StringReplace(S,'%dd',FormatDateTime('dd',Date),[rfReplaceAll,rfIgnoreCase]);
 S:=StringReplace(S,'%d',FormatDateTime('d',Date),[rfReplaceAll,rfIgnoreCase]);
 for i:=Length(S) downto 1 do
 if (s[i] in unusedchar_folders) then
 Delete(S,i,1);
 if S='' then S:=FormatDateTime('yy.mm.dd',Date);
 Result:=S;
end;

end.
