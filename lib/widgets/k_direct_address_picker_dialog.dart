import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'k_button.dart';
import 'k_dialog_title.dart';
import 'k_responsive.dart';
import 'k_dial_pad.dart';
import '../services/address_service.dart';
import 'package:katura_system/utils/app_colors.dart';
import '../screens/phone/phone_common.dart';
import '../screens/phone/phone_customer_style.dart';

/// 住所・郵便番号から住所を確定する共有ダイヤログ。
/// 受注入力「配達先の確定」ステップの「住所検索」で使用しているものと同一。
/// [onAddressConfirmed] には「都道府県＋市区町村＋町名＋詳細住所」を連結した文字列を返す。
class KDirectAddressPickerDialog extends StatefulWidget {
  final String initialPref;
  final String initialCity;
  final String initialTown;
  final Function(String) onAddressConfirmed;

  const KDirectAddressPickerDialog({
    super.key,
    required this.initialPref,
    required this.initialCity,
    required this.initialTown,
    required this.onAddressConfirmed,
  });

  @override
  State<KDirectAddressPickerDialog> createState() => _KDirectAddressPickerDialogState();
}

class _KDirectAddressPickerDialogState extends State<KDirectAddressPickerDialog> {
  int phase = 0; // 0: Pref, 1: City, 2: Town, 3: 字・丁目など(その他), 4: 番地住所
  bool isNumericMode = false; // Zip入力中かどうか
  String tempZip = "";
  String tempPref = "";
  String tempCity = "";
  String tempTown = "";
  String tempDetail = "";
  String tempOther = ""; // 字・丁目など（任意）
  bool _otherDone = false;
  List<({String town, String detail})> _azaCandidates = [];
  bool _azaLoading = false;
  bool _azaAllTown = false;
  String selectedInitial = 'すべて';
  List<String> items = [];
  List<Map<String, dynamic>> zipResults = [];
  bool isSearching = false;

  final _addressService = AddressService();

  final Map<String, List<String>> kanaMap = {
    'あ': ['あ', 'い', 'う', 'え', 'お'],
    'か': ['か', 'き', 'く', 'け', 'こ'],
    'さ': ['さ', 'し', 'す', 'せ', 'そ'],
    'た': ['た', 'ち', 'つ', 'て', 'と'],
    'な': ['な', 'に', 'ぬ', 'ね', 'の'],
    'は': ['は', 'ひ', 'ふ', 'へ', 'ほ'],
    'ま': ['ま', 'み', 'む', 'め', 'も'],
    'や': ['や', 'ゆ', 'よ'],
    'ら': ['ら', 'り', 'る', 'れ', 'ろ'],
    'わ': ['わ', 'を', 'ん'],
  };

  @override
  void initState() {
    super.initState();
    tempPref = widget.initialPref;
    tempCity = widget.initialCity;
    tempTown = widget.initialTown;

    if (tempPref.isNotEmpty && tempCity.isNotEmpty) {
      phase = 2; // 町名選択から開始
      _loadTowns();
    } else if (tempPref.isNotEmpty) {
      phase = 1; // 市区町村選択から開始
      _loadCities();
    } else {
      phase = 0;
      _loadInitialData();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => isSearching = true);
    final prefs = await _addressService.getPrefectures();
    setState(() {
      items = prefs;
      isSearching = false;
    });
  }

  Future<void> _loadCities() async {
    setState(() => isSearching = true);
    final newList = await _addressService.getCitiesByInitial(tempPref, 'すべて');
    setState(() {
      items = newList;
      isSearching = false;
    });
  }

  Future<void> _loadTowns() async {
    setState(() => isSearching = true);
    final newList = await _addressService.getTownsByInitial(tempPref, tempCity, 'すべて');
    setState(() {
      items = ['（すべて）', ...newList];
      isSearching = false;
    });
  }

  String get _townText => tempTown == '（すべて）' ? '' : tempTown;
  String get _fullAddress => '$tempPref$tempCity$_townText$tempOther$tempDetail';

