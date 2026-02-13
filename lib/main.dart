import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('patientsBox');
  runApp(HistoryApp());
}

class HistoryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'History Application',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PatientsListScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medical_services, size: 100, color: Colors.teal),
            SizedBox(height: 20),
            Text('History Application',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('by Dr Sameh Adel', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class PatientsListScreen extends StatefulWidget {
  @override
  _PatientsListScreenState createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  List<Map<String, dynamic>> patients = [];
  var box = Hive.box('patientsBox');

  @override
  void initState() {
    super.initState();
    List<dynamic>? saved = box.get('patients');
    if (saved != null) {
      patients = saved.cast<Map<String, dynamic>>();
    }
  }

  void savePatients() {
    box.put('patients', patients);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patients'),
        backgroundColor: Colors.teal,
      ),
      body: patients.isEmpty
          ? Center(
              child: Text(
                'No patients yet.\nTap + to add',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: patients.length,
              itemBuilder: (context, index) {
                var p = patients[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(p['name'] ?? 'No Name',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Age: ${p['age'] ?? '-'}'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // يمكن إضافة عرض تفاصيل المريض لاحقاً
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
        onPressed: () async {
          Map<String, dynamic>? newPatient = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddPatientScreen()),
          );
          if (newPatient != null) {
            setState(() {
              patients.add(newPatient);
            });
            savePatients();
          }
        },
      ),
    );
  }
}

class AddPatientScreen extends StatefulWidget {
  @override
  _AddPatientScreenState createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  Map<String, bool> checkboxes = {
    'Medical History': false,
    'Dental History': false,
    'Extra Oral': false,
    'Intra Oral': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Patient'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Patient Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: ageController,
                decoration: InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 24),
              Text(
                'Medical History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ...checkboxes.keys.map((key) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  child: CheckboxListTile(
                    title: Text(key),
                    value: checkboxes[key],
                    activeColor: Colors.teal,
                    onChanged: (val) {
                      setState(() {
                        checkboxes[key] = val!;
                      });
                    },
                  ),
                );
              }).toList(),
              SizedBox(height: 24),
              ElevatedButton(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Save Patient', style: TextStyle(fontSize: 18)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    Navigator.pop(context, {
                      'name': nameController.text,
                      'age': ageController.text,
                      'history': checkboxes,
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter patient name')),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
