import 'dart:io';

import 'package:flutter/material.dart';

class FilterTile extends StatelessWidget {
  final String name;
  final File imageFile;
  final ColorFilter filter;
  final bool isSelected;

  const FilterTile({
    super.key,
    required this.name,
    required this.imageFile,
    required this.filter,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.purple : Colors.transparent,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),

      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ColorFiltered(
              colorFilter: filter,
              child: Image.file(
                imageFile,
                height: 85,
                width: 85,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade900.withValues(alpha: 0.5), // Shadow color with opacity
                    spreadRadius: 10,
                    blurRadius: 12,
                    offset: Offset(0, 50), // X and Y offset of the shadow
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: 80,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      // color: isSelected ? Colors.purple : Colors.grey,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
