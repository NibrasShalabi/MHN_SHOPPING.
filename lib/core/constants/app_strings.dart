/// All user-facing text lives here — single source of truth.
/// The app is Arabic-only by design (no localization/.arb files needed).
/// Change any text here and it updates everywhere it's used.
class AppStrings {
  AppStrings._();

  // ==================== عام / مشترك ====================
  static const String appName = 'MHN Shopping';
  static const String ok = 'حسناً';
  static const String cancel = 'إلغاء';
  static const String confirm = 'تأكيد';
  static const String retry = 'إعادة المحاولة';
  static const String save = 'حفظ';
  static const String edit = 'تعديل';
  static const String delete = 'حذف';
  static const String search = 'بحث';
  static const String loading = 'جاري التحميل...';
  static const String noInternetConnection = 'لا يوجد اتصال بالإنترنت';
  static const String somethingWentWrong = 'حدث خطأ، حاول لاحقاً';
  static const String noResultsFound = 'لا توجد نتائج';

  // ==================== Splash / Onboarding ====================
  static const String onboardingTitle1 = 'أهلاً بك في ٌ';
  static const String onboardingSubtitle1 = 'متجرك المتكامل بتصميم فاخر';
  static const String onboardingTitle2 = 'تسوّق بسهولة';
  static const String onboardingSubtitle2 = 'سلتك تبقى محفوظة، وتابع طلبك لحظة بلحظة';
  static const String onboardingTitle3 = 'نظام الولاء';
  static const String onboardingSubtitle3 = 'اربح نقاط مع كل عملية شراء واستبدلها بمنتجات مميزة';
  static const String skip = 'تخطي';
  static const String next = 'التالي';
  static const String getStarted = 'ابدأ الآن';

  // ==================== تسجيل الدخول / التسجيل ====================
  static const String login = 'تسجيل الدخول';
  static const String signup = 'إنشاء حساب';
  static const String phoneNumber = 'رقم الهاتف';
  static const String secondaryPhoneNumber = 'رقم هاتف ثانٍ (اختياري)';
  static const String fullName = 'الاسم';
  static const String familyName = 'الكنية';
  static const String location = 'المكان';
  static const String governorate = 'المحافظة';
  static const String area = 'المنطقة';
  static const String gender = 'الجنس';
  static const String male = 'ذكر';
  static const String female = 'أنثى';
  static const String forgotPassword = 'نسيت كلمة المرور؟';
  static const String email = 'البريد الإلكتروني';
  static const String password = 'كلمة السر';
  static const String confirmPassword = 'تأكيد كلمة السر';
  static const String noAccountYet = 'ليس لديك حساب؟';
  static const String resetPasswordTitle = 'استعادة كلمة السر';
  static const String resetPasswordSubtitle =
      'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة تعيين كلمة السر';
  static const String sendResetLink = 'إرسال رابط إعادة التعيين';
  static const String checkYourEmail = 'تحقق من بريدك الإلكتروني';
  static const String resetLinkSentTo = 'أرسلنا رابط إعادة تعيين كلمة السر إلى';
  static const String backToLogin = 'رجوع لتسجيل الدخول';
  static const String selectGovernorate = 'اختر المحافظة';
  static const String selectGender = 'اختر الجنس';

  // ==================== رسائل التحقق ====================
  static const String fieldRequired = 'هذا الحقل مطلوب';
  static const String invalidEmail = 'صيغة البريد الإلكتروني غير صحيحة';
  static const String passwordTooShort = 'كلمة السر يجب أن تكون {min} أحرف على الأقل';
  static const String passwordsDoNotMatch = 'كلمتا السر غير متطابقتين';
  static const String invalidPhone = 'رقم الهاتف غير صحيح';
  static const String fillAllFields = 'الرجاء تعبئة كل الحقول';
  static const String enterYourEmail = 'أدخل بريدك الإلكتروني';

