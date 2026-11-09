# -*- coding: utf-8 -*-
"""
Ma3arf - Apply fixes for the 19 identified questions to ensure 100% uniqueness and 0 duplicates.
"""

import sys
import os

# Updates for Batch 1
updates_b1 = {
    807: {
        'id': 807,
        'category': 'القرآن الكريم',
        'difficulty': 'medium',
        'question': 'ما هي السورة القرآنية التي افتتحت بقوله تعالى: {سَبَّحَ لِلَّهِ مَا فِي السَّمَاوَاتِ وَالْأَرْضِ} وهي أولى المسبحات بالمصحف؟',
        'choices': ['سورة الحديد', 'سورة الحشر', 'سورة الصف', 'سورة الجمعة'],
        'correct': 0,
        'explanation': 'سورة الحديد هي أولى سور المسبحات في ترتيب المصحف الشريف، وافتتحت بـ {سَبَّحَ لِلَّهِ مَا فِي السَّمَاوَاتِ وَالْأَرْضِ وَهُوَ الْعَزِيزُ الْحَكِيمُ}.',
        'source': 'القرآن الكريم - سورة الحديد: آية 1',
        'sourceType': 'quran',
        'sourceReference': 'الحديد: 1',
        'isVerified': True,
        'reviewStatus': 'verified'
    },
    809: {
        'id': 809,
        'category': 'القرآن الكريم',
        'difficulty': 'easy',
        'question': 'كم حزباً قُسّم إليه القرآن الكريم كاملاً في تقسيم المصاحف المعتمد للتلاوة والورد؟',
        'choices': ['ثلاثون حزباً', 'ستون حزباً', 'أربعون حزباً', 'ثمانون حزباً'],
        'correct': 1,
        'explanation': 'قُسّم القرآن الكريم إلى ثلاثين جزءاً، وكل جزء يشتمل على حزبين اثنين، فمجموع أحزاب المصحف الشريف ستون حزباً تيسيراً للتلاوة والختم.',
        'source': 'مباحث في علوم القرآن لمناع القطان (ص 147)',
        'sourceType': 'quran',
        'sourceReference': 'مباحث علوم القرآن: ص 147',
        'isVerified': True,
        'reviewStatus': 'verified'
    },
    814: {
        'id': 814,
        'category': 'القرآن الكريم',
        'difficulty': 'medium',
        'question': 'ما هي السورة الكريمة التي خُتمت بذكر اسم نبيين جليلين هما إبراهيم وموسى عليهما السلام؟',
        'choices': ['سورة النجم', 'سورة الأعلى', 'سورة الغاشية', 'سورة القيامة'],
        'correct': 1,
        'explanation': 'خُتمت سورة الأعلى بقوله تعالى: {إِنَّ هَٰذَا لَفِي الصُّحُفِ الْأُولَىٰ * صُحُفِ إِبْرَاهِيمَ وَمُوسَىٰ}.',
        'source': 'القرآن الكريم - سورة الأعلى: الآيات 18-19',
        'sourceType': 'quran',
        'sourceReference': 'الأعلى: 18-19',
        'isVerified': True,
        'reviewStatus': 'verified'
    },
    815: {
        'id': 815,
        'category': 'القرآن الكريم',
        'difficulty': 'hard',
        'question': 'ما هي السورة القرآنية الوحيدة التي اشتملت كل آية من آياتها على اسم الجلالة «الله»؟',
        'choices': ['سورة الحشر', 'سورة المجادلة', 'سورة الفتح', 'سورة الطلاق'],
        'correct': 1,
        'explanation': 'سورة المجادلة (22 آية) تتميز بخصيصة فريدة وهي أن لفظ الجلالة «الله» ورد في كل آية من آياتها بلا استثناء.',
        'source': 'الإتقان في علوم القرآن للسيوطي (2/385)',
        'sourceType': 'quran',
        'sourceReference': 'الإتقان: 2/385',
        'isVerified': True,
        'reviewStatus': 'verified'
    },
    817: {
        'id': 817,
        'category': 'القرآن الكريم',
        'difficulty': 'medium',
        'question': 'ما هي السورة الوجيزة التي قال عنها الإمام الشافعي: «لو تدبر الناس هذه السورة لكفتهم»؟',
        'choices': ['سورة الكوثر', 'سورة العصر', 'سورة الإخلاص', 'سورة الفلق'],
        'correct': 1,
        'explanation': 'قال الإمام الشافعي رحمه الله في فضل سورة العصر: لو ما أنزل الله على خلقه حجة إلا هذه السورة لكفتهم، لاشتمالها على أركان الفلاح والنجاة.',
        'source': 'تفسير ابن كثير - تفسير سورة العصر (8/478)',
        'sourceType': 'quran',
        'sourceReference': 'ابن كثير: 8/478',
        'isVerified': True,
        'reviewStatus': 'verified'
    },
    835: {
        'id': 835,
        'category': 'السيرة النبوية',
        'difficulty': 'medium',
        'question': 'ما هي الصحيفة التاريخية التي أملاها النبي ﷺ لتنظيم العلاقة بين المهاجرين والأنصار واليهود في يثرب؟',
        'choices': ['صلح الحديبية', 'وثيقة المدينة المنورة', 'بيعة الرضوان', 'حلف المطيبين'],
        'correct': 1,
        'explanation': 'كتب النبي ﷺ كتاباً بين المهاجرين والأنصار وادع فيه يهود وعاهدهم وأقرهم على دينهم وأموالهم، عُرف تاريخياً بـ «وثيقة المدينة» كأول دستور مدني.',
        'source': 'السيرة النبوية لابن هشام (1/501)',
        'sourceType': 'sirah',
        'sourceReference': 'ابن هشام: 1/501',
        'isVerified': True,
        'reviewStatus': 'verified'
    },
    839: {
        'id': 839,
        'category': 'السيرة النبوية',
        'difficulty': 'medium',
        'question': 'ما هي الحادثة الإعجازية التي وقعت للنبي ﷺ في طفولته وهو في بادية بني سعد عند مرضعته؟',
        'choices': ['الإسراء والمعراج', 'حادثة شق الصدر الشريف وغسل قلبه', 'نزول الوحي بغار حراء', 'انشقاق القمر بمكة'],
        'correct': 1,
        'explanation': 'أتى جبريل عليه السلام رسول الله ﷺ وهو يلعب مع الصبيان عند حليمة السعدية فأخذه فصرعه فشق عن قلبه واستخرج حظ الشيطان وغسله بماء زمزم في طست من ذهب.',
        'source': 'صحيح مسلم - كتاب الإيمان: حديث رقم 162',
        'sourceType': 'hadith',
        'sourceReference': 'مسلم: 162',
        'isVerified': True,
        'reviewStatus': 'verified'
    }
}

