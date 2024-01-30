import 'package:flutter/material.dart';
import 'package:kadu_booking_app/theme/color.dart';
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
    return Container(
      // margin: EdgeInsets.only(
      //   bottom: Platform.isAndroid ? 16 : 0,
      // ),
      child: BottomAppBar(
        elevation: 0.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            // height: 60,
            color: Color(0xFFFFFFFF),
            child: Row(
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
                const SizedBox(width: 80),
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
              style: TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
