import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';

/// Handles playing audio effects within the game.
///
/// Supports both one-shot and looping sounds. Volume of the sounds is
/// automatically adjusted based on the distance from the camera's centre so
/// that objects near the middle of the screen are louder than those far away.
class AudioManager {
  AudioManager._();

  static FlameGame? _game;
  static final Map<String, AudioPlayer> _loopingPlayers = {};

  /// Initialises the audio manager with a reference to the [game].
  ///
  /// Must be called before any sounds are played.
  static void initialize(FlameGame game) {
    _game = game;
    // All game audio files are expected to live under `assets/sounds/`.
    FlameAudio.audioCache.prefix = '';
  }

  /// Calculates volume factor depending on how close [position] is to the
  /// centre of the screen. Returns a value in the 0-1 range.
  static double _volumeFor(Vector2 position) {
    final game = _game;
    if (game == null) {
      return 1;
    }
    final cameraCentre = game.camera.viewport.position;
    final maxDistance = game.size.length; // Distance at which volume becomes 0
    final distance = position.distanceTo(cameraCentre);
    final normalized = 1 - distance / maxDistance;
    return normalized.clamp(0, 1);
  }

  /// Preloads a list of audio files so that they can be reused later without
  /// additional loading cost.
  static Future<void> preload(List<String> fileNames) async {
    await FlameAudio.audioCache.loadAll(fileNames);
  }

  /// Plays a single sound effect located at [fileName]. The [position] decides
  /// how loud the sound should be depending on its distance to the screen
  /// centre. Optional [baseVolume] can be used to further tune the volume.
  static Future<void> playOnce(String fileName, Vector2 position,
      {double baseVolume = 1}) async {
    final volume = _volumeFor(position) * baseVolume;
    await FlameAudio.play(fileName, volume: volume);
  }

  /// Starts playing a looping sound. The sound is identified by [key] so that
  /// its volume can be updated or it can be stopped later. The [position]
  /// defines the initial volume.
  static Future<void> playLoop(String key, String fileName, Vector2 position,
      {double baseVolume = 1}) async {
    final volume = _volumeFor(position) * baseVolume;
    final player = await FlameAudio.loop(fileName, volume: volume);
    _loopingPlayers[key] = player;
  }

  /// Updates volume for a previously started looping sound.
  static void updateLoop(String key, Vector2 position,
      {double baseVolume = 1}) {
    final player = _loopingPlayers[key];
    if (player == null) return;
    final volume = _volumeFor(position) * baseVolume;
    player.setVolume(volume);
  }

  /// Stops and removes a looping sound identified by [key].
  static Future<void> stopLoop(String key) async {
    final player = _loopingPlayers.remove(key);
    await player?.stop();
  }
}
