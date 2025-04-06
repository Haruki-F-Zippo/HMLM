import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../image_type.dart';

class ImageTypeGridView extends StatelessWidget {
  const ImageTypeGridView({
    super.key,
    required this.selectedImageType,
    required this.onTap,
  });

  // 現在選択されているImageType
  final ImageType selectedImageType;
  // ImageTypeを返すコールバック関数
  final ValueChanged<ImageType> onTap;

  @override
  Widget build(BuildContext context) {
    // enumの定数を配列で返す.values
    const images = ImageType.values;

    // GridViewの定義
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      children: [
        for (final imageType in images)
          GestureDetector(
            onTap: () => onTap(imageType),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                // PaddingとbackgroundColorでボーダーを演出
                backgroundColor: imageType == selectedImageType
                    ? Colors.blue
                    : Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Image.asset(imageType.path),
                ),
              ),
            ),
          ),
      ],
    );
  }
}