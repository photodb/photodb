unit VistaDialogInterfaces;

interface

uses Windows, Classes, Controls, ShlObj, ActiveX;

const
 { IShellItem }

  {$EXTERNALSYM SIGDN_NORMALDISPLAY}
  SIGDN_NORMALDISPLAY                 = 0;
  {$EXTERNALSYM SIGDN_PARENTRELATIVEPARSING}
  SIGDN_PARENTRELATIVEPARSING         = $80018001;
  {$EXTERNALSYM SIGDN_DESKTOPABSOLUTEPARSING}
  SIGDN_DESKTOPABSOLUTEPARSING        = $80028000;
  {$EXTERNALSYM SIGDN_PARENTRELATIVEEDITING}
  SIGDN_PARENTRELATIVEEDITING         = $80031001;
  {$EXTERNALSYM SIGDN_DESKTOPABSOLUTEEDITING}
  SIGDN_DESKTOPABSOLUTEEDITING        = $8004c000;
  {$EXTERNALSYM SIGDN_FILESYSPATH}
  SIGDN_FILESYSPATH                   = $80058000;
  {$EXTERNALSYM SIGDN_URL}
  SIGDN_URL                           = $80068000;
  {$EXTERNALSYM SIGDN_PARENTRELATIVEFORADDRESSBAR}
  SIGDN_PARENTRELATIVEFORADDRESSBAR   = $8007c001;
  {$EXTERNALSYM SIGDN_PARENTRELATIVE}
  SIGDN_PARENTRELATIVE                = $80080001;

  {$EXTERNALSYM SICHINT_DISPLAY}
  SICHINT_DISPLAY                     = 0;
  {$EXTERNALSYM SICHINT_ALLFIELDS}
  SICHINT_ALLFIELDS                   = $80000000;

type
  {$EXTERNALSYM PROPID}
  PROPID = ULONG;
  PPropID = ^TPropID;
  TPropID = PROPID;

  {$EXTERNALSYM _tagpropertykey}
  _tagpropertykey = packed record
    fmtid: TGUID;
    pid: DWORD;
  end;
  {$EXTERNALSYM PROPERTYKEY}
  PROPERTYKEY = _tagpropertykey;
  PPropertyKey = ^TPropertyKey;
  TPropertyKey = _tagpropertykey;


const
  SID_IModalWindow       = '{b4db1657-70d7-485e-8e3e-6fcb5a5c1802}';
  SID_IEnumShellItem     = '{70629033-e363-4a28-a567-0db78006e6d7}';
  SID_IShellItem         = '{43826d1e-e718-42ee-bc55-a1e261c37bfe}';
  SID_IShellItemFilter   = '{2659B475-EEB8-48b7-8F07-B378810F48CF}';
  SID_IShellItemArray    = '{b63ea76d-1f85-456f-a19c-48159efa858b}';
  SID_IPropertyStore     = '{886d8eeb-8cf2-4446-8d02-cdba1dbdcf99}';
  SID_IPropertyDescriptionList = '{1f9fc1d0-c39b-4b26-817f-011967d3440e}';
  SID_IFileOperationProgressSink = '{04b0f1a7-9490-44bc-96e1-4296a31252e2}';
  SID_IFileDialogCustomize = '{e6fdd21a-163f-4975-9c8c-a69f1ba37034}';
  SID_IFileDialogEvents  = '{973510db-7d7f-452b-8975-74a85828d354}';
  SID_IFileDialogControlEvents = '{36116642-D713-4b97-9B83-7484A9D00433}';
  SID_IFileDialog        = '{42f85136-db7e-439c-85f1-e4075d135fc8}';
  SID_IFileOpenDialog    = '{d57c7288-d4ad-4768-be02-9d969532d960}';
  SID_IFileSaveDialog    = '{84bccd23-5fde-4cdb-aea4-af64b83d78ab}';

  {$EXTERNALSYM CLSID_ShelllItem}
  CLSID_ShelllItem: TGUID = (
    D1:$43826d1e; D2:$e718; D3:$42ee; D4:($bc,$55,$a1,$e2,$61,$c3,$7b,$fe));
  {$EXTERNALSYM CLSID_FileOpenDialog}
  CLSID_FileOpenDialog: TGUID = (
    D1:$DC1C5A9C; D2:$E88A; D3:$4DDE; D4:($A5,$A1,$60,$F8,$2A,$20,$AE,$F7));
  {$EXTERNALSYM CLSID_FileSaveDialog}
  CLSID_FileSaveDialog: TGUID = (
    D1:$C0B4E2F3; D2:$BA21; D3:$4773; D4:($8D,$BA,$33,$5E,$C9,$46,$EB,$8B));

