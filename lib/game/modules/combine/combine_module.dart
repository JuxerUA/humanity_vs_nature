import 'package:flame/components.dart';
import 'package:humanity_vs_nature/game/modules/city/city_component.dart';
import 'package:humanity_vs_nature/game/modules/combine/combine_component.dart';
import 'package:humanity_vs_nature/game/simulation_game.dart';

class CombineModule extends Component with HasGameRef<SimulationGame> {
  CombineComponent? combine;
  final citiesRequests = <CityComponent, int>{};

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
    _tryToSpawnCombine();
  }

  bool cityWantsToBuildNewFarm(CityComponent city) {
    citiesRequests[city] = (citiesRequests[city] ?? 0) + 1;
    return _tryToSpawnCombine();
  }

  bool _tryToSpawnCombine() {
    int sort(MapEntry<CityComponent, int> a, MapEntry<CityComponent, int> b) {
      final cityFarmCountA = a.key.farms.length;
      final cityFarmCountB = b.key.farms.length;
      final resultA = cityFarmCountA > 0 ? a.value / cityFarmCountA : 999;
      final resultB = cityFarmCountB > 0 ? b.value / cityFarmCountB : 999;
      return resultB.compareTo(resultA);
    }

    if (combine == null) {
      final entries = citiesRequests.entries.toList()..sort(sort);
      final bestRequest = entries.firstOrNull;
      if (bestRequest != null && bestRequest.value > 2) {
        addCombine(bestRequest.key);
        citiesRequests[bestRequest.key] = 0;
        return true;
      }
    }

    return false;
  }
}
