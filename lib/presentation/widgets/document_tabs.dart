import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aeroslate/domain/entities/document_tab.dart';
import 'package:aeroslate/presentation/providers/tabs_provider.dart';

class DocumentTabs extends ConsumerWidget {
  final List<DocumentTab> tabs;
  final ScrollController? scrollController;

  const DocumentTabs({
    super.key,
    required this.tabs,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTabIndex = ref.watch(
      tabsProvider.select((state) => state.currentTabIndex),
    );
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final double tabHeight = isSmallScreen ? 40 : 44;
    final double fontSize = isSmallScreen ? 11 : 12;
    final double iconSize = isSmallScreen ? 10 : 12;
    final scheme = theme.colorScheme;

    return Container(
      height: tabHeight,
      color: scheme.surfaceContainer,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (ctx, index) {
          final tab = tabs[index];
          final isSelected = index == currentTabIndex;
          final title = tab.title;
          final displayTitle =
              title.length > 15 ? title.substring(0, 15) : title;

          return GestureDetector(
            onTap: () => ref.read(tabsProvider.notifier).changeTab(index),
            child: Container(
              margin: EdgeInsets.symmetric(
                vertical: isSmallScreen ? 1.0 : 2.0,
                horizontal: isSmallScreen ? 1.0 : 2.0,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8.0 : 12.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: isSelected ? scheme.primary : scheme.surfaceContainer,
                borderRadius: BorderRadius.circular(4.0),
                border: Border(
                  bottom: BorderSide(
                    width: 2,
                    color: isSelected
                        ? theme.colorScheme.secondary
                        : scheme.outlineVariant,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!tab.isSplitView) ...[
                    Text(
                      displayTitle,
                      style: TextStyle(
                        fontSize: fontSize,
                        color: isSelected
                            ? scheme.onPrimary
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: 80,
                      child: Text(
                        tab.documents.isNotEmpty
                            ? tab.documents[0].pageBlock
                            : 'Empty',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: fontSize,
                          color: isSelected
                              ? scheme.onPrimary
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: isSmallScreen ? 14 : 16,
                      margin: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 4.0 : 6.0,
                      ),
                      color: isSelected
                          ? scheme.onPrimary.withValues(alpha: 0.54)
                          : scheme.outlineVariant,
                    ),
                    SizedBox(
                      width: 80,
                      child: Text(
                        tab.documents.length > 1
                            ? tab.documents[1].pageBlock
                            : 'Empty',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: fontSize,
                          color: isSelected
                              ? scheme.onPrimary
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(width: isSmallScreen ? 6.0 : 8.0),
                  InkWell(
                    onTap: () =>
                        ref.read(tabsProvider.notifier).closeTab(tab.id),
                    child: Icon(
                      Icons.close,
                      size: iconSize,
                      color: isSelected
                          ? scheme.onPrimary
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
