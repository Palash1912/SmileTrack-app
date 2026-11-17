// ─────────────────────────────────────────────────────────────────────────────
//  dental_tip_model.dart
//
//  Data models and static content for the Dental Tips feature.
//
//  Contains:
//    • AgeGroupTip       — model for age-based oral care tips
//    • FoodTip           — model for food impact on dental health
//    • BrushingTechnique — model for step-by-step brushing guides
//    • FaqItem           — model for FAQ question/answer pairs
//    • DentalTipsData    — static data class holding all content lists
// ─────────────────────────────────────────────────────────────────────────────

// ══════════════════════════════════════════════════════════════════════════════
//  MODEL CLASSES
// ══════════════════════════════════════════════════════════════════════════════

/// Represents oral care advice for a specific age group.
class AgeGroupTip {
  final String ageGroup;
  final String ageRange;
  final String emoji;
  final String imageUrl;
  final List<String> careTips;
  final List<String> gumCareTips;

  const AgeGroupTip({
    required this.ageGroup,
    required this.ageRange,
    required this.emoji,
    required this.imageUrl,
    required this.careTips,
    required this.gumCareTips,
  });
}

/// Represents a food item and its impact on dental health.
class FoodTip {
  final String name;
  final String emoji;
  final String imageUrl;
  final String afterCare;
  final List<String> reasons;

  const FoodTip({
    required this.name,
    required this.emoji,
    required this.imageUrl,
    required this.afterCare,
    required this.reasons,
  });
}

/// Represents a brushing technique for a specific tooth area.
class BrushingTechnique {
  final String title;
  final String area;
  final String emoji;
  final String imageUrl;
  final int durationSeconds;
  final List<String> steps;

  const BrushingTechnique({
    required this.title,
    required this.area,
    required this.emoji,
    required this.imageUrl,
    required this.durationSeconds,
    required this.steps,
  });
}

/// Represents a single FAQ question and its detailed answer.
class FaqItem {
  final String question;
  final String answer;

  const FaqItem({
    required this.question,
    required this.answer,
  });
}

// ══════════════════════════════════════════════════════════════════════════════
//  STATIC DATA
// ══════════════════════════════════════════════════════════════════════════════

/// All static dental tips content used across the Dental Tips feature tabs.
class DentalTipsData {
  DentalTipsData._(); // prevent instantiation

  // ── Age Group Tips ─────────────────────────────────────────────────────────

