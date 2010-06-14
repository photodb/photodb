unit FileDrop;

interface

uses Windows, ActiveX, Classes, ShlObj,SysUtils, dialogs;
type
  { TDragDropInfo слегка изменился по 
  сравнению с FMDD2.PAS }
  TDragDropInfo = class (TObject)
  private
    FInClientArea : Boolean;
    FDropPoint : TPoint;
    FFileList : TStringList;
  public
    constructor Create (ADropPoint : TPoint; 
    AInClient : Boolean);
    destructor Destroy; override;
    procedure Add (const s : String);
    property InClientArea : Boolean read 
    FInClientArea;
    property DropPoint : TPoint read 
    FDropPoint;
    property Files : TStringList read 
    FFileList;
    function CreateHDrop : HGlobal;
  end;

  TFileDropEvent = procedure 
  (DDI : TDragDropInfo) 
  of object;

  { TFileDropTarget знает, как принимать 
  сброшенные файлы }
  TFileDropTarget = class (TInterfacedObject, 
  IDropTarget)
  private
    FHandle : HWND;
    FOnFilesDropped : TFileDropEvent;
    FOnDragEnter: TNotifyEvent;
    FOnDragLeave: TNotifyEvent;
    FCanMove: boolean;
    procedure SetOnDragEnter(const Value: TNotifyEvent);
    procedure SetOnDragLeave(const Value: TNotifyEvent);
    procedure SetCanMove(const Value: boolean);
  public
    constructor Create (Handle: HWND; 
    AOnDrop: TFileDropEvent);
    destructor Destroy; override;

    { из IDropTarget }
function DragEnter(const dataObj: IDataObject; 
                       grfKeyState: Longint;
      pt: TPoint; var dwEffect: Longint)
      : HResult; stdcall;
    function DragOver(grfKeyState: Longint; 
    pt: TPoint;
      var dwEffect: Longint): HResult; stdcall;
    function DragLeave: HResult; stdcall;
    function Drop(const dataObj: IDataObject; 
                  grfKeyState: Longint; 
                  pt: TPoint;
      var dwEffect: Longint): HResult; 
      stdcall;

    property OnFilesDropped : TFileDropEvent
      read FOnFilesDropped write FOnFilesDropped;
       Procedure SetHandle(Handle : THandle);
    property OnDragEnter : TNotifyEvent read FOnDragEnter Write SetOnDragEnter;
    property OnDragLeave : TNotifyEvent read FOnDragLeave Write SetOnDragLeave;
    property CanMove : boolean Read FCanMove Write SetCanMove;
  end;

implementation

uses ShellAPI;

{ TDragDropInfo }

constructor TDragDropInfo.Create
    (
      ADropPoint : TPoint;
      AInClient : Boolean
    );
begin
  inherited Create;
  FFileList := TStringList.Create;
  FDropPoint := ADropPoint;
  FInClientArea := AInClient;
end;

destructor TDragDropInfo.Destroy;
begin
  FFileList.Free;
  inherited Destroy;
end;

procedure TDragDropInfo.Add
    (
      const s : String
    );
