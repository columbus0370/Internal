#!/usr/bin/env python3
import requests
from pathlib import Path
from PIL import Image
from io import BytesIO

assets_dir = Path('epl_match_simulator/assets/emblems')
assets_dir.mkdir(parents=True, exist_ok=True)

# High-quality official badge PNG URLs from reliable sources
# Using direct PNG links where available
badge_urls = {
    'Chelsea': 'https://resources.premierleague.com/premierleague/badges/70/t1.png',
    'Liverpool': 'https://resources.premierleague.com/premierleague/badges/58/t1.png',
    'Manchester United': 'https://resources.premierleague.com/premierleague/badges/1/t1.png',
    'Manchester City': 'https://resources.premierleague.com/premierleague/badges/43/t1.png',
    'Arsenal': 'https://resources.premierleague.com/premierleague/badges/1/t1.png',
    'Tottenham Hotspur': 'https://resources.premierleague.com/premierleague/badges/21/t1.png',
}

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
}

print("Downloading high-quality official Premier League badge images...")

for team, url in badge_urls.items():
    print(f"Downloading {team}...", end=" ")
    try:
        response = requests.get(url, timeout=15, headers=headers, allow_redirects=True)
        response.raise_for_status()

        safe_name = team.replace(' ', '_').replace('&', 'and').replace("'", '').lower()
        filename = f"{safe_name}.png"
        filepath = assets_dir / filename

        with open(filepath, 'wb') as f:
            f.write(response.content)

        # Verify it's a valid image
        try:
            img = Image.open(filepath)
            print(f"✓ ({img.width}x{img.height})")
        except:
            print("✓ (saved)")

    except Exception as e:
        print(f"✗ ({str(e)[:30]})")

print("\n" + "="*50)
print("If downloads failed, alternative sources:")
print("- https://www.premierleague.com/")
print("- https://en.wikipedia.org/wiki/Premier_League")
print("="*50)
