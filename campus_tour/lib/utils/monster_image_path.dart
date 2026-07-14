class MonsterImagePath {
  static const String _fairyFourPartsSegment = 'fairy_four_parts';
  static const String _fairyImgPrefix = 'assets/images/fairy_img';

  const MonsterImagePath._();

  static String staticImage(String imagePath) {
    final trimmedPath = imagePath.trim();
    if (trimmedPath.isEmpty) return trimmedPath;

    final folderName = _fourPartsFolderName(trimmedPath);
    if (folderName != null && folderName.isNotEmpty) {
      return '$_fairyImgPrefix/$folderName.png';
    }

    if (!trimmedPath.startsWith('assets/')) {
      return '$_fairyImgPrefix/$trimmedPath';
    }

    return trimmedPath;
  }

  static String? fourPartsFolderName(String imagePath) {
    return _fourPartsFolderName(imagePath) ??
        _fileNameWithoutExtension(imagePath);
  }

  static String? _fourPartsFolderName(String imagePath) {
    final pathParts = imagePath.trim().split('/');
    final fourPartsIndex = pathParts.indexOf(_fairyFourPartsSegment);
    if (fourPartsIndex >= 0 && pathParts.length > fourPartsIndex + 1) {
      return pathParts[fourPartsIndex + 1];
    }

    return null;
  }

  static String? _fileNameWithoutExtension(String imagePath) {
    final pathParts = imagePath.trim().split('/');
    final imageFileName = pathParts.isEmpty ? '' : pathParts.last;
    final extensionIndex = imageFileName.lastIndexOf('.');
    if (imageFileName.isEmpty || extensionIndex <= 0) return null;

    return imageFileName.substring(0, extensionIndex);
  }
}