# Updates for Batch 2
updates_b2 = {
    852: {
        'id': 852,
        'category': 'قصص الأنبياء',
        'difficulty': 'easy',
        'question': 'ما هي الآية الإلهية والمعجزة الخارقة التي أخرجها الله لقوم ثمود استجابة لطلبهم من نبيهم صالح عليه السلام؟',
        'choices': ['العصا واليد البيضاء', 'الناقة العظيمة من الصخرة', 'الطوفان الجارف', 'إحياء الميت'],
        'correct': 1,
        'explanation': 'أخرج الله تعالى لنبيه صالح ناقة عظيمة وفصيلها من الصخرة الصماء آية مبصرة لقومه ثمود، قال تعالى: {وَآتَيْنَا ثَمُودَ النَّاقَةَ مُبْصِرَةً فَظَلَمُوا بِهَا}.',
        'source': 'القرآن الكريم - سورة الإسراء: آية 59، وتفسير ابن كثير',
        'sourceType': 'quran',
        'sourceReference': 'الإسراء: 59',
        'isVerified': True,
        'reviewStatus': 'verified'
    },
    865: {
        'id': 865,
        'category': 'قصص الأنبياء',
        'difficulty': 'medium',
        'question': 'من هو النبي الصالح الذي ابتلاه الله بالضر والمرض وفقد الأهل والمال فصبر صبراً جميلاً حتى كشف الله ضره؟',
        'choices': ['نبي الله يونس عليه السلام', 'نبي الله أيوب عليه السلام', 'نبي الله يعقوب عليه السلام', 'نبي الله زكريا عليه السلام'],
        'correct': 1,
        'explanation': 'ضرب نبي الله أيوب عليه السلام أروع الأمثلة في الصبر وحسن اللجوء لربه، قال تعالى: {إِنَّا وَجَدْنَاهُ صَابِرًا نِّعْمَ الْعَبْدُ إِنَّهُ أَوَّابٌ}.',
        'source': 'القرآن الكريم - سورة ص: آية 44',
        'sourceType': 'quran',
        'sourceReference': 'ص: 44',
        'isVerified': True,
        'reviewStatus': 'verified'
    },
    869: {
        'id': 869,
        'category': 'قصص الأنبياء',
        'difficulty': 'medium',
        'question': 'من هو النبي الملك الذي أسال الله له عين القِطْر (النحاس المذاب) وسخر له الجن يعملون بين يديه؟',
        'choices': ['نبي الله داود عليه السلام', 'نبي الله سليمان عليه السلام', 'نبي الله يوسف عليه السلام', 'نبي الله ذو الكفل عليه السلام'],
        'correct': 1,
        'explanation': 'قال تعالى عن سليمان عليه السلام: {وَأَسَلْنَا لَهُ عَيْنَ الْقِطْرِ وَمِنَ الْجِنِّ مَن يَعْمَلُ بَيْنَ يَدَيْهِ بِإِذْنِ رَبِّهِ}.',
        'source': 'القرآن الكريم - سورة سبأ: آية 12',
        'sourceType': 'quran',
        'sourceReference': 'سبأ: 12',
        'isVerified': True,
        'reviewStatus': 'verified'
    },
    880: {
        'id': 880,
        'category': 'الحديث الشريف',
        'difficulty': 'easy',
        'question': 'ما هو السفر الحديثي الضخم الذي ألفه الإمام أحمد بن حنبل مرتباً على مسانيد الصحابة؟',
        'choices': ['صحيح ابن خزيمة', 'مسند الإمام أحمد بن حنبل', 'سنن الدارمي', 'معجم الطبراني الكبير'],
        'correct': 1,
        'explanation': 'مسند الإمام أحمد بن حنبل من أكبر وأوسع دواوين السنة، جمع فيه ما يقارب ثلاثين ألف حديث مرتبة على مسانيد الصحابة رضي الله عنهم.',
        'source': 'خصائص المسند للحافظ أبي موسى المديني (ص 21)',
        'sourceType': 'hadith',
        'sourceReference': 'خصائص المسند: 21',
        'isVerified': True,
        'reviewStatus': 'verified'
    },
    881: {
        'id': 881,
        'category': 'الحديث الشريف',
        'difficulty': 'medium',
        'question': 'ما هو المصطلح الحديثي للحديث الذي ينفرد بروايته شخص واحد فقط في طبقة من طبقات السند؟',
        'choices': ['الحديث المشهور', 'الحديث الغريب (الفرد)', 'الحديث العزيز', 'الحديث المتواتر'],
        'correct': 1,
        'explanation': 'الحديث الغريب في مصطلح أهل الحديث هو ما ينفرد بروايته راوٍ واحد فقط في أي طبقة من طبقات سنده.',
        'source': 'نخبة الفكر في مصطلح أهل الأثر لابن حجر (ص 34)',
        'sourceType': 'hadith',
        'sourceReference': 'نخبة الفكر: 34',
        'isVerified': True,
        'reviewStatus': 'verified'
    },
    883: {
        'id': 883,
        'category': 'الحديث الشريف',
        'difficulty': 'medium',
        'question': 'ما هو نوع الحديث المنقطع الذي يسقط من وسط إسناده راويان اثنان فأكثر على التوالي؟',
        'choices': ['الحديث المعلق', 'الحديث المعضل', 'الحديث المرسل', 'الحديث المدلس'],
        'correct': 1,
        'explanation': 'الحديث المعضل في اصطلاح أهل الحديث هو ما سقط من إسناده راويان متتاليان فأكثر، وهو من أقسام الحديث الضعيف المنقطع.',
        'source': 'تيسير مصطلح الحديث لمحمود الطحان (ص 88)',
        'sourceType': 'hadith',
        'sourceReference': 'تيسير مصطلح الحديث: 88',
        'isVerified': True,
        'reviewStatus': 'verified'
    },
    899: {
        'id': 899,
        'category': 'الحديث الشريف',
        'difficulty': 'medium',
        'question': 'كم تزيد صلاة الجماعة في المسجد على صلاة الرجل منفرداً في بيته وسوقه فضلاً وثواباً بنص الحديث المتفق عليه؟',
        'choices': ['بعشر درجات', 'بسبع وعشرين درجة', 'بخمسين درجة', 'بمائة درجة'],
        'correct': 1,
        'explanation': 'قال رسول الله ﷺ: «صلاةُ الجماعةِ تفضلُ صلاةَ الفَذِّ بسبعٍ وعشرينَ درجةً»، متفق عليه من حديث عبد الله بن عمر رضي الله عنهما.',
        'source': 'صحيح البخاري - كتاب الأذان: حديث رقم 645',
        'sourceType': 'hadith',
        'sourceReference': 'البخاري: 645',
        'isVerified': True,
        'reviewStatus': 'verified'
    }
}

