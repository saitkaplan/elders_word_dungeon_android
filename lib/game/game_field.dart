import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

enum HammerType {
  none,
  singleTile,
  fullRow,
  fullColumn,
}

class GameField extends FlameGame with DragCallbacks, TapCallbacks {
  GameField({required this.level});

  final int level;
  final List<GridTile> tiles = [];
  final List<GridTile> selectedTiles = [];

  List<Word> validWords = [];

  late List<List<String>> grid;
  late double tileSize;
  late double spacing;
  late String levelName;
  late TextComponent levelTitleComponent;

  int shiftCounter = 0;
  HammerType selectedHammerType = HammerType.none;

  @override
  Future<void> onLoad() async {
    double titleTopPadding = size.y * 0.025;
    double titleBottomPadding = size.y * 0.025;
    camera.viewfinder.position = Vector2(size.x / 2, size.y / 2);
    await loadLevelData();
    add(BackgroundComponent());

    // Level adı tasarımı
    levelTitleComponent = TextComponent(
      text: levelName,
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, titleTopPadding),
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: size.x * 0.075,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      priority: -55,
    );
    final double bgHeight = levelTitleComponent.position.y +
        levelTitleComponent.height +
        titleBottomPadding;
    // Level adı arkaplan rengi
    add(RectangleComponent(
      position: Vector2(0, 0),
      size: Vector2(size.x, bgHeight),
      paint: Paint()..color = Colors.blueGrey.shade900,
      priority: -60,
    ));
    add(levelTitleComponent);