type
// The following declarations require Windows >= Vista

  {$EXTERNALSYM _COMDLG_FILTERSPEC}
  _COMDLG_FILTERSPEC = packed record
    pszName: LPCWSTR;
    pszSpec: LPCWSTR;
  end;
  {$EXTERNALSYM COMDLG_FILTERSPEC}
  COMDLG_FILTERSPEC = _COMDLG_FILTERSPEC;
  PComdlgFilterSpec = ^TComdlgFilterSpec;
  TComdlgFilterSpec = COMDLG_FILTERSPEC;

  { IModalWindow }

  {$EXTERNALSYM IModalWindow}
  IModalWindow = interface(IUnknown)
    [SID_IModalWindow]
    function Show(hwndParent: HWND): HResult; stdcall;
  end;

  { IEnumShellItems }

  {$EXTERNALSYM IEnumShellItems}
  IEnumShellItems = interface(IUnknown)
    [SID_IEnumShellItem]
    function Next(celt: ULONG; out rgelt; pceltFetched: PLongint): HResult; stdcall;
    function Skip(celt: ULONG): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out ppenum: IEnumShellItems): HResult; stdcall;
  end;

  { IShellItem }

type
  {$EXTERNALSYM IShellItem}
  IShellItem = interface(IUnknown)
    [SID_IShellItem]
    function BindToHandler(const pbc: IBindCtx; const bhid: TGUID;
      const riid: TIID; out ppv): HResult; stdcall;
    function GetParent(var ppsi: IShellItem): HResult; stdcall;
    function GetDisplayName(sigdnName: DWORD; var ppszName: LPWSTR): HResult; stdcall;
    function GetAttributes(sfgaoMask: DWORD; var psfgaoAttribs: DWORD): HResult; stdcall;
    function Compare(const psi: IShellItem; hint: DWORD;
      var piOrder: Integer): HResult; stdcall;
  end;

  { IShellItemFilter }

type
  {$EXTERNALSYM IShellItemFilter}
  IShellItemFilter = interface(IUnknown)
    [SID_IShellItemFilter]
    function IncludeItem(const psi: IShellItem): HResult; stdcall;
    function GetEnumFlagsForItem(const psi: IShellItem;
      var pgrfFlags: DWORD): HResult; stdcall;
  end;

  { IShellItemArray }

const
  {$EXTERNALSYM SIATTRIBFLAGS_AND}
  SIATTRIBFLAGS_AND           = $1;
  {$EXTERNALSYM SIATTRIBFLAGS_OR}
  SIATTRIBFLAGS_OR            = $2;
  {$EXTERNALSYM SIATTRIBFLAGS_APPCOMPAT}
  SIATTRIBFLAGS_APPCOMPAT     = $3;
  {$EXTERNALSYM SIATTRIBFLAGS_MASK}
  SIATTRIBFLAGS_MASK          = $3;

type
  {$EXTERNALSYM IShellItemArray}
  IShellItemArray = interface(IUnknown)
    [SID_IShellItemArray]
    function BindToHandler(const pbc: IBindCtx; const rbhid: TGUID;
      const riid: TIID; out ppvOut): HResult; stdcall;
    function GetPropertyStore(flags: DWORD; const riid: TIID; out ppv): HResult; stdcall;
    function GetPropertyDescriptionList(const keyType: TPropertyKey;
      const riid: TIID; out ppv): HResult; stdcall;
    function GetAttributes(dwAttribFlags: DWORD; sfgaoMask: DWORD;
      var psfgaoAttribs: DWORD): HResult; stdcall;
    function GetCount(var pdwNumItems: DWORD): HResult; stdcall;
    function GetItemAt(dwIndex: DWORD; var ppsi: IShellItem): HResult; stdcall;
    function EnumItems(var ppenumShellItems: IEnumShellItems): HResult; stdcall;
  end;

