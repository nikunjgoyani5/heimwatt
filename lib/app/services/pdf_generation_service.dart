import 'package:heimwatt/app/modules/installation_steps/installation_form/models/installation_step_model.dart';
import 'package:heimwatt/app/modules/installation_steps/installation_steps_controller.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

import '../utils/exports.dart';

class PdfGenerationService {
  // static Future<Uint8List> generatePdf({required List<InstallationStep> installationSteps}) async {
  //   final pdf = pw.Document();
  //
  //   final Map<String, pw.MemoryImage> imageCache = {};
  //
  //   Future<pw.MemoryImage> loadPdfImage(String url) async {
  //     final res = await http.get(Uri.parse(url));
  //     return pw.MemoryImage(res.bodyBytes);
  //   }
  //
  //   for (var category in installationSteps) {
  //     for (var item in category.data ?? []) {
  //       for (var imgUrl in item.images ?? []) {
  //         if (!imageCache.containsKey(imgUrl)) {
  //           imageCache[imgUrl] = await loadPdfImage(imgUrl);
  //           Get.find<InstallationStepsController>().pdfGenerationProgress.value =
  //               Get.find<InstallationStepsController>().pdfGenerationProgress.value + 0.02;
  //         }
  //       }
  //     }
  //   }
  //   pdf.addPage(
  //     pw.MultiPage(
  //       margin: const pw.EdgeInsets.all(20),
  //
  //       build: (context) {
  //         List<pw.Widget> widgets = [];
  //
  //         for (var category in installationSteps) {
  //           widgets.add(
  //             pw.Padding(
  //               padding: const pw.EdgeInsets.only(left: 15, right: 15),
  //               child: pw.Row(
  //                 mainAxisAlignment: pw.MainAxisAlignment.center,
  //                 children: [
  //                   pw.SizedBox(
  //                     width: 500,
  //                     child: pw.Text(
  //                       category.title ?? "No data",
  //                       style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //           widgets.add(pw.SizedBox(height: 10));
  //
  //           for (var item in category.data ?? []) {
  //             // Subtitle
  //             widgets.add(
  //               pw.Padding(
  //                 padding: const pw.EdgeInsets.only(left: 15, right: 15, bottom: 10),
  //                 child: pw.Row(
  //                   mainAxisAlignment: pw.MainAxisAlignment.center,
  //                   children: [
  //                     pw.SizedBox(width: 500, child: pw.Text("${item.title ?? ""}", style: pw.TextStyle(fontSize: 16))),
  //                   ],
  //                 ),
  //               ),
  //             );
  //
  //             for (var imgUrl in item.images ?? []) {
  //               final img = imageCache[imgUrl]!;
  //
  //               widgets.add(
  //                 pw.Padding(
  //                   padding: const pw.EdgeInsets.only(bottom: 15, left: 15, right: 15),
  //                   child: pw.Row(
  //                     mainAxisAlignment: pw.MainAxisAlignment.center,
  //                     children: [pw.Image(img, height: 320, width: 500, fit: pw.BoxFit.cover)],
  //                   ),
  //                 ),
  //               );
  //             }
  //           }
  //
  //           widgets.add(pw.SizedBox(height: 20));
  //         }
  //
  //         return widgets;
  //       },
  //     ),
  //   );
  //
  //   // await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  //   return pdf.save();
  // }
  //
  // static Future<Uint8List> generateHeatPump2Pdf({
  //   String customerName = "Max Mustermann",
  //   String customerEmail = "max.mustermann@mail.de",
  //   String customerPhone = "+49 170 12 34 567",
  //   String customerAddressLine1 = "Musterstraße 12",
  //   String customerAddressLine2 = "10115 Berlin",
  //   String customerAddressLine3 = "ggf Zeile 3",
  //   String familyName = "Familie Mustermann",
  //   String status = "In Planung",
  //   String installationDate = "18. März 2025",
  //   String projectManager = "Anna Keller",
  //   String projectManagerPhone = "+49 30 98 76 5432",
  //   String companyPhone = "+49 4172 98 19 550",
  //   String companyEmail = "anfragen@heim-watt.de",
  // }) async
  // {
  //   final pdf = pw.Document();
  //
  //   // Load header image from assets
  //   pw.MemoryImage? headerBgImage;
  //   pw.MemoryImage? headerImage;
  //   pw.MemoryImage? headerImage1;
  //   pw.MemoryImage? page2HeaderBg;
  //   try {
  //     final ByteData headerImageData = await rootBundle.load('assets/images/pdf_header_img.png');
  //     final ByteData headerBg = await rootBundle.load('assets/images/pdf_2_cover_bg.png');
  //     final ByteData headerImageData1 = await rootBundle.load('assets/images/pdf_header_img1.png');
  //     final ByteData page2Bg = await rootBundle.load('assets/images/pdf_2_header_bg.png');
  //
  //     final Uint8List headerImageBytes = headerImageData.buffer.asUint8List();
  //     final Uint8List headerImageBytes1 = headerImageData1.buffer.asUint8List();
  //     final Uint8List headerBgImageBytes = headerBg.buffer.asUint8List();
  //     final Uint8List page2HeaderImageBytes = page2Bg.buffer.asUint8List();
  //
  //     headerBgImage = pw.MemoryImage(headerBgImageBytes);
  //     headerImage = pw.MemoryImage(headerImageBytes);
  //     headerImage1 = pw.MemoryImage(headerImageBytes1);
  //     page2HeaderBg = pw.MemoryImage(page2HeaderImageBytes);
  //   } catch (e) {
  //     debugPrint('Error loading header image: $e');
  //     // Fallback to colored header if image fails to load
  //     headerImage = null;
  //   }
  //
  //   // Colors
  //   final darkBlue = PdfColor.fromInt(0xFF001f30); // Dark blue header
  //   final lightGreen = PdfColor.fromInt(0xFF7CB342); // Light green accent
  //   final lightGray = PdfColor.fromInt(0xFFF5F5F5); // Light gray background
  //   final darkGray = PdfColor.fromInt(0xFF424242); // Dark gray text
  //   final white = PdfColor.fromInt(0xFFFFFFFF); // White
  //
  //   // Helper function to create header
  //   pw.Widget buildHeader() {
  //     if (headerBgImage != null && headerImage != null) {
  //       return pw.Container(
  //         height: 510,
  //         color: lightGray,
  //         width: double.infinity,
  //         child: pw.Stack(
  //           children: [
  //             // Background image section
  //             pw.Container(
  //               // height: 400,
  //               width: double.infinity,
  //               child: pw.Column(
  //                 children: [
  //                   pw.SizedBox(height: 45),
  //                   pw.Image(headerBgImage, fit: pw.BoxFit.contain),
  //                 ],
  //               ),
  //             ),
  //
  //             pw.Container(
  //               height: 100,
  //               width: double.infinity,
  //               decoration: pw.BoxDecoration(
  //                 color: darkBlue,
  //                 borderRadius: const pw.BorderRadius.only(
  //                   bottomRight: pw.Radius.circular(10),
  //                   bottomLeft: pw.Radius.circular(10),
  //                 ),
  //               ),
  //               child: pw.Center(
  //                 child: pw.Padding(
  //                   padding: const pw.EdgeInsets.all(20),
  //                   child: pw.Image(headerImage, height: 50, fit: pw.BoxFit.contain),
  //                 ),
  //               ),
  //             ),
  //             // Header logo/text section with bottom radius
  //           ],
  //         ),
  //       );
  //     } else {
  //       // Fallback to colored header with text
  //       return pw.Container(
  //         height: 120,
  //         color: darkBlue,
  //         child: pw.Row(
  //           mainAxisAlignment: pw.MainAxisAlignment.start,
  //           crossAxisAlignment: pw.CrossAxisAlignment.center,
  //           children: [
  //             pw.SizedBox(width: 40),
  //             pw.Text(
  //               'heimWatt',
  //               style: pw.TextStyle(color: white, fontSize: 32, fontWeight: pw.FontWeight.bold),
  //             ),
  //             pw.SizedBox(width: 20),
  //             pw.Text('Die richtige Entscheidung.', style: pw.TextStyle(color: white, fontSize: 14)),
  //           ],
  //         ),
  //       );
  //     }
  //   } // Helper function to create header
  //
  //   // Helper function to create footer
  //   pw.Widget buildFooter(int pageNumber, {int totalPages = 6}) {
  //     return pw.Column(
  //       children: [
  //         pw.Container(height: 15, color: lightGray),
  //         pw.Container(
  //           color: lightGray,
  //           child: pw.Row(
  //             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //             crossAxisAlignment: pw.CrossAxisAlignment.center,
  //             children: [
  //               pw.Padding(
  //                 child: pw.Text('heimWatt GmbH', style: pw.TextStyle(color: darkGray, fontSize: 10)),
  //                 padding: pw.EdgeInsets.symmetric(horizontal: 20),
  //               ),
  //               pw.Text('Fotoleitfaden Photovoltaik', style: pw.TextStyle(color: darkGray, fontSize: 10)),
  //               pw.Padding(
  //                 child: pw.Text('$pageNumber/$totalPages', style: pw.TextStyle(color: darkGray, fontSize: 10)),
  //                 padding: pw.EdgeInsets.symmetric(horizontal: 20),
  //               ),
  //             ],
  //           ),
  //         ),
  //         pw.Container(height: 15, color: lightGray),
  //       ],
  //     );
  //   }
  //
  //   // PAGE 1: Cover Page
  //   pdf.addPage(
  //     pw.Page(
  //       pageFormat: PdfPageFormat.a4,
  //       margin: pw.EdgeInsets.zero,
  //       build: (pw.Context context) {
  //         return pw.Container(
  //           child: pw.Column(
  //             children: [
  //               buildHeader(),
  //
  //               // Title section
  //               pw.Container(
  //                 width: double.infinity,
  //                 decoration: pw.BoxDecoration(
  //                   borderRadius: const pw.BorderRadius.only(
  //                     bottomRight: pw.Radius.circular(15),
  //                     bottomLeft: pw.Radius.circular(15),
  //                   ),
  //                   color: lightGray,
  //                 ),
  //                 padding: const pw.EdgeInsets.symmetric(vertical: 25),
  //                 child: pw.Column(
  //                   crossAxisAlignment: pw.CrossAxisAlignment.center,
  //                   mainAxisAlignment: pw.MainAxisAlignment.center,
  //                   children: [
  //                     pw.Text(
  //                       'Wärmepumpe',
  //                       style: pw.TextStyle(color: darkBlue, fontSize: 32, fontWeight: pw.FontWeight.bold),
  //                     ),
  //                     pw.SizedBox(height: 10),
  //                     pw.Text(
  //                       familyName,
  //                       style: pw.TextStyle(color: lightGreen, fontSize: 14, fontWeight: pw.FontWeight.normal),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               pw.Container(
  //                 width: double.infinity,
  //                 decoration: pw.BoxDecoration(
  //                   borderRadius: const pw.BorderRadius.only(
  //                     bottomRight: pw.Radius.circular(15),
  //                     bottomLeft: pw.Radius.circular(15),
  //                   ),
  //                   color: white,
  //                 ),
  //                 padding: const pw.EdgeInsets.symmetric(vertical: 40, horizontal: 20),
  //                 child: // Status boxes
  //                 pw.Row(
  //                   mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
  //                   children: [
  //                     pw.Expanded(
  //                       child: pw.Container(
  //                         padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  //                         decoration: pw.BoxDecoration(
  //                           color: lightGray,
  //                           borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
  //                         ),
  //                         child: pw.Column(
  //                           crossAxisAlignment: pw.CrossAxisAlignment.center,
  //                           mainAxisAlignment: pw.MainAxisAlignment.center,
  //                           children: [
  //                             pw.Text('Status', style: pw.TextStyle(color: darkGray, fontSize: 10)),
  //                             pw.SizedBox(height: 8),
  //                             pw.Text(
  //                               status,
  //                               style: pw.TextStyle(color: darkBlue, fontSize: 12, fontWeight: pw.FontWeight.bold),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                     pw.SizedBox(width: 10),
  //                     pw.Expanded(
  //                       child: pw.Container(
  //                         padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  //                         decoration: pw.BoxDecoration(
  //                           color: lightGray,
  //                           borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
  //                         ),
  //                         child: pw.Column(
  //                           crossAxisAlignment: pw.CrossAxisAlignment.center,
  //                           mainAxisAlignment: pw.MainAxisAlignment.center,
  //                           children: [
  //                             pw.Text('Installationstermin', style: pw.TextStyle(color: darkGray, fontSize: 10)),
  //                             pw.SizedBox(height: 8),
  //                             pw.Text(
  //                               installationDate,
  //                               style: pw.TextStyle(color: darkBlue, fontSize: 12, fontWeight: pw.FontWeight.bold),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               buildFooter(1),
  //             ],
  //           ),
  //           color: lightGray,
  //         );
  //       },
  //     ),
  //   );
  //
  //   // PAGE 2: Project Data
  //   pdf.addPage(
  //     pw.Page(
  //       pageFormat: PdfPageFormat.a5,
  //       margin: pw.EdgeInsets.zero,
  //       build: (pw.Context context) {
  //         return pw.Column(
  //           children: [
  //             // Header with image background
  //             pw.Container(
  //               height: 100,
  //               width: double.infinity,
  //               color: lightGray,
  //               child: (page2HeaderBg != null && headerImage1 != null)
  //                   ? pw.Stack(
  //                       children: [
  //                         pw.Positioned.fill(child: pw.Image(page2HeaderBg, fit: pw.BoxFit.fill)),
  //                         pw.Positioned(
  //                           left: 30,
  //                           top: 40,
  //                           child: pw.Image(headerImage1, height: 20, fit: pw.BoxFit.contain),
  //                         ),
  //                       ],
  //                     )
  //                   : pw.Container(
  //                       color: darkBlue,
  //                       child: pw.Padding(
  //                         padding: const pw.EdgeInsets.only(left: 40, top: 40),
  //                         child: pw.Text(
  //                           'heimWatt',
  //                           style: pw.TextStyle(color: white, fontSize: 32, fontWeight: pw.FontWeight.bold),
  //                         ),
  //                       ),
  //                     ),
  //             ),
  //             // Title
  //             pw.Container(
  //               width: double.infinity,
  //               decoration: pw.BoxDecoration(
  //                 color: lightGray,
  //                 borderRadius: pw.BorderRadius.only(
  //                   bottomLeft: pw.Radius.circular(15),
  //                   bottomRight: pw.Radius.circular(15),
  //                 ),
  //               ),
  //               padding: const pw.EdgeInsets.symmetric(horizontal: 30, vertical: 20),
  //               child: pw.Text(
  //                 'Projektdaten',
  //                 style: pw.TextStyle(color: darkBlue, fontSize: 22, fontWeight: pw.FontWeight.bold),
  //               ),
  //             ),
  //             // Content
  //             pw.Expanded(
  //               child: pw.Container(
  //                 width: double.infinity,
  //                 color: white,
  //                 padding: const pw.EdgeInsets.all(30),
  //                 child: pw.Column(
  //                   crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                   children: [
  //                     // Customer Information
  //                     pw.Row(
  //                       crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                       children: [
  //                         pw.Expanded(
  //                           child: pw.Column(
  //                             crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                             children: [
  //                               pw.Text('Kunde/Kundin', style: pw.TextStyle(color: darkGray, fontSize: 6)),
  //                               pw.SizedBox(height: 4),
  //                               pw.Text(
  //                                 customerName,
  //                                 style: pw.TextStyle(color: darkBlue, fontSize: 10, fontWeight: pw.FontWeight.bold),
  //                               ),
  //                               pw.SizedBox(height: 12),
  //                               pw.Text('eMail-Adresse', style: pw.TextStyle(color: darkGray, fontSize: 6)),
  //                               pw.SizedBox(height: 4),
  //                               pw.Text(
  //                                 customerEmail,
  //                                 style: pw.TextStyle(color: darkBlue, fontSize: 10, fontWeight: pw.FontWeight.bold),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                         pw.SizedBox(width: 20),
  //                         pw.Expanded(
  //                           child: pw.Column(
  //                             crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                             children: [
  //                               pw.Text('Telefonnummer', style: pw.TextStyle(color: darkGray, fontSize: 6)),
  //                               pw.SizedBox(height: 4),
  //                               pw.Text(
  //                                 customerPhone,
  //                                 style: pw.TextStyle(color: darkBlue, fontSize: 10, fontWeight: pw.FontWeight.bold),
  //                               ),
  //                               pw.SizedBox(height: 12),
  //                               pw.Text('Adresse', style: pw.TextStyle(color: darkGray, fontSize: 6)),
  //                               pw.SizedBox(height: 4),
  //                               pw.Text(
  //                                 customerAddressLine1,
  //                                 style: pw.TextStyle(color: darkBlue, fontSize: 10, fontWeight: pw.FontWeight.bold),
  //                               ),
  //                               pw.Text(
  //                                 customerAddressLine2,
  //                                 style: pw.TextStyle(color: darkBlue, fontSize: 6, fontWeight: pw.FontWeight.bold),
  //                               ),
  //                               pw.Text(
  //                                 customerAddressLine3,
  //                                 style: pw.TextStyle(color: darkBlue, fontSize: 10, fontWeight: pw.FontWeight.bold),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     pw.SizedBox(height: 20),
  //                     pw.Divider(color: lightGray, height: 2),
  //                     pw.SizedBox(height: 20),
  //                     // Project Manager Information
  //                     pw.Row(
  //                       crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                       children: [
  //                         pw.Expanded(
  //                           child: pw.Column(
  //                             crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                             children: [
  //                               pw.Text('Projektbearbeiter*in', style: pw.TextStyle(color: darkGray, fontSize: 6)),
  //                               pw.SizedBox(height: 4),
  //                               pw.Text(
  //                                 projectManager,
  //                                 style: pw.TextStyle(color: darkBlue, fontSize: 10, fontWeight: pw.FontWeight.bold),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                         pw.SizedBox(width: 20),
  //                         pw.Expanded(
  //                           child: pw.Column(
  //                             crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                             children: [
  //                               pw.Text('Telefonnummer', style: pw.TextStyle(color: darkGray, fontSize: 6)),
  //                               pw.SizedBox(height: 4),
  //                               pw.Text(
  //                                 projectManagerPhone,
  //                                 style: pw.TextStyle(color: darkBlue, fontSize: 10, fontWeight: pw.FontWeight.bold),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             buildFooter(2),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  //
  //   return pdf.save();
  // }
  //
  // static Future<Uint8List> generateHeatPump3Pdf({
  //   String customerName = "Max Mustermann",
  //   String customerEmail = "max.mustermann@mail.de",
  //   String customerPhone = "+49 170 12 34 567",
  //   String customerAddressLine1 = "Musterstraße 12",
  //   String customerAddressLine2 = "10115 Berlin",
  //   String customerAddressLine3 = "ggf Zeile 3",
  //   String familyName = "Familie Mustermann",
  //   String status = "In Planung",
  //   String installationDate = "18. März 2025",
  //   String projectManager = "Anna Keller",
  //   String projectManagerPhone = "+49 30 98 76 5432",
  //   String companyPhone = "+49 4172 98 19 550",
  //   String companyEmail = "anfragen@heim-watt.de",
  // }) async
  // {
  //   final pdf = pw.Document();
  //
  //   // Load header image from assets
  //   pw.MemoryImage? headerBgImage;
  //   pw.MemoryImage? headerImage;
  //   pw.MemoryImage? headerImage1;
  //   pw.MemoryImage? page2HeaderBg;
  //   try {
  //     final ByteData headerImageData = await rootBundle.load('assets/images/pdf_header_img.png');
  //     final ByteData headerBg = await rootBundle.load('assets/images/pdf_3_cover_bg.png');
  //     final ByteData headerImageData1 = await rootBundle.load('assets/images/pdf_header_img1.png');
  //     final ByteData page2Bg = await rootBundle.load('assets/images/pdf_3_header_bg.png');
  //
  //     final Uint8List headerImageBytes = headerImageData.buffer.asUint8List();
  //     final Uint8List headerImageBytes1 = headerImageData1.buffer.asUint8List();
  //     final Uint8List headerBgImageBytes = headerBg.buffer.asUint8List();
  //     final Uint8List page2HeaderImageBytes = page2Bg.buffer.asUint8List();
  //
  //     headerBgImage = pw.MemoryImage(headerBgImageBytes);
  //     headerImage = pw.MemoryImage(headerImageBytes);
  //     headerImage1 = pw.MemoryImage(headerImageBytes1);
  //     page2HeaderBg = pw.MemoryImage(page2HeaderImageBytes);
  //   } catch (e) {
  //     debugPrint('Error loading header image: $e');
  //     // Fallback to colored header if image fails to load
  //     headerImage = null;
  //   }
  //
  //   // Colors
  //   final darkBlue = PdfColor.fromInt(0xFF001f30); // Dark blue header
  //   final lightGreen = PdfColor.fromInt(0xFF7CB342); // Light green accent
  //   final lightGray = PdfColor.fromInt(0xFFF5F5F5); // Light gray background
  //   final darkGray = PdfColor.fromInt(0xFF424242); // Dark gray text
  //   final white = PdfColor.fromInt(0xFFFFFFFF); // White
  //
  //   // Helper function to create header
  //   pw.Widget buildHeader() {
  //     if (headerBgImage != null && headerImage != null) {
  //       return pw.Container(
  //         height: 515,
  //         color: lightGray,
  //         child: pw.Stack(
  //           children: [
  //             // Background image section
  //             pw.Container(
  //               width: double.infinity,
  //               child: pw.Column(
  //                 children: [
  //                   pw.SizedBox(height: 45),
  //                   pw.Image(headerBgImage, fit: pw.BoxFit.contain),
  //                 ],
  //               ),
  //             ),
  //
  //             pw.Container(
  //               height: 100,
  //               width: double.infinity,
  //               decoration: pw.BoxDecoration(
  //                 color: darkBlue,
  //                 borderRadius: const pw.BorderRadius.only(
  //                   bottomRight: pw.Radius.circular(10),
  //                   bottomLeft: pw.Radius.circular(10),
  //                 ),
  //               ),
  //               child: pw.Center(
  //                 child: pw.Padding(
  //                   padding: const pw.EdgeInsets.all(20),
  //                   child: pw.Image(headerImage, height: 50, fit: pw.BoxFit.contain),
  //                 ),
  //               ),
  //             ),
  //             // Header logo/text section with bottom radius
  //           ],
  //         ),
  //       );
  //     } else {
  //       // Fallback to colored header with text
  //       return pw.Container(
  //         height: 120,
  //         color: darkBlue,
  //         child: pw.Row(
  //           mainAxisAlignment: pw.MainAxisAlignment.start,
  //           crossAxisAlignment: pw.CrossAxisAlignment.center,
  //           children: [
  //             pw.SizedBox(width: 40),
  //             pw.Text(
  //               'heimWatt',
  //               style: pw.TextStyle(color: white, fontSize: 32, fontWeight: pw.FontWeight.bold),
  //             ),
  //             pw.SizedBox(width: 20),
  //             pw.Text('Die richtige Entscheidung.', style: pw.TextStyle(color: white, fontSize: 14)),
  //           ],
  //         ),
  //       );
  //     }
  //   } // Helper function to create header
  //
  //   pw.Widget buildHeader1() {
  //     if (headerImage1 != null) {
  //       return pw.Container(
  //         height: 100,
  //         width: double.infinity,
  //         decoration: pw.BoxDecoration(
  //           color: darkBlue,
  //           borderRadius: pw.BorderRadius.only(bottomRight: pw.Radius.circular(10), bottomLeft: pw.Radius.circular(10)),
  //         ),
  //         child: pw.Align(
  //           alignment: pw.AlignmentDirectional.centerStart,
  //           child: pw.Padding(
  //             child: pw.Image(headerImage1, height: 30, fit: pw.BoxFit.contain),
  //             padding: pw.EdgeInsets.only(left: 16),
  //           ),
  //         ),
  //       );
  //     } else {
  //       // Fallback to colored header with text
  //       return pw.Container(
  //         height: 120,
  //         color: darkBlue,
  //         child: pw.Row(
  //           mainAxisAlignment: pw.MainAxisAlignment.start,
  //           crossAxisAlignment: pw.CrossAxisAlignment.center,
  //           children: [
  //             pw.SizedBox(width: 40),
  //             pw.Text(
  //               'heimWatt',
  //               style: pw.TextStyle(color: white, fontSize: 32, fontWeight: pw.FontWeight.bold),
  //             ),
  //             pw.SizedBox(width: 20),
  //             pw.Text('Die richtige Entscheidung.', style: pw.TextStyle(color: white, fontSize: 14)),
  //           ],
  //         ),
  //       );
  //     }
  //   }
  //
  //   // Helper function to create footer
  //   pw.Widget buildFooter(int pageNumber, {int totalPages = 6}) {
  //     return pw.Column(
  //       children: [
  //         pw.Container(height: 15, color: lightGray),
  //         pw.Container(
  //           color: lightGray,
  //           child: pw.Row(
  //             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //             crossAxisAlignment: pw.CrossAxisAlignment.center,
  //             children: [
  //               pw.Padding(
  //                 child: pw.Text('heimWatt GmbH', style: pw.TextStyle(color: darkGray, fontSize: 10)),
  //                 padding: pw.EdgeInsets.symmetric(horizontal: 20),
  //               ),
  //               pw.Text('Fotoleitfaden Photovoltaik', style: pw.TextStyle(color: darkGray, fontSize: 10)),
  //               pw.Padding(
  //                 child: pw.Text('$pageNumber/$totalPages', style: pw.TextStyle(color: darkGray, fontSize: 10)),
  //                 padding: pw.EdgeInsets.symmetric(horizontal: 20),
  //               ),
  //             ],
  //           ),
  //         ),
  //         pw.Container(height: 15, color: lightGray),
  //       ],
  //     );
  //   }
  //
  //   // Helper function to create placeholder image
  //   pw.Widget buildPlaceholderImage(String label) {
  //     return pw.Container(
  //       height: 250,
  //       decoration: pw.BoxDecoration(
  //         color: lightGray,
  //         borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
  //         border: pw.Border.all(color: darkGray, width: 1),
  //       ),
  //       child: pw.Center(
  //         child: pw.Column(
  //           mainAxisAlignment: pw.MainAxisAlignment.center,
  //           children: [
  //             pw.Text(
  //               '[IMAGE]',
  //               style: pw.TextStyle(fontSize: 32, color: darkGray, fontWeight: pw.FontWeight.bold),
  //             ),
  //             pw.SizedBox(height: 10),
  //             pw.Text(
  //               label,
  //               style: pw.TextStyle(color: darkGray, fontSize: 14, fontWeight: pw.FontWeight.normal),
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }
  //
  //   // PAGE 1: Cover Page
  //   pdf.addPage(
  //     pw.Page(
  //       pageFormat: PdfPageFormat.a4,
  //       margin: pw.EdgeInsets.zero,
  //       build: (pw.Context context) {
  //         return pw.Container(
  //           child: pw.Column(
  //             children: [
  //               buildHeader(),
  //
  //               // Title section
  //               pw.Container(
  //                 width: double.infinity,
  //                 decoration: pw.BoxDecoration(
  //                   borderRadius: const pw.BorderRadius.only(
  //                     bottomRight: pw.Radius.circular(15),
  //                     bottomLeft: pw.Radius.circular(15),
  //                   ),
  //                   color: lightGray,
  //                 ),
  //                 padding: const pw.EdgeInsets.symmetric(vertical: 25),
  //                 child: pw.Column(
  //                   crossAxisAlignment: pw.CrossAxisAlignment.center,
  //                   mainAxisAlignment: pw.MainAxisAlignment.center,
  //                   children: [
  //                     pw.Text(
  //                       'Photovoltaik-Anlage',
  //                       style: pw.TextStyle(color: darkBlue, fontSize: 32, fontWeight: pw.FontWeight.bold),
  //                     ),
  //                     pw.SizedBox(height: 10),
  //                     pw.Text(
  //                       familyName,
  //                       style: pw.TextStyle(color: lightGreen, fontSize: 14, fontWeight: pw.FontWeight.normal),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               pw.Container(
  //                 width: double.infinity,
  //                 decoration: pw.BoxDecoration(
  //                   borderRadius: const pw.BorderRadius.only(
  //                     bottomRight: pw.Radius.circular(15),
  //                     bottomLeft: pw.Radius.circular(15),
  //                   ),
  //                   color: white,
  //                 ),
  //                 padding: const pw.EdgeInsets.symmetric(vertical: 40, horizontal: 20),
  //                 child: // Status boxes
  //                 pw.Row(
  //                   mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
  //                   children: [
  //                     pw.Expanded(
  //                       child: pw.Container(
  //                         padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  //                         decoration: pw.BoxDecoration(
  //                           color: lightGray,
  //                           borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
  //                         ),
  //                         child: pw.Column(
  //                           crossAxisAlignment: pw.CrossAxisAlignment.center,
  //                           mainAxisAlignment: pw.MainAxisAlignment.center,
  //                           children: [
  //                             pw.Text('Status', style: pw.TextStyle(color: darkGray, fontSize: 10)),
  //                             pw.SizedBox(height: 8),
  //                             pw.Text(
  //                               status,
  //                               style: pw.TextStyle(color: darkBlue, fontSize: 12, fontWeight: pw.FontWeight.bold),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                     pw.SizedBox(width: 10),
  //                     pw.Expanded(
  //                       child: pw.Container(
  //                         padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  //                         decoration: pw.BoxDecoration(
  //                           color: lightGray,
  //                           borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
  //                         ),
  //                         child: pw.Column(
  //                           crossAxisAlignment: pw.CrossAxisAlignment.center,
  //                           mainAxisAlignment: pw.MainAxisAlignment.center,
  //                           children: [
  //                             pw.Text('Installationstermin', style: pw.TextStyle(color: darkGray, fontSize: 10)),
  //                             pw.SizedBox(height: 8),
  //                             pw.Text(
  //                               installationDate,
  //                               style: pw.TextStyle(color: darkBlue, fontSize: 12, fontWeight: pw.FontWeight.bold),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               buildFooter(1),
  //             ],
  //           ),
  //           color: lightGray,
  //         );
  //       },
  //     ),
  //   );
  //
  //   // PAGE 2: Project Data
  //   pdf.addPage(
  //     pw.Page(
  //       pageFormat: PdfPageFormat.a5,
  //       margin: pw.EdgeInsets.zero,
  //       build: (pw.Context context) {
  //         return pw.Column(
  //           children: [
  //             // Header with image background
  //             pw.Container(
  //               height: 100,
  //               width: double.infinity,
  //               color: lightGray,
  //               child: (page2HeaderBg != null && headerImage1 != null)
  //                   ? pw.Stack(
  //                       children: [
  //                         pw.Positioned.fill(child: pw.Image(page2HeaderBg, fit: pw.BoxFit.fill)),
  //                         pw.Positioned(
  //                           left: 30,
  //                           top: 40,
  //                           child: pw.Image(headerImage1, height: 20, fit: pw.BoxFit.contain),
  //                         ),
  //                       ],
  //                     )
  //                   : pw.Container(
  //                       color: darkBlue,
  //                       child: pw.Padding(
  //                         padding: const pw.EdgeInsets.only(left: 40, top: 40),
  //                         child: pw.Text(
  //                           'heimWatt',
  //                           style: pw.TextStyle(color: white, fontSize: 32, fontWeight: pw.FontWeight.bold),
  //                         ),
  //                       ),
  //                     ),
  //             ),
  //             // Title
  //             pw.Container(
  //               width: double.infinity,
  //               decoration: pw.BoxDecoration(
  //                 color: lightGray,
  //                 borderRadius: pw.BorderRadius.only(
  //                   bottomLeft: pw.Radius.circular(15),
  //                   bottomRight: pw.Radius.circular(15),
  //                 ),
  //               ),
  //               padding: const pw.EdgeInsets.symmetric(horizontal: 30, vertical: 20),
  //               child: pw.Text(
  //                 'Projektdaten',
  //                 style: pw.TextStyle(color: darkBlue, fontSize: 22, fontWeight: pw.FontWeight.bold),
  //               ),
  //             ),
  //             // Content
  //             pw.Expanded(
  //               child: pw.Container(
  //                 width: double.infinity,
  //                 color: white,
  //                 padding: const pw.EdgeInsets.all(30),
  //                 child: pw.Column(
  //                   crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                   children: [
  //                     // Customer Information
  //                     pw.Row(
  //                       crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                       children: [
  //                         pw.Expanded(
  //                           child: pw.Column(
  //                             crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                             children: [
  //                               pw.Text('Kunde/Kundin', style: pw.TextStyle(color: darkGray, fontSize: 6)),
  //                               pw.SizedBox(height: 4),
  //                               pw.Text(
  //                                 customerName,
  //                                 style: pw.TextStyle(color: darkBlue, fontSize: 10, fontWeight: pw.FontWeight.bold),
  //                               ),
  //                               pw.SizedBox(height: 12),
  //                               pw.Text('eMail-Adresse', style: pw.TextStyle(color: darkGray, fontSize: 6)),
  //                               pw.SizedBox(height: 4),
  //                               pw.Text(
  //                                 customerEmail,
  //                                 style: pw.TextStyle(color: darkBlue, fontSize: 10, fontWeight: pw.FontWeight.bold),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                         pw.SizedBox(width: 20),
  //                         pw.Expanded(
  //                           child: pw.Column(
  //                             crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                             children: [
  //                               pw.Text('Telefonnummer', style: pw.TextStyle(color: darkGray, fontSize: 6)),
  //                               pw.SizedBox(height: 4),
  //                               pw.Text(
  //                                 customerPhone,
  //                                 style: pw.TextStyle(color: darkBlue, fontSize: 10, fontWeight: pw.FontWeight.bold),
  //                               ),
  //                               pw.SizedBox(height: 12),
  //                               pw.Text('Adresse', style: pw.TextStyle(color: darkGray, fontSize: 6)),
  //                               pw.SizedBox(height: 4),
  //                               pw.Text(
  //                                 customerAddressLine1,
  //                                 style: pw.TextStyle(color: darkBlue, fontSize: 10, fontWeight: pw.FontWeight.bold),
  //                               ),
  //                               pw.Text(
  //                                 customerAddressLine2,
  //                                 style: pw.TextStyle(color: darkBlue, fontSize: 6, fontWeight: pw.FontWeight.bold),
  //                               ),
  //                               pw.Text(
  //                                 customerAddressLine3,
  //                                 style: pw.TextStyle(color: darkBlue, fontSize: 10, fontWeight: pw.FontWeight.bold),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     pw.SizedBox(height: 20),
  //                     pw.Divider(color: lightGray, height: 2),
  //                     pw.SizedBox(height: 20),
  //                     // Project Manager Information
  //                     pw.Row(
  //                       crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                       children: [
  //                         pw.Expanded(
  //                           child: pw.Column(
  //                             crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                             children: [
  //                               pw.Text('Projektbearbeiter*in', style: pw.TextStyle(color: darkGray, fontSize: 6)),
  //                               pw.SizedBox(height: 4),
  //                               pw.Text(
  //                                 projectManager,
  //                                 style: pw.TextStyle(color: darkBlue, fontSize: 10, fontWeight: pw.FontWeight.bold),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                         pw.SizedBox(width: 20),
  //                         pw.Expanded(
  //                           child: pw.Column(
  //                             crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                             children: [
  //                               pw.Text('Telefonnummer', style: pw.TextStyle(color: darkGray, fontSize: 6)),
  //                               pw.SizedBox(height: 4),
  //                               pw.Text(
  //                                 projectManagerPhone,
  //                                 style: pw.TextStyle(color: darkBlue, fontSize: 10, fontWeight: pw.FontWeight.bold),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             buildFooter(2),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  //
  //   // PAGE 3: Outdoor Unit Location
  //   pdf.addPage(
  //     pw.Page(
  //       pageFormat: PdfPageFormat.a4,
  //       margin: pw.EdgeInsets.zero,
  //       build: (pw.Context context) {
  //         return pw.Column(
  //           children: [
  //             buildHeader1(),
  //             pw.Expanded(
  //               child: pw.Container(
  //                 width: double.infinity,
  //                 color: lightGray,
  //                 padding: const pw.EdgeInsets.all(16),
  //                 child: pw.Column(
  //                   crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                   children: [
  //                     pw.Text(
  //                       'Aufstellort\nAußeneinheit',
  //                       style: pw.TextStyle(color: darkBlue, fontSize: 30, fontWeight: pw.FontWeight.bold),
  //                     ),
  //                     pw.SizedBox(height: 10),
  //                     pw.Text('Unterkategorie 1', style: pw.TextStyle(color: lightGreen, fontSize: 12)),
  //                     pw.SizedBox(height: 30),
  //                     buildPlaceholderImage('Außeneinheit Bild 1'),
  //                     pw.SizedBox(height: 30),
  //                     buildPlaceholderImage('Außeneinheit Bild 2'),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             buildFooter(3),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  //
  //   // PAGE 4: Indoor Unit Location
  //   pdf.addPage(
  //     pw.Page(
  //       pageFormat: PdfPageFormat.a4,
  //       margin: pw.EdgeInsets.zero,
  //       build: (pw.Context context) {
  //         return pw.Column(
  //           children: [
  //             buildHeader1(),
  //             pw.Expanded(
  //               child: pw.Container(
  //                 width: double.infinity,
  //                 color: white,
  //                 padding: const pw.EdgeInsets.all(40),
  //                 child: pw.Column(
  //                   crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                   children: [
  //                     pw.Text(
  //                       'Aufstellort\nInneneinheit',
  //                       style: pw.TextStyle(color: darkGray, fontSize: 36, fontWeight: pw.FontWeight.bold),
  //                     ),
  //                     pw.SizedBox(height: 10),
  //                     pw.Text('Unterkategorie 1', style: pw.TextStyle(color: lightGreen, fontSize: 18)),
  //                     pw.SizedBox(height: 30),
  //                     buildPlaceholderImage('Inneneinheit Bild 1'),
  //                     pw.SizedBox(height: 30),
  //                     buildPlaceholderImage('Inneneinheit Bild 2'),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             buildFooter(4),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  //
  //   // PAGE 5: Meter Box
  //   pdf.addPage(
  //     pw.Page(
  //       pageFormat: PdfPageFormat.a4,
  //       margin: pw.EdgeInsets.zero,
  //       build: (pw.Context context) {
  //         return pw.Column(
  //           children: [
  //             buildHeader1(),
  //             pw.Expanded(
  //               child: pw.Container(
  //                 width: double.infinity,
  //                 color: lightGray,
  //                 padding: const pw.EdgeInsets.all(40),
  //                 child: pw.Column(
  //                   crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                   children: [
  //                     pw.Text(
  //                       'Zählerkasten',
  //                       style: pw.TextStyle(color: darkGray, fontSize: 36, fontWeight: pw.FontWeight.bold),
  //                     ),
  //                     pw.SizedBox(height: 10),
  //                     pw.Text('Unterkategorie 1', style: pw.TextStyle(color: lightGreen, fontSize: 18)),
  //                     pw.SizedBox(height: 30),
  //                     buildPlaceholderImage('Zählerkasten Bild 1'),
  //                     pw.SizedBox(height: 30),
  //                     buildPlaceholderImage('Zählerkasten Bild 2'),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             buildFooter(5),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  //
  //   // PAGE 6: Thank You Page
  //   pdf.addPage(
  //     pw.Page(
  //       pageFormat: PdfPageFormat.a4,
  //       margin: pw.EdgeInsets.zero,
  //       build: (pw.Context context) {
  //         return pw.Column(
  //           children: [
  //             buildHeader(),
  //             // Thank you section
  //             pw.Container(
  //               width: double.infinity,
  //               color: lightGray,
  //               padding: const pw.EdgeInsets.all(40),
  //               child: pw.Column(
  //                 children: [
  //                   pw.Text(
  //                     'Vielen Dank!',
  //                     style: pw.TextStyle(color: darkBlue, fontSize: 42, fontWeight: pw.FontWeight.bold),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             pw.Container(
  //               width: double.infinity,
  //               decoration: pw.BoxDecoration(
  //                 color: white,
  //                 borderRadius: pw.BorderRadius.only(
  //                   bottomLeft: pw.Radius.circular(15),
  //                   bottomRight: pw.Radius.circular(15),
  //                 ),
  //               ),
  //               padding: const pw.EdgeInsets.all(20),
  //               child: pw.Row(
  //                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   pw.Column(
  //                     crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                     children: [
  //                       pw.Text('Telefon', style: pw.TextStyle(color: darkGray, fontSize: 8)),
  //                       pw.SizedBox(height: 4),
  //                       pw.Text(
  //                         companyPhone,
  //                         style: pw.TextStyle(color: darkBlue, fontSize: 10, fontWeight: pw.FontWeight.bold),
  //                       ),
  //                     ],
  //                   ),
  //                   pw.Column(
  //                     crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                     children: [
  //                       pw.Text('eMail', style: pw.TextStyle(color: darkGray, fontSize: 8)),
  //                       pw.SizedBox(height: 4),
  //                       pw.Text(
  //                         companyEmail,
  //                         style: pw.TextStyle(color: darkBlue, fontSize: 10, fontWeight: pw.FontWeight.bold),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             buildFooter(6),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  //
  //   return pdf.save();
  // }

  /// Generate 6-page PDF document matching the design specifications
  static Future<Uint8List> generateHeatPumpPdf({
    String customerName = "Max Mustermann",
    String customerEmail = "max.mustermann@mail.de",
    String customerPhone = "+49 170 12 34 567",
    String customerAddressLine1 = "Musterstraße 12",
    String customerAddressLine2 = "10115 Berlin",
    String customerAddressLine3 = "ggf Zeile 3",
    String familyName = "Familie Mustermann",
    String status = "In Planung",
    String installationDate = "18. März 2025",
    String projectManager = "Anna Keller",
    String projectManagerPhone = "+49 30 98 76 5432",
    String companyPhone = "+49 4172 98 19 550",
    String companyEmail = "anfragen@heim-watt.de",
    required List<InstallationStep> installationSteps,
    required int type,
  }) async {
    final pdf = pw.Document();

    pw.MemoryImage? headerBgImage;
    pw.MemoryImage? headerImage;
    pw.MemoryImage? headerImage1;
    pw.MemoryImage? page2HeaderBg;

    ByteData? headerImageData;
    ByteData? headerBg;
    ByteData? headerImageData1;
    ByteData? page2Bg;

    try {
      if (type == 1) {
        headerImageData = await rootBundle.load('assets/images/pdf_header_img.png');
        headerBg = await rootBundle.load('assets/images/header_bg.png');
        headerImageData1 = await rootBundle.load('assets/images/pdf_header_img1.png');
        page2Bg = await rootBundle.load('assets/images/page_2_header_bg.png');
      } else if (type == 2) {
        headerImageData = await rootBundle.load('assets/images/pdf_header_img.png');
        headerBg = await rootBundle.load('assets/images/pdf_3_cover_bg.png');
        headerImageData1 = await rootBundle.load('assets/images/pdf_header_img1.png');
        page2Bg = await rootBundle.load('assets/images/pdf_3_header_bg.png');
      } else {
        headerImageData = await rootBundle.load('assets/images/pdf_header_img.png');
        headerBg = await rootBundle.load('assets/images/pdf_2_cover_bg.png');
        headerImageData1 = await rootBundle.load('assets/images/pdf_header_img1.png');
        page2Bg = await rootBundle.load('assets/images/pdf_2_header_bg.png');
      }

      headerBgImage = pw.MemoryImage(headerBg!.buffer.asUint8List());
      headerImage = pw.MemoryImage(headerImageData!.buffer.asUint8List());
      headerImage1 = pw.MemoryImage(headerImageData1!.buffer.asUint8List());
      page2HeaderBg = pw.MemoryImage(page2Bg!.buffer.asUint8List());
    } catch (_) {}

    final darkBlue = PdfColor.fromInt(0xFF001f30);
    final lightGreen = PdfColor.fromInt(0xFF7CB342);
    final lightGray = PdfColor.fromInt(0xFFF5F5F5);
    final darkGray = PdfColor.fromInt(0xFF424242);
    final white = PdfColor.fromInt(0xFFFFFFFF);
    pw.Widget buildHeader() {
      if (headerBgImage != null && headerImage != null) {
        return pw.Container(
          height: 465,
          color: lightGray,
          child: pw.Stack(
            children: [
              // Background image section
              pw.Container(
                width: double.infinity,
                child: pw.Column(children: [pw.Image(headerBgImage, fit: pw.BoxFit.contain)]),
              ),

              pw.Container(
                height: 100,
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  color: darkBlue,
                  borderRadius: const pw.BorderRadius.only(
                    bottomRight: pw.Radius.circular(10),
                    bottomLeft: pw.Radius.circular(10),
                  ),
                ),
                child: pw.Center(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(20),
                    child: pw.Image(headerImage, height: 50, fit: pw.BoxFit.contain),
                  ),
                ),
              ),
              // Header logo/text section with bottom radius
            ],
          ),
        );
      } else {
        // Fallback to colored header with text
        return pw.Container(
          height: 120,
          color: darkBlue,
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.SizedBox(width: 40),
              pw.Text(
                'heimWatt',
                style: pw.TextStyle(color: white, fontSize: 32, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(width: 20),
              pw.Text('Die richtige Entscheidung.', style: pw.TextStyle(color: white, fontSize: 14)),
            ],
          ),
        );
      }
    }

    pw.Widget buildHeader1() {
      return pw.Container(
        height: 100,
        width: double.infinity,
        decoration: pw.BoxDecoration(
          color: darkBlue,
          borderRadius: pw.BorderRadius.only(bottomRight: pw.Radius.circular(10), bottomLeft: pw.Radius.circular(10)),
        ),
        alignment: pw.Alignment.centerLeft,
        child: pw.Padding(
          padding: pw.EdgeInsets.only(left: 50),
          child: headerImage1 != null
              ? pw.Image(headerImage1!, height: 30)
              : pw.Text("heimWatt", style: pw.TextStyle(color: white, fontSize: 24)),
        ),
      );
    }

    pw.Widget buildFooter(int pageNumber, {int totalPages = 1}) {
      return pw.Container(
        color: lightGray,
        padding: pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('heimWatt GmbH', style: pw.TextStyle(color: darkGray, fontSize: 10)),
            pw.Text('$pageNumber/$totalPages', style: pw.TextStyle(color: darkGray, fontSize: 10)),
          ],
        ),
      );
    }

    // PAGE 1: Cover Page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Container(
            child: pw.Column(
              children: [
                buildHeader(),

                // Title section
                pw.Container(
                  width: double.infinity,
                  decoration: pw.BoxDecoration(
                    borderRadius: const pw.BorderRadius.only(
                      bottomRight: pw.Radius.circular(15),
                      bottomLeft: pw.Radius.circular(15),
                    ),
                    color: lightGray,
                  ),
                  padding: const pw.EdgeInsets.symmetric(vertical: 25),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(
                        type == 1
                            ? 'Wärmepumpe'
                            : type == 2
                            ? "Photovoltaik-Anlage"
                            : "Wärmepumpe & Photovoltaik",
                        style: pw.TextStyle(color: darkBlue, fontSize: 35, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        familyName,
                        style: pw.TextStyle(color: lightGreen, fontSize: 17, fontWeight: pw.FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Container(
                    width: double.infinity,
                    decoration: pw.BoxDecoration(
                      borderRadius: const pw.BorderRadius.only(
                        bottomRight: pw.Radius.circular(15),
                        bottomLeft: pw.Radius.circular(15),
                      ),
                      color: white,
                    ),
                    padding: const pw.EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    child: // Status boxes
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                      children: [
                        pw.Expanded(
                          child: pw.Container(
                            height: 70,
                            padding: const pw.EdgeInsets.symmetric(vertical: 10),
                            decoration: pw.BoxDecoration(
                              color: lightGray,
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text('Status', style: pw.TextStyle(color: darkGray, fontSize: 12)),
                                pw.SizedBox(height: 8),
                                pw.Text(
                                  'In Planung',
                                  style: pw.TextStyle(color: darkBlue, fontSize: 15, fontWeight: pw.FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 10),
                        pw.Expanded(
                          child: pw.Container(
                            height: 70,
                            padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                            decoration: pw.BoxDecoration(
                              color: lightGray,
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text('Installationstermin', style: pw.TextStyle(color: darkGray, fontSize: 12)),
                                pw.SizedBox(height: 8),
                                pw.Text(
                                  installationDate,
                                  style: pw.TextStyle(color: darkBlue, fontSize: 15, fontWeight: pw.FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                buildFooter(context.pageNumber, totalPages: context.pagesCount),
              ],
            ),
            color: lightGray,
          );
        },
      ),
    );
    Get.find<InstallationStepsController>().pdfGenerationProgress.value =
        Get.find<InstallationStepsController>().pdfGenerationProgress.value + 0.02;
    // PAGE 2: Project Data
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              // Header with image background
              pw.Container(
                height: 180,
                width: double.infinity,
                color: lightGray,
                child: (page2HeaderBg != null && headerImage1 != null)
                    ? pw.Stack(
                        alignment: pw.Alignment.center,
                        children: [
                          pw.Image(page2HeaderBg, fit: pw.BoxFit.fill),

                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(width: 20),
                              pw.Image(headerImage1, height: 35, fit: pw.BoxFit.contain),
                            ],
                          ),
                        ],
                      )
                    : pw.Container(
                        color: darkBlue,
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 40, top: 40),
                          child: pw.Text(
                            'heimWatt',
                            style: pw.TextStyle(color: white, fontSize: 32, fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ),
              ),
              // Title
              pw.Container(
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  color: lightGray,
                  borderRadius: pw.BorderRadius.only(
                    bottomLeft: pw.Radius.circular(15),
                    bottomRight: pw.Radius.circular(15),
                  ),
                ),
                padding: const pw.EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: pw.Text(
                  'Projektdaten',
                  style: pw.TextStyle(color: darkBlue, fontSize: 29, fontWeight: pw.FontWeight.bold),
                ),
              ),
              // Content
              pw.Expanded(
                child: pw.Container(
                  width: double.infinity,
                  color: white,
                  padding: const pw.EdgeInsets.all(30),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Customer Information
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('Kunde/Kundin', style: pw.TextStyle(color: darkGray, fontSize: 11)),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  customerName,
                                  style: pw.TextStyle(color: darkBlue, fontSize: 15, fontWeight: pw.FontWeight.bold),
                                ),
                                pw.SizedBox(height: 12),
                                pw.Text('eMail-Adresse', style: pw.TextStyle(color: darkGray, fontSize: 11)),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  customerEmail,
                                  style: pw.TextStyle(color: darkBlue, fontSize: 15, fontWeight: pw.FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(width: 20),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('Telefonnummer', style: pw.TextStyle(color: darkGray, fontSize: 11)),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  customerPhone,
                                  style: pw.TextStyle(color: darkBlue, fontSize: 15, fontWeight: pw.FontWeight.bold),
                                ),
                                pw.SizedBox(height: 12),
                                pw.Text('Adresse', style: pw.TextStyle(color: darkGray, fontSize: 11)),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  customerAddressLine1,
                                  style: pw.TextStyle(color: darkBlue, fontSize: 15, fontWeight: pw.FontWeight.bold),
                                ),
                                pw.Text(
                                  customerAddressLine2,
                                  style: pw.TextStyle(color: darkBlue, fontSize: 15, fontWeight: pw.FontWeight.bold),
                                ),
                                pw.Text(
                                  customerAddressLine3,
                                  style: pw.TextStyle(color: darkBlue, fontSize: 15, fontWeight: pw.FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 20),
                      pw.Divider(color: lightGray, height: 2),
                      pw.SizedBox(height: 20),
                      // Project Manager Information
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('Projektbearbeiter*in', style: pw.TextStyle(color: darkGray, fontSize: 11)),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  projectManager,
                                  style: pw.TextStyle(color: darkBlue, fontSize: 15, fontWeight: pw.FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(width: 20),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('Telefonnummer', style: pw.TextStyle(color: darkGray, fontSize: 11)),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  projectManagerPhone,
                                  style: pw.TextStyle(color: darkBlue, fontSize: 15, fontWeight: pw.FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              buildFooter(context.pageNumber, totalPages: context.pagesCount),
            ],
          );
        },
      ),
    );

    /// ---------- IMAGE CACHE ----------
    final Map<String, pw.MemoryImage> imageCache = {};

    Future<pw.MemoryImage> loadPdfImage(String url) async {
      final res = await http.get(Uri.parse(url));
      return pw.MemoryImage(res.bodyBytes);
    }

    for (var category in installationSteps) {
      for (var item in category.data ?? []) {
        for (var imgUrl in item.images ?? []) {
          if (!imageCache.containsKey(imgUrl)) {
            imageCache[imgUrl] = await loadPdfImage(imgUrl);
            Get.find<InstallationStepsController>().pdfGenerationProgress.value =
                Get.find<InstallationStepsController>().pdfGenerationProgress.value + 0.01;
          }
        }
      }
    }

    /// ---------- MULTIPAGE ----------
    pdf.addPage(
      pw.MultiPage(
        margin: pw.EdgeInsets.zero,
        header: (_) => pw.Padding(padding: pw.EdgeInsets.only(bottom: 15), child: buildHeader1()),
        footer: (c) => buildFooter(c.pageNumber, totalPages: c.pagesCount),
        build: (context) {
          List<pw.Widget> widgets = [];
          bool isFirst = true;

          for (var category in installationSteps) {
            if (!isFirst) widgets.add(pw.NewPage());
            isFirst = false;

            widgets.add(
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Container(
                    width: 500,
                    padding: pw.EdgeInsets.symmetric(vertical: 10),
                    child: pw.Text(
                      category.title ?? "",
                      style: pw.TextStyle(color: darkBlue, fontSize: 30, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
            Get.find<InstallationStepsController>().pdfGenerationProgress.value =
                Get.find<InstallationStepsController>().pdfGenerationProgress.value + 0.02;

            for (var item in category.data ?? []) {
              widgets.add(
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Container(
                      width: 500,
                      padding: pw.EdgeInsets.only(bottom: 10),
                      child: pw.Text(item.title ?? "", style: pw.TextStyle(color: lightGreen, fontSize: 16)),
                    ),
                  ],
                ),
              );

              final images = item.images ?? [];
              Get.find<InstallationStepsController>().pdfGenerationProgress.value =
                  Get.find<InstallationStepsController>().pdfGenerationProgress.value + 0.02;

              /// ===== PLACEHOLDER WHEN EMPTY =====
              if (images.isEmpty) {
                widgets.add(
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Container(
                        height: 270,
                        width: 500,
                        decoration: pw.BoxDecoration(
                          borderRadius: pw.BorderRadius.circular(20),
                          border: pw.Border.all(color: darkGray),
                          color: lightGray,
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            "No Images Found!",
                            style: pw.TextStyle(color: darkGray, fontSize: 18, fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                Get.find<InstallationStepsController>().pdfGenerationProgress.value =
                    Get.find<InstallationStepsController>().pdfGenerationProgress.value + 0.02;
              } else {
                /// ===== NORMAL IMAGES =====
                for (var imgUrl in images) {
                  final img = imageCache[imgUrl]!;

                  widgets.add(
                    pw.Padding(
                      padding: pw.EdgeInsets.only(bottom: 8),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.ClipRRect(
                            horizontalRadius: 10,
                            verticalRadius: 10,
                            child: pw.Image(img, height: 270, width: 500, fit: pw.BoxFit.contain),
                            // child: pw.Image(img, height: 270, width: 500, fit: pw.BoxFit.cover),
                          ),
                        ],
                      ),
                    ),
                  );
                  Get.find<InstallationStepsController>().pdfGenerationProgress.value =
                      Get.find<InstallationStepsController>().pdfGenerationProgress.value + 0.02;
                }
              }
            }
          }

          return widgets;
        },
      ),
    );

    Get.find<InstallationStepsController>().pdfGenerationProgress.value =
        Get.find<InstallationStepsController>().pdfGenerationProgress.value + 0.02;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              buildHeader(),

              pw.Container(
                width: double.infinity,
                color: lightGray,
                padding: const pw.EdgeInsets.all(40),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Vielen Dank!',
                      style: pw.TextStyle(color: darkBlue, fontSize: 42, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Container(
                  alignment: pw.Alignment.bottomCenter,
                  width: double.infinity,
                  decoration: pw.BoxDecoration(
                    color: white,
                    borderRadius: pw.BorderRadius.only(
                      bottomLeft: pw.Radius.circular(15),
                      bottomRight: pw.Radius.circular(15),
                    ),
                  ),
                  padding: const pw.EdgeInsets.all(30),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Telefon', style: pw.TextStyle(color: darkGray, fontSize: 12)),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            companyPhone,
                            style: pw.TextStyle(color: darkBlue, fontSize: 14, fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('eMail', style: pw.TextStyle(color: darkGray, fontSize: 12)),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            companyEmail,
                            style: pw.TextStyle(color: darkBlue, fontSize: 14, fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              buildFooter(context.pageNumber, totalPages: context.pagesCount),
            ],
          );
        },
      ),
    );

    return pdf.save();
    // await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }
}
