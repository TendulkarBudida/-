import 'dart:async';
import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dart_random_choice/dart_random_choice.dart';
import 'package:quiver/iterables.dart ';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:async/async.dart';

FlutterView view = WidgetsBinding.instance.platformDispatcher.views.first;

Size size = view.physicalSize / view.devicePixelRatio;
double deviceWidth = size.width;
double deviceHeight = size.height;

double safePadding = 10.0;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Housie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Housie'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Timer? timer;
  FlutterTts ftts = FlutterTts();

  var list = [for (var i = 1; i <= 90; i++) i];
  var newList = [0];
  var listLast5Numbers = [];
  var listLast10Numbers = [];

  bool isLast5Active = false;
  bool isLast10Active = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView(
        children: [
          getRow1(),
          getRow2(), SizedBox(height: safePadding,),
          getRow3(), SizedBox(height: safePadding,),
          getRow4(), SizedBox(height: safePadding,),
          getRow5(),
        ],
      ),
    );
  }

  Widget getRow1() {
    return Padding(
      padding: EdgeInsets.all(safePadding),
      child: Container(
        padding: EdgeInsets.all(safePadding * 0.5),
        width: deviceWidth - (2 * safePadding),
        height: deviceWidth - (5.5 * safePadding),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.deepOrangeAccent,
            border: Border.all(width: safePadding * 0.5, color: Colors.black)
        ),
        child: numbers(),
      ),
    );
  }

  Widget numbers() {
    double spacing = 1.0;

    return GridView.count(
      shrinkWrap: true,
      // padding: EdgeInsets.all(safePadding),
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      crossAxisCount: 10,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var i = 1; i <= 90; i++)
          Container(
            decoration: BoxDecoration(
              border: Border.all(width: safePadding * 0.25, color: Colors.black),
              color: colorOfContainers(i),
            ),
            alignment: AlignmentDirectional.center,
            child: Text('$i', textAlign: TextAlign.center),
          ),
      ],
    );
  }

  Color colorOfContainers(int i) {
    if (isLast5Active) {
      isLast10Active = false;
      last5Numbers();
      if (listLast5Numbers.contains(i)) {
        return Colors.pinkAccent;
      }
    }
    else if (isLast10Active) {
      last10Numbers();
      if (listLast10Numbers.contains(i)) {
        return Colors.pinkAccent;
      }
    }
    return newList.contains(i) ? (i == newList.last ? Colors.deepOrange : Colors.green) : Colors.yellow;
  }

  // Color foundNumbers(i) {
  //   for (var j = 0; j < newList.length; j++) {
  //     if (i == newList[j]) {
  //       return Colors.green;
  //     }
  //   }
  //   return Colors.yellow;
  // }
  //
  // var containerList =

  // void start() {
    // print("random number = ");
    // print(randomNumber);
    // print("newList = ");
    // print(newList);
    // print("list = ");
    // print(list);
  // }

  Widget getRow2() {
    return Center(
      child: SizedBox(
        height: deviceHeight * 0.05,
        width: deviceWidth * 0.35,
        child: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: startTimer,
          child: const Text('Start'),
        ),
      ),
    );
  }

  Future<void> prepareTts() async {
    await ftts.setLanguage("en-US");
    await ftts.setSpeechRate(0.5);
    await ftts.setVolume(1.0);
    await ftts.setPitch(1);
  }

  void startTimer() {
    setState(()  {
      isLast5Active = false;
      isLast10Active = false;

      int seconds = _counter;
      timer = Timer.periodic(Duration(seconds: seconds), (timer) {
        setState(() {
          var randomNumber = randomChoice(list);
          prepareTts();
          newList.add(randomNumber);
          list.remove(randomNumber);
          ftts.speak("$randomNumber");
          // timer.interval = Duration(seconds: _counter);
        });
      });
    });
  }

// int getRandomInt(int min, int max) {
//   final random = Random();
//   return min + random.nextInt(max - min + 1);
// }

// int randomNum = 0;
//
// int getRandomInt(int min, int max) {
//   final random = Random();
//   int number = min + random.nextInt(max - min + 1);
//   setState(() {
//     randomNum = number;
//   });
// }

  Widget getRow3() {
    return Center(
      child: SizedBox(
        height: deviceHeight * 0.05,
        width: deviceWidth * 0.35,
        child: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: stopTimer,
          child: const Text('Pause'),
        ),
      ),
    );
  }

  void stopTimer() {
    if (timer != null) {
      timer!.cancel();
      timer = null;
    }
  }

  Widget getRow4() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Speed:',
            style: TextStyle(
              fontSize: 35.0,
              color: Colors.black,
            ),
          ),
          SizedBox(width: 2 * safePadding),
          FloatingActionButton(
            onPressed: _decrementCounter,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.remove),
          ),
          SizedBox(width: 2 * safePadding),
          Text(
            '$_counter',
            style: const TextStyle(
              fontSize: 48.0,
              color: Colors.black,
            ),
          ),
          SizedBox(width: 2 * safePadding),
          FloatingActionButton(
            onPressed: _incrementCounter,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  int _counter = 5;
  void _incrementCounter() {
    setState(() {
      if (_counter != 10) {
        _counter++; stopTimer(); startTimer();
      }
    });
  }
  void _decrementCounter() {
    setState(() {
      if (_counter != 1) {
        _counter--; stopTimer(); startTimer();
      }
    });
  }

  Widget getRow5() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Repeat Last:',
            style: TextStyle(
              fontSize: 35.0,
              color: Colors.black,
            ),
          ),
          SizedBox(width: 2 * safePadding),
          FloatingActionButton(
            onPressed: () {isLast5Active = !isLast5Active;},
            backgroundColor: Colors.blue,
            child: const Text(
              '5',
              style: TextStyle(
                fontSize: 30.0,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(width: 2 * safePadding),
          FloatingActionButton(
            onPressed: () {isLast10Active = !isLast10Active;},
            backgroundColor: Colors.blue,
            child: const Text(
              '10',
              style: TextStyle(
                fontSize: 30.0,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void last5Numbers() {
    setState(() {
      stopTimer();
      listLast5Numbers = newList.reversed.take(5).toList();
    });
  }

  void last10Numbers() {
    setState(() {
      stopTimer();
      listLast10Numbers = newList.reversed.take(10).toList();
    });
  }

}