# Updates for Batch 3
updates_b3 = {
    907: {
        'id': 907,
        'category': 'الفقه',
        'difficulty': 'easy',
        'question': 'ما الذي يُشرع للمصلي قراءته سراً عقب التكبيرة الأولى مباشرة في صلاة الجنازة على الميت؟',
        'choices': ['قراءة سورة الفاتحة', 'الصلاة الإبراهيمية', 'الدعاء للميت بالمغفرة', 'دعاء الاستفتاح الطويل'],
        'correct': 0,
        'explanation': 'السنة الثابتة في صلاة الجنازة أن يقرأ المصلي بعد التكبيرة الأولى سورة الفاتحة سراً، كما روى عبد الله بن عباس رضي الله عنهما في صحيح البخاري.',
        'source': 'صحيح البخاري - كتاب الجنائز: حديث رقم 1335',
        'sourceType': 'hadith',
        'sourceReference': 'البخاري: 1335',
        'isVerified': True,
        'reviewStatus': 'verified'
    },
    929: {
        'id': 929,
        'category': 'العقيدة',
        'difficulty': 'easy',
        'question': 'من هو الملك الكريم الموكل بإنزال المطر وتصريف السحاب ونبات الأرض بأمر الله تعالى؟',
        'choices': ['جبريل عليه السلام', 'ميكائيل عليه السلام', 'إسرافيل عليه السلام', 'مالك خازن النار'],
        'correct': 1,
        'explanation': 'ميكائيل عليه السلام هو الملك الكريم الموكل بالقطر والمطر والنبات وتدبير الأرزاق الحياتية بإذن الله سبحانه وتعالى.',
        'source': 'البداية والنهاية لابن كثير (1/50) - فصل في الملائكة',
        'sourceType': 'aqeedah',
        'sourceReference': 'البداية والنهاية: 1/50',
        'isVerified': True,
        'reviewStatus': 'verified'
    }
}

