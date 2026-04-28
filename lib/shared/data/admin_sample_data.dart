import '../models/admin_models.dart';
import '../../core/constants/app_colors.dart';

class AdminData {
  AdminData._();

  // ── Admin User ────────────────────────────────────────────
  static const AdminUser currentAdmin = AdminUser(
    id: 'ADM-001',
    name: 'خالد بن عبدالله الشمري',
    nameEn: 'Khalid Al-Shamri',
    role: 'مدير الموارد البشرية',
    email: 'k.shamri@riyad-group.sa',
    phone: '+966 50 111 2200',
    initials: 'خش',
    permissions: ['all'],
  );

  // ── Departments ────────────────────────────────────────────
  static const List<Department> departments = [
    Department(id: 'D01', name: 'إدارة تقنية المعلومات',    headName: 'م. فهد العتيبي',   headTitle: 'مدير التقنية',           employeeCount: 18, pendingRequests: 7,  activeTasks: 12, attendanceIssues: 2, performanceScore: 87),
    Department(id: 'D02', name: 'إدارة المالية والمحاسبة', headName: 'أ. نورة الزهراني', headTitle: 'مدير المالية',           employeeCount: 12, pendingRequests: 4,  activeTasks: 8,  attendanceIssues: 1, performanceScore: 92),
    Department(id: 'D03', name: 'إدارة الموارد البشرية',    headName: 'أ. سارة المطيري',  headTitle: 'مدير الموارد البشرية',  employeeCount: 9,  pendingRequests: 11, activeTasks: 15, attendanceIssues: 0, performanceScore: 95),
    Department(id: 'D04', name: 'إدارة المبيعات',           headName: 'أ. منصور الحربي',  headTitle: 'مدير المبيعات',         employeeCount: 24, pendingRequests: 9,  activeTasks: 20, attendanceIssues: 4, performanceScore: 78),
    Department(id: 'D05', name: 'إدارة التطوير والابتكار', headName: 'م. عمر الدوسري',   headTitle: 'مدير التطوير',          employeeCount: 15, pendingRequests: 5,  activeTasks: 18, attendanceIssues: 1, performanceScore: 90),
    Department(id: 'D06', name: 'إدارة العمليات والخدمات', headName: 'أ. عبدالله القحطاني', headTitle: 'مدير العمليات',       employeeCount: 31, pendingRequests: 14, activeTasks: 22, attendanceIssues: 6, performanceScore: 73),
  ];

  // ── Employees ──────────────────────────────────────────────
  static const List<EmployeeRecord> employees = [
    EmployeeRecord(id: 'EMP-147', name: 'أحمد الغامدي',     title: 'مدير تطوير الأعمال',   deptId: 'D05', dept: 'التطوير والابتكار', status: 'نشط',    attendanceStatus: 'حاضر',   email: 'a.ghamdi@riyad.sa',   phone: '+966 55 987 6543', joined: '12 مارس 2019',    manager: 'م. عمر الدوسري',     pendingRequests: 2, activeTasks: 3, initials: 'أح'),
    EmployeeRecord(id: 'EMP-089', name: 'سارة المطيري',     title: 'مدير الموارد البشرية',  deptId: 'D03', dept: 'الموارد البشرية',   status: 'نشط',    attendanceStatus: 'حاضر',   email: 's.mutairi@riyad.sa',  phone: '+966 55 234 5678', joined: '5 يناير 2018',    manager: 'خالد الشمري',        pendingRequests: 1, activeTasks: 5, initials: 'سم'),
    EmployeeRecord(id: 'EMP-112', name: 'محمد الدوسري',     title: 'مهندس تقنية المعلومات', deptId: 'D01', dept: 'تقنية المعلومات',   status: 'نشط',    attendanceStatus: 'متأخر',  email: 'm.dosari@riyad.sa',   phone: '+966 55 345 6789', joined: '20 مارس 2020',    manager: 'م. فهد العتيبي',     pendingRequests: 3, activeTasks: 2, initials: 'مد'),
    EmployeeRecord(id: 'EMP-203', name: 'نورة الزهراني',    title: 'محاسبة أولى',            deptId: 'D02', dept: 'المالية',            status: 'نشط',    attendanceStatus: 'حاضر',   email: 'n.zahrani@riyad.sa',  phone: '+966 55 456 7890', joined: '8 مارس 2021',     manager: 'أ. نورة الزهراني',  pendingRequests: 0, activeTasks: 4, initials: 'نز'),
    EmployeeRecord(id: 'EMP-167', name: 'فهد العتيبي',      title: 'مدير تقنية المعلومات',  deptId: 'D01', dept: 'تقنية المعلومات',   status: 'نشط',    attendanceStatus: 'إجازة',  email: 'f.utaibi@riyad.sa',   phone: '+966 55 567 8901', joined: '15 يونيو 2017',   manager: 'عبدالله القحطاني',   pendingRequests: 1, activeTasks: 6, initials: 'فع'),
    EmployeeRecord(id: 'EMP-088', name: 'منصور الحربي',     title: 'مدير المبيعات الإقليمي', deptId: 'D04', dept: 'المبيعات',          status: 'نشط',    attendanceStatus: 'غائب',   email: 'm.harbi@riyad.sa',    phone: '+966 55 678 9012', joined: '3 أبريل 2016',    manager: 'عبدالله القحطاني',   pendingRequests: 4, activeTasks: 7, initials: 'مح'),
    EmployeeRecord(id: 'EMP-220', name: 'ريم القحطاني',     title: 'أخصائية تطوير بشري',   deptId: 'D03', dept: 'الموارد البشرية',   status: 'نشط',    attendanceStatus: 'حاضر',   email: 'r.qahtani@riyad.sa',  phone: '+966 55 789 0123', joined: '10 فبراير 2022',  manager: 'سارة المطيري',       pendingRequests: 0, activeTasks: 2, initials: 'رق'),
    EmployeeRecord(id: 'EMP-055', name: 'عمر الدوسري',      title: 'مدير التطوير',           deptId: 'D05', dept: 'التطوير والابتكار', status: 'نشط',    attendanceStatus: 'حاضر',   email: 'o.dosari@riyad.sa',   phone: '+966 55 890 1234', joined: '1 يناير 2015',    manager: 'عبدالله القحطاني',   pendingRequests: 2, activeTasks: 9, initials: 'عد'),
  ];