  // ==================== رسائل الأخطاء ====================
  static const String serverError = 'حدث خطأ بالسيرفر';
  static const String serverErrorRetry = 'حدث خطأ بالسيرفر، حاول لاحقاً';
  static const String checkYourConnection = 'تأكد من اتصالك بالإنترنت';
  static const String cacheError = 'حدث خطأ بالبيانات المحفوظة';
  static const String cacheErrorLocal = 'حدث خطأ بالبيانات المحفوظة محلياً';
  static const String noPermission = 'ليس لديك صلاحية للوصول لهذا المحتوى';
  static const String itemNotFound = 'العنصر المطلوب غير موجود';
  static const String actionAlreadyDone = 'تم تنفيذ هذه العملية مسبقاً';
  static const String unknownError = 'حدث خطأ غير متوقع';

  // ==================== الرئيسية / الأقسام ====================
  static const String home = 'الرئيسية';
  static const String categories = 'الأقسام';
  static const String allProducts = 'كل المنتجات';
  static const String filters = 'الفلاتر';
  static const String filterAll = 'الكل';
  static const String newBadge = 'جديد';
  static const String currencySy = 'ل.س';
  static const String pointsUnit = 'نقطة';

  // شعار التطبيق (سطرين)
  static const String logoLine1 = 'MHN';
  static const String logoLine2 = 'Shopping';

  // ==================== المنتج ====================
  static const String addToCart = 'أضف إلى السلة';
  static const String productDescription = 'الوصف';
  static const String ingredients = 'المكونات';
  static const String benefits = 'الفوائد';
  static const String usageInstructions = 'طريقة الاستخدام';
  static const String quantity = 'الكمية';
  static const String size = 'المقاس';
  static const String color = 'اللون';
  static const String sizeGuide = 'دليل المقاسات';
  static const String sizeGuideNote = 'القياسات تقريبية وقد تختلف قليلاً بين القطع.';
  static const String selectSize = 'اختاري المقاس';
  static const String selectColor = 'اختاري اللون';
  static const String price = 'السعر';
  static const String outOfStock = 'غير متوفر حالياً';

  // ==================== السلة ====================
  static const String cart = 'السلة';
  static const String emptyCart = 'سلتك فارغة';
  static const String emptyCartSubtitle = 'أضف منتجات لتظهر هنا';
  static const String subtotal = 'مجموع المنتجات';
  static const String shipping = 'التوصيل والشحن';
  static const String shippingNote = 'يُحدَّد حسب المنطقة عند التواصل';
  static const String total = 'الإجمالي';

  // مشاركة السلة
  static const String shareCart = 'مشاركة السلة';
  static const String sharedCartTitle = 'سلة مشتركة';
  static const String sharedCartIntro =
      'هذه سلة شاركها معك شخص آخر. أضيفي ما يعجبك إلى سلتك.';
  static const String saveWholeCart = 'حفظ السلة كاملة';
  static const String saveItem = 'حفظ';
  static const String itemSaved = 'تمت الإضافة إلى سلتك';
  static const String cartSaved = 'تم حفظ السلة كاملة';
  static const String sharedCartExpired = 'انتهت صلاحية هذه السلة';
  static const String cartShareMessage = 'شاهد سلّتي على تطبيق MHN:';
  static const String proceedToCheckout = 'إرسال الطلب عبر واتساب';
  static const String whatsappOrderHeader = 'طلب جديد من تطبيق MHN:';
  // TODO(logic-phase): move to remote config so it can change without a release.
  static const String adminWhatsappNumber = '000000000';
  static const String addedToCart = 'تمت الإضافة إلى السلة';
  static const String cartTermsLabel =
      'أوافق على أنه يجب دفع قيمة الطلب حتى يتم تثبيته';
  static const String cartTermsRequired = 'يجب الموافقة على الشرط أولاً';
  static const String sendingToWhatsapp = 'جارٍ إرسال الطلب عبر واتساب...';
  static const String clearCart = 'إفراغ السلة';
  static const String clearCartConfirm = 'سيتم إفراغ كامل السلة، هل أنت متأكد؟';
  static const String cartCleared = 'تم إفراغ السلة';

  // ==================== الطلب ====================
  static const String checkout = 'إتمام الطلب';
  static const String termsAndConditions = 'الشروط والأحكام';
  static const String agreeToTerms = 'أوافق على الشروط والأحكام';
  static const String placeOrder = 'إرسال الطلب';
  static const String cashPayment = 'الدفع نقداً';
  static const String transferPayment = 'تحويل';
  static const String orderPlacedSuccessfully = 'تم إرسال طلبك بنجاح';

