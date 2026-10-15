import 'package:flutter/material.dart';
import 'package:katura_system/utils/app_colors.dart';
import '../../../../services/customer_service.dart';
import '../../../../widgets/k_dialog_title.dart';
import '../../../../widgets/k_responsive.dart';
import 'delivery_destination_step.dart' show FacilitySearchForm;

/// 施設・住所の検索結果（施設名・住所・座標）。
class KFacilitySearchResult {
  final String name;
  final String address;
  final double lat;
  final double lng;
  const KFacilitySearchResult({required this.name, required this.address, required this.lat, required this.lng});
}

/// 受注入力「配達先の新規登録」と同じ検索フォーム（FacilitySearchForm）を、独立したダイアログで開く。
/// 受注画面以外（顧客詳細など）から企業・住所を検索して選ぶときに使う。
Future<KFacilitySearchResult?> showFacilitySearchHostDialog(BuildContext context, {int initialTab = 0, String title = '配達先の検索'}) {
  return showDialog<KFacilitySearchResult>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _FacilitySearchHostDialog(initialTab: initialTab, title: title),
  );
}

class _FacilitySearchHostDialog extends StatefulWidget {
  final int initialTab;
  final String title;
  const _FacilitySearchHostDialog({required this.initialTab, required this.title});

  @override
  State<_FacilitySearchHostDialog> createState() => _FacilitySearchHostDialogState();
}

class _FacilitySearchHostDialogState extends State<_FacilitySearchHostDialog> {
  final _svc = CustomerService();
  final _facilityController = TextEditingController();
  final _keywordController = TextEditingController();
  final _results = ValueNotifier<List<Map<String, dynamic>>>([]);
  final _loading = ValueNotifier<bool>(false);

  late int _tab;
  List<String> _prefList = [];
  String _pref = '';
  String _city = '';
  String _town = '（すべて）';
  String? _category;
  String? _genre;
  String _selectedAddress = '';

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab.clamp(0, 2);
    _svc.getAddressService().getPrefecturesByInitial('すべて').then((l) {
      if (mounted) setState(() => _prefList = l);
    });
  }

  @override
  void dispose() {
    _facilityController.dispose();
    _keywordController.dispose();
    _results.dispose();
    _loading.dispose();
    super.dispose();
  }

  Future<List<String>> _updateCities(String pref, String initial) async {
    final list = await _svc.getAddressService().getCitiesByInitial(pref, initial);
    if (mounted) setState(() { _pref = pref; _city = ''; _town = '（すべて）'; });
    return list;
  }

  Future<List<String>> _updateTowns(String pref, String city, String initial) async {
    final list = await _svc.getAddressService().getTownsByInitial(pref, city, initial);
    if (mounted) setState(() { _pref = pref; _city = city; _town = '（すべて）'; });
    return list;
  }

  Future<void> _search() async {
    _loading.value = true;
    _results.value = [];
    List<Map<String, dynamic>> results = [];
    try {
      final town = (_town == '（すべて）' || _town.isEmpty) ? '' : _town;
      final area = '$_pref$_city$town'.trim();
      final term = (_tab == 0 ? (_genre ?? '') : _keywordController.text).trim();
      if (area.isNotEmpty && term.isNotEmpty) {
        final raw = await _svc.getGoogleMapsService().searchPlacesPage('$area $term'.trim());
        results = raw.results.map((i) => {...i, 'isNearby': !('${i['address'] ?? ''}'.contains(_pref))}).toList();
      }
    } catch (_) {}
    if (!mounted) return;
    _loading.value = false;
    _results.value = results;
  }

  /// 「施設名: 住所 (緯度, 経度)」形式の選択結果を分解して、呼び出し元へ返す。
  Future<void> _onSelected(String payload) async {
    final clean = payload.replaceAll(RegExp(r'\[(KW|NEAR|OTH):[^\]]*\]'), '').trim();
    final idx = clean.indexOf(': ');
    final name = idx >= 0 ? clean.substring(0, idx).trim() : '個人宅';
    var rest = idx >= 0 ? clean.substring(idx + 2) : clean;
    double lat = 0, lng = 0;
    final m = RegExp(r'[(（]([-+]?\d*\.?\d+),\s*([-+]?\d*\.?\d+)[)）]\s*$').firstMatch(rest);
    if (m != null) {
      lat = double.tryParse(m.group(1)!) ?? 0;
      lng = double.tryParse(m.group(2)!) ?? 0;
      rest = rest.substring(0, m.start).trim();
    }
    if (mounted) setState(() => _selectedAddress = rest); // 住所を即時に反映
    if (lat == 0 && lng == 0 && rest.isNotEmpty) {
      final geo = await _svc.getGoogleMapsService().getLatLngFromAddress(rest);
      lat = (geo?['lat'] as num?)?.toDouble() ?? 0;
      lng = (geo?['lng'] as num?)?.toDouble() ?? 0;
    }
    if (!mounted) return;
    Navigator.pop(context, KFacilitySearchResult(name: name, address: rest, lat: lat, lng: lng));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.popupBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 16))),
      child: Container(
        width: rs(context, 640),
        padding: EdgeInsets.all(rs(context, 24)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  KDialogTitle(widget.title),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              Divider(height: rs(context, 24)),
              FacilitySearchForm(
                facilityControllerText: _facilityController.text,
                facilityController: _facilityController,
                addressControllerText: _selectedAddress,
                prefList: _prefList,
                searchPrefecture: _pref,
                searchCity: _city,
                searchTown: _town,
                searchCategory: _category,
                searchGenre: _genre,
                searchTabIndex: _tab,
                keywordQueryController: _keywordController,
                facilityResultsListenable: _results,
                isLoadingListenable: _loading,
                onAddressSelected: _onSelected,
                onSearchTabChanged: (v) => setState(() => _tab = v),
                onPrefChanged: (v) => _updateCities(v, 'すべて'),
                onCityChanged: (v) => _updateTowns(_pref, v, 'すべて'),
                onTownChanged: (v) => setState(() => _town = v),
                onAddressConfirmed: (p, c, t) => setState(() { _pref = p; _city = c; _town = t; }),
                onPrefInitialChanged: (i) async {
                  final l = await _svc.getAddressService().getPrefecturesByInitial(i);
                  if (mounted) setState(() => _prefList = l);
                  return l;
                },
                onCityInitialChanged: _updateCities,
                onTownInitialChanged: _updateTowns,
                onCategoryChanged: (v) => setState(() { _category = v; _genre = null; }),
                onGenreChanged: (v) => setState(() => _genre = v),
                onSearchSubmit: _search,
                onDialogVisibilityChanged: (_) {},
                onAdjustTap: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