{ IFileDialogCustomize }

const
  {$EXTERNALSYM CDCS_INACTIVE}
  CDCS_INACTIVE       = 0;
  {$EXTERNALSYM CDCS_ENABLED}
  CDCS_ENABLED        = $1;
  {$EXTERNALSYM CDCS_VISIBLE}
  CDCS_VISIBLE        = $2;

type
  {$EXTERNALSYM IFileDialogCustomize}
  IFileDialogCustomize = interface(IUnknown)
    [SID_IFileDialogCustomize]
    function EnableOpenDropDown(dwIDCtl: DWORD): HResult; stdcall;
    function AddMenu(dwIDCtl: DWORD; pszLabel: LPCWSTR): HResult; stdcall;
    function AddPushButton(dwIDCtl: DWORD; pszLabel: LPCWSTR): HResult; stdcall;
    function AddComboBox(dwIDCtl: DWORD): HResult; stdcall;
    function AddRadioButtonList(dwIDCtl: DWORD): HResult; stdcall;
    function AddCheckButton(dwIDCtl: DWORD; pszLabel: LPCWSTR; bChecked: BOOL): HResult; stdcall;
    function AddEditBox(dwIDCtl: DWORD; pszText: LPCWSTR): HResult; stdcall;
    function AddSeparator(dwIDCtl: DWORD): HResult; stdcall;
    function AddText(dwIDCtl: DWORD; pszText: LPCWSTR): HResult; stdcall;
    function SetControlLabel(dwIDCtl: DWORD; pszLabel: LPCWSTR): HResult; stdcall;
    function GetControlState(dwIDCtl: DWORD; out pdwState: DWORD): HResult; stdcall;
    function SetControlState(dwIDCtl: DWORD; dwState: DWORD): HResult; stdcall;
    function GetEditBoxText(dwIDCtl: DWORD; out ppszText: LPCWSTR): HResult; stdcall;
    function SetEditBoxText(dwIDCtl: DWORD; pszText: LPCWSTR): HResult; stdcall;
    function GetCheckButtonState(dwIDCtl: DWORD; out pbChecked: BOOL): HResult; stdcall;
    function SetCheckButtonState(dwIDCtl: DWORD; bChecked: BOOL): HResult; stdcall;
    function AddControlItem(dwIDCtl: DWORD; dwIDItem: DWORD; pszLabel: LPCWSTR): HResult; stdcall;
    function RemoveControlItem(dwIDCtl: DWORD; dwIDItem: DWORD): HResult; stdcall;
    function RemoveAllControlItems(dwIDCtl: DWORD): HResult; stdcall;
    function GetControlItemState(dwIDCtl: DWORD; dwIDItem: DWORD; out pdwState: DWORD): HResult; stdcall;
    function SetControlItemState(dwIDCtl: DWORD; dwIDItem: DWORD; dwState: DWORD): HResult; stdcall;
    function GetSelectedControlItem(dwIDCtl: DWORD; out pdwIDItem: DWORD): HResult; stdcall;
    function SetSelectedControlItem(dwIDCtl: DWORD; dwIDItem: DWORD): HResult; stdcall;
    function StartVisualGroup(dwIDCtl: DWORD; pszLabel: LPCWSTR): HResult; stdcall;
    function EndVisualGroup: HResult; stdcall;
    function MakeProminent(dwIDCtl: DWORD): HResult; stdcall;
    function SetControlItemText(dwIDCtl: DWORD; dwIDItem: DWORD; pszLabel: LPCWSTR): HResult; stdcall;
  end;

{ IFileDialogEvents }

