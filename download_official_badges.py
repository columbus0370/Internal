#!/usr/bin/env python3
import requests
import json
from pathlib import Path

assets_dir = Path('epl_match_simulator/assets/emblems')
assets_dir.mkdir(parents=True, exist_ok=True)

# Public API sources for Premier League team badges
# Using rapidapi football-data with free tier alternative

team_badge_urls = {
    'Arsenal': 'https://crests.football-data.org/64.svg',
    'Manchester City': 'https://crests.football-data.org/65.svg',
    'Manchester United': 'https://crests.football-data.org/66.svg',
    'Liverpool': 'https://crests.football-data.org/64.svg',
    'Aston Villa': 'https://crests.football-data.org/68.svg',
    'AFC Bournemouth': 'https://crests.football-data.org/1044.svg',
    'Brighton & Hove Albion': 'https://crests.football-data.org/331.svg',
    'Brentford': 'https://crests.football-data.org/402.svg',
    'Tottenham Hotspur': 'https://crests.football-data.org/73.svg',
    'Fulham': 'https://crests.football-data.org/63.svg',
    'Newcastle United': 'https://crests.football-data.org/67.svg',
    'Nottingham Forest': 'https://crests.football-data.org/70.svg',
    'Crystal Palace': 'https://crests.football-data.org/354.svg',
    'Chelsea': 'https://crests.football-data.org/61.svg',
    'Everton': 'https://crests.football-data.org/62.svg',
    'West Ham United': 'https://crests.football-data.org/563.svg',
    'Leeds United': 'https://crests.football-data.org/341.svg',
    'Sunderland': 'https://crests.football-data.org/58.svg',
    'Burnley': 'https://crests.football-data.org/328.svg',
    'Wolverhampton Wanderers': 'https://crests.football-data.org/76.svg',
}

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
}

downloaded = {}
failed = []

print("Downloading official Premier League team badges from football-data.org...")

for team, url in team_badge_urls.items():
    print(f"Downloading {team}...", end=" ")
    try:
        response = requests.get(url, timeout=10, headers=headers)
        response.raise_for_status()

        safe_name = team.replace(' ', '_').replace('&', 'and').replace("'", '').lower()
        filename = f"{safe_name}.svg"
        filepath = assets_dir / filename

        with open(filepath, 'wb') as f:
            f.write(response.content)

        downloaded[team] = filename
        print("✓")

    except Exception as e:
        print(f"✗ {e}")
        failed.append(team)

# Save mapping
mapping_file = assets_dir / 'team_emblems.json'
with open(mapping_file, 'w') as f:
    json.dump(downloaded, f, indent=2)

print(f"\n✓ Downloaded {len(downloaded)}/{len(team_badge_urls)} badges")
if failed:
    print(f"✗ Failed: {', '.join(failed)}")
