{ pkgs, ... }:

{
  dartpackages = with pkgs; [

    # Flutter framework (includes Dart SDK)
    flutter
                        # Dart SDK and runtime (provided by flutter)
                        # dart

    # Android development (required for Flutter mobile apps)
    # android-studio    # Full Android IDE

    # OR use these instead of android-studio for lighter setup:
    # android-tools     # ADB, fastboot, etc.
    # openjdk17         # Java runtime for Android tooling
  ];

  dart-nixpkgs-extensions = with pkgs.vscode-extensions; [
    # Official Dart language support
    dart-code.dart-code

    # Official Flutter extension
    dart-code.flutter
  ];

  dart-marketplace-extensions = with pkgs.vscode-utils.extensionsFromVscodeMarketplace; [
    # You can add additional Flutter/Dart extensions here if needed
  ];
}