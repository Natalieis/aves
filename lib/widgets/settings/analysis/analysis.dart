import 'dart:async';

import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
import 'package:aves/widgets/settings/settings_definition.dart';
import 'package:aves_model/aves_model.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class CatalogCount {
  final int total, catalogued;

  new(this.total, this.catalogued);

  double get ratio => total == 0 ? 0 : catalogued / total;

  int get percent => (ratio * 100).round();
}

class AnalysisSection extends SettingsSection {
  // cataloguing progress is only informational, no need to recount while scrolling
  static const _countsTtl = Duration(seconds: 5);

  CatalogCount _images = CatalogCount(0, 0);
  CatalogCount _videos = CatalogCount(0, 0);
  DateTime? _countedAt;

  @override
  String get key => 'analysis';

  @override
  Widget icon(BuildContext context) => SettingsTileLeading(
    icon: AIcons.analysis,
    color: context.select<AvesColorsData, Color>((v) => v.analysis),
  );

  @override
  String title(BuildContext context) => context.l10n.settingsAnalysisSectionTitle;

  Future<void> _count(BuildContext context) async {
    final now = DateTime.now();
    final countedAt = _countedAt;
    if (countedAt != null && now.difference(countedAt) < _countsTtl) return;

    final CollectionSource source;
    try {
      source = context.read<CollectionSource>();
    } on ProviderNotFoundException {
      // the section can also be built outside the main app tree (e.g. settings search)
      return;
    }

    var imageTotal = 0, imageDone = 0, videoTotal = 0, videoDone = 0;
    for (final entry in source.allEntries) {
      if (entry.isVideo) {
        videoTotal++;
        if (entry.isCatalogued) videoDone++;
      } else {
        imageTotal++;
        if (entry.isCatalogued) imageDone++;
      }
    }
    _images = CatalogCount(imageTotal, imageDone);
    _videos = CatalogCount(videoTotal, videoDone);
    _countedAt = now;
  }

  @override
  Future<List<SettingsTile>> tiles(BuildContext context) async {
    await _count(context);
    return [
      SettingsTileAutoAnalyze(images: _images, videos: _videos),
    ];
  }
}

class SettingsTileAutoAnalyze extends SettingsTile {
  final CatalogCount images, videos;

  new({required this.images, required this.videos});

  @override
  List<String> get settingKeys => [SettingKeys.autoAnalyzeKey];

  @override
  String title(BuildContext context) => context.l10n.settingsAutoAnalyze;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Selector<Settings, bool>(
      selector: (context, s) => s.autoAnalyze,
      builder: (context, value, child) => SwitchListTile(
        value: value,
        onChanged: (v) => settings.autoAnalyze = v,
        title: Text(title(context)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.settingsAutoAnalyzeSubtitle),
            const SizedBox(height: 8),
            _ProgressRow(label: l10n.catalogImagesLabel, count: images),
            const SizedBox(height: 4),
            _ProgressRow(label: l10n.catalogVideosLabel, count: videos),
          ],
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final CatalogCount count;

  const new({
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label · ${context.l10n.catalogProgress(count.catalogued, count.total, count.percent)}'),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: count.ratio,
            minHeight: 3,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}