  static const List<AgeGroupTip> ageGroups = [
    AgeGroupTip(
      ageGroup: 'Infants',
      ageRange: '0–1 year',
      emoji: '👶',
      imageUrl:
          'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400',
      careTips: [
        'Wipe gums with a damp soft cloth after every feeding.',
        'Use a rice-grain-sized amount of fluoride toothpaste once the first tooth appears.',
        'Never put baby to bed with a bottle — causes "baby bottle tooth decay".',
        'Schedule the first dentist visit by age 1 or within 6 months of first tooth eruption.',
      ],
      gumCareTips: [
        'Massage gums gently with a clean damp gauze pad to stimulate healthy development.',
        'Avoid sharing spoons or pacifiers — this transfers cavity-causing bacteria from adults.',
        'Chilled (not frozen) teething rings provide safe gum relief during teething.',
      ],
    ),
    AgeGroupTip(
      ageGroup: 'Toddlers',
      ageRange: '1–3 years',
      emoji: '🧒',
      imageUrl:
          'https://images.unsplash.com/photo-1516627145497-ae6968895b74?w=400',
      careTips: [
        'Brush twice daily using a soft-bristled infant toothbrush.',
        'Use a rice-grain smear of fluoride toothpaste (up to age 3).',
        'Supervise brushing — children cannot brush effectively on their own before age 6.',
        'Limit sugary drinks and snacks between meals.',
      ],
      gumCareTips: [
        'Gums should look pink and firm — red or swollen gums warrant a dentist visit.',
        'Begin flossing as soon as two teeth touch each other.',
        'Model good oral hygiene — children learn by watching parents brush.',
      ],
    ),
    AgeGroupTip(
      ageGroup: 'Children',
      ageRange: '4–11 years',
      emoji: '🧒‍♀️',
      imageUrl:
          'https://images.unsplash.com/photo-1490820374496-b2d63c3dc170?w=400',
      careTips: [
        'Use a pea-sized amount of fluoride toothpaste.',
        'Brush at least 2 full minutes twice daily — use a timer or electric toothbrush.',
        'Dental sealants on permanent molars reduce cavity risk by up to 80%.',
        'Fluoride varnish application by dentist every 6 months is recommended.',
        'Wear mouthguards during contact sports to prevent dental injuries.',
      ],
      gumCareTips: [
        'Floss daily — over 70% of cavities in children form between teeth.',
        'Gum bleeding during brushing may indicate gingivitis — consult a dentist.',
        'Visit the dentist every 6 months for professional cleaning and x-rays.',
      ],
    ),
    AgeGroupTip(
      ageGroup: 'Teens',
      ageRange: '12–17 years',
      emoji: '🧑',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
      careTips: [
        'Hormonal changes increase gum sensitivity — maintain strict oral hygiene.',
        'If wearing braces, use orthodontic-specific brushes and floss threaders.',
        'Avoid tobacco and vaping — they cause gum disease, bad breath, and oral cancer.',
        'Sports drinks are highly acidic; rinse with water immediately after consuming.',
        'Wisdom teeth monitoring with regular x-rays is important from age 17.',
      ],
      gumCareTips: [
        '"Puberty gingivitis" is common — red, swollen gums — reversible with good hygiene.',
        'Electric toothbrushes are proven to remove 21% more plaque than manual brushes.',
        'Use antibacterial mouthwash if gum inflammation is present.',
      ],
    ),
    AgeGroupTip(
      ageGroup: 'Adults',
      ageRange: '18–59 years',
      emoji: '🧑‍💼',
      imageUrl:
          'https://images.unsplash.com/photo-1558642452-9d2a7deb7f62?w=400',
      careTips: [
        'Brush twice daily and floss once daily — non-negotiable for long-term dental health.',
        'Replace toothbrush every 3 months or after illness.',
        'Dental checkups every 6 months catch problems early and save significant cost.',
        'Stress leads to teeth grinding (bruxism) — a night guard protects enamel.',
        'Dry mouth (often medication-related) dramatically increases cavity risk; stay hydrated.',
      ],
      gumCareTips: [
        'Periodontitis (advanced gum disease) is linked to heart disease, diabetes, and stroke.',
        'If gums bleed daily, it is not normal — schedule a periodontal evaluation.',
        'Use an interdental brush or water flosser if traditional floss is difficult.',
        'Dental care is safe and essential during pregnancy.',
      ],
    ),
    AgeGroupTip(
      ageGroup: 'Seniors',
      ageRange: '60+ years',
      emoji: '🧓',
      imageUrl:
          'https://images.unsplash.com/photo-1581579438747-1dc8d17bbce4?w=400',
      careTips: [
        'Dry mouth from medications is the #1 dental challenge for seniors.',
        'Use a soft-bristled brush and fluoride toothpaste — enamel thins with age.',
        'Exposed root surfaces from gum recession are highly susceptible to cavities.',
        'If wearing dentures, clean daily and remove at night to prevent infections.',
        'Annual oral cancer screening is critical — risk increases sharply after age 60.',
      ],
      gumCareTips: [
        'Bone loss in the jaw is normal with age; implants may require bone grafting.',
        'Use a fluoride mouth rinse to protect exposed root surfaces.',
        'Electric toothbrushes with pressure sensors are ideal for arthritic hands.',
        'Even fully edentulous patients need annual oral exams for soft tissue health.',
      ],
    ),
  ];

  // ── Damaging Foods ─────────────────────────────────────────────────────────