  // ── Requests ───────────────────────────────────────────────
  static const List<AdminRequest> requests = [
    AdminRequest(id: 'REQ-2025-0345', empName: 'سارة المطيري',  empId: 'EMP-089', dept: 'الموارد البشرية',   type: 'طلب إجازة سنوية',     submittedDate: 'منذ ساعتين',    status: 'pending',   priority: 'high',   details: 'إجازة سنوية — 5 أيام — 15 إلى 20 مارس'),
    AdminRequest(id: 'REQ-2025-0344', empName: 'محمد الدوسري',  empId: 'EMP-112', dept: 'تقنية المعلومات',   type: 'مطالبة مصاريف',        submittedDate: 'منذ 4 ساعات',   status: 'pending',   priority: 'normal', details: 'مصاريف تدريب خارجي — 1,800 ريال'),
    AdminRequest(id: 'REQ-2025-0340', empName: 'نورة الزهراني', empId: 'EMP-203', dept: 'المالية',            type: 'تصحيح حضور',           submittedDate: 'أمس 10:15',     status: 'pending',   priority: 'low',    details: 'تصحيح تسجيل دخول يوم 6 مارس'),
    AdminRequest(id: 'REQ-2025-0338', empName: 'فهد العتيبي',   empId: 'EMP-167', dept: 'تقنية المعلومات',   type: 'مهمة رسمية',           submittedDate: 'أمس 09:00',     status: 'pending',   priority: 'high',   details: 'رحلة عمل جدة — 3 أيام'),
    AdminRequest(id: 'REQ-2025-0330', empName: 'منصور الحربي',  empId: 'EMP-088', dept: 'المبيعات',          type: 'سلفة راتب',            submittedDate: '8 مارس 2025',   status: 'approved',  priority: 'normal', details: 'سلفة راتب شهر مارس — 5,000 ريال'),
    AdminRequest(id: 'REQ-2025-0318', empName: 'أحمد الغامدي',  empId: 'EMP-147', dept: 'التطوير والابتكار', type: 'طلب وثيقة',            submittedDate: '5 مارس 2025',   status: 'completed', priority: 'low',    details: 'شهادة راتب للسفارة'),
    AdminRequest(id: 'REQ-2025-0300', empName: 'ريم القحطاني',  empId: 'EMP-220', dept: 'الموارد البشرية',   type: 'إذن مغادرة',          submittedDate: '3 مارس 2025',   status: 'approved',  priority: 'low',    details: 'إذن مغادرة مبكرة — 2 ساعة'),
    AdminRequest(id: 'REQ-2025-0285', empName: 'عمر الدوسري',   empId: 'EMP-055', dept: 'التطوير والابتكار', type: 'طلب أصل',             submittedDate: '28 فبراير 2025', status: 'rejected',  priority: 'normal', details: 'طلب لابتوب للعمل الميداني'),
  ];

