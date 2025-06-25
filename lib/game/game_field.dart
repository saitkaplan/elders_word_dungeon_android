import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

enum HammerType {
  none,
  singleTile,
  fullRow,
  fullColumn,
}

class GameField extends FlameGame with DragCallbacks, TapCallbacks {
  final int level;
  int earnedPoint;
  final VoidCallback onLevelComplete;

  GameField({
    required this.level,
    required this.earnedPoint,
    required this.onLevelComplete,
  });

  final List<GridTile> tiles = [];
  final List<GridTile> selectedTiles = [];
  List<Word> validWords = [];

  late List<List<String>> grid;
  late double tileSize;
  late double spacing;
  late String levelName;
  late TextComponent levelTitleComponent;
  late final ScoreManager scoreManager;

  int shiftCounter = 0;
  HammerType selectedHammerType = HammerType.none;

  // Flame yapılarının ilk kez çağrıldığı fonksiyon
  @override
  Future<void> onLoad() async {
    // Genel yüklemeler
    await initialize();
    // Level data yüklemesi
    await loadLevelData();
    // UI componentlerinin yüklenmesi
    setupUI();
    // Grid alanının çizimi
    renderGrid();
  }

  Future<void> initialize() async {
    camera.viewfinder.position = Vector2(size.x / 2, size.y / 2);
  }

  Future<void> loadLevelData() async {
    final String data =
        await rootBundle.loadString('assets/level_data/level_$level.json');
    final Map<String, dynamic> jsonData = json.decode(data);
    grid = List<List<String>>.from(
      jsonData['grid'].map((row) => List<String>.from(row)),
    );
    validWords = List<Word>.from(
      jsonData['words'].map((w) => Word.fromJson(w)),
    );
    levelName = jsonData['name'];
  }

  void setupUI() {
    double titleTopPadding = size.y * 0.025;
    double skorTopPadding = size.y * 0.0325;

    // Bölüm adı bileşeni
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

    // Skor gösterge bileşeni
    scoreManager = ScoreManager(
      initialPosition: Vector2(size.x - 16, skorTopPadding),
    );

    // Üst bölme tasarımı
    final double levelTitleBgHeight = size.y * 0.1;

    // Ekleme işlemi bloğu
    addAll([
      BackgroundComponent(),
      RectangleComponent(
        position: Vector2(0, 0),
        size: Vector2(size.x, levelTitleBgHeight),
        paint: Paint()..color = Colors.blueGrey.shade900,
        priority: -60,
      ),
      levelTitleComponent,
      scoreManager,
    ]);
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
      if (kDebugMode) {
        print("SEÇİM İŞLEMİ BAŞLADIĞI AN 1 KERE DÖNEN NOKTA!");
      }
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
      if (kDebugMode) {
        print("İLK SEÇİM SONRASI SEÇİLEN SEÇİM SAYISI KADAR ÇALIŞAN NOKTA!");
      }
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
      if (kDebugMode) {
        print("SEÇİM İŞLEMİ TAMAMLANDIĞINDA VE KELİME DOĞRUYSA ÇALIŞAN NOKTA!");
      }
      return true;
    });

    if (isMatch) {
      for (var tile in selectedTiles) {
        grid[tile.row][tile.col] = '';
        tile.removeFromParent();
        tiles.remove(tile);
        scoreManager.increase(20);
        if (kDebugMode) {
          print("DOĞRU SEÇİMDE KELİME HARF İÇERİĞİ KADAR DÖNEN NOKTA!!!");
        }
      }
      checkAndShiftGridDown();
      checkRemainingValidWords();
    } else {
      for (var tile in selectedTiles) {
        tile.deselect();
        if (kDebugMode) {
          print("YANLIŞ SEÇİMDE SEÇİLEN KUTU HARF İÇERİĞİ KADAR DÖNEN NOKTA!");
        }
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
          scoreManager.decrease(10);
          if (kDebugMode) {
            print("HÜCRESEL ÇEKİÇ KULLANIMI SIRASINDA ÇALIŞAN NOKTA!");
          }
          checkAndShiftGridDown();
          checkRemainingValidWords();
          break;

        case HammerType.fullRow:
          for (int col = 0; col < grid[0].length; col++) {
            grid[tile.row][col] = '';
            if (kDebugMode) {
              print(
                "SATIR ÇEKİCİ KULLANIMI SIRASINDA SÜTUN SAYISI KADAR DÖNEN 1. NOKTA!",
              );
            }
          }
          tiles.removeWhere((t) {
            if (t.row == tile.row) {
              t.removeFromParent();
              if (kDebugMode) {
                print(
                  "SATIR ÇEKİCİ KULLANIMI SIRASINDA SÜTUN SAYISI KADAR DÖNEN 2. NOKTA!",
                );
              }
              return true;
            }
            return false;
          });
          scoreManager.decrease(10);
          if (kDebugMode) {
            print("SATIR ÇEKİCİ KULLANIMI SIRASINDA 1 KERE ÇALIŞAN NOKTA!");
          }
          checkAndShiftGridDown();
          checkRemainingValidWords();
          break;

        case HammerType.fullColumn:
          for (int row = 0; row < grid.length; row++) {
            grid[row][tile.col] = '';
            if (kDebugMode) {
              print(
                "SÜTUN ÇEKİCİ KULLANIMI SIRASINDA SATIR SAYISI KADAR DÖNEN 1. NOKTA!",
              );
            }
          }
          tiles.removeWhere((t) {
            if (t.col == tile.col) {
              t.removeFromParent();
              if (kDebugMode) {
                print(
                  "SÜTUN ÇEKİCİ KULLANIMI SIRASINDA SATIR SAYISI KADAR DÖNEN 2. NOKTA!",
                );
              }
              return true;
            }
            return false;
          });
          scoreManager.decrease(10);
          if (kDebugMode) {
            print("SÜTUN ÇEKİCİ KULLANIMI SIRASINDA 1 KERE ÇALIŞAN NOKTA!");
          }
          checkAndShiftGridDown();
          checkRemainingValidWords();
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

    // En alttaki satır kontrolü
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

  void checkRemainingValidWords() {
    for (final word in validWords) {
      bool wordAvailable = true;
      for (final path in word.path) {
        final row = path[0] + shiftCounter;
        final col = path[1];
        if (row >= grid.length || grid[row][col] == '') {
          wordAvailable = false;
          break;
        }
      }
      if (wordAvailable) {
        return;
      }
    }
    onLevelComplete();
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

// Skor Gösterge İşlemleri ve Tasarımı
class ScoreManager extends Component with HasGameRef<GameField> {
  final Vector2? initialPosition;
  ScoreManager({this.initialPosition});

  int _score = 0;
  late TextComponent _scoreText;

  @override
  Future<void> onLoad() async {
    _score = gameRef.earnedPoint;

    _scoreText = TextComponent(
      text: 'Skor: $_score',
      anchor: Anchor.topRight,
      position: initialPosition,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: game.size.x * 0.05,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      priority: -55,
    );
    add(_scoreText);
  }

  void increase(int value) {
    _score += value;
    gameRef.earnedPoint = _score;
    _updateText();
  }

  void decrease(int value) {
    _score -= value;
    gameRef.earnedPoint = _score;
    _updateText();
  }

  void reset() {
    _score = 0;
    _updateText();
  }

  int get score => _score;

  void _updateText() {
    _scoreText.text = 'Skor: $_score';
  }
}
