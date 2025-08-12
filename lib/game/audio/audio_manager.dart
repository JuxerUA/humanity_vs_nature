import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:audioplayers/audioplayers.dart';

/// Handles playing audio effects within the game.
///
/// Supports both one-shot and looping sounds. Volume of the sounds is
/// automatically adjusted based on the distance from the camera's centre so
/// that objects near the middle of the screen are louder than those far away.
class AudioManager {
  AudioManager(this.game) {
    // All game audio files are expected to live under `assets/sounds/`.
    FlameAudio.audioCache.prefix = 'assets/sounds/';
  }

  final FlameGame game;

  final Map<String, AudioPlayer> _loopingPlayers = {};

  /// Calculates volume factor depending on how close [position] is to the
  /// centre of the screen. Returns a value in the 0-1 range.
  double _volumeFor(Vector2 position) {
    final cameraCentre = game.camera.position;
    final maxDistance = game.size.length; // Distance at which volume becomes 0
    final distance = position.distanceTo(cameraCentre);
    final normalized = 1 - distance / maxDistance;
    return normalized.clamp(0, 1);
  }

  /// Plays a single sound effect located at [fileName]. The [position] decides
  /// how loud the sound should be depending on its distance to the screen
  /// centre. Optional [baseVolume] can be used to further tune the volume.
  Future<void> playOnce(String fileName, Vector2 position,
      {double baseVolume = 1}) async {
    final volume = _volumeFor(position) * baseVolume;
    await FlameAudio.play(fileName, volume: volume);
  }

  /// Starts playing a looping sound. The sound is identified by [key] so that
  /// its volume can be updated or it can be stopped later. The [position]
  /// defines the initial volume.
  Future<void> playLoop(String key, String fileName, Vector2 position,
      {double baseVolume = 1}) async {
    final volume = _volumeFor(position) * baseVolume;
    final player = await FlameAudio.loop(fileName, volume: volume);
    _loopingPlayers[key] = player;
  }

  /// Updates volume for a previously started looping sound.
  void updateLoop(String key, Vector2 position, {double baseVolume = 1}) {
    final player = _loopingPlayers[key];
    if (player == null) return;
    final volume = _volumeFor(position) * baseVolume;
    player.setVolume(volume);
  }

  /// Stops and removes a looping sound identified by [key].
  Future<void> stopLoop(String key) async {
    final player = _loopingPlayers.remove(key);
    await player?.stop();
  }
}
