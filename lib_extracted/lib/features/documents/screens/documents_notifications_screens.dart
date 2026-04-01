import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../shared/data/admin_sample_data.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DOCUMENTS OVERVIEW
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class DocumentsOverviewScreen extends StatelessWidget {
  const DocumentsOverviewScreen({super.key});

  static const _categories = [
    {'icon': '📋', 'title': 'عقود العمل',         'count': '109', 'status': 'محدّثة',    'color': AppColors.navyMid},
    {'icon': '🏥', 'title': 'وثائق التأمين',      'count': '102', 'status': '7 منتهية',  'color': AppColors.warning},
    {'icon': '🎓', 'title': 'الشهادات والمؤهلات', 'count': '89',  'status': 'مكتملة',   'color': AppColors.success},
    {'icon': '📄', 'title': 'طلبات الوثائق',      'count': '14',  'status': 'معلقة',     'color': AppColors.error},
    {'icon': '🏛', 'title': 'سياسات الشركة',      'count': '22',  'status': 'منشورة',   'color': AppColors.teal},
    {'icon': '✈️', 'title': 'وثائق السفر',         'count': '8',   'status': '3 تنتهي',  'color': AppColors.gold},
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bg,
    body: Column(children: [
      Container(
        decoration: const BoxDecoration(gradient: AppColors.navyGradient),
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          bottom: 16, left: 18, right: 18),
        child: Column(children: [
          Row(children: [
            GestureDetector(onTap: () => context.pop(),
              child: Container(width: 36, height: 36,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 17))),
            Expanded(child: Column(children: [
              Text('إدارة المستندات', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              Text('نظرة شاملة على الوثائق التنظيمية', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 11, color: AppColors.goldLight)),
            ])),
            const SizedBox(width: 36),
          ]),
          const SizedBox(height: 14),
          // Alert - expiring docs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.warningSoft.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.warning.withOpacity(0.4))),
            child: Row(children: [
              Text('10 وثائق ستنتهي صلاحيتها خلال 30 يوماً', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
              const Spacer(),
              const Text('⚠️', style: TextStyle(fontSize: 16)),
            ])),
        ]),
      ),
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Document requests alert
          const AlertBanner(
            message: '14 طلب وثيقة معلق من الموظفين — تحتاج مراجعة',
            type: 'warning'),
          // Stats
          SectionHeader(title: 'نظرة عامة'),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.5,
            children: _categories.map((c) => GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bgCard, borderRadius: BorderRadius.circular(16),
                  boxShadow: AppShadows.card,
                  border: Border(bottom: BorderSide(color: c['color'] as Color, width: 3))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (c['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6)),
                      child: Text(c['status'] as String, style: TextStyle(fontFamily: 'Cairo', 
                        fontSize: 10, fontWeight: FontWeight.w700,
                        color: c['color'] as Color))),
                    Text(c['icon'] as String, style: const TextStyle(fontSize: 22)),
                  ]),
                  const SizedBox(height: 6),
                  Text(c['count'] as String, style: TextStyle(fontFamily: 'Cairo', 
                    fontSize: 26, fontWeight: FontWeight.w900,
                    color: c['color'] as Color, height: 1)),
                  Text(c['title'] as String, style: TextStyle(fontFamily: 'Cairo', 
                    fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.tx2),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),
          // Pending document requests
          SectionHeader(title: 'طلبات الوثائق المعلقة',
            actionLabel: 'عرض الكل', onAction: () {}),
          ...List.generate(3, (i) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
              boxShadow: AppShadows.sm),
            child: Row(children: [
              StatusBadge(text: 'معلق', type: 'pending', dot: true),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(['شهادة راتب', 'خطاب خبرة', 'شهادة تأمين'][i],
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700)),
                Text(['سارة المطيري', 'فهد العتيبي', 'محمد الدوسري'][i],
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.tx3)),
              ])),
              const SizedBox(width: 10),
              Container(width: 42, height: 42,
                decoration: BoxDecoration(
                  color: AppColors.navySoft, borderRadius: BorderRadius.circular(12)),
                child: const Center(child: Text('📄', style: TextStyle(fontSize: 20)))),
            ]),
          )),
          const SizedBox(height: 10),
          // Expiring documents
          SectionHeader(title: 'وثائق تنتهي قريباً'),
          ...List.generate(3, (i) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
              boxShadow: AppShadows.sm,
              border: Border.all(color: AppColors.warning.withOpacity(0.3))),
            child: Row(children: [
              Text(['15 مارس', '18 مارس', '22 مارس'][i], style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w700)),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(['تأمين طبي — نورة الزهراني', 'رخصة عمل — منصور الحربي', 'بطاقة هوية — ريم القحطاني'][i],
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w700)),
                Text(['المالية', 'المبيعات', 'HR'][i],
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.tx3)),
              ])),
              const SizedBox(width: 8),
              const Text('⚠️', style: TextStyle(fontSize: 18)),
            ]),
          )),
        ]),
      )),
    ]),
  );
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NOTIFICATIONS CENTER
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class NotificationsCenterScreen extends StatefulWidget {
  const NotificationsCenterScreen({super.key});
  @override State<NotificationsCenterScreen> createState() => _NotifState();
}
class _NotifState extends State<NotificationsCenterScreen> {
  late List<dynamic> _notifs;

