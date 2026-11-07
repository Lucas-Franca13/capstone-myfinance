import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myfinance/controllers/finance_controller.dart';
import 'package:myfinance/demo_data.dart';
import 'package:myfinance/main.dart';
import 'package:myfinance/money_format.dart';
import 'package:myfinance/screens/home_screen.dart';
import 'package:myfinance/screens/profile_screen.dart';
import 'package:myfinance/screens/transactions_screen.dart';
import 'package:myfinance/services/local_repository.dart';
import 'package:myfinance/services/quote_repository.dart';
import 'package:myfinance/widgets/pill_nav_bar.dart';
import 'package:myfinance/widgets/theme_mode_switch.dart';

const quoteJson =
    '{"USDBRL":{"bid":"5.42","pctChange":"0.38","timestamp":"1793900000"},'
    '"EURBRL":{"bid":"6.18","pctChange":"-0.21","timestamp":"1793900000"},'
    '"BTCBRL":{"bid":"342800","pctChange":"1.72","timestamp":"1793900000"}}';

class MemoryRepository implements LocalRepository {
  final lists = <String, List<String>>{};
  final bools = <String, bool>{};
  final doubles = <String, double>{};
  @override
  Future<List<String>> getStringList(String key) async => lists[key] ?? [];
  @override
  Future<void> setStringList(String key, List<String> value) async =>
      lists[key] = value;
  @override
  Future<bool> getBool(String key) async => bools[key] ?? false;
  @override
  Future<void> setBool(String key, bool value) async => bools[key] = value;
  @override
  Future<double?> getDouble(String key) async => doubles[key];
  @override
  Future<void> setDouble(String key, double value) async =>
      doubles[key] = value;
}

class FailingWriteRepository extends MemoryRepository {
  @override
  Future<void> setBool(String key, bool value) async =>
      throw Exception('falha de escrita');
}

class DelayedRepository extends MemoryRepository {
  final gate = Completer<void>();
  @override
  Future<List<String>> getStringList(String key) async {
    if (key == 'entries') await gate.future;
    return super.getStringList(key);
  }
}

