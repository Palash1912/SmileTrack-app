class Country {
  final String name;
  final String code;
  final String dialCode;
  final String flag;

  const Country({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
  });

  String get displayName => '$flag  $name';
}

/// Comprehensive list of world countries with ISO codes, dial codes, and flag emojis.
const List<Country> kCountries = [
  Country(name: 'Afghanistan', code: 'AF', dialCode: '+93', flag: '🇦🇫'),
  Country(name: 'Albania', code: 'AL', dialCode: '+355', flag: '🇦🇱'),
  Country(name: 'Algeria', code: 'DZ', dialCode: '+213', flag: '🇩🇿'),
  Country(name: 'Argentina', code: 'AR', dialCode: '+54', flag: '🇦🇷'),
  Country(name: 'Armenia', code: 'AM', dialCode: '+374', flag: '🇦🇲'),
  Country(name: 'Australia', code: 'AU', dialCode: '+61', flag: '🇦🇺'),
  Country(name: 'Austria', code: 'AT', dialCode: '+43', flag: '🇦🇹'),
  Country(name: 'Bahamas', code: 'BS', dialCode: '+1-242', flag: '🇧🇸'),
  Country(name: 'Bahrain', code: 'BH', dialCode: '+973', flag: '🇧🇭'),
  Country(name: 'Bangladesh', code: 'BD', dialCode: '+880', flag: '🇧🇩'),
  Country(name: 'Barbados', code: 'BB', dialCode: '+1-246', flag: '🇧🇧'),
  Country(name: 'Belgium', code: 'BE', dialCode: '+32', flag: '🇧🇪'),
  Country(name: 'Bhutan', code: 'BT', dialCode: '+975', flag: '🇧🇹'),
  Country(name: 'Bolivia', code: 'BO', dialCode: '+591', flag: '🇧🇴'),
  Country(name: 'Brazil', code: 'BR', dialCode: '+55', flag: '🇧🇷'),
  Country(name: 'Bulgaria', code: 'BG', dialCode: '+359', flag: '🇧🇬'),
  Country(name: 'Cambodia', code: 'KH', dialCode: '+855', flag: '🇰🇭'),
  Country(name: 'Cameroon', code: 'CM', dialCode: '+237', flag: '🇨🇲'),
  Country(name: 'Canada', code: 'CA', dialCode: '+1', flag: '🇨🇦'),
  Country(name: 'Chile', code: 'CL', dialCode: '+56', flag: '🇨🇱'),
  Country(name: 'China', code: 'CN', dialCode: '+86', flag: '🇨🇳'),
  Country(name: 'Colombia', code: 'CO', dialCode: '+57', flag: '🇨🇴'),
  Country(name: 'Costa Rica', code: 'CR', dialCode: '+506', flag: '🇨🇷'),
  Country(name: 'Croatia', code: 'HR', dialCode: '+385', flag: '🇭🇷'),
  Country(name: 'Cyprus', code: 'CY', dialCode: '+357', flag: '🇨🇾'),
  Country(name: 'Czech Republic', code: 'CZ', dialCode: '+420', flag: '🇨🇿'),
  Country(name: 'Denmark', code: 'DK', dialCode: '+45', flag: '🇩🇰'),
  Country(name: 'Dominican Republic', code: 'DO', dialCode: '+1-809', flag: '🇩🇴'),
  Country(name: 'Ecuador', code: 'EC', dialCode: '+593', flag: '🇪🇨'),
  Country(name: 'Egypt', code: 'EG', dialCode: '+20', flag: '🇪🇬'),
  Country(name: 'Estonia', code: 'EE', dialCode: '+372', flag: '🇪🇪'),
  Country(name: 'Ethiopia', code: 'ET', dialCode: '+251', flag: '🇪🇹'),
  Country(name: 'Fiji', code: 'FJ', dialCode: '+679', flag: '🇫🇯'),
  Country(name: 'Finland', code: 'FI', dialCode: '+358', flag: '🇫🇮'),
  Country(name: 'France', code: 'FR', dialCode: '+33', flag: '🇫🇷'),
  Country(name: 'Georgia', code: 'GE', dialCode: '+995', flag: '🇬🇪'),
  Country(name: 'Germany', code: 'DE', dialCode: '+49', flag: '🇩🇪'),
  Country(name: 'Ghana', code: 'GH', dialCode: '+233', flag: '🇬🇭'),
  Country(name: 'Greece', code: 'GR', dialCode: '+30', flag: '🇬🇷'),
  Country(name: 'Guatemala', code: 'GT', dialCode: '+502', flag: '🇬🇹'),
  Country(name: 'Hong Kong', code: 'HK', dialCode: '+852', flag: '🇭🇰'),
  Country(name: 'Hungary', code: 'HU', dialCode: '+36', flag: '🇭🇺'),
  Country(name: 'Iceland', code: 'IS', dialCode: '+354', flag: '🇮🇸'),
  Country(name: 'India', code: 'IN', dialCode: '+91', flag: '🇮🇳'),
  Country(name: 'Indonesia', code: 'ID', dialCode: '+62', flag: '🇮🇩'),
  Country(name: 'Iran', code: 'IR', dialCode: '+98', flag: '🇮🇷'),
  Country(name: 'Iraq', code: 'IQ', dialCode: '+964', flag: '🇮🇶'),
  Country(name: 'Ireland', code: 'IE', dialCode: '+353', flag: '🇮🇪'),
  Country(name: 'Israel', code: 'IL', dialCode: '+972', flag: '🇮🇱'),
  Country(name: 'Italy', code: 'IT', dialCode: '+39', flag: '🇮🇹'),
  Country(name: 'Jamaica', code: 'JM', dialCode: '+1-876', flag: '🇯🇲'),
  Country(name: 'Japan', code: 'JP', dialCode: '+81', flag: '🇯🇵'),
  Country(name: 'Jordan', code: 'JO', dialCode: '+962', flag: '🇯🇴'),
  Country(name: 'Kazakhstan', code: 'KZ', dialCode: '+7', flag: '🇰🇿'),
  Country(name: 'Kenya', code: 'KE', dialCode: '+254', flag: '🇰🇪'),
  Country(name: 'Kuwait', code: 'KW', dialCode: '+965', flag: '🇰🇼'),
  Country(name: 'Lebanon', code: 'LB', dialCode: '+961', flag: '🇱🇧'),
  Country(name: 'Luxembourg', code: 'LU', dialCode: '+352', flag: '🇱🇺'),
  Country(name: 'Malaysia', code: 'MY', dialCode: '+60', flag: '🇲🇾'),
  Country(name: 'Maldives', code: 'MV', dialCode: '+960', flag: '🇲🇻'),
  Country(name: 'Malta', code: 'MT', dialCode: '+356', flag: '🇲🇹'),
  Country(name: 'Mexico', code: 'MX', dialCode: '+52', flag: '🇲🇽'),
  Country(name: 'Monaco', code: 'MC', dialCode: '+377', flag: '🇲🇨'),
  Country(name: 'Morocco', code: 'MA', dialCode: '+212', flag: '🇲🇦'),
  Country(name: 'Myanmar', code: 'MM', dialCode: '+95', flag: '🇲🇲'),
  Country(name: 'Nepal', code: 'NP', dialCode: '+977', flag: '🇳🇵'),
  Country(name: 'Netherlands', code: 'NL', dialCode: '+31', flag: '🇳🇱'),
  Country(name: 'New Zealand', code: 'NZ', dialCode: '+64', flag: '🇳🇿'),
  Country(name: 'Nigeria', code: 'NG', dialCode: '+234', flag: '🇳🇬'),
  Country(name: 'Norway', code: 'NO', dialCode: '+47', flag: '🇳🇴'),
  Country(name: 'Oman', code: 'OM', dialCode: '+968', flag: '🇴🇲'),
  Country(name: 'Pakistan', code: 'PK', dialCode: '+92', flag: '🇵🇰'),
  Country(name: 'Panama', code: 'PA', dialCode: '+507', flag: '🇵🇦'),
  Country(name: 'Peru', code: 'PE', dialCode: '+51', flag: '🇵🇪'),
  Country(name: 'Philippines', code: 'PH', dialCode: '+63', flag: '🇵🇭'),
  Country(name: 'Poland', code: 'PL', dialCode: '+48', flag: '🇵🇱'),
  Country(name: 'Portugal', code: 'PT', dialCode: '+351', flag: '🇵🇹'),
  Country(name: 'Qatar', code: 'QA', dialCode: '+974', flag: '🇶🇦'),
  Country(name: 'Romania', code: 'RO', dialCode: '+40', flag: '🇷🇴'),
  Country(name: 'Saudi Arabia', code: 'SA', dialCode: '+966', flag: '🇸🇦'),
  Country(name: 'Singapore', code: 'SG', dialCode: '+65', flag: '🇸🇬'),
  Country(name: 'South Africa', code: 'ZA', dialCode: '+27', flag: '🇿🇦'),
  Country(name: 'South Korea', code: 'KR', dialCode: '+82', flag: '🇰🇷'),
  Country(name: 'Spain', code: 'ES', dialCode: '+34', flag: '🇪🇸'),
  Country(name: 'Sri Lanka', code: 'LK', dialCode: '+94', flag: '🇱🇰'),
  Country(name: 'Sweden', code: 'SE', dialCode: '+46', flag: '🇸🇪'),
  Country(name: 'Switzerland', code: 'CH', dialCode: '+41', flag: '🇨🇭'),
  Country(name: 'Taiwan', code: 'TW', dialCode: '+886', flag: '🇹🇼'),
  Country(name: 'Thailand', code: 'TH', dialCode: '+66', flag: '🇹🇭'),
  Country(name: 'Turkey', code: 'TR', dialCode: '+90', flag: '🇹🇷'),
  Country(name: 'Ukraine', code: 'UA', dialCode: '+380', flag: '🇺🇦'),
  Country(name: 'United Arab Emirates', code: 'AE', dialCode: '+971', flag: '🇦🇪'),
  Country(name: 'United Kingdom', code: 'GB', dialCode: '+44', flag: '🇬🇧'),
  Country(name: 'United States', code: 'US', dialCode: '+1', flag: '🇺🇸'),
  Country(name: 'Uruguay', code: 'UY', dialCode: '+598', flag: '🇺🇾'),
  Country(name: 'Vietnam', code: 'VN', dialCode: '+84', flag: '🇻🇳'),
  Country(name: 'Zimbabwe', code: 'ZW', dialCode: '+263', flag: '🇿🇼'),
];

/// Helper to find a country matching text or emoji
Country? findCountry(String? query) {
  if (query == null || query.trim().isEmpty) return null;
  final clean = query.trim().toLowerCase();
  for (final c in kCountries) {
    if (c.name.toLowerCase() == clean ||
        c.code.toLowerCase() == clean ||
        c.flag == query.trim() ||
        c.displayName.toLowerCase() == clean) {
      return c;
    }
  }
  return null;
}
