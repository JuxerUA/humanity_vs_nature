import 'package:test/test.dart';
import 'package:flame/components.dart';
import 'package:humanity_vs_nature/game/modules/bulldozer/bulldozer_module.dart';
import 'package:humanity_vs_nature/game/modules/city/city_component.dart';
import 'package:humanity_vs_nature/game/modules/tree/tree_component.dart';

void main() {
  group('BulldozerModule', () {
    test('addBulldozer adds bulldozer and sets properties', () {
      final module = BulldozerModule();
      final city = CityComponent()..position = Vector2(10, 20);
      final tree = TreeComponent(isMature: true)..position = Vector2(30, 40);

      final bulldozer = module.addBulldozer(city, target: tree);

      expect(module.bulldozers.length, 1);
      expect(module.bulldozers.first, bulldozer);
      expect(module.children.contains(bulldozer), isTrue);
      expect(bulldozer.position, city.position);
      expect(bulldozer.targetTree, tree);
    });

    test('removeBulldozer removes bulldozer from lists', () {
      final module = BulldozerModule();
      final city = CityComponent();
      final bulldozer = module.addBulldozer(city);
      city.bulldozers.add(bulldozer);

      module.removeBulldozer(bulldozer);

      expect(module.bulldozers.isEmpty, isTrue);
      expect(city.bulldozers.isEmpty, isTrue);
    });
  });
}
