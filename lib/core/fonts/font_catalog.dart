import 'package:mongol_code/mongol_code.dart';

class FontItem {
  final String family;
  final String nameUnicode;
  final String nameMenksoft;
  final String englishDescription;

  FontItem({
    required this.family,
    required this.nameUnicode,
    required this.englishDescription,
  }) : nameMenksoft = convertUnicodeToMenksoft(nameUnicode);
}

class FontCatalog {
  static final List<FontItem> fonts = [
    FontItem(
      family: 'Qagan',
      nameUnicode: 'ᠴᠠᠭᠠᠨ ᠲᠢᠭ',
      englishDescription: 'Standard / Normal',
    ),
    FontItem(
      family: 'Garqag',
      nameUnicode: 'ᠭᠠᠷᠴᠠᠭ ᠲᠢᠭ',
      englishDescription: 'Title / Header',
    ),
    FontItem(
      family: 'Hara',
      nameUnicode: 'ᠬᠠᠷ᠎ᠠ ᠲᠢᠭ',
      englishDescription: 'Bold',
    ),
    FontItem(
      family: 'Scnin',
      nameUnicode: 'ᠰᠣᠨᠢᠨ ᠲᠢᠭ',
      englishDescription: 'News Print',
    ),
    FontItem(
      family: 'Hawang',
      nameUnicode: 'ᠬᠠᠸᠠᠩ ᠲᠢᠭ',
      englishDescription: 'Handwriting Brush',
    ),
    FontItem(
      family: 'Qimed',
      nameUnicode: 'ᠴᠢᠮᠡᠳ ᠲᠢᠭ',
      englishDescription: 'Handwriting Pen',
    ),
    FontItem(
      family: 'Narin',
      nameUnicode: 'ᠨᠠᠷᠢᠨ ᠲᠢᠭ',
      englishDescription: 'Thin',
    ),
    FontItem(
      family: 'Mcdvnbar',
      nameUnicode: 'ᠮᠣᠳᠣᠨ ᠪᠠᠷ ᠲᠢᠭ',
      englishDescription: 'Wood Carving',
    ),
    FontItem(
      family: 'Amglang',
      nameUnicode: 'ᠠᠮᠤᠭᠤᠯᠠᠩ ᠲᠢᠭ',
      englishDescription: 'Brush Calligraphy',
    ),
    FontItem(
      family: 'Sidam',
      nameUnicode: 'ᠰᠢᠳᠠᠮ ᠲᠢᠭ',
      englishDescription: 'Fat Round',
    ),
    FontItem(
      family: 'Qingming',
      nameUnicode: 'ᠴᠢᠩ ᠮᠢᠩ ᠲᠢᠭ',
      englishDescription: 'Qing Ming Style',
    ),
    FontItem(
      family: 'OnqaHara',
      nameUnicode: 'ᠤᠨᠴᠠ ᠬᠠᠷ᠎ᠠ ᠲᠢᠭ',
      englishDescription: 'Thick Stem',
    ),
    FontItem(
      family: 'Svgvnag',
      nameUnicode: 'ᠰᠤᠭᠤᠨᠠᠭ ᠲᠢᠭ',
      englishDescription: 'Thick Stem Thin Lines',
    ),
    FontItem(
      family: 'Svlbiya',
      nameUnicode: 'ᠰᠤᠯᠪᠢᠶ᠎ᠠ ᠲᠢᠭ',
      englishDescription: 'Double Stem',
    ),
    FontItem(
      family: 'Jclgq',
      nameUnicode: 'ᠵᠣᠯᠭᠠᠴᠠ ᠲᠢᠭ',
      englishDescription: 'Computer Form',
    ),
    FontItem(
      family: 'Tvgvrai',
      nameUnicode: 'ᠲᠤᠭᠤᠷᠠᠢ ᠲᠢᠭ',
      englishDescription: 'Hoof Print',
    ),
    FontItem(
      family: 'Erihe',
      nameUnicode: 'ᠡᠷᠢᠬᠡ ᠲᠢᠭ',
      englishDescription: 'Pearls (Beaded)',
    ),
    FontItem(
      family: 'Hvlvsvn',
      nameUnicode: 'ᠬᠤᠯᠤᠰᠤᠨ ᠲᠢᠭ',
      englishDescription: 'Bamboo Style',
    ),
    FontItem(
      family: 'Qimeg',
      nameUnicode: 'ᠴᠢᠮᠡᠭ ᠲᠢᠭ',
      englishDescription: 'Ornamental News',
    ),
    FontItem(
      family: 'Ujug',
      nameUnicode: 'ᠦᠵᠦᠭ ᠲᠢᠭ',
      englishDescription: 'Bamboo Pen',
    ),
    FontItem(
      family: 'Uyanga',
      nameUnicode: 'ᠤᠶᠠᠩᠭ᠎ᠠ ᠲᠢᠭ',
      englishDescription: 'Wavy Calligraphic',
    ),
  ];
}