  // ── Tasks ──────────────────────────────────────────────────
  static const List<AdminTask> tasks = [
    AdminTask(id: 'TSK-001', title: 'مراجعة تقارير الأداء الربعي Q1',    assignedTo: 'سارة المطيري',  dept: 'الموارد البشرية',   createdDate: '1 مارس 2025',   dueDate: '15 مارس 2025', status: 'in_progress', priority: 'high',   notes: 'يشمل مقارنة مع Q1 للعام الماضي'),
    AdminTask(id: 'TSK-002', title: 'تحديث سياسة الإجازات 2025',         assignedTo: 'ريم القحطاني', dept: 'الموارد البشرية',   createdDate: '5 مارس 2025',   dueDate: '12 مارس 2025', status: 'overdue',     priority: 'high',   notes: 'تجاوزت الموعد النهائي'),
    AdminTask(id: 'TSK-003', title: 'ترقية نظام ERP — المرحلة الثانية', assignedTo: 'فهد العتيبي',  dept: 'تقنية المعلومات',   createdDate: '10 فبراير 2025', dueDate: '30 مارس 2025', status: 'in_progress', priority: 'high'),
    AdminTask(id: 'TSK-004', title: 'إعداد خطة التوظيف Q2',              assignedTo: 'سارة المطيري',  dept: 'الموارد البشرية',   createdDate: '8 مارس 2025',   dueDate: '20 مارس 2025', status: 'pending',     priority: 'normal'),
    AdminTask(id: 'TSK-005', title: 'مراجعة ميزانية التسويق',            assignedTo: 'نورة الزهراني', dept: 'المالية',           createdDate: '3 مارس 2025',   dueDate: '18 مارس 2025', status: 'pending',     priority: 'normal'),
    AdminTask(id: 'TSK-006', title: 'تقييم أداء فريق المبيعات',         assignedTo: 'منصور الحربي', dept: 'المبيعات',          createdDate: '1 مارس 2025',   dueDate: '10 مارس 2025', status: 'overdue',     priority: 'high',   notes: 'التأخر يؤثر على خطة الحوافز'),
    AdminTask(id: 'TSK-007', title: 'إعداد تقرير الرواتب الشهري',       assignedTo: 'نورة الزهراني', dept: 'المالية',           createdDate: '9 مارس 2025',   dueDate: '28 مارس 2025', status: 'pending',     priority: 'normal'),
    AdminTask(id: 'TSK-008', title: 'برنامج الاستقبال للموظفين الجدد',  assignedTo: 'ريم القحطاني', dept: 'الموارد البشرية',   createdDate: '6 مارس 2025',   dueDate: '25 مارس 2025', status: 'in_progress', priority: 'low'),
  ];

  // ── Attendance ─────────────────────────────────────────────
  static const List<AttendanceRecord> attendanceRecords = [
    AttendanceRecord(empName: 'أحمد الغامدي',   empId: 'EMP-147', dept: 'التطوير',    date: 'الأحد 9 مارس',    checkIn: '08:02', checkOut: '17:08', hours: '9:06',  status: 'present', overtimeMin: 66),
    AttendanceRecord(empName: 'محمد الدوسري',   empId: 'EMP-112', dept: 'التقنية',    date: 'الأحد 9 مارس',    checkIn: '08:45', checkOut: '17:00', hours: '8:15',  status: 'late',    lateMin: 45),
    AttendanceRecord(empName: 'نورة الزهراني',  empId: 'EMP-203', dept: 'المالية',    date: 'الأحد 9 مارس',    checkIn: '07:58', checkOut: '18:30', hours: '10:32', status: 'present', overtimeMin: 90),
    AttendanceRecord(empName: 'فهد العتيبي',    empId: 'EMP-167', dept: 'التقنية',    date: 'الأحد 9 مارس',    checkIn: '—',     checkOut: '—',     hours: '—',     status: 'leave'),
    AttendanceRecord(empName: 'منصور الحربي',   empId: 'EMP-088', dept: 'المبيعات',   date: 'الأحد 9 مارس',    checkIn: '—',     checkOut: '—',     hours: '—',     status: 'absent'),
    AttendanceRecord(empName: 'سارة المطيري',   empId: 'EMP-089', dept: 'HR',         date: 'الأحد 9 مارس',    checkIn: '07:55', checkOut: '17:05', hours: '9:10',  status: 'present'),
    AttendanceRecord(empName: 'ريم القحطاني',   empId: 'EMP-220', dept: 'HR',         date: 'الأحد 9 مارس',    checkIn: '09:10', checkOut: '17:00', hours: '7:50',  status: 'late',    lateMin: 70),
    AttendanceRecord(empName: 'عمر الدوسري',    empId: 'EMP-055', dept: 'التطوير',    date: 'الأحد 9 مارس',    checkIn: '08:00', checkOut: '17:00', hours: '9:00',  status: 'present'),
  ];

