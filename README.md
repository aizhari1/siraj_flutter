# تطبيق سراج (Flutter) 📱

نسخة موبايل من منصة سراج التعليمية - أبيض وأزرق، أندرويد، بتتكلم مع نفس الباك ايند (NestJS) بتاع المنصة.

---

## 1) إيه اللي جاهز دلوقتي

- ✅ البنية الأساسية كاملة: تسجيل دخول/تسجيل جديد + التحقق بخطوتين (2FA)، تجديد التوكن تلقائي، تخزين آمن للجلسة
- ✅ توجيه تلقائي حسب الدور (طالب / مدرس / أدمن) لكل واحد الشاشات بتاعته
- ✅ **واجهة الطالب**: الرئيسية، تصفح الكورسات، تفاصيل الكورس، الاشتراك (مجاني أو دفع عبر WebView)، الامتحانات، الشهادات، الإشعارات، البروفايل
- ✅ **واجهة المدرس**: لوحة تحكم، كورساتي، إنشاء/تعديل كورس، إرسال للمراجعة، الطلاب
- ✅ **واجهة الأدمن**: لوحة تحكم، إدارة المستخدمين (تفعيل/تعطيل)، مراجعة الكورسات (قبول/رفض)
- ✅ الثيم بالكامل أبيض/أزرق مع خط Cairo ودعم RTL

## ⚠️ إيه اللي محتاج شغل إضافي (اختياري حسب احتياجك)
- إدارة الدروس والفيديوهات بالتفصيل داخل الكورس (رفع فيديو، ترتيب الدروس)
- عرض أسئلة الامتحان الفعلية من الـ API (الشاشة جاهزة والـ timer شغال، ناقص بس ربط الأسئلة الحقيقية)
- شاشات: المجتمع، الإنجازات، المفضلة، خطة المذاكرة، تذاكر الدعم (features إضافية في الباك ايند مش أساسية لأول نسخة)
- صفحة "نسيت كلمة السر" جاهزة بس بتعتمد على إعداد إرسال الإيميلات في الباك ايند

---

## 2) شغّل المشروع أول مرة على جهازك

الكود هنا **كل ملفات lib/ فقط** (Dart code)، من غير مجلدات android/ios لأنها لازم تتولّد بنسخة الـ Flutter SDK بتاعتك بالظبط. اعمل كده بالترتيب:

```bash
# 1. فك الضغط، وادخل المجلد
cd siraj_flutter

# 2. خلي فلاتر يولّد مجلدات android/ios (مرة واحدة بس)
flutter create . --org com.siraj --platforms=android --project-name siraj_app

# 3. نزّل المكتبات
flutter pub get

# 4. شغّله على المحاكي أو موبايلك (وصّل الموبايل بالـ USB وفعّل وضع المطور + USB debugging)
flutter run
```

> لو ظهر تعارض في pubspec.yaml بعد أمر `flutter create .`، خد نسخة pubspec.yaml اللي جوه الملف ده (هي الصح) واستبدل بيها.

## 3) وصّل التطبيق بالباك ايند بتاعك

في `lib/core/constants/api_constants.dart` الـ base URL بييجي من متغير بيئة:

```bash
# أثناء التطوير - محاكي أندرويد يشوف جهازك على 10.0.2.2
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000

# بعد رفع الباك ايند على Render (أو غيره)
flutter run --dart-define=API_BASE_URL=https://your-api.onrender.com
```

للبيلد النهائي:
```bash
flutter build apk --release --dart-define=API_BASE_URL=https://your-api.onrender.com
```

---

## 4) رفع الـ APK مجانًا عشان أي حد يجربه (Firebase App Distribution)

ده الحل المجاني المطلوب - بتاخد لينك تحمل بيه أي حد يريد تجربة التطبيق من غير Google Play.

### خطوة بخطوة:

1. روح [console.firebase.google.com](https://console.firebase.google.com) واعمل مشروع جديد مجاني (Spark plan - مجاني تمامًا).
2. جوه المشروع: **Add app → Android**، اكتب package name اللي اخترته فوق (`com.siraj.siraj_app`) - مش لازم ترفع أي ملف دلوقتي.
3. من القائمة الجانبية: **Release & Monitor → App Distribution**.
4. اعمل **Tester group** اسمه `testers` وضيف إيميلات أي حد عايزه يجرب التطبيق (مجانًا وبدون حد أقصى تقريبًا).
5. عشان ترفع أول نسخة يدوي بسرعة (قبل ما تظبط الأتمتة):
   ```bash
   flutter build apk --release
   npm install -g firebase-tools
   firebase login
   firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
     --app <FIREBASE_APP_ID> \
     --groups "testers"
   ```
   الـ `FIREBASE_APP_ID` تلاقيه في Project settings → عام → تحت الـ Android app اللي عملته.

### الأتمتة (اختياري لكن مريح جدًا)

عندك جاهز في المشروع: `.github/workflows/firebase-distribute.yml` - كل ما تعمل push على GitHub، هيبني الـ APK ويرفعه لوحده على Firebase App Distribution. محتاج تضيف الـ Secrets دي في إعدادات الريبو (Settings → Secrets and variables → Actions):

| اسم الـ Secret | القيمة |
|---|---|
| `FIREBASE_APP_ID` | من Project settings في Firebase |
| `FIREBASE_SERVICE_ACCOUNT` | ملف JSON لحساب خدمة (Service Account) من Firebase - Project settings → Service accounts → Generate new private key |
| `API_BASE_URL` | رابط الباك ايند بتاعك (مثال: `https://your-api.onrender.com`) |

بعد كده أي تحديث في الكود، push على main، والزملاء/العملاء يستلموا إشعار بنسخة جديدة يحملوها.

---

## 5) لو عايز تنشره فعليًا على Google Play بعدين

محتاج حساب Google Play Developer (25$ مرة واحدة فقط مدى الحياة، مش سنوي)، بعدها:
```bash
flutter build appbundle --release
```
وترفع ملف الـ `.aab` الناتج على [Google Play Console](https://play.google.com/console).

---

## هيكل المشروع
```
lib/
  core/            # ثيم، شبكة، تخزين، راوتر
  models/          # موديلات البيانات
  services/        # اتصال بالـ API الحقيقي (auth, courses, exams...)
  providers/        # حالة تسجيل الدخول (Riverpod)
  features/
    auth/           # تسجيل دخول، تسجيل جديد، 2FA
    student/        # واجهة الطالب
    teacher/        # واجهة المدرس
    admin/          # واجهة الأدمن
  shared/widgets/   # مكونات مشتركة (أزرار، كروت، إلخ)
```
