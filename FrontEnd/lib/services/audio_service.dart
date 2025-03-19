import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  final _positionSubject = StreamController<Duration>.broadcast();
  final _stateSubject = StreamController<bool>.broadcast();
  final _completionSubject =
      StreamController<void>.broadcast(); // New stream for completion events
  final Map<String, Duration?> _audioDurations = {};

  Stream<Duration> get positionStream => _positionSubject.stream;
  Stream<bool> get playingStream => _stateSubject.stream;
  Stream<void> get completionStream =>
      _completionSubject.stream; // Expose completion stream

  AudioService() {
    _init();
    _player.positionStream.listen((position) {
      _positionSubject.add(position);
    });

    _player.playerStateStream.listen((state) {
      final isPlaying = state.playing;
      _stateSubject.add(isPlaying);
    });

    // Listen for completion events
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _completionSubject.add(null);
      }
    });
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  }

  Future<void> loadStoryAudio(String storyTitle) async {
    try {
      // Clear any previous audio

      // Debug the story title being requested
      developer.log('Loading audio for story: "$storyTitle"');

      // Using direct path mapping for each story with audio
      if (storyTitle == 'The Family Reunion') {
        developer.log('Loading Story1.mp3');
        await _player.setAsset('lib/assets/audio/Story1.mp3');
      } else if (storyTitle == 'The World Traveler') {
        developer.log('Loading Story2.mp3');
        await _player.setAsset('lib/assets/audio/Story2.mp3');
      } else if (storyTitle == 'The Mansion Mystery') {
        developer.log('Loading Story3.mp3');
        await _player.setAsset('lib/assets/audio/Story3.mp3');
      } else if (storyTitle == 'The Battle of Rivers Crossing') {
        developer.log('Loading Story5.mp3');
        await _player.setAsset('lib/assets/audio/Story5.mp3');
      } else if (storyTitle == 'Arctic Expedition Crisis') {
        developer.log('Loading Story7.mp3');
        await _player.setAsset('lib/assets/audio/Story7.mp3');
      } else if (storyTitle == 'The Mars Mission Anomaly') {
        developer.log('Loading Story8.mp3');
        await _player.setAsset('lib/assets/audio/Story8.mp3');
      } else if (storyTitle == 'The Rainforest Expedition') {
        developer.log('Loading Story9.mp3');
        await _player.setAsset('lib/assets/audio/Story9.mp3');
      } else {
        // Use online sample for other stories
        developer.log('No audio mapping for $storyTitle, using online sample');
        await _player.setUrl(
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3');
      }
    } catch (e) {
      developer.log('Error loading audio: $e', error: e);

      // Fallback to online sample if any audio fails
      try {
        await _player.setUrl(
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3');
        developer.log('Loaded fallback audio');
      } catch (fallbackError) {
        developer.log('Failed to load fallback audio', error: fallbackError);
      }
    }
  }

  // Add this method to preload audio duration without playing
  Future<void> preloadAudioDuration(String storyTitle) async {
    final tempPlayer = AudioPlayer();
    try {
      // Use the same audio path mapping logic as in loadStoryAudio
      if (storyTitle == 'The Family Reunion') {
        await tempPlayer.setAsset('lib/assets/audio/Story1.mp3');
      } else if (storyTitle == 'The World Traveler') {
        await tempPlayer.setAsset('lib/assets/audio/Story2.mp3');
      } else if (storyTitle == 'The Mansion Mystery') {
        await tempPlayer.setAsset('lib/assets/audio/Story3.mp3');
      } else if (storyTitle == 'The Battle of Rivers Crossing') {
        await tempPlayer.setAsset('lib/assets/audio/Story5.mp3');
      } else if (storyTitle == 'Arctic Expedition Crisis') {
        await tempPlayer.setAsset('lib/assets/audio/Story7.mp3');
      } else if (storyTitle == 'The Mars Mission Anomaly') {
        await tempPlayer.setAsset('lib/assets/audio/Story8.mp3');
      } else if (storyTitle == 'The Rainforest Expedition') {
        await tempPlayer.setAsset('lib/assets/audio/Story9.mp3');
      }

      // Get the duration and store it
      final duration = await tempPlayer.duration;
      _audioDurations[storyTitle] = duration;
    } catch (e) {
      developer.log('Error preloading audio duration: $e', error: e);
    } finally {
      await tempPlayer.dispose();
    }
  }

  // Add method to get cached duration
  Future<Duration?> getAudioDuration(String storyTitle) async {
    // Return cached duration if available
    return _audioDurations[storyTitle];
  }

  void play() {
    _player.play();
  }

  void pause() {
    _player.pause();
  }

  void seek(Duration position) {
    _player.seek(position);
  }

  Future<Duration?> get duration => Future.value(_player.duration);

  bool get isPlaying => _player.playing;

  void dispose() {
    _player.dispose();
    _positionSubject.close();
    _stateSubject.close();
    _completionSubject.close(); // Close the new stream
  }
}
