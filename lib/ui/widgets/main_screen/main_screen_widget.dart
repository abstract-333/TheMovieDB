import 'package:flutter/material.dart';
import 'package:themoviedb/domain/factories/screen_factory.dart';
import 'package:themoviedb/domain/services/auth_service.dart';
import 'package:themoviedb/resources/resources.dart';
import 'package:themoviedb/ui/navigation/main_navigation.dart';
import 'package:themoviedb/ui/theme/app_colors.dart';

class MainScreenWidget extends StatefulWidget {
  const MainScreenWidget({Key? key}) : super(key: key);

  @override
  State<MainScreenWidget> createState() => _MainScreenWidgetState();
}

class _MainScreenWidgetState extends State<MainScreenWidget> {
  int _selectedTab = 1;
  final _screnFactory = ScreenFactory();

  void onSelectTab(int index) {
    if (_selectedTab == index) return;
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Padding(
          padding: EdgeInsets.all(50),
          child: Image(
            image: AssetImage(AppImages.sceenImage),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                await AuthService().logout();
                if (!mounted) return;
                MainNavigation.resetNavigation(context);
              },
              icon: const Icon(Icons.logout_rounded))
        ],
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          const Text('News'),
          _screnFactory.makeMovieList(),
          _screnFactory.makeTVShowList(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        currentIndex: _selectedTab,
        showUnselectedLabels: true,
        landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
        selectedIconTheme: const IconThemeData(
          shadows: [
            BoxShadow(
              color: Colors.white,
              blurRadius: 10,
              offset: Offset(2, 4),
            )
          ],
          size: 30,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'News',
            backgroundColor: AppColors.mainDarkBlue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie_filter_outlined),
            label: 'Films',
            backgroundColor: AppColors.mainDarkBlue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tv),
            label: 'Series',
            backgroundColor: AppColors.mainDarkBlue,
          ),
        ],
        onTap: onSelectTab,
      ),
    );
  }
}
