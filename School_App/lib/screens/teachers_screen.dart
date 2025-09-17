import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/teacher_provider.dart';
import '../models/models.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherProvider>().loadTeachers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teachers Management'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTeacherDialog(),
          ),
        ],
      ),
      body: Consumer<TeacherProvider>(
        builder: (context, teacherProvider, child) {
          if (teacherProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildSearchBar(),
              _buildTeacherStats(teacherProvider),
              Expanded(
                child: _buildTeachersList(teacherProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Search teachers...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildTeacherStats(TeacherProvider provider) {
    final filteredTeachers = _getFilteredTeachers(provider.teachers);
    final subjects = filteredTeachers.map((t) => t.subject).toSet().length;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                filteredTeachers.length.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const Text(
                'Teachers',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                subjects.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const Text(
                'Subjects',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeachersList(TeacherProvider provider) {
    final filteredTeachers = _getFilteredTeachers(provider.teachers);

    if (filteredTeachers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No teachers found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredTeachers.length,
      itemBuilder: (context, index) {
        final teacher = filteredTeachers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 2,
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              child: Text(
                teacher.name.isNotEmpty ? teacher.name[0].toUpperCase() : 'T',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              teacher.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Subject: ${teacher.subject}'),
                Text(
                  'Contact: ${teacher.contact}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditTeacherDialog(teacher);
                } else if (value == 'delete') {
                  _showDeleteConfirmation(teacher);
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (teacher.email != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.email, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text('Email: ${teacher.email}'),
                        ],
                      ),
                    ],
                    Row(
                      children: [
                        const Icon(Icons.class_, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text('Assigned Classes: ${teacher.assignedClasses.isEmpty ? 'None' : teacher.assignedClasses.join(', ')}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text('Joined: ${_formatDate(teacher.createdAt)}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Teacher> _getFilteredTeachers(List<Teacher> teachers) {
    if (_searchQuery.isEmpty) {
      return teachers;
    }

    return teachers
        .where((teacher) =>
            teacher.name.toLowerCase().contains(_searchQuery) ||
            teacher.subject.toLowerCase().contains(_searchQuery) ||
            teacher.contact.toLowerCase().contains(_searchQuery))
        .toList();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddTeacherDialog() {
    _showTeacherDialog();
  }

  void _showEditTeacherDialog(Teacher teacher) {
    _showTeacherDialog(teacher: teacher);
  }

  void _showTeacherDialog({Teacher? teacher}) {
    final isEditing = teacher != null;
    final nameController = TextEditingController(text: teacher?.name ?? '');
    final subjectController = TextEditingController(text: teacher?.subject ?? '');
    final contactController = TextEditingController(text: teacher?.contact ?? '');
    final emailController = TextEditingController(text: teacher?.email ?? '');
    List<String> selectedClasses = List.from(teacher?.assignedClasses ?? []);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Teacher' : 'Add New Teacher'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Teacher Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: subjectController,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: contactController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Assigned Classes:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th', '9th', '10th']
                          .map((className) => FilterChip(
                                label: Text(className),
                                selected: selectedClasses.contains(className),
                                onSelected: (selected) {
                                  setDialogState(() {
                                    if (selected) {
                                      selectedClasses.add(className);
                                    } else {
                                      selectedClasses.remove(className);
                                    }
                                  });
                                },
                              ))
                          .toList(),
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
                    final name = nameController.text.trim();
                    final subject = subjectController.text.trim();
                    final contact = contactController.text.trim();
                    final email = emailController.text.trim();

                    if (name.isEmpty || subject.isEmpty || contact.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all required fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      final provider = context.read<TeacherProvider>();
                      if (isEditing) {
                        final updatedTeacher = teacher.copyWith(
                          name: name,
                          subject: subject,
                          contact: contact,
                          email: email.isEmpty ? null : email,
                          assignedClasses: selectedClasses,
                        );
                        await provider.updateTeacher(updatedTeacher);
                      } else {
                        await provider.addTeacher(
                          name: name,
                          subject: subject,
                          contact: contact,
                          email: email.isEmpty ? null : email,
                          assignedClasses: selectedClasses,
                        );
                      }

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEditing ? 'Teacher updated successfully' : 'Teacher added successfully'),
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
                  child: Text(isEditing ? 'Update' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(Teacher teacher) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Teacher'),
          content: Text('Are you sure you want to delete ${teacher.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await context.read<TeacherProvider>().deleteTeacher(teacher.id);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Teacher deleted successfully'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting teacher: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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