  // ── Leave Records ──────────────────────────────────────────
  static const List<LeaveRecord> leaveRecords = [
    LeaveRecord(id: 'LV-2025-0342', empName: 'سارة المطيري',  empId: 'EMP-089', dept: 'الموارد البشرية',   type: 'سنوية',    fromDate: '15 مارس', toDate: '20 مارس', duration: '5 أيام',  reason: 'إجازة عائلية',           status: 'pending'),
    LeaveRecord(id: 'LV-2025-0335', empName: 'فهد العتيبي',   empId: 'EMP-167', dept: 'تقنية المعلومات',  type: 'مرضية',    fromDate: '8 مارس',  toDate: '10 مارس', duration: '3 أيام',  reason: 'شهادة طبية',             status: 'approved'),
    LeaveRecord(id: 'LV-2025-0320', empName: 'منصور الحربي',  empId: 'EMP-088', dept: 'المبيعات',         type: 'طارئة',    fromDate: '5 مارس',  toDate: '6 مارس',  duration: 'يومان',   reason: 'ظرف عائلي طارئ',        status: 'approved'),
    LeaveRecord(id: 'LV-2025-0310', empName: 'ريم القحطاني',  empId: 'EMP-220', dept: 'الموارد البشرية',  type: 'سنوية',    fromDate: '1 مارس',  toDate: '3 مارس',  duration: '3 أيام',  reason: 'إجازة اختيارية',        status: 'completed'),
    LeaveRecord(id: 'LV-2025-0290', empName: 'نورة الزهراني', empId: 'EMP-203', dept: 'المالية',          type: 'سنوية',    fromDate: '20 فبراير', toDate: '25 فبراير', duration: '5 أيام', reason: 'سفر خارجي',            status: 'completed'),
    LeaveRecord(id: 'LV-2025-0280', empName: 'أحمد الغامدي',  empId: 'EMP-147', dept: 'التطوير والابتكار', type: 'طارئة',   fromDate: '15 فبراير', toDate: '16 فبراير', duration: 'يومان', reason: 'ظرف خاص',              status: 'rejected'),
  ];

  // ── Announcements ──────────────────────────────────────────
  static const List<AdminAnnouncement> announcements = [
    AdminAnnouncement(id: 1, title: 'إجازة اليوم الوطني السعودي 95', category: 'إجازات رسمية', audience: 'جميع الموظفين', date: '20 سبتمبر 2025', body: 'يُعلن عن إجازة اليوم الوطني السعودي الـ 95 يوم الأربعاء 23 سبتمبر 2025. نتمنى للجميع إجازة طيبة.', publishStatus: 'منشور', isPinned: true),
    AdminAnnouncement(id: 2, title: 'تحديث سياسة العمل عن بُعد', category: 'سياسات HR', audience: 'جميع الموظفين', date: '5 مارس 2025', body: 'تمّ تحديث سياسة العمل عن بُعد. يرجى الاطلاع على النسخة المحدثة.', publishStatus: 'منشور'),
    AdminAnnouncement(id: 3, title: 'برنامج التدريب القيادي 2025', category: 'تدريب وتطوير', audience: 'المدراء والمشرفين', date: '1 مارس 2025', body: 'يُفتح التسجيل في برنامج التدريب القيادي لعام 2025 للمدراء والمشرفين.', publishStatus: 'منشور'),
    AdminAnnouncement(id: 4, title: 'مراجعة أداء النصف الأول 2025', category: 'الأداء', audience: 'جميع الإدارات', date: '28 فبراير 2025', body: 'تبدأ دورة مراجعة أداء النصف الأول من الشهر القادم. يُرجى تهيئة ملفات الأداء.', publishStatus: 'مسودة'),
  ];

