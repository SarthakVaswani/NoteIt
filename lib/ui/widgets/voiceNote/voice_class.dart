import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

final pathToSave = 'audio_ex.mp4';

class NoteRecorder {
  FlutterSoundRecorder _flutterSoundRecorder;
  bool _isRecinitialised = false;
  bool get isRecording => _flutterSoundRecorder.isRecording;

  Future init() async {
    _flutterSoundRecorder = FlutterSoundRecorder();
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone Permission');
    }
    await _flutterSoundRecorder.openAudioSession();
    _isRecinitialised = true;
  }

  void dispose() {
    if (_isRecinitialised) return;
    _flutterSoundRecorder.closeAudioSession();
    _flutterSoundRecorder = null;
    _isRecinitialised = false;
  }

  Future _record() async {
    if (_isRecinitialised) return;
    await _flutterSoundRecorder.startRecorder(toFile: pathToSave);
  }

  Future _stop() async {
    if (_isRecinitialised) return;
    await _flutterSoundRecorder.stopRecorder();
  }

  Future toggleRec() async {
    if (_isRecinitialised) return;
    if (_flutterSoundRecorder.isStopped) {
      await _record();
    } else {
      await _stop();
    }
  }
}
