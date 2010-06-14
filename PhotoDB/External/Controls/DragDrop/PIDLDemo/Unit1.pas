unit Unit1;
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
  ComCtrls, ActiveX, ShellApi, ShlObj, Buttons, ExtCtrls, DropSource,
  DropPIDLSource, StdCtrls, PathCombobox, DropTarget, DropPIDLTarget,
  CommCtrl;

type

  TForm1 = class(TForm)
    ListView1: TListView;
    Panel1: TPanel;
    DropPIDLSource1: TDropPIDLSource;
    Button1: TButton;
    StatusBar1: TStatusBar;
    Label1: TLabel;
    DropPIDLTarget1: TDropPIDLTarget;
    sbUpLevel: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListView1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ListView1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Button1Click(Sender: TObject);
    procedure ListView1DblClick(Sender: TObject);
    procedure ListView1KeyPress(Sender: TObject; var Key: Char);
    procedure DropPIDLTarget1Drop(Sender: TObject; ShiftState: TShiftState;
      Point: TPoint; var Effect: Integer);
    procedure sbUpLevelClick(Sender: TObject);
    procedure DropPIDLTarget1DragOver(Sender: TObject;
      ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
  private
    DragPoint: TPoint;
    CurrentShellFolder: IShellFolder;
    CurrentFolderImageIndex: integer;
    fImageList: TImageList;
    fRecyclePIDL: pItemIdList;

    //custom component NOT installed in the IDE...
    PathComboBox: TPathComboBox;
    procedure PathComboBoxChange(Sender: TObject);

    procedure SetCurrentFolder;
    procedure RefreshListNames;
    procedure PopulateListview;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;


implementation

{$R *.DFM}

//---------------------------------------------------------------------
// TLVItemData class
// (objects used to store extra data with each Listview item)
//---------------------------------------------------------------------

type
  TLVItemData = class
    SortStr: string; {just used to sort the listview}
    RelativePIDL: pItemIDList; {each item stores its own PIDLs}
    AbsolutePIDL: pItemIDList;
  public
    destructor Destroy; override;
  end;


destructor TLVItemData.Destroy;
begin
  //nb: ShellMalloc interface declared and assigned in DropSource.pas
  ShellMalloc.Free(RelativePIDL);
  ShellMalloc.Free(AbsolutePIDL);
  inherited;
end;

//---------------------------------------------------------------------
// Local functions ...
//---------------------------------------------------------------------

//Used to sort the listview...
function ListviewSort(Item1, Item2: TListItem;
  lParam: Integer): Integer; stdcall;
Begin
  if (Item1<>nil) and (Item2<>nil) and (Item1<>Item2) then
    Result:= lstrcmpi( pChar(TLVItemData(Item1.Data).SortStr),
      pChar(TLVItemData(Item2.Data).SortStr) )
  else Result:=0;
End;
//---------------------------------------------------------------------

function GetDisplayName(Folder: IShellFolder; Pidl: PItemIdList): String;
var StrRet: TStrRet;
Begin
  Result:='';
  Folder.GetDisplayNameOf(Pidl,0,StrRet);
  case StrRet.uType of
    STRRET_WSTR: Result:=WideCharToString(StrRet.pOleStr);
    STRRET_OFFSET: Result:=PChar(UINT(Pidl)+StrRet.uOffset);
    STRRET_CSTR: Result:=StrRet.cStr;
  End;
end;
//---------------------------------------------------------------------

//Just used for sorting listview...
function GetPathName(Folder: IShellFolder; Pidl: PItemIdList): String;
var StrRet: TStrRet;
Begin
  Result:='';
  Folder.GetDisplayNameOf(Pidl,SHGDN_FORPARSING,StrRet);
  case StrRet.uType of
    STRRET_WSTR: Result:=WideCharToString(StrRet.pOleStr);
    STRRET_OFFSET: Result:=PChar(UINT(Pidl)+StrRet.uOffset);
    STRRET_CSTR: Result:=StrRet.cStr;
  End;
end;

//---------------------------------------------------------------------
// TForm1 class ...
//---------------------------------------------------------------------

procedure TForm1.FormCreate(Sender: TObject);
var
  sfi: TShFileInfo;
begin

  //get access to the shell imagelist...
  FImageList := TImageList.create(self);
  FImageList.handle :=
    shgetfileinfo('',0,sfi,sizeof(tshfileinfo), shgfi_sysiconindex or shgfi_smallicon);
  FImageList.shareimages := true;
  FImageList.BlendColor := clHighlight;
  Listview1.SmallImages := FImageList;

  //Create our custom component...
  PathComboBox := TPathComboBox.create(self);
  PathComboBox.parent := self;
  PathComboBox.top := 35;
  PathComboBox.left := 2;
  PathComboBox.width := 434;
  PathComboBox.ShowVirtualFolders := true;
  PathComboBox.OnChange := PathComboBoxChange;
  PathComboBox.path := extractfilepath(paramstr(0));

  //SetCurrentFolder;
  DropPIDLTarget1.register(Listview1);

  fRecyclePIDL := nil;
  ShGetSpecialFolderLocation(0,CSIDL_BITBUCKET	,fRecyclePIDL);

  DragPoint := Point(-1,-1);
end;
//---------------------------------------------------------------------

procedure TForm1.FormDestroy(Sender: TObject);
var
  i: integer;
begin
  DropPIDLTarget1.unregister;

  with Listview1.items do
    for i := 0 to Count-1 do
      TLVItemData(Item[i].data).free;

  FImageList.free;
  ShellMalloc.Free(fRecyclePIDL);
end;
//---------------------------------------------------------------------

procedure TForm1.ListView1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  DragPoint := Point(X,Y);
  statusbar1.simpletext := '';
end;

//---------------------------------------------------------------------
// Start a Drag and Drop (DropPIDLSource1.execute) ...
//---------------------------------------------------------------------

procedure TForm1.ListView1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
const
  AllowedAttribMask: Longint = (SFGAO_CANCOPY or SFGAO_CANMOVE);
var
  i: integer;
  attr: UINT;
  res: TDragResult;
  tmpImageList: TImageList;
  dummyPt: TPoint;
  DraggingFromRecycle: boolean;
  attributes: integer;
begin
  //if AlreadyDragging then exit;
  //Filter out all but the mouse buttons from 'Shift'...
  Shift := (Shift * [ssLeft,ssRight]);
  //Make sure mouse has moved at least 10 pixels
  //and a mouse button pressed before starting drag ...
  //(DragPoint is set in the ListView1MouseDown event)
  if  (Shift = []) or (DragPoint.X = -1) or
      ((abs(DragPoint.X - X) <10) and (abs(DragPoint.Y - Y) <10)) then exit;
  //If no files selected then exit...
  if Listview1.SelCount = 0 then exit;
  DragPoint.X := -1;

  //OK, HOW TO KNOW IF WE'RE DRAGGING FROM THE 'RECYCLE BIN'...
  DraggingFromRecycle := false;
  //ILIsEqual() doesn't seem to work in Win95/Win98 ...
  if ILIsEqual(fRecyclePIDL,PathCombobox.pidl) then
    DraggingFromRecycle := true
  else
  begin
    //OK, not great but this works in Win95/Win98 ...
    attributes := integer(GetFileAttributes(pchar(PathCombobox.path)));
    if (attributes <> -1) and (attributes and FILE_ATTRIBUTE_HIDDEN <> 0) and
       (attributes and FILE_ATTRIBUTE_SYSTEM <> 0) then
      DraggingFromRecycle := true;
  end;

  //CopyFolderPidlToList automatically deletes anything from a previous dragdrop...
  DropPIDLSource1.CopyFolderPidlToList(PathComboBox.Pidl);
  //Fill DropSource1.Files with selected files in ListView1...
  for i := 0 to Listview1.items.Count-1 do
    if (Listview1.items.item[i].Selected) then
      with TLVItemData(Listview1.items.item[i].data) do
      begin
        //make sure the shell allows us to drag each selected file/folder ...
        attr := AllowedAttribMask;
        CurrentShellFolder.GetAttributesOf(1,RelativePIDL,attr);
        //If not allowed to copy and move the quit drag...
        if (attr and AllowedAttribMask) = 0  then exit;
        DropPIDLSource1.CopyFilePidlToList(RelativePIDL);
        if DraggingFromRecycle then
          DropPIDLSource1.MappedNames.add(Listview1.items.item[i].caption);
      end;

  //Let Listview1 draw the drag image for us ...
  tmpImageList := TImageList.Create(self);
  with Listview1 do
    tmpImageList.handle :=
      ListView_CreateDragImage(Handle,Selected.index,dummyPt);
  DropPIDLSource1.images := tmpImageList;
  DropPIDLSource1.showimage := True;

  statusbar1.simpletext := 'Dragging ...';

  //DropPIDLTarget1.dragtypes := [];
  //the above line has been commented out to
  //allow dropping onto self if a subfolder is the droptarget...
  //see DropPIDLTarget1DragOver()

  //Do the dragdrop...
  res := DropPIDLSource1.execute;

  tmpImageList.Free;
  //DropPIDLTarget1.dragtypes := [dtCopy,dtMove];

  if res in [drDropCopy, drDropMove] then
    statusbar1.simpletext := 'Drag and Drop succeeded.' else
    statusbar1.simpletext := 'Drag and Drop cancelled.';

  if res <> drDropMove then exit;

  //this is a real kludge, which also may not be long enough...
  //see detailed demo for a much better solution.
  sleep(1000);

  RefreshListNames;
end;

//---------------------------------------------------------------------
// DropPIDLTarget1 Methods ...
//---------------------------------------------------------------------

//If the Listview's droptarget is a system folder then
//make sure the target highlighting is done 'cleanly'...
//otherwise don't allow the drop.
procedure TForm1.DropPIDLTarget1DragOver(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
var
  NewTargetListItem: TListItem;
begin
  NewTargetListItem := Listview1.GetItemAt(Point.X,Point.Y);

  if (NewTargetListItem = nil) then
  begin
    //if a folder was previously a droptarget cancel its droptarget status...
    if (Listview1.DropTarget <> nil) then
    begin
      //Hide the drag image...
      DropPIDLTarget1.ShowImage := false;
      //cancel current droptarget folder as droptarget...
      Listview1.DropTarget := nil;
      application.processmessages;
      //windows must have time to repaint the invalidated listview items before...
      //show the drag image again...
      DropPIDLTarget1.ShowImage := true;
    end;
    Effect := DROPEFFECT_NONE
  end
  else if (Listview1.DropTarget = NewTargetListItem) then
    //Effect := Effect  //ie: don't fiddle with Effect
  else if (TLVItemData(NewTargetListItem.data).sortstr[1] = '1') then
  begin
    //only allow file system folders to be targets...

    //Hide the drag image...
    DropPIDLTarget1.ShowImage := false;
    //cancel current droptarget folder as droptarget...
    Listview1.DropTarget := nil;
    //set the new droptarget folder...
    Listview1.DropTarget := NewTargetListItem;
    application.processmessages;
    //windows must have time to repaint the invalidated listview items before...
    //show the drag image again...
    DropPIDLTarget1.ShowImage := true;
    //Effect := Effect  //ie: don't fiddle with Effect
  end
  else
    Effect := DROPEFFECT_NONE;
end;
//---------------------------------------------------------------------

procedure TForm1.DropPIDLTarget1Drop(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
var
  i: integer;
  fos: TShFileOpStruct;
  pCharFrom, pCharTo: pChar;
  strFrom, strTo, DestPath: string;
  Operation: integer;
begin

  //first, where are we dropping TO...
  strTo := '';
  if (Listview1.DropTarget <> nil) then
    //dropping into a subfolder...
    with TLVItemData(Listview1.DropTarget.data) do
    begin
      if sortstr[1] = '1' then
        strTo := copy(sortstr,2,MAX_PATH)+#0#0
      else
        Effect := DROPEFFECT_NONE; //subfolder must be a system folder!
    end
  else if PathComboBox.path <> '' then
    //OK, dropping into current folder...
    strTo := PathComboBox.path +#0#0
  else
    Effect := DROPEFFECT_NONE; //current folder must be a system folder!

  Operation := 0;
  case Effect of
    DROPEFFECT_COPY: Operation := FO_COPY;
    DROPEFFECT_MOVE: Operation := FO_MOVE;
    else Effect := DROPEFFECT_NONE;
  end;

  //only allow a Copy or Move operation...
  //otherwise stop and signal to source that no drop occured.
  if Effect = DROPEFFECT_NONE then exit;

  //now, where are we dropping FROM...
  strFrom := '';
  with DropPIDLTarget1 do
  begin
    for i := 0 to filenames.count-1 do
      if filenames[i] = '' then
        exit else //quit if 'virtual'
        strFrom := strFrom + filenames[i] + #0;
  end;

  if strFrom = '' then
  begin
    //signal to source something wrong...
    Effect := DROPEFFECT_NONE;
    exit;
  end;
  strFrom := strFrom + #0;

  pCharFrom := StrAlloc(length(strFrom));
  move(strFrom[1],pCharFrom^,length(strFrom));
  pCharTo := StrAlloc(length(strTo));
  move(strTo[1],pCharTo^,length(strTo));

  with fos do
  begin
    wnd := self.handle;
    wFunc := Operation;
    pFrom := pCharFrom;
    pTo := pCharto;
    fFlags := FOF_ALLOWUNDO;
    hNameMappings:= nil;
  end;
  SHFileOperation(fos);

  //if dropped files need to be renamed -
  //(eg if they have been dragged from the recycle bin) ...
  with DropPIDLTarget1 do
    if MappedNames.count > 0 then
    begin
      if PathComboBox.path[length(PathComboBox.path)] <> '\' then
        DestPath := PathComboBox.path + '\' else
        DestPath := PathComboBox.path;
      for i := 0 to MappedNames.count-1 do
      begin
        if fileexists(DestPath+ extractfilename(filenames[i])) then
          renamefile(DestPath+ extractfilename(filenames[i]),
            DestPath+MappedNames[i]);
      end;
    end;

  RefreshListNames;

  StrDispose(pCharFrom);
  StrDispose(pCharTo);
end;
//---------------------------------------------------------------------

procedure TForm1.SetCurrentFolder;
var
  sfi: tshfileinfo;
begin
  if PathComboBox.Pidl <> nil then
  begin
    //Get CurrentShellFolder...
    //nb: DesktopShellFolder is a Global Variable declared in PathComboBox.
    if PathComboBox.itemindex = 0 then //Desktop folder
      CurrentShellFolder := DesktopShellFolder else
      DesktopShellFolder.BindToObject(PathComboBox.Pidl,
          nil, IID_IShellFolder, pointer(CurrentShellFolder));
    //Get CurrentFolder's ImageIndex...
    shgetfileinfo(pChar(PathComboBox.Pidl),
      0,sfi,sizeof(tshfileinfo), SHGFI_PIDL or SHGFI_ICON);
    CurrentFolderImageIndex := sfi.iIcon;
    RefreshListNames;
  end;

  //don't allow a drop onto a virtual folder...
  if PathComboBox.path <> '' then
    DropPIDLTarget1.dragtypes := [dtCopy,dtMove] else
    DropPIDLTarget1.dragtypes := [];

  sbUpLevel.enabled := (PathComboBox.ItemIndex <> 0);
end;
//---------------------------------------------------------------------

procedure TForm1.RefreshListNames;
var
  i: integer;
begin
  with Listview1.items do
  begin
    beginupdate;
    for i := 0 to Count-1 do
      TLVItemData(Item[i].data).free;
    clear;
    screen.cursor := crHourglass;
    PopulateListview;
    screen.cursor := crDefault;
    endupdate;
  end;
end;
//---------------------------------------------------------------------

procedure TForm1.PopulateListview;
var
  EnumIdList: IEnumIdList;
  tmpPIDL: pItemIDList;
  NewItem: TListItem;
  ItemData: TLVItemData;
  sfi: TShFileInfo;
  Flags, dummy: DWORD;
begin
  if CurrentShellFolder = nil then exit;

  with Listview1.items do
  begin
    //get files and folders...
    Flags := SHCONTF_FOLDERS or SHCONTF_NONFOLDERS or SHCONTF_INCLUDEHIDDEN;
    if FAILED(CurrentShellFolder.EnumObjects(0,Flags,EnumIdList)) then exit;
    while (EnumIdList.Next(1,tmpPIDL,dummy) = NOERROR) do
    begin
      NewItem := Add;
      NewItem.caption := GetDisplayName(CurrentShellFolder,tmpPIDL);
      ItemData := TLVItemData.create;
      NewItem.data := ItemData;
      ItemData.RelativePIDL := tmpPIDL;
      ItemData.AbsolutePIDL := ILCombine(PathComboBox.Pidl,tmpPIDL);
      shgetfileinfo(pChar(ItemData.AbsolutePIDL),
        0,sfi,sizeof(tshfileinfo), SHGFI_PIDL or SHGFI_ICON or SHGFI_ATTRIBUTES);
      NewItem.ImageIndex := sfi.iIcon;
      //get sort order...
      if (sfi.dwAttributes and SFGAO_FOLDER)<>0 then
      begin
        if (sfi.dwAttributes and SFGAO_FILESYSTEM)<>0 then
          //file system folder
          ItemData.SortStr := '1'+ GetPathName(CurrentShellFolder,tmpPIDL)
        else
          //virtual folder
          ItemData.SortStr := '2'+ GetPathName(CurrentShellFolder,tmpPIDL);
      end
      else
        //files
        ItemData.SortStr := '9'+ GetPathName(CurrentShellFolder,tmpPIDL);
    end;
  end;
  ListView1.CustomSort(@ListviewSort, 0);
  if Listview1.items.count > 0 then Listview1.items[0].focused := true;
end;
//---------------------------------------------------------------------

procedure TForm1.PathComboBoxChange(Sender: TObject);
begin
  SetCurrentFolder;
  caption := PathComboBox.path;
end;
//---------------------------------------------------------------------

//If a folder double-clicked - open that folder...
procedure TForm1.ListView1DblClick(Sender: TObject);
var
  SelItem: TListItem;
begin
  SelItem := Listview1.Selected;
  if SelItem = nil then exit;
  with TLVItemData(SelItem.data) do
    if (sortstr[1] < '9') then //if a folder...
      PathComboBox.Pidl := AbsolutePIDL;
end;
//---------------------------------------------------------------------

//If a folder selected - open that folder...
procedure TForm1.ListView1KeyPress(Sender: TObject; var Key: Char);
var
  SelItem: TListItem;
begin
  SelItem := Listview1.Selected;
  if (SelItem = nil) or (ord(Key) <> VK_RETURN) then exit;
  with TLVItemData(SelItem.data) do
    if (sortstr[1] < '9') then //if a folder...
      PathComboBox.Pidl := AbsolutePIDL;
end;
//---------------------------------------------------------------------

procedure TForm1.sbUpLevelClick(Sender: TObject);
var
  tmpPidl: pItemIdList;
begin
  if PathComboBox.ItemIndex > 0 then
  begin
    tmpPidl := ILClone(PathComboBox.Pidl);
    ILRemoveLastID(tmpPidl);
    PathComboBox.Pidl := tmpPidl;
    ShellMalloc.Free(tmpPidl);
  end;
end;
//---------------------------------------------------------------------

procedure TForm1.Button1Click(Sender: TObject);
begin
  close;
end;
//---------------------------------------------------------------------
//---------------------------------------------------------------------

end.