  /// 「その他（字・丁目など）」ステップに入るとき候補を読み込む。候補がなくてもスキップしない。
  Future<void> _loadAza() async {
    setState(() {
      _azaLoading = true;
      tempOther = '';
      _otherDone = false;
      _azaCandidates = [];
      _azaAllTown = tempTown == '（すべて）';
    });
    try {
      final list = tempCity.isEmpty ? <({String town, String detail})>[] : await _addressService.getAzaCandidates(tempPref, tempCity, _townText);
      if (mounted) setState(() => _azaCandidates = list);
    } catch (e) {
      debugPrint('aza load error: $e');
    }
    if (mounted) setState(() => _azaLoading = false);
  }

  void _goNextFromAza() {
    setState(() {
      _otherDone = true;
      phase = 4;
    });
  }

  void _confirmNow() {
    widget.onAddressConfirmed(_fullAddress);
    Navigator.pop(context);
  }

  List<String> get _azaLabels => [
        'なし',
        for (final c in _azaCandidates) _azaAllTown ? '${c.town}${c.detail}' : c.detail,
      ];

  void _selectAzaLabel(String label) {
    final i = _azaLabels.indexOf(label);
    setState(() {
      if (i <= 0) {
        tempOther = '';
      } else {
        final c = _azaCandidates[i - 1];
        tempOther = c.detail;
        if (_azaAllTown) tempTown = c.town;
      }
    });
  }

