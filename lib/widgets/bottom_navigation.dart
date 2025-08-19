import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavigation extends StatelessWidget {
  final String currentRoute;

  const BottomNavigation({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _getCurrentIndex(),
      onTap: (index) => _onItemTapped(context, index),
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey[600],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.quiz),
          label: 'Exams',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.psychology),
          label: 'Predictor',
        ),
      ],
    );
  }

  int _getCurrentIndex() {
    switch (currentRoute) {
      case '/':
      case '/home':
        return 0;
      case '/search':
        return 1;
      case '/exams':
        return 2;
      case '/predictor':
        return 3;
      default:
        return 0;
    }
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/exams');
        break;
      case 3:
        context.go('/predictor');
        break;
    }
  }
}