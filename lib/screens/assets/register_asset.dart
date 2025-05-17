import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:inventpilot/models/asset.dart';
import 'package:inventpilot/providers/asset_controller.dart';

class RegisterAsset extends ConsumerStatefulWidget {
  const RegisterAsset({super.key});

  @override
  ConsumerState<RegisterAsset> createState() => _RegisterAssetState();
}

class _RegisterAssetState extends ConsumerState<RegisterAsset> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  // final _typeCtrl = TextEditingController();
  final _serialCtrl = TextEditingController();
  String? selectedType;

  String _barcode = '';
  String? _imagePath;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _imagePath = picked.path;
      });
    }
  }

  void _scanBarcode() {
    bool isScanned = false;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => Scaffold(
              appBar: AppBar(title: const Text("Escanear codigo de barras")),
              body: MobileScanner(
                onDetect: (capture) {
                  if (isScanned) return; // prevent double trigger

                  final code = capture.barcodes.first.rawValue ?? '';
                  setState(() {
                    _barcode = code;
                    _serialCtrl.text = code; // autofill serial field
                    isScanned = true;
                  });

                  // Delay slightly before closing scanner
                  Future.delayed(const Duration(milliseconds: 300), () {
                    Navigator.pop(context);
                  });
                },
              ),
            ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final asset = Asset(
        name: _nameCtrl.text,
        type: selectedType ?? '',
        serial: _serialCtrl.text,
        barcode: _barcode,
        imagePath: _imagePath ?? '',
      );
      ref.read(assetControllerProvider.notifier).addAsset(asset);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activo registrado exitosamente')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Activo")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Nombre de Activo",
                ),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Tipo de Activo'),
                items: const [
                  DropdownMenuItem(value: 'Monitor', child: Text('Monitor')),
                  DropdownMenuItem(value: 'CPU', child: Text('CPU')),
                  DropdownMenuItem(value: 'Laptop', child: Text('Laptop')),
                  DropdownMenuItem(value: 'Teclado', child: Text('Teclado')),
                  DropdownMenuItem(
                    value: 'Auriculares',
                    child: Text('Auriculares'),
                  ),
                  DropdownMenuItem(value: 'Mouse', child: Text('Mouse')),
                  DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedType = value;
                  });
                },
                validator:
                    (value) =>
                        value == null
                            ? 'Por favor selecciona un tipo de activo'
                            : null,
              ),
              TextFormField(
                controller: _serialCtrl,
                readOnly: true,
                decoration: const InputDecoration(labelText: "Numero de Serie"),
                validator:
                    (v) =>
                        v == null || v.trim().isEmpty
                            ? 'Debe escanear un código'
                            : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _scanBarcode,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text("Escanear Codigo de Barras"),
                  ),
                  const SizedBox(width: 10),
                  if (_barcode.isNotEmpty)
                    Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Tomar foto"),
                  ),
                  const SizedBox(width: 10),
                  if (_imagePath != null)
                    Image.file(
                      File(_imagePath!),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text("Registrar Activo"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
