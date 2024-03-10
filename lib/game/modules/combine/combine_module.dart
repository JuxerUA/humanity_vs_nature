import 'package:flame/components.dart';
import 'package:humanity_vs_nature/game/modules/city/city_component.dart';
import 'package:humanity_vs_nature/game/modules/combine/combine_component.dart';
import 'package:humanity_vs_nature/game/simulation_game.dart';

class CombineModule extends Component with HasGameRef<SimulationGame> {
  CombineComponent? combine;

  void addCombine(CityComponent owner) {
    final targetPlace = game.farmModule.findPlaceForNewFarm(owner.position);
    if (targetPlace != null) {
      final combine = CombineComponent(owner: owner, targetPlace: targetPlace)
        ..position = owner.position;
      this.combine = combine;
      add(combine);
    }
  }

  void removeCombine(CombineComponent combine) {
    remove(combine);
    this.combine = null;
  }

  bool cityWantsToBuildNewFarm(CityComponent city) {
    if (combine == null) {
      addCombine(city);
      return true;
    }
    return false;
  }
}
