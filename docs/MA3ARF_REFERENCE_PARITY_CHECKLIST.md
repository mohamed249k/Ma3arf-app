# MA3ARF (معارف) — REFERENCE PARITY CHECKLIST
## Comprehensive Audit: Web Application Reference vs. Flutter Mobile Application

- **Reference Web Application:** [https://mohamed249k.github.io/Ma3arf/](https://mohamed249k.github.io/Ma3arf/)
- **Mobile Target:** Flutter Android & iOS Application
- **Developer Attribution:** فكرة وإعداد وتطوير: محمد كرم (Mohamed Karam)
- **Official WhatsApp Contact:** `01017325592` (International destination: `201017325592`)
- **Total Question Bank:** 1,000 Verified Authentic Islamic Questions
- **Audit Date:** March 2026

---

## 1. Feature-by-Feature Parity Matrix

| Feature / Section | Web Reference Status | Flutter Mobile Status | Verification Method | Parity Status |
| :--- | :--- | :--- | :--- | :---: |
| **Hero Section & Branding** | Emerald background, Gold Crescent & Dome ornament, "مَعارِف", level badge, total XP, and 3-stat strip (1000 questions, 10 categories, 4 levels) | Identical structure, vector dome art (`IslamicDomeArt`), dynamic level calculation, responsive stat boxes | Automated Widget Tests & UI inspection | **100% PARITY** |
| **Wisdom of the Day (حكمة اليوم)** | Daily rotating verified question with quick answer preview and bookmark toggle | Daily rotating question based on day-of-year hash, expand/collapse view, favorite toggle with instant storage persistence | Automated unit tests & State tests | **100% PARITY** |
| **Game Modes Selection** | Comprehensive Quiz (`مسابقة شاملة`), Learning Mode (`نمط التعلّم المفتوح`), Daily Challenge (`التحدي اليومي`), Mistake Review (`بنك الأخطاء`) | All 4 modes implemented with dedicated routing, session config, question slicing, and audio cues | Session state tests & routing verification | **100% PARITY** |
| **Category Quick Grid** | 10 categories with authentic icons, question counts, and direct selection routing | 10 categories with verified Islamic iconography (Quran, Hadith, Seerah, etc.), accurate counts, and tap handling | Data integrity & navigation tests | **100% PARITY** |
| **Bottom Navigation Bar** | 5 items: الرئيسية (Home), البحث (Search), اليومي (Daily), المفضلة (Favorites), الإحصائيات (Stats) | 5-item Bottom Navigation Bar matching screenshot layout, deep emerald background `#0F261E`, gold active highlight `#D7B56D` | `test/footer_and_whatsapp_test.dart` | **100% PARITY** |
| **Islamic Charity Footer** | Ornamental curve, Sadaqah Jariyah card, Hadith quote box, Share & Copy buttons, Developer Credits, WhatsApp pill | Recreated in `AppFooter` widget: exact Arabic texts, Hadith «الدَّالُّ عَلَى الخَيْرِ كَفَاعِلِهِ», share/copy buttons, developer credits, WhatsApp pill | `test/footer_and_whatsapp_test.dart` & `AppFooter` | **100% PARITY** |
| **WhatsApp Submissions & Feedback** | Direct submission to Mohamed Karam via `201017325592` with structured Arabic text, copy fallback, local draft saving | Full 2-tab `FeedbackDialog`: Suggest Question + Report Issue, direct WhatsApp deep link + web fallback, clipboard copy, local draft persistence | `test/footer_and_whatsapp_test.dart` & `FeedbackDialog` | **100% PARITY** |
| **Search Engine** | Real-time text search across questions, choices, explanations, filter by category and difficulty | Real-time interactive search in `SearchScreen`, chip filtering, bookmarking, and explanation modal | Widget & unit tests | **100% PARITY** |
| **Audio & Visual Feedback** | Click, correct, wrong, victory sounds, theme toggling, custom dialogs | Complete sound synthesis & asset player in `AudioFeedbackService`, dark/light themes, zero overflow on all dialogs | Sound playback & Responsive tests | **100% PARITY** |
| **Responsive Viewports** | Mobile responsive layout across viewports (320px to 430px) | Zero layout overflow verified across 6 viewports (320, 360, 375, 390, 412, 430px) | `test/responsive_viewports_test.dart` (30/30 passed) | **100% PARITY** |

---

## 2. Islamic Charity Footer & Credits Verification

- **Hadith Badge:** «الدَّالُّ عَلَى الخَيْرِ كَفَاعِلِهِ» (رواه الإمام مسلم) styled in gold text with rounded translucent badge.
- **Sadaqah Card:** «وقفٌ لله تعالى وصدقة جارية» with full dedication text.
- **Sharing Actions:**
  - Primary button: «مشاركة التطبيق واحتساب الأجر» launching system share dialog with fallback to clipboard.
  - Secondary button: «نسخ الرابط» copying `https://mohamed249k.github.io/Ma3arf/` to clipboard with visual confirmation.
- **Developer Credits:**
  - Text: «فكرة وإعداد وتطوير: » + **«محمد كرم (Mohamed Karam)»** in gold typography.
  - WhatsApp Pill: Green pill with WhatsApp icon, `واتساب: 01017325592`, launching WhatsApp chat directly to `201017325592`.
  - Closing Statement: «— صدقة جارية ومتاح لكل مسلم ومسلمة للنشر والتعلم».
  - Copyright: «منصة معارف | Ma3arf © 2026 — تقبل الله منا ومنكم صالح الأعمال».

---

## 3. WhatsApp Integration Verification

- **Target Phone Number:** `201017325592` (Egypt E.164 standard), displayed locally as `01017325592`.
- **Suggestion Template Format:**
  - Greeting to "أستاذ محمد كرم"
  - Formatted question text with emoji bullet
  - Numbered options (1️⃣, 2️⃣, 3️⃣, 4️⃣)
  - Distinct correct answer indication
  - Category and difficulty level
  - Religious explanation and source citation
  - Closing attribution: «— أُرسل عبر منصة مَعارِف للتعليم الإسلامي (صدقة جارية)»
- **Issue Report Template Format:**
  - Greeting to "أستاذ محمد كرم"
  - Issue category (خطأ في الإجابة، صياغة السؤال، خطأ لغوي، نقص التوثيق...)
  - Target question reference / ID
  - Detailed description and proposed correction
  - Closing attribution
- **Action Buttons Provided:**
  1. Primary WhatsApp Button: Direct launch via `whatsapp://send` and `https://api.whatsapp.com/send`.
  2. Copy to Clipboard Button: Copies complete Arabic formatted message for manual sharing.
  3. Save Local Draft Button: Saves to `SharedPreferences` for offline continuity.

---

## 4. UI/UX & Responsive Layout Audit

- **Zero Overflows:** Tested on 320x640, 360x640, 375x667, 390x844, 412x915, and 430x932. All views pass with 0 pixel overflow.
- **Button Sizing & Padding:**
  - All interactive buttons have minimum height of 44dp–48dp.
  - Text has ample vertical and horizontal padding, preventing clipping or border collisions.
  - Removed stray emoji symbols from action buttons, standardizing on Phosphor Duotone and FontAwesome Islamic vectors.
- **Typography:** Fully RTL configured with Google Cairo/Tajawal font fallback, clear hierarchy, high contrast against deep emerald background `#0B1B15` and `#0F261E`.

---

## 5. Automated Test Suite Summary

- Total Automated Tests: **61 Tests**
- Test Results: **61 PASSED, 0 FAILED, 0 SKIPPED**
- Test Coverage:
  1. `question_bank_integrity_test.dart` (1,000 questions verified, distinct IDs, valid choices)
  2. `responsive_viewports_test.dart` (30 viewport tests across 6 phone form factors)
  3. `footer_and_whatsapp_test.dart` (Islamic footer, 5-tab navigation bar, WhatsApp integration)
  4. `game_state_test.dart` (Profile, XP, streaks, level progression, bookmarks)
  5. `game_config_test.dart` (Categories, difficulty levels, scoring rules)
  6. `icon_test.dart` (Phosphor duotone and Islamic icons rendering)
  7. `widget_test.dart` (App smoke test & landing screen)
