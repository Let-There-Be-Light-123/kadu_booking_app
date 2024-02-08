import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kadu_booking_app/providers/userdetailsprovider.dart';
import 'package:kadu_booking_app/screens/booking_status.dart/booking_status_pdf_helper.dart';
import 'package:kadu_booking_app/screens/propertydetails/property_detail_page.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:kadu_booking_app/ui_widgets/bulletpoints/bullet_points.dart';
import 'package:kadu_booking_app/ui_widgets/review/review_form.dart';
import 'package:kadu_booking_app/uihelper/uihelper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class BookingStatus extends StatefulWidget {
  final Map<String, dynamic> bookingData;
  final String imageUrl;
  const BookingStatus({
    Key? key,
    required this.bookingData,
    required this.imageUrl,
  }) : super(key: key);

  @override
  State<BookingStatus> createState() => _BookingStatusState();
}

class _BookingStatusState extends State<BookingStatus> {
  late UserDetailsProvider userDetailsProvider;
  late UserDetails userDetails;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final _screenshotController = ScreenshotController();
  final PdfGenerator pdfGenerator = PdfGenerator();

  @override
  void initState() {
    UserDetailsProvider userDetailsProvider =
        Provider.of<UserDetailsProvider>(context, listen: false);
    userDetails = userDetailsProvider.userDetails!;
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          defaultColor: const Color(0xFF9D50DD),
          importance: NotificationImportance.High,
          channelShowBadge: true,
          channelDescription: 'Download',
        ),
      ],
    );
    debugPrint('Booking Data: ${widget.bookingData}');
  }

  Future<void> generateAndSavePDF(
    String bookingStatus,
    String bookingReference,
    String formattedCheckInDate,
    String formattedCheckOutDate,
    int daysDifference,
    String numberOfGuests,
    UserDetails userDetails,
  ) async {
    try {
      await requestNotificationPermissions();

      final pdf = pw.Document();
      final theme = pw.ThemeData.withFont();

      pdf.addPage(
        pw.Page(
          theme: theme,
          build: (pw.Context context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Booking Details',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Booking Status: ${bookingStatus.isNotEmpty ? bookingStatus : "Unknown"}',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Booking ID - $bookingReference',
                    style: const pw.TextStyle(fontSize: 16),
                  ),
                  pw.SizedBox(height: 20),
                  if (bookingStatus == 'booked')
                    pw.Text(
                      'Your booking is confirmed!',
                      style: const pw.TextStyle(fontSize: 16),
                    )
                  else if (bookingStatus == 'pending verification')
                    pw.Text(
                      'Your booking is pending confirmation.',
                      style: const pw.TextStyle(fontSize: 16),
                    )
                  else
                    pw.Text(
                      'Unknown booking status.',
                      style: const pw.TextStyle(fontSize: 16),
                    ),
                  pw.SizedBox(height: 20),
                  pw.Container(
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(10),
                          color: PdfColor.fromHex('#E0E0E0'),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Check In',
                                style: const pw.TextStyle(fontSize: 12),
                              ),
                              pw.Text(
                                formattedCheckInDate,
                                style: const pw.TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(10),
                          color: PdfColor.fromHex('#E0E0E0'),
                          child: pw.Text(
                            '$daysDifference Nights',
                            style: const pw.TextStyle(fontSize: 16),
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(10),
                          color: PdfColor.fromHex('#E0E0E0'),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text(
                                'Check Out',
                                style: const pw.TextStyle(fontSize: 12),
                              ),
                              pw.Text(
                                formattedCheckOutDate,
                                style: const pw.TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    '1 Room for $numberOfGuests Adults',
                    style: const pw.TextStyle(fontSize: 16),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Primary Guest: ${userDetails.name}',
                    style: const pw.TextStyle(fontSize: 16),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(20),
                      color: PdfColor.fromHex('#FFFFFF'),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Important Information',
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Divider(color: PdfColor.fromHex('#B0B0B0')),
                        pw.SizedBox(height: 10),
                        pw.Bullet(
                          text:
                              'Please provide valid documents during check-in.',
                          style: const pw.TextStyle(fontSize: 16),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Bullet(
                          text:
                              'For accommodation queries, please contact the administrator.',
                          style: const pw.TextStyle(fontSize: 16),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Bullet(
                          text: 'For emergencies, contact 926-269-5628.',
                          style: const pw.TextStyle(fontSize: 16),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Bullet(
                          text: 'Feel free to donate for the cause.',
                          style: const pw.TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
      final directory = await getDownloadsDirectory();
      final path = '${directory!.path}/$bookingReference/booking_details.pdf';

      final file = File(path);

      updateNotificationProgress(0, 1); // Initial progress

      await file.writeAsBytes(await pdf.save());

      updateNotificationProgress(1, 1); // Final progress

      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 0,
          channelKey: 'basic_channel',
          title: 'Download complete!',
          body: 'PDF downloaded successfully in $path',
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'open_file',
            label: 'Open File',
          ),
        ],
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error generating PDF: $e',
        toastLength: Toast.LENGTH_LONG, // Adjust as needed
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> requestNotificationPermissions() async {
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.notification,
    ].request();
    statuses.forEach((permission, status) {
      if (!status.isGranted) {
        Fluttertoast.showToast(
          msg: 'Permission ${permission.toString()} is required.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    });
  }

  Future<void> updateNotificationProgress(int progress, int total) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: 'basic_channel',
        title: 'Downloading PDF...',
        body: '$progress/$total pages downloaded',
        notificationLayout: NotificationLayout.ProgressBar,
        progress: progress,
      ),
    );
  }

  String formatDate(String inputDate) {
    DateTime dateTime = DateTime.parse(inputDate);
    String formattedDate = DateFormat('E, dd MMM yyyy').format(dateTime);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> bookingData = widget.bookingData;

    final String bookingReference = bookingData['booking_reference'] ?? '';
    final String bookingStatus = bookingData['status'] ?? '';
    final List<dynamic> roomDetails =
        bookingData['room_details'] ?? <Map<String, dynamic>>[];
    final String propertyName = roomDetails.isNotEmpty
        ? roomDetails[0]['property_details']['property_name'] ?? ''
        : '';
    final String propertyId = roomDetails.isNotEmpty
        ? roomDetails[0]['property_details']['property_id'] ?? ''
        : '';

    final String propertyAddress = roomDetails.isNotEmpty
        ? roomDetails[0]['property_details']['address'] ?? ''
        : '';

    final String numberOfGuests = (bookingData['guest_ids'] != null &&
            bookingData['guest_ids'] is List &&
            (bookingData['guest_ids'] as List).isNotEmpty)
        ? (bookingData['guest_ids'] as List).length.toString()
        : '1';
    final String signatureUrl = bookingData['signatures'] != null &&
            bookingData['signatures'] is List &&
            (bookingData['signatures'] as List).isNotEmpty
        ? bookingData['signatures'][0]['signature']
        : '';
    final String checkInDate = bookingData['check_in_date'];
    final String checkOutDate = bookingData['check_out_date'];
    String formattedCheckInDate = formatDate(checkInDate);
    String formattedCheckOutDate = formatDate(checkOutDate);
    DateTime startDate = DateTime.parse(checkInDate);
    DateTime endDate = DateTime.parse(checkOutDate);

    Duration difference = endDate.difference(startDate);

    int daysDifference = difference.inDays;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.textColorSecondary,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              color: AppColors.textColorSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Booking Status: ${bookingStatus.isNotEmpty ? bookingStatus : "Unknown"}',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  verticalSpaceMedium,
                  Text(
                    'Booking ID - $bookingReference',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                    maxLines: 2, // Adjust the max lines as needed
                    overflow: TextOverflow.ellipsis, // Handle overflow
                  ),
                  verticalSpaceRegular,
                  if (bookingStatus == 'booked')
                    const Text(
                      'Your booking is confirmed!',
                      style: TextStyle(color: Colors.white),
                    )
                  else if (bookingStatus == 'pending verification')
                    const Text(
                      'Your booking is pending confirmation.',
                      style: TextStyle(color: Colors.white),
                    )
                  else
                    const Text(
                      'Unknown booking status.',
                      style: TextStyle(color: Colors.white),
                    ),
                  verticalSpaceRegular,
                ],
              ),
            ),
            verticalSpaceRegular,
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PropertyDetailPage(
                        propertyId: propertyId,
                        userDetailsProvider: Provider.of<UserDetailsProvider>(
                            context,
                            listen: false),
                      ),
                    ));
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                color: AppColors.backgroundColorDefault,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 250,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            propertyName,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          verticalSpaceRegular,
                          Text(
                            propertyAddress,
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Image.network(widget.imageUrl),
                    )
                  ],
                ),
              ),
            ),
            verticalSpaceRegular,
            verticalSpaceRegular,
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              alignment: Alignment.center,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        color: AppColors.backgroundColorDefault,
                        height: 110,
                        child: Column(children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Check In',
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ),
                          Text(
                            formattedCheckInDate,
                            style: GoogleFonts.poppins(fontSize: 16),
                            softWrap: true,
                          )
                        ]),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        color: Colors.grey[350],
                        child: Text(
                          '$daysDifference Nights',
                        ),
                      ),
                    ),
                    Expanded(
                      //check out container
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        color: AppColors.backgroundColorDefault,
                        height: 110,
                        child: Column(children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Check Out',
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ),
                          Text(
                            formattedCheckOutDate,
                            style: GoogleFonts.poppins(fontSize: 16),
                            softWrap: true,
                          )
                        ]),
                      ),
                    )
                  ]),
            ),
            verticalSpaceRegular,
            Divider(
              color: Colors.grey[350],
              height: 0,
              indent: 15,
              endIndent: 15,
            ),
            verticalSpaceRegular,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '1 Room for $numberOfGuests Adults',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, color: Colors.grey),
                        ),
                      ),
                    ),
                    verticalSpaceRegular,
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Primary Guest: ${userDetails.name}',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400, color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            verticalSpaceRegular,
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () async {
                  await pdfGenerator.createPdf(
                      bookingData,
                      propertyName,
                      propertyAddress,
                      bookingStatus,
                      bookingReference,
                      formattedCheckInDate,
                      formattedCheckOutDate,
                      daysDifference,
                      numberOfGuests,
                      userDetails,
                      signatureUrl);
                },
                child: const Text('Get PDF'),
              ),
            ),
            verticalSpaceRegular,
            if (bookingStatus == 'confirmed')
              ReviewForm(propertyId: propertyId),
            // ReviewForm(propertyId: propertyId),
            verticalSpaceRegular,
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              padding: const EdgeInsets.all(20.0),
              height: 350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Important Information',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  verticalSpaceRegular,
                  Divider(
                    color: Colors.grey[350],
                    height: 0,
                  ),
                  verticalSpaceRegular,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BulletPoint(
                          'Please provide valid documents during check-in.'),
                      verticalSpaceRegular,
                      BulletPoint(
                          'For accommodation queries, please contact the administrator.'),
                      verticalSpaceRegular,
                      BulletPoint('For emergencies, contact 926-269-5628.'),
                      verticalSpaceRegular,
                      BulletPoint('Feel free to donate for the cause.'),
                    ],
                  ),
                ],
              ),
            ),
            verticalSpaceLarge,
            verticalSpaceLarge
          ],
        ),
      ),
    );
  }
}
