unit uUpdateDBTypes;

interface

uses
  uDBForm;

const
  IID_DBUpdaterCallBack: TGUID = '{E173457E-4657-476F-BF70-710D24C3EAAE}';

type
  IDBUpdaterCallBack = interface
    ['{E173457E-4657-476F-BF70-710D24C3EAAE}']
    procedure UpdaterSetText(Text: string);
    procedure UpdaterSetMaxValue(Value: Integer);
    procedure UpdaterSetAutoAnswer(Value: Integer);
    procedure UpdaterSetTimeText(Text: string);
    procedure UpdaterSetPosition(Value: Integer);
    procedure UpdaterSetFileName(FileName: string);
    procedure UpdaterAddFileSizes(Value: Int64);
    procedure UpdaterDirectoryAdded(Sender: TObject);
    procedure UpdaterOnDone(Sender: TObject);
    procedure UpdaterShowForm(Sender: TObject);
    procedure UpdaterSetBeginUpdation(Sender: TObject);
    procedure UpdaterShowImage(Sender: TObject);
    procedure UpdaterSetFullSize(Value: Int64);
    procedure UpdaterFoundedEvent(Owner: TObject; FileName: string; Size: Int64);
    function UpdaterGetForm: TDBForm;
  end;

implementation

end.
