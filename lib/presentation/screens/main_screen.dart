import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/catalog/demo_document_catalog.dart';
import '../../l10n/app_localizations.dart';
import '../providers/header_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/tabs_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/document_tabs.dart';
import '../widgets/document_view.dart';
import '../widgets/split_document_view.dart';
import '../widgets/toc_navigation_drawer.dart';

/// Static portfolio shell for the AeroSlate document viewer.
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  double _drawerWidth = 250;
  bool _drawerOpen = true;
  bool _resizerHover = false;
  bool _resizing = false;
  String _searchQuery = '';
  final ScrollController _tabScrollController = ScrollController();

  static const double _minDrawerWidth = 220;
  static const double _maxDrawerWidth = 520;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final tabs = ref.read(tabsProvider);
      if (tabs.tabs.isEmpty) {
        ref
            .read(tabsProvider.notifier)
            .openDocumentInNewTab(DemoDocumentCatalog.documents.first);
      }
    });
  }

  @override
  void dispose() {
    _tabScrollController.dispose();
    super.dispose();
  }

  void _scrollTabs(double offset) {
    if (!_tabScrollController.hasClients) return;
    final position = _tabScrollController.position;
    final target = (_tabScrollController.offset + offset)
        .clamp(position.minScrollExtent, position.maxScrollExtent);
    _tabScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 200),
      curve: Curves.ease,
    );
  }

  Future<void> _showLanguageDialog(AppLocalizations loc) async {
    final current = ref.read(localeProvider);
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.changeLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              value: 'en',
              groupValue: current.languageCode,
              onChanged: (value) => Navigator.of(ctx).pop(value),
              title: Text(loc.english),
            ),
            RadioListTile<String>(
              value: 'fr',
              groupValue: current.languageCode,
              onChanged: (value) => Navigator.of(ctx).pop(value),
              title: Text(loc.french),
            ),
          ],
        ),
      ),
    );
    if (selected != null) {
      await ref.read(localeProvider.notifier).setLocale(Locale(selected));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final tabsState = ref.watch(tabsProvider);
    final headerTitle = ref.watch(headerTitleProvider);
    final headerSubtitle = ref.watch(headerSubtitleProvider);
    const headerHeight = 112.0;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          Positioned.fill(
            top: headerHeight,
            left: _drawerOpen ? _drawerWidth : 0,
            child: tabsState.tabs.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : IndexedStack(
                    index: tabsState.currentTabIndex,
                    children: tabsState.tabs.map((tab) {
                      if (tab.isSplitView && tab.documents.isNotEmpty) {
                        return SplitDocumentView(
                          key: ValueKey('split-${tab.id}'),
                          tabId: tab.id,
                          leftDocument: tab.documents.first,
                          rightDocument: tab.documents.length > 1
                              ? tab.documents[1]
                              : null,
                        );
                      }
                      return DocumentView(
                        key: ValueKey('${tab.id}-${tab.documents.first.id}'),
                        document: tab.documents.first,
                        paneId: 'S::${tab.id}',
                      );
                    }).toList(),
                  ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Container(
                height: headerHeight,
                color: theme.colorScheme.surface,
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: _drawerOpen
                                ? 'Hide document list'
                                : 'Show document list',
                            onPressed: () =>
                                setState(() => _drawerOpen = !_drawerOpen),
                            icon: Icon(
                                _drawerOpen ? Icons.menu_open : Icons.menu),
                          ),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 30),
                            child: Image.asset(
                              theme.brightness == Brightness.dark
                                  ? 'assets/dark_icons/ar_logo_dark.png'
                                  : 'assets/ar_logo_light.png',
                              height: 30,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AeroSlate',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '$headerSubtitle | $headerTitle',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: loc.changeLanguage,
                            onPressed: () => _showLanguageDialog(loc),
                            icon: const Icon(Icons.language),
                          ),
                          PopupMenuButton<String>(
                            tooltip: 'Appearance',
                            icon: const Icon(Icons.palette_outlined),
                            onSelected: (value) {
                              final notifier =
                                  ref.read(themeModeProvider.notifier);
                              if (value == 'light') {
                                notifier.setThemeMode(ThemeMode.light);
                              } else if (value == 'dark') {
                                notifier.setThemeMode(ThemeMode.dark);
                              } else {
                                notifier.setThemeMode(ThemeMode.system);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                  value: 'light', child: Text('Light theme')),
                              PopupMenuItem(
                                  value: 'dark', child: Text('Dark theme')),
                              PopupMenuItem(
                                  value: 'system', child: Text('System theme')),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 42,
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: 'Scroll tabs left',
                            onPressed: () => _scrollTabs(-160),
                            icon: const Icon(Icons.chevron_left),
                          ),
                          Expanded(
                            child: DocumentTabs(
                              tabs: tabsState.tabs,
                              scrollController: _tabScrollController,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Scroll tabs right',
                            onPressed: () => _scrollTabs(160),
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_drawerOpen)
            Positioned(
              top: headerHeight,
              left: 0,
              bottom: 0,
              width: _drawerWidth,
              child: Material(
                elevation: 1,
                child: TocNavigationDrawer(
                  width: _drawerWidth,
                  searchQuery: _searchQuery,
                  onSearchChanged: (value) =>
                      setState(() => _searchQuery = value),
                ),
              ),
            ),
          if (_drawerOpen)
            Positioned(
              top: headerHeight,
              left: _drawerWidth - 4,
              bottom: 0,
              width: 8,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                onEnter: (_) => setState(() => _resizerHover = true),
                onExit: (_) => setState(() => _resizerHover = false),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (_) => setState(() => _resizing = true),
                  onPanEnd: (_) => setState(() => _resizing = false),
                  onPanUpdate: (details) => setState(() {
                    _drawerWidth = (_drawerWidth + details.delta.dx)
                        .clamp(_minDrawerWidth, _maxDrawerWidth);
                  }),
                  child: AnimatedOpacity(
                    opacity: _resizerHover || _resizing ? 1 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: Container(color: theme.colorScheme.primary),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
