import 'package:flame/components.dart';
import 'package:humanity_vs_nature/pages/game/modules/bulldozer/bulldozer_component.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';

class BulldozerModule extends Component with HasGameRef<SimulationGame> {
  final List<BulldozerComponent> _bulldozers = [];

  List<BulldozerComponent> get bulldozers => _bulldozers;

  void addBulldozer(PositionComponent owner) {
    final bulldozer = BulldozerComponent(base: owner)
      ..position = owner.position;
    _bulldozers.add(bulldozer);
    add(bulldozer);
  }

  void removeBulldozer(BulldozerComponent bulldozer) {
    remove(bulldozer);
    _bulldozers.remove(bulldozer);
  }
}
