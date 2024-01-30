// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kadu_booking_app/api/api_repository.dart';
import 'package:kadu_booking_app/models/file_model.dart';
import 'package:kadu_booking_app/providers/userdetailsprovider.dart';
import 'package:kadu_booking_app/screens/otp/phone_otp.dart';
import 'package:kadu_booking_app/screens/signin/signin_phonde.dart';
import 'package:kadu_booking_app/screens/signup/signup_options.dart';
import 'package:kadu_booking_app/services/phone_login_handler.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kadu_booking_app/screens/custombtn/custombtn.dart';
import 'package:kadu_booking_app/screens/homescreen/main_screen.dart';
import 'package:kadu_booking_app/screens/verification/under_verification.dart';
import 'package:kadu_booking_app/services/phonepermissions/phone_permission_handler.dart';
import 'package:kadu_booking_app/services/resetpassword/reset_password.dart';
import 'package:kadu_booking_app/services/sharedpreferences/remember_me_manager.dart';
import 'package:kadu_booking_app/services/smspermissions/sms_permisssion_handler.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:kadu_booking_app/uihelper/uihelper.dart';
import 'package:http/http.dart' as http;

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool isObsecure = true;
  bool rememberMe = false;
  bool _loginTypePhone = false;
  bool _isImageLoaded = false;

  // late final ApiRepository apiRepository;

  final PhoneLoginHandler _phoneLoginHandler = PhoneLoginHandler();

  final PhonePermissionHandler _phonePermissionHandler =
      PhonePermissionHandler();
  final SmsPermissionHandler _smsPermissionHandler = SmsPermissionHandler();

  final RememberMeManager _rememberMeManager = RememberMeManager();
  Uint8List? loginImage;

  final AuthServices _authServices = AuthServices();

  void _handleForgottenPassword(BuildContext context) async {
    var email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    bool confirmed = await _showConfirmationDialog(context);

    if (confirmed) {
      var forgotPasswordData = {'email': email};

      try {
        var apiUrl = '${dotenv.env['API_URL']}/api/send-temporary-password';
        var response = await http.post(
          Uri.parse(apiUrl),
          body: forgotPasswordData,
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset email sent successfully'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to initiate password reset'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (error) {
        debugPrint('Error: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirmation'),
              content: Text('Are you sure you want to reset your password?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text('Confirm'),
                ),
              ],
            );
          },
        ) ??
        false; // Return false if the user cancels the dialog
  }

  void _handleSignIn(BuildContext context) async {
    var network = Network();
    var loginData = {
      'identifier': emailController.text,
      'password': passwordController.text,
    };
    var response = await network.authData(loginData, 'login');

    if (response.statusCode == 200) {
      var userDetailsResponse = await network.getData('userDetails');
      var userDetailsJson = jsonDecode(userDetailsResponse.body);

      if (userDetailsResponse.statusCode == 200) {
        var userDetailsJson = jsonDecode(userDetailsResponse.body);

        var userDetailsProvider = context.read<UserDetailsProvider>();
        List<FileModel>? files = userDetailsProvider.files; // Correct syntax

        if (userDetailsJson['files'] != null) {
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
        await network.getAndSendFCMTokenToServer();
        if (userDetails.isVerified) {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const VerificationScreen()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to fetch user details'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      print('Login failed!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startPhoneLogin(BuildContext context) async {
    String phoneNumber = phoneNumberController.text;
    String? error = await _phoneLoginHandler.initiatePhoneLogin(phoneNumber);

    if (error == null) {
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhoneOtp(
            verificationId: '1234',
            phoneNo: phoneNumber,
          ),
        ),
      );
    } else {
      // Handle login initiation failure
      print("Error: $error");
    }
  }

  bool isEmailOrPhoneNumber(String input) {
    // Check if the input is a valid email
    bool isEmail =
        RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(input);

    if (isEmail) {
      setState(() {
        _loginTypePhone = false;
        print("Email type login $_loginTypePhone");
      });
      // _loginTypePhone = false;
      return true;
    }

    // Check if the input is a valid phone number
    bool isPhoneNumber = RegExp(r"^\d{10}$").hasMatch(input);
    if (isPhoneNumber) {
      setState(() {
        _loginTypePhone = true;
        print("phone typ elogin $_loginTypePhone");
      });
      return true;
    }
    return false;
  }

  validateEmail(value) {
    if (value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  validatePassWord(value) {
    if (value == null || value.isEmpty) {
      return 'Please enter valid Password';
    }
    if (value.length < 8) {
      return 'Minimum 8 characters are required';
    }
    return null;
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _smsPermissionHandler.checkSmsPermissionOnInit(context);
    _loadRememberMe();
    // _getImage();
  }

  void _loadRememberMe() async {
    Map<String, dynamic> rememberMeData =
        await RememberMeManager.loadRememberMe();

    setState(() {
      rememberMe = rememberMeData['rememberMe'];
      emailController.text = rememberMeData['email'];
      passwordController.text = rememberMeData['password'];
    });
  }

  void _saveRememberMe() async {
    await RememberMeManager.saveRememberMe(
        rememberMe!, emailController.text, passwordController.text);
  }

  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColorDefault,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                verticalSpaceLarge,
                Column(
                  children: <Widget>[
                    Container(
                      child: Text(
                        "Login",
                        style: GoogleFonts.poppins(
                          fontSize: 40,
                          color: AppColors.textColorPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Text(
                      "By Signing in you are agreeing to our",
                      style:
                          GoogleFonts.poppins(fontSize: 15, color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Terms and Privacy Policay',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            color: AppColors.textColorPrimary),
                      ),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                verticalSpaceRegular,
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          width: width * .9,
                          child: TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              hintText: "Email",
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {},
                          ),
                        ),
                        SizedBox(height: height * .02),
                        Container(
                            width: width * .9,
                            child: TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              enabled: !_loginTypePhone,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                hintText: "Password",
                                suffixIcon: const Icon(Icons.lock_outline),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter valid password';
                                } else {
                                  return null;
                                }
                              },
                            )),
                        SizedBox(height: height * .01),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        rememberMe = value!;
                                        print(value);
                                      });
                                    },
                                  ),
                                  const Text(
                                    "Remember me",
                                    style: TextStyle(
                                        color: AppColors.textColorPrimary,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  _handleForgottenPassword(context);
                                },
                                child: const Text(
                                  "Forgotten password?",
                                  style: TextStyle(
                                      color: AppColors.textColorPrimary,
                                      fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
                SizedBox(height: height * .01),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    width: 320,
                    child: MaterialButton(
                      minWidth: double.infinity,
                      height: 45,
                      onPressed: () async {
                        _handleSignIn(context);

                        // if (_formKey.currentState!.validate()) {
                        // _handleSignIn(context);

                        // RegisteredUser? currentUser = await handleLogin(
                        //         emailController.text, passwordController.text)
                        //     .then((value) {
                        //   if (value != null && value.is_verified == true) {
                        //     Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //             builder: (context) => MainScreen()));
                        //   } else if (value != null &&
                        //       value.is_verified == false) {
                        //     Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //             builder: (context) =>
                        //                 VerificationScreen()));
                        //   }
                        // });
                        // }
                      },
                      color: AppColors.primaryColorOrange,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        "Login",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                verticalSpaceRegular,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    width: 320,
                    child: MaterialButton(
                      minWidth: double.infinity,
                      height: 45,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignInWithPhone()));
                      },
                      color: AppColors.primaryColorOrange,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        "Login With Phone",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                verticalSpaceSmall,
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) => const SignUpOptions()),
                    );
                  },
                  child: CustomBtn(
                    width: width * .9,
                    text: "Create Account",
                    btnColor: AppColors.color,
                    btnTextColor: Colors.black,
                  ),
                ),
                verticalSpaceSmall,
                Container(
                  height: 250,
                  width: width,
                  child:
                      Image.asset('assets/login_image.png', fit: BoxFit.fill),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ImageLoadingWidget extends StatelessWidget {
  final VoidCallback onImageLoaded;

  ImageLoadingWidget({required this.onImageLoaded});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      '${dotenv.env['API_URL']}/storage/public/uploads/chandelier.jpeg',
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          // Image has loaded successfully
          // Trigger the callback to notify the parent that the image is loaded
          onImageLoaded();
          return child;
        } else {
          // Image is still loading
          return Center(
            child: CircularProgressIndicator(
              color: Colors.black,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
            ),
          );
        }
      },
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
        print('Error loading image: $error');
        return const Center(
          child: Icon(
            Icons.error,
            color: Colors.red,
          ),
        );
      },
    );
  }
}
