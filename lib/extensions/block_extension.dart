import 'package:flame/components.dart';

extension BlockExtension on Block {
  Block get blockLeft => Block(x - 1, y);

  Block get blockRight => Block(x + 1, y);

  Block get blockAbove => Block(x, y + 1);

  Block get blockBelow => Block(x, y - 1);
}
