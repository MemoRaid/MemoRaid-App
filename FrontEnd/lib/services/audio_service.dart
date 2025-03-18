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
      } else if (storyTitle == 'The Mansion Mystery') {
        developer.log('Loading Story3.mp3');
        await _player.setAsset('lib/assets/audio/Story3.mp3');
      } else if (storyTitle == 'The Battle of Rivers Crossing') {
        developer.log('Loading Story4.mp3');
        await _player.setAsset('lib/assets/audio/Story5.mp3');
      } else if (storyTitle == 'Arctic Expedition Crisis') {
        // Add support for Arctic Expedition Crisis story
        developer.log('Loading Story6.mp3');
        await _player.setAsset('lib/assets/audio/Story7.mp3');
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
