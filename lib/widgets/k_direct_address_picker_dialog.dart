import 'package:flutter/material.dart';
import 'k_button.dart';
import 'k_responsive.dart';
import 'k_dial_pad.dart';
import '../services/address_service.dart';

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
  int phase = 0; // 0: Pref, 1: City, 2: Town, 3: Detail
  bool isNumericMode = false; // Zip入力中かどうか
  String tempZip = "";
  String tempPref = "";
  String tempCity = "";
  String tempTown = "";
  String tempDetail = "";
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

  @override
  Widget build(BuildContext context) {
    // 画面より大きくならないようダイヤログサイズを制限する（ナンバーキーの見切れ防止）
    final media = MediaQuery.of(context);
    final double maxW = media.size.width - rs(context, 64);
    final double maxH = media.size.height - media.viewInsets.bottom - rs(context, 64);
    final double dialogW = rs(context, 900) < maxW ? rs(context, 900) : maxW;
    final double dialogH = rs(context, 700) < maxH ? rs(context, 700) : maxH;

    return Dialog(
      backgroundColor: Colors.white,
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
                Text('住所・郵便番号で検索',
                  style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold, color: Colors.deepPurple)),
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
            if (phase == 3) ...[
              Divider(height: rs(context, 32)),
              SizedBox(
                width: double.infinity,
                height: rs(context, 50),
                child: KButton(
                  label: 'この内容で確定',
                  onPressed: () {
                    widget.onAddressConfirmed("$tempPref$tempCity$tempTown$tempDetail");
                    Navigator.pop(context);
                  },
                ),
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
      {'title': '詳細住所', 'value': tempDetail, 'phase': 3},
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
              }
            } : null,
            child: Card(
              elevation: isActive ? 4 : 0,
              margin: EdgeInsets.symmetric(horizontal: rs(context, 4)),
              color: isActive ? Colors.white : (isCompleted ? Colors.deepPurple.withValues(alpha: 0.05) : Colors.grey.shade100),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(rs(context, 8)),
                side: BorderSide(
                  color: isActive ? Colors.deepPurple : (isCompleted ? Colors.deepPurple.withValues(alpha: 0.2) : Colors.transparent),
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
                        color: isActive ? Colors.orange : (isCompleted ? Colors.deepPurple : Colors.grey.shade400),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted && !isActive
                          ? Icon(Icons.check, color: Colors.white, size: rs(context, 14))
                          : Text('${index + 1}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: rf(context, 12))),
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
                              color: isActive ? Colors.orange : (isCompleted ? Colors.black87 : Colors.grey),
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
                          tempPref = res['name'] ?? "";
                          tempCity = res['city'] ?? "";
                          tempTown = res['town'] ?? "";
                          phase = 3;
                          isNumericMode = false;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      );
    }

    if (phase == 3) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('詳細住所を入力してください', style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          SizedBox(height: rs(context, 20)),
          Text("$tempPref$tempCity$tempTown", style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold)),
          SizedBox(height: rs(context, 40)),
          Text(tempDetail.isEmpty ? '丁目-番地-号' : tempDetail,
            style: TextStyle(fontSize: rf(context, 48), fontWeight: FontWeight.bold, color: tempDetail.isEmpty ? Colors.grey.shade300 : Colors.deepPurple)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('頭文字 [$selectedInitial] の項目', style: TextStyle(fontSize: rf(context, 14), color: Colors.grey, fontWeight: FontWeight.bold)),
        if (isSearching) const Expanded(child: Center(child: CircularProgressIndicator())),
        if (!isSearching)
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                return ListTile(
                  title: Text(item, style: TextStyle(fontSize: rf(context, 18), fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.deepPurple),
                  onTap: () => _handleAddressItemSelect(item),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildRightDialArea() {
    if (phase == 3) return _buildNumericDialPad();

    return Column(
      children: [
        _buildModeSwitchButton(),
        SizedBox(height: rs(context, 16)),
        Expanded(
          child: isNumericMode ? _buildNumericDialPad() : _buildKanaDialPad(),
        ),
      ],
    );
  }

  Widget _buildModeSwitchButton() {
    return SizedBox(
      width: double.infinity,
      height: rs(context, 50),
      child: OutlinedButton.icon(
        onPressed: () {
          setState(() {
            isNumericMode = !isNumericMode;
            if (isNumericMode) {
              tempZip = "";
            } else {
              selectedInitial = 'すべて';
            }
          });
        },
        icon: Icon(isNumericMode ? Icons.abc : Icons.pin_drop),
        label: Text(isNumericMode ? '地域名で選択' : '郵便番号で入力',
          style: const TextStyle(fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.deepPurple, width: rs(context, 2)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 12))),
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
        } else if (phase == 3) {
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
      } else if (phase == 3) {
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
      }
      selectedInitial = 'すべて';
    });
  }
}
