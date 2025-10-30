import 'package:flutter_test/flutter_test.dart';
import 'package:kazumi/modules/download/download_task.dart';

void main() {
  group('DownloadTask', () {
    test('should calculate progress correctly', () {
      final task = DownloadTask(
        gid: 'test-gid',
        url: 'http://example.com/file.mp4',
        title: 'Test Download',
        totalLength: 1000,
        completedLength: 500,
        downloadSpeed: 0,
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(task.progress, 0.5);
    });

    test('should return 0 progress when totalLength is 0', () {
      final task = DownloadTask(
        gid: 'test-gid',
        url: 'http://example.com/file.mp4',
        title: 'Test Download',
        totalLength: 0,
        completedLength: 0,
        downloadSpeed: 0,
        status: 'waiting',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(task.progress, 0.0);
    });

    test('should correctly identify active status', () {
      final task = DownloadTask(
        gid: 'test-gid',
        url: 'http://example.com/file.mp4',
        title: 'Test Download',
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(task.isActive, true);
      expect(task.isWaiting, false);
      expect(task.isPaused, false);
      expect(task.isComplete, false);
      expect(task.isError, false);
    });

    test('should correctly identify completed status', () {
      final task = DownloadTask(
        gid: 'test-gid',
        url: 'http://example.com/file.mp4',
        title: 'Test Download',
        status: 'complete',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(task.isComplete, true);
      expect(task.isActive, false);
    });

    test('should create task from aria2 status', () {
      final aria2Status = {
        'gid': 'abc123',
        'status': 'active',
        'totalLength': '10485760',
        'completedLength': '5242880',
        'downloadSpeed': '1048576',
        'files': [
          {
            'path': '/downloads/video.mp4',
            'uris': [
              {'uri': 'http://example.com/video.mp4'}
            ]
          }
        ]
      };

      final task = DownloadTask.fromAria2Status(
        aria2Status,
        title: 'My Video',
      );

      expect(task.gid, 'abc123');
      expect(task.status, 'active');
      expect(task.totalLength, 10485760);
      expect(task.completedLength, 5242880);
      expect(task.downloadSpeed, 1048576);
      expect(task.title, 'My Video');
      expect(task.url, 'http://example.com/video.mp4');
      expect(task.fileName, '/downloads/video.mp4');
    });

    test('copyWith should update only specified fields', () {
      final original = DownloadTask(
        gid: 'test-gid',
        url: 'http://example.com/file.mp4',
        title: 'Original Title',
        status: 'active',
        completedLength: 100,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = original.copyWith(
        title: 'Updated Title',
        completedLength: 200,
      );

      expect(updated.title, 'Updated Title');
      expect(updated.completedLength, 200);
      expect(updated.gid, 'test-gid'); // unchanged
      expect(updated.url, 'http://example.com/file.mp4'); // unchanged
      expect(updated.status, 'active'); // unchanged
    });

    test('should identify downloading status', () {
      final activeTask = DownloadTask(
        gid: 'test-gid',
        url: 'http://example.com/file.mp4',
        title: 'Test Download',
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final waitingTask = DownloadTask(
        gid: 'test-gid-2',
        url: 'http://example.com/file2.mp4',
        title: 'Test Download 2',
        status: 'waiting',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(activeTask.isDownloading, true);
      expect(waitingTask.isDownloading, true);
    });
  });
}
