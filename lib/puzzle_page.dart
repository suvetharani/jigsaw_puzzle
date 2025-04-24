import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

import 'puzzle_piece.dart';

const int gridSize = 3;
const double pieceSize = 120;

class PuzzlePage extends StatefulWidget {
  const PuzzlePage({super.key});

  @override
  State<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {
  ui.Image? puzzleImage;
  bool isLoading = false;
  late List<PuzzlePiece> pieces;
  bool isCompleted = false;
  String selectedImage = 'assets/images/dog.webp';

  final List<Map<String, String>> imageList = [
    {'name': 'Farmer Puzzle', 'path': 'assets/images/farmer_puzzle.jpeg'},
    {'name': 'Dog 1', 'path': 'assets/images/dog1.jpeg'},
    {'name': 'Dog', 'path': 'assets/images/dog.webp'},
    {'name': 'Cat', 'path': 'assets/images/cat.jpeg'},
    {'name': 'Cat 1', 'path': 'assets/images/cat1.jpg'},
    {'name': 'Cat 2', 'path': 'assets/images/cat2.jpeg'},
    {'name': 'Nature', 'path': 'assets/images/nature.jpg'},
    {'name': 'Nature 1', 'path': 'assets/images/nature1.jpeg'},
    {'name': 'Nature 2', 'path': 'assets/images/nature2.jpeg'},
    {'name': 'Nature 3', 'path': 'assets/images/nature3.webp'},
  ];

  @override
  void initState() {
    super.initState();
    loadImage(selectedImage);
  }

  Future<void> loadImage(String path) async {
    setState(() {
      isLoading = true;
      isCompleted = false;
    });

    try {
      final ByteData data = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(
        Uint8List.view(data.buffer),
        targetWidth: gridSize * 120,
        targetHeight: gridSize * 120,
      );
      final frame = await codec.getNextFrame();
      if (mounted) {
        setState(() {
          puzzleImage = frame.image;
          isLoading = false;
          _initializePieces(shuffle: true);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading image: $e')),
        );
      }
    }
  }

  void _initializePieces({bool shuffle = false}) {
    if (puzzleImage == null) return;

    final positions = List.generate(gridSize * gridSize, (index) => index);
    if (shuffle) {
      positions.shuffle();
    }

    pieces = List.generate(gridSize * gridSize, (index) {
      final originalPosition = positions[index];
      return PuzzlePiece(
        key: ValueKey('piece_${selectedImage}_$originalPosition'),
        image: puzzleImage!,
        row: originalPosition ~/ gridSize,
        col: originalPosition % gridSize,
        imageSize: pieceSize * gridSize,
      );
    });
  }

  void _resetPuzzle() {
    setState(() {
      _initializePieces(shuffle: true);
      isCompleted = false;
    });
  }

  void _swapPieces(int fromIndex, int toIndex) {
    if (fromIndex == toIndex) return;
    
    setState(() {
      final temp = pieces[fromIndex];
      pieces[fromIndex] = pieces[toIndex];
      pieces[toIndex] = temp;
      _checkCompletion();
    });
  }

  void _checkCompletion() {
    if (pieces.isEmpty) return;

    bool completed = true;
    for (int i = 0; i < pieces.length; i++) {
      final correctRow = i ~/ gridSize;
      final correctCol = i % gridSize;
      if (pieces[i].row != correctRow || pieces[i].col != correctCol) {
        completed = false;
        break;
      }
    }
    
    if (completed && !isCompleted) {
      setState(() {
        isCompleted = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Puzzle Completed! 🎉'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Jigsaw Puzzle',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.brown,
      ),
      backgroundColor: Colors.brown[100],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : puzzleImage == null
              ? const Center(child: Text('No image loaded'))
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.brown,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: DropdownButton<String>(
                                    value: selectedImage,
                                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                                    elevation: 16,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    underline: Container(
                                      height: 0,
                                    ),
                                    dropdownColor: Colors.brown,
                                    onChanged: (String? newValue) {
                                      if (newValue != null && newValue != selectedImage) {
                                        setState(() {
                                          selectedImage = newValue;
                                        });
                                        loadImage(newValue);
                                      }
                                    },
                                    items: imageList.map<DropdownMenuItem<String>>((Map<String, String> image) {
                                      return DropdownMenuItem<String>(
                                        value: image['path']!,
                                        child: Text(
                                          image['name']!,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                ElevatedButton.icon(
                                  onPressed: _resetPuzzle,
                                  icon: const Icon(Icons.restart_alt, size: 20, color: Colors.white),
                                  label: const Text(
                                    'Reset',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.brown,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    minimumSize: const Size(100, 40),
                                  ),
                                ),
                                if (isCompleted)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 20),
                                    child: Icon(Icons.check_circle, color: Colors.green, size: 40),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: pieceSize * gridSize,
                              height: pieceSize * gridSize,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.brown, width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: gridSize,
                                ),
                                itemCount: gridSize * gridSize,
                                itemBuilder: (context, index) {
                                  return DragTarget<int>(
                                    onWillAccept: (sourceIndex) => sourceIndex != null && sourceIndex != index,
                                    onAccept: (sourceIndex) => _swapPieces(sourceIndex, index),
                                    builder: (context, candidateData, rejectedData) {
                                      return Draggable<int>(
                                        data: index,
                                        feedback: Material(
                                          elevation: 8,
                                          child: SizedBox(
                                            width: pieceSize,
                                            height: pieceSize,
                                            child: pieces[index],
                                          ),
                                        ),
                                        childWhenDragging: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.3),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.5),
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.brown.withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: pieces[index],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