  // ── Notifications ──────────────────────────────────────────
  static List<AdminNotification> get notifications => [
    AdminNotification(id: 1,  title: 'طلب موافقة عاجل',        body: 'طلب إجازة من سارة المطيري — يحتاج اعتمادك',              time: 'منذ 10 دقائق', type: 'approval',   isRead: false),
    AdminNotification(id: 2,  title: 'مهمة متأخرة',            body: 'تحديث سياسة الإجازات — تجاوزت الموعد النهائي',          time: 'منذ ساعة',     type: 'task',       isRead: false),
    AdminNotification(id: 3,  title: 'استثناء حضور',           body: 'منصور الحربي — غائب اليوم دون مسوّغ',                   time: 'منذ 3 ساعات',  type: 'attendance', isRead: false),
    // ── NEW: Project notifications ───────────────────────
    AdminNotification(id: 7,  title: '🏗 مشروع متأخر',         body: 'مشروع HR — المرحلة 2 تجاوزت الموعد النهائي',            time: 'منذ 5 ساعات',  type: 'project',    isRead: false),
    AdminNotification(id: 8,  title: '🏁 مرحلة مشروع ERP',    body: 'تكامل الأنظمة — الموعد النهائي: 31 مارس',               time: 'أمس 07:00',    type: 'project',    isRead: false),
    AdminNotification(id: 9,  title: '⚠️ خطر مشروع',          body: 'تأخر توفر الموارد التقنية — مشروع ERP — يحتاج إجراء',  time: 'أمس 10:00',    type: 'project',    isRead: true),
    // ── NEW: Expense notifications ───────────────────────
    AdminNotification(id: 10, title: '💰 طلب مصروف عالٍ',     body: 'فهد العتيبي — SAR 12,500 سفر GITEX — ينتظر اعتمادك',  time: 'منذ 6 ساعات',  type: 'expense',    isRead: false),
    AdminNotification(id: 11, title: '📎 مرفقات ناقصة',        body: 'طلب مصروف EXP-2025-018 بدون فاتورة مرفقة',            time: 'أمس 11:30',    type: 'expense',    isRead: true),
    AdminNotification(id: 12, title: '✅ مصروف معتمد',         body: 'تم اعتماد طلب مصاريف أحمد الغامدي — SAR 450',         time: 'أمس 14:00',    type: 'expense',    isRead: true),
    // ── Existing ─────────────────────────────────────────
    AdminNotification(id: 4,  title: '4 طلبات معلقة',          body: 'لديك 4 طلبات تحتاج مراجعتك في صندوق الموافقات',      time: 'أمس 08:00',    type: 'request',    isRead: true),
    AdminNotification(id: 5,  title: 'تقرير الأداء الأسبوعي', body: 'تم إعداد تقرير أداء الأسبوع الثاني من مارس',          time: 'أمس 09:00',    type: 'report',     isRead: true),
    AdminNotification(id: 6,  title: 'موظف جديد',              body: 'انضم رانا العمري إلى إدارة المبيعات اليوم',           time: 'قبل يومين',    type: 'hr',         isRead: true),
  ];

  // ── Follow-up Items ────────────────────────────────────────
  static const List<FollowUpItem> followUpItems = [
    FollowUpItem(id: 'FU-001', title: 'متابعة تحديث سياسة الإجازات',      responsible: 'ريم القحطاني', dept: 'HR',       dueDate: '12 مارس', status: 'overdue',     type: 'task',     isOverdue: true),
    FollowUpItem(id: 'FU-002', title: 'اعتماد طلب إجازة سارة المطيري',   responsible: 'خالد الشمري',  dept: 'إدارة',    dueDate: 'اليوم',   status: 'pending',     type: 'approval', isEscalated: false),
    FollowUpItem(id: 'FU-003', title: 'مراجعة تقييم فريق المبيعات',      responsible: 'منصور الحربي', dept: 'المبيعات', dueDate: '10 مارس', status: 'overdue',     type: 'task',     isOverdue: true, isEscalated: true),
    FollowUpItem(id: 'FU-004', title: 'إكمال ملف موظف جديد — رانا العمري', responsible: 'سارة المطيري', dept: 'HR',      dueDate: '14 مارس', status: 'in_progress', type: 'hr'),
    FollowUpItem(id: 'FU-005', title: 'مراجعة ميزانية التسويق الربعية',  responsible: 'نورة الزهراني', dept: 'المالية', dueDate: '18 مارس', status: 'pending',     type: 'finance'),
    FollowUpItem(id: 'FU-006', title: 'متابعة ترقية نظام ERP',            responsible: 'فهد العتيبي',   dept: 'التقنية', dueDate: '30 مارس', status: 'in_progress', type: 'task'),
  ];

