import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// Tooltip to zoom in on SVG
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get nmx_svg_tooltip_zoomIn;

  /// Tooltip to zoom out on SVG
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get nmx_svg_tooltip_zoomOut;

  /// Tooltip to reset zoom on SVG
  ///
  /// In en, this message translates to:
  /// **'Reset zoom'**
  String get nmx_svg_tooltip_resetZoom;

  /// Displays current SVG zoom percent
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String nmx_svg_zoomPercent(Object percent);

  /// Tooltip to enable panning in SVG view
  ///
  /// In en, this message translates to:
  /// **'Enable pan'**
  String get nmx_svg_tooltip_enablePan;

  /// Tooltip to disable panning in SVG view
  ///
  /// In en, this message translates to:
  /// **'Disable pan'**
  String get nmx_svg_tooltip_disablePan;

  /// Tooltip to export SVG as PDF
  ///
  /// In en, this message translates to:
  /// **'Export as PDF'**
  String get nmx_svg_tooltip_exportPdf;

  /// Tooltip to enable drawing mode
  ///
  /// In en, this message translates to:
  /// **'Enable drawing'**
  String get nmx_svg_tooltip_enableDrawing;

  /// Tooltip to disable drawing mode
  ///
  /// In en, this message translates to:
  /// **'Disable drawing'**
  String get nmx_svg_tooltip_disableDrawing;

  /// Tooltip to enable text annotation
  ///
  /// In en, this message translates to:
  /// **'Enable text'**
  String get nmx_svg_tooltip_enableText;

  /// Tooltip to disable text annotation
  ///
  /// In en, this message translates to:
  /// **'Disable text'**
  String get nmx_svg_tooltip_disableText;

  /// Tooltip for freehand drawing tool
  ///
  /// In en, this message translates to:
  /// **'Freehand'**
  String get nmx_svg_tooltip_freehand;

  /// Tooltip for circle drawing tool
  ///
  /// In en, this message translates to:
  /// **'Circle'**
  String get nmx_svg_tooltip_circle;

  /// Tooltip for square drawing tool
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get nmx_svg_tooltip_square;

  /// Tooltip for the drawing line color picker
  ///
  /// In en, this message translates to:
  /// **'Line color'**
  String get nmx_svg_tooltip_color;

  /// Color option: black
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get nmx_svg_color_black;

  /// Color option: red
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get nmx_svg_color_red;

  /// Color option: green
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get nmx_svg_color_green;

  /// Color option: yellow
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get nmx_svg_color_yellow;

  /// Color option: white
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get nmx_svg_color_white;

  /// Tooltip to undo last drawing
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get nmx_svg_tooltip_undo;

  /// Tooltip to redo last undone drawing
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get nmx_svg_tooltip_redo;

  /// Tooltip to save current drawings
  ///
  /// In en, this message translates to:
  /// **'Save drawings'**
  String get nmx_svg_tooltip_saveDrawings;

  /// Tooltip to clear all drawings
  ///
  /// In en, this message translates to:
  /// **'Clear drawings'**
  String get nmx_svg_tooltip_clearDrawings;

  /// Error when SVG fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load SVG'**
  String get nmx_svg_failedLoad;

  /// Snackbar when drawings are saved
  ///
  /// In en, this message translates to:
  /// **'{count} drawings saved'**
  String nmx_svg_drawingsSaved(Object count);

  /// Message shown when drawing save fails
  ///
  /// In en, this message translates to:
  /// **'Drawings were not saved. Try again.'**
  String get nmx_svg_drawingsSaveFailed;

  /// Snackbar when export succeeds
  ///
  /// In en, this message translates to:
  /// **'Exported to PDF'**
  String get nmx_svg_exportedPdf;

  /// Message shown when export fails
  ///
  /// In en, this message translates to:
  /// **'Export did not finish. Try again.'**
  String get nmx_svg_exportFailed;

  /// Tooltip: manuals
  ///
  /// In en, this message translates to:
  /// **'Manuals'**
  String get nmx_manuals;

  /// Tooltip: attachments
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get nmx_attachments;

  /// Tooltip: libraries
  ///
  /// In en, this message translates to:
  /// **'Libraries'**
  String get nmx_libraries;

  /// Tooltip to scroll tabs left
  ///
  /// In en, this message translates to:
  /// **'Scroll left'**
  String get nmx_scrollLeft;

  /// Tooltip to scroll tabs right
  ///
  /// In en, this message translates to:
  /// **'Scroll right'**
  String get nmx_scrollRight;

  /// Tooltip: applicability filter
  ///
  /// In en, this message translates to:
  /// **'Applicability'**
  String get nmx_applicability;

  /// Tooltip: service bulletin
  ///
  /// In en, this message translates to:
  /// **'Service bulletin'**
  String get nmx_serviceBulletin;

  /// Tooltip: favorite list
  ///
  /// In en, this message translates to:
  /// **'Favorite list'**
  String get nmx_favoriteList;

  /// Tooltip: recent documents
  ///
  /// In en, this message translates to:
  /// **'Recent documents'**
  String get nmx_recentDocuments;

  /// Tooltip: search
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get nmx_search;

  /// Tooltip: split view
  ///
  /// In en, this message translates to:
  /// **'Split view'**
  String get nmx_splitView;

  /// Tooltip: TR temporary revisions
  ///
  /// In en, this message translates to:
  /// **'TR - Temporary revisions'**
  String get nmx_TR;

  /// Tooltip: SD supporting documents
  ///
  /// In en, this message translates to:
  /// **'SD - Supporting documents'**
  String get nmx_SD;

  /// Tooltip: list of attachments
  ///
  /// In en, this message translates to:
  /// **'List of attachments'**
  String get nmx_listAttachments;

  /// Tooltip: share current document
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get nmx_share;

  /// Tooltip to enable drawing globally
  ///
  /// In en, this message translates to:
  /// **'Enable Drawing'**
  String get nmx_enableDrawing;

  /// Tooltip to disable drawing globally
  ///
  /// In en, this message translates to:
  /// **'Disable Drawing'**
  String get nmx_disableDrawing;

  /// Tooltip: print document
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get nmx_print;

  /// Tooltip: download as PDF
  ///
  /// In en, this message translates to:
  /// **'Download as PDF'**
  String get nmx_downloadPdf;

  /// Tooltip: text annotation mode
  ///
  /// In en, this message translates to:
  /// **'Text annotation'**
  String get nmx_textAnnotation;

  /// Placeholder when no doc is open
  ///
  /// In en, this message translates to:
  /// **'Open a document'**
  String get nmx_openDocument;

  /// Instruction to rotate device
  ///
  /// In en, this message translates to:
  /// **'Rotate to landscape'**
  String get nmx_rotateLandscape;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// Message shown when there is no document loaded in the current tab
  ///
  /// In en, this message translates to:
  /// **'No document in this tab'**
  String get nmx_noDocumentInThisTab;

  /// Indicates a new version is available
  ///
  /// In en, this message translates to:
  /// **'System update available'**
  String get nmx_systemUpdate;

  /// Indicates library update is ready
  ///
  /// In en, this message translates to:
  /// **'Library data download ready'**
  String get nmx_libraryDownload;

  /// Go to previous document
  ///
  /// In en, this message translates to:
  /// **'Backward'**
  String get nmx_backward;

  /// Go to next document
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get nmx_forward;

  /// Open simple/advanced search
  ///
  /// In en, this message translates to:
  /// **'Open search panel'**
  String get nmx_openSearchPanel;

  /// Show library list
  ///
  /// In en, this message translates to:
  /// **'Available libraries'**
  String get nmx_availableLibraries;

  /// Show manuals/publications
  ///
  /// In en, this message translates to:
  /// **'Available manuals'**
  String get nmx_availableManuals;

  /// Show notices tab
  ///
  /// In en, this message translates to:
  /// **'Notices'**
  String get nmx_notices;

  /// Show favorites
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get nmx_favorites;

  /// Show view history
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get nmx_history;

  /// Expand or collapse TOC panel
  ///
  /// In en, this message translates to:
  /// **'Toggle table of contents'**
  String get nmx_toggleTOC;

  /// Switch to single-pane mode
  ///
  /// In en, this message translates to:
  /// **'Single mode'**
  String get nmx_singleMode;

  /// Switch to split-view mode
  ///
  /// In en, this message translates to:
  /// **'Split mode'**
  String get nmx_splitMode;

  /// Go full screen
  ///
  /// In en, this message translates to:
  /// **'Enter full screen'**
  String get nmx_enterFullScreen;

  /// Leave full-screen mode
  ///
  /// In en, this message translates to:
  /// **'Exit full screen'**
  String get nmx_exitFullScreen;

  /// Open AeroSlate menu
  ///
  /// In en, this message translates to:
  /// **'Application menu'**
  String get nmx_appMenu;

  /// Settings in app menu
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get nmx_settings;

  /// Help in app menu
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get nmx_help;

  /// Account in app menu
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get nmx_account;

  /// Show/hide temporary revisions table
  ///
  /// In en, this message translates to:
  /// **'Toggle TR revisions'**
  String get nmx_toggleTR;

  /// Show/hide supporting documents table
  ///
  /// In en, this message translates to:
  /// **'Toggle SD documents'**
  String get nmx_toggleSD;

  /// Show metadata for current module
  ///
  /// In en, this message translates to:
  /// **'Data module status'**
  String get nmx_dataModuleStatus;

  /// Add or view text notes
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get nmx_notes;

  /// Enable freehand drawing
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get nmx_draw;

  /// Attach files to TOC units
  ///
  /// In en, this message translates to:
  /// **'File attachment'**
  String get nmx_fileAttachment;

  /// Open parts catalog cart
  ///
  /// In en, this message translates to:
  /// **'Shopping cart'**
  String get nmx_shoppingCart;

  /// Filter by PSN
  ///
  /// In en, this message translates to:
  /// **'Applicability filter'**
  String get nmx_applicabilityFilter;

  /// Manage service bulletin status
  ///
  /// In en, this message translates to:
  /// **'Configure service bulletins'**
  String get nmx_configureServiceBulletins;

  /// Increase document zoom
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get nmx_zoomIn;

  /// Decrease document zoom
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get nmx_zoomOut;

  /// Rotate document clockwise
  ///
  /// In en, this message translates to:
  /// **'Rotate right'**
  String get nmx_rotateRight;

  /// Rotate document counter-clockwise
  ///
  /// In en, this message translates to:
  /// **'Rotate left'**
  String get nmx_rotateLeft;

  /// Move document when zoomed
  ///
  /// In en, this message translates to:
  /// **'Pan'**
  String get nmx_pan;

  /// Restore default zoom & pan
  ///
  /// In en, this message translates to:
  /// **'Reset view'**
  String get nmx_resetView;

  /// Show interactive hotspots
  ///
  /// In en, this message translates to:
  /// **'Hotspots'**
  String get nmx_hotspots;

  /// Load image at original size
  ///
  /// In en, this message translates to:
  /// **'See full-size image'**
  String get nmx_fullSizeImage;

  /// Copy document link
  ///
  /// In en, this message translates to:
  /// **'Copy URL'**
  String get nmx_copyURL;

  /// Download decrypted copy
  ///
  /// In en, this message translates to:
  /// **'Download document'**
  String get nmx_downloadDoc;

  /// Send document to printer
  ///
  /// In en, this message translates to:
  /// **'Print document'**
  String get nmx_printDoc;

  /// Restore default table state
  ///
  /// In en, this message translates to:
  /// **'Reset table'**
  String get nmx_resetTable;

  /// Reload current view
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get nmx_refresh;

  /// Hide right feature panel
  ///
  /// In en, this message translates to:
  /// **'Close panel'**
  String get nmx_closePanel;

  /// Show tables inside text
  ///
  /// In en, this message translates to:
  /// **'Display inline tables'**
  String get nmx_displayInlineTables;

  /// Show tables as small icons
  ///
  /// In en, this message translates to:
  /// **'Display tables as icons'**
  String get nmx_displayTablesAsIcons;

  /// Insert images into text flow
  ///
  /// In en, this message translates to:
  /// **'Display inline images'**
  String get nmx_displayInlineImages;

  /// Show images as icons
  ///
  /// In en, this message translates to:
  /// **'Display images as icons'**
  String get nmx_displayImagesAsIcons;

  /// Highlight document changes
  ///
  /// In en, this message translates to:
  /// **'Turn on revision bars'**
  String get nmx_turnOnRevBars;

  /// Hide change markings
  ///
  /// In en, this message translates to:
  /// **'Turn off revision bars'**
  String get nmx_turnOffRevBars;

  /// Jump to top of document
  ///
  /// In en, this message translates to:
  /// **'Scroll to top'**
  String get nmx_scrollToTop;

  /// Collapse the floating action toolbar
  ///
  /// In en, this message translates to:
  /// **'Collapse toolbar'**
  String get nmx_collapseToolbar;

  /// Expand the floating action toolbar
  ///
  /// In en, this message translates to:
  /// **'Expand toolbar'**
  String get nmx_expandToolbar;

  /// No description provided for @nmx_lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get nmx_lightTheme;

  /// No description provided for @nmx_darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get nmx_darkTheme;

  /// Title for dialog when opening an image
  ///
  /// In en, this message translates to:
  /// **'Open image'**
  String get nmx_openImage;

  /// Open in a new tab
  ///
  /// In en, this message translates to:
  /// **'New tab'**
  String get nmx_newTab;

  /// Cancel action label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get nmx_cancel;

  /// No description provided for @nmx_filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get nmx_filter;

  /// No description provided for @nmx_temporaryRevisions.
  ///
  /// In en, this message translates to:
  /// **'Temporary Revisions'**
  String get nmx_temporaryRevisions;

  /// No description provided for @nmx_searchToc.
  ///
  /// In en, this message translates to:
  /// **'Search TOC'**
  String get nmx_searchToc;

  /// No description provided for @nmx_searchDocumentsHint.
  ///
  /// In en, this message translates to:
  /// **'Search documents...'**
  String get nmx_searchDocumentsHint;

  /// No description provided for @nmx_noRecentTabs.
  ///
  /// In en, this message translates to:
  /// **'No recently closed tabs'**
  String get nmx_noRecentTabs;

  /// No description provided for @nmx_noDocumentSelected.
  ///
  /// In en, this message translates to:
  /// **'No document selected'**
  String get nmx_noDocumentSelected;

  /// No description provided for @nmx_open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get nmx_open;

  /// No description provided for @nmx_openInNewTab.
  ///
  /// In en, this message translates to:
  /// **'Open in new tab'**
  String get nmx_openInNewTab;

  /// No description provided for @nmx_openInLeftPane.
  ///
  /// In en, this message translates to:
  /// **'Open in left pane'**
  String get nmx_openInLeftPane;

  /// No description provided for @nmx_openInRightPane.
  ///
  /// In en, this message translates to:
  /// **'Open in right pane'**
  String get nmx_openInRightPane;

  /// No description provided for @nmx_detach.
  ///
  /// In en, this message translates to:
  /// **'Detach'**
  String get nmx_detach;

  /// No description provided for @nmx_errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'The content is not available now. Try again.'**
  String get nmx_errorWithMessage;

  /// No description provided for @nmx_firstPage.
  ///
  /// In en, this message translates to:
  /// **'First page'**
  String get nmx_firstPage;

  /// No description provided for @nmx_previousPage.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get nmx_previousPage;

  /// No description provided for @nmx_nextPage.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get nmx_nextPage;

  /// No description provided for @nmx_lastPage.
  ///
  /// In en, this message translates to:
  /// **'Last page'**
  String get nmx_lastPage;

  /// No description provided for @nmx_showOutline.
  ///
  /// In en, this message translates to:
  /// **'Show outline'**
  String get nmx_showOutline;

  /// No description provided for @nmx_thumbnails.
  ///
  /// In en, this message translates to:
  /// **'Thumbnails'**
  String get nmx_thumbnails;

  /// No description provided for @nmx_findInDocument.
  ///
  /// In en, this message translates to:
  /// **'Find in document'**
  String get nmx_findInDocument;

  /// No description provided for @nmx_previousMatch.
  ///
  /// In en, this message translates to:
  /// **'Previous match'**
  String get nmx_previousMatch;

  /// No description provided for @nmx_nextMatch.
  ///
  /// In en, this message translates to:
  /// **'Next match'**
  String get nmx_nextMatch;

  /// No description provided for @nmx_highlight.
  ///
  /// In en, this message translates to:
  /// **'Highlight'**
  String get nmx_highlight;

  /// No description provided for @nmx_matchCase.
  ///
  /// In en, this message translates to:
  /// **'Match case'**
  String get nmx_matchCase;

  /// No description provided for @nmx_matchDiacritics.
  ///
  /// In en, this message translates to:
  /// **'Match diacritics'**
  String get nmx_matchDiacritics;

  /// No description provided for @nmx_wholeWords.
  ///
  /// In en, this message translates to:
  /// **'Whole words'**
  String get nmx_wholeWords;

  /// No description provided for @nmx_verticalScrolling.
  ///
  /// In en, this message translates to:
  /// **'Vertical scrolling'**
  String get nmx_verticalScrolling;

  /// No description provided for @nmx_horizontalScrolling.
  ///
  /// In en, this message translates to:
  /// **'Horizontal scrolling'**
  String get nmx_horizontalScrolling;

  /// No description provided for @nmx_wrappedScrolling.
  ///
  /// In en, this message translates to:
  /// **'Wrapped scrolling'**
  String get nmx_wrappedScrolling;

  /// No description provided for @nmx_noSpreads.
  ///
  /// In en, this message translates to:
  /// **'No spreads'**
  String get nmx_noSpreads;

  /// No description provided for @nmx_oddSpreads.
  ///
  /// In en, this message translates to:
  /// **'Odd spreads'**
  String get nmx_oddSpreads;

  /// No description provided for @nmx_evenSpreads.
  ///
  /// In en, this message translates to:
  /// **'Even spreads'**
  String get nmx_evenSpreads;

  /// No description provided for @nmx_handTool.
  ///
  /// In en, this message translates to:
  /// **'Hand tool'**
  String get nmx_handTool;

  /// No description provided for @nmx_enterAnnotation.
  ///
  /// In en, this message translates to:
  /// **'Enter annotation'**
  String get nmx_enterAnnotation;

  /// No description provided for @nmx_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get nmx_add;

  /// No description provided for @nmx_authenticationError.
  ///
  /// In en, this message translates to:
  /// **'Authentication Error'**
  String get nmx_authenticationError;

  /// Message shown when sign-in token exchange fails
  ///
  /// In en, this message translates to:
  /// **'Sign-in did not finish. Select Retry to try again.'**
  String get nmx_authenticationErrorMessage;

  /// No description provided for @nmx_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get nmx_retry;

  /// No description provided for @nmx_signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get nmx_signIn;

  /// No description provided for @nmx_noTemporaryRevisions.
  ///
  /// In en, this message translates to:
  /// **'No Temporary Revisions found for this selection.'**
  String get nmx_noTemporaryRevisions;

  /// No description provided for @nmx_versionLabel.
  ///
  /// In en, this message translates to:
  /// **'v{version}'**
  String nmx_versionLabel(Object version);

  /// No description provided for @nmx_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get nmx_close;

  /// No description provided for @nmx_temporaryRevisionsFor.
  ///
  /// In en, this message translates to:
  /// **'Temporary Revisions - {manualId}'**
  String nmx_temporaryRevisionsFor(Object manualId);

  /// No description provided for @nmx_hideTemporaryRevisions.
  ///
  /// In en, this message translates to:
  /// **'Hide Temporary Revisions'**
  String get nmx_hideTemporaryRevisions;

  /// No description provided for @nmx_folder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get nmx_folder;

  /// No description provided for @nmx_trNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'TR Number'**
  String get nmx_trNumberLabel;

  /// No description provided for @nmx_sectionPage.
  ///
  /// In en, this message translates to:
  /// **'Section & Page #'**
  String get nmx_sectionPage;

  /// No description provided for @nmx_issueDate.
  ///
  /// In en, this message translates to:
  /// **'Issue Date'**
  String get nmx_issueDate;

  /// No description provided for @nmx_reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get nmx_reason;

  /// No description provided for @nmx_affectedDocs.
  ///
  /// In en, this message translates to:
  /// **'Affected Docs'**
  String get nmx_affectedDocs;

  /// No description provided for @nmx_notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get nmx_notSpecified;

  /// No description provided for @nmx_errorLoadingPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences did not load. Sign in again.'**
  String get nmx_errorLoadingPreferences;

  /// No description provided for @nmx_selectAircraftModel.
  ///
  /// In en, this message translates to:
  /// **'Select Aircraft Model'**
  String get nmx_selectAircraftModel;

  /// No description provided for @nmx_searchAircraftModels.
  ///
  /// In en, this message translates to:
  /// **'Search aircraft models'**
  String get nmx_searchAircraftModels;

  /// No description provided for @nmx_noModelsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No models available.'**
  String get nmx_noModelsAvailable;

  /// No description provided for @nmx_noResultsForQuery.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\".'**
  String nmx_noResultsForQuery(Object query);

  /// No description provided for @nmx_failedToLoadModels.
  ///
  /// In en, this message translates to:
  /// **'Model list is unavailable now. Try again.'**
  String get nmx_failedToLoadModels;

  /// No description provided for @nmx_browseByFamily.
  ///
  /// In en, this message translates to:
  /// **'Browse by Family'**
  String get nmx_browseByFamily;

  /// No description provided for @nmx_copyLabel.
  ///
  /// In en, this message translates to:
  /// **'Copy {label}'**
  String nmx_copyLabel(Object label);

  /// No description provided for @nmx_labelCopied.
  ///
  /// In en, this message translates to:
  /// **'{label} copied'**
  String nmx_labelCopied(Object label);

  /// No description provided for @nmx_modelsForFamily.
  ///
  /// In en, this message translates to:
  /// **'{family} Models'**
  String nmx_modelsForFamily(Object family);

  /// No description provided for @nmx_searchModels.
  ///
  /// In en, this message translates to:
  /// **'Search models'**
  String get nmx_searchModels;

  /// No description provided for @nmx_failedLoadPdfWithError.
  ///
  /// In en, this message translates to:
  /// **'The PDF did not load. Try again.'**
  String get nmx_failedLoadPdfWithError;

  /// No description provided for @nmx_failedLoadPdf.
  ///
  /// In en, this message translates to:
  /// **'Failed to load PDF'**
  String get nmx_failedLoadPdf;

  /// No description provided for @nmx_noOutlineAvailable.
  ///
  /// In en, this message translates to:
  /// **'No outline available'**
  String get nmx_noOutlineAvailable;

  /// No description provided for @nmx_librariesForModel.
  ///
  /// In en, this message translates to:
  /// **'{model} Libraries'**
  String nmx_librariesForModel(Object model);

  /// No description provided for @nmx_searchLibraries.
  ///
  /// In en, this message translates to:
  /// **'Search libraries'**
  String get nmx_searchLibraries;

  /// No description provided for @nmx_selectLibraryPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select a library to view available publications'**
  String get nmx_selectLibraryPrompt;

  /// No description provided for @nmx_availablePublicationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Available Publications:'**
  String get nmx_availablePublicationsLabel;

  /// No description provided for @nmx_noPublicationsFound.
  ///
  /// In en, this message translates to:
  /// **'No publications found.'**
  String get nmx_noPublicationsFound;

  /// No description provided for @nmx_issueNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Issue {issue}'**
  String nmx_issueNumberLabel(Object issue);

  /// No description provided for @nmx_failedToLoadPublications.
  ///
  /// In en, this message translates to:
  /// **'Publication list did not load. Try again.'**
  String get nmx_failedToLoadPublications;

  /// No description provided for @nmx_failedToOpenPublication.
  ///
  /// In en, this message translates to:
  /// **'The publication did not open. Try again.'**
  String get nmx_failedToOpenPublication;

  /// No description provided for @nmx_missingDeviceOrBid.
  ///
  /// In en, this message translates to:
  /// **'Missing device ID or BID in preferences'**
  String get nmx_missingDeviceOrBid;

  /// No description provided for @nmx_noLicensedLibrary.
  ///
  /// In en, this message translates to:
  /// **'No licensed library found for selection.'**
  String get nmx_noLicensedLibrary;

  /// No description provided for @nmx_libraryBasePathNotSet.
  ///
  /// In en, this message translates to:
  /// **'Library base path not set.'**
  String get nmx_libraryBasePathNotSet;

  /// No description provided for @nmx_pdfTools.
  ///
  /// In en, this message translates to:
  /// **'PDF tools'**
  String get nmx_pdfTools;

  /// No description provided for @nmx_svg_tooltip_rectangle.
  ///
  /// In en, this message translates to:
  /// **'Rectangle'**
  String get nmx_svg_tooltip_rectangle;

  /// No description provided for @nmx_svg_tooltip_ellipse.
  ///
  /// In en, this message translates to:
  /// **'Ellipse'**
  String get nmx_svg_tooltip_ellipse;

  /// No description provided for @nmx_svg_tooltip_line.
  ///
  /// In en, this message translates to:
  /// **'Line'**
  String get nmx_svg_tooltip_line;

  /// No description provided for @nmx_svg_tooltip_polyline.
  ///
  /// In en, this message translates to:
  /// **'Polyline'**
  String get nmx_svg_tooltip_polyline;

  /// No description provided for @nmx_svg_tooltip_polygon.
  ///
  /// In en, this message translates to:
  /// **'Polygon'**
  String get nmx_svg_tooltip_polygon;

  /// No description provided for @nmx_svg_tooltip_arrow.
  ///
  /// In en, this message translates to:
  /// **'Arrow'**
  String get nmx_svg_tooltip_arrow;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
