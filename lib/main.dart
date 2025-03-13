import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(CardMatchingGame());
}

class CardModel {
  final String imageAssetPath;
  bool isFaceUp;
  bool isMatched;

  CardModel({
    required this.imageAssetPath,
    this.isFaceUp = false,
    this.isMatched = false,
  });
}

class CardMatchingGame extends StatefulWidget {
  @override
  _CardMatchingGameState createState() => _CardMatchingGameState();
}

class _CardMatchingGameState extends State<CardMatchingGame> {
  late List<CardModel> cards;
  int _firstSelectedIndex = -1;
  int _secondSelectedIndex = -1;
  bool _isChecking = false;
  int score = 0;
  Timer? _timer;
  int _elapsedTime = 0;
  late DateTime _firstCardTime;

  @override
  void initState() {
    super.initState();
    _initializeCards();
  }

  void _initializeCards() {
    cards = [
      CardModel(imageAssetPath: 'assets/captainamerica.jpeg'),
      CardModel(imageAssetPath: 'assets/captainamerica.jpeg'),
      CardModel(imageAssetPath: 'assets/beyblade.jpeg'),
      CardModel(imageAssetPath: 'assets/beyblade.jpeg'),
      CardModel(imageAssetPath: 'assets/naruto.jpeg'),
      CardModel(imageAssetPath: 'assets/naruto.jpeg'),
      CardModel(imageAssetPath: 'assets/thor.jpeg'),
      CardModel(imageAssetPath: 'assets/thor.jpeg'),
      CardModel(imageAssetPath: 'assets/inazuma.jpeg'),
      CardModel(imageAssetPath: 'assets/inazuma.jpeg'),
      CardModel(imageAssetPath: 'assets/spiderman.jpeg'),
      CardModel(imageAssetPath: 'assets/spiderman.jpeg'),
      CardModel(imageAssetPath: 'assets/haikyuu.jpeg'),
      CardModel(imageAssetPath: 'assets/haikyuu.jpeg'),
      CardModel(imageAssetPath: 'assets/demonslayer.jpeg'),
      CardModel(imageAssetPath: 'assets/demonslayer.jpeg'),
    ];
    cards.shuffle();
    score = 0;
    _firstSelectedIndex = -1;
    _secondSelectedIndex = -1;
    _isChecking = false;
    _elapsedTime = 0;

    // Start Timer
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _elapsedTime = 0;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _checkForMatch() async {
    if (_firstSelectedIndex != -1 && _secondSelectedIndex != -1) {
      setState(() {
        _isChecking = true;
      });

      bool isMatch = cards[_firstSelectedIndex].imageAssetPath ==
          cards[_secondSelectedIndex].imageAssetPath;

      if (isMatch) {
        setState(() {
          cards[_firstSelectedIndex].isMatched = true;
          cards[_secondSelectedIndex].isMatched = true;
          int timeTaken = DateTime.now().difference(_firstCardTime).inSeconds;

          score += 10;
          if (timeTaken <= 2) {
            score += 5; // Bonus points for quick match
          }
        });
      } else {
        await Future.delayed(Duration(seconds: 1));
        setState(() {
          cards[_firstSelectedIndex].isFaceUp = false;
          cards[_secondSelectedIndex].isFaceUp = false;
          score -= 5; // Deduct points for mismatch
        });
      }

      setState(() {
        _firstSelectedIndex = -1;
        _secondSelectedIndex = -1;
        _isChecking = false;
      });

      // Stop timer if all pairs are matched
      if (_checkForWin()) {
        _stopTimer();
      }
    }
  }

  void _onCardTapped(int index) {
    if (_isChecking || cards[index].isFaceUp || cards[index].isMatched) {
      return;
    }
    setState(() {
      cards[index].isFaceUp = true;
      if (_firstSelectedIndex == -1) {
        _firstSelectedIndex = index;
        _firstCardTime = DateTime.now(); // Record first card selection time
      } else {
        _secondSelectedIndex = index;
        _checkForMatch();
      }
    });
  }

  bool _checkForWin() {
    return cards.every((card) => card.isMatched);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text('Cards Flipping Game'),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.blueGrey[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Name: Joshika Alaparthi',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Panther ID: 002828256',
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[300]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 4,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  children: List.generate(cards.length, (index) {
                    return GestureDetector(
                      onTap: () => _onCardTapped(index),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: cards[index].isFaceUp || cards[index].isMatched
                              ? Colors.grey
                              : Colors.yellow,
                          borderRadius: BorderRadius.circular(8.0),
                          image: cards[index].isFaceUp || cards[index].isMatched
                              ? DecorationImage(
                                  image:
                                      AssetImage(cards[index].imageAssetPath),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: Center(
                          child: cards[index].isFaceUp || cards[index].isMatched
                              ? null
                              : Text(
                                  "Back",
                                  style: TextStyle(color: Colors.black),
                                ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Score: $score',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              SizedBox(height: 10),
              Text(
                'Time: $_elapsedTime sec',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _initializeCards();
                  });
                },
                child: Text('Restart Game'),
              ),
              if (_checkForWin())
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'You Win!',
                    style: TextStyle(fontSize: 32, color: Colors.green),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
