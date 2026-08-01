import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yp_flutter_recruitment_demo/app/app.dart';
import 'package:yp_flutter_recruitment_demo/app/app_bootstrap.dart';

void main() {
  // 核心烟测：一级 tab 可见，进入二级页后底部 tab 不再保留。
  testWidgets('shows four Flutter tabs and opens a domain detail page', (
    tester,
  ) async {
    final dependencies = await AppBootstrap.create();

    await tester.pumpWidget(RecruitmentDemoApp(dependencies: dependencies));
    await tester.pumpAndSettle();

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
  });
}
