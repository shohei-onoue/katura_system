import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/branch_model.dart';
import '../services/branch_service.dart';
import '../services/receipt_service.dart';
import 'k_responsive.dart';
import 'package:katura_system/utils/app_colors.dart';

/// 受注内容から領収書HTMLを生成し、WebViewでプレビュー・印刷するダイアログ。
class KReceiptPreviewDialog extends StatefulWidget {
  final String branchName;
  final String recipientName; // 宛名
  final String recipientHonorific; // 御中 / 様
  final int totalPrice; // 税込合計
  final List<Map<String, dynamic>> items;
  final String paymentMethod; // 現金 / カード
  final DateTime issueDate;

  const KReceiptPreviewDialog({
    super.key,
    required this.branchName,
    required this.recipientName,
    this.recipientHonorific = '御中',
    required this.totalPrice,
    required this.items,
    required this.paymentMethod,
    required this.issueDate,
  });

  @override
  State<KReceiptPreviewDialog> createState() => _KReceiptPreviewDialogState();
}

class _KReceiptPreviewDialogState extends State<KReceiptPreviewDialog> {
  final _branchService = BranchService();
  final _receiptService = ReceiptService();
  BranchModel? _branch;
  WebViewController? _controller;
  bool _loading = true;
  bool _printing = false;
  int _issueNo = 1; // この領収書に付く通し番号（発行数 + 1）

  /// B5横（257mm × 182mm）
  static final PdfPageFormat _b5Landscape =
      PdfPageFormat(257 * PdfPageFormat.mm, 182 * PdfPageFormat.mm);

