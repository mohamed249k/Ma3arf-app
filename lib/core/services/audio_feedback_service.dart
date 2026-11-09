import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:ma3arf/core/services/storage_service.dart';

class AudioFeedbackService {
  AudioFeedbackService._();
  static final AudioFeedbackService instance = AudioFeedbackService._();

  bool _isSoundEnabled = true;
  bool _isInitialized = false;
  AudioPlayer? _player;
  DateTime _lastPlayTime = DateTime.fromMillisecondsSinceEpoch(0);

  bool get isSoundEnabled => _isSoundEnabled;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isSoundEnabled = await StorageService.loadSoundEnabled();
    try {
      _player = AudioPlayer();
      await _player?.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.assistanceSonification,
            audioFocus: AndroidAudioFocus.none,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
            options: const {AVAudioSessionOptions.mixWithOthers},
          ),
        ),
      );
      await _player?.setPlayerMode(PlayerMode.lowLatency);
    } catch (_) {
      // Gracefully fall back if low-level audio context cannot be configured
    }
    _isInitialized = true;
  }

  Future<void> toggleSound() async {
    _isSoundEnabled = !_isSoundEnabled;
    await StorageService.saveSoundEnabled(_isSoundEnabled);
    if (_isSoundEnabled) {
      playClick();
      try {
        HapticFeedback.lightImpact();
      } catch (_) {}
    }
  }

  Future<void> _playSound(String assetFileName, {double volume = 0.85}) async {
    if (!_isSoundEnabled) return;
    final now = DateTime.now();
    if (now.difference(_lastPlayTime).inMilliseconds < 40) {
      return; // Rate limit to prevent sound pileup
    }
    _lastPlayTime = now;

    try {
      if (_player != null) {
        await _player?.stop();
        await _player?.setVolume(volume);
        await _player?.play(AssetSource('audio/$assetFileName'));
      } else {
        SystemSound.play(SystemSoundType.click);
      }
    } catch (_) {
      try {
        SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
  }

  void playCorrect() {
    if (!_isSoundEnabled) return;
    _playSound('correct.wav', volume: 0.9);
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  void playIncorrect() {
    if (!_isSoundEnabled) return;
    _playSound('incorrect.wav', volume: 0.8);
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  void playQuizComplete() {
    if (!_isSoundEnabled) return;
    _playSound('complete.wav', volume: 0.95);
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  void playAchievement() {
    if (!_isSoundEnabled) return;
    _playSound('achievement.wav', volume: 0.95);
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  void playClick() {
    if (!_isSoundEnabled) return;
    _playSound('click.wav', volume: 0.6);
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
  }

  void playCountdownAlert(int secondsLeft) {
    if (!_isSoundEnabled) return;
    if (secondsLeft <= 3 && secondsLeft > 0) {
      _playSound('countdown.wav', volume: 0.7);
      try {
        HapticFeedback.selectionClick();
      } catch (_) {}
    }
  }

  void dispose() {
    try {
      _player?.dispose();
    } catch (_) {}
    _player = null;
  }
}
