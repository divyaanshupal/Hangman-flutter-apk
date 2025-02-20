import 'package:flutter/material.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Game Rules"),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      backgroundColor: const Color(0xFF1E1E2C), // Same background as game screen
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Rules of Hangman:",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "1. Guess the word letter by letter.\n"
                "2. You get a total of 6 incorrect guesses.\n"
                "3. For every incorrect guess, a part of the hangman is drawn.\n"
                "4. Use the hints provided to help you guess.\n"
                "5. The game is over when you either guess the word or all parts of the hangman are drawn.\n"
                "6. Every correct answer , the streak (at the right corner of game screen) will increase by one\n"
                "7. Highest Score is the Maximum streak you have stored till the game history"
                ,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Enjoy and good luck!",
                style: TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  color: Colors.greenAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
