import 'package:flutter/material.dart';

class _TodoItem {
  String title;
  bool completed;

  _TodoItem({
    @required this.title,
    @required this.completed,
  });
  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "completed": completed,
    };
  }
}

class CHeckNew extends StatefulWidget {
  const CHeckNew({Key key}) : super(key: key);

  @override
  _CHeckNewState createState() => _CHeckNewState();
}

class _CHeckNewState extends State<CHeckNew> {
  final Map<String, bool> _map = {};
  int _count = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => setState(
            () => _map.addEntries([MapEntry('Checkbox #${++_count}', false)])),
      ),
      body: ListView(
        children: _map.keys
            .map(
              (key) => CheckboxListTile(
                value: _map[key],
                onChanged: (value) => setState(() => _map[key] = value),
                subtitle: Text(key),
              ),
            )
            .toList(),
      ),
    );
  }
}
