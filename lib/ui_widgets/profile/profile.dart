import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kadu_booking_app/providers/userdetailsprovider.dart';
import 'package:kadu_booking_app/screens/editprofile/edit_profile.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:provider/provider.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  late UserDetailsProvider userDetailsProvider;
  late UserDetails userDetails;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDetailsProvider>(
      builder: (context, userDetailsProvider, child) {
        UserDetails userDetails = userDetailsProvider.userDetails!;
        bool hasFiles = userDetailsProvider.userDetails?.files != null &&
            userDetailsProvider.userDetails!.files?.isNotEmpty == true &&
            userDetailsProvider.userDetails!.files![0].filename != null;
        String baseUrl = '${dotenv.env['API_URL']}';

        return ListTile(
          tileColor: Colors.white,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditProfile(myProfile: 'User'),
              ),
            );
          },
          leading: hasFiles
              ? Image.network(
                  '${baseUrl}/storage/public/uploads/users/${userDetails.socialSecurity}/${userDetails.files![0].filename}',
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  'assets/avatar2.png',
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
          title: Text(
            userDetails.name ?? 'User',
            style: GoogleFonts.poppins(
              color: AppColors.textColorPrimary,
              fontSize: 20,
            ),
          ),
          subtitle: Text(userDetails.email ?? ''),
          trailing: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              color: Colors.white60,
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Icon(
              Icons.navigate_next_rounded,
              color: AppColors.primaryColorOrange,
              size: 40,
            ),
          ),
        );
      },
    );
  }
}
