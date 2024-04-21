// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Start`
  String get start {
    return Intl.message(
      'Start',
      name: 'start',
      desc: '',
      args: [],
    );
  }

  /// `Tutorial enabled`
  String get tutorialEnabled {
    return Intl.message(
      'Tutorial enabled',
      name: 'tutorialEnabled',
      desc: '',
      args: [],
    );
  }

  /// `Tutorial disabled`
  String get tutorialDisabled {
    return Intl.message(
      'Tutorial disabled',
      name: 'tutorialDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Disable`
  String get disable {
    return Intl.message(
      'Disable',
      name: 'disable',
      desc: '',
      args: [],
    );
  }

  /// `Enable`
  String get enable {
    return Intl.message(
      'Enable',
      name: 'enable',
      desc: '',
      args: [],
    );
  }

  /// `Loading`
  String get loading {
    return Intl.message(
      'Loading',
      name: 'loading',
      desc: '',
      args: [],
    );
  }

  /// `Awareness`
  String get awareness {
    return Intl.message(
      'Awareness',
      name: 'awareness',
      desc: '',
      args: [],
    );
  }

  /// `Pollution`
  String get pollution {
    return Intl.message(
      'Pollution',
      name: 'pollution',
      desc: '',
      args: [],
    );
  }

  /// `Resume`
  String get resume {
    return Intl.message(
      'Resume',
      name: 'resume',
      desc: '',
      args: [],
    );
  }

  /// `Tutorial`
  String get tutorial {
    return Intl.message(
      'Tutorial',
      name: 'tutorial',
      desc: '',
      args: [],
    );
  }

  /// `Main Menu`
  String get mainMenu {
    return Intl.message(
      'Main Menu',
      name: 'mainMenu',
      desc: '',
      args: [],
    );
  }

  /// `Got It!`
  String get gotIt {
    return Intl.message(
      'Got It!',
      name: 'gotIt',
      desc: '',
      args: [],
    );
  }

  /// `Do you know?`
  String get doYouKnow {
    return Intl.message(
      'Do you know?',
      name: 'doYouKnow',
      desc: '',
      args: [],
    );
  }

  /// `Welcome`
  String get welcome {
    return Intl.message(
      'Welcome',
      name: 'welcome',
      desc: '',
      args: [],
    );
  }

  /// `Interface`
  String get interface {
    return Intl.message(
      'Interface',
      name: 'interface',
      desc: '',
      args: [],
    );
  }

  /// `Game goal`
  String get gameGoal {
    return Intl.message(
      'Game goal',
      name: 'gameGoal',
      desc: '',
      args: [],
    );
  }

  /// `Trees`
  String get trees {
    return Intl.message(
      'Trees',
      name: 'trees',
      desc: '',
      args: [],
    );
  }

  /// `Bulldozers`
  String get bulldozers {
    return Intl.message(
      'Bulldozers',
      name: 'bulldozers',
      desc: '',
      args: [],
    );
  }

  /// `Cities`
  String get cities {
    return Intl.message(
      'Cities',
      name: 'cities',
      desc: '',
      args: [],
    );
  }

  /// `Farms`
  String get farms {
    return Intl.message(
      'Farms',
      name: 'farms',
      desc: '',
      args: [],
    );
  }

  /// `Fields`
  String get fields {
    return Intl.message(
      'Fields',
      name: 'fields',
      desc: '',
      args: [],
    );
  }

  /// `Carbon dioxide (CO₂)`
  String get carbonDioxideCo2 {
    return Intl.message(
      'Carbon dioxide (CO₂)',
      name: 'carbonDioxideCo2',
      desc: '',
      args: [],
    );
  }

  /// `Methane (CH₄)`
  String get methaneCh4 {
    return Intl.message(
      'Methane (CH₄)',
      name: 'methaneCh4',
      desc: '',
      args: [],
    );
  }

  /// `Natural disasters`
  String get disasters {
    return Intl.message(
      'Natural disasters',
      name: 'disasters',
      desc: '',
      args: [],
    );
  }

  /// `Play Again!`
  String get playAgain {
    return Intl.message(
      'Play Again!',
      name: 'playAgain',
      desc: '',
      args: [],
    );
  }

  /// `Oh, no! Looks like this planet is doomed 😟\n\nWell, at least it's only a game 😅 Maybe there's another way to make things right.\n\nGood luck!`
  String get ohNonlooksLikeThisPlanetIsDoomedWellAtLeast {
    return Intl.message(
      'Oh, no! Looks like this planet is doomed 😟\n\nWell, at least it\'s only a game 😅 Maybe there\'s another way to make things right.\n\nGood luck!',
      name: 'ohNonlooksLikeThisPlanetIsDoomedWellAtLeast',
      desc: '',
      args: [],
    );
  }

  /// `Congratulations! 😁\n\nThe general level of awareness among citizens has reached a level of no return. Global warming is no longer a threat to us! We can breathe again 😅\n\nCongratulations again!`
  String
      get congratulationsntheGeneralLevelOfAwarenessAmongCitizensHasReachedA {
    return Intl.message(
      'Congratulations! 😁\n\nThe general level of awareness among citizens has reached a level of no return. Global warming is no longer a threat to us! We can breathe again 😅\n\nCongratulations again!',
      name:
          'congratulationsntheGeneralLevelOfAwarenessAmongCitizensHasReachedA',
      desc: '',
      args: [],
    );
  }

  /// `Cities create bulldozers to make more space for fields and farms. Bulldozers can be useful for you too, because they make space for new trees too 😉`
  String get citiesLikeToLetOutBulldozersToClearSomeMore {
    return Intl.message(
      'Cities create bulldozers to make more space for fields and farms. Bulldozers can be useful for you too, because they make space for new trees too 😉',
      name: 'citiesLikeToLetOutBulldozersToClearSomeMore',
      desc: '',
      args: [],
    );
  }

  /// `Agriculture is the main cause of deforestation on the planet.`
  String get agricultureIsTheLeadingCauseOfDeforestationOnThePlanet {
    return Intl.message(
      'Agriculture is the main cause of deforestation on the planet.',
      name: 'agricultureIsTheLeadingCauseOfDeforestationOnThePlanet',
      desc: '',
      args: [],
    );
  }

  /// `There is another important gas, methane or CH₄. You can see some white particles here. That's it! Note that methane, although smaller in volume, affects the Pollution bar 80 times more than carbon dioxide.`
  String get thereIsAnotherImportantGasMethaneOrCh4YouCan {
    return Intl.message(
      'There is another important gas, methane or CH₄. You can see some white particles here. That\'s it! Note that methane, although smaller in volume, affects the Pollution bar 80 times more than carbon dioxide.',
      name: 'thereIsAnotherImportantGasMethaneOrCh4YouCan',
      desc: '',
      args: [],
    );
  }

  /// `Although there is much less methane in the atmosphere than carbon dioxide, it can cause more than 80 times more powerful greenhouse effect. Methane is a wonderful gas. Over time, it turns into carbon dioxide.`
  String get althoughThereIsMuchLessMethaneInTheAtmosphereThan {
    return Intl.message(
      'Although there is much less methane in the atmosphere than carbon dioxide, it can cause more than 80 times more powerful greenhouse effect. Methane is a wonderful gas. Over time, it turns into carbon dioxide.',
      name: 'althoughThereIsMuchLessMethaneInTheAtmosphereThan',
      desc: '',
      args: [],
    );
  }

  /// `In this game, the cities are the only source of carbon dioxide. The larger the population of the city and the lower the average level of awareness of the city dwellers, the more carbon dioxide it creates. By tapping on the town you can hasten the awareness of the townspeople 🧐\n\nAs awareness increases, citizens also consume less animal-based foods, which helps reduce the amount of methane.`
  String get inThisGameTheCitiesAreTheOnlySourceOf {
    return Intl.message(
      'In this game, the cities are the only source of carbon dioxide. The larger the population of the city and the lower the average level of awareness of the city dwellers, the more carbon dioxide it creates. By tapping on the town you can hasten the awareness of the townspeople 🧐\n\nAs awareness increases, citizens also consume less animal-based foods, which helps reduce the amount of methane.',
      name: 'inThisGameTheCitiesAreTheOnlySourceOf',
      desc: '',
      args: [],
    );
  }

  /// `You can see these blue particles coming from the cities. That's carbon dioxide or CO₂. If there's too much CO₂, you're going to lose. Luckily plants can absorb it 😍`
  String get youCanSeeTheseBlueParticlesComingFromTheCities {
    return Intl.message(
      'You can see these blue particles coming from the cities. That\'s carbon dioxide or CO₂. If there\'s too much CO₂, you\'re going to lose. Luckily plants can absorb it 😍',
      name: 'youCanSeeTheseBlueParticlesComingFromTheCities',
      desc: '',
      args: [],
    );
  }

  /// `The oceans absorb up to 30% of the carbon dioxide released into the atmosphere due to human activity. Phytoplankton - microscopic plants drifting in the water - play a key role in absorbing CO₂ by the oceans.`
  String get theOceansAbsorbUpTo30OfTheCarbonDioxide {
    return Intl.message(
      'The oceans absorb up to 30% of the carbon dioxide released into the atmosphere due to human activity. Phytoplankton - microscopic plants drifting in the water - play a key role in absorbing CO₂ by the oceans.',
      name: 'theOceansAbsorbUpTo30OfTheCarbonDioxide',
      desc: '',
      args: [],
    );
  }

  /// `Weather disasters like fires or tornadoes were also planned for this game. But not this time 🙃`
  String get weatherDisastersLikeFiresOrTornadoesWereAlsoPlannedFor {
    return Intl.message(
      'Weather disasters like fires or tornadoes were also planned for this game. But not this time 🙃',
      name: 'weatherDisastersLikeFiresOrTornadoesWereAlsoPlannedFor',
      desc: '',
      args: [],
    );
  }

  /// `Global warming is also destroying climate stability and increasing the frequency and severity of natural disasters.`
  String get globalWarmingIsAlsoDestroyingClimateStabilityAndIncreasingThe {
    return Intl.message(
      'Global warming is also destroying climate stability and increasing the frequency and severity of natural disasters.',
      name: 'globalWarmingIsAlsoDestroyingClimateStabilityAndIncreasingThe',
      desc: '',
      args: [],
    );
  }

  /// `It's a farm. It raises animals for food. This is very sad.. 😔\n\nIn the process of digesting food, the animals produce methane (CH₄).`
  String get itsAFarmItRaisesAnimalsForFoodnsoundsWildDoesnt {
    return Intl.message(
      'It\'s a farm. It raises animals for food. This is very sad.. 😔\n\nIn the process of digesting food, the animals produce methane (CH₄).',
      name: 'itsAFarmItRaisesAnimalsForFoodnsoundsWildDoesnt',
      desc: '',
      args: [],
    );
  }

  /// `The majority of human-produced methane comes from livestock farming.`
  String get theMajorityOfHumanproducedMethaneComesFromLivestockFarming {
    return Intl.message(
      'The majority of human-produced methane comes from livestock farming.',
      name: 'theMajorityOfHumanproducedMethaneComesFromLivestockFarming',
      desc: '',
      args: [],
    );
  }

  /// `Fields provide cities and farms with plant food.`
  String get theFieldsProvideCitiesAndFarmsWithPlantFoodOf {
    return Intl.message(
      'Fields provide cities and farms with plant food.',
      name: 'theFieldsProvideCitiesAndFarmsWithPlantFoodOf',
      desc: '',
      args: [],
    );
  }

  /// `Most of the food grown in the fields is used to feed farm animals. If all people switched to a plant-based diet, we could reduce the number of fields by many times and return these areas to the wild.`
  String get mostOfTheFoodGrownInTheFieldsIsUsed {
    return Intl.message(
      'Most of the food grown in the fields is used to feed farm animals. If all people switched to a plant-based diet, we could reduce the number of fields by many times and return these areas to the wild.',
      name: 'mostOfTheFoodGrownInTheFieldsIsUsed',
      desc: '',
      args: [],
    );
  }

  /// `Well, it's pretty simple 😁\n\nIf you manage to fill the green bar, you win.\n\nIf the orange bar fills up before you do, you lose.\n\nYou need to get rid of the excess gas by planting trees and raising awareness.\n\nGood luck!`
  String get wellItsPrettySimpleNifYouCanFillInThe {
    return Intl.message(
      'Well, it\'s pretty simple 😁\n\nIf you manage to fill the green bar, you win.\n\nIf the orange bar fills up before you do, you lose.\n\nYou need to get rid of the excess gas by planting trees and raising awareness.\n\nGood luck!',
      name: 'wellItsPrettySimpleNifYouCanFillInThe',
      desc: '',
      args: [],
    );
  }

  /// `At the top of the screen you can see the interface.\n\nThe left blue part contains counters for both gases.\n\nThe green Awareness bar shows the average level of awareness of the townspeople.\n\nThe orange Pollution bar shows the level of gassing of the area. If it is filled, the effects of global warming will become irreversible and you will lose.`
  String get atTheTopOfTheScreenYouCanSeeThe {
    return Intl.message(
      'At the top of the screen you can see the interface.\n\nThe left blue part contains counters for both gases.\n\nThe green Awareness bar shows the average level of awareness of the townspeople.\n\nThe orange Pollution bar shows the level of gassing of the area. If it is filled, the effects of global warming will become irreversible and you will lose.',
      name: 'atTheTopOfTheScreenYouCanSeeThe',
      desc: '',
      args: [],
    );
  }

  /// `Trees use CO₂ (blue particles) to grow. A mature tree no longer absorbs the gas, but you can tap on it to make it drop its cones. New trees grow from these cones 😊\n\nThere is also a chance of getting a cone if you tap on the grass.`
  String get treesUseCo2BlueParticlesToGrowTheLargestTree {
    return Intl.message(
      'Trees use CO₂ (blue particles) to grow. A mature tree no longer absorbs the gas, but you can tap on it to make it drop its cones. New trees grow from these cones 😊\n\nThere is also a chance of getting a cone if you tap on the grass.',
      name: 'treesUseCo2BlueParticlesToGrowTheLargestTree',
      desc: '',
      args: [],
    );
  }

  /// `Plants gain mass mainly by converting carbon dioxide into carbohydrate. Thus, the more active a plant grows, the more carbon dioxide it absorbs.`
  String get plantsGainMassMainlyByConvertingCarbonDioxideIntoCarbohydrate {
    return Intl.message(
      'Plants gain mass mainly by converting carbon dioxide into carbohydrate. Thus, the more active a plant grows, the more carbon dioxide it absorbs.',
      name: 'plantsGainMassMainlyByConvertingCarbonDioxideIntoCarbohydrate',
      desc: '',
      args: [],
    );
  }

  /// `Hi there!\n\nWe are facing the problem of global warming. You've probably heard about it by now 😲\n\nWell, we need a hero to clean up the mess.\n\nCould that be you? Definitely! Let's get to work.`
  String get hiTherenweAreFacingTheProblemOfGlobalWarmingYouve {
    return Intl.message(
      'Hi there!\n\nWe are facing the problem of global warming. You\'ve probably heard about it by now 😲\n\nWell, we need a hero to clean up the mess.\n\nCould that be you? Definitely! Let\'s get to work.',
      name: 'hiTherenweAreFacingTheProblemOfGlobalWarmingYouve',
      desc: '',
      args: [],
    );
  }

  /// `Population`
  String get population {
    return Intl.message(
      'Population',
      name: 'population',
      desc: '',
      args: [],
    );
  }

  /// `Awareness increased!`
  String get awarenessIncreased {
    return Intl.message(
      'Awareness increased!',
      name: 'awarenessIncreased',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'uk'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
