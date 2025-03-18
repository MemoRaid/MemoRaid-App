import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'dart:async';

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
      // Map specific story titles to their actual file names
      String audioPath = 'lib/assets/audio/';
      if (storyTitle == 'The Family Reunion') {
        audioPath += 'Story1.mp3';
      } else if (storyTitle == 'The World Traveler') {
        audioPath += 'Story2.mp3';
      } else {
        // For stories without specific audio files, create a file name based on the title
        String audioFileName = storyTitle.toLowerCase().replaceAll(' ', '_');
        audioPath += '$audioFileName.mp3';
      }

      print('Attempting to load audio file: $audioPath');

      // Try to load the audio file
      if (storyTitle == 'The Family Reunion' ||
          storyTitle == 'The World Traveler') {
        await _player.setAsset(audioPath);
        print('Successfully loaded story audio: $storyTitle');
      } else {
        // For other stories, use a sample audio as fallback
        print('No specific audio file for this story, using fallback');
        await _player.setUrl(
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3');
      }
    } catch (e) {
      print('Error loading audio: $e');

      // Fallback to online sample if local audio fails
      try {
        await _player.setUrl(
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3');
        print('Loaded fallback audio');
      } catch (fallbackError) {
        print('Error loading fallback audio: $fallbackError');
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