    renderGrid();
  }

  Future<void> loadLevelData() async {
    final String data =
        await rootBundle.loadString('assets/data/level_$level.json');
    final Map<String, dynamic> jsonData = json.decode(data);
    grid = List<List<String>>.from(
      jsonData['grid'].map((row) => List<String>.from(row)),
    );
    validWords = List<Word>.from(
      jsonData['words'].map((w) => Word.fromJson(w)),
    );
    levelName = jsonData['name'];
  }

  // Grid Sistemi Genel Tasarımı
  void renderGrid() {
    final double bottomGridPadding = size.y * 0.1;
    spacing = size.x * 0.015;

    final int rowCount = grid.length;
    final int colCount = grid[0].length;

    final double gridMaxWidth = size.x * 0.8;
    tileSize = (gridMaxWidth - (spacing * (colCount - 1))) / colCount;

    tiles.clear();

    final double gridWidth = colCount * tileSize + (colCount - 1) * spacing;
    final double gridHeight = rowCount * tileSize + (rowCount - 1) * spacing;

    final Vector2 startPosition = Vector2(
      (size.x - gridWidth) / 2,
      size.y - gridHeight - bottomGridPadding,
    );

    for (int row = 0; row < rowCount; row++) {
      for (int col = 0; col < colCount; col++) {
        final String letter = grid[row][col];

        final Vector2 tilePosition = Vector2(
          startPosition.x + col * (tileSize + spacing),
          startPosition.y + row * (tileSize + spacing),
        );

        final tile = GridTile(
          row: row,
          col: col,
          letter: letter,
          size: Vector2.all(tileSize),
          position: tilePosition,
        );

        tiles.add(tile);
        add(tile);
      }
    }

    // Grid Arkaplan
    add(RectangleComponent(
      position: startPosition - Vector2.all(4),
      size: Vector2(gridWidth, gridHeight) + Vector2.all(8),
      paint: Paint()..color = Colors.grey.shade900.withOpacity(0.5),
      priority: -90,
    ));

    // Grid Alt Satır Vurgusu
    final bottomLineY = startPosition.y + (rowCount - 1) * (tileSize + spacing);
    add(RectangleComponent(
      position: Vector2(startPosition.x, bottomLineY),
      size: Vector2(gridWidth, tileSize),
      paint: Paint()..color = Colors.red.withOpacity(0.2),
      priority: -80,
    ));
  }

  GridTile? tileAtPosition(Vector2 pos) {
    for (var tile in tiles) {
      if (tile.toRect().contains(pos.toOffset())) {
        return tile;
      }
    }
    return null;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    final pos = event.canvasPosition;
    final tile = tileAtPosition(pos);
    if (tile != null && tile.isBottomRow(grid.length)) {
      tile.select();
      selectedTiles.add(tile);
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (selectedTiles.isEmpty) return;
    final currentTile = selectedTiles.last;
    final nextTile = tileAtPosition(event.canvasStartPosition);
    if (nextTile != null &&
        !nextTile.isSelected &&
        currentTile.isNeighbor(nextTile)) {
      nextTile.select();
      selectedTiles.add(nextTile);
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    final selectedPath = selectedTiles
        .map((tile) => [tile.row - shiftCounter, tile.col])
        .toList();
    bool isMatch = validWords.any((word) {
      if (word.path.length != selectedPath.length) return false;
      for (int i = 0; i < word.path.length; i++) {
        if (word.path[i][0] != selectedPath[i][0] ||
            word.path[i][1] != selectedPath[i][1]) {
          return false;
        }
      }
      return true;
    });

    if (isMatch) {
      for (var tile in selectedTiles) {
        grid[tile.row][tile.col] = '';
        tile.removeFromParent();
        tiles.remove(tile);
      }
      checkAndShiftGridDown();
    } else {
      for (var tile in selectedTiles) {
        tile.deselect();
      }
    }
    selectedTiles.clear();
  }

  @override
  void onTapDown(TapDownEvent event) {
    final tile = tileAtPosition(event.canvasPosition);
    if (tile != null && selectedHammerType != HammerType.none) {
      switch (selectedHammerType) {
        case HammerType.singleTile:
          grid[tile.row][tile.col] = '';
          tile.removeFromParent();
          tiles.remove(tile);
          checkAndShiftGridDown();
          break;

        case HammerType.fullRow:
          for (int col = 0; col < grid[0].length; col++) {
            grid[tile.row][col] = '';
          }
          tiles.removeWhere((t) {
            if (t.row == tile.row) {
              t.removeFromParent();
              return true;
            }
            return false;
          });
          checkAndShiftGridDown();
          break;

        case HammerType.fullColumn:
          for (int row = 0; row < grid.length; row++) {
            grid[row][tile.col] = '';
          }
          tiles.removeWhere((t) {
            if (t.col == tile.col) {
              t.removeFromParent();
              return true;
            }
            return false;
          });
          checkAndShiftGridDown();
          break;

        case HammerType.none:
          // No-op
          break;
      }
    }
  }

  void checkAndShiftGridDown() {
    spacing = size.x * 0.015;
    final int rows = grid.length;
    final int columns = grid[0].length;
    bool shifted = false;

    // En alttaki satır boş mu kontrol et
    bool isBottomRowEmpty = true;
    for (int col = 0; col < columns; col++) {
      if (grid[rows - 1][col] != '') {
        isBottomRowEmpty = false;
        break;
      }
    }

    if (isBottomRowEmpty) {
      grid.removeAt(rows - 1);
      grid.insert(0, List.generate(columns, (_) => ''));
      for (var tile in tiles) {
        tile.position.y += tileSize + spacing;
        tile.row += 1;
      }
      shiftCounter += 1;
      shifted = true;
    }
    if (shifted) {
      checkAndShiftGridDown();
    }
  }
}

// Grid Sistemi İç Harf ve Tasarım Mekanikleri
class GridTile extends PositionComponent {
  final String letter;
  int row;
  final int col;
  bool isSelected = false;
  late TextComponent label;

  GridTile({
    required this.letter,
    required this.row,
    required this.col,
    required super.size,
    required super.position,
  });

  @override
  Future<void> onLoad() async {
    priority = -70;
    label = TextComponent(
      text: letter,
      anchor: Anchor.center,
      position: size / 2,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: size.x * 0.5,
          color: Colors.white,
        ),
      ),
    );
    add(label);
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.greenAccent,
    ));
  }

  void deselect() {
    isSelected = false;
    label.textRenderer = TextPaint(
      style: TextStyle(
        fontSize: size.x * 0.5,
        color: Colors.white60,
      ),
    );
  }

  void select() {
    isSelected = true;
    label.textRenderer = TextPaint(
      style: TextStyle(
        fontSize: size.x * 0.6,
        color: Colors.red.shade400,
      ),
    );
  }

  bool isBottomRow(int totalRows) => row == totalRows - 1;

  bool isNeighbor(GridTile other) {
    final dx = (other.col - col).abs();
    final dy = (other.row - row).abs();
    return (dx == 1 && dy == 0) || (dx == 0 && dy == 1);
  }
}

// .json Dosyaları Metrik Değer Yönetimi
class Word {
  final String id;
  final List<List<int>> path;

  Word({required this.id, required this.path});

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'],
      path: List<List<int>>.from(
        json['path'].map((p) => List<int>.from(p)),
      ),
    );
  }
}

// Oyun Alanı Arkaplan Tasarımı
class BackgroundComponent extends Component with HasGameRef<GameField> {
  @override
  int priority = -100;

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, game.size.x, game.size.y),
      Paint()..color = const Color(0xFF222831),
    );
  }
}
