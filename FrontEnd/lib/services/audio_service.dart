import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  final _positionSubject = StreamController<Duration>.broadcast();
  final _stateSubject = StreamController<bool>.broadcast();

  Stream<Duration> get positionStream => _positionSubject.stream;
  Stream<bool> get playingStream => _stateSubject.stream;

  AudioService() {
    _init();
    _player.positionStream.listen((position) {
      _positionSubject.add(position);
    });

    _player.playerStateStream.listen((state) {
      final isPlaying = state.playing;
      _stateSubject.add(isPlaying);
    });
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  }

  Future<void> loadStoryAudio(String storyTitle) async {
    try {
      // Clear any previous audio
      await _player.stop();

      // Debug the story title being requested
      developer.log('Loading audio for story: "$storyTitle"');

      // Using direct path mapping for each story with audio
      if (storyTitle == 'The Family Reunion') {
        developer.log('Loading Story1.mp3');
        await _player.setAsset('lib/assets/audio/Story1.mp3');
      } else if (storyTitle == 'The World Traveler') {
        developer.log('Loading Story2.mp3');
        await _player.setAsset('lib/assets/audio/Story2.mp3');
      } else if (storyTitle == 'The Battle of Rivers Crossing') {
        // Use a more direct approach for Story4
        developer.log('Attempting to load Story4.mp3');

        try {
          // Try loading directly with the absolute path first
          await _player.setAsset('lib/assets/audio/Story4.mp3');
          developer.log('Successfully loaded Story4.mp3');
        } catch (error) {
          developer.log('Failed to load Story4.mp3: $error', error: error);

          // Try with a folder path approach
          try {
            await _player.setAsset('assets/audio/Story4.mp3');
            developer.log('Loaded Story4 with assets/ prefix');
          } catch (error2) {
            // Final fallback to online sample
            developer.log(
                'All attempts to load Story4.mp3 failed, using online sample');
            await _player.setUrl(
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3');
          }
        }
      } else {
        // Use online sample for other stories
        developer.log('No audio mapping for $storyTitle, using online sample');
        await _player.setUrl(
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3');
      }
    } catch (e) {
      developer.log('Error in loadStoryAudio: $e', error: e);

      // Fallback to online sample
      try {
        await _player.setUrl(
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3');
      } catch (fallbackError) {
        developer.log('Failed to load fallback audio', error: fallbackError);
      }
    }
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
  }
}
