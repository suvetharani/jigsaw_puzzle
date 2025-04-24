import 'package:flutter/material.dart';

class ImageSelector extends StatelessWidget {
  final List<String> imagePaths;
  final String selectedImage;
  final ValueChanged<String> onImageSelected;

  const ImageSelector({
    super.key,
    required this.imagePaths,
    required this.selectedImage,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedImage,
      onChanged: (String? newValue) {
        if (newValue != null) {
          onImageSelected(newValue);
        }
      },
      items: imagePaths.map<DropdownMenuItem<String>>((String path) {
        return DropdownMenuItem<String>(
          value: path,
          child: Text(
            path.split('/').last, // Just show file name like cat.jpeg
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
    );
  }
}
