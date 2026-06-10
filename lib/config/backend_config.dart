/// Basculer ici entre LOCAL et PROD 
/// Décommente simplement l'option qui t'intéresse puis commente l'autre.
 //const bool kUseProdBackend = false; // <- Local (même réseau Wi-Fi)
  const bool kUseProdBackend = true; // <- Production

// ---- Paramètres locaux (téléphone physique connecté au même réseau Wi-Fi) ----
const String kLocalHost = '192.168.1.98';
const String kLocalPort = '5000';
const String kLocalBaseNoApi = 'http://$kLocalHost:$kLocalPort';
const String kLocalBaseUrl = '$kLocalBaseNoApi/api';

// ---- Paramètres production ----
const String kProdBaseNoApi = 'https://api.tranoo.store';
const String kProdBaseUrl = '$kProdBaseNoApi/api';

// Si tu préfères ne pas toucher au booléen ci-dessus,
// tu peux aussi copier/coller les deux lignes suivantes
// et commenter/décommenter selon tes besoins :
// const String kManualBackendNoApi = 'http://192.168.1.xxx:5000'; // LOCAL
// const String kManualBackendNoApi = 'https://api.tranoo.store'; // PROD

String getApiBaseUrl() => kUseProdBackend ? kProdBaseUrl : kLocalBaseUrl;
String getBackendBaseUrl() =>
    kUseProdBackend ? kProdBaseNoApi : kLocalBaseNoApi;
