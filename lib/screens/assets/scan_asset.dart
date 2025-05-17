import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventpilot/screens/assets/asset_details.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:inventpilot/providers/asset_controller.dart';
import 'package:inventpilot/models/asset.dart';

class ScanAsset extends ConsumerStatefulWidget {
  const ScanAsset({super.key});
  @override
  ConsumerState<ScanAsset> createState() => _ScanAssetState();
}

class _ScanAssetState extends ConsumerState<ScanAsset> {
  bool isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Escanear Activo")),
      body: MobileScanner(
        onDetect: (capture) {
          final code = capture.barcodes.first.rawValue ?? '';
          final assets = ref.read(assetControllerProvider).value;

          if (assets == null) return;

          Asset? foundAsset;
          try {
            foundAsset = assets.firstWhere(
              (a) => a.serial == code || a.barcode == code,
            );
          } catch (_) {
            foundAsset = null;
          }

          if (foundAsset != null && foundAsset.id != null) {
            Navigator.pop(context); // close scanner
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AssetDetails(assetId: foundAsset?.id!),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Activo no registrado")),
            );
          }
        },
      ),
    );
  }
}