const
  {$EXTERNALSYM FDEOR_DEFAULT}
  FDEOR_DEFAULT       = 0;
  {$EXTERNALSYM FDEOR_ACCEPT}
  FDEOR_ACCEPT        = $1;
  {$EXTERNALSYM FDEOR_REFUSE}
  FDEOR_REFUSE        = $2;

  {$EXTERNALSYM FDESVR_DEFAULT}
  FDESVR_DEFAULT      = 0;
  {$EXTERNALSYM FDESVR_ACCEPT}
  FDESVR_ACCEPT       = $1;
  {$EXTERNALSYM FDESVR_REFUSE}
  FDESVR_REFUSE       = $2;

  {$EXTERNALSYM FDAP_BOTTOM}
  FDAP_BOTTOM         = 0;
  {$EXTERNALSYM FDAP_TOP}
  FDAP_TOP            = $1;

type
  IFileDialog = interface;

  {$EXTERNALSYM IFileDialogEvents}
  IFileDialogEvents = interface(IUnknown)
    [SID_IFileDialogEvents]
    function OnFileOk(const pfd: IFileDialog): HResult; stdcall;
    function OnFolderChanging(const pfd: IFileDialog;
      const psiFolder: IShellItem): HResult; stdcall;
    function OnFolderChange(const pfd: IFileDialog): HResult; stdcall;
    function OnSelectionChange(const pfd: IFileDialog): HResult; stdcall;
    function OnShareViolation(const pfd: IFileDialog; const psi: IShellItem;
      out pResponse: DWORD): HResult; stdcall;
    function OnTypeChange(const pfd: IFileDialog): HResult; stdcall;
    function OnOverwrite(const pfd: IFileDialog; const psi: IShellItem;
      out pResponse: DWORD): HResult; stdcall;
  end;

  { IFileDialogControlEvents }

  {$EXTERNALSYM IFileDialogControlEvents}
  IFileDialogControlEvents = interface(IUnknown)
    [SID_IFileDialogControlEvents]
    function OnItemSelected(const pfdc: IFileDialogCustomize; dwIDCtl: DWORD;
      dwIDItem: DWORD): HResult; stdcall;
    function OnButtonClicked(const pfdc: IFileDialogCustomize;
      dwIDCtl: DWORD): HResult; stdcall;
    function OnCheckButtonToggled(const pfdc: IFileDialogCustomize;
      dwIDCtl: DWORD; bChecked: BOOL): HResult; stdcall;
    function OnControlActivating(const pfdc: IFileDialogCustomize;
      dwIDCtl: DWORD): HResult; stdcall;
  end;

  { IFileDialog }

  TComdlgFilterSpecArray = array of TComdlgFilterSpec;

  {$EXTERNALSYM IFileDialog}
  IFileDialog = interface(IModalWindow)
    [SID_IFileDialog]
    function SetFileTypes(cFileTypes: UINT; rgFilterSpec: TComdlgFilterSpecArray): HResult; stdcall;
    function SetFileTypeIndex(iFileType: UINT): HResult; stdcall;
    function GetFileTypeIndex(var piFileType: UINT): HResult; stdcall;
    function Advise(const pfde: IFileDialogEvents; var pdwCookie: DWORD): HResult; stdcall;
    function Unadvise(dwCookie: DWORD): HResult; stdcall;
    function SetOptions(fos: DWORD): HResult; stdcall;
    function GetOptions(var pfos: DWORD): HResult; stdcall;
    function SetDefaultFolder(const psi: IShellItem): HResult; stdcall;
    function SetFolder(const psi: IShellItem): HResult; stdcall;
    function GetFolder(var ppsi: IShellItem): HResult; stdcall;
    function GetCurrentSelection(var ppsi: IShellItem): HResult; stdcall;
    function SetFileName(pszName: LPCWSTR): HResult; stdcall;
    function GetFileName(var pszName: LPCWSTR): HResult; stdcall;
    function SetTitle(pszTitle: LPCWSTR): HResult; stdcall;
    function SetOkButtonLabel(pszText: LPCWSTR): HResult; stdcall;
    function SetFileNameLabel(pszLabel: LPCWSTR): HResult; stdcall;
    function GetResult(var ppsi: IShellItem): HResult; stdcall;
    function AddPlace(const psi: IShellItem; fdap: DWORD): HResult; stdcall;
    function SetDefaultExtension(pszDefaultExtension: LPCWSTR): HResult; stdcall;
    function Close(hr: HResult): HResult; stdcall;
    function SetClientGuid(const guid: TGUID): HResult; stdcall;
    function ClearClientData: HResult; stdcall;
    function SetFilter(const pFilter: IShellItemFilter): HResult; stdcall;
  end;

  { IFileOpenDialog }

