// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kadu_booking_app/models/file_model.dart';
import 'package:kadu_booking_app/models/property_model.dart';
import 'package:kadu_booking_app/providers/userdetailsprovider.dart';
import 'package:kadu_booking_app/screens/homescreen/locationsearch.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:kadu_booking_app/uihelper/uihelper.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TokenResponse {
  final String? token;

  TokenResponse({this.token});

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      token: json['token'],
    );
  }
}

class EditProfile extends StatefulWidget {
  final String myProfile;

  const EditProfile({super.key, required this.myProfile});
  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  String nameControl = '';
  String addressControl = '';
  String emailControl = '';
  String phoneControl = '';

  late UserDetailsProvider userDetailsProvider;
  late UserDetails userDetails;

  late ImagePicker _imagePicker;
  File? _pickedImage;

  Future<void> updateProfile() async {
    // String newName = nameController.text;
    // String newEmail = emailController.text;
    // String newPhone = phoneController.text;
    // String newAddress = addressController.text;

    String? newName = (nameControl != '') ? nameControl : userDetails.name;
    String? newEmail = (emailControl != '') ? emailControl : userDetails.email;
    String? newPhone = (phoneControl != '')
        ? phoneControl
        : (userDetails.phone != null ? userDetails.phone.toString() : '');
    String? newAddress =
        (addressControl != '') ? addressControl : userDetails.address;

    if (newName != userDetails.name ||
        newEmail != userDetails.email ||
        newPhone != (userDetails.phone?.toString() ?? '') ||
        newAddress != userDetails.address) {
      Map<String, dynamic> requestBody = {
        "name": newName,
        "email": newEmail,
        "phone": newPhone,
        "address": newAddress,
      };
      var _getToken = await getToken();
      var token = _getToken.token;
      try {
        final response = await http.post(
          Uri.parse('${dotenv.env['API_URL']}/api/user/update'),
          body: json.encode(requestBody),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${token}',
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            userDetails = UserDetails(
              socialSecurity: userDetails.socialSecurity,
              name: newName,
              email: newEmail,
              phone: int.tryParse(newPhone),
              address: newAddress,
              roleId: userDetails.roleId,
              isVerified: userDetails.isVerified,
              isActive: userDetails.isActive,
              emailVerifiedAt: userDetails.emailVerifiedAt,
              createdAt: userDetails.createdAt,
              updatedAt: userDetails.updatedAt,
              favoriteProperties: userDetails.favoriteProperties,
            );
          });
          userDetailsProvider.setUserDetails(userDetails);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to update profile. Status code: ${response.statusCode}',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (error) {
        print("Error during profile update: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error during profile update'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<TokenResponse> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String tokenString = prefs.getString('token') ?? '';
    final Map<String, dynamic> tokenMap = json.decode(tokenString);
    final TokenResponse tokenResponse = TokenResponse.fromJson(tokenMap);
    return tokenResponse;
  }

  void initializeControllers() {
    nameController.text = userDetails.name ?? '';
    emailController.text = userDetails.email ?? '';
    phoneController.text = userDetails.phone?.toString() ?? '';
    addressController.text = userDetails.address ?? '';
  }

  @override
  void initState() {
    super.initState();
    userDetailsProvider =
        Provider.of<UserDetailsProvider>(context, listen: false);
    userDetails = userDetailsProvider.userDetails!;
    _imagePicker = ImagePicker();
    initializeControllers();
  }

  Future<void> pickImage() async {
    final pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _pickedImage = File(pickedImage.path);
      });
      await uploadImageToServer();
    }
  }

  Future<void> uploadImageToServer() async {
    try {
      var client = http.Client();
      var url = Uri.parse('${dotenv.env['API_URL']}/api/uploadUser');

      var request = http.MultipartRequest('POST', url);
      request.fields['user_id'] = userDetails.socialSecurity.toString();
      if (_pickedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', _pickedImage!.path),
        );
      }

      var response = await client.send(request);

      if (response.statusCode == 200) {
        await getUserData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image uploaded successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error uploading image'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      client.close();
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error uploading image",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> getUserData() async {
    try {
      var _getToken = await getToken();
      var token = _getToken.token;
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/api/userDetails'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token}',
        },
      );
      if (response.statusCode == 200) {
        var userDetailsJson = jsonDecode(response.body);

        List<FileModel>? files = userDetailsProvider.files; // Correct syntax

        if (userDetailsJson['files'] != null &&
            userDetailsJson['files'] is List) {
          files = (userDetailsJson['files'] as List)
              .map((fileItem) => FileModel.fromJson(fileItem))
              .toList();
        }
        var userDetails = UserDetails(
          socialSecurity: userDetailsJson['user']['social_security'],
          name: userDetailsJson['user']['name'],
          email: userDetailsJson['user']['email'],
          phone: userDetailsJson['user']['phone'],
          roleId: userDetailsJson['user']['role_id'],
          isVerified:
              userDetailsJson['user']['is_verified'] == 1 ? true : false,
          isActive: userDetailsJson['user']['is_active'] == 1 ? true : false,
          emailVerifiedAt: userDetailsJson['user']['email_verified_at'],
          address: userDetailsJson['user']['address'],
          createdAt: userDetailsJson['user']['created_at'],
          updatedAt: userDetailsJson['user']['updated_at'],
          files: files,
        );
        userDetailsProvider.setUserDetails(userDetails);

        PaintingBinding.instance?.imageCache?.clear();
        PaintingBinding.instance?.imageCache?.clearLiveImages();

        // Show success SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User details fetched successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print(
            'Failed to fetch user details after image upload. Status code: ${response.statusCode}');

        // Show error SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to fetch user details. Status code: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print('Error fetching user details after image upload: $error');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Error fetching user details. Check your internet connection.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String baseUrl = '${dotenv.env['API_URL']}';

    return Consumer<UserDetailsProvider>(
        builder: (context, userDetailsProvider, child) {
      userDetails = userDetailsProvider.userDetails!;
      initializeControllers();
      return SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          color: AppColors.backgroundColorDefault,
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(children: <Widget>[
              AppBar(
                backgroundColor: Colors.white,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 25,
                    color: AppColors.primaryColorOrange,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  widget.myProfile,
                  style: GoogleFonts.poppins(
                      fontSize: 25, color: AppColors.textColorPrimary),
                ),
              ),
              verticalSpaceLarge,
              Align(
                child: GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    width: 50 * 2,
                    height: 50 * 2,
                    child: ClipOval(
                      child: _pickedImage != null
                          ? Image.file(
                              _pickedImage!,
                              width: 30 * 2,
                              height: 30 * 2,
                              fit: BoxFit.cover,
                            )
                          : userDetailsProvider.userDetails?.files != null &&
                                  userDetailsProvider
                                      .userDetails!.files!.isNotEmpty &&
                                  userDetailsProvider
                                          .userDetails!.files![0].filename !=
                                      null
                              ? Image.network(
                                  '${baseUrl}/storage/public/uploads/users/${userDetailsProvider.userDetails!.socialSecurity}/${userDetailsProvider.userDetails!.files![0].filename}',
                                  width: 30 * 2,
                                  height: 30 * 2,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/avatar2.png',
                                  width: 30 * 2,
                                  height: 30 * 2,
                                  fit: BoxFit.cover,
                                ),
                    ),
                  ),
                ),
              ),
              ProfileTextfield(
                label: 'Name',
                hintText: userDetails.name ?? '',
                initialValue: 'User',
                onChanged: (value) {
                  nameController.value = nameController.value.copyWith(
                    text: value,
                  );
                  nameControl = value;
                },
              ),
              verticalSpaceRegular,
              ProfileTextfield(
                label: 'Email Address',
                hintText: userDetails.email ?? '',
                initialValue: 'User',
                onChanged: (value) {
                  emailControl = value;
                },
              ),
              verticalSpaceRegular,
              ProfileTextfield(
                label: 'Phone Number',
                hintText: userDetails.phone?.toString() ?? '',
                initialValue: 'User',
                onChanged: (value) {
                  phoneController.text = value;
                  phoneControl = value;
                },
              ),
              verticalSpaceRegular,
              ProfileTextfield(
                label: 'Address',
                hintText:
                    userDetailsProvider.getUserAddress() ?? "Select Location",
                initialValue: 'User',
                isEnabled: false,
                onChanged: (value) {
                  addressController.text = value;
                  addressControl = value;
                },
              ),
              verticalSpaceRegular,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 50,
                        width: 250,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          'Select Location',
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              decoration: TextDecoration.none,
                              color: Colors.grey),
                        ),
                      ),
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: MaterialButton(
                            height: 30,
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return const SearchPlacesScreen();
                              }));
                            },
                            child: const Icon(
                              Icons.location_searching,
                              color: Colors.green,
                              size: 25,
                            ),
                          )),
                    ]),
              ),
              verticalSpaceRegular,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                    'This location will enable new section in home for nearby properties',
                    style: GoogleFonts.poppins(
                        color: AppColors.textColorPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none)),
              ),
              verticalSpaceRegular,
              SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: Container(
                    height: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.orange),
                      ),
                      onPressed: () async {
                        await updateProfile();
                      },
                      child: Text(
                        "Update Profile",
                        style: GoogleFonts.poppins(
                          fontSize: 25,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )),
              verticalSpaceLarge,
              verticalSpaceLarge,
              verticalSpaceLarge,
            ]),
          ),
        ),
      );
    });
  }
}

class ProfileTextfield extends StatefulWidget {
  final String label;
  final String hintText;
  final String initialValue;
  final TextEditingController? controller; // Updated to be non-nullable
  final Function(String) onChanged;
  final bool isEnabled;

  ProfileTextfield({
    required this.label,
    required this.hintText,
    required this.initialValue,
    this.controller, // Updated to be non-nullable
    required this.onChanged,
    this.isEnabled = true,
  });

  @override
  State<ProfileTextfield> createState() => _ProfileTextfieldState();
}

class _ProfileTextfieldState extends State<ProfileTextfield> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                color: AppColors.textColorPrimary,
                decoration: TextDecoration.none,
                fontSize: 15),
          ),
          verticalSpaceSmall,
          Material(
            color: Colors.white,
            child: TextField(
              controller: widget.controller, // Use the provided controller
              enabled: widget.isEnabled,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                hintStyle:
                    GoogleFonts.poppins(fontSize: 15, color: Colors.grey),
                hintText: widget.hintText,
              ),
              onChanged: widget.onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
