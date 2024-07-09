import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soulscript/journal/domain/journal_entry.dart';

class JournalEntryDisplay extends StatefulWidget {
  final JournalEntry journalEntry;
  const JournalEntryDisplay({super.key, required this.journalEntry});

  @override
  State<JournalEntryDisplay> createState() => _JournalEntryDisplayState();
}

class _JournalEntryDisplayState extends State<JournalEntryDisplay> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'SoulScript',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  DateFormat('MMMM d, y').format(widget.journalEntry.date),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                widget.journalEntry.content,
                style: const TextStyle(fontSize: 16),
              ),
              if (widget.journalEntry.imageUrl.isNotEmpty)
                Column(
                  children: [
                    const SizedBox(height: 32),
                    Platform.isAndroid
                        ? Image.file(
                            File(widget.journalEntry.imageUrl),
                            fit: BoxFit.contain,
                          )
                        : Image.network(
                            widget.journalEntry.imageUrl,
                            fit: BoxFit.contain,
                          ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
