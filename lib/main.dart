import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '미로찾기 프로젝트',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MazeGame(),
    );
  }
}

class MazeGame extends StatefulWidget {
  const MazeGame({super.key});

  @override
  State<MazeGame> createState() => _MazeGameState();
}

class _MazeGameState extends State<MazeGame> {
  final int _rows = 11;
  final int _cols = 11;
  late List<List<int>> _maze;
  late int _playerRow;
  late int _playerCol;
  final int _goalRow = 9;
  final int _goalCol = 9;
  final FocusNode _focusNode = FocusNode();
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeMaze();
    _playerRow = 0;
    _playerCol = 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _focusNode.requestFocus();
  }

  void _initializeMaze() {
    // 전체를 벽으로 채움
    _maze = List.generate(_rows, (i) => List.generate(_cols, (j) => 1));

    // 미로를 생성하여 경로를 만듦
    _generateMaze(0, 0);

    // 목적지 표시
    _maze[_goalRow][_goalCol] = 2;
  }

  void _generateMaze(int startRow, int startCol) {
    // 시작점에서 경로를 만듦
    _maze[startRow][startCol] = 0;

    // 이동 방향을 무작위로 섞음
    List<List<int>> directions = [
      [0, 2],
      [2, 0],
      [0, -2],
      [-2, 0]
    ];
    directions.shuffle(_random);

    for (var direction in directions) {
      int newRow = startRow + direction[0];
      int newCol = startCol + direction[1];

      if (newRow >= 0 && newRow < _rows && newCol >= 0 && newCol < _cols && _maze[newRow][newCol] == 1) {
        _maze[startRow + direction[0] ~/ 2][startCol + direction[1] ~/ 2] = 0;
        _maze[newRow][newCol] = 0;
        _generateMaze(newRow, newCol);
      }
    }
  }

  void _resetGame() {
    setState(() {
      _initializeMaze();
      _playerRow = 0;
      _playerCol = 0;
    });
  }

  void _movePlayer(int dRow, int dCol) {
    setState(() {
      int newRow = _playerRow + dRow;
      int newCol = _playerCol + dCol;
      if (newRow >= 0 && newRow < _rows && newCol >= 0 && newCol < _cols && _maze[newRow][newCol] != 1) {
        _playerRow = newRow;
        _playerCol = newCol;
        if (_playerRow == _goalRow && _playerCol == _goalCol) {
          _showClearDialog();
        }
      }
    });
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('클리어!'),
          content: const Text('목적지에 도착했습니다!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('미로찾기 프로젝트'),
      ),
      body: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: (event) {
          if (event is RawKeyDownEvent) {
            switch (event.logicalKey.keyLabel) {
              case 'Arrow Up':
                _movePlayer(-1, 0);
                break;
              case 'Arrow Down':
                _movePlayer(1, 0);
                break;
              case 'Arrow Left':
                _movePlayer(0, -1);
                break;
              case 'Arrow Right':
                _movePlayer(0, 1);
                break;
            }
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_rows, (row) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_cols, (col) {
                  if (row == _playerRow && col == _playerCol) {
                    return _buildCell(Colors.blue);
                  } else if (_maze[row][col] == 2) {
                    return _buildCell(Colors.red);
                  } else if (_maze[row][col] == 1) {
                    return _buildCell(Colors.black);
                  } else {
                    return _buildCell(Colors.grey);
                  }
                }),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildCell(Color color) {
    return Container(
      width: 30,
      height: 30,
      margin: const EdgeInsets.all(1),
      color: color,
    );
  }
}
