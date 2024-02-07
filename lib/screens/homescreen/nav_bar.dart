import 'package:flutter/material.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:kadu_booking_app/ui_widgets/hexagonalfab/hexagonal_fab.dart';
import 'package:kadu_booking_app/uihelper/uihelper.dart';

class NavBar extends StatelessWidget {
  final int pageIndex;
  final Function(int) onTap;

  const NavBar({
    super.key,
    required this.pageIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 0.0,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.zero,
          width: MediaQuery.of(context).size.width,
          color: const Color(0xFFFFFFFF),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              navItem(
                Icons.home_outlined,
                pageIndex == 0,
                'Home',
                onTap: () => onTap(0),
              ),
              navItem(
                Icons.edit_note,
                pageIndex == 1,
                'Bookings',
                onTap: () => onTap(1),
              ),
              // const SizedBox(width: 80),
              const HexagonalFab(),
              navItem(
                Icons.star_outlined,
                pageIndex == 2,
                'Favorites',
                onTap: () => onTap(2),
              ),
              navItem(
                Icons.menu_outlined,
                pageIndex == 3,
                'Menu',
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget navItem(IconData icon, bool selected, String desc,
      {Function()? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            verticalSpaceRegular,
            Icon(
              icon,
              size: 24,
              color: selected
                  ? AppColors.primaryColorOrange
                  : Colors.black.withOpacity(0.4),
            ),
            Text(
              desc,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
