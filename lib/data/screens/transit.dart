import 'package:flutter/material.dart';

class Transit extends StatefulWidget {
  const Transit({super.key});

  @override
  State<Transit> createState() => _TransitState();
}

class _TransitState extends State<Transit> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, String>> inTransit = [
    {
      'title': 'Toyota Corolla',
      'status': 'En Transit',
      'price': '18,000,000 f',
    },
    {'title': 'Honda Civic', 'status': 'En Transit', 'price': '20,000,000 f'},
  ];

  final List<Map<String, String>> inConsumption = [
    {
      'title': 'Ford Focus',
      'status': 'En Consommation',
      'price': '22,000,000 f',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Transits'),
        leading: null,
        backgroundColor: Colors.amber,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'En Transits'), Tab(text: 'En Consommation')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransitList(inTransit),
          _buildTransitList(inConsumption),
        ],
      ),
    );
  }

  Widget _buildTransitList(List<Map<String, String>> transits) {
    if (transits.isEmpty) {
      return const Center(
        child: Text(
          'Aucun transit disponible',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: transits.length,
      itemBuilder: (context, index) {
        final transit = transits[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(transit['title']!),
            subtitle: Text(transit['status']!),
            trailing: Text(
              transit['price']!,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
