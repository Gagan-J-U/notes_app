typedef CloseLoadingScreen = bool Function();
typedef UpdateLoadingScreen = bool Function(String message);

class LoadingScreenController {
  final CloseLoadingScreen close;
  final UpdateLoadingScreen update;

  const LoadingScreenController({
    required this.close,
    required this.update,
  });
}