void main() {
  test('valores financeiros usam separadores brasileiros', () {
    expect(formatBrl(123456.78), 'R\$ 123.456,78');
    expect(formatBrl(-12.5), '−R\$ 12,50');
  });

  test('API converte respostas reais e trata HTTP inválido', () async {
    final success = QuoteRepository(
      MockClient((_) async => http.Response(quoteJson, 200)),
    );
    final quotes = await success.loadQuotes();
    expect(quotes.map((q) => q.code).toList(), ['USD', 'EUR', 'BTC']);
    expect(quotes.first.value, 5.42);
    expect(quotes[1].changePercent, -0.21);
    final failure = QuoteRepository(
      MockClient((_) async => http.Response('erro', 503)),
    );
    expect(failure.loadQuotes(), throwsException);
  });

  test(
    'preferências e transações são recuperadas por uma nova instância',
    () async {
      final store = MemoryRepository();
      final first = FinanceController(store);
      await first.load();
      await first.toggleFavorite('USD');
      await first.setHideBalance(true);
      await first.setBudget(1000);
      final second = FinanceController(store);
      await second.load();
      expect(second.favorites, contains('USD'));
      expect(second.hideBalance, isTrue);
      expect(second.budget, 1000);
    },
  );

  test('tema muda antes da gravação e reverte se ela falhar', () async {
    final finance = FinanceController(FailingWriteRepository());
    await finance.load();
    final states = <bool>[];
    finance.addListener(() => states.add(finance.darkMode));
    await expectLater(finance.setDarkMode(true), throwsException);
    expect(states, [true, false]);
    expect(finance.darkMode, isFalse);
  });

  test(
    'salvar durante a leitura inicial preserva transações anteriores',
    () async {
      final store = DelayedRepository();
      final earlier = FinanceEntry(
        title: 'Anterior',
        category: 'Casa',
        value: 20,
        isIncome: false,
        createdAt: DateTime(2026, 11, 1),
      );
      store.lists['entries'] = [jsonEncode(earlier.toJson())];
      final finance = FinanceController(store);
      final loading = finance.load();
      final saving = finance.addEntry(
        FinanceEntry(
          title: 'Nova',
          category: 'Casa',
          value: 10,
          isIncome: false,
          createdAt: DateTime(2026, 11, 2),
        ),
      );
      store.gate.complete();
      await Future.wait([loading, saving]);
      expect(finance.entries.map((e) => e.title).toList(), [
        'Nova',
        'Anterior',
      ]);
      expect(store.lists['entries'], hasLength(2));
    },
  );

  testWidgets('formulário valida, salva e mostra transação no extrato', (
    tester,
  ) async {
    final store = MemoryRepository();
    await tester.pumpWidget(
      MyFinanceApp(
        httpClient: MockClient((_) async => http.Response(quoteJson, 200)),
        localRepository: store,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nova transação').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar transação'));
    await tester.pumpAndSettle();
    expect(find.text('Preencha este campo'), findsNWidgets(2));
    expect(find.text('Informe um valor maior que zero'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'Mercado');
    await tester.enterText(find.byType(TextFormField).at(1), '42,50');
    await tester.enterText(find.byType(TextFormField).at(2), 'Alimentação');
    await tester.ensureVisible(find.text('Salvar transação'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar transação'));
    await tester.pumpAndSettle();
    expect(find.text('Mercado'), findsWidgets);
    expect(store.lists['entries'], hasLength(1));
    await tester.tap(find.byIcon(Icons.receipt_long_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Suas movimentações'), findsOneWidget);
    expect(find.text('Mercado'), findsWidgets);
  });

  testWidgets('API, detalhe, favorito e pílula persistente', (tester) async {
    final store = MemoryRepository();
    await tester.pumpWidget(
      MyFinanceApp(
        httpClient: MockClient((_) async => http.Response(quoteJson, 200)),
        localRepository: store,
      ),
    );
    await tester.pumpAndSettle();
    final pillElement = tester.element(find.byType(PillNavBar));
    await tester.tap(find.byIcon(Icons.currency_exchange_rounded));
    await tester.pumpAndSettle();
    expect(find.text('USD'), findsWidgets);
    expect(
      identical(tester.element(find.byType(PillNavBar)), pillElement),
      isTrue,
    );
    await tester.tap(find.text('USD').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Favoritar moeda'));
    await tester.tap(find.text('Favoritar moeda'));
    await tester.pumpAndSettle();
    expect(store.lists['favorites'], contains('USD'));
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.favorite_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Moedas favoritas'), findsOneWidget);
    expect(find.text('USD'), findsWidgets);
    expect(
      identical(tester.element(find.byType(PillNavBar)), pillElement),
      isTrue,
    );
  });

  testWidgets('orçamento mensal valida, salva e fecha o diálogo', (
    tester,
  ) async {
    final store = MemoryRepository();
    await tester.pumpWidget(
      MyFinanceApp(
        httpClient: MockClient((_) async => http.Response(quoteJson, 200)),
        localRepository: store,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.favorite_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Orçamento mensal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Informe um valor maior que zero'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '1500,50');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(AlertDialog), findsNothing);
    expect(store.doubles['budget'], 1500.5);
    expect(find.text('Limite de ${formatBrl(1500.5)} por mês'), findsOneWidget);
  });

  Future<MemoryRepository> pumpWithEntries(
    WidgetTester tester,
    List<FinanceEntry> entries,
  ) async {
    final store = MemoryRepository();
    store.lists['entries'] = [
      for (final entry in entries) jsonEncode(entry.toJson()),
    ];
    await tester.pumpWidget(
      MyFinanceApp(
        httpClient: MockClient((_) async => http.Response(quoteJson, 200)),
        localRepository: store,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.receipt_long_rounded));
    await tester.pumpAndSettle();
    return store;
  }

  Finder inStatement(String text) => find.descendant(
    of: find.byType(TransactionsScreen),
    matching: find.text(text),
  );

  final rent = FinanceEntry(
    title: 'Aluguel',
    category: 'Casa',
    value: 1200,
    isIncome: false,
    createdAt: DateTime(2026, 11, 2),
  );
  final salary = FinanceEntry(
    title: 'Salário',
    category: 'Trabalho',
    value: 5000,
    isIncome: true,
    createdAt: DateTime(2026, 11, 1),
  );

  testWidgets('deslizar exclui, desfazer restaura e exclusão persiste', (
    tester,
  ) async {
    final store = await pumpWithEntries(tester, [rent, salary]);
    await tester.drag(inStatement('Aluguel'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(inStatement('Aluguel'), findsNothing);
    expect(store.lists['entries'], hasLength(1));
    await tester.tap(find.text('Desfazer').first);
    await tester.pumpAndSettle();
    expect(inStatement('Aluguel'), findsOneWidget);
    expect(
      store.lists['entries']!.map(
        (item) => (jsonDecode(item) as Map<String, dynamic>)['title'],
      ),
      ['Aluguel', 'Salário'],
    );
    await tester.drag(inStatement('Aluguel'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    final reopened = FinanceController(store);
    await reopened.load();
    expect(reopened.entries.map((entry) => entry.title), ['Salário']);
  });

  testWidgets('detalhe exclui a transação e volta ao extrato', (tester) async {
    final store = await pumpWithEntries(tester, [rent]);
    await tester.tap(inStatement('Aluguel'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Excluir transação'));
    await tester.pumpAndSettle();
    expect(find.text('Ainda não há transações'), findsOneWidget);
    expect(store.lists['entries'], isEmpty);
    expect(find.text('Desfazer'), findsWidgets);
  });

  testWidgets('filtro separa receitas e despesas', (tester) async {
    await pumpWithEntries(tester, [rent, salary]);
    await tester.tap(find.text('Receitas'));
    await tester.pumpAndSettle();
    expect(inStatement('Salário'), findsOneWidget);
    expect(inStatement('Aluguel'), findsNothing);
    await tester.tap(find.text('Despesas'));
    await tester.pumpAndSettle();
    expect(inStatement('Aluguel'), findsOneWidget);
    expect(inStatement('Salário'), findsNothing);
    await tester.tap(find.text('Todas'));
    await tester.pumpAndSettle();
    expect(inStatement('Aluguel'), findsOneWidget);
    expect(inStatement('Salário'), findsOneWidget);
  });

  testWidgets('switch de tema funciona em qualquer tela e é salvo', (
    tester,
  ) async {
    final store = MemoryRepository();
    await tester.pumpWidget(
      MyFinanceApp(
        httpClient: MockClient((_) async => http.Response(quoteJson, 200)),
        localRepository: store,
      ),
    );
    await tester.pumpAndSettle();
    Brightness brightness() =>
        Theme.of(tester.element(find.byType(ThemeModeSwitch).last)).brightness;
    await tester.tap(
      find.descendant(
        of: find.byType(HomeScreen),
        matching: find.byType(ThemeModeSwitch),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(brightness(), Brightness.dark);
    expect(store.bools['darkMode'], isTrue);
    final reopened = FinanceController(store);
    await reopened.load();
    expect(reopened.darkMode, isTrue);
    await tester.tap(find.byTooltip('Abrir perfil'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(ProfileScreen),
        matching: find.byType(ThemeModeSwitch),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(brightness(), Brightness.light);
    expect(store.bools['darkMode'], isFalse);
  });

  testWidgets('erro de API mostra nova tentativa', (tester) async {
    await tester.pumpWidget(
      MyFinanceApp(
        httpClient: MockClient((_) async => http.Response('erro', 503)),
        localRepository: MemoryRepository(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.currency_exchange_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Tentar novamente'), findsOneWidget);
  });

  testWidgets('telas principais cabem em largura compacta', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      MyFinanceApp(
        httpClient: MockClient((_) async => http.Response(quoteJson, 200)),
        localRepository: MemoryRepository(),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Nova transação').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nova transação').first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.currency_exchange_rounded).first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
