import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/college_provider.dart';
import '../widgets/college_card.dart';
import '../widgets/bottom_navigation.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Colleges'),
        centerTitle: true,
      ),
      body: Consumer<CollegeProvider>(
        builder: (context, provider, child) {
          if (provider.favoriteColleges.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add colleges to favorites to see them here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/search'),
                    child: const Text('Explore Colleges'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.favoriteColleges.length,
            itemBuilder: (context, index) {
              final college = provider.favoriteColleges[index];
              return CollegeCard(
                college: college,
                isFavorite: true,
                onTap: () => context.go('/college/${college.id}'),
                onFavoriteToggle: () => provider.toggleFavorite(college),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const BottomNavigation(currentRoute: '/favorites'),
    );
  }
}