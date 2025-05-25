= Codes Barres

== Le problème qu'il y avait
*Résolution insuffisante* : CameraX analyse par défaut en *640×480 pixels*, insuffisant pour décoder les QR Codes complexes (versions 25, 40).

== Solution technique

=== Augmentation de la résolution d'analyse
MLKit nécessite *minimum 2 pixels par "pixel" du QR Code* (idéal), en réalité *4-8 pixels* requis.

*Compromis trouvé :* Résolution de *5 mégapixels (2592×1920)* au lieu de 640×480.

```kotlin
private val barcodesUseCase by lazy {
    ImageAnalysis.Builder()
        // Par défaut: 640x480 (insuffisant)
        .setTargetResolution(Size(2592, 1920)) // 5MP
        .setBackpressureStrategy(
          ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
        .build().apply {...}}}
```

=== Optimisation du scanner
*Limitation aux QR Codes uniquement* pour améliorer performances car defacto, on scanne tout, code-barres, etc.:

```kotlin
private val barcodeClient by lazy {
    BarcodeScanning.getClient(BarcodeScannerOptions
        .Builder()
        // Limite aux QR Codes
        .setBarcodeFormats(Barcode.FORMAT_QR_CODE) 
        .build())}
```

== Limitations pratiques
- *QR Code v40 (177$dot$177) :* Techniquement lisible mais *pas adapté grand public* (taille physique, temps de traitement)
- *Recommandation Google :* 2MP pour usage standard, 5MP pour cas extrêmes
- *Latence vs qualité :* 20MP natif = trop lent, 5MP = bon compromis