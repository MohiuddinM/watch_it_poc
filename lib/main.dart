import 'package:flutter/material.dart';
import 'package:watch_it_poc/watcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

final model = CounterModel();

class CounterModel with ChangeNotifier {
  int _count1 = 0;
  int _count2 = 0;
  int _count3 = 0;

  int get count1 => _count1;

  int get count2 => _count2;

  int get count3 => _count3;

  void increment1() {
    _count1 += 1;
    notifyListeners();
  }

  void increment2() {
    _count2 += 1;
    notifyListeners();
  }

  void increment3() {
    _count3 += 1;
    notifyListeners();
  }
}

class HomePage extends WatchingWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    watch(context, model, selector: (m) => m.count1);
    watch(context, model, selector: (m) => m.count2);

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('count 1: ${model.count1.toString()}'),
              const SizedBox(width: 16),
              Text('count 2: ${model.count2.toString()}'),
              const SizedBox(width: 16),
              Text('count 3: ${model.count3.toString()}'),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: model.increment1,
            child: const Text('Increment1'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: model.increment2,
            child: const Text('Increment2'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: model.increment3,
            child: const Text('Increment3'),
          ),
        ],
      ),
    );
  }
}
