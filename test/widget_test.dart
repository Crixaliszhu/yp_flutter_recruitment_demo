import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yp_flutter_recruitment_demo/app/app.dart';
import 'package:yp_flutter_recruitment_demo/app/app_bootstrap.dart';

void main() {
  // 核心烟测：Flutter 启动页结束后进入一级 tab，二级页不再保留底部 tab。
  testWidgets(
    'launches into four Flutter tabs and opens a domain detail page',
    (tester) async {
      await AppBootstrap.init();

      await tester.pumpWidget(const RecruitmentDemoApp());
      expect(find.text('渔泡招聘'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('首页'), findsWidgets);
      expect(find.text('集市'), findsOneWidget);
      expect(find.text('消息'), findsOneWidget);
      expect(find.text('我的'), findsOneWidget);

      await tester.tap(find.text('进入首页二级页'));
      await tester.pumpAndSettle();

      expect(find.text('首页二级页'), findsOneWidget);
      expect(find.byIcon(Icons.route), findsOneWidget);
      expect(find.text('集市'), findsNothing);
      expect(find.text('消息'), findsNothing);
      expect(find.text('我的'), findsNothing);
    },
  );
}