  /// 店舗別の発行者情報（会社名・登録番号）。登録番号は店舗ごとに要設定。
  static const Map<String, Map<String, String>> _issuerByBranch = {
    '名古屋店': {'company': '株式会社 AXIS', 'registrationNumber': 'T2180301040543'},
    '岡崎本店': {'company': '株式会社 AXIS', 'registrationNumber': ''},
    '岐阜店': {'company': '株式会社 AXIS', 'registrationNumber': ''},
  };

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    BranchModel? branch;
    try {
      final branches = await _branchService.getAllBranches();
      for (final b in branches) {
        if (b.name == widget.branchName) {
          branch = b;
          break;
        }
      }
    } catch (_) {}
    final issued = await _receiptService.issuedCount();
    final no = issued + 1;
    final html = _buildHtml(branch, no);
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..setBackgroundColor(const Color(0xFFE5E5E5))
      ..loadHtmlString(html);
    if (!mounted) return;
    setState(() {
      _branch = branch;
      _issueNo = no;
      _controller = controller;
      _loading = false;
    });
  }

  Future<void> _print() async {
    if (_printing) return;
    setState(() => _printing = true);
    try {
      // 印刷時に採番を確定（発行数を加算）し、確定番号でHTMLを再生成
      final committedNo = await _receiptService.issue();
      final html = _buildHtml(_branch, committedNo);
      if (mounted) {
        setState(() => _issueNo = committedNo);
        await _controller?.loadHtmlString(html);
      }
      await Printing.layoutPdf(
        name: '領収書_${widget.branchName}_${_no4(committedNo)}',
        format: _b5Landscape,
        onLayout: (format) => Printing.convertHtml(format: format, html: html),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('印刷に失敗しました: $e')));
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  /// 通し番号を4桁ゼロ埋め表示にする。
  String _no4(int n) => n.toString().padLeft(4, '0');

  String _yen(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  String _esc(String s) =>
      s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

  String _buildHtml(BranchModel? branch, int issueNo) {
    final issuer = _issuerByBranch[widget.branchName] ??
        const {'company': '株式会社 AXIS', 'registrationNumber': ''};
    // 社名は店舗設定（BranchModel.companyName）優先。未設定時のみ既定値にフォールバック。
    final branchCompany = branch?.companyName ?? '';
    final company =
        _esc(branchCompany.isNotEmpty ? branchCompany : (issuer['company'] ?? '株式会社 AXIS'));
    final registrationNumber = _esc(issuer['registrationNumber'] ?? '');
    final shopName = _esc('肉弁当専門店かつら ${widget.branchName}');
    final address = _esc(branch?.address ?? '');
    final tel = _esc(branch?.phone ?? '');

    final d = widget.issueDate;
    final dateStr = '${d.year}/${d.month}/${d.day}';
    final receiptNo = _no4(issueNo);

    // 但し書きは「御弁当」固定表記。金額（単価）ごとに集計し、違う金額は改行して表示。
    final Map<int, int> qtyByPrice = {};
    for (final i in widget.items) {
      final price = (i['price'] is num) ? (i['price'] as num).toInt() : 0;
      final qty = (i['quantity'] is num) ? (i['quantity'] as num).toInt() : 0;
      qtyByPrice[price] = (qtyByPrice[price] ?? 0) + qty;
    }
    final priceEntries = qtyByPrice.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    final provisoLines = priceEntries.isEmpty
        ? ['<div>但　御弁当代として</div>']
        : [
            for (var idx = 0; idx < priceEntries.length; idx++)
              '<div>${idx == 0 ? '但　' : '　　'}御弁当${_yen(priceEntries[idx].key)}円×${priceEntries[idx].value}名様分</div>'
          ];
    final provisoItemsHtml = provisoLines.join();

    final tax = (widget.totalPrice * 8 / 108).round();

    final provisoPayment = widget.paymentMethod.isEmpty
        ? '上記正に領収いたしました。'
        : '上記正に【${_esc(widget.paymentMethod)}支払いにて】領収いたしました。';

    return '''<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>領収書 - 肉弁当専門店かつら ${_esc(widget.branchName)}</title>
<style>
  /* 印刷・用紙設定 (B5横) */
  @page {
    size: 257mm 182mm;
    margin: 0;
  }

  * {
    box-sizing: border-box;
    -webkit-print-color-adjust: exact;
    print-color-adjust: exact;
  }

  body {
    margin: 0;
    padding: 30px;
    background-color: #e5e5e5;
    font-family: "Yu Mincho", "YuMincho", "Hiragino Mincho ProN", "MS PMincho", serif;
    color: #1a1a1a;
    display: flex;
    justify-content: center;
  }

  /* 領収書用紙本体（B5横・上下左右の余白を均等に） */
  .receipt-sheet {
    background-color: #ffffff;
    width: 257mm;
    height: 182mm;
    padding: 18mm;
    position: relative;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.15);
    display: flex;
    flex-direction: column;
    overflow: hidden;
  }

  @media print {
    html, body {
      width: 257mm;
      height: 182mm;
      margin: 0;
      padding: 0;
      background: none;
      overflow: hidden;
    }
    /* 用紙(257×182mm)より一回り小さくして中央配置。
       上下左右2mm + padding16mm = 余白18mm均等。はみ出しによる2ページ目を防止 */
    .receipt-sheet {
      box-shadow: none;
      width: 253mm;
      height: 178mm;
      margin: 2mm auto;
      padding: 16mm;
      overflow: hidden;
      page-break-inside: avoid;
      break-inside: avoid;
      page-break-after: avoid;
    }
  }

  /* 画面プレビュー: 用紙(B5横 972×688px ≒ 257×182mm)と同比率で全体を表示 */
  @media screen {
    html, body {
      width: 972px;
      height: 688px;
      overflow: hidden;
    }
    body {
      padding: 0;
      display: block;
      background-color: #e5e5e5;
    }
    .receipt-sheet {
      width: 972px;
      height: 688px;
      box-shadow: none;
    }
  }

  /* タイトル */
  .title {
    text-align: center;
    font-size: 30pt;
    font-weight: 700;
    letter-spacing: 0.6em;
    margin-right: -0.6em; /* 字間補正 */
    margin-top: 0;
    margin-bottom: 14px;
  }

  /* ヘッダーブロック（宛名・No・発行日） */
  .header-container {
    display: flex;
    justify-content: space-between;
    align-items: flex-end;
    margin-bottom: 18px;
  }

  .recipient-block {
    display: flex;
    align-items: baseline;
    font-size: 17pt;
    font-weight: 600;
    border-bottom: 2px solid #000;
    padding-bottom: 4px;
    min-width: 52%;
  }

  .recipient-name {
    letter-spacing: 0.05em;
  }

  .recipient-honorific {
    margin-left: auto;
    padding-left: 16px;
    font-size: 14pt;
  }

  .meta-block {
    font-size: 12pt;
    line-height: 1.6;
    text-align: left;
    margin-left: auto;
  }

  .meta-row {
    display: flex;
    gap: 18px;
  }

  /* 金額ブロック */
  .amount-container {
    text-align: center;
    margin: 16px 0 12px 0;
  }

  .amount-wrapper {
    display: inline-block;
    border-bottom: 2px solid #000000;
    padding: 0 50px 4px 50px;
  }

  .amount-label {
    font-size: 16pt;
    font-weight: bold;
    letter-spacing: 0.3em;
    margin-right: 16px;
  }

  .amount-val {
    font-size: 24pt;
    font-weight: bold;
    letter-spacing: 0.05em;
  }

  /* 但し書き文面 */
  .proviso-block {
    text-align: center;
    font-size: 12pt;
    line-height: 1.7;
    margin-bottom: 16px;
    letter-spacing: 0.02em;
  }

  /* 金額違いの明細行。数行ぶんの高さを確保して下部余白を安定させる */
  .proviso-items {
    min-height: 4em;
  }

  .proviso-payment {
    margin-top: 4px;
  }

  /* 下部セクション（印紙・内訳・発行者）: 下端に配置して上下余白を均等に */
  .footer-container {
    display: flex;
    justify-content: space-between;
    align-items: flex-end;
    margin-top: auto;
  }

  .footer-left {
    display: flex;
    align-items: flex-start;
    gap: 18px;
  }

  /* 収入印紙枠 */
  .stamp-frame {
    width: 58px;
    height: 68px;
    border: 1px solid #777;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    font-size: 10pt;
    color: #666;
    line-height: 1.35;
    letter-spacing: 0.25em;
    padding-left: 0.25em;
  }

  /* 内訳表 */
  .breakdown-area {
    font-size: 10pt;
    line-height: 1.45;
  }

  .breakdown-table {
    border-bottom: 1px solid #000;
    padding-bottom: 3px;
    margin-bottom: 3px;
    width: 210px;
  }

  .breakdown-row {
    display: flex;
    justify-content: space-between;
    margin-bottom: 1px;
  }

  .breakdown-title {
    letter-spacing: 0.4em;
  }

  .tax-note {
    font-size: 9pt;
    letter-spacing: 0.02em;
  }

  /* 発行者情報エリア */
  .issuer-area {
    position: relative;
    font-size: 10.5pt;
    line-height: 1.5;
    text-align: left;
    padding-right: 14px;
  }

  .issuer-company {
    font-weight: 600;
  }

  .issuer-shop {
    font-weight: 600;
    margin-bottom: 3px;
  }
</style>
</head>
<body>

<div class="receipt-sheet">
  <!-- タイトル -->
  <h1 class="title">領収書</h1>

  <!-- 宛名 ＆ No/日付 -->
  <div class="header-container">
    <div class="recipient-block">
      <span class="recipient-name">${_esc(widget.recipientName)}</span>
      <span class="recipient-honorific">${_esc(widget.recipientHonorific)}</span>
    </div>
    <div class="meta-block">
      <div class="meta-row"><span>No.</span><span>$receiptNo</span></div>
      <div class="meta-row"><span>発行日</span><span>$dateStr</span></div>
    </div>
  </div>

  <!-- 金額表示 -->
  <div class="amount-container">
    <div class="amount-wrapper">
      <span class="amount-label">金額</span>
      <span class="amount-val">¥${_yen(widget.totalPrice)}-</span>
    </div>
  </div>

  <!-- 但し書き（金額違いは改行。下部余白は確保） -->
  <div class="proviso-block">
    <div class="proviso-items">$provisoItemsHtml</div>
    <div class="proviso-payment">$provisoPayment</div>
  </div>

  <!-- 下部（印紙枠・内訳・発行者） -->
  <div class="footer-container">
    <div class="footer-left">
      <!-- 印紙枠 -->
      <div class="stamp-frame">
        <div>印紙</div>
        <div>税入</div>
      </div>

      <!-- 内訳表 -->
      <div class="breakdown-area">
        <div class="breakdown-table">
          <div class="breakdown-row">
            <span class="breakdown-title">内訳</span>
            <span></span>
          </div>
          <div class="breakdown-row">
            <span>消費税額8%</span>
            <span>¥${_yen(tax)}-</span>
          </div>
        </div>
        <div class="tax-note">※軽減税率8%対象商品</div>
      </div>
    </div>

    <!-- 発行者情報とスタンプ -->
    <div class="issuer-area">
      <div class="issuer-company">$company</div>
      <div class="issuer-shop">$shopName</div>
      <div>$address</div>
      <div>TEL:$tel</div>
      <div>登録番号:$registrationNumber</div>
    </div>
  </div>
</div>

</body>
</html>''';
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    return Dialog(
      insetPadding: EdgeInsets.all(rs(context, 12)),
      backgroundColor: AppColors.popupBackground,
      child: SizedBox(
        width: screen.width,
        height: screen.height,
        child: Scaffold(
          backgroundColor: AppColors.popupBackground,
          appBar: AppBar(
            title: Text('領収書プレビュー  No.${_no4(_issueNo)}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: AppColors.popupBackground,
            foregroundColor: Colors.black,
            elevation: 0,
            actions: [
              TextButton.icon(
                onPressed: (_loading || _printing) ? null : _print,
                icon: const Icon(Icons.print),
                label: const Text('印刷'),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(width: rs(context, 8)),
            ],
          ),
          body: _loading || _controller == null
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  color: const Color(0xFFE5E5E5),
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(rs(context, 16)),
                  // 用紙全体(972×688px = B5横相当)を画面内に収まるよう縮小表示（スクロールなし）
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 12)],
                      ),
                      child: SizedBox(
                        width: 972,
                        height: 688,
                        child: WebViewWidget(controller: _controller!),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
