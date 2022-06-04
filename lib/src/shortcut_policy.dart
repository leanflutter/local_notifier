enum ShortcutPolicy {
  /// Don't check, create, or modify a shortcut.
  ignore,

  /// Require a shortcut with matching AUMI, don't create or modify an existing one.
  requireNoCreate,

  /// Require a shortcut with matching AUMI, create if missing, modify if not matching.
  /// This is the default.
  requireCreate,
}