  // ==================== متابعة الطلب ====================
  static const String orderTracking = 'متابعة الطلب';
  static const String orderStatusPending = 'قيد الانتظار';
  static const String orderStatusConfirmed = 'تم التأكيد';
  static const String orderStatusPreparing = 'قيد التحضير';
  static const String orderStatusOutForDelivery = 'في الطريق إليك';
  static const String orderStatusDelivered = 'تم التسليم';
  static const String orderStatusDelayed = 'مؤجّل';
  static const String orderStatusCancelled = 'ملغى';
  static const String expectedDelivery = 'الوقت المتوقع للتسليم';
  static const String noOrdersYet = 'لا يوجد طلبات بعد';
  static const String noOrdersYetSubtitle = 'ابدأ التسوّق وستظهر طلباتك هنا';
  static const String orderPlacedAt = 'وقت الطلب';
  static const String orderElapsed = 'مدة الطلب';
  static const String currentOrders = 'الطلبات الحالية';
  static const String pastOrders = 'الطلبات السابقة';
  static const String adminMessages = 'رسائل الإدارة';
  static const String tapToDismiss = 'اضغط على الرسالة لإخفائها';
  static const String orderDelayedNote = 'طلبك مؤجّل مؤقتاً، سنتواصل معك قريباً.';
  static const String orderCancelledNote =
      'نعتذر، تم إلغاء الطلب. سيتم التواصل معك خلال 24 ساعة لإعادة المبلغ المدفوع.';
  static const String days = 'يوم';
  static const String hours = 'ساعة';
  static const String minutes = 'دقيقة';

  // ==================== الولاء ====================
  static const String loyaltyPoints = 'نقاط الولاء';
  static const String loyaltyIntro = 'اجمع النقاط مع كل تفاعل واستبدلها بمنتجات من قسم الولاء';
  static const String loyaltyHowToEarn = 'كيف تربح النقاط؟';
  static const String loyaltyEarnPurchase = 'عند إتمام طلب';
  static const String loyaltyEarnRating = 'عند تقييم التطبيق (مرة واحدة)';
  static const String loyaltyEarnSuggestion = 'عند اقتراح منتج تتم إضافته';
  static const String loyaltyStore = 'قسم الولاء';
  static const String redeemPoints = 'استبدال بالنقاط';
  static const String pointsHistory = 'سجل النقاط';

  // ==================== الرياضة / Fitness ====================
  static const String fitness = 'الرياضة واللياقة';
  static const String bodyManagement = 'إدارة الجسم';
  static const String yoga = 'يوجا';
  static const String pilates = 'بيلاتس';
  static const String nutrition = 'التغذية';
  static const String weightLossMeds = 'أدوية التنحيف';
  static const String height = 'الطول';
  static const String weight = 'الوزن';
  static const String age = 'العمر';
  static const String chronicDiseases = 'الأمراض المزمنة';
  static const String hereditaryDiseases = 'الأمراض الوراثية';
  static const String contactCoach = 'تواصلي مع الكوتش';
  static const String fitnessIntro =
      'قسم مخصّص لكِ — تمارين وبرامج تُصمَّم على يد مختصين حسب حالتك.';
  static const String fitnessDisclaimer =
      'هذه المعلومات تُرسل إلى مختص بشري لمراجعتها. التطبيق لا يقدّم تشخيصاً طبياً ولا يصف علاجاً، ولا يغني عن استشارة طبيبك.';
  static const String formSubmitted = 'تم إرسال بياناتك';
  static const String formSubmittedBody =
      'استلمنا بياناتك، وسيتواصل معك المختص قريباً.';
  static const String sendData = 'إرسال البيانات';
  static const String optionalField = 'اختياري';
  static const String yes = 'نعم';
  static const String no = 'لا';
  static const String medsDisclaimer =
      'المنتجات المعروضة للاطلاع فقط. لا تبدئي أي منتج قبل استشارة طبيبك، والتواصل مع الإدارة للاستفسار عن التوفر.';
  static const String contactAdminAboutProduct = 'استفسري عن المنتج';
  static const String contactAdmin = 'تواصل مع الإدارة';
  static const String supplements = 'مستحضرات ومستلزمات';
  static const String fitnessBannerTitle = 'الرياضة واللياقة';
  static const String fitnessBannerBody = 'برامج وتغذية بإشراف مختصين';
  static const String discoverSection = 'اكتشفي القسم';
  static const String sportsEquipment = 'مستلزمات رياضية';
  static const String programSubmit = 'إرسال البيانات';
  static const String programSubmitted = 'تم استلام بياناتك';