  static const List<FoodTip> damagingFoods = [
    FoodTip(
      name: 'Sugary Sodas & Energy Drinks',
      emoji: '🥤',
      imageUrl:
          'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=400',
      reasons: [
        'pH as low as 2.3 — directly dissolves enamel on contact (dental erosion).',
        'Sugar feeds Streptococcus mutans bacteria, which produce acids causing cavities.',
        'Carbonation itself weakens enamel regardless of sugar content.',
      ],
      afterCare:
          'Rinse immediately with water. Wait 30 minutes before brushing — acid softens enamel and brushing too soon causes abrasion.',
    ),
    FoodTip(
      name: 'Sticky Candies & Gummies',
      emoji: '🍬',
      imageUrl:
          'https://images.unsplash.com/photo-1628191013085-990d39ec90b6?w=400',
      reasons: [
        'Adhere to tooth surfaces and grooves for hours, providing prolonged acid exposure.',
        'Even "fruit" gummies are equally damaging — concentrated fructose.',
        'Chewy candies can dislodge dental fillings and crowns.',
      ],
      afterCare:
          'Brush within 30 minutes. Floss specifically between teeth where candy lodged.',
    ),
    FoodTip(
      name: 'Citrus Fruits & Juices',
      emoji: '🍋',
      imageUrl:
          'https://images.unsplash.com/photo-1587438096043-6d04a4e3fb8d?w=400',
      reasons: [
        'Lemon juice has pH 2.0 — highly acidic, erodes enamel directly on contact.',
        'Directly applied citric acid erodes enamel faster than sodas.',
        'Vitamin C is essential for gum health — the acid must be neutralized afterward.',
      ],
      afterCare:
          'Drink through a straw to minimize contact. Rinse with water, wait 45 minutes before brushing.',
    ),
    FoodTip(
      name: 'White Bread & Refined Starches',
      emoji: '🍞',
      imageUrl:
          'https://images.unsplash.com/photo-1549931319-a545dcf3bc7b?w=400',
      reasons: [
        'Amylase in saliva rapidly converts refined starch to sugar within seconds of chewing.',
        'Starchy residue fills tooth crevices and acts identically to sugar for cavity-causing bacteria.',
        'Bread causes more cavities than chocolate in many peer-reviewed studies.',
      ],
      afterCare: 'Rinse with water after eating. Brush within an hour.',
    ),
    FoodTip(
      name: 'Alcohol',
      emoji: '🍷',
      imageUrl:
          'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?w=400',
      reasons: [
        'Causes severe dry mouth — saliva is your primary natural defense against cavities.',
        'Wine erodes enamel; tannins also damage gums and cause staining.',
        'Chronic alcohol use is a major risk factor for oral cancer.',
      ],
      afterCare:
          'Drink water alongside alcohol. Use fluoride mouthwash before bed. Never skip brushing.',
    ),
  ];

  // ── Avoid Lists ────────────────────────────────────────────────────────────

  static const List<String> avoidBeforeMorningBrush = [
    '🍊 Citrus juices — highly acidic; brush first, then eat',
    '☕ Coffee — wait until after brushing to prevent staining',
    '🍌 Bananas — high sugar activates bacteria on unbrushed teeth',
    '🥛 Milk — lactose feeds oral bacteria on unbrushed teeth',
    '🧃 Fruit juices — high sugar concentration even in "natural" varieties',
  ];

  static const List<String> avoidBeforeEveningBrush = [
    '🍫 Chocolate or sweets — sugar remains active overnight',
    '🍕 Pizza / starchy snacks — get lodged in crevices and ferment overnight',
    '🍷 Wine — erodes enamel; neutralize before sleep',
    '🍪 Crackers — refined starch converts to sugar rapidly',
    '🥜 Peanut butter — highly sticky, adheres to tooth surfaces',
  ];

  static const List<String> strongTeethFoods = [
    '🧀 Cheese — raises oral pH, provides calcium and phosphate to remineralize enamel',
    '🥛 Dairy (yogurt, milk) — casein proteins and calcium strengthen tooth structure',
    '🥦 Leafy greens — folate, calcium, and magnesium support gum health',
    '🐟 Fatty fish (salmon, sardines) — vitamin D boosts calcium absorption for teeth',
    '🥚 Eggs — vitamin D and phosphorus essential for enamel mineralization',
    '🌰 Almonds — high calcium and protein with very low sugar',
    '🥕 Crunchy vegetables (carrots, celery) — mechanical cleaning action + saliva stimulation',
    '🍵 Green tea — polyphenols suppress bacteria that cause cavities and bad breath',
    '💧 Fluoridated water — rinses acids, hydrates, and fluoride remineralizes enamel',
  ];

