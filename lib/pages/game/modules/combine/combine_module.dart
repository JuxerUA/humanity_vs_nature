import 'package:flame/components.dart';
import 'package:humanity_vs_nature/pages/game/modules/city/city_component.dart';
import 'package:humanity_vs_nature/pages/game/modules/combine/combine_component.dart';
import 'package:humanity_vs_nature/pages/game/modules/farm/farm_component.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';

class CombineModule extends Component with HasGameRef<SimulationGame> {
  final List<CombineComponent> _combines = [];

  List<CombineComponent> get combines => _combines;

  void addCombine(CityComponent owner) {
    final targetPlace = game.getNearestFreeSpot(
        owner.position, FarmComponent.requiredSpotRadius);
    if (targetPlace != null) {
      final combine = CombineComponent(owner: owner, targetPlace: targetPlace)
        ..position = owner.position;
      _combines.add(combine);
      add(combine);
    }
  }

  void removeCombine(CombineComponent combine) {
    remove(combine);
    _combines.remove(combine);
  }
}
