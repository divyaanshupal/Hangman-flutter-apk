import 'package:flutter/material.dart';
import 'data/word_hints.dart';
import 'package:hangman_game/rules_screen.dart';
import 'package:hangman_game/game/figure_widget.dart';
import 'package:hangman_game/game/letters.dart';
import 'package:hangman_game/consts/consts.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';


import 'login_page.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  var characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  late String word;
  late String hint;
  List<String> selectedChar = [];
  var tries = 0;
  String selectedDifficulty = 'Easy'; // Default difficulty

  final Map<String, Set<String>> usedWords = {
    'Easy': {},
    'Medium': {},
    'Hard': {},
  };

  String playerName = "Divyanshu"; // Temporary Player Name
  int maxStreak = 0; // Tracks the maximum streak achieved
  int currentStreak = 0; // Tracks the current streak


  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    var availableWords = wordHints[selectedDifficulty]!
        .where((item) => !usedWords[selectedDifficulty]!.contains(item['word']))
        .toList();

    if (availableWords.isEmpty) {
      usedWords[selectedDifficulty]!.clear();
      availableWords = wordHints[selectedDifficulty]!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All words used. Resetting the word pool.')),
      );
    }

    var randomItem = availableWords[Random().nextInt(availableWords.length)];
    word = randomItem['word']!;
    hint = randomItem['hint']!;
    usedWords[selectedDifficulty]!.add(word);
    selectedChar.clear();
    tries = 0;
  }

  void _restartGame() {
    setState(() {
      _initializeGame();
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut(); // Logs out the user

    // Show a logout confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged out successfully!')),
    );

    // Redirect to LoginPage and remove all previous screens
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false, // Removes all routes from the stack
    );
  }
  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Game Over"),
          content: Text("You lost the game! The word was '$word'."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _restartGame();
              },
              child: const Text("Restart Game"),
            ),
          ],
        );
      },
    );
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Congratulations!"),
          content: Text("You guessed the word correctly! The word was '$word'."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                updateStreak(); // Update streak before restarting
                _restartGame();
              },
              child: const Text("Next"),
            ),
          ],
        );
      },
    );
  }
  bool hasWon=false;
  void updateStreak() {
    currentStreak++;
    if (currentStreak > maxStreak) {
      maxStreak = currentStreak;
    }
  }
  void resetStreak(){
    currentStreak=0;
  }


  @override
  Widget build(BuildContext context) {
    if (tries == 6) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        resetStreak();
        _showGameOverDialog();
      });
    }

    if (word.split("").every((letter) => selectedChar.contains(letter))) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateStreak();  // Update streak first
        _showWinDialog(); // Then show the dialog
      });
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("HANGMAN : THE GAME"),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person, size: 60, color: Colors.white),
                  const SizedBox(height: 10),
                  Text(
                    "Player: ${FirebaseAuth.instance.currentUser?.email}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Max Streak: $maxStreak",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.rule),
              title: const Text("Rules of Game"),
              onTap:() {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const RulesScreen()),
                );
              }
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Select Difficulty',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          DropdownButton<String>(
            value: selectedDifficulty,
            items: ['Easy', 'Medium', 'Hard'].map((String difficulty) {
              return DropdownMenuItem<String>(
                value: difficulty,
                child: Text(difficulty),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedDifficulty = newValue!;
                _initializeGame();
              });
            },
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(
                  flex: 4,
                  child: Stack(
                    children: [
                      figure(GameUI.hang, tries >= 0),
                      figure(GameUI.head, tries >= 1),
                      figure(GameUI.body, tries >= 2),
                      figure(GameUI.leftArm, tries >= 3),
                      figure(GameUI.rightArm, tries >= 4),
                      figure(GameUI.leftLeg, tries >= 5),
                      figure(GameUI.rightLeg, tries >= 6),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Hint: $hint',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: word
                          .split("")
                          .map(
                            (e) => letters(
                          e,
                          !selectedChar.contains(e.toUpperCase()),
                        ),
                      )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                crossAxisCount: 7,
                children: characters.split("").map((e) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                    onPressed: selectedChar.contains(e.toUpperCase())
                        ? null
                        : () {
                      setState(() {
                        selectedChar.add(e.toUpperCase());
                        if (!word.split("").contains(e.toUpperCase())) {
                          tries++;
                        }
                      });
                    },
                    child: Text(
                      e,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: const Text(
                "Developed with ❤ by DIVYANSHU PAL",
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
