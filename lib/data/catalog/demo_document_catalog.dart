import '../../domain/entities/document.dart';

/// The documents exposed by the portfolio demo.
///
/// These are Flutter asset paths, not remote service paths. Keeping the
/// catalog in the data layer lets the presentation layer use the same
/// Document entity and tab/viewer flow as the original application.
class DemoDocumentCatalog {
  static const List<Document> documents = [
    Document(
      id: 'demo-as-awm-01-000',
      chapter: 'AS AWM',
      path: 'assets/AS-AWM-01-000_I1_R4_20200612.pdf',
      folder: 'AeroSlate demo',
      created: '',
      pageBlockKey: 'AS-AWM-01-000',
      manual: '',
      pageBlock: 'AS AWM 01 000',
    ),
    Document(
      id: 'demo-ac-a320-0624',
      chapter: 'AC A320',
      path: 'assets/AC_A320_0624.pdf',
      folder: 'AeroSlate demo',
      created: '',
      pageBlockKey: 'AC_A320_0624',
      manual: '',
      pageBlock: 'AC A320 0624',
    ),
  ];
}
