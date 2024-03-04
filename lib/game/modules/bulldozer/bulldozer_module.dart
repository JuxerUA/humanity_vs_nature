import 'package:flame/components.dart';
import 'package:humanity_vs_nature/game/modules/bulldozer/bulldozer_component.dart';
import 'package:humanity_vs_nature/game/modules/city/city_component.dart';
import 'package:humanity_vs_nature/game/simulation_game.dart';

class BulldozerModule extends Component with HasGameRef<SimulationGame> {
  final List<BulldozerComponent> bulldozers = [];

  BulldozerComponent addBulldozer(CityComponent owner) {
    final bulldozer = BulldozerComponent(base: owner)
      ..position = owner.position;
    bulldozers.add(bulldozer);
    add(bulldozer);
    return bulldozer;
  }

  void removeBulldozer(BulldozerComponent bulldozer) {
    remove(bulldozer);
    bulldozer.base.bulldozers.remove(bulldozer);
    bulldozers.remove(bulldozer);
  }
}