  /// Why the health questions are asked — shown above every program form.
  static const String healthDataNotice =
      'هذه المعلومات مطلوبة من طبيب التغذية المشرف على القسم، ولا يمكن إعداد أي '
      'برنامج غذائي أو رياضي بدونها حفاظاً على سلامتك. لن يطّلع عليها سوى المختص.';

  static const String contactCoachTitle = 'تواصل مع الكوتش';
  static const String contactCoachBody =
      'تواصل مع الكوتش ليتم تخصيص برنامج خاص لك ولصحتك مصمم خصيصاً لك.';
  static const String openWhatsapp = 'فتح واتساب';

  /// Supplements are informational only — nothing here can be ordered
  /// without the specialist.
  static const String supplementsNotice =
      'تُعرض هذه المستحضرات للاطّلاع فقط، ولا يمكن طلبها إلا بعد تحديدها من المختص.';
  static const String askSpecialist = 'استشر المختص';

  static const String requiredField = 'مطلوب';


  // ==================== اقتراح منتج ====================
  static const String suggestProduct = 'أضف منتجك';
  static const String productName = 'اسم المنتج';
  static const String productLink = 'رابط المنتج';
  static const String submitSuggestion = 'إرسال الاقتراح';
  static const String suggestionThankYouApproved = 'شكراً لتعاونك، تم توفير المنتج، اطّلع عليه';
  static const String suggestionThankYouRejected =
      'شكراً لتعاونك، لكن لا نستطيع توفير المنتج حالياً. لتفاصيل أكثر تواصل مع الدعم';
  static const String suggestProductIntro =
      'لم تجد ما تبحث عنه؟ اقترح المنتج وسنراجعه ونوفّره إن أمكن.';
  static const String suggestProductHint = 'مثال: سيروم فيتامين سي';
  static const String productLinkHint = 'https://...';
  static const String suggestionSent = 'تم إرسال اقتراحك، سنراجعه قريباً';
  static const String suggestionTermsTitle = 'قبل الإرسال';

  /// بنود قسم الاقتراحات — أضف أو عدّل بحرية، الصفحة تعرضها تلقائياً.
  static const List<String> suggestionTerms = [
    'المنتج المقترح يخضع للمراجعة قبل إضافته، وقد لا نتمكن من توفيره.',
    'يجب أن يكون الرابط لصفحة المنتج مباشرة من موقع موثوق.',
    'لا يُسمح باقتراح منتجات مخالفة للقوانين أو غير مناسبة.',
    'سنعلمك بالنتيجة عبر قسم متابعة الطلب.',
  ];

  // رسائل التحقق من الرابط
  static const String linkMustBeHttps = 'يجب أن يبدأ الرابط بـ https';
  static const String invalidLink = 'الرابط غير صحيح';
  static const String linkTooLong = 'الرابط طويل جداً';
  static const String nameTooLong = 'الاسم طويل جداً';
  static const String invalidNumber = 'أدخلي رقماً صحيحاً';
  static const String valueTooSmall = 'القيمة أصغر من المسموح';
  static const String valueTooLarge = 'القيمة أكبر من المسموح';

  // ==================== الدعم / التقييم ====================
  static const String support = 'الدعم';
  static const String feedback = 'اقتراحاتكم';
  static const String sendFeedback = 'إرسال';
  static const String rateApp = 'قيّم التطبيق';
  static const String menu = 'القائمة';

  // ==================== الدعم ====================
  static const String supportIntro =
      'أخبرنا بما يشغلك — شكوى، اقتراح، أو مشكلة تقنية. نقرأ كل رسالة.';
  static const String supportTopic = 'نوع الرسالة';
  static const String topicComplaint = 'شكوى';
  static const String topicSuggestion = 'اقتراح';
  static const String topicBug = 'مشكلة تقنية';
  static const String topicOther = 'أخرى';
  static const String supportMessage = 'رسالتك';
  static const String supportMessageHint = 'اكتبي التفاصيل هنا...';
  static const String supportSend = 'إرسال';
  static const String supportSent = 'وصلتنا رسالتك، شكراً لك';
  static const String messageTooShort = 'الرسالة قصيرة جداً';

