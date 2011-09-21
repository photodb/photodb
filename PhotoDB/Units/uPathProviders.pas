unit uPathProviders;

interface

type
  TPathProviderFeature = class(TObject)

  end;

  TPathProvider = class(TObject)

  end;

  TPathItem = class(TObject)

  end;

  TPathProviderManager = class(TObject)
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterProvider(Provider: TPathProvider);
  end;

implementation

{ TPathProviderManager }

constructor TPathProviderManager.Create;
begin

end;

destructor TPathProviderManager.Destroy;
begin

  inherited;
end;

procedure TPathProviderManager.RegisterProvider(Provider: TPathProvider);
begin

end;

end.
