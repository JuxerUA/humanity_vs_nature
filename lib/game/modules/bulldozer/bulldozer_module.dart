import 'package:flame/components.dart';
import 'package:humanity_vs_nature/game/modules/bulldozer/bulldozer_component.dart';
import 'package:humanity_vs_nature/game/modules/city/city_component.dart';
import 'package:humanity_vs_nature/game/modules/tree/tree_component.dart';
import 'package:humanity_vs_nature/game/simulation_game.dart';

class BulldozerModule extends Component with HasGameRef<SimulationGame> {
  final List<BulldozerComponent> bulldozers = [];

  BulldozerComponent addBulldozer(CityComponent owner,
      {TreeComponent? target}) {
    final bulldozer = BulldozerComponent(city: owner)
      ..position = owner.position
      ..targetTree = target;
    bulldozers.add(bulldozer);
    add(bulldozer);
    return bulldozer;
  }

  void removeBulldozer(BulldozerComponent bulldozer) {
    remove(bulldozer);
    bulldozer.city.bulldozers.remove(bulldozer);
    bulldozers.remove(bulldozer);
  }
}
