import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class const OverlayMetadata({
  final double? aperture,
  final String? exposureTime,
  final double? focalLength,
  final int? iso,
  final String? description,
  // file info
  final String? videoCodec,
  final double? frameRate,
  final int? bitRate,
}) extends Equatable {
  @override
  List<Object?> get props => [aperture, exposureTime, focalLength, iso, description, videoCodec, frameRate, bitRate];

  bool get hasShootingDetails => aperture != null || exposureTime != null || focalLength != null || iso != null;

  bool get hasFileInfo => videoCodec != null || frameRate != null || bitRate != null;

  factory fromMap(Map map) {
    return OverlayMetadata(
      aperture: map['aperture'] as double?,
      exposureTime: map['exposureTime'] as String?,
      focalLength: map['focalLength'] as double?,
      iso: map['iso'] as int?,
      description: map['description'] as String?,
      videoCodec: map['videoCodec'] as String?,
      frameRate: (map['frameRate'] as num?)?.toDouble(),
      bitRate: (map['bitRate'] as num?)?.toInt(),
    );
  }
}
