import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';

class MicState {
  final String? userId;
  final String? userName;

  MicState({this.userId, this.userName});

  MicState.empty()
      : userId = null,
        userName = null;

  factory MicState.fromMap(Map<dynamic, dynamic> data) {
    return MicState(
      userId: data['userId'] as String?,
      userName: data['userName'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
    };
  }
}

class MicStateNotifier extends StateNotifier<List<MicState>> {
  MicStateNotifier() : super(List.generate(10, (_) => MicState.empty()));

  final DatabaseReference _micRef =
      FirebaseDatabase.instance.ref('mic_assignments/');

  void initialize() {
    _micRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        final updatedState = List<MicState>.generate(
          10,
          (index) {
            final micData = data['mic_$index'];
            return micData != null
                ? MicState.fromMap(micData)
                : MicState.empty();
          },
        );
        state = updatedState;
      }
    });
  }

  Future<void> assignMic(int index, String userId, String userName) async {
    try {
      await _micRef.child('mic_$index').set({
        'userId': userId,
        'userName': userName,
      });
      print('Mic $index assigned to $userName.');
    } catch (e) {
      print('Error assigning mic: $e');
    }
  }

  Future<void> releaseMic(int index) async {
    try {
      await _micRef.child('mic_$index').remove();
      print('Mic $index released.');
    } catch (e) {
      print('Error releasing mic: $e');
    }
  }
}

final micStateProvider =
    StateNotifierProvider<MicStateNotifier, List<MicState>>((ref) {
  final notifier = MicStateNotifier();
  notifier.initialize();
  return notifier;
});
