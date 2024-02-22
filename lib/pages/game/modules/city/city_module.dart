import 'dart:async';

import 'package:flame/components.dart';
import 'package:humanity_vs_nature/pages/game/models/block_type.dart';
import 'package:humanity_vs_nature/pages/game/models/spot.dart';
import 'package:humanity_vs_nature/pages/game/modules/city/city_component.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';

class CityModule extends Component with HasGameRef<SimulationGame> {
  final List<CityComponent> _cities = [];

  List<CityComponent> get cities => _cities;

  Iterable<Spot> get spots => _cities.map((e) => e.spot);

  @override
  FutureOr<void> onLoad() async {
    final city1 = CityComponent()
      ..position = Vector2(game.size.x / 2, game.size.y / 4);
    final city2 = CityComponent()
      ..position = Vector2(game.size.x / 2, game.size.y / 4 * 3);
    _cities.addAll([city1, city2]);
    await addAll(_cities);
    game.matrix
      ..markBlocksForSpot(city1.spot, BlockType.city)
      ..markBlocksForSpot(city2.spot, BlockType.city);
    return super.onLoad();
  }
}
