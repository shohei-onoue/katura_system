// ignore_for_file: curly_braces_in_flow_control_structures
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:katura_system/models/customer_model.dart';
import 'package:katura_system/models/menu_model.dart';
import 'package:katura_system/models/order_model.dart';
import 'package:katura_system/widgets/k_item_details_dialog.dart';
import 'package:katura_system/widgets/k_order_intake_dialog.dart';
import 'package:katura_system/screens/phone/landscape/landscape_customer.dart';
import 'package:katura_system/screens/phone/landscape/landscape_drawer.dart';
import 'package:katura_system/screens/phone/landscape/landscape_order_list.dart';
import 'package:katura_system/screens/phone/phone_order_list_dialogs.dart';
import 'package:katura_system/screens/phone/phone_shell.dart';
import 'package:katura_system/widgets/k_numeric_input_dialog.dart';

const _sizes = <Size>[Size(844, 390), Size(667, 375), Size(932, 430), Size(800, 360), Size(390, 844)];

OrderModel _order(String id, String name, {String addr = '岡崎市井田町3-5'}) => OrderModel(
      id: id,
      customerName: name,
      address: addr,
      phoneNumber: '090-1234-5678',
      receptionDate: DateTime(2026, 10, 19),
      deliveryDate: DateTime(2026, 10, 19),
      deliveryTime: '10:00',
      deliveryType: '配達',
      items: [
        {'name': '幕の内弁当', 'price': 630, 'quantity': 10},
        {'name': 'から揚げ弁当', 'price': 700, 'quantity': 5},
        {'name': 'お茶', 'price': 100, 'quantity': 15},
      ],
      totalCount: 30,
    );

Future<void> _run(WidgetTester tester, Size size, double notch, Widget Function() build) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  final pad = FakeViewPadding(left: notch, right: notch);
  tester.view.padding = pad;
  tester.view.viewPadding = pad;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: build()));
  await tester.pump(const Duration(milliseconds: 300));
  expect(tester.takeException(), isNull, reason: '$size notch=$notch');
}

Future<void> _runDialog(WidgetTester tester, Size size, double notch, Future<void> Function(BuildContext) open) async {
  await _run(tester, size, notch, () => Scaffold(body: Builder(builder: (c) => TextButton(onPressed: () => open(c), child: const Text('open')))));
  await tester.tap(find.text('open'));
  await tester.pump(const Duration(milliseconds: 400));
  expect(tester.takeException(), isNull, reason: 'dialog $size notch=$notch');
}

