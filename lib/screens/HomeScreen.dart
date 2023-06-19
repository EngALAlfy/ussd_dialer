import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:smart_select/smart_select.dart';
import 'package:ussd_dialer/providers/ExcelProvider.dart';
import 'package:ussd_dialer/providers/SimsProvider.dart';
import 'package:ussd_dialer/providers/UssdProvider.dart';
import 'package:ussd_dialer/widgets/IsLoadingWidget.dart';

class HomeScreen extends StatelessWidget {
  final _amountController = TextEditingController();
  final _codeFormatController = TextEditingController();
  final _delayController = TextEditingController(text: "10");
  final _durationController = TextEditingController(text: "50");

  @override
  Widget build(BuildContext context) {
    context.read<SimsProvider>().getSimCards();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Recharger"),
      ),
      body: Container(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          children: [
            simSelect(),
            SizedBox(
              height: 10,
            ),
            TextButton.icon(
                onPressed: () {
                  context.read<ExcelProvider>().getExcel();
                },
                icon: Icon(Icons.file_upload),
                label: Text("Choose Excel File")),
            SizedBox(
              height: 10,
            ),
            Consumer<ExcelProvider>(
              builder: (context, value, child) =>
                  Text("File name : ${value.fileName}"),
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: _codeFormatController,
              decoration: InputDecoration(
                labelText: "Code Format",
                hintText: "*9*7*m*a#",
                helperText: "Enter m for mobile number and a for amount"
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Amount",
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Divider(),
            SizedBox(
              height: 30,
            ),
            TextField(
              controller: _delayController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Delay",
                hintText: "10",
                helperText: "Delay between every USSD"
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Duration",
                hintText: "50",
                helperText: "Duration of every USSD"
              ),
            ),
            SizedBox(
              height: 50,
            ),
            loggerList(),
            SizedBox(
              height: 50,
            ),
            Consumer<UssdProvider>(
              builder: (context, value, child) => Center(child: Text("Status : ${value.status}"),),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Consumer<UssdProvider>(builder: (context, value, child) {
        if(value.status == "done" || value.status == "N/A"){
          return FloatingActionButton.extended(
              onPressed: () {
                startDial(context);
              },
              backgroundColor: Colors.green,
              label: Text("Start"));
        }else{
          return FloatingActionButton.extended(
              onPressed: () {
                context.read<UssdProvider>().stopDial();
              },
              backgroundColor: Colors.red,
              label: Text("Stop"));
        }
      },),
    );
  }

  simSelect() {
    return Consumer<SimsProvider>(
      builder: (context, value, child) {
        if (value.sims == null) {
          return IsLoadingWidget();
        }
        return SmartSelect<int>.single(
          title: 'SIM',
          value: value.sim,
          choiceItems: value.sims,
          modalType: S2ModalType.bottomSheet,
          choiceType: S2ChoiceType.radios,
          onChange: (state) {
            value.sim = state.value;
          },
          tileBuilder: (context, state) {
            return S2Tile.fromState(
              state,
              isTwoLine: true,
              trailing: Icon(Icons.keyboard_arrow_left_rounded),
            );
          },
        );
      },
    );
  }

  loggerList() {
    //ScrollController controller = ScrollController();
    return Container(
      height: 200,
      color: Colors.black,
      child: Consumer<UssdProvider>(
        builder: (context, value, child) => ListView.builder(

          padding: EdgeInsets.all(10),
          itemCount: value.results.length,
          itemBuilder: (context, index) => Text(
            "${value.results.keys.elementAt(index)} : ${value.results.values.elementAt(index)}",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Future<void> startDial(BuildContext context) async {
    var sim = context.read<SimsProvider>().sim;
    var numbers = context.read<ExcelProvider>().numbers;
    var amount = _amountController.text ?? "0";
    var codeFormat = _codeFormatController.text;

    var delay = _delayController.text;
    var duration = _durationController.text;

    context.read<UssdProvider>().sim = sim;
    context.read<UssdProvider>().numbers = numbers;
    context.read<UssdProvider>().amount = amount;
    context.read<UssdProvider>().codeFormat = codeFormat;
    context.read<UssdProvider>().delay = Duration(seconds: int.tryParse(delay ?? "10") ?? 10);
    context.read<UssdProvider>().duration = Duration(seconds: int.tryParse(duration ?? "50") ?? 50);

    if(sim == null){
      Alert(context: context,type: AlertType.error, title: "Error",desc: "Please , Select sim").show();
      return;
    }

    if(amount == null || amount.isEmpty || amount == "0"){
      Alert(context: context,type: AlertType.error, title: "Error",desc: "Please , Enter amount > 0").show();
      return;
    }

    if(codeFormat == null || codeFormat.isEmpty){
      Alert(context: context,type: AlertType.error, title: "Error",desc: "Please , Enter code format with m for mobile and a for amount").show();
      return;
    }

    if(numbers == null || numbers.isEmpty){
      Alert(context: context,type: AlertType.error, title: "Error",desc: "please , Select excel sheet with numbers").show();
      return;
    }

    context.read<UssdProvider>().startDialLoop();
  }
}
