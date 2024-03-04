import 'package:flame/components.dart';
import 'package:flame/math.dart';
import 'package:humanity_vs_nature/game/models/spot.dart';
import 'package:humanity_vs_nature/game/modules/city/city_component.dart';
import 'package:humanity_vs_nature/game/modules/farm/farm_component.dart';
import 'package:humanity_vs_nature/game/modules/matrix/block_type.dart';
import 'package:humanity_vs_nature/game/simulation_game.dart';

class FarmModule extends Component with HasGameRef<SimulationGame> {
  final List<FarmComponent> farms = [];

  Iterable<Spot> get spots => farms.map((e) => e.spot);

  Future<void> spawnInitialFarms() async {
    for (final city in game.cityModule.cities) {
      final farmPlace = findPlaceForNewFarm(city.position);
      if (farmPlace != null) {
        final farm = addFarm(farmPlace, city);
        city.farms.add(farm);
        farm.storedGas = 100 * randomFallback.nextDouble();
      }
    }
  }

  Vector2? findPlaceForNewFarm(Vector2 position) {
    return game.getNearestFreeSpot(
      position,
      FarmComponent.requiredSpotRadius,
      ignoreBlocks: true,
    );
  }

  FarmComponent addFarm(Vector2 position, CityComponent owner) {
    final farm = FarmComponent(owner: owner)..position = position;
    farms.add(farm);
    add(farm);
    farm.baseField = game.fieldModule.addFirstFieldForFarm(farm);
    return farm;

    game.fieldModule.removeAllFieldsInTheFieldArea(farm.baseField);
    //TODO remove all trees too
  }

  void removeFarm(FarmComponent farm) {
    remove(farm);
    farms.remove(farm);
    farm.owner.farms.remove(farm);
    game.fieldModule.onFarmRemoved(farm);
    game.matrix.removeBlocksOfTypeForSpot(farm.spot, BlockType.farm);
  }
}
