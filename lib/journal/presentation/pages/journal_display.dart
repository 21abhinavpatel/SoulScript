import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:soulscript/core/alpha_num_calculations.dart';
import 'package:soulscript/core/loader.dart';
import 'package:soulscript/core/show_snackbar.dart';
import 'package:soulscript/journal/domain/journal_entry.dart';
import 'package:soulscript/journal/presentation/bloc/journal_bloc.dart';
import 'package:soulscript/journal/presentation/pages/journal_editor.dart';
import 'package:soulscript/journal/presentation/pages/journal_entry_display.dart';
import 'dart:io' show Platform;

class JournalDisplay extends StatefulWidget {
  const JournalDisplay({super.key});

  @override
  State<JournalDisplay> createState() => _JournalDisplayState();
}

class _JournalDisplayState extends State<JournalDisplay> {
  @override
  void initState() {
    super.initState();
    print(DateTime.now());
    if (Platform.isAndroid) {
      context.read<JournalBloc>().add(JournalGetterStreamEvent());
    } else {
      context.read<JournalBloc>().add(JournalGetterEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'SoulScript',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.black,
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const JournalEditor(),
                    ),
                  );
                },
                icon: const Icon(Icons.add_circle),
              ),
              const SizedBox(width: 8.0)
            ],
          )
        ],
      ),
      body: BlocConsumer<JournalBloc, JournalState>(
        listener: (context, state) {
          if (state is JournalFailure) {
            showSnackBar(context, state.error);
          }
        },
        builder: (context, state) {
          if (state is JournalGetterSuccess) {
            print(DateTime.now());
            final allJournalEntriesResponse = state.allJournalEntries;
            List<JournalEntry> allJournalEntries = [];
            for (var dateId in allJournalEntriesResponse.keys.toList()) {
              String imageUrl = '';
              if (Platform.isAndroid) {
                imageUrl = allJournalEntriesResponse[dateId]!['l']!;
              } else {
                imageUrl = allJournalEntriesResponse[dateId]!['i']!;
              }
              JournalEntry journalEntry = JournalEntry(
                  content: allJournalEntriesResponse[dateId]!['c']!,
                  imageUrl: imageUrl,
                  date: DateTime(2023, 12, 31).add(
                      Duration(days: alphaNumToNum(dateId.substring(0, 2)))));
              allJournalEntries.add(journalEntry);
            }
            allJournalEntries.sort((a, b) => b.date.compareTo(a.date));
            Map<String, List<JournalEntry>> groupedJournalEntries = {};
            DateFormat formatter = DateFormat('MM-yyyy');
            for (var journalEntry in allJournalEntries) {
              String monthYear = formatter.format(journalEntry.date);
              if (!groupedJournalEntries.containsKey(monthYear)) {
                groupedJournalEntries[monthYear] = [];
              }
              groupedJournalEntries[monthYear]!.add(journalEntry);
            }
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: buildGroupedJournalEntries(
                      context, groupedJournalEntries),
                ),
              ),
            );
          } else {
            return const Loader();
          }
        },
      ),
    );
  }

  List<Widget> buildGroupedJournalEntries(
    BuildContext context,
    Map<String, List<JournalEntry>> groupedJournalEntries,
  ) {
    List<Widget> tiles = [];
    for (int index = 0; index < groupedJournalEntries.length; index++) {
      final monthYear = groupedJournalEntries.keys.toList()[index];
      final month =
          DateFormat('MMMM').format(DateFormat('MM-yyyy').parse(monthYear));
      final year =
          DateFormat('yy').format(DateFormat('MM-yyyy').parse(monthYear));
      String formattedYear = '';
      if (year != DateFormat('yy').format(DateTime.now())) {
        formattedYear = " '$year";
      }
      tiles.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  month + formattedYear,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(29, 29, 29, 1),
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: buildJournalEntry(
                      context, groupedJournalEntries[monthYear]!),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return tiles;
  }

  List<Widget> buildJournalEntry(
    BuildContext context,
    List<JournalEntry> allJournalEntries,
  ) {
    List<Widget> tiles = [];
    for (int index = 0; index < allJournalEntries.length; index++) {
      final journalEntry = allJournalEntries[index];
      tiles.add(
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JournalEntryDisplay(
                  journalEntry: journalEntry,
                ),
              ),
            );
          },
          child: ListTile(
            title: Text(
              journalEntry.content,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
            subtitle: Text(
                DateFormat('dd/MM/yy').format(journalEntry.date).toString()),
            trailing: journalEntry.imageUrl.isNotEmpty
                ? IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.image_outlined),
                  )
                : null,
          ),
        ),
      );
      if (index < allJournalEntries.length - 1) {
        tiles.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              color: Color.fromRGBO(41, 40, 43, 1),
              thickness: 1,
            ),
          ),
        );
      }
    }
    return tiles;
  }
}
