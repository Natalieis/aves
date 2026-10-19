import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/multipage.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/widgets/viewer/multipage/controller.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

class OverlayPositionTitleRow extends StatelessWidget {
  final AvesEntry entry;
  final String? collectionPosition;
  final MultiPageController? multiPageController;
  final bool showPosition;
  final bool showTitle;

  const new({
    super.key,
    required this.entry,
    required this.collectionPosition,
    required this.multiPageController,
    required this.showPosition,
    required this.showTitle,
  });

  @override
  Widget build(BuildContext context) {
    // avoid computing the title when it is not displayed
    final title = showTitle ? entry.bestTitle : null;

    Text toText({String? pagePosition}) => Text(
      [
        if (showPosition && collectionPosition != null) collectionPosition,
        if (showPosition && pagePosition != null) pagePosition,
        if (title != null) '${Unicode.FSI}$title${Unicode.PDI}',
      ].join(AText.separator),
    );

    if (multiPageController == null) return toText();

    return StreamBuilder<MultiPageInfo?>(
      stream: multiPageController!.infoStream,
      builder: (context, _) {
        final multiPageInfo = multiPageController!.info;
        String? pagePosition;
        if (multiPageInfo != null) {
          // page count may be 0 when we know an entry to have multiple pages
          // but fail to get information about these pages
          final pageCount = multiPageInfo.pageCount;
          if (pageCount > 0) {
            final page = multiPageInfo.getById(entry.pageId ?? entry.id) ?? multiPageInfo.defaultPage;
            pagePosition = '${(page?.index ?? 0) + 1}/$pageCount';
          }
        }
        return toText(pagePosition: pagePosition);
      },
    );
  }
}
