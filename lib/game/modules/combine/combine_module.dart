import 'package:flame/components.dart';
import 'package:humanity_vs_nature/game/modules/city/city_component.dart';
import 'package:humanity_vs_nature/game/modules/combine/combine_component.dart';
import 'package:humanity_vs_nature/game/simulation_game.dart';

class CombineModule extends Component with HasGameRef<SimulationGame> {
  CombineComponent? combine;
  double timer = 0;

  @override
  void update(double dt) {
    super.update(dt);
    if ((timer += dt) > 1.1) {
      timer -= 1.1;
      if (combine == null) {
        final angriestCity = (game.cityModule.cities.toList()
              ..sort(
                  (a, b) => a.animalFoodAmount.compareTo(b.animalFoodAmount)))
            .first;
        if (angriestCity.plantFoodAmount < 1000) {
          addCombine(angriestCity);
        }
      }
    }
  }

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
}