# Updates for Batch 4
updates_b4 = {
    960: {
        'id': 960,
        'category': 'معلومات إسلامية عامة',
        'difficulty': 'medium',
        'question': 'من هو الرحالة المسلم الرائد الملقب بـ«أمير الرحالين» ومؤلف كتاب «تحفة النظار في غرائب الأمصار»؟',
        'choices': ['ابن جبير الأندلسي', 'ابن بطوطة الطنجي', 'المسعودي', 'ياقوت الحموي'],
        'correct': 1,
        'explanation': 'أبو عبد الله محمد بن بطوطة الطنجي طاف أصقاع العالم الإسلامي والهند والصين لثلاثين عاماً ودون مشاهداته في رحلته الشهيرة عالمياً.',
        'source': 'تحفة النظار في غرائب الأمصار وعجائب الأسفار لابن بطوطة',
        'sourceType': 'history',
        'sourceReference': 'تحفة النظار: المقدمة',
        'isVerified': True,
        'reviewStatus': 'verified'
    },
    976: {
        'id': 976,
        'category': 'الأخلاق الإسلامية',
        'difficulty': 'easy',
        'question': 'ما هو الخلق القرآني العظيم الذي يقابل الغدر ونكث العهود والمواثيق مع الله والناس؟',
        'choices': ['الوفاء بالعهد', 'الغل والحقد', 'الافتخار والخيلاء', 'المداهنة والرياء'],
        'correct': 0,
        'explanation': 'الوفاء بالعهد من أسمى خلال الإيمان، قال تعالى: {وَأَوْفُوا بِالْعَهْدِ إِنَّ الْعَهْدَ كَانَ مَسْئُولًا}.',
        'source': 'القرآن الكريم - سورة الإسراء: آية 34',
        'sourceType': 'quran',
        'sourceReference': 'الإسراء: 34',
        'isVerified': True,
        'reviewStatus': 'verified'
    },
    981: {
        'id': 981,
        'category': 'الأخلاق الإسلامية',
        'difficulty': 'easy',
        'question': 'ما هو الجزاء الأخروي النبوي العظيم لمن يستر عورات أخيه المسلم وعيوبه ولا يشيعها؟',
        'choices': ['يُعاقب بالحرمان', '«مَن سَتَرَ مُسْلِماً سَتَرَهُ اللَّهُ في الدُّنْيَا وَالآخِرَةِ»', 'لا ثواب له في الآخرة', 'يُلام على سكوته'],
        'correct': 1,
        'explanation': 'قال رسول الله ﷺ: «ومَن سَتَرَ مُسْلِماً سَتَرَهُ اللَّهُ في الدُّنْيَا وَالآخِرَةِ، وَاللَّهُ فِي عَوْنِ العَبْدِ مَا كَانَ العَبْدُ فِي عَوْنِ أَخِيهِ».',
        'source': 'صحيح مسلم - كتاب الذكر والدعاء والتوبة: حديث رقم 2699',
        'sourceType': 'hadith',
        'sourceReference': 'مسلم: 2699',
        'isVerified': True,
        'reviewStatus': 'verified'
    }
}

