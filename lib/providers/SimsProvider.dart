import 'package:flutter/material.dart';
import 'package:sim_data/sim_data.dart';
import 'package:smart_select/smart_select.dart';

class SimsProvider extends ChangeNotifier{

  List<S2Choice<int>> sims;
  int sim;

  getSimCards() async {
    SimData simData = await SimDataPlugin.getSimData();
    sims = simData.cards.map((e) => e == null ? null : S2Choice(value: e.subscriptionId, title: e.displayName)).toList();
    notifyListeners();
  }

}