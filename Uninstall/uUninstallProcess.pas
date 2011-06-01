unit uUninstallProcess;

interface

uses
  uActions,
  uUninstallActions,
  uSelfDeleteAction;

implementation

initialization

  TInstallManager.Instance.RegisterScope(TUninstallFiles);
  TInstallManager.Instance.RegisterScope(TUninstallShortCuts);
  TInstallManager.Instance.RegisterScope(TUninstallRegistry);
  TInstallManager.Instance.RegisterScope(TSelfDeleteActions);
  TInstallManager.Instance.RegisterScope(TUninstallNotify);

end.