begin
  Files.Add (s+#0);
end;

function TDragDropInfo.CreateHDrop: HGlobal;
var
  RequiredSize : Integer;
  i : Integer;
  hGlobalDropInfo : HGlobal;
  DropFiles : PDropFiles;
  c : PChar;
begin
  {
    Построим структуру TDropFiles в памяти,
    выделенной через
    GlobalAlloc. Область памяти сделаем глобальной
    и совместной,
    поскольку она, вероятно, будет передаваться 
    другому процессу.
  }

  { Определяем необходимый размер структуры }
  RequiredSize := sizeof (TDropFiles);
  for i := 0 to Self.Files.Count-1 do
  begin
    { Длина каждой строки, плюс 1 байт для 
    терминатора }
    RequiredSize := RequiredSize + 
    Length (Self.Files[i]) + 1;
  end;
  { 1 байт для завершающего терминатора }
  inc (RequiredSize);

  hGlobalDropInfo := GlobalAlloc
((GMEM_SHARE or GMEM_MOVEABLE or GMEM_ZEROINIT), 
      RequiredSize);
  if (hGlobalDropInfo <> 0) then
  begin
    { Заблокируем область памяти, чтобы к ней 
      можно было обратиться
    }
      DropFiles := GlobalLock (hGlobalDropInfo);

    { Заполним поля структуры DropFiles }
    {
      pFiles -- смещение от начала 
      структуры до первого байта массива
      с именами файлов.
    }
    DropFiles.pFiles := sizeof (TDropFiles);
    DropFiles.pt := Self.FDropPoint;
    DropFiles.fNC := Self.InClientArea;
    DropFiles.fWide := False;

    {
      Копируем каждое имя файла в буфер.
      Буфер начинается со смещения 
      DropFiles + DropFiles.pFiles,
      то есть после последнего поля структуры.
    }
    c := PChar (DropFiles);
    c := c + DropFiles.pFiles;
    for i := 0 to Self.Files.Count-1 do
    begin
      StrCopy(c, PChar (Self.Files[i]));
      c := c + Length (Self.Files[i]);
    end;

    { Снимаем блокировку }
    GlobalUnlock (hGlobalDropInfo);
  end;

  Result := hGlobalDropInfo;
end;


{ TFileDropTarget }

constructor TFileDropTarget.Create
    (
      Handle: HWND;
      AOnDrop: TFileDropEvent
    );
begin
  inherited Create;
  _AddRef;
  FHandle := Handle;
  FCanMove:=false;
  FOnFilesDropped := AOnDrop;
  ActiveX.CoLockObjectExternal(Self,
  true, false);
  ActiveX.RegisterDragDrop (FHandle, Self);
end;

{ Destroy снимает блокировку с объекта 
и разрывает связь с ним }
destructor TFileDropTarget.Destroy;
var
  WorkHandle: HWND;
begin
  {
    Если значение FHandle не равно 0, 
    значит, связь с окном все 
    еще существует. Обратите внимание 
    на то, что FHandle необходимо
    прежде всего присвоить 0, потому 
    что CoLockObjectExternal и
    RevokeDragDrop вызывают Release, 
    что, в свою очередь, может
    привести к вызову Free и зацикливанию 
    программы.
    Подозреваю, что этот фрагмент не 
    совсем надежен. Если объект будет
    освобожден до того, как 
    счетчик ссылок упадет до 0,
    может возникнуть исключение.
  }
{  if (FHandle <> 0) then
  begin
    WorkHandle := FHandle;
    FHandle := 0;
    ActiveX.CoLockObjectExternal 
    (Self, false, true);
    ActiveX.RevokeDragDrop (WorkHandle);
  end;  }

  inherited Destroy;
end;

function TFileDropTarget.DragEnter
    (
      const dataObj: IDataObject;
      grfKeyState: Longint;
      pt: TPoint;
      var dwEffect: Longint
    ): HResult; stdcall;
begin
  dwEffect := DROPEFFECT_COPY;
  Result := S_OK;
  if Assigned(FOnDragEnter) then
  FOnDragEnter(Self);  
end;

function TFileDropTarget.DragOver
    (
      grfKeyState: Longint;
      pt: TPoint;
      var dwEffect: Longint
    ): HResult; stdcall;
begin
{ if CanMove then
 begin
  if grfKeyState and 8<>0 then dwEffect := DROPEFFECT_MOVE else
  dwEffect := DROPEFFECT_COPY;
 end else        }
  dwEffect := DROPEFFECT_COPY;
  Result := S_OK;
end;

function TFileDropTarget.DragLeave: 
HResult; stdcall;
begin
  Result := S_OK;
  if Assigned(FOnDragLeave) then
  FOnDragLeave(Self);
end;

{
  Обработка сброшенных данных.
}
function TFileDropTarget.Drop
    (
      const dataObj: IDataObject;
      grfKeyState: Longint;
      pt: TPoint;
      var dwEffect: Longint
    ): HResult; stdcall;
var
  Medium : TSTGMedium;
  Format : TFormatETC;
  NumFiles: Integer;
  i : Integer;
  rslt : Integer;
  DropInfo : TDragDropInfo;
  szFilename : array [0..MAX_PATH] of char;
  InClient : Boolean;
  DropPoint : TPoint;
begin
  dataObj._AddRef;
  {
    Получаем данные.  Структура TFormatETC 
    сообщает 
    dataObj.GetData, как получить данные 
    и в каком формате
    они должны храниться (эта информация 
    содержится в 
    структуре TSTGMedium).
  }
  Format.cfFormat := CF_HDROP;
  Format.ptd      := Nil;
  Format.dwAspect := DVASPECT_CONTENT;
  Format.lindex   := -1;
  Format.tymed    := TYMED_HGLOBAL;

  { Заносим данные в структуру Medium }
  rslt := dataObj.GetData (Format, Medium);

  {
    Если все прошло успешно, далее 
    действуем, как при операции файлового
    перетаскивания FMDD.
  }
  if (rslt = S_OK) then
  begin
    { Получаем количество файлов и
    прочие сведения }
    NumFiles := DragQueryFile
    (Medium.hGlobal, $FFFFFFFF, NIL, 0);
    InClient := DragQueryPoint
    (Medium.hGlobal, DropPoint);

    { Создаем объект TDragDropInfo }
    DropInfo := TDragDropInfo.Create
    (DropPoint, InClient);

    { Заносим все файлы в список }
    for i := 0 to NumFiles - 1 do
    begin
      DragQueryFile (Medium.hGlobal, i,
      szFilename,
                     sizeof(szFilename));
      DropInfo.Add (szFilename);
    end;
    { Если указан обработчик, вызываем его }
    if (Assigned (FOnFilesDropped)) then
    begin
      FOnFilesDropped (DropInfo);
    end;

    DropInfo.Free;
  end;
  if (Medium.unkForRelease = nil) then
    ReleaseStgMedium (Medium);

  dataObj._Release;
  dwEffect := DROPEFFECT_COPY;
  result := S_OK;
  if Assigned(FOnDragLeave) then
  FOnDragLeave(Self);
end;

procedure TFileDropTarget.SetHandle(Handle: THandle);
begin
  FHandle := Handle;
  ActiveX.RegisterDragDrop (Handle, Self);
end;

procedure TFileDropTarget.SetOnDragEnter(const Value: TNotifyEvent);
begin
  FOnDragEnter := Value;
end;

procedure TFileDropTarget.SetOnDragLeave(const Value: TNotifyEvent);
begin
  FOnDragLeave := Value;
end;

procedure TFileDropTarget.SetCanMove(const Value: boolean);
begin
  FCanMove := Value;
end;

initialization
  OleInitialize (Nil);

finalization
  OleUninitialize;

end.
