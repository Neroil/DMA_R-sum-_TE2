= Exercice 4 : Wearables

== Ce qu'il fallait faire (Ex 1)

Dans la partie notificationActivity, ce qu'il fallait faire était de dupliquer les notifications générales et de les envoyer à la montre à l'aide du `WearableExtender` :

```kotlin
notif.extend(NotificationCompat.WearableExtender()
    .addAction(action1)
    .addAction(action2)
    .addAction(action3))
```

Sinon le reste du code était classique.

== Ce qu'il fallait faire (Ex 2)

=== Objectif
Créer deux applications synchronisées (smartphone + montre) qui partagent des données en temps réel via la *Wearable Data Layer API*. L'exemple concret : synchroniser une couleur RGB entre les deux appareils via des sliders.

=== Architecture MVVM partagée
- *Même ViewModel* dans le module `common` (code réutilisé)
- *Instances séparées* du ViewModel (pas de partage d'instance)  
- *Communication via Data Layer API* uniquement

=== Problèmes du code original
Le code initial était incomplet :
- ❌ Pas de gestion des interactions utilisateur (sliders)
- ❌ Pas d'observation des changements de couleur
- ❌ Pas d'envoi de données vers la Data Layer API

=== Solutions implémentées

==== A. Gestion des interactions utilisateur
```kotlin
class DataSyncActivity : AppCompatActivity(), 
                        OnSeekBarChangeListener {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        // Configuration des listeners pour les sliders RGB
        binding.red.setOnSeekBarChangeListener(this)
        binding.green.setOnSeekBarChangeListener(this)
        binding.blue.setOnSeekBarChangeListener(this)
    }
}
```

==== B. Envoi des données (smartphone → montre)
```kotlin
override fun onStopTrackingTouch(seekBar: SeekBar) {
    val r = binding.red.progress
    val g = binding.green.progress  
    val b = binding.blue.progress

    // Envoi vers Data Layer API
    dataClient.putDataItem(Tools.createColorUpdate(r,g,b))
}
```

*Mécanisme :*
1. Utilisateur relâche un slider (`onStopTrackingTouch`)
2. Récupération des valeurs RGB actuelles
3. Création d'un `DataItem` via `Tools.createColorUpdate()`
4. Envoi via `dataClient.putDataItem()`

==== C. Réception et mise à jour de l'interface
```kotlin
override fun onCreate(savedInstanceState: Bundle?) {
    // Observation des changements de couleur
    colorViewModel.color.observe(this) { newColor ->
        binding.root.setBackgroundColor(newColor)
        binding.red.progress = Color.red(newColor)
        binding.green.progress = Color.green(newColor)
        binding.blue.progress = Color.blue(newColor)
    }
}
```

==== D. Gestion du cycle de vie
```kotlin
override fun onResume() {
    super.onResume()
    // Récupération des données existantes
    dataClient.dataItems.addOnSuccessListener(colorViewModel)
    // Écoute des changements en temps réel
    dataClient.addListener(colorViewModel)
}

override fun onPanelClosed(featureId: Int, menu: Menu) {
    super.onPanelClosed(featureId, menu)
    // Arrêt de l'écoute pour éviter les fuites mémoire
    dataClient.removeListener(colorViewModel)
}
```

=== Flux de synchronisation complet
1. *Smartphone* : User bouge slider rouge
2. *Smartphone* : `onStopTrackingTouch` → `putDataItem(R,G,B)`
3. *Data Layer API* : Synchronisation automatique
4. *Montre* : `ColorViewModel.onDataChanged()` appelé
5. *Montre* : `_color.value` mis à jour
6. *Montre* : Interface observe `color` → background + sliders mis à jour

