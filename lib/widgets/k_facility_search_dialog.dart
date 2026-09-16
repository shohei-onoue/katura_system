import 'package:flutter/material.dart';
import '../services/customer_service.dart';
import 'k_responsive.dart';
import 'k_multimodal_text_field.dart';
import 'package:katura_system/utils/app_colors.dart';

/// 施設・住所検索の結果（施設名・住所・座標）。
class KFacilitySearchResult {
  final String name;
  final String address;
  final double lat;
  final double lng;
  const KFacilitySearchResult({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
  });
}

/// 「地域・カテゴリ」「地域・キーワード」「住所」で施設／住所を検索する共通ダイアログ。
/// 受注フォームの配達先確定ステップと共通利用できるよう独立部品化している。
Future<KFacilitySearchResult?> showKFacilitySearchDialog(
  BuildContext context, {
  int initialTab = 0,
  String initialArea = '',
}) {
  return showDialog<KFacilitySearchResult>(
    context: context,
    builder: (_) => _KFacilitySearchDialog(initialTab: initialTab, initialArea: initialArea),
  );
}

class _KFacilitySearchDialog extends StatefulWidget {
  final int initialTab;
  final String initialArea;
  const _KFacilitySearchDialog({required this.initialTab, required this.initialArea});

  @override
  State<_KFacilitySearchDialog> createState() => _KFacilitySearchDialogState();
}

class _KFacilitySearchDialogState extends State<_KFacilitySearchDialog> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _svc = CustomerService();
  final _areaController = TextEditingController();
  final _keywordController = TextEditingController();
  final _addressController = TextEditingController();

  Map<String, Map<String, List<String>>> _hierarchy = {};
  String? _category;
  String? _genre;

  bool _loading = false;
  List<Map<String, dynamic>> _results = [];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this, initialIndex: widget.initialTab.clamp(0, 2));
    _tab.addListener(() => setState(() {}));
    _areaController.text = widget.initialArea;
    _loadHierarchy();
  }

  Future<void> _loadHierarchy() async {
    final h = await _svc.getAddressService().getCategoryHierarchy();
    if (mounted) setState(() => _hierarchy = h);
  }

  @override
  void dispose() {
    _tab.dispose();
    _areaController.dispose();
    _keywordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _runSearch() async {
    setState(() {
      _loading = true;
      _results = [];
    });
    List<Map<String, dynamic>> results = [];
    try {
      final idx = _tab.index;
      if (idx == 0 || idx == 1) {
        final area = _areaController.text.trim();
        final term = (idx == 0 ? (_genre ?? '') : _keywordController.text).trim();
        if (area.isEmpty || term.isEmpty) {
          if (mounted) setState(() => _loading = false);
          return;
        }
        final raw = await _svc.getGoogleMapsService().searchPlacesByText('$area $term'.trim());
        results = List<Map<String, dynamic>>.from(raw);
      } else {
        final raw = await _svc.getAddressService().searchByAddressOrZip(_addressController.text.trim());
        results = List<Map<String, dynamic>>.from(raw);
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _results = results;
      _loading = false;
    });
  }

  Future<void> _pick(Map<String, dynamic> item) async {
    double? lat = (item['lat'] as num?)?.toDouble();
    double? lng = (item['lng'] as num?)?.toDouble();
    final address = (item['address'] ?? '').toString();
    if ((lat == null || lat == 0) && address.isNotEmpty) {
      final geo = await _svc.getGoogleMapsService().getLatLngFromAddress(address);
      lat = (geo?['lat'] as num?)?.toDouble();
      lng = (geo?['lng'] as num?)?.toDouble();
    }
    if (!mounted) return;
    Navigator.pop(
      context,
      KFacilitySearchResult(
        name: (item['name'] ?? '').toString(),
        address: address,
        lat: lat ?? 0,
        lng: lng ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.popupBackground,
      child: SizedBox(
        width: rs(context, 560),
        height: rs(context, 640),
        child: Column(
          children: [
            Container(
              color: const Color(0xFF000038),
              padding: EdgeInsets.symmetric(horizontal: rs(context, 16), vertical: rs(context, 10)),
              child: Row(
                children: [
                  Text('施設・住所の検索',
                      style: TextStyle(color: AppColors.background, fontWeight: FontWeight.bold, fontSize: rf(context, 15))),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close, color: AppColors.background), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            TabBar(
              controller: _tab,
              labelColor: const Color(0xFF000038),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF000038),
              labelStyle: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: '地域・カテゴリ'),
                Tab(text: '地域・キーワード'),
                Tab(text: '住所'),
              ],
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: EdgeInsets.all(rs(context, 16)),
                child: TabBarView(
                  controller: _tab,
                  children: [
                    _categoryTab(context),
                    _keywordTab(context),
                    _addressTab(context),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: rs(context, 16)),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _runSearch,
                  icon: const Icon(Icons.search),
                  label: const Text('検索'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000038),
                    foregroundColor: AppColors.background,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty
                      ? Center(child: Text('検索結果なし', style: TextStyle(color: Colors.grey, fontSize: rf(context, 13))))
                      : ListView.separated(
                          padding: EdgeInsets.all(rs(context, 12)),
                          itemCount: _results.length,
                          separatorBuilder: (context, index) => Divider(height: rs(context, 1)),
                          itemBuilder: (context, i) {
                            final it = _results[i];
                            return ListTile(
                              dense: true,
                              title: Text('${it['name']}',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 13))),
                              subtitle: Text('${it['address']}', style: TextStyle(fontSize: rf(context, 12))),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _pick(it),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _labeledField(BuildContext context, String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        SizedBox(height: rs(context, 6)),
        child,
        SizedBox(height: rs(context, 14)),
      ],
    );
  }

  Widget _areaField(BuildContext context) => _labeledField(
        context,
        '地域（都道府県・市区町村）',
        KMultimodalTextField(
          label: '',
          showLabel: false,
          controller: _areaController,
          maxLines: 1,
          height: rs(context, 52),
        ),
      );

  Widget _categoryTab(BuildContext context) {
    final cats = _hierarchy.keys.toList();
    final genres = (_category != null ? _hierarchy[_category]?.keys.toList() : const <String>[]) ?? const <String>[];
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _areaField(context),
          _labeledField(
            context,
            'カテゴリ',
            DropdownButtonFormField<String>(
              initialValue: _category,
              isExpanded: true,
              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
              items: cats.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() {
                _category = v;
                _genre = null;
              }),
            ),
          ),
          _labeledField(
            context,
            'ジャンル',
            DropdownButtonFormField<String>(
              initialValue: _genre,
              isExpanded: true,
              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
              items: genres.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (v) => setState(() => _genre = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _keywordTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _areaField(context),
          _labeledField(
            context,
            'キーワード',
            KMultimodalTextField(
              label: '',
              showLabel: false,
              controller: _keywordController,
              maxLines: 1,
              height: rs(context, 52),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addressTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _labeledField(
            context,
            '住所・郵便番号',
            KMultimodalTextField(
              label: '',
              showLabel: false,
              controller: _addressController,
              maxLines: 1,
              height: rs(context, 52),
            ),
          ),
        ],
      ),
    );
  }
}
