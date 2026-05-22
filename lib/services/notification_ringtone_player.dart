import 'package:audioplayers/audioplayers.dart';
import 'package:tranoo/utils/notification_sounds.dart';

class NotificationRingtonePlayer {
  static final AudioPlayer _player = AudioPlayer();
  static bool _playing = false;

  static Future<void> playAlertLoop() async {
    if (_playing) return;
    _playing = true;
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource(NotificationSounds.alertRingAsset));
  }

  static Future<void> stop() async {
    if (!_playing) return;
    _playing = false;
    await _player.stop();
  }
}
