// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_const

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_to_pdf/export_delegate.dart';
import 'package:flutter_to_pdf/export_frame.dart';
import 'package:kadu_booking_app/providers/userdetailsprovider.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:kadu_booking_app/uihelper/uihelper.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// ignore: must_be_immutable
class PdfCreateAndView extends StatefulWidget {
  String? bookingStatus;
  String? bookingReference;
  String? formattedCheckInDate;
  String? formattedCheckOutDate;
  int? daysDifference;
  String? numberOfGuests;
  UserDetails? userDetails;
  PdfCreateAndView({
    Key? key,
    this.bookingStatus,
    this.bookingReference,
    this.formattedCheckInDate,
    this.formattedCheckOutDate,
    this.daysDifference,
    this.numberOfGuests,
    this.userDetails,
  }) : super(key: key);
  @override
  State<PdfCreateAndView> createState() => _PdfCreateAndViewState();
}

class _PdfCreateAndViewState extends State<PdfCreateAndView> {
  final ExportDelegate exportDelegate = ExportDelegate();

  Future<void> _createPdf() async {
    final pdf = pw.Document();

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
                          pw.Text('Booking ID: BR04719211071489f1b'),
                          pw.SizedBox(height: 10.0),
                          pw.Text('Booking Date: 12 Jan 2026'),
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
                            pw.Text('Hotel Name'),
                            pw.SizedBox(height: 10.0),
                            pw.Text('Hotel'),
                            pw.SizedBox(height: 10.0),
                            pw.Text('Address'),
                            pw.SizedBox(height: 10.0),
                            pw.Text('Reception Phone'),
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
                                                  pw.Text('12 Jan 2026'),
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
                                                  pw.Text('12 Jan 2026'),
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
                    child: pw.Image(pw.MemoryImage(stayImageBytes),
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
                            pw.Text('John Doe'),
                          ],
                        ),
                        pw.SizedBox(height: 10),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Social Security Number'),
                            pw.Text('767606007'),
                          ],
                        ),
                        pw.SizedBox(height: 10),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Room ID'),
                            pw.Text('Deluxe 001'),
                          ],
                        ),
                        pw.SizedBox(height: 10),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Total Guests'),
                            pw.Text('3'),
                          ],
                        ),
                        pw.SizedBox(height: 10),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Total Nights'),
                            pw.Text('3'),
                          ],
                        ),
                        pw.SizedBox(height: 10),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Meal Included'),
                            pw.Text('Yes'),
                          ],
                        ),
                        pw.SizedBox(height: 50),
                        pw.Container(
                          padding: pw.EdgeInsets.symmetric(horizontal: 20.0),
                          child: pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text('Signature'),
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

  Future<void> saveFile(document, String name) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File('${dir.path}/$name.pdf');

    await file.writeAsBytes(await document.save());
    debugPrint('Saved exported PDF at: ${file.path}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body: Center(
        child: ExportFrame(
          frameId: 'hotel_voucher_frame',
          exportDelegate: ExportDelegate(),
          child: ElevatedButton(
            onPressed: () async {
              _createPdf();
            },
            child: const Text('Export to PDF'),
          ),
        ),
      ),
    );
  }
}
