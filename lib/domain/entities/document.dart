enum DocumentType { pdf, other }

class Document {
  final String id;
  final String chapter;
  final String path;
  final String folder;
  final String created;
  final String pageBlockKey;
  final String manual;
  final String pageBlock;
  final String? pageNum;
  final String? content;

  const Document({
    required this.id,
    required this.chapter,
    required this.path,
    required this.folder,
    required this.created,
    required this.pageBlockKey,
    required this.manual,
    required this.pageBlock,
    this.pageNum,
    this.content,
  });

  DocumentType get type {
    final lowerPath = path.toLowerCase();
    if (lowerPath.endsWith('.pdf')) {
      return DocumentType.pdf;
    }
    return DocumentType.other;
  }

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as String,
      chapter: json['chapter'] as String,
      path: json['path'] as String,
      folder: json['folder'] as String,
      created: json['created'] as String,
      pageBlockKey: json['pageBlockKey'] as String,
      manual: json['manual'] as String,
      pageBlock: json['pageBlock'] as String,
      pageNum: json['pageNum'] as String?,
      content: json['content'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapter': chapter,
      'path': path,
      'folder': folder,
      'created': created,
      'pageBlockKey': pageBlockKey,
      'manual': manual,
      'pageBlock': pageBlock,
      'pageNum': pageNum,
      'content': content,
    };
  }
}
