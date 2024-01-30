import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kadu_booking_app/providers/userdetailsprovider.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;

Future<Uint8List> fetchImageFromUrl(String url) async {
  final response = await http.get(Uri.parse(url));
  return response.bodyBytes;
}

class PdfGenerator {
  Future<void> createPdf(
      Map<String, dynamic> bookingData,
      String? propertyName,
      String? propertyAddress,
      String? bookingStatus,
      String? bookingReference,
      String? formattedCheckInDate,
      String? formattedCheckOutDate,
      int? daysDifference,
      String? numberOfGuests,
      UserDetails? userDetails,
      String? signatureUrl) async {
    final pdf = pw.Document();
    String baseUrl = '${dotenv.env['API_URL']}';

    final List<dynamic> roomDetails =
        bookingData['room_details'] ?? <Map<String, dynamic>>[];

    final String roomId = roomDetails[0]['room_id'] ?? '';

    final Uint8List mainLogoImageBytes =
        (await rootBundle.load('assets/Shelter_Solutions_Logo.png'))
            .buffer
            .asUint8List();
    final Uint8List logoImageBytes =
        (await rootBundle.load('assets/logo.png')).buffer.asUint8List();
    final Uint8List stayImageBytes =
        (await rootBundle.load('assets/stay.jpg')).buffer.asUint8List();
    final Uint8List approvedImageBytes =
        (await rootBundle.load('assets/approved.jpeg')).buffer.asUint8List();
    final String propertyContact = roomDetails.isNotEmpty
        ? roomDetails[0]['property_details']['contact'] ?? ''
        : '';
    final String bookingDate = bookingData['updated_at'];
    final propertyImageBytes = await fetchImageFromUrl(
        '$baseUrl/storage/public/uploads/properties/${bookingData['room_details'][0]['property_details']['property_id']}/${bookingData['room_details'][0]['property_details']['files'][0]['filename']}');
    final signatureImageBytes = await fetchImageFromUrl(
        '$baseUrl/storage/public/uploads/signatures/$bookingReference/$signatureUrl');
    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        padding: pw.EdgeInsets.only(top: 10.0),
                        height: 80,
                        width: 80,
                        child: pw.Image(pw.MemoryImage(logoImageBytes)),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.only(top: 20.0),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text(
                              'BOOKING',
                              style: pw.TextStyle(
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              'VOUCHER',
                              style: pw.TextStyle(
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    height: 80,
                    width: 180,
                    child: pw.Image(pw.MemoryImage(mainLogoImageBytes),
                        fit: pw.BoxFit.fill),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(thickness: 1.0, height: 20.0),
              pw.Container(
                // padding: pw.EdgeInsets.on(horizontal: 20.0),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.SizedBox(height: 10.0),
                          pw.Text('Booking ID: ${bookingReference}'),
                          pw.SizedBox(height: 10.0),
                          pw.Text('Booking Date: $bookingDate'),
                          pw.SizedBox(height: 10.0),
                          pw.Text('Check-in: 14:00'),
                          pw.SizedBox(height: 10.0),
                          pw.Text('Check-out: 10:00'),
                          pw.SizedBox(height: 10.0),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 80.0),
                    pw.Expanded(
                      child: pw.Align(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.SizedBox(height: 10.0),
                            pw.Text('Stay Details'),
                            pw.SizedBox(height: 10.0),
                            pw.Text('$propertyName'),
                            pw.SizedBox(height: 10.0),
                            pw.Text('$propertyAddress'),
                            pw.SizedBox(height: 10.0),
                            pw.Text('Reception Phone: ${propertyContact}'),
                            pw.SizedBox(height: 20.0),
                            pw.Container(
                              alignment: pw.Alignment.centerLeft,
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Row(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.start,
                                    children: [
                                      pw.Expanded(
                                        child: pw.Row(
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Container(
                                              child: pw.Container(
                                                width: 2.0,
                                                height: 40.0,
                                                color: PdfColors.orange500,
                                              ),
                                            ),
                                            pw.SizedBox(width: 10.0),
                                            pw.Expanded(
                                              child: pw.Column(
                                                children: [
                                                  pw.Text('Check-in:'),
                                                  pw.SizedBox(height: 10.0),
                                                  pw.Text(
                                                      '$formattedCheckInDate'),
                                                ],
                                              ),
                                            ),
                                            pw.SizedBox(width: 10.0),
                                            pw.Container(
                                              child: pw.Container(
                                                width: 2.0,
                                                height: 40.0,
                                                color: PdfColors.orange500,
                                              ),
                                            ),
                                            pw.SizedBox(width: 10.0),
                                            pw.Expanded(
                                              child: pw.Column(
                                                children: [
                                                  pw.Text('Check-Out:'),
                                                  pw.SizedBox(height: 10.0),
                                                  pw.Text(
                                                      '$formattedCheckOutDate'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Divider(thickness: 1.0, height: 20.0),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Container(
                    alignment: pw.Alignment.center,
                    height: 150,
                    width: 150,
                    child: pw.Image(pw.MemoryImage(propertyImageBytes),
                        fit: pw.BoxFit.fill),
                  ),
                  pw.SizedBox(width: 50.0),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Booking Details'),
                        pw.Divider(),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Main Guest'),
                            pw.Text('${userDetails!.name}'),
                          ],
                        ),
                        pw.SizedBox(height: 10),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Social Security Number'),
                            pw.Text('${userDetails!.socialSecurity}'),
                          ],
                        ),
                        pw.SizedBox(height: 10),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Room ID'),
                            pw.Text('${roomId}'),
                          ],
                        ),
                        pw.SizedBox(height: 10),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Total Guests'),
                            pw.Text('$numberOfGuests'),
                          ],
                        ),
                        pw.SizedBox(height: 10),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Total Nights'),
                            pw.Text('$daysDifference'),
                          ],
                        ),
                        pw.SizedBox(height: 40),
                        pw.Container(
                          padding: pw.EdgeInsets.symmetric(horizontal: 20.0),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.SizedBox(
                                height: 30,
                                child: pw.Image(
                                    pw.MemoryImage(signatureImageBytes)),
                              ),
                              pw.SizedBox(height: 10),
                              pw.Text('Signature'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Divider(thickness: 1.0, height: 20.0),
              pw.SizedBox(height: 20),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          alignment: pw.Alignment.centerLeft,
                          child: pw.Container(
                            width: 10.0,
                            height: 100.0,
                            color: PdfColors.orange500,
                          ),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.only(left: 20.0),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment
                                .start, // Align items to the left

                            children: [
                              pw.Text('SHELTER SOLUTION 360°'),
                              pw.SizedBox(height: 20),
                              pw.Text('hello@reallygreatsite.com'),
                              pw.SizedBox(height: 5),
                              pw.Text('123 Anywhere St., Any City, ST 12345'),
                              pw.SizedBox(height: 5),
                              pw.Text('+123456789'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.Container(
                    height: 80,
                    padding: pw.EdgeInsets.symmetric(horizontal: 20.0),
                    child: pw.Image(pw.MemoryImage(approvedImageBytes)),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
            ],
          );
        },
      ),
    );

    final List<int> bytes = await pdf.save();
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/booking_voucher.pdf');
    await file.writeAsBytes(bytes);

    await OpenFile.open(file.path);
  }
}