void main() {
  setUpAll(() async => initializeDateFormatting('ja'));
  for (final size in _sizes) {
    final portrait = size.height > size.width;
    // 縦向きではノッチは上側なので左右ノッチは横向きのみ。横向き専用部品は縦向きでは使われない。
    for (final notch in portrait ? [0.0] : [0.0, 44.0]) {
      final tag = '${size.width.toInt()}x${size.height.toInt()} notch=${notch.toInt()}';

      testWidgets('LandscapeDrawer $tag', (t) async {
        await _run(t, size, notch, () => Scaffold(
              body: LandscapeDrawer(selectedIndex: 1, loginId: 'katura-okazaki', onSelect: (_) {}, onLogout: () {}, onClose: () {}),
            ));
      });

      testWidgets('PhoneLandscapeRail $tag', (t) async {
        await _run(t, size, notch, () => Scaffold(
              body: Row(children: [
                PhoneLandscapeRail(selectedIndex: 1, onNavigate: (_) {}, onLogout: () {}, onBell: () {}, pendingCount: 3),
                const Expanded(child: SizedBox()),
              ]),
            ));
      });

      if (!portrait) testWidgets('LandscapeOrderList $tag', (t) async {
        await _run(t, size, notch, () => Scaffold(
              body: LandscapeOrderList(
                orders: [
                  _order('1', '田中 太郎'),
                  _order('2', '株式会社 とても長い名前の鈴木商事グループ本社', addr: '愛知県名古屋市緑区鳴海町非常に長い住所1-93-4567'),
                ],
                isLoading: false,
                selectedDay: DateTime(2026, 10, 19),
                displayNames: const {},
                warnOrderIds: const {'2'},
                branches: const ['全店', '岡崎本店', '名古屋', '岐阜'],
                selectedBranch: '全店',
                onPrevDay: () {},
                onNextDay: () {},
                onToday: () {},
                onSelectBranch: (_) {},
                onDelivered: (_) async {},
                onEdit: (_, _) {},
                onCancel: (_) {},
              ),
            ));
      });

      if (!portrait) testWidgets('LandscapeOrderList empty $tag', (t) async {
        await _run(t, size, notch, () => Scaffold(
              body: LandscapeOrderList(
                orders: const [],
                isLoading: false,
                selectedDay: DateTime(2026, 10, 19),
                displayNames: const {},
                warnOrderIds: const {},
                branches: const ['全店', '岡崎本店'],
                selectedBranch: '全店',
                onPrevDay: () {},
                onNextDay: () {},
                onToday: () {},
                onSelectBranch: (_) {},
                onDelivered: (_) async {},
                onEdit: (_, _) {},
                onCancel: (_) {},
              ),
            ));
      });

      if (!portrait) testWidgets('LandscapeCustomerView $tag', (t) async {
        final cs = [
          Customer(id: 'a', name: '山田 一郎', phoneNumber: '090-1234-5678', address: '岡崎市井田町3-5'),
          Customer(id: 'b', name: '株式会社 鈴木商事', companyName: '鈴木商事', phoneNumber: '0564-00-0000', address: '安城市'),
        ];
        await _run(t, size, notch, () => Scaffold(
              body: LandscapeCustomerView(
                customers: cs,
                elapsedDays: (_) => 120,
                selected: cs.first,
                sortKey: 'name',
                sortAscending: true,
                searchText: '',
                onSort: (_) {},
                onSearch: () {},
                onClearSearch: () {},
                onTap: (_) {},
                onLongPress: (_) {},
                checkedIds: const {},
                onCancelSelect: () {},
                onDeleteChecked: () {},
                onDetail: (_) {},
                onDelete: (_) {},
                onSelectAll: () {},
                onNewOrder: () {},
              ),
            ));
      });

      testWidgets('KNumericInputDialog time $tag', (t) async {
        await _runDialog(t, size, notch, (c) => showDialog(
              context: c,
              builder: (_) => KNumericInputDialog(title: '配達時刻', initialValue: '1130', maxLength: 4, overwrite: true, timeFormat: true, onConfirmed: (_) {}),
            ));
      });

      testWidgets('KNumericInputDialog phone $tag', (t) async {
        await _runDialog(t, size, notch, (c) => showDialog(
              context: c,
              builder: (_) => KNumericInputDialog(title: '電話番号', maxLength: 11, onConfirmed: (_) {}),
            ));
      });

      testWidgets('KItemDetailsDialog $tag', (t) async {
        await _runDialog(t, size, notch, (c) => showDialog(
              context: c,
              builder: (_) => KItemDetailsDialog(menu: MenuModel(id: 'm', name: '幕の内弁当', category: '弁当', price: 630, description: '説明' * 30)),
            ));
      });

      testWidgets('KOrderIntakeDialog $tag', (t) async {
        await _runDialog(t, size, notch, (c) => showDialog(context: c, builder: (_) => const KOrderIntakeDialog()));
      });

      testWidgets('showPhoneFigmaConfirm $tag', (t) async {
        await _runDialog(t, size, notch, (c) => showPhoneFigmaConfirm(
              c,
              icon: Icons.event_busy,
              iconColor: Colors.red,
              iconBg: const Color(0xFFFFEBEE),
              title: '予約キャンセルの確認',
              message: '山田 花子様の予約をキャンセルし、登録内容を削除します。元に戻せません。よろしいですか？',
              cancelLabel: 'いいえ',
              confirmLabel: 'キャンセルする',
            ));
      });
    }
  }
}
