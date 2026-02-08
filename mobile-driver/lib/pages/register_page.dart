import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/register_driver_request.dart';
import '../services/auth_service.dart';
import '../component/custom_button.dart';
import '../component/custom_text_field.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _vehiclePlateController = TextEditingController();
  final _ktpNumberController = TextEditingController();
  final _simNumberController = TextEditingController();

  File? _ktpImage;
  File? _simImage;

  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _pickImage(bool isKtp) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (isKtp) {
          _ktpImage = File(pickedFile.path);
        } else {
          _simImage = File(pickedFile.path);
        }
      });
    }
  }

  void _register() async {
    if (_ktpImage == null || _simImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload both KTP and SIM photos")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final request = RegisterDriverRequest(
      name: _nameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      password: _passwordController.text,
      vehicleType: _vehicleTypeController.text,
      vehiclePlate: _vehiclePlateController.text,
      ktpNumber: _ktpNumberController.text,
      simNumber: _simNumberController.text,
      ktpImage: _ktpImage!,
      simImage: _simImage!,
    );

    final success = await _authService.register(request);

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context); // Go back to Login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Registration"),
        backgroundColor: const Color(0xFF00BFFF),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Icon(
                Icons.drive_eta_rounded,
                size: 60,
                color: Color(0xFF87CEEB),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: "Full Name",
                icon: Icons.person,
                controller: _nameController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: "Phone Number",
                icon: Icons.phone,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: "Email",
                icon: Icons.email,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: "Password",
                icon: Icons.lock,
                controller: _passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _vehicleTypeController.text.isEmpty
                    ? null
                    : _vehicleTypeController.text,
                decoration: const InputDecoration(
                  labelText: "Vehicle Type",
                  prefixIcon: Icon(Icons.motorcycle),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "MOTOR", child: Text("MOTOR")),
                  DropdownMenuItem(value: "CAR", child: Text("CAR")),
                ],
                onChanged: (value) {
                  setState(() {
                    _vehicleTypeController.text = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: "Vehicle Plate Number",
                icon: Icons.confirmation_number,
                controller: _vehiclePlateController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: "KTP Number",
                icon: Icons.badge,
                controller: _ktpNumberController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: "SIM Number",
                icon: Icons.card_membership,
                controller: _simNumberController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text("KTP Photo"),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _pickImage(true),
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _ktpImage != null
                                ? Image.file(_ktpImage!, fit: BoxFit.cover)
                                : const Center(child: Icon(Icons.add_a_photo)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        const Text("SIM Photo"),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _pickImage(false),
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _simImage != null
                                ? Image.file(_simImage!, fit: BoxFit.cover)
                                : const Center(child: Icon(Icons.add_a_photo)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: "REGISTER",
                onPressed: _register,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
