unit uShellNamespaceUtils;

interface

uses
  uMemory,
  System.Classes,
  Winapi.Windows,
  Winapi.ActiveX,
  System.Win.ComObj,
  ShlObj,
  uSysUtils,
  ShellAPI;

procedure ExecuteShellPathRelativeToMyComputerMenuAction(Handle: THandle; Path: string; Files: TStrings; Verb: AnsiString);
function ClipboardHasPIDList: Boolean;
procedure PastePIDListToFolder(Handle: THandle; Folder: string);

implementation

//WPD shell extension
//code from MSDN, ported to DELPHI XE2 by Dmitry Veresov (c) 2012
(*procedure ProcessDataObject(pdto: IDataObject);
var
  fmte: TFORMATETC;
  stm: TSTGMEDIUM;
  hr: HRESULT;
  pid: PIDA;
  I: UINT;
  psfRoot: IShellFolder;
  psf2: IShellFolder2;
  pidl: PItemIDList;
  vt:  POleVariant;
  PKEY_Size: SHCOLUMNID;
  pName: TStrRet;
  spSetStorage: IPropertySetStorage;
  spPropStorage: IPropertyStorage;

  PropSpec: array of TPropSpec;
  PropVariant: array of TPropVariant;
begin
 //copy data from clipboard
 fmte.cfFormat := RegisterClipboardFormat(CFSTR_SHELLIDLIST);
 fmte.ptd:=  nil;
 fmte.dwAspect := DVASPECT_CONTENT;
 fmte.lindex := -1;
 fmte.tymed := TYMED_HGLOBAL ;

 hr := pdto.GetData(fmte, stm);
 if SUCCEEDED(hr) and (stm.hGlobal <> 0) then
 begin
  pid := PIDA(GlobalLock(stm.hGlobal));
  if (pid <> nil) then  // defend against buggy data object
  begin

   hr := SHBindToObject(nil, HIDA_GetPIDLFolder(pid), nil,
                       StringToGUID(SID_IShellFolder), Pointer(psfRoot));
   if (SUCCEEDED(hr)) then
   begin
    for i := 0 to pid.cidl - 1 do
    begin

     hr := SHBindToFolderIDListParent(psfRoot,
                HIDA_GetPIDLItem(pid, i),
                StringToGUID(SID_IShellFolder2), Pointer(psf2), pidl);
     if (SUCCEEDED(hr)) then
     begin

       hr := psf2.BindToObject(ILFindLastID(pidl), nil, StringToGUID('{0000013A-0000-0000-C000-000000000046}'), spSetStorage);
       if (SUCCEEDED(hr)) then
       begin
         hr := spSetStorage.Open(PKEY_GenericObj, STGM_READ, spPropStorage);
         if (SUCCEEDED(hr)) then
         begin

           Setlength(PropSpec, 1);
           Setlength(PropVariant, 1);
           PropSpec[0].ulKind := PRSPEC_PROPID;
           PropSpec[0].propid := WPD_OBJECT_ID; // WPD_FUNCTIONAL_OBJECT_CATEGORY

           hr := spPropStorage.ReadMultiple(1, @PropSpec[0], @PropVariant[0]);
           //profit!
         end;

       end;
     end;
    end;

   end;
   GlobalUnlock(stm.hGlobal);
  end;
  ReleaseStgMedium(&stm);
 end;
end;    *)

function GetFolder(Handle: HWND; Path: WideString): IShellFolder;
var
  Desktop: IShellFolder;
  ItemIDList: PITEMIDLIST;
  Eaten, Attr: ULONG;
begin
  Result := nil;
  if Succeeded(SHGetDesktopFolder(Desktop)) then
  begin
    if Path <> '' then
    begin
      if Succeeded(Desktop.ParseDisplayName(Handle, nil, PWideChar(Path),  Eaten, ItemIDList, Attr)) then
      begin
        Desktop.BindToObject(ItemIDList, nil, IShellFolder,
                             Result);
        CoTaskMemFree(ItemIDList);
      end;
    end;
  end;
end;

function ClipboardHasPIDList: Boolean;
var
  fmte: TFORMATETC;
  stm: TSTGMEDIUM;
  D: IDataObject;
  HR: HRESULT;
begin
  Result := False;
  HR := OleGetClipboard(D);
  if Succeeded(HR) then
  begin
    fmte.cfFormat := RegisterClipboardFormat(CFSTR_SHELLIDLIST);
    fmte.ptd:=  nil;
    fmte.dwAspect := DVASPECT_CONTENT;
    fmte.lindex := -1;
    fmte.tymed := TYMED_HGLOBAL;

    HR := D.GetData(fmte, stm);

    Result := SUCCEEDED(HR) and (stm.hGlobal <> 0);
  end;
end;

function GetDisplayName( pidl: PItemIDList; pMalloc: IMalloc; const Value: STRRET ): string;
begin
  with Value do
  case uType of
    STRRET_CSTR: Result := PChar(@cStr[0]);
    STRRET_WSTR:
    begin
      Result := pOleStr;
      pMalloc.Free( pOleStr );
    end;
    STRRET_OFFSET: Result := PChar( LongWord(pidl) + uOffset );
  end;
end;

procedure PastePIDListToFolder(Handle: THandle; Folder: string);
var
  Desktop: IShellFolder;
  HR: HRESULT;
  PathPIDL: PItemIDList;
  L: Cardinal;
  FPath: PWideChar;
  Menu: IContextMenu;
  cmd: TCMInvokeCommandInfo;
  Attr: Cardinal;