def update_file(filename, updates):
    path = os.path.join('tools', filename)
    with open(path, 'r', encoding='utf-8') as f:
        code = f.read()
    
    # We load module dynamically to find list
    import importlib.util
    spec = importlib.util.spec_from_file_location("mod", path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    
    # Batch variable name
    var_name = [v for v in dir(mod) if v.startswith('BATCH_')][0]
    data = getattr(mod, var_name)
    
    for item in data:
        if item['id'] in updates:
            item.update(updates[item['id']])
            
    # Serialize data back cleanly
    import pprint
    # Write custom python code
    header = f'# -*- coding: utf-8 -*-\n"""\nMa3arf - Phase 4: {var_name}\n"""\n\n{var_name} = [\n'
    entries = []
    for q in data:
        q_code = "    {\n"
        for k in ['id', 'category', 'difficulty', 'question', 'choices', 'correct', 'explanation', 'source', 'sourceType', 'sourceReference', 'isVerified', 'reviewStatus']:
            val = q[k]
            if isinstance(val, str):
                escaped = val.replace('\\', '\\\\').replace("'", "\\'")
                q_code += f"        '{k}': '{escaped}',\n"
            elif isinstance(val, list):
                escaped_items = ", ".join([f"'{c.replace('\\', '\\\\').replace('\'', '\\\'')}'" for c in val])
                q_code += f"        '{k}': [{escaped_items}],\n"
            elif isinstance(val, bool):
                q_code += f"        '{k}': {str(val)},\n"
            elif isinstance(val, int):
                q_code += f"        '{k}': {val},\n"
        q_code += "    }"
        entries.append(q_code)
    
    footer = "\n]\n"
    full_content = header + ",\n".join(entries) + footer
    with open(path, 'w', encoding='utf-8') as f:
        f.write(full_content)
    print(f"Updated {filename} successfully.")

if __name__ == '__main__':
    update_file('questions_batch1.py', updates_b1)
    update_file('questions_batch2.py', updates_b2)
    update_file('questions_batch3.py', updates_b3)
    update_file('questions_batch4.py', updates_b4)
