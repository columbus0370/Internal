#!/usr/bin/env python3
from pathlib import Path

# Team colors (primary color)
team_colors = {
    'Arsenal': '#EF0107',
    'Manchester City': '#6CABDE',
    'Manchester United': '#DA291C',
    'Liverpool': '#CE1126',
    'Aston Villa': '#008687',
    'AFC Bournemouth': '#DA291C',
    'Brighton & Hove Albion': '#0087DC',
    'Brentford': '#DC0000',
    'Tottenham Hotspur': '#132257',
    'Fulham': '#000000',
    'Newcastle United': '#241F20',
    'Nottingham Forest': '#E53233',
    'Crystal Palace': '#1B50BE',
    'Chelsea': '#0051BA',
    'Everton': '#003DA5',
    'West Ham United': '#7D2C3B',
    'Leeds United': '#FFBE0B',
    'Sunderland': '#EB172B',
    'Burnley': '#6B1A2A',
    'Wolverhampton Wanderers': '#FDB913',
}

assets_dir = Path('epl_match_simulator/assets/emblems')

for team, color in team_colors.items():
    # Create a simple shield SVG
    svg_content = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg width="100" height="100" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="grad_{team.replace(' ', '_')}" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:{color};stop-opacity:1" />
      <stop offset="100%" style="stop-color:{{color_darker}};stop-opacity:1" />
    </linearGradient>
  </defs>

  <!-- Shield shape -->
  <path d="M 50 5 L 85 25 L 85 55 Q 50 90 50 90 Q 15 55 15 55 L 15 25 Z"
        fill="url(#grad_{team.replace(' ', '_')})"
        stroke="white"
        stroke-width="2"/>

  <!-- Team initials/pattern -->
  <text x="50" y="60"
        font-size="28"
        font-weight="bold"
        text-anchor="middle"
        fill="white"
        font-family="Arial">
    {team[0]}
  </text>
</svg>'''

    safe_name = team.replace(' ', '_').replace('&', 'and').replace("'", '').lower()
    filename = f"{safe_name}.svg"
    filepath = assets_dir / filename

    with open(filepath, 'w') as f:
        f.write(svg_content)

    print(f"✓ Created {filename}")

print(f"\n✓ Created {len(team_colors)} team crest SVGs")
