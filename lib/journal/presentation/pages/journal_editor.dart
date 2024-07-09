import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:soulscript/core/alpha_num_calculations.dart';
import 'package:soulscript/core/loader.dart';
import 'package:soulscript/core/show_snackbar.dart';
import 'package:soulscript/journal/presentation/bloc/journal_bloc.dart';
import 'package:soulscript/journal/presentation/pages/journal_display.dart';

class JournalEditor extends StatefulWidget {
  const JournalEditor({super.key});

  @override
  State<JournalEditor> createState() => _JournalEditorState();
}

class _JournalEditorState extends State<JournalEditor> {
  final contentController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  File? image;
  bool showTextFormatContainer = false;
  List<int> fontSizes = [14, 16, 18, 20, 22, 24, 26, 28, 30];

  @override
  void dispose() {
    super.dispose();
    contentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    return BlocConsumer<JournalBloc, JournalState>(
      listener: (context, state) {
        if (state is JournalFailure) {
          showSnackBar(context, state.error);
        } else if (state is JournalUploadSuccess) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const JournalDisplay()),
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        if (state is JournalLoading) {
          return const Loader();
        }
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text('SoulScript'),
            backgroundColor: Colors.black,
            actions: [
              image != null
                  ? Row(
                      children: [
                        IconButton(
                          onPressed: selectImage,
                          icon: const Icon(Icons.image_outlined),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              image = null;
                            });
                          },
                          icon: const Icon(Icons.cancel_outlined),
                        )
                      ],
                    )
                  : Row(
                      children: [
                        IconButton(
                          onPressed: selectImage,
                          icon: const Icon(Icons.add_photo_alternate_outlined),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.cancel_outlined,
                            color: Colors.grey.shade800,
                          ),
                        )
                      ],
                    ),
              IconButton(
                onPressed: uploadJournal,
                icon: const Icon(Icons.upload),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextButton(
                  onPressed: () => selectDate(context),
                  child: Text(
                    DateFormat('MMMM d, y').format(selectedDate),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                Expanded(
                  child: Form(
                    key: formKey,
                    child: TextFormField(
                      controller: contentController,
                      maxLines: null,
                      autofocus: true,
                      keyboardType: TextInputType.multiline,
                      decoration:
                          const InputDecoration(border: InputBorder.none),
                      enableInteractiveSelection: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Content is missing!";
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void uploadJournal() {
    if (formKey.currentState!.validate()) {
      final allJournalEntries =
          (context.read<JournalBloc>().state as JournalGetterSuccess)
              .allJournalEntries;
      final selectedDateNumber =
          selectedDate.difference(DateTime(2023, 12, 31)).inDays;
      final selectedDateKey = numToAlphaNum(selectedDateNumber, 2);
      int suffix = 0;
      if (allJournalEntries.isNotEmpty) {
        for (var dateId in allJournalEntries.keys.toList()) {
          if (dateId.startsWith(selectedDateKey)) {
            suffix += 1;
          }
        }
      }
      String modifiedSuffix = numToAlphaNum(suffix, 1);
      final dateId = numToAlphaNum(
              selectedDate.difference(DateTime(2023, 12, 31)).inDays, 2) +
          modifiedSuffix;

      context.read<JournalBloc>().add(
            UploadJournalEntryEvent(
              dateId: dateId,
              content: contentController.text.trim(),
              image: image,
            ),
          );
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2100, 12, 31),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<File?> pickImage() async {
    final xFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (xFile != null) {
      return File(xFile.path);
    }
    return null;
  }

  void selectImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        image = pickedImage;
      });
    }
  }

  Widget buildIconContainer() {
    return Container(
      color: Colors.black45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(onPressed: selectImage, icon: const Icon(Icons.image)),
          IconButton(
            onPressed: () {
              setState(() {
                showTextFormatContainer = !showTextFormatContainer;
              });
            },
            icon: const Icon(Icons.text_format),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.mic)),
        ],
      ),
    );
  }

  Widget buildTextFormatContainer() {
    return Container(
      color: Colors.black45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.format_bold),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.format_italic),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.format_underline),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease),
            onPressed: () {},
          ),
          IconButton(
              icon: const Icon(Icons.format_list_bulleted),
              onPressed: insertBulletPoint),
          IconButton(
            icon: const Icon(Icons.format_list_numbered),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  void insertBulletPoint() {
    final selection = contentController.selection;
    final currentText = contentController.text;

    // Find the beginning of the current line:
    final lineStart = currentText.lastIndexOf('\n', selection.start) + 1;

    // Find the end of the current line:
    final lineEnd = currentText.indexOf('\n', selection.start);
    final actualLineEnd = lineEnd == -1 ? currentText.length : lineEnd;

    // Extract the current line text:
    final currentLine = currentText.substring(lineStart, actualLineEnd);

    String newText;
    int newOffset;

    // Check if the current line already has a bullet point:
    if (currentLine.startsWith('● ')) {
      // Remove the bullet point:
      newText = currentText.replaceRange(lineStart, lineStart + 2, '');
      newOffset = selection.start - 2;
    } else {
      // Add the bullet point:
      newText = currentText.replaceRange(lineStart, lineStart, '● ');
      newOffset = selection.start + 2;
    }

    // Update the text and maintain cursor position:
    contentController.value = contentController.value.copyWith(
      text: newText,
      // Keep the cursor where it was:
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}
