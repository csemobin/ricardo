/*
import 'dart:io';
import 'dart:ui';

Future<void> createInvoicePDF({required Map<String, dynamic> items}) async {
  final PdfDocument document = PdfDocument();
  final PdfPage page = document.pages.add();
  final PdfGraphics graphics = page.graphics;

  // Fonts
  final titleFont =
  PdfStandardFont(PdfFontFamily.helvetica, 22, style: PdfFontStyle.bold);
  final boldFont =
  PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
  final normalFont = PdfStandardFont(PdfFontFamily.helvetica, 12);

  double y = 0;

  // Header Section
  graphics.drawRectangle(
    brush: PdfSolidBrush(PdfColor(133, 100, 255)),
    bounds: Rect.fromLTWH(0, y, page.getClientSize().width, 100),
  );
  graphics.drawString('BOOKING INVOICE', titleFont,
      bounds: Rect.fromLTWH(20, y + 20, 300, 40), brush: PdfBrushes.white);
  graphics.drawString('Date: ${items['date']}', normalFont,
      bounds: Rect.fromLTWH(20, y + 60, 300, 60), brush: PdfBrushes.white);
  y += 120;

  // Table Header
  graphics.drawRectangle(
    brush: PdfSolidBrush(PdfColor(133, 100, 255)),
    bounds: Rect.fromLTWH(0, y, page.getClientSize().width, 20),
  );
  graphics.drawString('ITEM DESCRIPTION', boldFont,
      bounds: Rect.fromLTWH(20, y, 150, 20), brush: PdfBrushes.white);
  graphics.drawString('QTY', boldFont,
      bounds: Rect.fromLTWH(250, y, 50, 20), brush: PdfBrushes.white);
  graphics.drawString('PRICE', boldFont,
      bounds: Rect.fromLTWH(400, y, 70, 20), brush: PdfBrushes.white);
  y += 50;

  // Table Rows
  graphics.drawString('${items['name']}', normalFont,
      bounds: Rect.fromLTWH(20, y, 200, 20));
  graphics.drawString('1', normalFont, bounds: Rect.fromLTWH(250, y, 50, 20));
  graphics.drawString('\$${items['price']}', normalFont,
      bounds: Rect.fromLTWH(400, y, 70, 20));
  y += 50;

  // Separator Line
  graphics.drawLine(PdfPen(PdfColor(200, 200, 200)), Offset(20, y),
      Offset(page.getClientSize().width - 20, y));
  y += 40;

  // Booking Details
  graphics.drawString('BOOKING DETAILS', boldFont,
      bounds: Rect.fromLTWH(20, y, 200, 20));
  graphics.drawString('Location: ${items['location']}', normalFont,
      bounds: Rect.fromLTWH(20, y + 20, 200, 40));

  // Footer
  graphics.drawString('📞 +123-456-7890', normalFont,
      bounds: Rect.fromLTWH(20, y + 70, 200, 20));
  graphics.drawString('✉ business@domain.com', normalFont,
      bounds: Rect.fromLTWH(20, y + 90, 200, 20));
  graphics.drawString('📍 Address', normalFont,
      bounds: Rect.fromLTWH(20, y + 110, 200, 20));
  graphics.drawString('🌐 website.com', normalFont,
      bounds: Rect.fromLTWH(20, y + 130, 200, 20));

  // Save PDF
  final bytes = await document.save();
  document.dispose();

  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/booking_invoice.pdf';
  final file = File(path);
  await file.writeAsBytes(bytes);

  print('📄 PDF saved to: $path');
  await OpenFile.open(path);
}
*/
