import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/chat_session.dart';
import '../models/message.dart';

class PdfService {
  static Future<void> exportChatToPdf(ChatSession session) async {
    final pdf = pw.Document();

    // Define colors to match app branding
    final primaryColor = PdfColor.fromInt(0xFF6B4EFF);
    final surfaceColor = PdfColor.fromInt(0xFF1C1C1E);
    final textColor = PdfColor.fromInt(0xFFFFFFFF);
    final secondaryTextColor = PdfColor.fromInt(0xFF8E8E93);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          padding: const pw.EdgeInsets.only(bottom: 20),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'AI CHAT EXPORT',
                style: pw.TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                session.createdAt.toString().split('.')[0],
                style: pw.TextStyle(color: secondaryTextColor, fontSize: 10),
              ),
            ],
          ),
        ),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  session.title,
                  style: pw.TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Container(height: 2, width: 40, color: primaryColor),
                pw.SizedBox(height: 24),
              ],
            ),
          ),
          ...session.messages.map((msg) {
            final isUser = msg.sender == MessageSender.user;
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 16),
              child: pw.Row(
                mainAxisAlignment: isUser
                    ? pw.MainAxisAlignment.end
                    : pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (!isUser)
                    pw.Container(
                      width: 20,
                      height: 20,
                      margin: const pw.EdgeInsets.only(right: 8, top: 2),
                      decoration: pw.BoxDecoration(
                        color: primaryColor,
                        shape: pw.BoxShape.circle,
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          'AI',
                          style: pw.TextStyle(color: textColor, fontSize: 8),
                        ),
                      ),
                    ),
                  pw.Flexible(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: isUser ? surfaceColor : null,
                        borderRadius: pw.BorderRadius.circular(12),
                        border: !isUser
                            ? pw.Border.all(color: surfaceColor, width: 1)
                            : null,
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (!isUser)
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 4),
                              child: pw.Text(
                                msg.modelName.toUpperCase(),
                                style: pw.TextStyle(
                                  color: primaryColor,
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          pw.Text(
                            msg.text,
                            style: pw.TextStyle(
                              color: isUser ? textColor : PdfColors.black,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isUser)
                    pw.Container(
                      width: 20,
                      height: 20,
                      margin: const pw.EdgeInsets.only(left: 8, top: 2),
                      decoration: pw.BoxDecoration(
                        color: surfaceColor,
                        shape: pw.BoxShape.circle,
                        border: pw.Border.all(color: primaryColor, width: 1),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          'ME',
                          style: pw.TextStyle(color: textColor, fontSize: 8),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File(
      "${output.path}/chat_export_${session.id.substring(0, 8)}.pdf",
    );
    await file.writeAsBytes(await pdf.save());

    await OpenFile.open(file.path);
  }
}