  static const List<String> afterBrushingAvoid = [
    '🍽 Eating anything for 30 minutes — disrupts fluoride absorption into enamel',
    '☕ Coffee or tea — immediately stains freshly cleaned enamel',
    '🍊 Acidic foods — attack the temporarily softened enamel post-brushing',
    '🧴 Rinsing with water immediately — washes away the protective fluoride film',
  ];

  // ── Brushing Techniques ────────────────────────────────────────────────────

  static const List<BrushingTechnique> techniques = [
    BrushingTechnique(
      title: 'Upper Front Teeth',
      area: 'Upper Incisors & Canines',
      emoji: '😁',
      imageUrl:
          'https://images.unsplash.com/photo-1607613009820-a29f7bb81c04?w=400',
      durationSeconds: 30,
      steps: [
        'Place bristles at a 45° angle toward the gum line.',
        'Use gentle circular or short back-and-forth strokes — never scrub aggressively.',
        'Cover outer (lip-facing), inner, and biting edge surfaces.',
        'Apply gentle pressure — you should feel the gums but not experience pain.',
        'Spend a full 30 seconds on upper front teeth alone.',
      ],
    ),
    BrushingTechnique(
      title: 'Lower Front Teeth',
      area: 'Lower Incisors & Canines',
      emoji: '🦷',
      imageUrl:
          'https://images.unsplash.com/photo-1588776814546-1ffbb5d21da7?w=400',
      durationSeconds: 30,
      steps: [
        'Tilt the brush vertically for the narrow inner lower front surfaces.',
        'Use up-and-down strokes with the toe of the brush for inner incisors.',
        'Outer surfaces: 45° angle with circular motion, 30 seconds.',
        'These teeth accumulate the most tartar (calculus) — floss daily in this area.',
      ],
    ),
    BrushingTechnique(
      title: 'Upper Back Teeth',
      area: 'Upper Premolars & Molars',
      emoji: '🦴',
      imageUrl:
          'https://images.unsplash.com/photo-1606811841689-23dfddce3e95?w=400',
      durationSeconds: 30,
      steps: [
        'Most cavities form in molar grooves — use fluoride toothpaste with good foam.',
        'Brush outer, inner, and chewing surfaces of every molar thoroughly.',
        'Insert the brush fully to reach the last molar — most people miss this tooth.',
        'Circular motion on outer surfaces; back-and-forth on chewing surfaces.',
      ],
    ),
    BrushingTechnique(
      title: 'Lower Back Teeth',
      area: 'Lower Premolars & Molars',
      emoji: '🦷',
      imageUrl:
          'https://images.unsplash.com/photo-1550614000-4895a10e1bfd?w=400',
      durationSeconds: 30,
      steps: [
        'Lower molars collect more food debris — floss after every major meal.',
        'Reach all the way to the wisdom teeth area if present.',
        'Inner surfaces require a tilted brush angle — these are often missed entirely.',
        'Chewing surfaces: vigorous back-and-forth motion removes food from grooves.',
      ],
    ),
    BrushingTechnique(
      title: 'Tongue Cleaning',
      area: 'Dorsal Surface of Tongue',
      emoji: '👅',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
      durationSeconds: 15,
      steps: [
        '90% of bad breath (halitosis) originates from tongue bacteria — not teeth.',
        'Use a dedicated tongue scraper — it is superior to using a toothbrush.',
        'Scrape from back to front 5–7 times; rinse the scraper between each pass.',
        'Do not trigger the gag reflex by going too far back — work gradually forward.',
      ],
    ),
  ];

  // ── Brush Type Info ────────────────────────────────────────────────────────

  static const String softBrushInfo =
      'Soft-bristled brushes are recommended by the ADA for most people. They effectively '
      'remove plaque while protecting enamel and gums. Hard bristles cause gum recession and '
      'enamel abrasion over time — conditions that are permanent and expensive to treat. '
      'Use a soft-bristled brush unless your dentist specifically advises otherwise.';

  static const String hardBrushInfo =
      'Hard-bristled brushes are rarely necessary or advisable. Dentists may recommend medium '
      'bristles for patients with heavy tartar buildup, but only with professional guidance. '
      'Hard bristles on sensitive gums cause irreversible recession. If your gums bleed, '
      'switching to a soft brush and improving technique is always the correct first step.';

  // ── FAQ ────────────────────────────────────────────────────────────────────

