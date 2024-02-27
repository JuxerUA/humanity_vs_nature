import 'package:flame/components.dart';
import 'package:humanity_vs_nature/pages/game/models/spot.dart';
import 'package:humanity_vs_nature/pages/game/modules/city/city_component.dart';
import 'package:humanity_vs_nature/pages/game/modules/farm/farm_component.dart';
import 'package:humanity_vs_nature/pages/game/modules/matrix/block_type.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';

class FarmModule extends Component with HasGameRef<SimulationGame> {
  final List<FarmComponent> farms = [];

  Iterable<Spot> get spots => farms.map((e) => e.spot);

  void addFarm(Vector2 position, CityComponent owner) {
    final farm = FarmComponent(owner: owner)..position = position;
    farms.add(farm);
    add(farm);
    farm.baseField = game.fieldModule.addFirstFarmField(position);
    //todo we need to remove all fields in the area of the base field
  }

  void removeFarm(FarmComponent farm) {
    remove(farm);
    farms.remove(farm);
    game.fieldModule.onFarmRemoved(farm);
    game.matrix.removeBlocksOfTypeForSpot(farm.spot, BlockType.farm);
  }
}
