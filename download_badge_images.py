#!/usr/bin/env python3
import requests
from pathlib import Path

assets_dir = Path('epl_match_simulator/assets/emblems')
assets_dir.mkdir(parents=True, exist_ok=True)

# Official Premier League badge image URLs
# Using known public image URLs
badge_urls = {
    'Chelsea': 'https://upload.wikimedia.org/wikipedia/en/c/cc/Chelsea_FC.svg',
    'Liverpool': 'https://upload.wikimedia.org/wikipedia/en/0/0c/Liverpool_FC.svg',
    'Manchester United': 'https://upload.wikimedia.org/wikipedia/en/7/7a/Manchester_United_FC_crest.svg',
    'Manchester City': 'https://upload.wikimedia.org/wikipedia/en/e/eb/Manchester_City_FC_badge.svg',
    'Arsenal': 'https://upload.wikimedia.org/wikipedia/en/5/53/Arsenal_FC.svg',
    'Tottenham Hotspur': 'https://upload.wikimedia.org/wikipedia/en/b/b4/Tottenham_Hotspur.svg',
}

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
}

print("Attempting to download official badge PNG images...")

for team, url in badge_urls.items():
    print(f"Downloading {team}...", end=" ")
    try:
        response = requests.get(url, timeout=10, headers=headers, allow_redirects=True)
        response.raise_for_status()

        # Try PNG variant of URL
        if 'svg' in url:
            png_url = url.replace('.svg', '.png')
            response = requests.get(png_url, timeout=10, headers=headers, allow_redirects=True)
            response.raise_for_status()

        safe_name = team.replace(' ', '_').replace('&', 'and').replace("'", '').lower()

        # Determine extension based on content type
        content_type = response.headers.get('content-type', '').lower()
        if 'png' in content_type:
            ext = '.png'
        elif 'jpeg' in content_type or 'jpg' in content_type:
            ext = '.jpg'
        else:
            ext = '.png'

        filename = f"{safe_name}{ext}"
        filepath = assets_dir / filename

        with open(filepath, 'wb') as f:
            f.write(response.content)

        print(f"✓ ({filename})")

    except Exception as e:
        print(f"✗ ({e})")

print("\nNote: If downloads failed, please provide direct image URLs or PNG files manually.")
