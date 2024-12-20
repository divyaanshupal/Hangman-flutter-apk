import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hangman_game/consts/consts.dart';
import 'package:hangman_game/game/figure_widget.dart';
import 'package:hangman_game/game/letters.dart';
import 'package:hangman_game/rules_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  var characters = "abcdefghijklmnopqrstuvwxyz".toUpperCase();
  late String word;
  late String hint;
  List<String> selectedChar = [];
  var tries = 0;
  String selectedDifficulty = 'Easy'; // Default difficulty

  final Map<String, List<Map<String, String>>> wordHints = {
  'Easy': [
    {'word': 'DOG', 'hint': 'A loyal pet.'},
    {'word': 'SUN', 'hint': 'Shines during the day.'},
    {'word': 'CAR', 'hint': 'A vehicle with four wheels.'},
    {'word': 'CAT', 'hint': 'A furry pet that loves milk.'},
    {'word': 'HAT', 'hint': 'You wear it on your head.'},
    {'word': 'BED', 'hint': 'You sleep on it.'},
    {'word': 'BAT', 'hint': 'Used to hit the ball in cricket.'},
    {'word': 'FAN', 'hint': 'Keeps you cool in summer.'},
    {'word': 'BUS', 'hint': 'Public transport on wheels.'},
    {'word': 'BOX', 'hint': 'You can store things in it.'},
    {'word': 'PEN', 'hint': 'Used for writing.'},
    {'word': 'MAP', 'hint': 'Used for navigation.'},
    {'word': 'RUN', 'hint': 'Move quickly on foot.'},
    {'word': 'FOX', 'hint': 'A clever animal.'},
    {'word': 'ZOO', 'hint': 'A place with many animals.'},
    {'word': 'RAIN', 'hint': 'Falls from the sky during storms.'},
    {'word': 'BOOK', 'hint': 'You can read it.'},
    {'word': 'FISH', 'hint': 'Swims in the water.'},
    {'word': 'TREE', 'hint': 'A tall plant with leaves.'},
    {'word': 'ROAD', 'hint': 'Cars drive on it.'},
    {'word': 'MILK', 'hint': 'A white drink from cows.'},
    {'word': 'SHIP', 'hint': 'Sails on the sea.'},
    {'word': 'BELL', 'hint': 'Rings to make sound.'},
    {'word': 'FLAG', 'hint': 'Represents a country.'},
    {'word': 'CAKE', 'hint': 'A sweet dessert for birthdays.'},
    {'word': 'BALL', 'hint': 'You play with it.'},
    {'word': 'CUP', 'hint': 'You drink tea or coffee in it.'},
    {'word': 'CHAIR', 'hint': 'You sit on it.'},
    {'word': 'DOOR', 'hint': 'You open it to enter a room.'},
    {'word': 'CLOCK', 'hint': 'Tells you the time.'},
    {'word': 'HAND', 'hint': 'Part of your body with fingers.'},
    {'word': 'MOON', 'hint': 'Shines at night in the sky.'},
    {'word': 'RING', 'hint': 'A small circular ornament for your finger.'},
    {'word': 'LAMP', 'hint': 'Lights up a room.'},
    {'word': 'FROG', 'hint': 'A small green amphibian.'},

  ],
  'Medium': [
    {'word': 'BANANA', 'hint': 'A yellow fruit.'},
    {'word': 'PYTHON', 'hint': 'A programming language or a snake.'},
    {'word': 'CANDLE', 'hint': 'Used during a power outage.'},
    {'word': 'BASKET', 'hint': 'Used to carry things.'},
    {'word': 'PLANET', 'hint': 'Earth is one of these.'},
    {'word': 'GUITAR', 'hint': 'A musical instrument with strings.'},
    {'word': 'MARKET', 'hint': 'A place for shopping.'},
    {'word': 'WINDOW', 'hint': 'Allows light into a room.'},
    {'word': 'TIGER', 'hint': 'A big cat with stripes.'},
    {'word': 'KITTEN', 'hint': 'A baby cat.'},
    {'word': 'FARMER', 'hint': 'Works in agriculture.'},
    {'word': 'DOCTOR', 'hint': 'Takes care of your health.'},
    {'word': 'GARDEN', 'hint': 'A place with plants and flowers.'},
    {'word': 'BRIDGE', 'hint': 'Connects two places over water.'},
    {'word': 'BOTTLE', 'hint': 'Holds liquids like water.'},
    {'word': 'LADDER', 'hint': 'Used to climb up.'},
    {'word': 'MARKER', 'hint': 'Used for highlighting text.'},
    {'word': 'WALLET', 'hint': 'Holds money and cards.'},
    {'word': 'CIRCLE', 'hint': 'A round shape.'},
    {'word': 'FINGER', 'hint': 'Part of your hand.'},
    {'word': 'BRANCH', 'hint': 'Part of a tree.'},
    {'word': 'ENGINE', 'hint': 'Powers vehicles.'},
    {'word': 'ROCKET', 'hint': 'Used for space travel.'},
    {'word': 'DESERT', 'hint': 'A dry, sandy place.'},
    {'word': 'RIVER', 'hint': 'A flowing water body.'},
    {'word': 'LITTLE', 'hint': 'The opposite of big.'},
    {'word': 'PUZZLE', 'hint': 'You solve it for fun or learning.'},
    {'word': 'PENCIL', 'hint': 'Used to write and erase easily.'},
    {'word': 'LIVING', 'hint': 'The act of being alive.'},
    {'word': 'TRAVEL', 'hint': 'Going to different places.'},
    {'word': 'FRIEND', 'hint': 'Someone you trust and care about.'},
    {'word': 'PRINTER', 'hint': 'Produces paper copies of digital files.'},
    {'word': 'GUITARS', 'hint': 'Plural for stringed musical instruments.'},
    {'word': 'PLANING', 'hint': 'Smoothing or preparing a surface.'},
    {'word': 'BRICKS', 'hint': 'Used for building houses.'},

  ],
  'Hard': [
    {'word': 'HANGMAN', 'hint': 'The name of this game!'},
    {'word': 'MONKEY', 'hint': 'A playful animal.'},
    {'word': 'ELEVEN', 'hint': 'A number after ten.'},
    {'word': 'FOSSIL', 'hint': 'Preserved remains of ancient life.'},
    {'word': 'POCKET', 'hint': 'A small pouch in clothing.'},
    {'word': 'JUNGLE', 'hint': 'A dense forest.'},
    {'word': 'CANYON', 'hint': 'A deep valley with steep sides.'},
    {'word': 'LANTERN', 'hint': 'Used to light up dark areas.'},
    {'word': 'PRISON', 'hint': 'A place to hold criminals.'},
    {'word': 'SUMMER', 'hint': 'The warmest season.'},
    {'word': 'PYRAMID', 'hint': 'An ancient Egyptian structure.'},
    {'word': 'TUNNEL', 'hint': 'Passage underground or through hills.'},
    {'word': 'SILVER', 'hint': 'A shiny metal.'},
    {'word': 'PLANETS', 'hint': 'Orbit around stars.'},
    {'word': 'MARKERS', 'hint': 'Used for marking items.'},
    {'word': 'CANYONS', 'hint': 'Natural steep valleys.'},
    {'word': 'GALAXY', 'hint': 'A collection of stars and planets.'},
    {'word': 'CIRCUS', 'hint': 'A place with clowns and acrobats.'},
    {'word': 'FREEZER', 'hint': 'Keeps food cold.'},
    {'word': 'CASTLE', 'hint': 'A home for kings and queens.'},
    {'word': 'MIRROR', 'hint': 'Reflects your image.'},
    {'word': 'PLANING', 'hint': 'Smoothing a surface.'},
    {'word': 'CIRCUIT', 'hint': 'Electrical connection path.'},
    {'word': 'HAMMER', 'hint': 'A tool used to drive nails.'},
    {'word': 'FURNACE', 'hint': 'Heats up a building.'},
    {'word': 'LANTERN', 'hint': 'A portable source of light.'},
    {'word': 'TROPICS', 'hint': 'Hot, humid climate regions.'},
    {'word': 'ANCHOR', 'hint': 'Used to hold ships in place.'},
    {'word': 'CANYONS', 'hint': 'Deep natural valleys carved by rivers.'},
    {'word': 'ISLANDS', 'hint': 'Surrounded by water on all sides.'},
    {'word': 'HORIZON', 'hint': 'Where the earth meets the sky.'},
    {'word': 'TUNNELS', 'hint': 'Passages dug underground.'},
    {'word': 'POWDERY', 'hint': 'Something with a fine texture.'},
    {'word': 'CRYSTAL', 'hint': 'A clear, sparkling mineral.'},
    {'word': 'VOLCANO', 'hint': 'A mountain that erupts lava.'},

  ],
};


  final Map<String, Set<String>> usedWords = {
    'Easy': {},
    'Medium': {},
    'Hard': {},
  };

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
      // Reset used words and notify the user
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

  @override
  Widget build(BuildContext context) {
    if (tries == 6) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showGameOverDialog());
    }

    if (word.split("").every((letter) => selectedChar.contains(letter))) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showWinDialog());
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("HANGMAN : THE GAME"),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              // Navigate to the Rules Screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RulesScreen()),
              );
            },
          ),
        ],
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
