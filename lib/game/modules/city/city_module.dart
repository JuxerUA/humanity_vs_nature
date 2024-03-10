import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/math.dart';
import 'package:humanity_vs_nature/game/models/spot.dart';
import 'package:humanity_vs_nature/game/modules/city/city_component.dart';
import 'package:humanity_vs_nature/game/modules/matrix/block_type.dart';
import 'package:humanity_vs_nature/game/simulation_game.dart';

class CityModule extends Component with HasGameRef<SimulationGame> {
  static const requiredAverageAwareness = 0.75;

  final List<CityComponent> cities = [];

  Iterable<Spot> get spots => cities.map((e) => e.spot);

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

    final city1 = CityComponent()
      ..position = firstCityPosition
      ..updateTimer = 0;
    final city2 = CityComponent()
      ..position = secondCityPosition
      ..updateTimer = city1.updateTimer + 1 / 3;
    final city3 = CityComponent()
      ..position = thirdCityPosition
      ..updateTimer = city2.updateTimer + 1 / 3;
    cities.addAll([city1, city2, city3]);
    await addAll(cities);
    game.matrix
      ..markBlocksForSpot(city1.spot, BlockType.city)
      ..markBlocksForSpot(city2.spot, BlockType.city)
      ..markBlocksForSpot(city3.spot, BlockType.city);
  }

  void updateAwarenessProgress() {
    var totalPopulation = 0;
    var totalAwareness = 0.0;
    for (final city in cities) {
      totalPopulation += city.population;
      totalAwareness += city.awareness * city.population;
    }
    game.awarenessPercentage.value =
        (totalAwareness / totalPopulation / requiredAverageAwareness * 100).round();
  }
}
