unit uExplorerProvidersInit;

interface

uses
  uPathProviders,
  uExplorerMyComputerProvider,
  uExplorerPortableDeviceProvider,
  uExplorerDateStackProviders,
  uExplorerGroupsProvider,
  uExplorerPersonsProvider,
  uExplorerShelfProvider;

implementation

initialization
  PathProviderManager.RegisterProvider(TPortableDeviceProvider.Create);
  PathProviderManager.RegisterSubProvider(TMyComputerProvider, TPortableDeviceProvider);

  PathProviderManager.RegisterProvider(TExplorerDateStackProvider.Create);
  PathProviderManager.RegisterSubProvider(TMyComputerProvider, TExplorerDateStackProvider);

  PathProviderManager.RegisterProvider(TGroupProvider.Create);
  PathProviderManager.RegisterSubProvider(TMyComputerProvider, TGroupProvider);

  PathProviderManager.RegisterProvider(TPersonProvider.Create);
  PathProviderManager.RegisterSubProvider(TMyComputerProvider, TPersonProvider);

  PathProviderManager.RegisterProvider(TShelfProvider.Create);
  PathProviderManager.RegisterSubProvider(TMyComputerProvider, TShelfProvider);

end.
