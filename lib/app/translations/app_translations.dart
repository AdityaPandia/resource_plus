import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          // Common
          'loading': 'Loading...',
          'error': 'Error',
          'success': 'Success',
          'cancel': 'Cancel',
          'save': 'Save',
          'delete': 'Delete',
          'edit': 'Edit',
          'add': 'Add',
          'continue': 'Continue',
          'back': 'Back',
          'next': 'Next',
          'retry': 'Retry',
          'refresh': 'Refresh',
          'close': 'Close',
          'ok': 'OK',
          'yes': 'Yes',
          'no': 'No',

          // Navigation
          'home': 'Home',
          'attendance': 'Attendance',
          'profile': 'Profile',
          'notifications': 'Notifications',
          'settings': 'Settings',
          'calendar': 'Calendar',

          // Authentication
          'instance_scan': 'Instance Scan',
          'scan_qr_code': 'Scan QR Code',
          'enter_instance_name': 'Enter Instance Name',
          'instance_name': 'Instance Name',
          'invalid_instance': 'Invalid instance',
          'network_error': 'Network error. Please try again.',
          'unexpected_response': 'Unexpected response from server.',

          'email_verification': 'Email Verification',
          'enter_email': 'Enter your email address',
          'email': 'Email',
          'send_code': 'Send Code',
          'invalid_email': 'Invalid email address',

          'code_verification': 'Code Verification',
          'enter_verification_code': 'Enter verification code',
          'verification_code': 'Verification Code',
          'verify': 'Verify',
          'resend_code': 'Resend Code',
          'invalid_otp': 'Invalid OTP',

          'password': 'Password',
          'enter_password': 'Enter your password',
          'invalid_credentials': 'Invalid credentials',
          'user_locked':
              'User is locked, Please contact the system administrator to unlock!',
          'user_disabled':
              'Your login is Disabled, Please contact the system administrator.',
          'one_more_chance':
              'You have one more chance left. If your login attempt fails one more time, your account will get locked.',
          'employee_terminated':
              'Your login attempt was not successful. Employee is terminated/resigned.',

          'new_password': 'New Password',
          'confirm_password': 'Confirm Password',
          'set_password': 'Set Password',
          'password_changed': 'Password changed successfully',
          'password_change_failed': 'Password change failed',
          'same_password_error':
              'Sorry, your new password cannot be the same as your old password. Please choose a different password and try again.',

          'biometric_link': 'Biometric Link',
          'link_biometric': 'Link Biometric',
          'biometric_linked': 'Biometric linked successfully',

          'login': 'Login',
          'username': 'Username',
          'forgot_password': 'Forgot Password?',
          'login_with_biometric': 'Login with Biometric',
          'authentication_successful': 'Authentication successful',

          // Home
          'welcome_back': 'Welcome Back',
          'hr_portal': 'HR Portal',
          'access_hr_services': 'Access HR Services and information',
          'todays_schedule': 'Today\'s Schedule',
          'see_all': 'See All',

          // Attendance
          'attendance': 'Attendance',
          'recent_attendance': 'Recent Attendance',
          'present': 'Present',
          'absent': 'Absent',
          'late': 'Late',
          'early': 'Early',
          'weekend': 'Week End',

          // Profile
          'profile': 'Profile',
          'contact_information': 'Contact Information',
          'work_information': 'Work Information',
          'skills': 'Skills',
          'certifications': 'Certifications',
          'employee_number': 'Employee Number',
          'employee_name': 'Employee Name',
          'phone': 'Phone',
          'join_date': 'Join Date',
          'company': 'Company',
          'department': 'Department',
          'position': 'Position',
          'organization': 'Organization',
          'logout': 'Logout',

          // Notifications
          'notifications': 'Notifications',
          'mark_all_as_read': 'Mark all as read',
          'unread': 'Unread',
          'read': 'Read',

          // Settings
          'settings': 'Settings',
          'preferences': 'Preferences',
          'language': 'Language',
          'choose_language': 'Choose your preferred language',
          'dark_mode': 'Dark Mode',
          'security': 'Security',
          'change_password': 'Change Password',
          'privacy_settings': 'Privacy Settings',
          'notifications_settings': 'Notifications',
          'help_support': 'Help & Support',
          'support': 'Support',
          'sign_out': 'Sign out',
          'mark_all_as_read': 'Mark all as read',
          'push_notifications': 'Push Notifications',
          'email_notifications': 'Email Notifications',
          'data_collection': 'Data Collection',
          'analytics': 'Analytics',
          'contact_support': 'Contact Support',
          'call_support': 'Call Support',
          'live_chat': 'Live Chat',

          // Calendar
          'calendar': 'Calendar',
          'connect_calendar': 'Connect Calendar',
          'disconnect_calendar': 'Disconnect Calendar',
          'connect_google_calendar': 'Connect Google Calendar',
          'calendar_connected': 'Calendar connected successfully',
          'calendar_disconnected': 'Calendar disconnected successfully',
          'failed_to_connect': 'Failed to connect to Google Calendar',
          'no_events': 'No events for this date',
          'add_event': 'Add Event',
          'event_title': 'Event Title',
          'event_description': 'Event Description',
          'event_location': 'Event Location',
          'start_time': 'Start Time',
          'end_time': 'End Time',
          'today': 'Today',

          // Error messages
          'failed_to_load_data': 'Failed to load data',
          'failed_to_load_home_data': 'Failed to load home data',
          'failed_to_load_attendance_data': 'Failed to load attendance data',
          'failed_to_load_profile_data': 'Failed to load profile data',
          'failed_to_load_notification_data':
              'Failed to load notification data',
          'failed_to_load_settings_data': 'Failed to load settings data',
          'failed_to_update_notification': 'Failed to update notification',

          // Success messages
          'data_loaded_successfully': 'Data loaded successfully',
          'notification_updated': 'Notification updated successfully',
        },
        'ar_SA': {
          // Common
          'loading': 'جاري التحميل...',
          'error': 'خطأ',
          'success': 'نجح',
          'cancel': 'إلغاء',
          'save': 'حفظ',
          'delete': 'حذف',
          'edit': 'تعديل',
          'add': 'إضافة',
          'continue': 'متابعة',
          'back': 'رجوع',
          'next': 'التالي',
          'retry': 'إعادة المحاولة',
          'refresh': 'تحديث',
          'close': 'إغلاق',
          'ok': 'موافق',
          'yes': 'نعم',
          'no': 'لا',

          // Navigation
          'home': 'الرئيسية',
          'attendance': 'الحضور',
          'profile': 'الملف الشخصي',
          'notifications': 'الإشعارات',
          'settings': 'الإعدادات',
          'calendar': 'التقويم',

          // Authentication
          'instance_scan': 'مسح المثيل',
          'scan_qr_code': 'مسح رمز QR',
          'enter_instance_name': 'أدخل اسم المثيل',
          'instance_name': 'اسم المثيل',
          'invalid_instance': 'مثيل غير صالح',
          'network_error': 'خطأ في الشبكة. يرجى المحاولة مرة أخرى.',
          'unexpected_response': 'استجابة غير متوقعة من الخادم.',

          'email_verification': 'التحقق من البريد الإلكتروني',
          'enter_email': 'أدخل عنوان بريدك الإلكتروني',
          'email': 'البريد الإلكتروني',
          'send_code': 'إرسال الرمز',
          'invalid_email': 'عنوان بريد إلكتروني غير صالح',

          'code_verification': 'التحقق من الرمز',
          'enter_verification_code': 'أدخل رمز التحقق',
          'verification_code': 'رمز التحقق',
          'verify': 'تحقق',
          'resend_code': 'إعادة إرسال الرمز',
          'invalid_otp': 'رمز OTP غير صالح',

          'password': 'كلمة المرور',
          'enter_password': 'أدخل كلمة المرور',
          'invalid_credentials': 'بيانات اعتماد غير صالحة',
          'user_locked':
              'المستخدم مقفل، يرجى الاتصال بمسؤول النظام لإلغاء القفل!',
          'user_disabled': 'تسجيل الدخول معطل، يرجى الاتصال بمسؤول النظام.',
          'one_more_chance':
              'لديك فرصة واحدة متبقية. إذا فشلت محاولة تسجيل الدخول مرة أخرى، سيتم قفل حسابك.',
          'employee_terminated':
              'محاولة تسجيل الدخول غير ناجحة. الموظف منتهي/مستقيل.',

          'new_password': 'كلمة مرور جديدة',
          'confirm_password': 'تأكيد كلمة المرور',
          'set_password': 'تعيين كلمة المرور',
          'password_changed': 'تم تغيير كلمة المرور بنجاح',
          'password_change_failed': 'فشل تغيير كلمة المرور',
          'same_password_error':
              'عذراً، لا يمكن أن تكون كلمة المرور الجديدة هي نفس كلمة المرور القديمة. يرجى اختيار كلمة مرور مختلفة والمحاولة مرة أخرى.',

          'biometric_link': 'ربط القياسات الحيوية',
          'link_biometric': 'ربط القياسات الحيوية',
          'biometric_linked': 'تم ربط القياسات الحيوية بنجاح',

          'login': 'تسجيل الدخول',
          'username': 'اسم المستخدم',
          'forgot_password': 'نسيت كلمة المرور؟',
          'login_with_biometric': 'تسجيل الدخول بالقياسات الحيوية',
          'authentication_successful': 'تم المصادقة بنجاح',

          // Home
          'welcome_back': 'مرحباً بعودتك',
          'hr_portal': 'بوابة الموارد البشرية',
          'access_hr_services': 'الوصول إلى خدمات الموارد البشرية والمعلومات',
          'todays_schedule': 'جدول اليوم',
          'see_all': 'عرض الكل',

          // Attendance
          'attendance': 'الحضور',
          'recent_attendance': 'الحضور الأخير',
          'present': 'حاضر',
          'absent': 'غائب',
          'late': 'متأخر',
          'early': 'مبكر',
          'weekend': 'نهاية الأسبوع',

          // Profile
          'profile': 'الملف الشخصي',
          'contact_information': 'معلومات الاتصال',
          'work_information': 'معلومات العمل',
          'skills': 'المهارات',
          'certifications': 'الشهادات',
          'employee_number': 'رقم الموظف',
          'employee_name': 'اسم الموظف',
          'phone': 'الهاتف',
          'join_date': 'تاريخ الانضمام',
          'company': 'الشركة',
          'department': 'القسم',
          'position': 'المنصب',
          'organization': 'المنظمة',
          'logout': 'تسجيل الخروج',

          // Notifications
          'notifications': 'الإشعارات',
          'mark_all_as_read': 'تحديد الكل كمقروء',
          'unread': 'غير مقروء',
          'read': 'مقروء',

          // Settings
          'settings': 'الإعدادات',
          'preferences': 'التفضيلات',
          'language': 'اللغة',
          'choose_language': 'اختر لغتك المفضلة',
          'dark_mode': 'الوضع المظلم',
          'security': 'الأمان',
          'change_password': 'تغيير كلمة المرور',
          'privacy_settings': 'إعدادات الخصوصية',
          'notifications_settings': 'إعدادات الإشعارات',
          'help_support': 'المساعدة والدعم',
          'support': 'الدعم',
          'sign_out': 'تسجيل الخروج',
          'mark_all_as_read': 'تحديد الكل كمقروء',
          'push_notifications': 'الإشعارات الفورية',
          'email_notifications': 'إشعارات البريد الإلكتروني',
          'data_collection': 'جمع البيانات',
          'analytics': 'التحليلات',
          'contact_support': 'اتصل بالدعم',
          'call_support': 'اتصال الدعم',
          'live_chat': 'الدردشة المباشرة',

          // Calendar
          'calendar': 'التقويم',
          'connect_calendar': 'ربط التقويم',
          'disconnect_calendar': 'فصل التقويم',
          'connect_google_calendar': 'ربط تقويم Google',
          'calendar_connected': 'تم ربط التقويم بنجاح',
          'calendar_disconnected': 'تم فصل التقويم بنجاح',
          'failed_to_connect': 'فشل الاتصال بتقويم Google',
          'no_events': 'لا توجد أحداث لهذا التاريخ',
          'add_event': 'إضافة حدث',
          'event_title': 'عنوان الحدث',
          'event_description': 'وصف الحدث',
          'event_location': 'موقع الحدث',
          'start_time': 'وقت البدء',
          'end_time': 'وقت الانتهاء',
          'today': 'اليوم',

          // Error messages
          'failed_to_load_data': 'فشل تحميل البيانات',
          'failed_to_load_home_data': 'فشل تحميل بيانات الصفحة الرئيسية',
          'failed_to_load_attendance_data': 'فشل تحميل بيانات الحضور',
          'failed_to_load_profile_data': 'فشل تحميل بيانات الملف الشخصي',
          'failed_to_load_notification_data': 'فشل تحميل بيانات الإشعارات',
          'failed_to_load_settings_data': 'فشل تحميل بيانات الإعدادات',
          'failed_to_update_notification': 'فشل تحديث الإشعار',

          // Success messages
          'data_loaded_successfully': 'تم تحميل البيانات بنجاح',
          'notification_updated': 'تم تحديث الإشعار بنجاح',
        },
      };
}
