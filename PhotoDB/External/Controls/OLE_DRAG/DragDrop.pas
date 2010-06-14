unit DragDrop;

interface

uses Windows, ActiveX, Classes, FileDrop;

type
  { TFileDropSource - источник 
  для перетаскивания файлов }
  TFileDropSource = class (TInterfacedObject, 
  IDropSource)
    constructor Create;
    function QueryContinueDrag
    (fEscapePressed: BOOL;
      grfKeyState: Longint): HResult; stdcall;
    function GiveFeedback(dwEffect: Longint): 
    HResult; stdcall;
  end;

  { THDropDataObject - объект данных с 
  информацией о перетаскиваемых файлах }
  THDropDataObject = class(TInterfacedObject, 
  IDataObject)
  private
    FDropInfo : TDragDropInfo;
  public
    constructor Create(ADropPoint : TPoint; 
    AInClient : Boolean);
    destructor Destroy; override;
    procedure Add (const s : String);
    { из IDataObject }
    function GetData(const formatetcIn: 
    TFormatEtc;
      out medium: TStgMedium): HResult; stdcall;
    function GetDataHere(const formatetc: 
    TFormatEtc;
      out medium: TStgMedium): HResult; stdcall;
    function QueryGetData(const formatetc:
    TFormatEtc): HResult;
      stdcall;
    function GetCanonicalFormatEtc(const 
    formatetc: TFormatEtc;
      out formatetcOut: TFormatEtc): 
      HResult; stdcall;
    function SetData(const formatetc: 
    TFormatEtc;
           var medium: TStgMedium;
           fRelease: BOOL): HResult; stdcall;
    function EnumFormatEtc(dwDirection: 
    Longint; out enumFormatEtc:
      IEnumFormatEtc): HResult; stdcall;
    function DAdvise(const formatetc: 
    TFormatEtc; advf: Longint;
      const advSink: IAdviseSink; 
      out dwConnection: Longint): HResult; 
      stdcall;
    function DUnadvise(dwConnection: Longint): 
    HResult; stdcall;
    function EnumDAdvise(out enumAdvise: 
    IEnumStatData): HResult;
      stdcall;
  end;

implementation

uses EnumFmt;

{ TFileDropSource }
constructor TFileDropSource.Create;
begin
  inherited Create;
  _AddRef;
end;
{
QueryContinueDrag определяет 
необходимые действия. Функция предполагает, 
что для перетаскивания используется 
только левая кнопка мыши.
}
function TFileDropSource.QueryContinueDrag
    (
      fEscapePressed: BOOL;
      grfKeyState: Longint
    ): HResult;
begin
  if (fEscapePressed) then
  begin
    Result := DRAGDROP_S_CANCEL;
  end
  else if ((grfKeyState and MK_LBUTTON) = 0) then
  begin
    Result := DRAGDROP_S_DROP;
  end
  else
  begin
    Result := S_OK;
  end;
end;

function TFileDropSource.GiveFeedback
   (
     dwEffect: Longint
    ): HResult;
begin
  case dwEffect of
    DROPEFFECT_NONE,
    DROPEFFECT_COPY,
//    DROPEFFECT_MOVE,
    DROPEFFECT_LINK,
    DROPEFFECT_SCROLL : Result := 
    DRAGDROP_S_USEDEFAULTCURSORS;
    else
      Result := S_OK;
  end;
end;

{ THDropDataObject }
constructor THDropDataObject.Create
    (
      ADropPoint : TPoint;
      AInClient : Boolean
    );
begin
  inherited Create;
  _AddRef;
  FDropInfo := TDragDropInfo.Create 
  (ADropPoint, AInClient);
end;

destructor THDropDataObject.Destroy;
begin
  if (FDropInfo <> nil) then
    FDropInfo.Free;
  inherited Destroy;
end;

procedure THDropDataObject.Add
    (
      const s : String
    );
begin
  FDropInfo.Add (s);
end;

function THDropDataObject.GetData
    (
      const formatetcIn: TFormatEtc;
      out medium: TStgMedium
    ): HResult;
begin
  Result := DV_E_FORMATETC;
  { Необходимо обнулить все поля medium 
  на случай ошибки}
  medium.tymed := 0;
  medium.hGlobal := 0;
  medium.unkForRelease := nil;

  { Если формат поддерживается, создаем 
  и возвращаем данные }
  if (QueryGetData (formatetcIn) = S_OK) then
  begin
    if (FDropInfo <> nil) then
    begin
      medium.tymed := TYMED_HGLOBAL;
      { За освобождение отвечает 
      вызывающая сторона! }
      medium.hGlobal := FDropInfo.CreateHDrop;
      Result := S_OK;
    end;
  end;
end;

function THDropDataObject.GetDataHere
    (
      const formatetc: TFormatEtc;
      out medium: TStgMedium
     ): HResult;
begin   
  Result := DV_E_FORMATETC;  { К сожалению, 
  не поддерживается }
end;

function THDropDataObject.QueryGetData
    (
      const formatetc: TFormatEtc
     ): HResult;
begin
  Result := DV_E_FORMATETC;
  with formatetc do
    if dwAspect = DVASPECT_CONTENT then
if (cfFormat = CF_HDROP) and (tymed = 
TYMED_HGLOBAL) then
        Result := S_OK;
end;

function THDropDataObject.GetCanonicalFormatEtc
    (
      const formatetc: TFormatEtc;
      out formatetcOut: TFormatEtc
     ): HResult;
begin
  formatetcOut.ptd := nil;
  Result := E_NOTIMPL;
end;

function THDropDataObject.SetData
    (
      const formatetc: TFormatEtc;
      var medium: TStgMedium;
      fRelease: BOOL
     ): HResult;
begin
  Result := E_NOTIMPL;
end;

{ EnumFormatEtc возвращает список 
поддерживаемых форматов }
function THDropDataObject.EnumFormatEtc
    (
      dwDirection: Longint;
      out enumFormatEtc:
      IEnumFormatEtc
     ): HResult;
const
  DataFormats: array [0..0] of TFormatEtc =
  (
    (
      cfFormat : CF_HDROP;
      ptd      : Nil;
      dwAspect : DVASPECT_CONTENT;
      lindex   : -1;
      tymed    : TYMED_HGLOBAL;
    )
  );
  DataFormatCount = 1;

begin
  { Поддерживается только Get. Задать 
  содержимое данных нельзя }
  if dwDirection = DATADIR_GET then
  begin
    enumFormatEtc := TEnumFormatEtc.Create
      (@DataFormats, DataFormatCount, 0);
    Result := S_OK;
  end else
  begin
    enumFormatEtc := nil;
    Result := E_NOTIMPL;
  end;
end;

{ Функции Advise не поддерживаются }
function THDropDataObject.DAdvise
    (
      const formatetc: TFormatEtc;
      advf: Longint;
      const advSink: IAdviseSink;
      out dwConnection: Longint
     ): HResult;
begin
  Result := OLE_E_ADVISENOTSUPPORTED;
end;

function THDropDataObject.DUnadvise
    (
      dwConnection: Longint
     ): HResult;
begin
  Result := OLE_E_ADVISENOTSUPPORTED;
end;
function THDropDataObject.EnumDAdvise
    (
      out enumAdvise: IEnumStatData
    ): HResult;
begin
  Result := OLE_E_ADVISENOTSUPPORTED;
end;

initialization
  OleInitialize (Nil);

finalization
  OleUninitialize;

end.

