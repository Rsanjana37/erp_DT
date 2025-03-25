import 'package:flutter/material.dart';

class TaskBox extends StatelessWidget {
  final List<Map<String, String>> events;

  const TaskBox({Key? key, required this.events}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: events.map((event) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['task'] ?? 'Untitled Task',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event['time'] ?? 'No Deadline',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (events.indexOf(event) < events.length - 1)
                    const Divider(),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
