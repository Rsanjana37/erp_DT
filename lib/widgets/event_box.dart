import 'package:flutter/material.dart';

class EventBox extends StatelessWidget {
  final List<Map<String, dynamic>> events;

  const EventBox({Key? key, required this.events}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  title: Text(event['title'] ?? 'Untitled Event'),
                  subtitle: Text(event['time'] ?? 'Nill'),
                  leading: Icon(Icons.event,
                      color: Theme.of(context).colorScheme.primary),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
