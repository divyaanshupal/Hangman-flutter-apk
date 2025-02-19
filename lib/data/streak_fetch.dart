import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StreakService {
  static Future<int> fetchMaxStreak() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (userId.isEmpty) return 0; // Default value if no user is logged in

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('streak')
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('maxStreak')) {
          return data['maxStreak'] as int;
        }
      }
    } catch (e) {
      print("Error fetching max streak: $e");
    }
    return 0; // Default if not found
  }
}
