import 'package:appodeal_flutter/appodeal_flutter.dart';

class AdService {
  Future showNonSkippableAd(Function func) async {
    Appodeal.show(AdType.nonSkippable);

    Appodeal.setNonSkippableCallback((event) {
      if (event == 'onNonSkippableVideoShown') {
        func.call();
      } else if (event == 'onNonSkippableVideoFailedToLoad' ||
          event == 'onNonSkippableVideoShowFailed') {
        func.call();
      }
    });
  }
}
