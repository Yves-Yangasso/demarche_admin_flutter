import 'package:flutter/material.dart';

class QrScannerView extends StatelessWidget {
  const QrScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Scanner un QR Code", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ),
      body: Stack(
        children: [
          // Placeholder for Camera
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      _buildCorner(Alignment.topLeft),
                      _buildCorner(Alignment.topRight),
                      _buildCorner(Alignment.bottomLeft),
                      _buildCorner(Alignment.bottomRight),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  "Placez le QR Code dans le cadre",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