begin
  HR := SHGetDesktopFolder(Desktop);
  if Succeeded(HR) then
  begin
    FPath := StringToOleStr(Folder);
    L := Length(FPath);
    Attr := 0;
    HR := Desktop.ParseDisplayName(Handle, nil, FPath, L, PathPIDL, Attr);
    if Succeeded(HR) then
    begin
      HR := Desktop.GetUIObjectOf( 0, 1, PathPIDL, IContextMenu, nil, Pointer(Menu));
      if Succeeded(HR) then
      begin
        FillMemory( @cmd, SizeOf(cmd), 0 );
        with cmd do
        begin
          cbSize := SizeOf( cmd );
          fMask := 0;
          hwnd := 0;
          lpVerb := PAnsiChar( 'Paste' );
          nShow := SW_SHOWNORMAL;
        end;
        HR := Menu.InvokeCommand( cmd );
        OleCheck(hr);
      end;
    end;
  end;
end;

procedure ExecuteShellPathRelativeToMyComputerMenuAction(Handle: THandle; Path: string; Files: TStrings; Verb: AnsiString);
type
  TPItemIDListArray = array of PItemIDList;
var
  PathParts: TStringList;
  I, J: Integer;
  HR: HRESULT;
  pMalloc: IMalloc;
  MyComputer, CurrentFolder: IShellFolder;
  EnumIDList: IEnumIDList;
  pceltFetched: ULONG;
  rgelt: PItemIDList;
  FilePIDLs: TPItemIDListArray;
  Value: STRRET;
  Name: string;
  Menu: IContextMenu;

  procedure ExecuteMenuAction;
  var
    cmd: TCMInvokeCommandInfo;
  begin
    if Succeeded(HR) then
    begin
      FillMemory( @cmd, sizeof(cmd), 0 );
      with cmd do
      begin
        cbSize := SizeOf( cmd );
        fMask := 0;
        hwnd := 0;
        lpVerb := PAnsiChar( Verb );
        //lpVerb := PAnsiChar( 'Copy' );
        //lpVerb := PAnsiChar( 'Cut' );
        //lpVerb := PAnsiChar( 'Properties' );
        nShow := SW_SHOWNORMAL;
      end;
      HR := Menu.InvokeCommand( cmd );
    end;
  end;

begin
  if Files <> nil then
  begin
    SetLength(FilePIDLs, Files.Count + 1);
    FillChar(FilePIDLs[Files.Count], Sizeof(PItemIDList), #0);
    for I := 0 to Files.Count - 1 do
      FilePIDLs[I] := nil;
  end;

  HR := SHGetMalloc(pMalloc);
  if Succeeded(HR) then
  begin
    MyComputer := GetFolder(Handle, '::{20D04FE0-3AEA-1069-A2D8-08002B30309D}');
    PathParts := TStringList.Create;
    try
      PathParts.Delimiter := '\';
      PathParts.StrictDelimiter := True;
      PathParts.DelimitedText := Path;

      CurrentFolder := MyComputer;
      for I := 0 to PathParts.Count do
      begin
        if CurrentFolder = nil then
          Exit;

        if (I < PathParts.Count) and (PathParts[I] = '') then
          Continue;

        CurrentFolder.EnumObjects(handle, SHCONTF_FOLDERS or SHCONTF_NONFOLDERS, EnumIDList);

        pceltFetched := 1;
        while(pceltFetched = 1) do
        begin
          EnumIDList.Next(1, rgelt, pceltFetched);
          if pceltFetched > 0 then
          begin
            HR := CurrentFolder.GetDisplayNameOf(rgelt, SHGDN_INFOLDER or SHGDN_INCLUDE_NONFILESYS, Value);
            Name := GetDisplayName(rgelt, pMalloc, Value);

            if I < PathParts.Count then
            begin
              if Name = PathParts[I] then
              begin

                if I = PathParts.Count - 1 then
                begin
                  if (Files <> nil) and (Files.Count > 0) then
                  begin
                    HR := SHBindToObject(CurrentFolder, rgelt, nil, StringToGUID(SID_IShellFolder), Pointer(CurrentFolder));
                    Break;
                  end else
                  begin
                    HR := CurrentFolder.GetUIObjectOf(Handle, 1, rgelt, IContextMenu, nil, Pointer(Menu));
                    if Succeeded(HR) then
                      ExecuteMenuAction;
                  end;

                end else
                begin
                  HR := SHBindToObject(CurrentFolder, rgelt, nil, StringToGUID(SID_IShellFolder), Pointer(CurrentFolder));
                  Break;
                end;

              end;
            end else
            begin
              if Files <> nil then
              begin
                for J := 0 to Files.Count - 1 do
                begin
                  if Files[J] = Name then
                    FilePIDLs[J] := ILClone(rgelt);
                end;
              end;
            end;

          end else
            Break;
        end;
      end;

      if (Files <> nil) and (FilePIDLs <> nil) then
      begin
        HR := CurrentFolder.GetUIObjectOf(Handle,  Files.Count, FilePIDLs[0], IContextMenu, nil, Pointer(Menu));
        if Succeeded(HR) then
          ExecuteMenuAction;
      end;
    finally
      F(PathParts);
    end;
  end;

  if (Files <> nil) then
  begin
    for I := 0 to Files.Count - 1 do
      if FilePIDLs[I] <> nil then
        pMalloc.Free(FilePIDLs[I]);
  end;
end;

end.
