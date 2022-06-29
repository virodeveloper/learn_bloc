import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => PersonBloc(),
        child: const HomePage(),
      ),
    ),
  );
}

@immutable
abstract class LoadsAction {
  const LoadsAction();
}

@immutable
class LoadsPersonAction implements LoadsAction {
  final PersonURL url;

 const LoadsPersonAction({required this.url}) : super();
}

enum PersonURL { person1, person2 }

extension UrlString on PersonURL {
  String get urlString {
    switch (this) {
      case PersonURL.person1:
        return 'http://127.0.0.1:5500/api/persons1.json';
      case PersonURL.person2:
        return 'http://127.0.0.1:5500/api/persons2.json';
    }
  }
}

@immutable
class Person {
  final String name;
  final int age;

  const Person({
    required this.name,
    required this.age,
  });

  Person.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        age = json['age'] as int;
}

Future<Iterable<Person>> getPersons(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((req) => req.close())
    .then((resp) => resp.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List<dynamic>)
    .then((list) => list.map((e) => Person.fromJson(e)));

@immutable
class FetchResults {
  final Iterable<Person> persons;
  final bool isFromCache;

  const FetchResults({
    required this.persons,
    required this.isFromCache,
  });

  @override
  String toString() =>
      'FetchResults( person: $persons, isFromCache: $isFromCache)';
}

class PersonBloc extends Bloc<LoadsAction, FetchResults?> {
  final Map<PersonURL, Iterable<Person>> _cache = {};

  PersonBloc() : super(null) {
    on<LoadsPersonAction>((event, emit) async {
      final _url = event.url;
      if (_cache.containsKey(_url)) {
        final _person = _cache[_url]!;
        emit(FetchResults(
          persons: _person,
          isFromCache: true,
        ));
      } else {
        final persons = await getPersons(event.url.urlString);
        emit(FetchResults(
          persons: persons,
          isFromCache: false,
        ));
      }
    });
  }
}

extension Subscript<T> on Iterable<T> {
  T? operator [](int index) => length > index ? elementAt(index) : null;
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () {
                  context.read<PersonBloc>().add(
                        const LoadsPersonAction(
                          url: PersonURL.person1,
                        ),
                      );
                },
                child: const Text('Get person1 data'),
              ),
              TextButton(
                onPressed: () {
                  context.read<PersonBloc>().add(
                        const LoadsPersonAction(
                          url: PersonURL.person2,
                        ),
                      );
                },
                child: const Text('Get person2 data'),
              )
            ],
          ),
          BlocBuilder<PersonBloc, FetchResults?>(
            buildWhen: (previous, current) =>
                previous?.persons != current?.persons,
            builder: (context, state) {
              final _persons = state?.persons;

              if (_persons == null) {
                return const SizedBox.shrink();
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: _persons.length,
                  itemBuilder: (context, int index) {
                  
                  final _person= _persons[index]!;
                  return ListTile(
                    title: Text(_person.name),
                    subtitle: Text(_person.age.toString()),
                  );
                }),
              );
            },
          )
        ],
      ),
    );
  }
}
