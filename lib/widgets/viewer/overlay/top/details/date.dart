import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/widgets/viewer/multipage/controller.dart';
import 'package:aves/widgets/viewer/overlay/top/details/details.dart';
import 'package:material_ui/material_ui.dart';

class OverlayDateRow extends StatelessWidget {
  final AvesEntry entry;
  final MultiPageController? multiPageController;
  final double? frameRate;

  const new({
    super.key,
    required this.entry,
    required this.multiPageController,
    this.frameRate,
  });

  @override
  Widget build(BuildContext context) {
    final locale = settings.avesLocale;
    final use24hour = MediaQuery.alwaysUse24HourFormatOf(context);

    final date = entry.bestDate;
    final dateText = date != null ? formatDateTime(date, locale, use24hour) : AText.valueNotAvailable;
    final resolutionText = entry.isSvg
        ? entry.aspectRatioText
        : entry.isSized
        ? entry.getResolutionText(locale)
        : '';
    final mediaText = [
      if (resolutionText.isNotEmpty) resolutionText,
      if (frameRate != null && frameRate! > 0) _formatFrameRate(frameRate!),
    ].join(' · ');

    return Row(
      children: [
        Icon(
          AIcons.date,
          size: ViewerDetailOverlayContent.iconSize,
          shadows: ViewerDetailOverlayContent.shadows(context),
        ),
        const SizedBox(width: ViewerDetailOverlayContent.iconPadding),
        Expanded(flex: 3, child: Text(dateText)),
        Expanded(flex: 2, child: Text(mediaText)),
      ],
    );
  }

  /// Drops the decimal part only when it is actually zero,
  /// so that `60.0` reads `60` while `29.97` is left untouched.
  static String _formatFrameRate(double value) {
    var text = value.toStringAsFixed(2);
    if (text.contains('.')) {
      text = text.replaceFirst(RegExp(r'0+$'), '');
      text = text.replaceFirst(RegExp(r'\.$'), '');
    }
    return text;
  }
}
