import 'package:flutter_test/flutter_test.dart';

import 'package:aeroslate/data/catalog/demo_document_catalog.dart';

void main() {
  test('contains the bundled AeroSlate demo publications', () {
    expect(DemoDocumentCatalog.documents, hasLength(2));
    expect(
      DemoDocumentCatalog.documents.map((document) => document.path),
      containsAll(<String>[
        'assets/AS-AWM-01-000_I1_R4_20200612.pdf',
        'assets/AC_A320_0624.pdf',
      ]),
    );
  });
}
