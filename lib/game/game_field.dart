import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class GameField extends FlameGame with DragCallbacks, TapCallbacks {
  GameField({required this.level});

  final int level;
  late List<List<String>> grid;
  final double tileSize = 65.0;
  final double spacing = 6.5;
  final List<GridTile> tiles = [];
  final List<GridTile> selectedTiles = [];
  List<Word> validWords = [];
  late String levelName;
  late TextComponent levelTitleComponent;

  final double bottomGridPadding = 80.0;
  final double topTitlePadding = 40.0;
  final double spacingAfterTitle = 30.0;
  final double titleBackgroundHorizontalPadding = 20.0;
  final double titleBackgroundVerticalPadding = 10.0;

  int shiftCounter = 0;
  bool isHammerMode = false;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.position = Vector2(size.x / 2, size.y / 2);
    await loadLevelData();

    // Priority Sıralaması:
    // 1. BackgroundComponent: -100 (En arkada)
    // 2. Grid Arkaplanı (blueGrey): -90 (BackgroundComponent'ın önünde)
    // 3. Alt Satır Vurgusu (red): -80 (Grid Arkaplanının önünde)
    // 4. GridTile'lar (ve içindeki yeşil çerçeveler): -70 (Alt Satır Vurgusunun önünde)
    // 5. Level Arkaplanı (black): -60 (GridTile'ların önünde)
    // 6. Level Adı (levelTitleComponent): -55 (Level Arkaplanının önünde)
    // 7. HammerComponent: 100 (En önde)

    add(BackgroundComponent());

    levelTitleComponent = TextComponent(
      text: levelName,
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, topTitlePadding),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      priority: -55,
    );

    final double bgHeight = levelTitleComponent.position.y +
        levelTitleComponent.height +
        titleBackgroundVerticalPadding;

    add(RectangleComponent(
      position: Vector2(0, 0),
      size: Vector2(size.x, bgHeight),
      paint: Paint()..color = Colors.black,
      priority: -60,
    ));

    add(levelTitleComponent);

    renderGrid();
    await add(HammerComponent());
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

  void renderGrid() {
    final int rows = grid.length;
    final int columns = grid[0].length;
    final double totalGridWidth = columns * tileSize + (columns - 1) * spacing;
    final double totalGridHeight = rows * tileSize + (rows - 1) * spacing;
    final double startX = (size.x - totalGridWidth) / 2;
    final double startY = size.y - totalGridHeight - bottomGridPadding;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final String letter = grid[row][col];
        final double x = startX + col * (tileSize + spacing);
        final double y = startY + row * (tileSize + spacing);
        final tile = GridTile(
          letter: letter,
          row: row,
          col: col,
          size: Vector2(tileSize, tileSize),
          position: Vector2(x, y),
        );
        tiles.add(tile);
        add(tile);
      }
    }

    // Grid Arkaplan rengi
    add(RectangleComponent(
      position: Vector2(startX - 6, startY - 6),
      size: Vector2(
        columns * tileSize + (columns - 1) * spacing + 12,
        rows * tileSize + (rows - 1) * spacing + 12,
      ),
      paint: Paint()..color = Colors.blueGrey.withOpacity(0.4),
      priority: -90,
    ));

    // Alt satır rengi
    add(RectangleComponent(
      position: Vector2(
        startX - 4,
        startY + (rows - 1) * (tileSize + spacing) - 4,
      ),
      size: Vector2(
        columns * tileSize + (columns - 1) * spacing + 8,
        tileSize + 8,
      ),
      paint: Paint()..color = Colors.red.withOpacity(0.4),
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
    if (tile != null) {
      if (isHammerMode) {
        grid[tile.row][tile.col] = '';
        tile.removeFromParent();
        tiles.remove(tile);
        checkAndShiftGridDown();
      }
    }
  }

  void checkAndShiftGridDown() {
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
        style: const TextStyle(
          fontSize: 30,
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
      style: const TextStyle(
        fontSize: 30,
        color: Colors.white,
      ),
    );
  }

  void select() {
    isSelected = true;
    label.textRenderer = TextPaint(
      style: const TextStyle(
        fontSize: 30,
        color: Colors.red,
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

// Arkaplan rengi
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

class HammerComponent extends TextComponent
    with DragCallbacks, HasGameRef<GameField> {
  HammerComponent()
      : super(
          text: '🔨',
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 32,
              color: Colors.white,
            ),
          ),
        );

  late Vector2 initialPosition;

  @override
  Future<void> onLoad() async {
    const double hammerDistanceFromBottom = 90.0;
    final double hammerX = gameRef.size.x / 1.125;
    final double hammerY = gameRef.size.y - hammerDistanceFromBottom - size.y;
    initialPosition = Vector2(hammerX, hammerY);
    position = initialPosition.clone();
    priority = 100;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    position += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    final tile = gameRef.tileAtPosition(position);
    if (tile != null) {
      gameRef.grid[tile.row][tile.col] = '';
      tile.removeFromParent();
      gameRef.tiles.remove(tile);
      gameRef.checkAndShiftGridDown();
    }
    position = initialPosition.clone();
  }
}
