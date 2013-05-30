unit uIDBForm;

interface

type
  ICurrentImageSource = interface(IInterface)
  ['{1BFE6E8F-2411-4250-BF57-75BCEF69F091}']
    function GetCurrentImageFileName: string;
  end;

  IDBForm = interface
  ['{3A0E49B4-5524-4C9C-B029-E10A2D250D7D}']
    function QueryInterfaceEx(const IID: TGUID; out Obj): HResult;
  end;

implementation

end.
