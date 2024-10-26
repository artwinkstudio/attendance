'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"ms-icon-144x144.png": "3a8c5adc641c9d3e6ec7b5bfc4336036",
"android-icon-72x72.png": "218d63e9a333f7fe1bab0cbdd80f1858",
"android-icon-36x36.png": "fb81d0791420377dc8a6c7e82ddbb968",
"flutter.js": "f393d3c16b631f36852323de8e583132",
"apple-icon-57x57.png": "e69b6a5bfa1e7026478a2a2d89089d31",
"apple-icon-76x76.png": "81be6bb234cf28f7f241b945531180d7",
"apple-icon-180x180.png": "d0a0e780ca0fab433a2c12ccf7bb276c",
"favicon-16x16.png": "45c46195a3296245b9e826a706e45970",
"apple-icon-120x120.png": "9ef2a79b6b265cff91e2ae97998e43ba",
"main.dart.js": "0ec886895420c1170e313730ee371053",
"apple-icon-144x144.png": "3a8c5adc641c9d3e6ec7b5bfc4336036",
"apple-icon-114x114.png": "2607c7a5b4af5af0119708e81768f3fd",
"apple-icon-72x72.png": "218d63e9a333f7fe1bab0cbdd80f1858",
"apple-icon-precomposed.png": "9f97c3822dd2eba50df9f238271c0348",
"browserconfig.xml": "653d077300a12f09a69caeea7a8947f8",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin": "db55d7790bc5bc1e3aec9669a15a6e3e",
"assets/fonts/MaterialIcons-Regular.otf": "eb6d02f6ca48f969f21908e8b9ccc336",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/images/logo.jpg": "b43de1f01c6158d7bf4dbabf76e08a09",
"assets/NOTICES": "b351db993cb8915ee487a1830aa8f60e",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.json": "a013ed9711d38487a7ea539b47b30d4a",
"assets/AssetManifest.bin.json": "78a67e21c2735dfcdc7522f1094e696f",
"apple-icon.png": "9f97c3822dd2eba50df9f238271c0348",
"ms-icon-150x150.png": "42682cc20178abff2480cb67d1ac3c6f",
"index.html": "20f0b6e49557db27240b1d815ecf0acf",
"/": "20f0b6e49557db27240b1d815ecf0acf",
"manifest.json": "b58fcfa7628c9205cb11a1b2c3e8f99a",
"canvaskit/canvaskit.js": "66177750aff65a66cb07bb44b8c6422b",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/chromium/canvaskit.js": "671c6b4f8fcc199dcc551c7bb125f239",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/skwasm.js": "694fda5704053957c2594de355805228",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"favicon.ico": "e1b7c890d8376df48323014b8b8715ba",
"android-icon-96x96.png": "30f6cbc2c24ee4f81332617f266f7388",
"android-icon-192x192.png": "990e1c023b877f6d1083ea1470481d13",
"favicon-32x32.png": "a0bbde9b19ac73b6adb823b3a324f629",
"android-icon-48x48.png": "bcf703bbd31ac0b2cd1b58bbf4dacde7",
"apple-icon-60x60.png": "bfa5e0b9477ef8b27d42a482ed217bec",
"favicon.png": "a56c635956dd7a064124feb8a0418560",
"ms-icon-310x310.png": "b25c5e723c2e56753e9d5450978b252f",
"android-icon-144x144.png": "3a8c5adc641c9d3e6ec7b5bfc4336036",
"apple-icon-152x152.png": "f83604e5416f5960b97aef17d86ad8de",
"ms-icon-70x70.png": "c15d068aad71babb1d957f50ec3e9eb5",
"favicon-96x96.png": "30f6cbc2c24ee4f81332617f266f7388",
"version.json": "daddb57faee272b6414f39afea3e53dc",
"flutter_bootstrap.js": "f31d91f5209db1488cc4f9a4a4fe00fe"};
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
