unit uUninstallProcess;

interface

uses
  uActions,
  uUninstallActions,
  uSelfDeleteAction,
  uAssociationActions,
  uUninstallCurrentUser;

implementation

initialization

  TInstallManager.Instance.RegisterScope(TInstallCloseApplication);
  TInstallManager.Instance.RegisterScope(TUninstallShortCuts);
  TInstallManager.Instance.RegisterScope(TInstallAssociations);
  TInstallManager.Instance.RegisterScope(TUnInstallStillImageHandler);
  TInstallManager.Instance.RegisterScope(TUninstallNotify); //should be before TUninstallRegistry because notifications uses statistics -> registry
  TInstallManager.Instance.RegisterScope(TUninstallRegistry);
  TInstallManager.Instance.RegisterScope(TInstallFileActions);
  TInstallManager.Instance.RegisterScope(TUninstallUserSettingsAction); //delete current user settings
  TInstallManager.Instance.RegisterScope(TUninstallFiles);
  TInstallManager.Instance.RegisterScope(TUnInstallCacheHandler); //should be after TUninstallNotify because TUninstallNotify uses app data directory
  TInstallManager.Instance.RegisterScope(TSelfDeleteActions);

end.
