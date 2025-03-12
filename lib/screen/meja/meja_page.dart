import 'package:flutter/material.dart';
import 'dart:math';

class MejaPage extends StatefulWidget {
  @override
  _MejaPageState createState() => _MejaPageState();
}

class _MejaPageState extends State<MejaPage> {
  // Store the positions of each table (Meja)
  Map<int, Offset> _mejaPositions = {};
  // Define the size of the resizable area
  double _areaWidth = 300;
  double _areaHeight = 300;

  // Grid snapping size
  final double _gridSize = 20;

  @override
  void initState() {
    super.initState();
    // Initialize positions of Meja
    _initializeMejaPositions();
  }

  void _initializeMejaPositions() {
    for (int i = 0; i < 5; i++) {
      _mejaPositions[i] = Offset(20.0 + (i * 60), 20.0);
    }
  }

  // Helper to snap to grid
  Offset _snapToGrid(Offset offset) {
    return Offset(
      (offset.dx / _gridSize).round() * _gridSize,
      (offset.dy / _gridSize).round() * _gridSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Meja Layout Manager"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetLayout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Resizable area container
            GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _areaWidth = max(200, _areaWidth + details.delta.dx);
                  _areaHeight = max(200, _areaHeight + details.delta.dy);
                });
              },
              child: Container(
                width: _areaWidth,
                height: _areaHeight,
                color: Colors.grey[300],
                child: Stack(
                  children: [
                    // Draw grid
                    CustomPaint(
                      size: Size(_areaWidth, _areaHeight),
                      painter: GridPainter(gridSize: _gridSize),
                    ),
                    // Draggable tables (Meja)
                    ..._mejaPositions.entries.map((entry) {
                      int id = entry.key;
                      Offset position = entry.value;

                      // Ensure tables stay within bounds
                      if (position.dx > _areaWidth - 50) {
                        position = Offset(_areaWidth - 50, position.dy);
                      }
                      if (position.dy > _areaHeight - 50) {
                        position = Offset(position.dx, _areaHeight - 50);
                      }

                      return Positioned(
                        left: position.dx,
                        top: position.dy,
                        child: Draggable<int>(
                          data: id,
                          feedback: _buildMeja(id, isDragging: true),
                          childWhenDragging: Opacity(
                            opacity: 0.5,
                            child: _buildMeja(id),
                          ),
                          onDragEnd: (details) {
                            setState(() {
                              Offset newOffset = details.offset;
                              Offset localOffset = newOffset -
                                  Offset(
                                    (MediaQuery.of(context).size.width -
                                            _areaWidth) /
                                        2,
                                    (MediaQuery.of(context).size.height -
                                            _areaHeight -
                                            100) /
                                        2,
                                  );

                              _mejaPositions[id] = _snapToGrid(localOffset);
                            });
                          },
                          child: _buildMeja(id),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveLayout,
              child: Text("Save Layout"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeja(int id, {bool isDragging = false}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isDragging ? Colors.blue : Colors.orange,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Center(
        child: Text(
          "Meja $id",
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }

  void _resetLayout() {
    setState(() {
      _initializeMejaPositions();
    });
  }

  void _saveLayout() {
    print("Saved Layout: $_mejaPositions");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Layout saved successfully!")),
    );
  }
}

// Custom painter for grid
class GridPainter extends CustomPainter {
  final double gridSize;

  GridPainter({required this.gridSize});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
