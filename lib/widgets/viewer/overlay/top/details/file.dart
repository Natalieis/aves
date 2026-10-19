import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/metadata/overlay.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/utils/file_utils.dart';

/// Builds the compact media info text shown in the viewer corner badge,
/// e.g. `128.6 MB · AV1 · 12.4 Mbps`.
/// Resolution and frame rate are displayed with the date row instead.
String? buildMediaInfoText(AvesEntry entry, OverlayMetadata details, {bool includeBitRate = true}) {
  final parts = <String>[];

  final sizeBytes = entry.sizeBytes;
  if (sizeBytes != null && sizeBytes > 0) {
    parts.add(formatFileSize(settings.avesLocale, sizeBytes));
  }

  final format = _formatName(entry, details);
  if (format != null) {
    parts.add(format);
  }

  final bitRate = entry.catalogMetadata?.videoBitRate ?? details.bitRate;
  if (includeBitRate && bitRate != null && bitRate > 0) {
    parts.add(_formatBitRate(bitRate));
  }

  return parts.isEmpty ? null : parts.join(' · ');
}

String? _formatName(AvesEntry entry, OverlayMetadata details) {
  if (entry.isVideo) {
    // only report the actual codec (AV1, HEVC, ...), never the container (MKV, MP4, ...)
    // catalogued videos carry it in the database, uncatalogued ones fall back to the platform
    final codec = entry.catalogMetadata?.videoCodec ?? details.videoCodec;
    if (codec == null) return null;
    return _codecNames[codec] ?? _fallbackName(codec);
  }
  final mimeType = entry.mimeType;
  return _mimeNames[mimeType] ?? _fallbackName(mimeType);
}

const _codecNames = {
  'video/av01': 'AV1',
  'video/hevc': 'HEVC',
  'video/h265': 'HEVC',
  'video/avc': 'AVC',
  'video/h264': 'AVC',
  'video/x-vnd.on2.vp9': 'VP9',
  'video/x-vnd.on2.vp8': 'VP8',
  'video/mp4v-es': 'MPEG-4',
  'video/mpeg2': 'MPEG-2',
  'video/dolby-vision': 'Dolby Vision',
  // short names reported by ffmpeg/mpv during cataloguing
  'av1': 'AV1',
  'hevc': 'HEVC',
  'h265': 'HEVC',
  'h264': 'AVC',
  'avc': 'AVC',
  'vp9': 'VP9',
  'vp8': 'VP8',
  'mpeg4': 'MPEG-4',
  'mpeg2video': 'MPEG-2',
  'dolbyvision': 'Dolby Vision',
  'dvhe': 'Dolby Vision',
  'dvh1': 'Dolby Vision',
};

const _mimeNames = {
  'image/jpeg': 'JPEG',
  'image/heic': 'HEIC',
  'image/heif': 'HEIF',
  'image/avif': 'AVIF',
  'image/png': 'PNG',
  'image/gif': 'GIF',
  'image/webp': 'WebP',
  'image/svg+xml': 'SVG',
  'image/bmp': 'BMP',
  'image/tiff': 'TIFF',
  'video/mp4': 'MP4',
  'video/x-matroska': 'MKV',
  'video/webm': 'WebM',
  'video/quicktime': 'MOV',
  'video/3gpp': '3GP',
};

String? _fallbackName(String mimeType) {
  final slash = mimeType.indexOf('/');
  if (slash < 0 || slash == mimeType.length - 1) return null;
  final subtype = mimeType.substring(slash + 1);
  // drop vendor prefixes like `x-vnd.on2.`
  final cleaned = subtype.replaceFirst(RegExp(r'^x(-vnd)?\.?(on2\.)?'), '');
  return cleaned.toUpperCase();
}

String _formatBitRate(int bitRate) {
  if (bitRate >= 1000000) {
    return '${(bitRate / 1000000).toStringAsFixed(1)} Mbps';
  }
  return '${(bitRate / 1000).round()} kbps';
}
