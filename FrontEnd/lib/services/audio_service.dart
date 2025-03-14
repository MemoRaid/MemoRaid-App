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
    // In a real app, you would have actual audio files for each story
    // For now, we'll use a dummy URL based on the story title
    final audioUrl = 'https://example.com/audio/$storyTitle.mp3';

    // For demo purposes, let's use a sample audio URL
    // You'd replace this with actual story audio files
    await _player.setUrl(
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3');
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

  
