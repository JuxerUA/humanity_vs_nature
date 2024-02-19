import 'package:flame/components.dart';
import 'package:humanity_vs_nature/pages/game/models/dot_type.dart';
import 'package:humanity_vs_nature/pages/game/models/spot.dart';
import 'package:humanity_vs_nature/pages/game/modules/city/city_component.dart';
import 'package:humanity_vs_nature/pages/game/modules/farm/farm_component.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';

class FarmModule extends Component with HasGameRef<SimulationGame> {
  final List<FarmComponent> _farms = [];

  Iterable<Spot> get spots => _farms.map((e) => e.spot);

  void addFarm(Vector2 position, CityComponent owner) {
    final farm = FarmComponent(owner: owner)..position = position;
    _farms.add(farm);
    add(farm);
    game.fieldModule.addFirstFarmField(position);
  }

  void removeFarm(FarmComponent farm) {
    remove(farm);
    _farms.remove(farm);
    game.markDotsForSpot(farm.spot, DotType.none);
  }
}
