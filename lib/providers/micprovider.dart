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
  MicStateNotifier() : super(List.generate(8, (_) => MicState.empty()));

  final DatabaseReference _micRef =
      FirebaseDatabase.instance.ref('mic_assignments/');

  void initialize() {
    _micRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        final updatedState = List<MicState>.generate(
          8,
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
    final micRef = FirebaseDatabase.instance.ref('mic_assignments/mic_$index');
    final micSnapshot = await micRef.get();

    // Check if the mic is already occupied
    if (micSnapshot.exists && micSnapshot.child('userId').value != userId) {
      return; // Do nothing if the mic is already occupied by another user
    }

    // Update the mic state in the database
    await micRef.set({'userId': userId, 'userName': userName});

    // Update the mic state locally
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          MicState(userId: userId, userName: userName) // Assign the new mic
        else
          state[i]
    ];
  }

  Future<void> releaseMic(int index) async {
    // Reset the mic state in the database
    await FirebaseDatabase.instance.ref('mic_assignments/mic_$index').remove();

    // Update the mic state locally
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          MicState(userId: null, userName: null) // Reset mic
        else
          state[i]
    ];
  }
}

final micStateProvider =
    StateNotifierProvider<MicStateNotifier, List<MicState>>((ref) {
  final notifier = MicStateNotifier();
  notifier.initialize();
  return notifier;
});