  // ── KPIs ───────────────────────────────────────────────────
  static List<KpiStat> get kpis => [
    KpiStat(label: 'إجمالي الموظفين',   value: '109', change: '+3 هذا الشهر',  icon: '👥', isPositive: true,  color: AppColors.navyMid),
    KpiStat(label: 'حضور اليوم',        value: '94',  change: '86% من الكل',   icon: '✅', isPositive: true,  color: AppColors.success),
    KpiStat(label: 'طلبات معلقة',       value: '31',  change: '+7 الأسبوع',   icon: '📋', isPositive: false, color: AppColors.warning),
    KpiStat(label: 'مهام متأخرة',       value: '8',   change: 'تحتاج متابعة', icon: '⚠️', isPositive: false, color: AppColors.error),
    KpiStat(label: 'في إجازة اليوم',   value: '11',  change: '10% من الكل',   icon: '🌴', isPositive: true,  color: AppColors.teal),
    KpiStat(label: 'نسبة إنجاز المهام', value: '73%', change: '+5% عن الأسبوع', icon: '📈', isPositive: true, color: AppColors.gold),
  ];

  // ── Recent Activity ────────────────────────────────────────
  static const List<Map<String, String>> recentActivity = [
    {'icon': '✅', 'text': 'تمت الموافقة على طلب إجازة فهد العتيبي',    'time': 'منذ 15 د', 'type': 'success'},
    {'icon': '📋', 'text': 'تقديم طلب مصاريف جديد من محمد الدوسري',   'time': 'منذ 32 د', 'type': 'info'},
    {'icon': '⚠️', 'text': 'تسجيل تأخر — ريم القحطاني — 70 دقيقة',   'time': 'منذ ساعة', 'type': 'warning'},
    {'icon': '🔴', 'text': 'منصور الحربي — غياب غير مبرر اليوم',      'time': 'منذ 2 س',  'type': 'error'},
    {'icon': '📝', 'text': 'تم إنشاء مهمة جديدة لإدارة التطوير',     'time': 'أمس',      'type': 'info'},
    {'icon': '👤', 'text': 'انضم رانا العمري إلى فريق المبيعات',      'time': 'أمس',      'type': 'success'},
  ];

  // ─────────────────────────────────────────────────────────
  // PROJECT DATA
  // ─────────────────────────────────────────────────────────
  static const List<Project> projects = [
    Project(
      id: 'P01', code: 'PRJ-2025-001',
      name: 'تطوير نظام إدارة الموارد البشرية ERP',
      dept: 'تقنية المعلومات', manager: 'فهد العتيبي', managerInitials: 'فع',
      startDate: '1 يناير 2025', endDate: '30 يونيو 2025',
      status: 'active', priority: 'high', progress: 0.62,
      taskCount: 24, completedTasks: 15, milestoneCount: 5,
      description: 'تطوير وتحديث نظام ERP الخاص بإدارة الموارد البشرية ليشمل كافة الوحدات التشغيلية.',
      isDelayed: false,
    ),

    Project(
      id: 'P02', code: 'PRJ-2025-002',
      name: 'إعادة هيكلة سياسات الموارد البشرية 2025',
      dept: 'الموارد البشرية', manager: 'سارة المطيري', managerInitials: 'سم',
      startDate: '15 فبراير 2025', endDate: '15 أبريل 2025',
      status: 'delayed', priority: 'high', progress: 0.38,
      taskCount: 12, completedTasks: 4, milestoneCount: 3,
      description: 'مراجعة شاملة لسياسات الموارد البشرية وتحديثها لتتوافق مع الأنظمة الحديثة.',
      isDelayed: true,
    ),
    Project(
      id: 'P03', code: 'PRJ-2025-003',
      name: 'توسعة فريق المبيعات — الربع الثاني',
      dept: 'المبيعات', manager: 'منصور الحربي', managerInitials: 'مح',
      startDate: '1 مارس 2025', endDate: '31 مايو 2025',
      status: 'active', priority: 'normal', progress: 0.45,
      taskCount: 8, completedTasks: 4, milestoneCount: 2,
      description: 'خطة توسعة فريق المبيعات لاستيعاب 12 موظف جديد في الربع الثاني.',
      isDelayed: false,
    ),
    Project(
      id: 'P04', code: 'PRJ-2025-004',
      name: 'برنامج التدريب والتطوير القيادي',
      dept: 'الموارد البشرية', manager: 'ريم القحطاني', managerInitials: 'رق',
      startDate: '1 مارس 2025', endDate: '30 سبتمبر 2025',
      status: 'active', priority: 'normal', progress: 0.20,
      taskCount: 16, completedTasks: 3, milestoneCount: 4,
      description: 'برنامج تدريبي متكامل يستهدف المدراء والمشرفين لتطوير الكفاءات القيادية.',
      isDelayed: false,
    ),
    Project(
      id: 'P05', code: 'PRJ-2025-005',
      name: 'مراجعة ميزانية التشغيل Q2 2025',
      dept: 'المالية', manager: 'نورة الزهراني', managerInitials: 'نز',
      startDate: '10 مارس 2025', endDate: '10 أبريل 2025',
      status: 'delayed', priority: 'high', progress: 0.55,
      taskCount: 6, completedTasks: 3, milestoneCount: 2,
      description: 'مراجعة شاملة وتحليل ميزانية التشغيل للربع الثاني من عام 2025.',
      isDelayed: true,
    ),
    Project(
      id: 'P06', code: 'PRJ-2024-018',
      name: 'تطوير منصة التجارة الإلكترونية',
      dept: 'التطوير والابتكار', manager: 'عمر الدوسري', managerInitials: 'عد',
      startDate: '1 أكتوبر 2024', endDate: '28 فبراير 2025',
      status: 'completed', priority: 'high', progress: 1.0,
      taskCount: 32, completedTasks: 32, milestoneCount: 6,
      description: 'بناء منصة متكاملة للتجارة الإلكترونية مع ربط بأنظمة الدفع المحلية.',
      isDelayed: false,
    ),
  ];