const
  {$EXTERNALSYM FOS_OVERWRITEPROMPT}
  FOS_OVERWRITEPROMPT         = $2;
  {$EXTERNALSYM FOS_STRICTFILETYPES}
  FOS_STRICTFILETYPES         = $4;
  {$EXTERNALSYM FOS_NOCHANGEDIR}
  FOS_NOCHANGEDIR             = $8;
  {$EXTERNALSYM FOS_PICKFOLDERS}
  FOS_PICKFOLDERS             = $20;
  {$EXTERNALSYM FOS_FORCEFILESYSTEM}
  FOS_FORCEFILESYSTEM         = $40;
  {$EXTERNALSYM FOS_ALLNONSTORAGEITEMS}
  FOS_ALLNONSTORAGEITEMS      = $80;
  {$EXTERNALSYM FOS_NOVALIDATE}
  FOS_NOVALIDATE              = $100;
  {$EXTERNALSYM FOS_ALLOWMULTISELECT}
  FOS_ALLOWMULTISELECT        = $200;
  {$EXTERNALSYM FOS_PATHMUSTEXIST}
  FOS_PATHMUSTEXIST           = $800;
  {$EXTERNALSYM FOS_FILEMUSTEXIST}
  FOS_FILEMUSTEXIST           = $1000;
  {$EXTERNALSYM FOS_CREATEPROMPT}
  FOS_CREATEPROMPT            = $2000;
  {$EXTERNALSYM FOS_SHAREAWARE}
  FOS_SHAREAWARE              = $4000;
  {$EXTERNALSYM FOS_NOREADONLYRETURN}
  FOS_NOREADONLYRETURN        = $8000;
  {$EXTERNALSYM FOS_NOTESTFILECREATE}
  FOS_NOTESTFILECREATE        = $10000;
  {$EXTERNALSYM FOS_HIDEMRUPLACES}
  FOS_HIDEMRUPLACES           = $20000;
  {$EXTERNALSYM FOS_HIDEPINNEDPLACES}
  FOS_HIDEPINNEDPLACES        = $40000;
  {$EXTERNALSYM FOS_NODEREFERENCELINKS}
  FOS_NODEREFERENCELINKS      = $100000;
  {$EXTERNALSYM FOS_DONTADDTORECENT}
  FOS_DONTADDTORECENT         = $2000000;
  {$EXTERNALSYM FOS_FORCESHOWHIDDEN}
  FOS_FORCESHOWHIDDEN         = $10000000;
  {$EXTERNALSYM FOS_DEFAULTNOMINIMODE}
  FOS_DEFAULTNOMINIMODE       = $20000000;
  {$EXTERNALSYM FOS_FORCEPREVIEWPANEON}
  FOS_FORCEPREVIEWPANEON      = $40000000;

