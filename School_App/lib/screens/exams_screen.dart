import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/exam_provider.dart';
import '../providers/student_provider.dart';
import '../models/models.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExamProvider>().loadExams();
      context.read<StudentProvider>().loadStudents();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exams & Results'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.assignment), text: 'Exam Schedule'),
            Tab(icon: Icon(Icons.edit), text: 'Enter Marks'),
            Tab(icon: Icon(Icons.analytics), text: 'Results Summary'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ExamScheduleTab(),
          _EnterMarksTab(),
          _ResultsSummaryTab(),
        ],
      ),
    );
  }
}

class _ExamScheduleTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ExamProvider>(
      builder: (context, examProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Exam Schedule',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => _showAddExamDialog(context, examProvider),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Exam'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (examProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (examProvider.exams.isEmpty)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No exams scheduled yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: examProvider.exams.length,
                    itemBuilder: (context, index) {
                      final exam = examProvider.exams[index];
                      final isUpcoming = exam.date.isAfter(DateTime.now());
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isUpcoming ? Colors.blue : Colors.grey,
                            child: Icon(
                              isUpcoming ? Icons.upcoming : Icons.history,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            exam.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Subject: ${exam.subject}'),
                              Text('Class: ${exam.className}'),
                              Text('Date: ${DateFormat('MMM d, y').format(exam.date)}'),
                              Text('Total Marks: ${exam.totalMarks}'),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'delete') {
                                _showDeleteConfirmation(context, examProvider, exam);
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
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showAddExamDialog(BuildContext context, ExamProvider examProvider) {
    final nameController = TextEditingController();
    final classController = TextEditingController();
    final subjectController = TextEditingController();
    final totalMarksController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Exam'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Exam Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: classController,
                            decoration: const InputDecoration(
                              labelText: 'Class',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: subjectController,
                            decoration: const InputDecoration(
                              labelText: 'Subject',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: totalMarksController,
                      decoration: const InputDecoration(
                        labelText: 'Total Marks',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
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
                    if (nameController.text.trim().isEmpty ||
                        classController.text.trim().isEmpty ||
                        subjectController.text.trim().isEmpty ||
                        totalMarksController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      await examProvider.addExam(
                        name: nameController.text.trim(),
                        date: selectedDate,
                        className: classController.text.trim(),
                        subject: subjectController.text.trim(),
                        totalMarks: int.parse(totalMarksController.text.trim()),
                      );

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Exam added successfully!'),
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
                  child: const Text('Add Exam'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, ExamProvider examProvider, Exam exam) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Exam'),
          content: Text('Are you sure you want to delete "${exam.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await examProvider.deleteExam(exam.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Exam deleted successfully'),
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

class _EnterMarksTab extends StatefulWidget {
  @override
  State<_EnterMarksTab> createState() => _EnterMarksTabState();
}

class _EnterMarksTabState extends State<_EnterMarksTab> {
  String? _selectedExamId;
  
  @override
  Widget build(BuildContext context) {
    return Consumer2<ExamProvider, StudentProvider>(
      builder: (context, examProvider, studentProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter Student Marks',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Exam:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: _selectedExamId,
                        hint: const Text('Choose an exam'),
                        isExpanded: true,
                        items: examProvider.exams
                            .map((exam) => DropdownMenuItem(
                                  value: exam.id,
                                  child: Text('${exam.name} - ${exam.className} (${exam.subject})'),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedExamId = value;
                          });
                          if (value != null) {
                            examProvider.loadExamResults(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedExamId != null) ...[
                _buildMarksEntrySection(examProvider, studentProvider),
              ] else
                const Expanded(
                  child: Center(
                    child: Text(
                      'Please select an exam to enter marks',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMarksEntrySection(ExamProvider examProvider, StudentProvider studentProvider) {
    final selectedExam = examProvider.exams.firstWhere((exam) => exam.id == _selectedExamId);
    final classStudents = studentProvider.getStudentsByClass(selectedExam.className);
    final existingResults = examProvider.getResultsForExam(_selectedExamId!);
    
    if (classStudents.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            'No students found for this class',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(Icons.assignment, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    '${selectedExam.name} - Total Marks: ${selectedExam.totalMarks}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: classStudents.length,
              itemBuilder: (context, index) {
                final student = classStudents[index];
                final existingResult = existingResults
                    .where((result) => result.studentId == student.id)
                    .toList();
                final currentMarks = existingResult.isNotEmpty 
                    ? existingResult.first.marksObtained.toString() 
                    : '';
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: existingResult.isNotEmpty ? Colors.green : Colors.grey,
                      child: Text(
                        student.rollNo,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    title: Text(
                      student.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Roll: ${student.rollNo} | Section: ${student.section}'),
                    trailing: SizedBox(
                      width: 120,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(text: currentMarks),
                              decoration: const InputDecoration(
                                hintText: 'Marks',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType: TextInputType.number,
                              onSubmitted: (value) {
                                _enterMarks(examProvider, student.id, value, selectedExam.totalMarks);
                              },
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text('/${selectedExam.totalMarks}'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _enterMarks(ExamProvider examProvider, String studentId, String marksText, int totalMarks) {
    try {
      final marks = int.parse(marksText.trim());
      if (marks < 0 || marks > totalMarks) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Marks should be between 0 and $totalMarks'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final grade = _calculateGrade(marks, totalMarks);
      
      examProvider.enterMarks(
        examId: _selectedExamId!,
        studentId: studentId,
        marksObtained: marks,
        grade: grade,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Marks saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid marks'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _calculateGrade(int marks, int totalMarks) {
    final percentage = (marks / totalMarks) * 100;
    if (percentage >= 95) return 'A+';
    if (percentage >= 90) return 'A';
    if (percentage >= 85) return 'B+';
    if (percentage >= 80) return 'B';
    if (percentage >= 75) return 'C+';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }
}

class _ResultsSummaryTab extends StatefulWidget {
  @override
  State<_ResultsSummaryTab> createState() => _ResultsSummaryTabState();
}

class _ResultsSummaryTabState extends State<_ResultsSummaryTab> {
  String? _selectedExamId;
  
  @override
  Widget build(BuildContext context) {
    return Consumer2<ExamProvider, StudentProvider>(
      builder: (context, examProvider, studentProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Results Summary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Exam:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: _selectedExamId,
                        hint: const Text('Choose an exam'),
                        isExpanded: true,
                        items: examProvider.exams
                            .map((exam) => DropdownMenuItem(
                                  value: exam.id,
                                  child: Text('${exam.name} - ${exam.className}'),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedExamId = value;
                          });
                          if (value != null) {
                            examProvider.loadExamResults(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedExamId != null) ...[
                _buildResultsSummary(examProvider, studentProvider),
              ] else
                const Expanded(
                  child: Center(
                    child: Text(
                      'Please select an exam to view results',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultsSummary(ExamProvider examProvider, StudentProvider studentProvider) {
    final selectedExam = examProvider.exams.firstWhere((exam) => exam.id == _selectedExamId);
    final results = examProvider.getResultsForExam(_selectedExamId!);
    final classAverage = examProvider.getClassAverage(_selectedExamId!);
    final gradeDistribution = examProvider.getGradeDistribution(_selectedExamId!);
    
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.groups, color: Colors.blue),
                          const SizedBox(height: 8),
                          Text(
                            results.length.toString(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const Text('Students Appeared'),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.trending_up, color: Colors.green),
                          const SizedBox(height: 8),
                          Text(
                            classAverage.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const Text('Class Average'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Grade Distribution
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Grade Distribution',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: gradeDistribution.entries.map((entry) {
                        return Chip(
                          label: Text('${entry.key}: ${entry.value}'),
                          backgroundColor: _getGradeColor(entry.key),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Individual Results
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Individual Results',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (results.isEmpty)
                      const Center(
                        child: Text(
                          'No results available yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      Column(
                        children: results.map((result) {
                          final student = studentProvider.students
                              .where((s) => s.id == result.studentId)
                              .toList();
                          final studentName = student.isNotEmpty ? student.first.name : 'Unknown';
                          final percentage = result.getPercentage(selectedExam.totalMarks);
                          
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getGradeColor(result.grade ?? 'F'),
                              child: Text(
                                result.grade ?? 'F',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(studentName),
                            subtitle: Text('Marks: ${result.marksObtained}/${selectedExam.totalMarks}'),
                            trailing: Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: percentage >= 60 ? Colors.green : Colors.red,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+': return Colors.green.shade700;
      case 'A': return Colors.green;
      case 'B+': return Colors.lightGreen;
      case 'B': return Colors.lime;
      case 'C+': return Colors.yellow.shade700;
      case 'C': return Colors.orange;
      case 'D': return Colors.deepOrange;
      case 'F': return Colors.red;
      default: return Colors.grey;
    }
  }
}