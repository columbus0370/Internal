Map<String, String> premierLeagueBadges = {
  'Arsenal': '🔴',
  'Manchester City': '🔵',
  'Manchester United': '🔴',
  'Liverpool': '🔴',
  'Aston Villa': '🔵',
  'AFC Bournemouth': '🔴',
  'Brighton & Hove Albion': '⚪',
  'Brentford': '⚪',
  'Tottenham Hotspur': '⚪',
  'Fulham': '⚪',
  'Newcastle United': '⚫',
  'Nottingham Forest': '🔴',
  'Crystal Palace': '⚫',
  'Chelsea': '🔵',
  'Everton': '🔵',
  'West Ham United': '🔴',
  'Leeds United': '⚪',
  'Sunderland': '🔴',
  'Burnley': '🔵',
  'Wolverhampton Wanderers': '🟠',
};

String getTeamBadge(String teamName) {
  return premierLeagueBadges[teamName] ?? '⚽';
}
