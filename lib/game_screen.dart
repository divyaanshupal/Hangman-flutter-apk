import 'package:flutter/material.dart';
import 'data/streakData.dart';
import 'data/streak_fetch.dart';
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
  var characters = "QWERTYUIOPASDFGHJKLZXCVBNM";
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
    print("LOG : func called");
    currentStreak++;
    if (currentStreak > maxStreak) {
      maxStreak = currentStreak;
    }
  }
  void resetStreak(){
    currentStreak=0;
  }

  void _onLetterSelected(String letter) {
    if (selectedChar.contains(letter) || tries >= 6) return; // Prevent duplicate selection

    setState(() {
      selectedChar.add(letter);
      if (!word.contains(letter)) {
        tries++;
      }
    });

    // 🔹 Ensure Dialog appears after UI update
    Future.delayed(Duration.zero, () {
      if (tries == 6) {
        resetStreak();
        savingStreak(currentStreak, maxStreak, FirebaseAuth.instance.currentUser!.uid);
        _showGameOverDialog();
      } else if (word.split("").every((letter) => selectedChar.contains(letter))) {
        updateStreak();
        savingStreak(currentStreak, maxStreak, FirebaseAuth.instance.currentUser!.uid);
        _showWinDialog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("HANGMAN : THE GAME"),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        actions: [
            // Fire logo with current streak
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                // Navigate to the rules screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RulesScreen()),
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange), // Fire logo
                  const SizedBox(width: 4), // Space between icon and text
                  Text(
                    "$currentStreak", // Current streak value
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                //color: Colors.blueAccent, // Fallback background color
              ),
              child: Center(
                child: Container(
                  width: 100, // Set width to make it circular
                  height: 100, // Set height equal to width
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle, // Makes it a circle
                    image: DecorationImage(
                      image: AssetImage('assests/profile.jpg'), // Corrected "assets" spelling
                      fit: BoxFit.cover, // Ensures the image covers the circular area
                    ),
                  ),
                ),
              ),
            ),

            ListTile(
              contentPadding: EdgeInsets.all(16), // Add padding around the content
              //leading: const Icon(Icons.person, size: 60, color: Colors.white), // Leading icon
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
                children: [
                  Text(
                    "Player: ${FirebaseAuth.instance.currentUser?.email}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),

                  /// 🔹 Using FutureBuilder to Fetch Max Streak
                  FutureBuilder<int>(
                    future: StreakService.fetchMaxStreak(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text("Loading...",
                            style: TextStyle(color: Colors.white70, fontSize: 16));
                      } else if (snapshot.hasError) {
                        return const Text("Error",
                            style: TextStyle(color: Colors.red, fontSize: 16));
                      } else {
                        return Text("Highest Score: ${snapshot.data ?? 0} 🔥",
                            style: const TextStyle(color: Colors.white70, fontSize: 16,fontWeight: FontWeight.bold));
                      }
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.rule),
              title: const Text("Rules of Game"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RulesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: _logout,
            ),
            Expanded(child: SizedBox(height: 20)),
            const Padding(padding: EdgeInsets.only(bottom: 18.0),
              child: Text('Made by Divyanshu Pal',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),),

            )
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
          SizedBox(height: 20,),
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Increase the button size by dividing by a smaller number (e.g., 5 instead of 7)
                double buttonSize = constraints.maxWidth / 5 - 8; // Adjust size based on screen width

                return Container(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                      childAspectRatio: 1, // Ensures square buttons
                    ),
                    itemCount: characters.length,
                    itemBuilder: (context, index) {
                      String e = characters[index];

                      return SizedBox(
                        width: buttonSize,
                        height: buttonSize,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            //backgroundColor: Colors.black54,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8), // Slightly rounded buttons
                            ),
                            padding: EdgeInsets.zero,
                            alignment: Alignment.center,
                          ),
                          onPressed: selectedChar.contains(e.toUpperCase())
                              ? null
                              : () => _onLetterSelected(e.toUpperCase()),

                          child: Text(
                            e,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 27, // Increase the font size here
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // Expanded(
          //   child: Container(
          //     alignment: Alignment.center,
          //     child: const Text(
          //       "Developed with ❤ by DIVYANSHU PAL",
          //       style: TextStyle(
          //         color: Colors.white70,
          //         fontWeight: FontWeight.bold,
          //         fontSize: 14,
          //         letterSpacing: 1,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
//git update