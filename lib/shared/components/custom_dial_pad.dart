import 'package:flutter/material.dart';

class CustomDialPad extends StatelessWidget {
  final Function(String) onDigitPressed;
  final VoidCallback onBackspacePressed;
  final bool isDarkMode;
  final TextEditingController amountController;
  final bool isFieldNotEmpty;

  const CustomDialPad({
    Key? key,
    required this.onDigitPressed,
    required this.onBackspacePressed,
    required this.amountController,
    required this.isDarkMode,
    required this.isFieldNotEmpty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonColor =
        isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0);
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Amount Display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Send Amount       Rs",
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? const Color(0xFFE0E0E0) : Colors.black,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: TextField(
                    controller: amountController,
                    readOnly: true,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: "00.00",
                      hintStyle: const TextStyle(color: Colors.grey),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: isFieldNotEmpty ? Colors.green : Colors.grey,
                          width: 2,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: isFieldNotEmpty ? Colors.green : Colors.grey,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dial Pad
            for (var row in [
              ['1', '2', '3'],
              ['4', '5', '6'],
              ['7', '8', '9'],
              ['.', '0', 'X']
            ])
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row.map((label) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        if (label == "X") {
                          onBackspacePressed();
                        } else {
                          onDigitPressed(label);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: MediaQuery.of(context).size.width * 0.22,
                        height: 60,
                        margin: const EdgeInsets.all(6),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: label == "X" ? Colors.redAccent : buttonColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode
                                  ? Colors.black.withOpacity(0.5)
                                  : Colors.grey.withOpacity(0.3),
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: label == "X"
                            ? const Icon(Icons.backspace,
                                color: Colors.white, size: 22)
                            : Text(label,
                                style:
                                    TextStyle(color: textColor, fontSize: 24)),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
