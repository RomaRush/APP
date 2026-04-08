import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class MentalHealthScreen extends StatefulWidget {
  const MentalHealthScreen({super.key});

  @override
  State<MentalHealthScreen> createState() => _MentalHealthScreenState();
}

class _MentalHealthScreenState extends State<MentalHealthScreen> {
  // Questions list based on the screenshot provided
  // 1. Emotional feeling
  // 2. Predominant mood
  // 3. Calm and safe
  // 4. Concentration
  // 5. Friend or critic
  // 6. Interaction with people
  // 7. Noticed something pleasant
  // 8. Reaction to small problems
  // 9. Emotional feeling (repeat?)
  
  // Storing values for 9 sliders. 
  final List<double> _values = List.filled(9, 3.0); 

  final List<String> _questions = [
    "Как ты в целом чувствуешь себя эмоционально сегодня?",
    "Каким было мое преобладающее настроение сегодня?",
    "Насколько спокойно и безопасно я себя чувствовал?",
    "Насколько легко мне было концентрироваться?",
    "Был ли я сегодня себе другом или критиком?",
    "Было ли мне комфортно взаимодействовать с людьми?",
    "Заметил ли я сегодня что-то приятное?",
    "Как я реагировал на мелкие проблемы и неудачи сегодня?",
    "Как ты в целом чувствуешь себя ментально сегодня?",
  ];

  void _calculateResult() {
    double total = _values.reduce((a, b) => a + b);
    double maxScore = _values.length * 5.0;
    double percentage = total / maxScore;
    
    String res;
    Color color;
    
    if (percentage >= 0.8) {
      res = "Превосходно";
      color = const Color(0xFF00E676);
    } else if (percentage >= 0.6) {
      res = "Хорошо";
      color = Colors.lightGreen;
    } else if (percentage >= 0.4) {
      res = "Нормально";
      color = Colors.orangeAccent;
    } else {
      res = "Нужен отдых";
      color = Colors.redAccent;
    }

    Navigator.pop(context, {'status': res, "color": color});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Здоровье', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
               Color(0xFF2E2414), // Dark Brown/Gold top
               Color(0xFF0D0D15), // Black bottom variant
               Colors.black,
            ],
            stops: [0.0, 0.4, 1.0]
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Gold Flower / Star Icon Placeholder
                // Using an Icon for now, or asset if available. User sent image but I can't extract assets easily.
                // Using a similar Icon.
                const Icon(Icons.spa, color: Color(0xFFD4AF37), size: 100), // Gold color
                
                const SizedBox(height: 20),
                Text(
                  "Этот тест придуман калифорнийскими учеными в 2024 году. Пройдя, вы получите оценку о своем ментальном здоровье",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                ),
                const SizedBox(height: 40),
                
                ...List.generate(_questions.length, (index) {
                  return _buildQuestion(_questions[index], index);
                }),
                
                const SizedBox(height: 40),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _calculateResult,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Отправить результат', style: TextStyle(color: Colors.black, fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion(String question, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
            thumbColor: Colors.white,
            trackHeight: 2.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
            overlayColor: Colors.white.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: _values[index],
            min: 1,
            max: 5,
            divisions: 4,
            onChanged: (val) {
              setState(() {
                _values[index] = val;
              });
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
