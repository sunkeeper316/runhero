enum GearSlot {
  weapon('武器'),
  helmet('頭盔'),
  armor('衣服'),
  shoes('鞋子'),
  ring('戒指');

  const GearSlot(this.label);

  final String label;

  String effectLabel(int level) => switch (this) {
    GearSlot.weapon => '攻擊 +${level * 12}',
    GearSlot.helmet => '防禦 +${level * 4}',
    GearSlot.armor => '生命 +${level * 12}／防禦 +${level * 6}',
    GearSlot.shoes => '防禦 +${level * 2}',
    GearSlot.ring => '生命 +${level * 18}',
  };
}
