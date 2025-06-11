import 'package:flutter/material.dart';
import 'package:movie_app/empMain.dart';

class EmpLogin extends StatefulWidget {
  const EmpLogin({super.key});

  @override
  State<EmpLogin> createState() => _EmpLoginState();
}

class _EmpLoginState extends State<EmpLogin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();

  void _login() {
  if (_formKey.currentState!.validate()) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Welcome, Employee ID: ${_idController.text}')),
    );

    // Delay a bit to show the SnackBar then navigate
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EmpMain()),
      );
    });
  }
}


  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Employee Login'),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Container(
        child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter Your Employee ID',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _idController,
                    decoration: const InputDecoration(
                      labelText: 'Employee ID',
                      prefixIcon: Icon(Icons.badge),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your Employee ID';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Login',style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
            ),
          ),
      )
    );
  }
}