  @override
  void initState() {
    super.initState();
    _notifs = AdminData.notifications;
  }

  String _notifIcon(String type) {
    switch (type) {
      case 'approval':   return '✅';
      case 'task':       return '✏️';
      case 'attendance': return '⏱';
      case 'request':    return '📋';
      case 'report':     return '📊';
      case 'hr':         return '👥';
      case 'project':    return '🏗';
      case 'expense':    return '💰';
      default:           return 'ℹ️';
    }
  }

  Color _notifColor(String type) {
    switch (type) {
      case 'approval':   return AppColors.success;
      case 'task':       return AppColors.error;
      case 'attendance': return AppColors.warning;
      case 'request':    return AppColors.navyMid;
      case 'report':     return AppColors.teal;
      case 'hr':         return AppColors.gold;
      case 'project':    return AppColors.navyLight;
      case 'expense':    return AppColors.gold;
      default:           return AppColors.g500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = _notifs.where((n) => !n.isRead).length;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        Container(
          decoration: const BoxDecoration(gradient: AppColors.navyGradient),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            bottom: 14, left: 18, right: 18),
          child: Row(children: [
            GestureDetector(
              onTap: () => setState(() { for (final n in _notifs) {
                n.isRead = true;
              } }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(9)),
                child: Text('قراءة الكل', style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70)))),
            Expanded(child: Column(children: [
              Text('مركز الإشعارات', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              if (unread > 0) Text('$unread إشعار غير مقروء', style: TextStyle(fontFamily: 'Cairo', 
                fontSize: 11, color: AppColors.goldLight)),
            ])),
            GestureDetector(onTap: () => context.pop(),
              child: Container(width: 36, height: 36,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 17))),
          ]),
        ),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: _notifs.length,
          itemBuilder: (_, i) {
            final n = _notifs[i];
            final isRead = n.isRead as bool;
            final color = _notifColor(n.type as String);
            return GestureDetector(
              onTap: () => setState(() => n.isRead = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isRead ? AppColors.bgCard : AppColors.navyGhost,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isRead ? AppShadows.sm : AppShadows.card,
                  border: isRead
                    ? null
                    : Border.all(color: AppColors.navyBorder, width: 1.5)),
                child: Row(children: [
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                    if (!isRead)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.navyMid, shape: BoxShape.circle)),
                  ]),
                  const SizedBox(width: 8),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(n.time as String, style: TextStyle(fontFamily: 'Cairo', 
                        fontSize: 10, color: AppColors.g400)),
                      Text(n.title as String, style: TextStyle(fontFamily: 'Cairo', 
                        fontSize: 13,
                        fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                        color: AppColors.tx1)),
                    ]),
                    const SizedBox(height: 4),
                    Text(n.body as String, style: TextStyle(fontFamily: 'Cairo', 
                      fontSize: 12, color: AppColors.tx3, height: 1.6),
                      textAlign: TextAlign.right),
                  ])),
                  const SizedBox(width: 10),
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text(
                      _notifIcon(n.type as String),
                      style: const TextStyle(fontSize: 18)))),
                ]),
              ),
            );
          },
        )),
      ]),
    );
  }
}
