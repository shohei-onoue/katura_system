enum SearchStep { method, category, subCategory, prefecture, city, town, finalForm }

/// 施設検索のカテゴリマスタ
const Map<String, List<String>> facilityCategories = {
  '公共施設': ['役所・官公庁', '警察・消防', '図書館・文化施設', '公園・運動施設'],
  '医療関係': ['総合病院', '内科・外科', '歯科医', '小児科医', '産婦人科'],
  '寺社仏閣': ['寺院', '神社', '教会・その他'],
};
