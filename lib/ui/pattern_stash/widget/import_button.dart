import 'package:craft_stash/premadePatterns/createFromJsons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

IconButton patternImportButton({required BuildContext context}) {
  return IconButton(
    onPressed: () async {
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['json'],
        );

        if (result != null) {
          String? filePath = result.files.single.path;
          if (filePath != null) {
            await createPatternFromJsons(path: filePath);
            // await OpenFile.open(filePath);
          }
        }
      } on PlatformException catch (e) {
        print('Failed to open file manager: ${e.message}');
      } catch (e, stack) {
        print('An unknown error occurred: $e');
        print(stack);
      }
    },
    icon: Icon(Icons.folder),
  );
}
