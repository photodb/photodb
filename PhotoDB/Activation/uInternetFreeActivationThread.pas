unit uInternetFreeActivationThread;

interface

uses
  Classes, SysUtils, uMemory, uInternetUtils, uConstants, uActivationUtils,
  uTranslate, uGOM, uDBForm;

type
  TFreeRegistrationCallBack = procedure(Reply: string) of object;

  InternetActivationInfo = record
    Owner: TObject;
    FirstName: string;
    LastName: string;
    Email: string;
    Phone: string;
    Country: string;
    City: string;
    Address: string;
    CallBack: TFreeRegistrationCallBack;
  end;

type
  TInternetFreeActivationThread = class(TThread)
  private
    { Private declarations }
    FInfo: InternetActivationInfo;
    FServerReply: string;
  protected
    procedure Execute; override;
    procedure DoCallBack;
  public
    constructor Create(Info: InternetActivationInfo);
  end;

implementation

{ TInternetFreeActivationThread }

constructor TInternetFreeActivationThread.Create(Info: InternetActivationInfo);
begin
  inherited Create(False);
  FInfo := Info;
end;

procedure TInternetFreeActivationThread.DoCallBack;
begin
  if GOM.IsObj(FInfo.Owner) then
    FInfo.CallBack(FServerReply);
end;

procedure TInternetFreeActivationThread.Execute;
var
  QueryUrl, QueryParams: string;
begin
  FreeOnTerminate := True;
  try
    try
      QueryUrl := FreeActivationURL;
      QueryParams := Format('?k=%s&v=%d&fn=%s&ln=%s&e=%s&p=%s&co=%s&ci=%s&a=%s',
        [TActivationManager.Instance.ApplicationCode,
        ReleaseNumber,
        EncodeBase64Url(FInfo.FirstName),
        EncodeBase64Url(FInfo.LastName),
        EncodeBase64Url(FInfo.Email),
        EncodeBase64Url(FInfo.Phone),
        EncodeBase64Url(FInfo.Country),
        EncodeBase64Url(FInfo.City),
        EncodeBase64Url(FInfo.Address)]);
      FServerReply := DownloadFile(QueryUrl + QueryParams);
    except
      on e: Exception do
        FServerReply := e.Message;
    end;
  finally
    Synchronize(DoCallBack);
  end;
end;

end.
