unit uFreeImageIO;

interface

uses
  Classes,
  FreeImage;

procedure SetStreamFreeImageIO(var IO: FreeImageIO);

implementation

function StreamFI_ReadProc(buffer: Pointer; size, count: Cardinal;
  handle: fi_handle): Cardinal; stdcall;
begin
  Result := Cardinal(TStream(handle).Read(buffer^, size * count));
end;

function StreamFI_WriteProc(buffer: Pointer; size, count: Cardinal;
  handle: fi_handle): Cardinal; stdcall;
begin
  Result := TStream(handle).Write(buffer^, size * count);
end;

function StreamFI_SeekProc(handle: fi_handle; offset: LongInt;
  origin: Integer): Integer; stdcall;
begin
  Result := TStream(handle).Seek(offset, origin);
end;

function StreamFI_TellProc(handle: fi_handle): LongInt; stdcall;
begin
  Result := LongInt(TStream(handle).Position);
end;

procedure SetStreamFreeImageIO(var IO: FreeImageIO);
begin
  IO.read_proc := StreamFI_ReadProc;
  IO.write_proc := StreamFI_WriteProc;
  IO.seek_proc := StreamFI_SeekProc;
  IO.tell_proc := StreamFI_TellProc;
end;

end.
