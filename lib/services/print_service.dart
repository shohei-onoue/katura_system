import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PrintService {
  static String generateOrderHtml(Map<String, dynamic> data) {
    final items = (data['items'] as List<Map<String, dynamic>>);
    final itemsHtml = items.map((item) => 
      "<tr><td style='border-bottom: 1px solid #eee;'>${item['name']}</td><td style='text-align: right; border-bottom: 1px solid #eee;'>${item['quantity']}</td></tr>"
    ).join("");

    final String ticketHtml = """
      <div class="ticket">
        <div class="header">
          <span class="type">${data['deliveryType']}</span>
          <span class="time">${data['deliveryTime']}</span>
        </div>
        <div class="customer">
          <div class="name">${data['name']} 様</div>
          <div class="facility">${data['facility'] ?? ''}</div>
          <div class="address">${data['address']}</div>
          <div class="phone">${data['phone']}</div>
        </div>
        <table class="items">
          $itemsHtml
        </table>
        <div class="footer">
          <div>個数: ${data['totalCount']} | 梱包: ${data['packaging']}</div>
          <div class="remarks">備考: ${data['remarks']}</div>
        </div>
      </div>
    """;

    // A4 grid: 4 rows x 2 columns = 8 tickets
    return """
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        @page { size: A4; margin: 0; }
        body { margin: 0; padding: 0; font-family: 'Helvetica', sans-serif; }
        .grid {
          display: grid;
          grid-template-columns: 105mm 105mm;
          grid-template-rows: 74.25mm 74.25mm 74.25mm 74.25mm;
          width: 210mm;
          height: 297mm;
        }
        .ticket {
          border: 0.1mm solid #ccc;
          padding: 3mm;
          box-sizing: border-box;
          overflow: hidden;
          display: flex;
          flex-direction: column;
        }
        .header { display: flex; justify-content: space-between; border-bottom: 2px solid #000; padding-bottom: 1mm; margin-bottom: 1mm; }
        .type { font-weight: bold; font-size: 14pt; background: #000; color: #fff; padding: 0 2mm; }
        .time { font-weight: bold; font-size: 14pt; }
        .customer { margin-bottom: 2mm; }
        .name { font-weight: bold; font-size: 12pt; }
        .facility { font-size: 9pt; }
        .address { font-size: 8pt; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .phone { font-size: 10pt; font-weight: bold; }
        .items { width: 100%; border-collapse: collapse; font-size: 9pt; flex-grow: 1; }
        .footer { border-top: 1px solid #000; padding-top: 1mm; font-size: 8pt; }
        .remarks { color: #555; font-style: italic; }
      </style>
    </head>
    <body>
      <div class="grid">
        $ticketHtml $ticketHtml $ticketHtml $ticketHtml
        $ticketHtml $ticketHtml $ticketHtml $ticketHtml
      </div>
    </body>
    </html>
    """;
  }

  static Future<void> printOrder(Map<String, dynamic> data) async {
    final htmlContent = generateOrderHtml(data);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => await Printing.convertHtml(
        format: format,
        html: htmlContent,
      ),
    );
  }
}
