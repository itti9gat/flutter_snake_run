import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:snake_run/models/point.dart';
import 'package:snake_run/widget/body_snake.dart';

enum Direction { LEFT, RIGHT, UP, DOWN }
enum GameState { START, RUNNING, END }

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  var snakePosition;
  Point scorePosition;
  Timer timer;
  Point newPointPosition;
  Direction _direction = Direction.UP;
  GameState gameState = GameState.START;
  var score = 0;
  var speed = 0;
  var screenWidth = 0.0;
  var boxSize = 15.0;

  @override
  void initState() {
    super.initState();
  }

  void startingSnake() {
    setState(() {
      final midPoint = (screenWidth / boxSize / 2).round().toDouble();
      snakePosition = [
        Point(midPoint, midPoint),
        Point(midPoint, midPoint + 1),
        Point(midPoint, midPoint + 2),
        Point(midPoint, midPoint + 3),
      ];
    });
  }

  void genScorePoint() {
    final gridPoint = (screenWidth / boxSize).round() - 2;

    var rng = new Random();
    var pointX = (rng.nextInt(gridPoint) + 1).toDouble();
    var pointY = (rng.nextInt(gridPoint) + 1).toDouble();

    var _scorePosition = Point(pointX, pointY);

    if (snakePosition.contains(_scorePosition)) {
      genScorePoint();
    }

    setState(() {
      scorePosition = _scorePosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width - 50.0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("Score: $score", style: TextStyle(fontSize: 20.0)),
                Row(
                  children: [
                    Text("speed", style: TextStyle(fontSize: 15.0)),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        print(speed);
                        var _speed = speed - 50;
                        if (_speed < 50) {
                          _speed = 50;
                        }
                        setState(() {
                          speed = _speed;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        var _speed = speed + 50;
                        setState(() {
                          speed = _speed;
                        });
                      },
                    )
                  ],
                )
              ]),
              Container(
                width: screenWidth,
                height: screenWidth,
                color: Colors.green,
                child: _getByGameState(),
              ),
              SizedBox(
                height: 20.0,
              ),
              Container(
                width: screenWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () {
                        setState(() {
                          _direction = Direction.UP;
                        });
                      },
                      color: Colors.orangeAccent,
                      child: Icon(Icons.keyboard_arrow_up),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                          onPressed: () {
                            setState(() {
                              _direction = Direction.LEFT;
                            });
                          },
                          color: Colors.orangeAccent,
                          child: Icon(Icons.keyboard_arrow_left),
                        ),
                        SizedBox(
                          width: 50.0,
                        ),
                        RaisedButton(
                          onPressed: () {
                            setState(() {
                              _direction = Direction.RIGHT;
                            });
                          },
                          color: Colors.orangeAccent,
                          child: Icon(Icons.keyboard_arrow_right),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    RaisedButton(
                      onPressed: () {
                        setState(() {
                          _direction = Direction.DOWN;
                        });
                      },
                      color: Colors.orangeAccent,
                      child: Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getByGameState() {
    var child;
    switch (gameState) {
      case GameState.START:
        child = _showStaticPage("Tab to Start");
        break;

      case GameState.RUNNING:
        child = _showSnakeGame();
        break;

      case GameState.END:
        timer.cancel();
        child = _showStaticPage("Your Score: $score\n\nTap to play again!");
        break;
    }
    return child;
  }

  Widget _showStaticPage(String message) {
    return InkWell(
      onTap: () {
        startingSnake();
        genScorePoint();
        setState(() {
          score = 0;
          speed = 400;
          _direction = Direction.UP;
          gameState = GameState.RUNNING;
        });
        timer =
            new Timer.periodic(new Duration(milliseconds: speed), onTimeTick);
      },
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: Colors.white, fontSize: 30.0),
        ),
      ),
    );
  }

  Widget _showSnakeGame() {
    List<Positioned> snakePiecesWithNewPoints = List();
    snakePosition.forEach(
      (i) {
        snakePiecesWithNewPoints.add(
          Positioned(
            child: bodySnake,
            left: i.x * boxSize,
            top: i.y * boxSize,
          ),
        );
      },
    );

    snakePiecesWithNewPoints.add(
      Positioned(
        child: pointInGame,
        left: scorePosition.x * boxSize,
        top: scorePosition.y * boxSize,
      ),
    );

    return Stack(children: snakePiecesWithNewPoints);
  }

  void onTimeTick(Timer timer) {
    setState(() {
      snakePosition.insert(0, addHeadSnake());
      snakePosition.removeLast();
    });

    var checkscreenWidth = ((screenWidth / boxSize).round() - 1).toDouble();

    if (snakePosition.first.x < 0 ||
        snakePosition.first.y < 0 ||
        snakePosition.first.x > checkscreenWidth ||
        snakePosition.first.y > checkscreenWidth) {
      setState(() {
        gameState = GameState.END;
      });
    }

    if (snakePosition.first.x == scorePosition.x &&
        snakePosition.first.y == scorePosition.y) {
      setState(() {
        snakePosition.insert(0, addHeadSnake());
        score += 10;
      });
      genScorePoint();
      if (score % 300 == 0) {
        var _speed = speed - 50;
        setState(() {
          speed = _speed;
        });
      }
    }
  }

  Point addHeadSnake() {
    var newHeadPos;

    switch (_direction) {
      case Direction.LEFT:
        var currentHeadPos = snakePosition.first;
        newHeadPos = Point(currentHeadPos.x - 1, currentHeadPos.y);
        break;

      case Direction.RIGHT:
        var currentHeadPos = snakePosition.first;
        newHeadPos = Point(currentHeadPos.x + 1, currentHeadPos.y);
        break;

      case Direction.UP:
        var currentHeadPos = snakePosition.first;
        newHeadPos = Point(currentHeadPos.x, currentHeadPos.y - 1);
        break;

      case Direction.DOWN:
        var currentHeadPos = snakePosition.first;
        newHeadPos = Point(currentHeadPos.x, currentHeadPos.y + 1);
        break;
    }

    return newHeadPos;
  }
}