  static const List<FaqItem> faqs = [
    FaqItem(
      question: 'How long should I brush my teeth?',
      answer:
          'The ADA recommends brushing for exactly 2 minutes — 30 seconds per quadrant of your '
          'mouth. Studies show most people brush for only 45 seconds. Use a timer or an electric '
          'toothbrush with a built-in timer. Brushing longer than 3 minutes can cause enamel abrasion.',
    ),
    FaqItem(
      question: 'Should I brush before or after breakfast?',
      answer:
          'Brush BEFORE breakfast, not after. Overnight, bacteria multiply and produce acids. '
          'Brushing before breakfast removes these bacteria and fluoride from toothpaste protects '
          'teeth during the meal. If you eat acidic foods (orange juice, citrus), wait 30–45 '
          'minutes after eating before brushing to avoid abrading softened enamel.',
    ),
    FaqItem(
      question: 'Is flossing really necessary?',
      answer:
          'Absolutely. Toothbrushes cannot reach the 35–40% of tooth surface area located between '
          'teeth. The majority of cavities and gum disease originate between teeth. Floss once '
          'daily, preferably at night. Interdental brushes, water flossers, or soft picks are '
          'equally effective alternatives for those who struggle with traditional floss.',
    ),
    FaqItem(
      question: 'How often should I replace my toothbrush?',
      answer:
          'Replace your toothbrush every 3 months or when bristles show visible wear, bending, '
          'or fraying — whichever comes first. Worn bristles lose up to 30% of their cleaning '
          'effectiveness. Always replace after an illness (cold, flu, throat infection) to '
          'prevent reinfection.',
    ),
    FaqItem(
      question: 'Is mouthwash a substitute for brushing?',
      answer:
          'No. Mouthwash is a supplement, never a replacement for brushing and flossing. It '
          'cannot physically remove plaque or food debris. Antibacterial mouthwash (chlorhexidine) '
          'is effective for reducing bacteria and gum inflammation. Fluoride mouthwash strengthens '
          'enamel. Use it as the final step in your routine.',
    ),
    FaqItem(
      question: 'What causes bad breath and how do I fix it?',
      answer:
          'Causes include tongue bacteria (90% of cases), gum disease, dry mouth, food, poor oral '
          'hygiene, and occasionally systemic conditions (GERD, sinus infections). Fix: brush and '
          'floss daily, clean your tongue with a scraper, stay well hydrated. Mouthwash only masks '
          '— it does not cure — bad breath. See a dentist if the problem persists.',
    ),
    FaqItem(
      question: 'How much toothpaste should I use?',
      answer:
          'Adults: a pea-sized amount (about 1 cm). Children aged 3–6: a pea-sized amount. '
          'Children under 3: a rice-grain smear. Using more toothpaste does not improve cleaning '
          'and causes excess fluoride ingestion in children. Excessive fluoride in children can '
          'cause fluorosis — white spots on developing permanent teeth.',
    ),
    FaqItem(
      question: 'Why do my gums bleed when I brush?',
      answer:
          'Bleeding gums are almost always a sign of gingivitis — early gum disease caused by '
          'plaque accumulation. It is not normal and should not be ignored. The solution is '
          'usually improved brushing and flossing, not brushing more gently. Bleeding typically '
          'resolves within 2 weeks of consistent care. If it persists, see a periodontist.',
    ),
    FaqItem(
      question: 'Is an electric toothbrush better than manual?',
      answer:
          'Oscillating-rotating electric toothbrushes are clinically proven to remove 21% more '
          'plaque and reduce gum disease 11% more than manual brushes over 3 months (Cochrane '
          'Review 2014). They are especially beneficial for people with braces, arthritis, or '
          'poor manual dexterity. A proper manual brush technique is nearly as effective for '
          'motivated, compliant adults.',
    ),
    FaqItem(
      question: 'Can I use whitening toothpaste every day?',
      answer:
          'Most whitening toothpastes are safe for daily use, but use them cautiously if you '
          'have sensitive teeth. They work through mild abrasives and chemical agents such as '
          'hydrogen peroxide. Very abrasive whitening pastes used aggressively can thin enamel '
          'over time. Look for the ADA Seal of Acceptance. For significant whitening, '
          'professional dental bleaching is safer and far more effective.',
    ),
  ];
}
