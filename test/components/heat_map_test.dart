import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:main/components/heat_map.dart';
import 'package:main/data_providers/session_data_provider.dart';
import 'package:main/theme/theme_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Generate mocks with Mockito
// Need mocks for SDP and TP
@GenerateNiceMocks([
  MockSpec<SessionDataProvider>(),
  MockSpec<ThemeProvider>(),
])
import 'heat_map_test.mocks.dart';

void main() {
  // mocks
  late MockSessionDataProvider mockSessionDataProvider;
  late MockThemeProvider mockThemeProvider;

  // test data
  final testStartDate = DateTime(2025, 1, 1);
  final testEndDate = DateTime(2025, 1, 31);
  final testDatasets = {
    DateTime(2025, 1, 1): 1,
    DateTime(2025, 1, 15): 2,
    DateTime(2025, 1, 31): 3,
  };

  setUp(() {
    mockSessionDataProvider = MockSessionDataProvider();
    mockThemeProvider = MockThemeProvider();

    // This is default stubbing for SessionDataProvider
    when(mockSessionDataProvider.heatMapDataset).thenReturn(testDatasets);
    // When we call the mock getStartDate(), we return the testing start date
    when(mockSessionDataProvider.getStartDateForHeatMap())
        .thenReturn(testStartDate);
    when(mockSessionDataProvider.showActivityOnDay(any, any))
        .thenAnswer((_) async {});

    // Default stubbing for ThemeProvider
    when(mockThemeProvider.isDarkMode).thenReturn(false);
  });

  Widget buildTestableWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SessionDataProvider>.value(
          value: mockSessionDataProvider,
        ),
        ChangeNotifierProvider<ThemeProvider>.value(
          value: mockThemeProvider,
        )
      ],
      // Must generate child as MaterialApp to test heat map exclusively.
      child: const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: MyHeatMap(),
          ),
        ),
      ),
    );
  }

  group('MyHeatMap Widget Tests', () {
    // -- TEST 1 --
    testWidgets('Renders HeatMapCalendar with correct initial data',
        (WidgetTester tester) async {
      // GUIDE:
      // Arrange: Default stubs from setUp are used
      // Act: pump and settle widget
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Assert: HeatMapCalendar is rendered with correct initial data
      // 1. Find the widget
      final heatMapCalendarFinder = find.byType(HeatMapCalendar);
      expect(heatMapCalendarFinder, findsOneWidget);

      // 2. Get the actual HeatMapCalendar widget instance
      final HeatMapCalendar heatMapCalendarWidget =
          tester.widget<HeatMapCalendar>(heatMapCalendarFinder);

      // 3. Verify its data and other properties
      expect(heatMapCalendarWidget.datasets, testDatasets);
      expect(heatMapCalendarWidget.initDate, testStartDate);
      expect(heatMapCalendarWidget.showColorTip, isFalse);
      expect(heatMapCalendarWidget.flexible, isTrue);
      expect(heatMapCalendarWidget.size, 30);
      expect(heatMapCalendarWidget.monthFontSize, 20);
      expect(heatMapCalendarWidget.weekFontSize, 15);
      expect(heatMapCalendarWidget.colorMode, ColorMode.color);
      expect(heatMapCalendarWidget.colorsets, const {1: Colors.green});
    });

    // -- TEST 2 --
    testWidgets('HeatMapCalendar uses correct defaultColor in light mode',
        (WidgetTester tester) async {
      // GUIDE:

      // Arrange
      when(mockThemeProvider.isDarkMode).thenReturn(false);

      // Act: pump and settle widget
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Assert
      final HeatMapCalendar heatMapCalendarWidget =
          tester.widget<HeatMapCalendar>(find.byType(HeatMapCalendar));
      expect(heatMapCalendarWidget.defaultColor, Colors.grey.shade200);
    });

    // -- TEST 3 --
    testWidgets('HeatMapCalendar uses correct defaultColor in dark mode',
        (WidgetTester tester) async {
      // Arrange
      when(mockThemeProvider.isDarkMode).thenReturn(true);

      // Act
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final HeatMapCalendar heatMapCalendarWidget =
          tester.widget<HeatMapCalendar>(find.byType(HeatMapCalendar));
      expect(heatMapCalendarWidget.defaultColor, Colors.grey.shade800);
    });

    // -- TEST 4 --
    testWidgets('HeatMapCalendar uses correct textColor in light mode',
        (WidgetTester tester) async {
      when(mockThemeProvider.isDarkMode).thenReturn(false);
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();
      final HeatMapCalendar heatMapCalendarWidget =
          tester.widget(find.byType(HeatMapCalendar));
      expect(heatMapCalendarWidget.textColor, Colors.black);
      expect(heatMapCalendarWidget.weekTextColor, Colors.black);
    });

    // -- TEST 5 --
    testWidgets('HeatMapCalendar uses correct textColor in dark mode',
        (WidgetTester tester) async {
      when(mockThemeProvider.isDarkMode).thenReturn(true);
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();
      final HeatMapCalendar heatMapCalendarWidget =
          tester.widget(find.byType(HeatMapCalendar));
      expect(heatMapCalendarWidget.textColor, Colors.white);
      expect(heatMapCalendarWidget.weekTextColor, Colors.white);
    });

    // -- TEST 6 --
    testWidgets(
        'HeatMapCalendar onClick triggers SessionDataProvider.showActivityOnDay',
        (WidgetTester tester) async {
      // Arrange
      final dateToClick = DateTime(2023, 1,
          20); // A date within the range but not necessarily in datasets

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final HeatMapCalendar heatMapCalendarWidget =
          tester.widget<HeatMapCalendar>(find.byType(HeatMapCalendar));

      // Act: Simulate the onClick call
      // We can't directly tap on the internal cells of HeatMapCalendar easily
      // without knowing its implementation details or if it exposes keys.
      // So, we directly invoke the callback passed to HeatMapCalendar.
      expect(heatMapCalendarWidget.onClick, isNotNull);
      heatMapCalendarWidget.onClick!(dateToClick);

      // Assert
      // Verify that showActivityOnDay was called with the correct context and date.
      // The `any` for context is because capturing the exact BuildContext in a test is tricky.
      verify(mockSessionDataProvider.showActivityOnDay(any, dateToClick))
          .called(1);
    });

    // -- TEST 7 --
    testWidgets('handles null or empty datasets gracefully', (WidgetTester tester) async {
      // Arrange
      when(mockSessionDataProvider.heatMapDataset).thenReturn(null); // Test with null datasets
      // Start date can remain the same or be specific for this test
      when(mockSessionDataProvider.getStartDateForHeatMap()).thenReturn(testStartDate);

      // Act
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Assert
      final heatMapCalendarFinder = find.byType(HeatMapCalendar);
      expect(heatMapCalendarFinder, findsOneWidget); // It should still render HeatMapCalendar

      final HeatMapCalendar heatMapCalendarWidget =
      tester.widget<HeatMapCalendar>(heatMapCalendarFinder);
      expect(heatMapCalendarWidget.datasets, isNull); // Verify it passes null

      // Arrange for empty dataset
      when(mockSessionDataProvider.heatMapDataset).thenReturn({}); // Test with empty datasets
      await tester.pumpWidget(buildTestableWidget()); // Rebuild with new data
      await tester.pumpAndSettle();

      final HeatMapCalendar heatMapCalendarWidgetEmpty =
      tester.widget<HeatMapCalendar>(find.byType(HeatMapCalendar));
      // Verify that is passes either isNull OR isEmpty, both are ok
      expect(
          heatMapCalendarWidgetEmpty.datasets,
          anyOf(isNull, isEmpty), // from package:matcher
          reason: "Datasets should be null or empty when an empty map is provided"
      );
    });
  });
}