  /// 町名が検索結果に無い場合の追加検索：NAVITIMEを外部で開き、町名を入力して端末に保存する。
  Future<void> _addTownByNavitime() async {
    try {
      await launchUrl(_addressService.buildNavitimeSearchUri(tempPref, tempCity, ''), mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('navitime open error: $e');
    }
    if (!mounted) return;
    final townCtrl = TextEditingController();
    final kanaCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('町名を追加'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: townCtrl, decoration: const InputDecoration(labelText: '町名・字')),
            TextField(controller: kanaCtrl, decoration: const InputDecoration(labelText: '読み（ひらがな・任意）')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('キャンセル')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('追加')),
        ],
      ),
    );
    final town = townCtrl.text.trim();
    final kana = kanaCtrl.text.trim();
    townCtrl.dispose();
    kanaCtrl.dispose();
    if (ok != true || town.isEmpty || !mounted) return;
    await _addressService.saveCustomTown(tempPref, tempCity, town, townKana: kana);
    if (!mounted) return;
    setState(() {
      selectedInitial = 'すべて';
      isSearching = true;
    });
    _refreshItems();
  }

  Widget _addSearchButton() {
    return OutlinedButton.icon(
      onPressed: _addTownByNavitime,
      icon: const Icon(Icons.travel_explore, size: 18),
      label: const Text('追加検索'),
    );
  }

  // ---- スマホ版（幅600未満）----
  void _phoneMode(bool toNumeric) {
    if (toNumeric == isNumericMode) return;
    setState(() {
      isNumericMode = toNumeric;
      if (isNumericMode) {
        tempZip = '';
        zipResults = [];
      } else {
        selectedInitial = 'すべて';
      }
    });
  }

  void _phoneGoPhase(int index) {
    setState(() {
      phase = index;
      selectedInitial = 'すべて';
      isNumericMode = false;
    });
    if (phase == 0) {
      _loadInitialData();
    } else if (phase == 1) {
      _loadCities();
    } else if (phase == 2) {
      _loadTowns();
    } else if (phase == 3) {
      _loadAza();
    }
  }

  Widget _buildPhone() {
    final values = [tempPref, tempCity, tempTown, _otherDone ? (tempOther.isEmpty ? 'なし' : tempOther) : '', tempDetail];
    const titles = ['都道府県', '市区町村', '町名', '字など', '番地住所'];
    final chips = Row(
      children: [
        for (var i = 0; i < 5; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: PcStepChip(
              title: titles[i],
              value: values[i],
              done: values[i].isNotEmpty,
              active: phase == i,
              onTap: (i == 0 || values[i - 1].isNotEmpty) ? () => _phoneGoPhase(i) : null,
            ),
          ),
        ],
      ],
    );

    Widget body;
    if (isNumericMode) {
      body = Column(
        children: [
          Container(
            height: 52,
            margin: const EdgeInsets.fromLTRB(18, 8, 18, 0),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: PcColors.field, border: Border.all(color: PcColors.line), borderRadius: BorderRadius.circular(10)),
            child: Text('〒 $tempZip', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: PcColors.purple)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 6),
            child: Align(alignment: Alignment.centerLeft, child: Text('郵便番号で検索中：$tempZip', style: const TextStyle(fontSize: 11.5, color: PcColors.sub))),
          ),
          Expanded(
            child: isSearching
                ? const Center(child: CircularProgressIndicator())
                : (zipResults.isEmpty
                    ? const Center(child: Text('該当する住所がありません', style: TextStyle(color: PcColors.hint)))
                    : _phoneZipList()),
          ),
          const SizedBox(height: 10),
          PcNumPad(onKey: _handleNumericInput),
        ],
      );
    } else if (phase == 3) {
      body = Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 6),
            child: Align(alignment: Alignment.centerLeft, child: Text('字・丁目などの項目${_azaLoading ? '（読込中）' : ''}', style: const TextStyle(fontSize: 11.5, color: PcColors.sub))),
          ),
          Expanded(
            child: _azaCandidates.isEmpty && !_azaLoading
                ? const Center(child: Text('該当なし（字・丁目などはありません）', style: TextStyle(color: PcColors.hint)))
                : PcChevronList(items: _azaLabels, selected: tempOther.isEmpty ? 'なし' : null, onTap: _selectAzaLabel),
          ),
          const SizedBox(height: 10),
        ],
      );
    } else if (phase == 4) {
      body = Column(
        children: [
          const SizedBox(height: 18),
          const Text('詳細住所を入力してください', style: TextStyle(fontSize: 11.5, color: PcColors.sub)),
          const SizedBox(height: 8),
          Text('$tempPref$tempCity$_townText$tempOther', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PcColors.text)),
          const SizedBox(height: 8),
          Text(
            tempDetail.isEmpty ? '丁目-番地-号' : tempDetail,
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: tempDetail.isEmpty ? PcColors.handle : PcColors.purple),
          ),
          const SizedBox(height: 18),
          PcNumPad(onKey: _handleNumericInput),
        ],
      );
    } else {
      body = Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 6),
            child: Row(
              children: [
                Expanded(child: Text('頭文字［$selectedInitial］の項目', style: const TextStyle(fontSize: 11.5, color: PcColors.sub))),
                if (phase == 2) _addSearchButton(),
              ],
            ),
          ),
          Expanded(
            child: isSearching
                ? const Center(child: CircularProgressIndicator())
                : (phase == 2 && items.where((e) => e != '（すべて）').isEmpty
                    ? _townEmptyState()
                    : PcChevronList(items: items, onTap: _handleAddressItemSelect)),
          ),
          const SizedBox(height: 10),
          PcKanaPad(
            selected: selectedInitial,
            kanaMap: kanaMap,
            onKana: _handleKanaTap,
            onAll: _handleAllTap,
            onBack: phase > 0 ? _handleBack : () => Navigator.pop(context),
          ),
        ],
      );
    }

    return Dialog.fullscreen(
      backgroundColor: Colors.white,
      child: PcSheet(
        title: '住所・郵便番号で検索',
        full: true,
        footer: isNumericMode
            ? null
            : (phase == 4
                ? PcButton(label: 'この内容で確定', onTap: _confirmNow)
                : (phase == 3
                    ? Row(
                        children: [
                          Expanded(child: PcButton(label: '戻る', onTap: _handleBack)),
                          const SizedBox(width: 8),
                          Expanded(child: PcButton(label: 'このまま確定', onTap: _confirmNow)),
                          const SizedBox(width: 8),
                          Expanded(child: PcButton(label: '次へ', onTap: _goNextFromAza)),
                        ],
                      )
                    : null)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
              child: PcSegment(
                labels: const ['住所検索', '郵便番号検索'],
                index: isNumericMode ? 1 : 0,
                onChanged: (i) => _phoneMode(i == 1),
                selectedFill: PcColors.purple,
                selectedText: Colors.white,
              ),
            ),
            Padding(padding: const EdgeInsets.fromLTRB(18, 0, 18, 6), child: chips),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }

  Widget _phoneZipList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: PcColors.line2), borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: zipResults.length,
        itemBuilder: (_, i) {
          final res = zipResults[i];
          return InkWell(
            onTap: () => setState(() {
              tempPref = res['pref'] ?? res['name'] ?? '';
              tempCity = res['city'] ?? '';
              tempTown = res['town'] ?? '';
              phase = 3;
              isNumericMode = false;
              _loadAza();
            }),
            child: Container(
              height: 43,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Expanded(child: Text('${res['address']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PcColors.text))),
                  const Icon(Icons.chevron_right, size: 20, color: PcColors.chevron),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isPhoneWidth(context)) return _buildPhone();
    // 画面より大きくならないようダイヤログサイズを制限する（ナンバーキーの見切れ防止）
    final media = MediaQuery.of(context);
    final double maxW = media.size.width - rs(context, 64);
    final double maxH = media.size.height - media.viewInsets.bottom - rs(context, 64);
    final double dialogW = rs(context, 900) < maxW ? rs(context, 900) : maxW;
    final double dialogH = rs(context, 700) < maxH ? rs(context, 700) : maxH;

    return Dialog(
      backgroundColor: AppColors.popupBackground,
      insetPadding: EdgeInsets.all(rs(context, 24)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 16))),
      child: Container(
        width: dialogW,
        height: dialogH,
        padding: EdgeInsets.all(rs(context, 20)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const KDialogTitle('住所・郵便番号で検索'),
                const Spacer(),
                // 住所検索／郵便番号検索の切り替え（ラジオボタン）
                _buildModeRadio('住所検索', !isNumericMode),
                SizedBox(width: rs(context, 24)),
                _buildModeRadio('郵便番号検索', isNumericMode),
                SizedBox(width: rs(context, 16)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            SizedBox(height: rs(context, 16)),
            _buildStepper(),
            Divider(height: rs(context, 32)),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 左側: 状況表示またはリスト
                  Expanded(
                    child: _buildLeftContent(),
                  ),
                  VerticalDivider(width: rs(context, 32), color: Colors.grey.shade200),
                  // 右側: ダイヤルパッド
                  SizedBox(
                    width: rs(context, 300),
                    child: _buildRightDialArea(),
                  ),
                ],
              ),
            ),
            if (phase == 3 && !isNumericMode) ...[
              Divider(height: rs(context, 32)),
              SizedBox(
                width: double.infinity,
                height: rs(context, 50),
                child: Row(
                  children: [
                    Expanded(child: KButton(label: '戻る', onPressed: _handleBack)),
                    SizedBox(width: rs(context, 12)),
                    Expanded(child: KButton(label: 'このまま確定', onPressed: _confirmNow)),
                    SizedBox(width: rs(context, 12)),
                    Expanded(child: KButton(label: '次へ', onPressed: _goNextFromAza)),
                  ],
                ),
              ),
            ],
            if (phase == 4 && !isNumericMode) ...[
              Divider(height: rs(context, 32)),
              SizedBox(
                width: double.infinity,
                height: rs(context, 50),
                child: KButton(label: 'この内容で確定', onPressed: _confirmNow),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStepper() {
    final List<Map<String, dynamic>> steps = [
      {'title': '都道府県', 'value': tempPref, 'phase': 0},
      {'title': '市区町村', 'value': tempCity, 'phase': 1},
      {'title': '町名', 'value': tempTown, 'phase': 2},
      {'title': 'その他', 'value': _otherDone ? (tempOther.isEmpty ? 'なし' : tempOther) : '', 'phase': 3},
      {'title': '詳細住所', 'value': tempDetail, 'phase': 4},
    ];

    return Row(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isActive = phase == step['phase'];
        final isCompleted = step['value'].toString().isNotEmpty;
        final isAvailable = index == 0 || steps[index - 1]['value'].toString().isNotEmpty;

        return Expanded(
          child: GestureDetector(
            onTap: isAvailable ? () {
              setState(() {
                phase = step['phase'];
                selectedInitial = 'すべて';
                isNumericMode = false;
              });
              if (phase == 0) {
                _loadInitialData();
              } else if (phase == 1) {
                _loadCities();
              } else if (phase == 2) {
                _loadTowns();
              } else if (phase == 3) {
                _loadAza();
              }
            } : null,
            child: Card(
              elevation: 0,
              margin: EdgeInsets.symmetric(horizontal: rs(context, 4)),
              color: isActive ? Color.alphaBlend(AppColors.selectButton, AppColors.popupBackground) : (isCompleted ? Color.alphaBlend(AppColors.accentPurple.withValues(alpha: 0.05), AppColors.popupBackground) : Colors.grey.shade100),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(rs(context, 8)),
                side: BorderSide(
                  color: isActive ? Colors.transparent : (isCompleted ? AppColors.accentPurple.withValues(alpha: 0.2) : Colors.transparent),
                  width: rs(context, 2),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: rs(context, 8), horizontal: rs(context, 12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: rs(context, 24),
                      height: rs(context, 24),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.accentOrange : (isCompleted ? AppColors.accentPurple : Colors.grey.shade400),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted && !isActive
                          ? Icon(Icons.check, color: AppColors.mainBackground, size: rs(context, 14))
                          : Text('${index + 1}', style: TextStyle(color: AppColors.mainBackground, fontWeight: FontWeight.bold, fontSize: rf(context, 12))),
                      ),
                    ),
                    SizedBox(width: rs(context, 8)),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(step['title'], style: TextStyle(fontSize: rf(context, 11), color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                          Text(isCompleted ? step['value'] : (isActive ? '選択中' : '-'),
                            style: TextStyle(
                              fontSize: rf(context, 13),
                              fontWeight: FontWeight.bold,
                              color: isActive ? AppColors.primaryText : (isCompleted ? Colors.black87 : Colors.grey),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLeftContent() {
    if (isNumericMode) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('郵便番号で検索中: $tempZip', style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          SizedBox(height: rs(context, 12)),
          if (isSearching) const Expanded(child: Center(child: CircularProgressIndicator())),
          if (!isSearching && zipResults.isEmpty) const Expanded(child: Center(child: Text('該当する住所がありません'))),
          if (!isSearching && zipResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: zipResults.length,
                itemBuilder: (context, i) {
                  final res = zipResults[i];
                  return Card(
                    margin: EdgeInsets.only(bottom: rs(context, 8)),
                    child: ListTile(
                      title: Text(res['address'], style: TextStyle(fontSize: rf(context, 18), fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        setState(() {
                          // 候補カードの住所（都道府県・市区町村・町名）をすべて反映する
                          tempPref = res['pref'] ?? res['name'] ?? "";
                          tempCity = res['city'] ?? "";
                          tempTown = res['town'] ?? "";
                          phase = 3;
                          isNumericMode = false;
                        });
                        _loadAza();
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      );
    }

    if (phase == 3) return _buildAzaContent();

    if (phase == 4) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('詳細住所を入力してください', style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          SizedBox(height: rs(context, 20)),
          Text("$tempPref$tempCity$_townText$tempOther", style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold)),
          SizedBox(height: rs(context, 40)),
          Text(tempDetail.isEmpty ? '丁目-番地-号' : tempDetail,
            style: TextStyle(fontSize: rf(context, 48), fontWeight: FontWeight.bold, color: tempDetail.isEmpty ? Colors.grey.shade300 : AppColors.accentPurple)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('頭文字 [$selectedInitial] の項目', style: TextStyle(fontSize: rf(context, 14), color: Colors.grey, fontWeight: FontWeight.bold))),
            if (phase == 2) _addSearchButton(),
          ],
        ),
        if (isSearching) const Expanded(child: Center(child: CircularProgressIndicator())),
        if (!isSearching && phase == 2 && items.where((e) => e != '（すべて）').isEmpty) Expanded(child: _townEmptyState()),
        if (!isSearching && !(phase == 2 && items.where((e) => e != '（すべて）').isEmpty))
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                return ListTile(
                  title: Text(item, style: TextStyle(fontSize: rf(context, 18), fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.accentPurple),
                  onTap: () => _handleAddressItemSelect(item),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _townEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('該当なし（この条件の町名はありません）', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              setState(() {
                tempTown = '（すべて）';
                phase = 3;
                selectedInitial = 'すべて';
              });
              _loadAza();
            },
            child: const Text('町名なしで次へ'),
          ),
        ],
      ),
    );
  }

  Widget _buildAzaContent() {
    final labels = _azaLabels;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('その他（字・丁目など）の項目', style: TextStyle(fontSize: rf(context, 14), color: Colors.grey, fontWeight: FontWeight.bold)),
            if (_azaLoading) ...[
              SizedBox(width: rs(context, 12)),
              SizedBox(width: rs(context, 12), height: rs(context, 12), child: const CircularProgressIndicator(strokeWidth: 2)),
            ],
          ],
        ),
        SizedBox(height: rs(context, 12)),
        Expanded(
          child: _azaCandidates.isEmpty && !_azaLoading
              ? const Center(child: Text('該当なし（字・丁目などはありません）。「このまま確定」か「次へ」で進めます', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: labels.length,
                  itemBuilder: (context, i) {
                    final selected = i == 0 ? tempOther.isEmpty : (tempOther.isNotEmpty && labels[i] == (_azaAllTown ? '$tempTown$tempOther' : tempOther));
                    return ListTile(
                      tileColor: selected ? AppColors.selectButton : null,
                      title: Text(labels[i], style: TextStyle(fontSize: rf(context, 18), fontWeight: FontWeight.bold)),
                      trailing: Icon(selected ? Icons.check_circle : Icons.chevron_right, color: AppColors.accentPurple),
                      onTap: () => _selectAzaLabel(labels[i]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRightDialArea() {
    if (phase == 4) return _buildNumericDialPad();
    if (phase == 3) return const SizedBox.shrink();

    return isNumericMode ? _buildNumericDialPad() : _buildKanaDialPad();
  }

  /// 大きめのラジオボタン（住所検索／郵便番号検索）
  Widget _buildModeRadio(String label, bool selected) {
    return InkWell(
      onTap: () {
        final toNumeric = label == '郵便番号検索';
        if (toNumeric == isNumericMode) return;
        setState(() {
          isNumericMode = toNumeric;
          if (isNumericMode) {
            tempZip = '';
            zipResults = [];
          } else {
            selectedInitial = 'すべて';
          }
        });
      },
      borderRadius: BorderRadius.circular(rs(context, 8)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: rs(context, 6), horizontal: rs(context, 4)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                size: rs(context, 34), color: selected ? AppColors.accentPurple : Colors.grey),
            SizedBox(width: rs(context, 8)),
            Text(label,
                style: TextStyle(fontSize: rf(context, 18), fontWeight: FontWeight.bold, color: selected ? AppColors.primaryText : Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildKanaDialPad() {
    final List<KDialKey> keys = [];
    for (var entry in kanaMap.entries) {
      final baseChar = entry.key;
      final cycle = entry.value;
      final isMatch = cycle.contains(selectedInitial);
      keys.add(KDialKey(
        label: isMatch ? selectedInitial : baseChar,
        subLabel: cycle.join(''),
        isHighlight: isMatch,
        onTap: () => _handleKanaTap(baseChar, cycle, isMatch),
      ));
    }
    keys.add(KDialKey(label: 'すべて', isHighlight: selectedInitial == 'すべて', onTap: _handleAllTap));
    if (phase > 0) keys.add(KDialKey(label: '戻る', onTap: _handleBack));
    // 高さが足りない場合も全キーが見えるよう縮小表示する
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: rs(context, 300),
          child: KDialPad(keys: keys),
        ),
      ),
    );
  }

  Widget _buildNumericDialPad() {
    final List<String> labels = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '-', '0', '⌫'];
    final List<KDialKey> keys = labels.map((label) => KDialKey(
      label: label,
      onTap: () => _handleNumericInput(label),
    )).toList();
    // 利用可能な高さに収まらない場合も全ボタンが見えるよう縮小表示する
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: rs(context, 300),
          child: KDialPad(keys: keys),
        ),
      ),
    );
  }

  void _handleNumericInput(String val) {
    if (val == '⌫') {
      setState(() {
        if (isNumericMode) {
          if (tempZip.isNotEmpty) {
            if (tempZip.endsWith("-")) {
              tempZip = tempZip.substring(0, tempZip.length - 2);
            } else {
              tempZip = tempZip.substring(0, tempZip.length - 1);
            }
          }
        } else if (phase == 4) {
          if (tempDetail.isNotEmpty) tempDetail = tempDetail.substring(0, tempDetail.length - 1);
        }
      });
      if (isNumericMode) _refreshZipResults();
      return;
    }

    setState(() {
      if (isNumericMode) {
        if (tempZip.length < 8) {
          tempZip += val;
          if (tempZip.length == 3) tempZip += "-";
        }
      } else if (phase == 4) {
        tempDetail += val;
      }
    });
    if (isNumericMode && tempZip.length >= 3) _refreshZipResults();
  }

  Future<void> _refreshZipResults() async {
    if (tempZip.length < 3) {
      setState(() => zipResults = []);
      return;
    }
    setState(() => isSearching = true);
    final results = await _addressService.searchByAddressOrZip(tempZip);
    setState(() {
      zipResults = results;
      isSearching = false;
    });
  }

  Future<void> _handleKanaTap(String base, List<String> cycle, bool isMatch) async {
    String next = isMatch ? cycle[(cycle.indexOf(selectedInitial) + 1) % cycle.length] : base;
    setState(() {
      selectedInitial = next;
      isSearching = true;
    });
    _refreshItems();
  }

  Future<void> _handleAllTap() async {
    setState(() {
      selectedInitial = 'すべて';
      isSearching = true;
    });
    _refreshItems();
  }

  Future<void> _refreshItems() async {
    List<String> newList;
    if (phase == 0) {
      newList = await _addressService.getPrefecturesByInitial(selectedInitial);
    } else if (phase == 1) {
      newList = await _addressService.getCitiesByInitial(tempPref, selectedInitial);
    } else {
      newList = await _addressService.getTownsByInitial(tempPref, tempCity, selectedInitial);
    }

    setState(() {
      items = (phase == 2 && selectedInitial == 'すべて') ? ['（すべて）', ...newList] : newList;
      isSearching = false;
    });
  }

  Future<void> _handleAddressItemSelect(String item) async {
    setState(() => isSearching = true);
    if (phase == 0) {
      tempPref = item;
      phase = 1;
      selectedInitial = 'すべて';
      _loadCities();
    } else if (phase == 1) {
      tempCity = item;
      phase = 2;
      selectedInitial = 'すべて';
      _loadTowns();
    } else if (phase == 2) {
      tempTown = item;
      phase = 3;
      isSearching = false;
      _loadAza();
    }
  }

  void _handleBack() {
    setState(() {
      if (phase == 1) {
        phase = 0;
        tempPref = "";
        _loadInitialData();
      } else if (phase == 2) {
        phase = 1;
        tempCity = "";
        _loadCities();
      } else if (phase == 3) {
        phase = 2;
        _loadTowns();
      } else if (phase == 4) {
        phase = 3;
      }
      selectedInitial = 'すべて';
    });
  }
}
