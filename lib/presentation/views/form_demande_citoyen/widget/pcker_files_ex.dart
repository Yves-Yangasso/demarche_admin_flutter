import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FilePreviewExample extends StatefulWidget {
  final List<String> allowedExtension;
  final String messageFile;
  final String indicateSelect;

  const FilePreviewExample({
    super.key,
    required this.allowedExtension,
    required this.messageFile,
    required this.indicateSelect,
  });

  @override
  State<FilePreviewExample> createState() => _FilePreviewExampleState();
}

class _FilePreviewExampleState extends State<FilePreviewExample> {
  Uint8List? imageBytes;
  String? fileName;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: widget.allowedExtension,
      withData: true,
    );

    if (result == null) return;

    final file = result.files.first;

    if (file.size > 100 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.messageFile)),
      );
      return;
    }

    setState(() {
      fileName = file.name;
      imageBytes = file.bytes;
    });
  }

  bool get isImage {
    if (fileName == null) return false;

    final ext = fileName!.toLowerCase();

    return ext.endsWith('.jpg') ||
        ext.endsWith('.jpeg') ||
        ext.endsWith('.png');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: pickFile,
            icon: const Icon(Icons.upload_file),
            label: Text(
              widget.indicateSelect.isEmpty
                  ? "Sélectionner"
                  : widget.indicateSelect,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: fileName == null
                ? Text(
                    widget.messageFile,
                    overflow: TextOverflow.ellipsis,
                  )
                : Row(
                    children: [
                      if (isImage && imageBytes != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.memory(
                            imageBytes!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        const Icon(
                          Icons.picture_as_pdf,
                          size: 40,
                          color: Colors.red,
                        ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          fileName!,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}