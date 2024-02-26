import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/math.dart';
import 'package:humanity_vs_nature/pages/game/models/spot.dart';
import 'package:humanity_vs_nature/pages/game/modules/city/city_component.dart';
import 'package:humanity_vs_nature/pages/game/modules/matrix/block_type.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';

class CityModule extends Component with HasGameRef<SimulationGame> {
  final List<CityComponent> _cities = [];

  List<CityComponent> get cities => _cities;

  Iterable<Spot> get spots => _cities.map((e) => e.spot);

  @override
  FutureOr<void> onLoad() async {
    const offset = CityComponent.radius * 2.5;
    final buildingZone = Rectangle.fromLTRB(
      offset,
      offset,
      game.worldSize.x - offset,
      game.worldSize.y - offset,
    );

    final firstCityPosition = Vector2(
      buildingZone.left + buildingZone.width * randomFallback.nextDouble(),
      buildingZone.top +
          buildingZone.width * 0.25 * randomFallback.nextDouble(),
    );

    final secondCityPosition = Vector2(
      buildingZone.left +
          buildingZone.width * 0.3 * randomFallback.nextDouble(),
      buildingZone.bottom -
          buildingZone.width * 0.5 +
          buildingZone.width * 0.5 * randomFallback.nextDouble(),
    );

    final thirdCityPosition = Vector2(
      buildingZone.left +
          buildingZone.width * 0.7 +
          buildingZone.width * 0.3 * randomFallback.nextDouble(),
      buildingZone.bottom -
          buildingZone.width * 0.5 +
          buildingZone.width * 0.5 * randomFallback.nextDouble(),
    );

    final city1 = CityComponent()..position = firstCityPosition;
    final city2 = CityComponent()..position = secondCityPosition;
    final city3 = CityComponent()..position = thirdCityPosition;
    _cities.addAll([city1, city2, city3]);
    await addAll(_cities);
    game.matrix
      ..markBlocksForSpot(city1.spot, BlockType.city)
      ..markBlocksForSpot(city2.spot, BlockType.city)
      ..markBlocksForSpot(city3.spot, BlockType.city);
    return super.onLoad();
  }
}
