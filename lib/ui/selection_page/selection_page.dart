import 'package:flutter/material.dart';


class SelectionPage extends StatefulWidget{

  const SelectionPage({super.key, required this.title});

  final String title;

  static Route<void> route(String title) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: '/SelectionPage'),
      builder: (_) => SelectionPage(title: title ),
    );
  }

  @override
  State<SelectionPage> createState() => _SelectionPageState();
  
}

class _SelectionPageState extends State<SelectionPage>{
  
  Widget _buildClickableCard({
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return 
    Card(
      elevation: 5, // Adds a shadow effect
      margin: const EdgeInsets.all(8.0), // Space around the card
      color: color,
      child: InkWell(
        // Makes the entire card clickable
        onTap: onTap,
        splashColor: Colors.white70, // Visual feedback when tapped
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // First line (Title)
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              // Second line (Subtitle/Detail)
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Classes des ${widget.title}'),
        backgroundColor:  Theme.of(context).colorScheme.inversePrimary,
      ),
      // GridView fills the remaining screen space
      body: GridView.count(
        // Creates a 2x2 grid (2 columns)
        crossAxisCount: 2,
        // The children will be equally sized to fill the space
        children: <Widget>[
          // --- Card 1 ---
          _buildClickableCard(
            title: 'Important',
            subtitle: 'Urgent',
            color: const Color.fromARGB(255, 229, 30, 30),
            onTap: () {
              debugPrint('Card 1 Tapped!');
              // Add navigation or action here
            },
          ),
          
          // --- Card 2 ---
          _buildClickableCard(
            title: 'Important',
            subtitle: 'Pas urgent',
            color: const Color.fromARGB(255, 146, 160, 67),
            onTap: () {
              debugPrint('Card 2 Tapped!');
              // Add navigation or action here
            },
          ),
          
          // --- Card 3 ---
          _buildClickableCard(
            title: 'Pas important',
            subtitle: 'Urgent',
            color: Colors.orange.shade600,
            onTap: () {
              debugPrint('Card 3 Tapped!');
              // Add navigation or action here
            },
          ),
          
          // --- Card 4 ---
          _buildClickableCard(
            title: 'Pas important',
            subtitle: 'Pas urgent',
            color: const Color.fromARGB(255, 53, 229, 76),
            onTap: () {
              debugPrint('Card 4 Tapped!');
              // Add navigation or action here
            },
          ),
        ],
      ),
    );
  }
}