  static const List<ProjectMilestone> milestones = [
    ProjectMilestone(id: 'M01', projectId: 'P01', title: 'تحليل المتطلبات والتصميم',    targetDate: '28 يناير 2025',  status: 'completed', isCompleted: true),
    ProjectMilestone(id: 'M02', projectId: 'P01', title: 'تطوير الوحدة الأساسية',       targetDate: '28 فبراير 2025', status: 'completed', isCompleted: true),
    ProjectMilestone(id: 'M03', projectId: 'P01', title: 'تكامل الأنظمة ووحدة الحضور', targetDate: '31 مارس 2025',   status: 'active',    isCompleted: false),
    ProjectMilestone(id: 'M04', projectId: 'P01', title: 'الاختبار الشامل والتدقيق',    targetDate: '30 أبريل 2025',  status: 'pending',   isCompleted: false),
    ProjectMilestone(id: 'M05', projectId: 'P01', title: 'الإطلاق والتدريب',             targetDate: '30 يونيو 2025',  status: 'pending',   isCompleted: false),
    ProjectMilestone(id: 'M06', projectId: 'P02', title: 'مراجعة السياسات الحالية',     targetDate: '1 مارس 2025',    status: 'completed', isCompleted: true),
    ProjectMilestone(id: 'M07', projectId: 'P02', title: 'صياغة السياسات الجديدة',      targetDate: '25 مارس 2025',   status: 'delayed',   isCompleted: false, isDelayed: true),
    ProjectMilestone(id: 'M08', projectId: 'P02', title: 'اعتماد واعتراض الإدارة',      targetDate: '15 أبريل 2025',  status: 'pending',   isCompleted: false),
  ];

  static const List<ProjectRisk> risks = [
    ProjectRisk(id: 'R01', projectId: 'P01', title: 'تأخر توفر الموارد التقنية',  impact: 'عالي',  likelihood: 'متوسط', owner: 'فهد العتيبي',  status: 'مراقَب'),
    ProjectRisk(id: 'R02', projectId: 'P02', title: 'عدم توافق السياسات مع الأنظمة', impact: 'متوسط', likelihood: 'منخفض', owner: 'سارة المطيري', status: 'مراقَب'),
    ProjectRisk(id: 'R03', projectId: 'P05', title: 'تأخر بيانات المالية',         impact: 'عالي',  likelihood: 'عالٍ',  owner: 'نورة الزهراني', status: 'نشط'),
  ];

