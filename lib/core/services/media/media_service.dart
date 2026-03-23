import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../utils/path_utils.dart';

part 'media_service.g.dart';

@riverpod
MediaService mediaService(Ref ref) => MediaService();

class MediaService {
  final _uuid = const Uuid();
  final _picker = ImagePicker();

  // ── 디렉토리 ───────────────────────────────────────────────────────────────

  Future<Directory> get _photosDir async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'media', 'photos'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<Directory> get _thumbsDir async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'media', 'thumbnails'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<Directory> get _voiceDir async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'media', 'voice'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<Directory> get _videoDir async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'media', 'videos'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  // ── 사진 선택 + 저장 ──────────────────────────────────────────────────────

  /// 갤러리에서 사진 선택 후 압축 저장
  /// 반환: {photoPath, thumbnailPath} 또는 null (취소)
  Future<({String photoPath, String thumbnailPath})?> pickAndSavePhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 90,
    );
    if (picked == null) return null;
    return _compressAndSave(File(picked.path));
  }

  /// 카메라로 촬영 후 저장
  Future<({String photoPath, String thumbnailPath})?> captureAndSavePhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 90,
    );
    if (picked == null) return null;
    return _compressAndSave(File(picked.path));
  }

  Future<({String photoPath, String thumbnailPath})> _compressAndSave(
      File source) async {
    final id = _uuid.v4();
    final photosDir = await _photosDir;
    final thumbsDir = await _thumbsDir;

    final photoPath = p.join(photosDir.path, '$id.webp');
    final thumbPath = p.join(thumbsDir.path, '${id}_thumb.webp');

    // 원본 WebP 압축
    final photo = await FlutterImageCompress.compressAndGetFile(
      source.absolute.path,
      photoPath,
      format: CompressFormat.webp,
      quality: 85,
      minWidth: 1,
      minHeight: 1,
    );
    // 압축 실패 시 원본 복사
    if (photo == null) await source.copy(photoPath);

    // 썸네일 생성
    final thumb = await FlutterImageCompress.compressAndGetFile(
      source.absolute.path,
      thumbPath,
      format: CompressFormat.webp,
      quality: 70,
      minWidth: 300,
      minHeight: 300,
    );
    // 썸네일 실패 시 원본 복사
    if (thumb == null) await source.copy(thumbPath);

    // DB에는 Documents 기준 상대 경로 저장 (iOS 컨테이너 경로 변경 대비)
    final relativePhoto = PathUtils.toRelative(photoPath) ?? photoPath;
    final relativeThumb = PathUtils.toRelative(thumbPath) ?? thumbPath;
    return (photoPath: relativePhoto, thumbnailPath: relativeThumb);
  }

  /// 아바타(프로필/노드) 사진 저장 — UUID 고유 경로 + 반환값 검증
  /// 반환: Documents 기준 상대 경로 (예: media/photos/avatar_xxx.webp)
  Future<String?> pickAndSaveAvatar() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (picked == null) return null;

    final photosDir = await _photosDir;
    final id = _uuid.v4();
    final avatarPath = p.join(photosDir.path, 'avatar_$id.webp');
    final result = await FlutterImageCompress.compressAndGetFile(
      picked.path,
      avatarPath,
      format: CompressFormat.webp,
      quality: 85,
      minWidth: 256,
      minHeight: 256,
    );
    if (result == null) return null;
    // DB에는 Documents 기준 상대 경로 저장 (iOS 컨테이너 경로 변경 대비)
    return PathUtils.toRelative(avatarPath) ?? avatarPath;
  }

  // ── 음성 ─────────────────────────────────────────────────────────────────

  Future<String> getVoicePath(String filename) async {
    final dir = await _voiceDir;
    return p.join(dir.path, filename);
  }

  Future<String> newVoicePath() async {
    final dir = await _voiceDir;
    return p.join(dir.path, '${_uuid.v4()}.m4a');
  }

  // ── 영상 선택/촬영 + 저장 ────────────────────────────────────────────────

  /// 갤러리에서 영상 선택 후 로컬 저장
  /// 반환: 복사된 파일 경로 또는 null (취소)
  Future<String?> pickAndSaveVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return null;
    return _saveVideoFile(File(picked.path));
  }

  /// 카메라로 영상 촬영 후 로컬 저장
  Future<String?> captureAndSaveVideo({required int maxSeconds}) async {
    final picked = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: maxSeconds > 0 ? Duration(seconds: maxSeconds) : null,
    );
    if (picked == null) return null;
    return _saveVideoFile(File(picked.path));
  }

  /// 영상 파일을 Documents/media/videos/에 복사 후 상대 경로 반환
  Future<String?> _saveVideoFile(File src) async {
    final dir = await _videoDir;
    final uuid = _uuid.v4();
    final dest = File(p.join(dir.path, '$uuid.mp4'));
    await src.copy(dest.path);
    // DB에는 Documents 기준 상대 경로 저장
    return PathUtils.toRelative(dest.path) ?? dest.path;
  }

  /// 영상에서 첫 프레임 썸네일 이미지 생성 (JPG)
  /// videoPath는 상대/절대 모두 지원
  Future<String?> generateVideoThumbnail(String videoPath) async {
    try {
      final thumbsDir = await _thumbsDir;
      final id = _uuid.v4();
      final thumbPath = p.join(thumbsDir.path, 'video_thumb_$id.jpg');
      // videoPath가 상대 경로일 수 있으므로 절대 경로로 변환
      final absoluteVideoPath = PathUtils.toAbsolute(videoPath) ?? videoPath;
      final result = await VideoThumbnail.thumbnailFile(
        video: absoluteVideoPath,
        thumbnailPath: thumbPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 600,
        quality: 80,
        timeMs: 0,
      );
      if (result == null) return null;
      // 상대 경로로 반환
      return PathUtils.toRelative(result) ?? result;
    } catch (_) {
      return null;
    }
  }

  // ── 삭제 ─────────────────────────────────────────────────────────────────

  Future<void> deleteFile(String? path) async {
    if (path == null) return;
    final absolutePath = PathUtils.toAbsolute(path) ?? path;
    final file = File(absolutePath);
    if (await file.exists()) await file.delete();
  }

  Future<void> deleteVideo(String path) async {
    final absolutePath = PathUtils.toAbsolute(path) ?? path;
    final f = File(absolutePath);
    if (f.existsSync()) f.deleteSync();
  }

  // ── 미디어 디렉토리 전체 경로 (백업용) ──────────────────────────────────

  Future<Directory> get mediaRootDir async {
    final base = await getApplicationDocumentsDirectory();
    return Directory(p.join(base.path, 'media'));
  }
}
