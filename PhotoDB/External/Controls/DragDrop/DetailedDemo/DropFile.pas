unit DropFile;

interface

{$include DragDrop.inc}

uses
  DropTarget, DropSource,
{$ifdef VER12_PLUS}
  ImgList,
{$endif}
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, FileCtrl, Outline, DirOutln, CommCtrl,
  ComCtrls, Grids, ActiveX, ShlObj, ComObj;

type

  // This thread is used to watch for and
  // display changes in DirectoryOutline.directory
  TDirectoryThread = class(TThread)
  private
    fListView: TListView;
    fDirectory: string;
    FWakeupEvent: THandle; //Used to signal change of directory or terminating
    FFiles: TStrings;
  protected
    procedure ScanDirectory;
    procedure UpdateListView;
    procedure SetDirectory(Value: string);
    procedure ProcessFilenameChanges(fcHandle: THandle);
  public
    constructor Create(ListView: TListView; Dir: string);
    procedure Execute; override;
    destructor Destroy; override;
    procedure WakeUp;
    property Directory: string read FDirectory write SetDirectory;
  end;


  TFormFile = class(TForm)
    DriveComboBox: TDriveComboBox;
    DirectoryOutline: TDirectoryOutline;
    Memo1: TMemo;
    ListView1: TListView;
    btnClose: TButton;
    StatusBar1: TStatusBar;
    Button1: TButton;
    DropFileTarget1: TDropFileTarget;
    Panel1: TPanel;
    DropSource1: TDropFileSource;
    ImageList1: TImageList;
    DropDummy1: TDropDummy;
    procedure DriveComboBoxChange(Sender: TObject);
    procedure DirectoryOutlineChange(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ListView1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ListView1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DropSource1Feedback(Sender: TObject; Effect: Integer;
      var UseDefaultCursors: Boolean);
    procedure DropFileTarget1Enter(Sender: TObject;
      ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
    procedure DropFileTarget1Drop(Sender: TObject; ShiftState: TShiftState;
      Point: TPoint; var Effect: Integer);
    procedure DropFileTarget1GetDropEffect(Sender: TObject;
      ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
  private
    { Private declarations }
    DragPoint: TPoint;
    SourcePath: string;
    IsEXEfile: boolean;
    DirectoryThread: TDirectoryThread;
  public
    { Public declarations }
  end;

var
  FormFile: TFormFile;

implementation

{$R *.DFM}

//CUSTOM CURSORS:
//The cursors in DropCursors.res are exactly the same as the default cursors.
//Use DropCursors.res as a template if you wish to customise your own cursors.
//For this demo we've created Cursors.res - some coloured cursors.
{$R Cursors.res}
const
   crCopy = 101; crMove = 102; crLink = 103;
   crCopyScroll = 104; crMoveScroll = 105; crLinkScroll = 106;

//----------------------------------------------------------------------------
// Miscellaneous functions
//----------------------------------------------------------------------------

//******************* AddSlash *************************
function AddSlash(path: string): string;
begin
  if (length(path) = 0) or (path[length(path)]='\') then
    result := path
  else result := path +'\';
end;

//******************* CreateLink *************************
procedure CreateLink(SourceFile, ShortCutName: String);
var
  IUnk: IUnknown;
  ShellLink: IShellLink;
  IPFile: IPersistFile;
  tmpShortCutName: string;
  WideStr: WideString;
  i: integer;
begin
  IUnk := CreateComObject(CLSID_ShellLink);
  ShellLink := IUnk as IShellLink;
  IPFile  := IUnk as IPersistFile;
  with ShellLink do
  begin
    SetPath(PChar(SourceFile));
    SetWorkingDirectory(PChar(ExtractFilePath(SourceFile)));
  end;
  ShortCutName := ChangeFileExt(ShortCutName,'.lnk');
  if fileexists(ShortCutName) then
  begin
    ShortCutName := copy(ShortCutName,1,length(ShortCutName)-4);
    i := 1;
    repeat
      tmpShortCutName := ShortCutName +'(' + inttostr(i)+ ').lnk';
      inc(i);
    until not fileexists(tmpShortCutName);
    WideStr := tmpShortCutName;
  end
  else WideStr := ShortCutName;
  IPFile.Save(PWChar(WideStr),False);
end;

//----------------------------------------------------------------------------
// TFormFile methods
//----------------------------------------------------------------------------

//******************* TFormFile.FormCreate *************************
procedure TFormFile.FormCreate(Sender: TObject);
begin
  DragPoint := point(-1,-1);
  //Register the DropTarget window...
  DropFileTarget1.Register(Listview1);
  //DropFileTarget2 is used just to show a drag image over the form as well as
  //the Listview control, just 'icing on the cake'. Note: no drop is allowed.
  DropDummy1.Register(self);

  //Load custom cursors...
  Screen.cursors[crCopy] := loadcursor(hinstance, 'COPY');
  Screen.cursors[crMove] := loadcursor(hinstance, 'MOVE');
  Screen.cursors[crLink] := loadcursor(hinstance, 'LINK');
  Screen.cursors[crCopyScroll] := loadcursor(hinstance, 'COPYSC');
  Screen.cursors[crMoveScroll] := loadcursor(hinstance, 'MOVESC');
  Screen.cursors[crLinkScroll] := loadcursor(hinstance, 'LINKSC');
end;

//******************* TFormFile.FormDestroy *************************
procedure TFormFile.FormDestroy(Sender: TObject);
begin
  if (DirectoryThread <> nil) then
  begin
    DirectoryThread.Terminate;
    DirectoryThread.WakeUp;
  end;
  //UnRegister the DropTarget window...
  DropFileTarget1.UnRegister;
  DropDummy1.UnRegister;
end;

//******************* TFormFile.Button1Click *************************
procedure TFormFile.btnCloseClick(Sender: TObject);
begin
  close;
end;

//******************* TFormFile.DriveComboBoxChange *************************
procedure TFormFile.DriveComboBoxChange(Sender: TObject);
begin
  DirectoryOutline.Drive := DriveComboBox.Drive;
end;

//******************* TFormFile.DirectoryOutlineChange *************************
procedure TFormFile.DirectoryOutlineChange(Sender: TObject);
begin
  if (DirectoryThread = nil) then
  begin
    DirectoryThread := TDirectoryThread.Create(ListView1, DirectoryOutline.Directory)
  end else
    DirectoryThread.Directory := DirectoryOutline.Directory;
end;

//******************* TFormFile.ListView1MouseDown *************************
procedure TFormFile.ListView1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  DragPoint := Point(X,Y);
end;

//******************* TFormFile.ListView1MouseMove *************************
procedure TFormFile.ListView1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  i: integer;
  Filename: string;
  Res: TDragResult;
begin

  //Make sure mouse has moved at least 10 pixels before starting drag ...
  if (DragPoint.X = -1) or ((Shift <> [ssLeft]) and (Shift <> [ssRight])) or
     ((abs(DragPoint.X - X) <10) and (abs(DragPoint.Y - Y) <10)) then exit;
  //If no files selected then exit...
  if Listview1.SelCount = 0 then exit;

  Statusbar1.simpletext := '';
  DropSource1.Files.clear;
  //DropSource1.MappedNames.clear;

  //Fill DropSource1.Files with selected files in ListView1
  for i := 0 to Listview1.items.Count-1 do
    if (Listview1.items.item[i].Selected) then
    begin
      Filename :=
        AddSlash(DirectoryOutline.Directory)+Listview1.items.item[i].caption;
      DropSource1.Files.Add(Filename);
      //DropSource1.MappedNames.Add('NewFileName'+inttostr(i+1));
    end;

  DropFileTarget1.Dragtypes := [];
  //--------------------------
    res := DropSource1.execute;
  //--------------------------
  DropFileTarget1.Dragtypes := [dtCopy,dtMove,dtLink];

  //Note:
  //The target is responsible from this point on
  //for the copying/moving/linking of the file
  //but the target feeds back to the source what
  //(should have) happened via the returned value of Execute.

  //Feedback in Statusbar1 what happened...
  with StatusBar1 do
    case Res of
      drDropCopy: simpletext := 'Copied successfully';
      drDropMove: simpletext := 'Moved successfully';
      drDropLink: simpletext := 'Linked successfully';
      drCancel: simpletext := 'Drop was cancelled';
      drOutMemory: simpletext := 'Drop cancelled - out of memory';
      else simpletext := 'Drop cancelled - unknown reason';
    end;

end;

//Demonstrates CopyToClipboard method...
//******************* TFormFile.Button1Click *************************
procedure TFormFile.Button1Click(Sender: TObject);
var
  i: integer;
  Filename: string;
begin
  if Listview1.selcount = 0 then
  begin
    StatusBar1.simpletext := 'No files have been selected!';
    exit;
  end;

  DropSource1.Files.clear;
  for i := 0 to Listview1.items.Count-1 do
    if (Listview1.items.item[i].Selected) then
    begin
      Filename :=
        AddSlash(DirectoryOutline.Directory)+Listview1.items.item[i].caption;
      DropSource1.Files.Add(Filename);
    end;
//--------------------------
  DropSource1.CopyToClipboard;
//--------------------------
  DropSource1.Files.clear; //added for safety
  StatusBar1.simpletext :=
    format('%d  file(s) copied to clipboard.',[Listview1.selcount]);

end;

//--------------------------
// SOURCE events...
//--------------------------

//******************* TFormFile.DropSource1Feedback *************************
procedure TFormFile.DropSource1Feedback(Sender: TObject; Effect: Integer;
  var UseDefaultCursors: Boolean);
begin
  UseDefaultCursors := false; //We want to use our own.
  case DWORD(Effect) of
    DROPEFFECT_COPY: Windows.SetCursor(Screen.Cursors[crCopy]);
    DROPEFFECT_MOVE: Windows.SetCursor(Screen.Cursors[crMove]);
    DROPEFFECT_LINK: Windows.SetCursor(Screen.Cursors[crLink]);
    DROPEFFECT_SCROLL OR DROPEFFECT_COPY:
      Windows.SetCursor(Screen.Cursors[crCopyScroll]);
    DROPEFFECT_SCROLL OR DROPEFFECT_MOVE:
      Windows.SetCursor(Screen.Cursors[crMoveScroll]);
    DROPEFFECT_SCROLL OR DROPEFFECT_LINK:
      Windows.SetCursor(Screen.Cursors[crLinkScroll]);
  else UseDefaultCursors := true; //Use default NoDrop
  end;

end;

//--------------------------
// TARGET events...
//--------------------------

//******************* TFormFile.DropFileTarget1Enter *************************
procedure TFormFile.DropFileTarget1Enter(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
begin
  //Note: GetDataOnEnter = true ...
  //saves the location (path) of the files being dragged.
  //Also flags if an EXE file.
  //This info will be used to set the default (ie. no Shift or Ctrl Keys pressed)
  //drag behaviour, whether COPY, MOVE or LINK
  if (DropFileTarget1.Files.count > 0) then
  begin
    SourcePath := extractfilepath(DropFileTarget1.Files[0]);
    if (DropFileTarget1.Files.count = 1) and
         (lowercase(extractfileext(DropFileTarget1.Files[0])) ='.exe') then
      IsEXEfile := true else 
      IsEXEfile := false;
  end;
end;

//******************* TFormFile.DropFileTarget1Drop *************************
procedure TFormFile.DropFileTarget1Drop(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
var
  i, SuccessCnt: integer;
  NewFilename: string;
  newPath: string;
begin
  SuccessCnt := 0;
  NewPath := AddSlash(DirectoryOutline.Directory);
  with DropFileTarget1 do
  begin
    for i := 0 to Files.count-1 do
    begin
      //Name mapping occurs when dragging files from Recycled Bin...
      //In most situations Name Mapping can be ignored entirely.
      if i < MappedNames.count then
        NewFilename := NewPath+MappedNames[i] else
        NewFilename := NewPath+ExtractFilename(Files[i]);

      if (Effect = DROPEFFECT_LINK) then
      begin
        CreateLink(Files[i], NewFilename);
        inc(SuccessCnt);
        continue;
      end;

      if NewFilename = Files[i] then
      begin
        windows.messagebox(handle,
          'The destination folder is the same as the source!',
          'DropSource Demo', mb_iconStop or mb_OK);
        Break;
      end;
      if not fileexists(NewFilename) then
        try
          if (Effect = DROPEFFECT_MOVE) and
              renamefile(Files[i],NewFilename) then
            inc(SuccessCnt)
          else if (Effect = DROPEFFECT_COPY) and
                    copyfile(PChar(Files[i]),PChar(NewFilename),true) then
            inc(SuccessCnt);
        except
        end;
    end; {for loop}

    if (Effect = DROPEFFECT_MOVE) then
      StatusBar1.simpletext :=
        format('%d file(s) were moved.   Files dropped at point (%d,%d).',
          [SuccessCnt, Point.x,Point.y])
    else if (Effect = DROPEFFECT_COPY) then
      StatusBar1.simpletext :=
        format('%d file(s) were copied.   Files dropped at point (%d,%d).',
          [SuccessCnt, Point.x,Point.y])
    else
      StatusBar1.simpletext :=
        format('%d file(s) were linked.   Files dropped at point (%d,%d).',
          [SuccessCnt, Point.x,Point.y]);
  end;
end;

//******************* TFormFile.DropFileTarget1GetDropEffect *************************
procedure TFormFile.DropFileTarget1GetDropEffect(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
begin
  //Note: The 'Effect' parameter (on event entry) is the
  //set of effects allowed by both the source and target.
  //Use this event when you wish to override the Default behaviour...

  //We're only interested in ssShift & ssCtrl here so
  //mouse buttons states are screened out ...
  ShiftState := ([ssShift, ssCtrl] * ShiftState);

  //if source and target paths are the same then DROPEFFECT_NONE
  if (AddSlash(DirectoryOutline.Directory) = SourcePath) then
    Effect := DROPEFFECT_NONE
  //else if Ctrl+Shift...
  else if (ShiftState = [ssShift, ssCtrl]) and
    (Effect and DROPEFFECT_LINK<>0) then Effect := DROPEFFECT_LINK
  //else if Shift...
  else if (ShiftState = [ssShift]) and
    (Effect and DROPEFFECT_MOVE<>0) then Effect := DROPEFFECT_MOVE
  //else if Ctrl...
  else if (ShiftState = [ssCtrl]) and
    (Effect and DROPEFFECT_COPY<>0) then Effect := DROPEFFECT_COPY
  //else if dragging a single EXE file then default to LINK ...
  else if IsEXEfile and (Effect and DROPEFFECT_LINK<>0) then
    Effect := DROPEFFECT_LINK
  //else if source and target drives are the same then default to MOVE
  else if (SourcePath <> '') and (DirectoryOutline.Directory[1] = SourcePath[1]) and
    (Effect and DROPEFFECT_MOVE<>0) then Effect := DROPEFFECT_MOVE
  else if (Effect and DROPEFFECT_COPY<>0) then Effect := DROPEFFECT_COPY
  else if (Effect and DROPEFFECT_MOVE<>0) then Effect := DROPEFFECT_MOVE
  else if (Effect and DROPEFFECT_LINK<>0) then Effect := DROPEFFECT_LINK
  else Effect := DROPEFFECT_NONE;

  //Adding DROPEFFECT_SCROLL to Effect will now
  //automatically scroll the target window.
  if (Point.Y < 15) or (Point.Y > Listview1.clientheight-15) then
    Effect := Effect or integer(DROPEFFECT_SCROLL);
end;

//----------------------------------------------------------------------------
// TDirectoryThread methods
//----------------------------------------------------------------------------

//OK, we're showing off ... it's a little fiddly for a demo ...
//but still you can see what can be done.

//******************* TDirectoryThread.Create *************************
constructor TDirectoryThread.Create(ListView: TListView; Dir: string);
begin
  inherited Create(True);

  fListView := ListView;
  FreeOnTerminate := true;
  Priority := tpLowest;
  fDirectory := Dir;
  FWakeupEvent := windows.CreateEvent(nil, False, False, nil);
  FFiles := TStringList.Create;

  Resume;
end;

//******************* TDirectoryThread.Destroy *************************
destructor TDirectoryThread.Destroy;
begin
  CloseHandle(FWakeupEvent);
  FFiles.Free;
  inherited Destroy;
end;

//******************* TDirectoryThread.WakeUp *************************
procedure TDirectoryThread.WakeUp;
begin
  SetEvent(FWakeupEvent);
end;

//******************* TDirectoryThread.SetDirectory *************************
procedure TDirectoryThread.SetDirectory(Value: string);
begin
  if (Value = FDirectory) then
    exit;
  FDirectory := Value;
  WakeUp;
end;

//******************* TWaitThread.ScanDirectory *************************
procedure TDirectoryThread.ScanDirectory;
var
  sr: TSearchRec;
  res: integer;
begin
  FFiles.Clear;
  res := FindFirst(AddSlash(fDirectory)+'*.*', 0, sr);
  try
    while (res = 0) and (not Terminated) do
    begin
      if (sr.name <> '.') and (sr.name <> '..') then
        FFiles.Add(lowercase(sr.name));
      res := FindNext(sr);
    end;
  finally
    FindClose(sr);
  end;
end;

//******************* TDirectoryThread.UpdateListView *************************
procedure TDirectoryThread.UpdateListView;
var
  NewItem : TListItem;
  i: integer;
begin
  with fListView.items do
  begin
    beginupdate;
    clear;
    for i := 0 to FFiles.Count-1 do
    begin
      NewItem := Add;
      NewItem.Caption := FFiles[i];
    end;
    if count > 0 then fListView.itemfocused := item[0];
    endupdate;
  end;
  FFiles.Clear;
end;

//******************* TWaitThread.Execute *************************
procedure TDirectoryThread.Execute;
var
  fFileChangeHandle : THandle;
begin

  //OUTER LOOP - which will exit only when terminated ...
  //  directory changes will be processed within this OUTER loop
  //  (file changes will be processed within the INNER loop)
  while (not Terminated) do
  begin
    ScanDirectory;
    Synchronize(UpdateListView);

    //Monitor directory for file changes
    fFileChangeHandle :=
      FindFirstChangeNotification(PChar(fDirectory), false, FILE_NOTIFY_CHANGE_FILE_NAME);
    if (fFileChangeHandle = INVALID_HANDLE_VALUE) then
      //Can't monitor filename changes! Just wait for change of directory or terminate
      WaitForSingleObject(FWakeupEvent, INFINITE)
    else
      try
        //This function performs an INNER loop...
        ProcessFilenameChanges(fFileChangeHandle);
      finally
        FindCloseChangeNotification(fFileChangeHandle);
      end;
  end;
end;

//******************* TWaitThread.ProcessFilenameChanges *************************
procedure TDirectoryThread.ProcessFilenameChanges(fcHandle: THandle);
var
  WaitResult : DWORD;
  HandleArray : array[0..1] of THandle;
begin
  HandleArray[0] := FWakeupEvent;
  HandleArray[1] := fcHandle;
  //INNER LOOP -
  //  which will exit only if terminated or the directory is changed
  //  filename changes will be processed within this loop
  while (not Terminated) do
  begin
    //wait for either filename or directory change, or terminate...
    WaitResult := WaitForMultipleObjects(2, @HandleArray, False, INFINITE);

    if (WaitResult = WAIT_OBJECT_0 + 1) then //filename has changed
    begin
      repeat //collect all immediate filename changes...
        FindNextChangeNotification(fcHandle);
      until Terminated or (WaitForSingleObject(fcHandle, 0) <> WAIT_OBJECT_0);
      if Terminated then break;
      //OK, now update (before restarting inner loop)...
      ScanDirectory;
      Synchronize(UpdateListView);
    end else
    begin // Either directory changed or terminated ...
      //collect all (almost) immediate directory changes before exiting...
      while (not Terminated) and
        (WaitForSingleObject(FWakeupEvent, 100) = WAIT_OBJECT_0) do;
      break;
    end;
  end;
end;

end.