type

  {$EXTERNALSYM IPropertyStore}
  IPropertyStore = interface(IUnknown)
    [SID_IPropertyStore]
    function GetCount(out cProps: DWORD): HResult; stdcall;
    function GetAt(iProp: DWORD; out pkey: TPropertyKey): HResult; stdcall;
    function GetValue(const key: TPropertyKey; out pv: TPropVariant): HResult; stdcall;
    function SetValue(const key: TPropertyKey; const propvar: TPropVariant): HResult; stdcall;
    function Commit: HResult; stdcall;
  end;

  {$EXTERNALSYM IPropertyDescriptionList}
  IPropertyDescriptionList = interface(IUnknown)
    [SID_IPropertyDescriptionList]
    function GetCount(out pcElem: UINT): HResult; stdcall;
    function GetAt(iElem: UINT; const riid: TIID; out ppv): HResult; stdcall;
  end;

  {$EXTERNALSYM IFileOpenDialog}
  IFileOpenDialog = interface(IFileDialog)
    [SID_IFileOpenDialog]
    function GetResults(var ppenum: IShellItemArray): HResult; stdcall;
    function GetSelectedItems(var ppsai: IShellItemArray): HResult; stdcall;
  end;

  {$EXTERNALSYM IFileOperationProgressSink}
  IFileOperationProgressSink = interface(IUnknown)
    [SID_IFileOperationProgressSink]
    function StartOperations: HResult; stdcall;
    function FinishOperations(hrResult: HResult): HResult; stdcall;
    function PreRenameItem(dwFlags: DWORD; const psiItem: IShellItem;
      pszNewName: LPCWSTR): HResult; stdcall;
    function PostRenameItem(dwFlags: DWORD; const psiItem: IShellItem;
      pszNewName: LPCWSTR; hrRename: HResult; const psiNewlyCreated: IShellItem): HResult; stdcall;
    function PreMoveItem(dwFlags: DWORD; const psiItem: IShellItem;
      const psiDestinationFolder: IShellItem; pszNewName: LPCWSTR): HResult; stdcall;
    function PostMoveItem(dwFlags: DWORD; const psiItem: IShellItem;
      const psiDestinationFolder: IShellItem; pszNewName: LPCWSTR;
      hrMove: HResult; const psiNewlyCreated: IShellItem): HResult; stdcall;
    function PreCopyItem(dwFlags: DWORD; const psiItem: IShellItem;
      const psiDestinationFolder: IShellItem; pszNewName: LPCWSTR): HResult; stdcall;
    function PostCopyItem(dwFlags: DWORD; const psiItem: IShellItem;
      const psiDestinationFolder: IShellItem; pszNewName: LPCWSTR;
      hrCopy: HResult; const psiNewlyCreated: IShellItem): HResult; stdcall;
    function PreDeleteItem(dwFlags: DWORD; const psiItem: IShellItem): HResult; stdcall;
    function PostDeleteItem(dwFlags: DWORD; const psiItem: IShellItem; hrDelete: HResult;
      const psiNewlyCreated: IShellItem): HResult; stdcall;
    function PreNewItem(dwFlags: DWORD; const psiDestinationFolder: IShellItem;
      pszNewName: LPCWSTR): HResult; stdcall;
    function PostNewItem(dwFlags: DWORD; const psiDestinationFolder: IShellItem;
      pszNewName: LPCWSTR; pszTemplateName: LPCWSTR; dwFileAttributes: DWORD;
      hrNew: HResult; const psiNewItem: IShellItem): HResult; stdcall;
    function UpdateProgress(iWorkTotal: UINT; iWorkSoFar: UINT): HResult; stdcall;
    function ResetTimer: HResult; stdcall;
    function PauseTimer: HResult; stdcall;
    function ResumeTimer: HResult; stdcall;
  end;

  { IFileSaveDialog }

  {$EXTERNALSYM IFileSaveDialog}
  IFileSaveDialog = interface(IFileDialog)
    [SID_IFileSaveDialog]
    function SetSaveAsItem(const psiIShellItem): HResult; stdcall;
    function SetProperties(const pStore: IPropertyStore): HResult; stdcall;
    function SetCollectedProperties(const pList: IPropertyDescriptionList;
      fAppendDefault: BOOL): HResult; stdcall;
    function GetProperties(out ppStore: IPropertyStore): HResult; stdcall;
    function ApplyProperties(const psi: IShellItem;
      const pStore: IPropertyStore; hwnd: HWND;
      const pSink: IFileOperationProgressSink): HResult; stdcall;
  end;

implementation

end.
