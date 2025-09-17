import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../models/models.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('School Dashboard'),
        centerTitle: true,
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, dashboardProvider, child) {
          if (dashboardProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'School Overview',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSummaryCards(dashboardProvider),
                const SizedBox(height: 20),
                const Text(
                  'Upcoming Events',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 300,
                  child: _buildUpcomingEvents(dashboardProvider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(DashboardProvider provider) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard(
          'Total Students',
          provider.totalStudents.toString(),
          Icons.school,
          Colors.blue,
        ),
        _buildSummaryCard(
          'Total Teachers',
          provider.totalTeachers.toString(),
          Icons.person,
          Colors.green,
        ),
        _buildSummaryCard(
          'Today\'s Attendance',
          '${provider.todayAttendance.toStringAsFixed(1)}%',
          Icons.check_circle,
          Colors.orange,
        ),
        _buildSummaryCard(
          'Upcoming Events',
          provider.upcomingEvents.length.toString(),
          Icons.event,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEvents(DashboardProvider provider) {
    if (provider.upcomingEvents.isEmpty) {
      return const Center(
        child: Text(
          'No upcoming events',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: provider.upcomingEvents.length,
      itemBuilder: (context, index) {
        final event = provider.upcomingEvents[index];
        return Card(
          child: ListTile(
            leading: Icon(
              event.type == EventType.event ? Icons.event : Icons.announcement,
              color: Colors.blue,
            ),
            title: Text(event.title),
            subtitle: Text(
              '${event.date.day}/${event.date.month}/${event.date.year}',
            ),
            trailing: event.isToday 
                ? const Chip(
                    label: Text('Today'),
                    backgroundColor: Colors.orange,
                  )
                : null,
          ),
        );
      },
    );
  }
}