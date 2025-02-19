import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';



Future<String> savingStreak(int currentS , int maxS , String id ) async{
  String res = "done";
  try{
   await FirebaseFirestore.instance.collection('streak').doc(id).set({
    'maxStreak': maxS,
    'currentStreak': currentS,

  }, SetOptions(merge: true));}
      catch(e){
    res = e.toString();
      }

      return res;
}

// class CustomDrawer extends StatelessWidget {
//   const CustomDrawer({Key? key}) : super(key: key);
//
//   Future<int> fetchMaxStreak() async {
//     String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
//     if (userId.isEmpty) return 0;
//
//     try {
//       DocumentSnapshot doc =
//       await FirebaseFirestore.instance.collection('users').doc(userId).get();
//
//       if (doc.exists && doc.data() != null) {
//         return (doc['maxStreak'] ?? 0) as int; // Return maxStreak value
//       }
//     } catch (e) {
//       print("Error fetching max streak: ${e.toString()}");
//     }
//     return 0; // Default to 0 if not found
//   }