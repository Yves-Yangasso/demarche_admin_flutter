import 'package:flutter/material.dart';

Widget buildStepIndicator({required int currentStep}) {
  return Row(
    children: List.generate(4, (i) {
      final isDone = i < currentStep;
      final isActive = i == currentStep;
      return Expanded(
        child: Row(
          children: [
            isDone || isActive
                ? CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.black,
                    child: isDone
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Text(
                            "${i + 1}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  )
                : CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[300]!, width: 1.5),
                      ),
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      child: Text(
                        "${i + 1}",
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
            if (i < 3)
              Expanded(
                child: Container(
                  height: 2,
                  color: isDone ? Colors.black : Colors.grey[300],
                ),
              ),
          ],
        ),
      );
    }),
  );
}