  // ==================== تقييم التطبيق ====================
  static const String rateAppIntro = 'كم تقيّمين تجربتك مع التطبيق؟';
  static const String rateAppReward = 'احصلي على نقاط ولاء مقابل تقييمك';
  static const String rateAppComment = 'ملاحظاتك (اختياري)';
  static const String rateAppSubmit = 'إرسال التقييم';
  static const String rateAppThanks = 'شكراً لتقييمك';
  static const String rateAppOnce = 'التقييم متاح مرة واحدة فقط';
  static const String selectRating = 'اختاري عدد النجوم';

  // ==================== متجر الولاء ====================
  static const String loyaltyStoreIntro = 'استبدلي نقاطك بمنتجات مختارة.';
  static const String yourPoints = 'رصيدك';
  static const String redeem = 'استبدال';
  static const String notEnoughPoints = 'نقاطك غير كافية';
  static const String redeemConfirm = 'سيتم خصم النقاط من رصيدك، هل أنت متأكدة؟';
  static const String redeemed = 'تم الاستبدال بنجاح';
  static const String alreadyRated = 'قيّمت التطبيق مسبقاً';

  // ==================== الدعم ====================
  static const String supportTypeComplaint = 'شكوى';
  static const String supportTypeSuggestion = 'اقتراح';
  static const String supportTypeBug = 'مشكلة تقنية';
  static const String supportTypeOther = 'أخرى';
  static const String supportTypeLabel = 'نوع الرسالة';
  static const String supportMessageLabel = 'رسالتك';

  // ==================== التقييم والمراجعات ====================
  static const String yourRating = 'تقييمك';
  static const String reviewOptional = 'أضيفي تعليقاً (اختياري)';
  static const String addPhoto = 'أضيفي صورة';
  static const String submitRating = 'إرسال التقييم';
  static const String ratingSubmitted = 'شكراً لتقييمك';
  static const String customerReviews = 'آراء العملاء';
  static const String noReviewsYet = 'لا توجد مراجعات بعد';

  // ==================== من نحن ====================
  // TODO(content): كل النصوص هنا مؤقتة — تُستبدل بالمحتوى الحقيقي لاحقاً.
  static const String aboutUs = 'من نحن';
  static const String aboutHeadline = 'نُقدّم لكِ الأفضل';
  static const String aboutTagline =
      'منتجات مختارة بعناية، وخدمة تليق بك — منذ اليوم الأول.';

  static const String ourMission = 'رسالتنا';
  static const String ourMissionBody =
      'أن نوفّر منتجات أصلية بجودة عالية وسعر عادل، مع تجربة تسوّق مريحة وواضحة من الطلب حتى التسليم.';

  static const String ourGoals = 'أهدافنا';
  static const String goalQuality = 'جودة مضمونة';
  static const String goalQualityBody = 'نختبر كل منتج قبل إدراجه في المتجر.';
  static const String goalPrice = 'سعر عادل';
  static const String goalPriceBody = 'أسعار واضحة بلا رسوم مخفية.';
  static const String goalDelivery = 'توصيل موثوق';
  static const String goalDeliveryBody = 'متابعة طلبك خطوة بخطوة حتى يصلك.';
  static const String goalSupport = 'دعم قريب منك';
  static const String goalSupportBody = 'فريق يجيب على أسئلتك في أي وقت.';

  static const String productsSource = 'مصدر بضائعنا';
  static const String productsSourceBody =
      'نتعامل مع موردين معتمدين ووكلاء رسميين، ونتحقق من مصدر كل شحنة قبل عرضها لك.';

  static const String contactUs = 'تواصل معنا';
  static const String contactUsBody = 'هل لديك سؤال؟ فريق الدعم جاهز لمساعدتك.';

  // ==================== الإشعارات ====================
  static const String notifications = 'الإشعارات';
  static const String noNotifications = 'لا يوجد إشعارات';
}