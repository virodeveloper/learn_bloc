import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'dart:math' as math show Random;

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    ),
  );
}

const names = [
  'foo',
  'Bar',
  'Baz',
];

extension RandomElement<T> on Iterable<T> {
  T getRandomName() => elementAt(math.Random().nextInt(length));
}

class NamesCubit extends Cubit<String?> {
  NamesCubit() : super(null);

  void pickRandomname() => emit(names.getRandomName());
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late NamesCubit _nameCubit;

  @override
  void initState() {
    super.initState();
    _nameCubit = NamesCubit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: StreamBuilder<String?>(
          stream: _nameCubit.stream,
          builder: (context, snaphot) {
            final button = TextButton(
              onPressed: () => _nameCubit.pickRandomname(),
              child: Column(
                children: [
                  Text(snaphot.data ?? ''),
                  const Text('Pick Random number'),
                ],
              ),
            );
            switch (snaphot.connectionState) {
              case ConnectionState.none:
                return button;
              case ConnectionState.waiting:
                return button;
              case ConnectionState.active:
                return button;
              case ConnectionState.done:
                return button;
            }
          }),
    );
  }

  @override
  void dispose() {
    _nameCubit.close();
    super.dispose();
  }
}
