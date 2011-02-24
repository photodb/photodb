unit uInstallProcess;

interface

uses
  uActions,
  uInstallActions,
  uUpdatingWindowsActions,
  uAssociationActions,
  uUninstall,
  uSetupDatabaseActions;

implementation

initialization

  TInstallManager.Instance.RegisterScope(TInstallFiles);
  TInstallManager.Instance.RegisterScope(TInstallRegistry);
  TInstallManager.Instance.RegisterScope(TUninstallPreviousShortcutsAction);
  TInstallManager.Instance.RegisterScope(TInstallShortcuts);
  TInstallManager.Instance.RegisterScope(TInstallAssociations);
  TInstallManager.Instance.RegisterScope(TInstallUpdatingWindows);
  TInstallManager.Instance.RegisterScope(TSetupDatabaseActions);
  TInstallManager.Instance.RegisterScope(TInstallRunProgram);

end.
