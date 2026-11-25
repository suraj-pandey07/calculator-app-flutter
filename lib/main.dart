
import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() =>
      _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String display = '0';

  double? firstNumber;
  String? operator;
  bool startNewNumber = false;

  final List<String> buttons = [
    'AC', 'DEL', '%', '÷',
    '7', '8', '9', '×',
    '4', '5', '6', '−',
    '1', '2', '3', '+',
    '00', '0', '.', '=',
  ];

  void buttonPressed(String value) {
    setState(() {
      if (value == 'AC') {
        clearAll();
      } else if (value == 'DEL') {
        deleteLast();
      } else if (value == '=') {
        calculate();
      } else if (['+', '−', '×', '÷', '%'].contains(value)) {
        selectOperator(value);
      } else {
        enterNumber(value);
      }
    });
  }

  void clearAll() {
    display = '0';
    firstNumber = null;
    operator = null;
    startNewNumber = false;
  }

  void deleteLast() {
    if (startNewNumber || display.length == 1) {
      display = '0';
    } else {
      display = display.substring(0, display.length - 1);
    }
  }

  void enterNumber(String value) {
    if (startNewNumber) {
      display = value == '.' ? '0.' : value;
      startNewNumber = false;
      return;
    }

    if (value == '.' && display.contains('.')) return;

    if (display == '0' && value != '.') {
      display = value;
    } else {
      display += value;
    }
  }

  void selectOperator(String value) {
    firstNumber = double.tryParse(display);
    operator = value;
    startNewNumber = true;
  }

  void calculate() {
    if (firstNumber == null || operator == null) return;

    final secondNumber = double.tryParse(display);

    if (secondNumber == null) return;

    double result;

    switch (operator) {
      case '+':
        result = firstNumber! + secondNumber;
        break;

      case '−':
        result = firstNumber! - secondNumber;
        break;

      case '×':
        result = firstNumber! * secondNumber;
        break;

      case '÷':
        if (secondNumber == 0) {
          display = 'Cannot divide by 0';
          firstNumber = null;
          operator = null;
          startNewNumber = true;
          return;
        }
        result = firstNumber! / secondNumber;
        break;

      case '%':
        result = firstNumber! % secondNumber;
        break;

      default:
        return;
    }

    display = result == result.roundToDouble()
        ? result.toInt().toString()
        : result.toStringAsPrecision(8)
            .replaceAll(RegExp(r'0+$'), '')
            .replaceAll(RegExp(r'\.$'), '');

    firstNumber = null;
    operator = null;
    startNewNumber = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  alignment: Alignment.bottomRight,
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),

                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,

                    child: Text(
                      display,
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                flex: 5,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: buttons.length,

                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),

                  itemBuilder: (context, index) {
                    final label = buttons[index];

                    final isOperator = [
                      '+', '−', '×', '÷', '%', '='
                    ].contains(label);

                    final isUtility = ['AC', 'DEL'].contains(label);

                    return FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: isOperator
                            ? Colors.indigo
                            : isUtility
                                ? Colors.blueGrey
                                : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,

                        foregroundColor: isOperator || isUtility
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),

                      onPressed: () => buttonPressed(label),

                      child: Text(
                        label,
                        style: const TextStyle(fontSize: 22),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
