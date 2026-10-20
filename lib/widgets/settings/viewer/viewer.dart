import 'dart:async';

import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/basic/list_tiles/slider.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/tile_leading.dart';
import 'package:aves/widgets/settings/common/tiles/sub_page.dart';
import 'package:aves/widgets/settings/common/tiles/switch_list.dart';
import 'package:aves/widgets/settings/settings_definition.dart';
import 'package:aves/widgets/settings/viewer/entry_background.dart';
import 'package:aves/widgets/settings/viewer/overlay_page.dart';
import 'package:aves/widgets/settings/viewer/slideshow_page.dart';
import 'package:aves/widgets/settings/viewer/viewer_actions_editor_page.dart';
import 'package:aves_model/aves_model.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class ViewerSection extends SettingsSection {
  @override
  String get key => 'viewer';

  @override
  Widget icon(BuildContext context) => SettingsTileLeading(
    icon: AIcons.image,
    color: context.select<AvesColorsData, Color>((v) => v.image),
  );

  @override
  String title(BuildContext context) => context.l10n.settingsViewerSectionTitle;

  @override
  Future<List<SettingsTile>> tiles(BuildContext context) async {
    final isCutoutAware = await windowService.isCutoutAware();
    return [
      if (!settings.useTvLayout) SettingsTileViewerQuickActions(),
      SettingsTileViewerOverlay(),
      SettingsTileViewerSlideshow(),
      if (!settings.useTvLayout) SettingsTileViewerGestureSideTapNext(),
      if (!settings.useTvLayout) SettingsTileViewerSideTapArea(),
      if (!settings.useTvLayout && isCutoutAware) SettingsTileViewerUseCutout(),
      SettingsTileViewerMotionPhotoAutoPlay(),
      SettingsTileViewerImageBackground(),
    ];
  }
}

class SettingsTileViewerQuickActions extends SettingsTile {
  @override
  List<String> get settingKeys => ViewerActionEditorPage.settingKeys;

  @override
  String title(BuildContext context) => context.l10n.settingsViewerQuickActionsTile;

  @override
  Widget build(BuildContext context) => SettingsSubPageTile(
    title: title,
    routeName: ViewerActionEditorPage.routeName,
    builder: (context) => const ViewerActionEditorPage(),
  );
}

class SettingsTileViewerOverlay extends SettingsTile {
  @override
  List<String> get settingKeys => ViewerOverlayPage.settingKeys;

  @override
  String title(BuildContext context) => context.l10n.settingsViewerOverlayTile;

  @override
  Widget build(BuildContext context) => SettingsSubPageTile(
    title: title,
    routeName: ViewerOverlayPage.routeName,
    builder: (context) => const ViewerOverlayPage(),
  );
}

class SettingsTileViewerSlideshow extends SettingsTile {
  @override
  List<String> get settingKeys => ViewerSlideshowPage.settingKeys;

  @override
  String title(BuildContext context) => context.l10n.settingsViewerSlideshowTile;

  @override
  Widget build(BuildContext context) => SettingsSubPageTile(
    title: title,
    routeName: ViewerSlideshowPage.routeName,
    builder: (context) => const ViewerSlideshowPage(),
  );
}

class SettingsTileViewerGestureSideTapNext extends SettingsTile {
  @override
  List<String> get settingKeys => [SettingKeys.viewerGestureSideTapNextKey];

  @override
  String title(BuildContext context) => context.l10n.settingsViewerGestureSideTapNext;

  @override
  Widget build(BuildContext context) => SettingsSwitchListTile(
    selector: (context, s) => s.viewerGestureSideTapNext,
    onChanged: (v) => settings.viewerGestureSideTapNext = v,
    title: title,
  );
}

class SettingsTileViewerSideTapArea extends SettingsTile {
  @override
  List<String> get settingKeys => [SettingKeys.viewerSideTapAreaPercentKey];

  @override
  String title(BuildContext context) => context.l10n.settingsViewerSideTapArea;

  @override
  Widget build(BuildContext context) => Selector<Settings, int>(
    selector: (context, s) => s.viewerSideTapAreaPercent,
    builder: (context, percent, child) => SliderListTile(
      title: (_) => context.l10n.settingsViewerSideTapArea,
      // 0 keeps the automatic ratio, 1 to 30 is a fixed percentage
      value: percent.toDouble(),
      min: 0,
      max: 30,
      divisions: 30,
      onChanged: (v) => settings.viewerSideTapAreaPercent = v.round(),
      titleTrailing: (context, v) => Text(v <= 0 ? context.l10n.settingsViewerSideTapAreaAuto : '${v.round()}%'),
    ),
  );
}

class SettingsTileViewerUseCutout extends SettingsTile {
  @override
  List<String> get settingKeys => [SettingKeys.viewerUseCutoutKey];

  @override
  String title(BuildContext context) => context.l10n.settingsViewerUseCutout;

  @override
  Widget build(BuildContext context) => SettingsSwitchListTile(
    selector: (context, s) => s.viewerUseCutout,
    onChanged: (v) => settings.viewerUseCutout = v,
    title: title,
  );
}

class SettingsTileViewerMotionPhotoAutoPlay extends SettingsTile {
  @override
  List<String> get settingKeys => [SettingKeys.enableMotionPhotoAutoPlayKey];

  @override
  String title(BuildContext context) => context.l10n.settingsMotionPhotoAutoPlay;

  @override
  Widget build(BuildContext context) => SettingsSwitchListTile(
    selector: (context, s) => s.enableMotionPhotoAutoPlay,
    onChanged: (v) => settings.enableMotionPhotoAutoPlay = v,
    title: title,
  );
}

class SettingsTileViewerImageBackground extends SettingsTile {
  @override
  List<String> get settingKeys => [SettingKeys.imageBackgroundKey];

  @override
  String title(BuildContext context) => context.l10n.settingsImageBackground;

  @override
  Widget build(BuildContext context) => Selector<Settings, EntryBackground>(
    selector: (context, s) => s.imageBackground,
    builder: (context, current, child) => ListTile(
      title: Text(title(context)),
      trailing: EntryBackgroundSelector(
        getter: () => current,
        setter: (value) => settings.imageBackground = value,
      ),
    ),
  );
}
