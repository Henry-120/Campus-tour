import 'dart:math';

class BigHeadService {
  // 目前最新穩定版本建議使用 9.x，或者維持 7.x 也可以
  static const String baseUrl = "https://api.dicebear.com/9.x/notionists-neutral/svg";

  static String generateRandomUrl() {
    final seed = _getRandomString(12);

    // 💡 建議加上 backgroundType=pixelated 或加上背景色
    // 因為 big-heads 預設可能是透明背景，在某些 UI 下會看不清楚
    return "$baseUrl?seed=$seed&radius=50";
  }

  static String _getRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    // 建議不要在方法內建立 Random 實例，可以提到類別層級共用，效率更好
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }
}