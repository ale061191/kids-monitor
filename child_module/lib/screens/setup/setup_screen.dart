import 'package:flutter/material.dart';

import 'consent_screen.dart';
import 'permissions_screen.dart';
import 'registration_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int _currentStep = 0;

  final List<String> _stepTitles = [
    'Consentimiento',
    'Permisos',
    'Registro',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración inicial'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: _buildCurrentStep(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(_stepTitles.length, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted || isActive
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade300,
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.check, color: Colors.white)
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: isActive
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _stepTitles[index],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isActive
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.shade600,
                              fontWeight:
                                  isActive ? FontWeight.bold : FontWeight.normal,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (index < _stepTitles.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                      margin: const EdgeInsets.only(bottom: 32),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return ConsentScreen(
          onAccept: () {
            setState(() {
              _currentStep = 1;
            });
          },
        );
      case 1:
        return PermissionsScreen(
          onContinue: () {
            setState(() {
              _currentStep = 2;
            });
          },
        );
      case 2:
        return RegistrationScreen(
          onComplete: () {
            Navigator.of(context).pushReplacementNamed('/home');
          },
        );
      default:
        return const SizedBox();
    }
  }
}