  // ─────────────────────────────────────────────────────────
  // EXPENSE DATA
  // ─────────────────────────────────────────────────────────
  static const List<ExpenseRequest> expenses = [
    ExpenseRequest(id: 'EXP-2025-021', empName: 'محمد الدوسري',   empId: 'EMP-112', dept: 'تقنية المعلومات',   category: 'تدريب',    categoryIcon: '🎓', amount: 3800,  currency: 'SAR', submittedDate: 'منذ 4 ساعات',  expenseDate: '8 مارس 2025',  status: 'pending',   priority: 'normal', notes: 'دورة أمن المعلومات — بوابة إيداك',     hasAttachment: true),
    ExpenseRequest(id: 'EXP-2025-020', empName: 'فهد العتيبي',    empId: 'EMP-167', dept: 'تقنية المعلومات',   category: 'سفر',      categoryIcon: '✈️', amount: 12500, currency: 'SAR', submittedDate: 'منذ 6 ساعات',  expenseDate: '5 مارس 2025',  status: 'pending',   priority: 'high',   notes: 'سفر مؤتمر GITEX دبي',                  hasAttachment: true,  isHighValue: true),
    ExpenseRequest(id: 'EXP-2025-019', empName: 'منصور الحربي',   empId: 'EMP-088', dept: 'المبيعات',          category: 'ضيافة',    categoryIcon: '🍽', amount: 1200,  currency: 'SAR', submittedDate: 'أمس',           expenseDate: '7 مارس 2025',  status: 'pending',   priority: 'low',    notes: 'استضافة عملاء — مطعم التوبة',           hasAttachment: true),
    ExpenseRequest(id: 'EXP-2025-018', empName: 'أحمد الغامدي',   empId: 'EMP-147', dept: 'التطوير والابتكار', category: 'نقل',      categoryIcon: '🚗', amount: 450,   currency: 'SAR', submittedDate: 'منذ يومين',     expenseDate: '6 مارس 2025',  status: 'approved',  priority: 'low',    notes: 'تنقل لاجتماع خارجي',                    hasAttachment: false, projectRef: 'PRJ-2025-001'),
    ExpenseRequest(id: 'EXP-2025-017', empName: 'نورة الزهراني',  empId: 'EMP-203', dept: 'المالية',            category: 'مشتريات', categoryIcon: '🛒', amount: 6800,  currency: 'SAR', submittedDate: 'منذ 3 أيام',    expenseDate: '4 مارس 2025',  status: 'approved',  priority: 'normal', notes: 'مستلزمات مكتبية للربع الثاني',          hasAttachment: true,  isHighValue: true),
    ExpenseRequest(id: 'EXP-2025-016', empName: 'سارة المطيري',   empId: 'EMP-089', dept: 'الموارد البشرية',   category: 'سفر',      categoryIcon: '✈️', amount: 8900,  currency: 'SAR', submittedDate: 'منذ 4 أيام',    expenseDate: '3 مارس 2025',  status: 'rejected',  priority: 'normal', notes: 'مؤتمر HR — أبوظبي',                     hasAttachment: false, isHighValue: true),
    ExpenseRequest(id: 'EXP-2025-015', empName: 'ريم القحطاني',   empId: 'EMP-220', dept: 'الموارد البشرية',   category: 'تشغيل',   categoryIcon: '⚙️', amount: 2300,  currency: 'SAR', submittedDate: 'منذ أسبوع',     expenseDate: '28 فبراير 2025',status: 'approved',  priority: 'low',    notes: 'خدمات صيانة وتشغيل',                    hasAttachment: true),
    ExpenseRequest(id: 'EXP-2025-014', empName: 'عمر الدوسري',    empId: 'EMP-055', dept: 'التطوير والابتكار', category: 'سكن',      categoryIcon: '🏨', amount: 4500,  currency: 'SAR', submittedDate: 'منذ أسبوع',     expenseDate: '27 فبراير 2025',status: 'returned',  priority: 'normal', notes: 'إقامة فندقية — رحلة عمل الرياض',         hasAttachment: false, projectRef: 'PRJ-2024-018'),
  ];

  static const List<ExpenseCategory> expenseCategories = [
    ExpenseCategory(id: 'EC01', name: 'سفر',      icon: '✈️', requestCount: 12, totalAmount: 68500),
    ExpenseCategory(id: 'EC02', name: 'تدريب',    icon: '🎓', requestCount: 8,  totalAmount: 32400),
    ExpenseCategory(id: 'EC03', name: 'ضيافة',    icon: '🍽', requestCount: 15, totalAmount: 18200),
    ExpenseCategory(id: 'EC04', name: 'مشتريات',  icon: '🛒', requestCount: 7,  totalAmount: 41600),
    ExpenseCategory(id: 'EC05', name: 'نقل',      icon: '🚗', requestCount: 22, totalAmount: 9800),
    ExpenseCategory(id: 'EC06', name: 'سكن',      icon: '🏨', requestCount: 6,  totalAmount: 27000),
    ExpenseCategory(id: 'EC07', name: 'تشغيل',    icon: '⚙️', requestCount: 10, totalAmount: 15400),
    ExpenseCategory(id: 'EC08', name: 'أخرى',     icon: '📦', requestCount: 5,  totalAmount: 7100),
  ];
}
