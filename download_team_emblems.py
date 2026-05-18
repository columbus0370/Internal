#!/usr/bin/env python3
import requests
import os
from pathlib import Path

# Create assets directory
assets_dir = Path('epl_match_simulator/assets/emblems')
assets_dir.mkdir(parents=True, exist_ok=True)

# Premier League team emblems from available sources
# Using Wikimedia Commons direct links and other public sources
team_emblems_urls = {
    'Arsenal': 'https://upload.wikimedia.org/wikipedia/en/5/53/Arsenal_FC.svg',
    'Manchester City': 'https://upload.wikimedia.org/wikipedia/en/e/eb/Manchester_City_FC_badge.svg',
    'Manchester United': 'https://upload.wikimedia.org/wikipedia/en/7/7a/Manchester_United_FC_crest.svg',
    'Liverpool': 'https://upload.wikimedia.org/wikipedia/en/0/0c/Liverpool_FC.svg',
    'Aston Villa': 'https://upload.wikimedia.org/wikipedia/en/f/f9/Aston_Villa_FC_crest.svg',
    'AFC Bournemouth': 'https://upload.wikimedia.org/wikipedia/en/e/e5/AFC_Bournemouth_2013.svg',
    'Brighton & Hove Albion': 'https://upload.wikimedia.org/wikipedia/en/f/fd/Brighton_and_Hove_Albion_FC_logo.svg',
    'Brentford': 'https://upload.wikimedia.org/wikipedia/en/2/2a/Brentford_FC_crest.svg',
    'Tottenham Hotspur': 'https://upload.wikimedia.org/wikipedia/en/b/b4/Tottenham_Hotspur.svg',
    'Fulham': 'https://upload.wikimedia.org/wikipedia/en/e/eb/Fulham_FC_%28shield%29.svg',
    'Newcastle United': 'https://upload.wikimedia.org/wikipedia/en/e/e8/Newcastle_United_FC_logo.svg',
    'Nottingham Forest': 'https://upload.wikimedia.org/wikipedia/en/e/e5/Nottingham_Forest_FC_logo.svg',
    'Crystal Palace': 'https://upload.wikimedia.org/wikipedia/en/0/0c/Crystal_Palace_FC_logo.svg',
    'Chelsea': 'https://upload.wikimedia.org/wikipedia/en/c/cc/Chelsea_FC.svg',
    'Everton': 'https://upload.wikimedia.org/wikipedia/en/7/7c/Everton_FC_logo.svg',
    'West Ham United': 'https://upload.wikimedia.org/wikipedia/en/c/c2/West_Ham_United_FC_logo.svg',
    'Leeds United': 'https://upload.wikimedia.org/wikipedia/en/5/5a/Leeds_United_FC_logo.svg',
    'Sunderland': 'https://upload.wikimedia.org/wikipedia/en/2/2e/Sunderland_AFC_logo.svg',
    'Burnley': 'https://upload.wikimedia.org/wikipedia/en/6/62/Burnley_FC_logo.svg',
    'Wolverhampton Wanderers': 'https://upload.wikimedia.org/wikipedia/en/f/fc/Wolverhampton_Wanderers.svg',
}

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
}

team_emblems = {}

for team_name, url in team_emblems_urls.items():
    print(f"Downloading {team_name}...")

    try:
        response = requests.get(url, timeout=10, headers=headers)
        response.raise_for_status()

        # Determine extension
        if url.endswith('.svg'):
            ext = '.svg'
        elif url.endswith('.png'):
            ext = '.png'
        else:
            ext = '.svg'  # Default to SVG

        # Create safe filename
        safe_name = team_name.replace(' ', '_').replace('&', 'and').replace("'", '').lower()
        filename = f"{safe_name}{ext}"
        filepath = assets_dir / filename

        # Save file
        with open(filepath, 'wb') as f:
            f.write(response.content)

        team_emblems[team_name] = filename
        print(f"✓ {filename}")

    except Exception as e:
        print(f"✗ {team_name}: {e}")

# Save mapping
import json
mapping_file = assets_dir / 'team_emblems.json'
with open(mapping_file, 'w') as f:
    json.dump(team_emblems, f, indent=2)

print(f"\n✓ Downloaded {len(team_emblems)}/{len(team_emblems_urls)} emblems")
