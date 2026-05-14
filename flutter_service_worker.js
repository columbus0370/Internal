'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/assets/emblems/brentford.svg": "8677c1d435d5448e7ad28ab93f2f4c6c",
"assets/assets/emblems/everton.svg": "77e2c3d21f0409ea37215558c488bcc0",
"assets/assets/emblems/sunderland.svg": "e7907290e4bf2b814d3dcc8cbcf07d27",
"assets/assets/emblems/newcastle_united.svg": "79ec67d7378bae25e09172ee7ee9d2ed",
"assets/assets/emblems/west_ham_united.svg": "8115c977891d48e50e61cded04452b64",
"assets/assets/emblems/afc_bournemouth.svg": "1876843d2361c1e3088a00ece63e1bf9",
"assets/assets/emblems/nottingham_forest.svg": "319c59ba7cdc123509a774faee34b85b",
"assets/assets/emblems/chelsea.svg": "30ecca9e264434fe4db73b7fa9a9e8e2",
"assets/assets/emblems/burnley.svg": "29fafa6c89ea4e6d5183045ef70aab9f",
"assets/assets/emblems/crystal_palace.svg": "50ad09c7748857faff1f3b6a5bf53163",
"assets/assets/emblems/manchester_city.svg": "90c1613d03575f0f3dc3f50104f55eca",
"assets/assets/emblems/manchester_united.svg": "4b75589786211d6293e07ccfa0029900",
"assets/assets/emblems/aston_villa.svg": "04930b2cd7fc5e2c0e68cd68fb2d35b9",
"assets/assets/emblems/team_emblems.json": "99914b932bd37a50b983c5e7c90ae93b",
"assets/assets/emblems/liverpool.svg": "a8852c75adcccc838c73f64cd1b1c2e1",
"assets/assets/emblems/wolverhampton_wanderers.svg": "d0a4626798a5533bb56d56f6c27dacd6",
"assets/assets/emblems/arsenal.svg": "75c65b1e3afb2794dff09fab17f13ee0",
"assets/assets/emblems/brighton_and_hove_albion.svg": "75f7d76f5a2e2733013a8d0716bdfceb",
"assets/assets/emblems/tottenham_hotspur.svg": "5e262021bc2d7e61d315e6851a6da7f1",
"assets/assets/emblems/leeds_united.svg": "e1aabcf553e95ee928159b2d400030c1",
"assets/assets/emblems/fulham.svg": "3b33ba03ef622368ea1273204bd5952a",
"assets/fonts/MaterialIcons-Regular.otf": "71f4a07b8abb6436be8be44b77986070",
"assets/AssetManifest.bin": "5f0f4bd7690a205c122742a01ea267f3",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "f855f50ef615ce276e16874a9a0ca6a5",
"assets/NOTICES": "5b9ca0efc18a09bc6307505e175fccee",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/AssetManifest.json": "4efc99f43eb009fb3b52d25d9ab594bb",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"version.json": "bae0a127cf3820510a570ad34c2eeecc",
"index.html": "3be7951dfcd82e6496f081dc296bd503",
"/": "3be7951dfcd82e6496f081dc296bd503",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"flutter.js": "f31737fb005cd3a3c6bd9355efd33061",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/skwasm.js": "9fa2ffe90a40d062dd2343c7b84caf01",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/chromium/canvaskit.js": "87325e67bf77a9b483250e1fb1b54677",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"canvaskit/canvaskit.js": "5fda3f1af7d6433d53b24083e2219fa0",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"flutter_bootstrap.js": "89264debdc14131e349ca185e90304bb",
"manifest.json": "1ff418429f34899dca72ddb610b337ee",
"main.dart.js": "f53e6c72a0060b8da6a6a48553e036c1"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
