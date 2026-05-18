#!/usr/bin/env python3
from pathlib import Path

assets_dir = Path('epl_match_simulator/assets/emblems')

# Manchester City badge SVG
manchester_city_svg = '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="100" height="100" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <!-- Outer circle white -->
  <circle cx="50" cy="50" r="48" fill="white" stroke="#003399" stroke-width="2"/>

  <!-- Inner blue circle -->
  <circle cx="50" cy="50" r="42" fill="#6CABDE"/>

  <!-- Text ring MANCHESTER -->
  <path id="circlePath" cx="50" cy="50" r="35" fill="none"/>
  <text font-size="8" font-weight="bold" fill="white" letter-spacing="1">
    <textPath href="#circlePath" startOffset="50%" text-anchor="middle">
      MANCHESTER CITY
    </textPath>
  </text>

  <!-- Shield/Emblem background -->
  <circle cx="50" cy="50" r="28" fill="white" opacity="0.9"/>

  <!-- Eagle head (simplified) -->
  <g transform="translate(50, 35)">
    <circle cx="0" cy="0" r="4" fill="#003399"/>
    <path d="M -2 -2 L -5 -1 L -3 0 Z" fill="#003399"/>
    <path d="M 2 -2 L 5 -1 L 3 0 Z" fill="#003399"/>
  </g>

  <!-- Crown -->
  <g transform="translate(50, 50)">
    <rect x="-8" y="0" width="16" height="6" fill="#FFD700" rx="1"/>
    <polygon points="0,-2 -3,-5 -1,-2 0,-6 1,-2 3,-5 0,-2" fill="#FFD700"/>
  </g>

  <!-- City symbol -->
  <g transform="translate(50, 62)">
    <rect x="-5" y="0" width="10" height="5" fill="#003399"/>
    <polygon points="-4,0 -2,-2 0,0 2,-2 4,0" fill="#003399"/>
  </g>
</svg>'''

# Arsenal badge SVG
arsenal_svg = '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="100" height="110" viewBox="0 0 100 110" xmlns="http://www.w3.org/2000/svg">
  <!-- Shield background -->
  <path d="M 50 5 L 85 25 L 85 55 Q 50 90 50 90 Q 15 55 15 55 L 15 25 Z"
        fill="#EF0107" stroke="#002B5C" stroke-width="1.5"/>

  <!-- Gold/tan border -->
  <path d="M 50 8 L 82 26 L 82 54 Q 50 87 50 87 Q 18 54 18 54 L 18 26 Z"
        fill="none" stroke="#D4AF37" stroke-width="1.5"/>

  <!-- Arsenal text banner -->
  <rect x="20" y="15" width="60" height="12" fill="white" opacity="0.95" rx="2"/>
  <text x="50" y="25" font-size="11" font-weight="bold" text-anchor="middle" fill="#002B5C" font-family="Arial">Arsenal</text>

  <!-- Cannon (golden) -->
  <g transform="translate(50, 55)">
    <!-- Cannon barrel -->
    <rect x="-12" y="-2" width="24" height="4" fill="#D4AF37" rx="2"/>
    <!-- Cannon wheels -->
    <circle cx="-10" cy="8" r="4" fill="#8B7355" stroke="#654321" stroke-width="0.5"/>
    <circle cx="10" cy="8" r="4" fill="#8B7355" stroke="#654321" stroke-width="0.5"/>
    <!-- Connection lines -->
    <line x1="-8" y1="2" x2="-10" y2="4" stroke="#D4AF37" stroke-width="1"/>
    <line x1="8" y1="2" x2="10" y2="4" stroke="#D4AF37" stroke-width="1"/>
  </g>
</svg>'''

# Tottenham Hotspur badge SVG
tottenham_svg = '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="100" height="120" viewBox="0 0 100 120" xmlns="http://www.w3.org/2000/svg">
  <!-- White background -->
  <rect width="100" height="120" fill="white"/>

  <!-- Navy circle background -->
  <circle cx="50" cy="45" r="38" fill="#132257"/>

  <!-- Cockerel (rooster) on top of ball -->
  <g transform="translate(50, 35)">
    <!-- Ball -->
    <circle cx="0" cy="10" r="6" fill="white" stroke="#132257" stroke-width="0.5"/>
    <path d="M -3 10 Q 0 8 3 10 M -3 10 Q 0 12 3 10" stroke="#132257" stroke-width="0.5" fill="none"/>

    <!-- Rooster body -->
    <ellipse cx="0" cy="-2" rx="4" ry="5" fill="white"/>
    <!-- Rooster head -->
    <circle cx="0" cy="-8" r="3" fill="white"/>
    <!-- Rooster comb -->
    <path d="M -1 -11 L -2 -14 L 0 -13 L 2 -14 L 1 -11 Z" fill="white"/>
    <!-- Beak -->
    <polygon points="2,-8 5,-7 2,-6" fill="white"/>
    <!-- Tail feathers -->
    <path d="M -3 -1 Q -7 -5 -6 2" fill="none" stroke="white" stroke-width="1.5" stroke-linecap="round"/>
    <path d="M -2 0 Q -8 -2 -7 5" fill="none" stroke="white" stroke-width="1.5" stroke-linecap="round"/>
  </g>

  <!-- Text -->
  <text x="50" y="105" font-size="10" font-weight="bold" text-anchor="middle" fill="#132257" font-family="Arial">TOTTENHAM</text>
  <text x="50" y="117" font-size="9" font-weight="bold" text-anchor="middle" fill="#132257" font-family="Arial">HOTSPUR</text>
</svg>'''

# Save SVGs
with open(assets_dir / 'manchester_city.svg', 'w') as f:
    f.write(manchester_city_svg)
print("✓ Created manchester_city.svg")

with open(assets_dir / 'arsenal.svg', 'w') as f:
    f.write(arsenal_svg)
print("✓ Created arsenal.svg")

with open(assets_dir / 'tottenham_hotspur.svg', 'w') as f:
    f.write(tottenham_svg)
print("✓ Created tottenham_hotspur.svg")

print("\n✓ All 3 new official badges created successfully!")
