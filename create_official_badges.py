#!/usr/bin/env python3
from pathlib import Path

assets_dir = Path('epl_match_simulator/assets/emblems')

# Chelsea badge SVG
chelsea_svg = '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="100" height="100" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <!-- Blue background -->
  <circle cx="50" cy="50" r="48" fill="#0051BA" stroke="#D4AF37" stroke-width="2"/>

  <!-- White circle background for lion -->
  <circle cx="50" cy="50" r="38" fill="white"/>

  <!-- Lion silhouette (simplified) -->
  <g transform="translate(50, 50)">
    <!-- Head -->
    <circle cx="0" cy="-8" r="6" fill="#003399"/>
    <!-- Body -->
    <ellipse cx="0" cy="4" rx="5" ry="8" fill="#003399"/>
    <!-- Front legs -->
    <rect x="-3" y="10" width="2" height="8" fill="#003399"/>
    <rect x="1" y="10" width="2" height="8" fill="#003399"/>
    <!-- Tail -->
    <path d="M 5 2 Q 12 -2 14 8" fill="none" stroke="#003399" stroke-width="1.5"/>
  </g>

  <!-- Decorative elements -->
  <circle cx="25" cy="25" r="3" fill="#E74C3C"/>
  <circle cx="75" cy="25" r="3" fill="#E74C3C"/>
  <circle cx="75" cy="75" r="3" fill="#E74C3C"/>
  <circle cx="25" cy="75" r="3" fill="#E74C3C"/>
</svg>'''

# Liverpool badge SVG
liverpool_svg = '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="100" height="120" viewBox="0 0 100 120" xmlns="http://www.w3.org/2000/svg">
  <!-- Red Liver Bird -->
  <g transform="translate(50, 35)">
    <!-- Head -->
    <circle cx="0" cy="-10" r="7" fill="#C8102E"/>
    <!-- Beak -->
    <path d="M 6 -10 L 12 -8 L 6 -6 Z" fill="#C8102E"/>
    <!-- Body -->
    <ellipse cx="0" cy="5" rx="8" ry="12" fill="#C8102E"/>
    <!-- Wings -->
    <path d="M -8 -2 Q -15 0 -12 12" fill="none" stroke="#C8102E" stroke-width="3" stroke-linecap="round"/>
    <path d="M -8 2 Q -14 8 -10 15" fill="none" stroke="#C8102E" stroke-width="2.5" stroke-linecap="round"/>
    <path d="M 8 -2 Q 15 0 12 12" fill="none" stroke="#C8102E" stroke-width="3" stroke-linecap="round"/>
    <path d="M 8 2 Q 14 8 10 15" fill="none" stroke="#C8102E" stroke-width="2.5" stroke-linecap="round"/>
    <!-- Legs -->
    <circle cx="-4" cy="18" r="2.5" fill="#C8102E"/>
    <circle cx="4" cy="18" r="2.5" fill="#C8102E"/>
    <!-- Ball under feet -->
    <circle cx="0" cy="28" r="5" fill="#C8102E" opacity="0.8"/>
  </g>

  <!-- L.F.C. Text -->
  <text x="50" y="110" font-size="18" font-weight="bold" text-anchor="middle" fill="#C8102E" font-family="Arial">L.F.C.</text>
</svg>'''

# Manchester United badge SVG
manchester_united_svg = '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="100" height="100" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <!-- Shield shape background -->
  <path d="M 50 10 L 85 30 L 85 55 Q 50 85 50 85 Q 15 55 15 55 L 15 30 Z"
        fill="#DA291C" stroke="#F7B900" stroke-width="2"/>

  <!-- Yellow banner bottom -->
  <rect x="20" y="70" width="60" height="15" fill="#F7B900" opacity="0.9"/>

  <!-- Devil symbol (simplified red devil) -->
  <g transform="translate(50, 45)">
    <!-- Head -->
    <circle cx="0" cy="-5" r="5" fill="#FFD700"/>
    <!-- Horns -->
    <path d="M -4 -10 L -6 -16" stroke="#FFD700" stroke-width="1.5" fill="none" stroke-linecap="round"/>
    <path d="M 4 -10 L 6 -16" stroke="#FFD700" stroke-width="1.5" fill="none" stroke-linecap="round"/>
    <!-- Body -->
    <ellipse cx="0" cy="6" rx="4" ry="6" fill="#FFD700"/>
  </g>

  <!-- Text on banner -->
  <text x="50" y="81" font-size="10" font-weight="bold" text-anchor="middle" fill="#DA291C" font-family="Arial">MANCHESTER</text>
  <text x="50" y="92" font-size="9" font-weight="bold" text-anchor="middle" fill="#DA291C" font-family="Arial">UNITED</text>
</svg>'''

# Save SVGs
with open(assets_dir / 'chelsea.svg', 'w') as f:
    f.write(chelsea_svg)
print("✓ Created chelsea.svg")

with open(assets_dir / 'liverpool.svg', 'w') as f:
    f.write(liverpool_svg)
print("✓ Created liverpool.svg")

with open(assets_dir / 'manchester_united.svg', 'w') as f:
    f.write(manchester_united_svg)
print("✓ Created manchester_united.svg")

print("\n✓ All 3 official badges created successfully!")
