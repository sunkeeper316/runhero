enum MonsterType {
  goblin('哥布林', 'goblin.png'),
  slime('史萊姆', 'slime.png'),
  orc('獸人', 'orc.png'),
  oni('赤鬼', 'oni.png'),
  demon('角魔', 'demon.png');

  const MonsterType(this.label, this.assetName);

  final String label;
  final String assetName;
}
