import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/catalog/demo_document_catalog.dart';
import '../../domain/entities/document.dart';
import '../providers/tabs_provider.dart';

/// Static document list used as the portfolio demo's TOC/navigation drawer.
class TocNavigationDrawer extends ConsumerWidget {
  final double width;
  final String searchQuery;
  final ValueChanged<String>? onSearchChanged;

  const TocNavigationDrawer({
    super.key,
    required this.width,
    this.searchQuery = '',
    this.onSearchChanged,
  });

  void _showDocumentOptions(
    BuildContext context,
    WidgetRef ref,
    Document document,
  ) {
    final notifier = ref.read(tabsProvider.notifier);
    final tabs = ref.read(tabsProvider);
    final isSplit =
        tabs.tabs.isNotEmpty && tabs.tabs[tabs.currentTabIndex].isSplitView;

    final actions = <Widget>[
      ListTile(
        leading: const Icon(Icons.open_in_browser),
        title: const Text('Open'),
        onTap: () {
          Navigator.pop(context);
          notifier.openDocumentInCurrentTab(document);
        },
      ),
      ListTile(
        leading: const Icon(Icons.tab),
        title: const Text('Open in new tab'),
        onTap: () {
          Navigator.pop(context);
          notifier.openDocumentInNewTab(document);
        },
      ),
    ];

    if (!isSplit) {
      actions.add(
        ListTile(
          leading: const Icon(Icons.splitscreen),
          title: const Text('Open in split view'),
          onTap: () {
            Navigator.pop(context);
            notifier.openDocumentInSplitView(document);
          },
        ),
      );
    } else {
      actions.addAll([
        ListTile(
          leading: const Icon(Icons.keyboard_arrow_left),
          title: const Text('Open in left pane'),
          onTap: () {
            Navigator.pop(context);
            notifier.openDocumentInSplitPane(document, 0);
          },
        ),
        ListTile(
          leading: const Icon(Icons.keyboard_arrow_right),
          title: const Text('Open in right pane'),
          onTap: () {
            Navigator.pop(context);
            notifier.openDocumentInSplitPane(document, 1);
          },
        ),
      ]);
    }

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: actions),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = searchQuery.trim().toLowerCase();
    final documents = DemoDocumentCatalog.documents.where((document) {
      if (query.isEmpty) return true;
      return document.pageBlock.toLowerCase().contains(query) ||
          document.chapter.toLowerCase().contains(query) ||
          document.path.toLowerCase().contains(query);
    }).toList(growable: false);
    final tabsState = ref.watch(tabsProvider);
    final currentDocument = tabsState.tabs.isNotEmpty &&
            tabsState.tabs[tabsState.currentTabIndex].documents.isNotEmpty
        ? tabsState.tabs[tabsState.currentTabIndex].documents.first
        : null;

    return SizedBox(
      width: width,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
            child: TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search documents',
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 8, 12, 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Demo publications',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: documents.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final document = documents[index];
                final selected = currentDocument?.id == document.id;
                return ListTile(
                  selected: selected,
                  leading: const Icon(Icons.picture_as_pdf_outlined),
                  title: Text(document.pageBlock),
                  subtitle: Text(document.path),
                  onTap: () => ref
                      .read(tabsProvider.notifier)
                      .openDocumentInCurrentTab(document),
                  onLongPress: () =>
                      _showDocumentOptions(context, ref, document),
                  trailing: IconButton(
                    tooltip: 'Document actions',
                    icon: const Icon(Icons.more_vert),
                    onPressed: () =>
                        _showDocumentOptions(context, ref, document),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
