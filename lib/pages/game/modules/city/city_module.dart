import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/math.dart';
import 'package:humanity_vs_nature/pages/game/models/spot.dart';
import 'package:humanity_vs_nature/pages/game/modules/city/city_component.dart';
import 'package:humanity_vs_nature/pages/game/modules/matrix/block_type.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';

class CityModule extends Component with HasGameRef<SimulationGame> {
  final List<CityComponent> cities = [];

  Iterable<Spot> get spots => cities.map((e) => e.spot);

  @override
  FutureOr<void> onLoad() async {
    await spawnInitialCities();
    return super.onLoad();
  }

  Future<void> spawnInitialCities() async {
    const offset = CityComponent.radius * 2.5;
    final buildingZone = Rectangle.fromLTRB(
      offset,
      offset,
      game.worldSize.x - offset,
      game.worldSize.y - offset,
    );

    final firstCityPosition = Vector2(
      buildingZone.left +
          buildingZone.width * 0.25 +
          buildingZone.width * 0.5 * randomFallback.nextDouble(),
      buildingZone.top +
          buildingZone.height * 0.25 * randomFallback.nextDouble(),
    );

    final secondCityPosition = Vector2(
      buildingZone.left +
          buildingZone.width * 0.3 * randomFallback.nextDouble(),
      buildingZone.bottom -
          buildingZone.height * 0.5 +
          buildingZone.height * 0.5 * randomFallback.nextDouble(),
    );

    final thirdCityPosition = Vector2(
      buildingZone.left +
          buildingZone.width * 0.7 +
          buildingZone.width * 0.3 * randomFallback.nextDouble(),
      buildingZone.bottom -
          buildingZone.height * 0.5 +
          buildingZone.height * 0.5 * randomFallback.nextDouble(),
    );

    final city1 = CityComponent()..position = firstCityPosition;
    final city2 = CityComponent()..position = secondCityPosition;
    final city3 = CityComponent()..position = thirdCityPosition;
    cities.addAll([city1, city2, city3]);
    await addAll(cities);
    game.matrix
      ..markBlocksForSpot(city1.spot, BlockType.city)
      ..markBlocksForSpot(city2.spot, BlockType.city)
      ..markBlocksForSpot(city3.spot, BlockType.city);
  }
}
