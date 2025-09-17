import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/database_helper.dart';
import 'package:uuid/uuid.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<SchoolEvent> _events = [];
  bool _isLoading = false;
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final events = await _db.getEvents();
      setState(() {
        _events = events;
      });
    } catch (e) {
      debugPrint('Error loading events: $e');
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events & Notices'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEventDialog(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.event), text: 'All Events'),
            Tab(icon: Icon(Icons.upcoming), text: 'Upcoming'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AllEventsTab(
            events: _events,
            isLoading: _isLoading,
            onRefresh: _loadEvents,
            onDelete: _deleteEvent,
          ),
          _UpcomingEventsTab(
            events: _events.where((event) => event.isUpcoming).toList(),
            isLoading: _isLoading,
            onRefresh: _loadEvents,
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    EventType selectedType = EventType.event;
    String selectedAudience = 'all';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Event/Notice'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<EventType>(
                            value: selectedType,
                            decoration: const InputDecoration(
                              labelText: 'Type',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: EventType.event,
                                child: Text('Event'),
                              ),
                              DropdownMenuItem(
                                value: EventType.notice,
                                child: Text('Notice'),
                              ),
                            ],
                            onChanged: (value) {
                              setDialogState(() {
                                selectedType = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedAudience,
                            decoration: const InputDecoration(
                              labelText: 'Target Audience',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'all',
                                child: Text('All'),
                              ),
                              DropdownMenuItem(
                                value: 'students',
                                child: Text('Students'),
                              ),
                              DropdownMenuItem(
                                value: 'teachers',
                                child: Text('Teachers'),
                              ),
                            ],
                            onChanged: (value) {
                              setDialogState(() {
                                selectedAudience = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 8),
                        Text('Date: ${DateFormat('MMM d, y').format(selectedDate)}'),
                        const Spacer(),
                        TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setDialogState(() {
                                selectedDate = date;
                              });
                            }
                          },
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty ||
                        descriptionController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      final event = SchoolEvent(
                        id: _uuid.v4(),
                        title: titleController.text.trim(),
                        description: descriptionController.text.trim(),
                        date: selectedDate,
                        type: selectedType,
                        targetAudience: selectedAudience,
                        createdAt: DateTime.now(),
                      );

                      await _db.insertEvent(event);
                      await _loadEvents();

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${selectedType.name.toUpperCase()} added successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteEvent(String eventId) async {
    // For now, remove from local list (in real app, would delete from database)
    setState(() {
      _events.removeWhere((event) => event.id == eventId);
    });
  }
}

class _AllEventsTab extends StatelessWidget {
  final List<SchoolEvent> events;
  final bool isLoading;
  final VoidCallback onRefresh;
  final Function(String) onDelete;

  const _AllEventsTab({
    required this.events,
    required this.isLoading,
    required this.onRefresh,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (events.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No events or notices yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the + button to add one',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final isUpcoming = event.isUpcoming;
          final isToday = event.isToday;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: event.type == EventType.event ? Colors.blue : Colors.orange,
                child: Icon(
                  event.type == EventType.event ? Icons.event : Icons.announcement,
                  color: Colors.white,
                ),
              ),
              title: Text(
                event.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d, y').format(event.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.group,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.targetAudience?.toUpperCase() ?? 'ALL',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isToday)
                    const Chip(
                      label: Text(
                        'TODAY',
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    )
                  else if (isUpcoming)
                    const Chip(
                      label: Text(
                        'UPCOMING',
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteConfirmation(context, event);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, SchoolEvent event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Event'),
          content: Text('Are you sure you want to delete "${event.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                onDelete(event.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Event deleted successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class _UpcomingEventsTab extends StatelessWidget {
  final List<SchoolEvent> events;
  final bool isLoading;
  final VoidCallback onRefresh;

  const _UpcomingEventsTab({
    required this.events,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final upcomingEvents = events.where((event) => event.isUpcoming).toList();
    upcomingEvents.sort((a, b) => a.date.compareTo(b.date));

    if (upcomingEvents.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upcoming, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No upcoming events',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: upcomingEvents.length,
        itemBuilder: (context, index) {
          final event = upcomingEvents[index];
          final daysUntil = event.date.difference(DateTime.now()).inDays;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 2,
            color: event.isToday ? Colors.red.shade50 : null,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: event.isToday 
                    ? Colors.red 
                    : (event.type == EventType.event ? Colors.blue : Colors.orange),
                child: Text(
                  event.isToday ? 'T' : daysUntil.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                event.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.isToday 
                        ? 'Today'
                        : daysUntil == 1 
                            ? 'Tomorrow'
                            : 'In $daysUntil days',
                    style: TextStyle(
                      fontSize: 12,
                      color: event.isToday ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: Chip(
                label: Text(
                  event.type.name.toUpperCase(),
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
                backgroundColor: event.type == EventType.event ? Colors.blue : Colors.orange,
              ),
            ),
          );
        },
      ),
    );
  }
}