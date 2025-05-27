= Les capteurs et les wearables

== Capteurs

Tendance à augmenter le nombre de capteurs plus on avance.

*Capteurs simples* = luminosité [lx], pression [hPa], proximité [cm] (en général binaire on/off), humidité [%], température [°C].

Capteurs mouvements attention aux système d'axe, pour natel : x, y sur l'écran et z parrallèle à celui-ci (+z face à l'écran, -z dos du natel) :
- *Accéléromètre* = indique sur chaque axe [m \* s^(-2)], au repos accélération de la gravité, utile pour mouvement peu précis (secouement, immobilité, marche/course).
- *Magnétomètre* = indique pour chaque axe l'intensité du champ magnétique [_micro_ T], utile pour positionnement par rapport au nord magnétique mais facilement perturbé (aimant, masse métallique).
- *Gyroscope* = meilleur que l'accéléromètre mais moins répandu et plus consommateur d'énérgie, indique la vitesse de rotation sur les 3 axes [rad \* s^(-1)], utile pour la VR ou AR.

=== Accès capteurs Kotlin

Comme _LocationManager_ on accède aux capteurs par le _SensorManager_, exemple inscription à accéléromètre :
```kt
val sensorManager = getSystemService(SENSOR_SERVICE) as SensorManager
val accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
// inscription au capteur
// ici listener est un SensorEventListener, on peut utiliser "this" si on est dans une activité p.ex.
sensorManager.registerListener(listener, accelerometer, SensorManager.SENSOR_DELAY_NORMAL)
// […]
// désinscription
sensorManager.unregisterListener(listener)
```

On peut donner une *précision temporelle* : `SENSOR_DELAY_NORMAL`, `SENSOR_DELAY_UI`, `SENSOR_DELAY_GAME`, `SENSOR_DELAY_FASTEST` (Android 12 si fréquence > 200Hz alors permissions particulières).

Attention => toujours se *désinscrire* d'un capteur si plus nécessaires car résultats dans le Thread-UI donc pas ralentir inutilement.

Le _SensorManager_ donne résultats à un _SensorEventListener_ (p.ex. Activité) qui doit avoir :
```kt
// appelée à chaque nouvelle valeur
override fun onSensorChanged(event: SensorEvent) {
  when(event.sensor.type) {
    // event.values est un tableau de float de données brutes, sa taille dépend du capteur
    Sensor.TYPE_ACCELEROMETER -> {
      event.values // float[3]
    }
    Sensor.TYPE_LIGHT -> {
      event.values // float[1]
    }
  }
}
override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
```

Attention => comme nous somme sur une *JVM* nous avons donc un _garbage collector_, si l'on doit créer beaucoup d'instance alors celui-ci peut prendre, dans des cas extrêmes, plus de ressources que l'application. Cela peut être le cas avec les capteurs car on peut devoir reporter un nouvel _SensorEvent_ plusieurs centaines de fois par secondes. Dans ce cas alors on aura un *pool d'instances* qui sera géré par le _SensorManager_ qui modifiera des _SensorEvent_ existant pour éviter d'en recréer. Donc il ne faut *pas garder de références* sur les _SensorEvent_ car ils pourront être modifier par la suite (copie, traitement immédiat).

Les données brutes récupérées ne sont pas toujour utiles seules donc Le _SensorManager_ met à disposition des méthodes pour l'interprétation de ces données. Exemple avec la pression pour en déduire l'altitude :
```kt
// p0 pression au niveau de la mer, p pression actuelle
SensorManager.getAltitude(float p0, float p)
```

Pour gyro, accel ou magnéto les données brutes sont une matrice de rotation 3D. La position de référence est l'axe -z aligné sur le centre de gravité de la terre et +y aligné sur le nord magnétique.
```kt
SensorManager.getRotationMatrix( float[] R, // matrice de rotation
  float[] I, // matrice d'inclinaison
  float[] gravity, // Accéléromètre
  float[] geomagnetic) // Magnétomètre
```

Matrice de transformations 3D :
#grid(
  columns: (1fr, 1fr, 2fr, 2fr, 2fr),
  rows: (auto),
  grid.cell(image("../images/matrix-trans.png")),
  grid.cell(image("../images/matrix-scale.png")),
  grid.cell(image("../images/matrix-rotX.png")),
  grid.cell(image("../images/matrix-rotY.png")),
  grid.cell(image("../images/matrix-rotZ.png")),
)

=== Capteurs composites

Des capteurs virtuel qui fusionnent et traite les données de capteurs physiques :
- *Step counter/detector (podomètre)* = basé en général sur accéléromètre
- *Game rotation vector* = gyro + accél + magnéto
- *Linear Acceleration* = accél + gyro ou magnéto 
- ...

=== Analyse avancée capteurs

On peut reconnaître des activités humaines grâce aux capteur (si fitness, transport, se déplace, ...).

4 groupes d'attribut :
- *Environnemental* = temp, bruit, etc.
- *Mouvement* = accél, gyro, magnéto
- *Localistion* = GPS, etc.
- *Physiologique* = temp corporelle, rythme cardiaque, etc.

1 seul capteur ne suffira pas en général pour déterminer avec précision l'activité.

On doit avoir la *permission* `ACTIVITY_RECOGNITION` depuis Android 10 (2019) pour le podomètre et autres librairies. Mais l'accès aux données brutes est toujours possible.

Utilisation détournée = écoute de discussions grâce à l'accél à partir des vibrations provoquée par le micro, détérminer appui de touche du clavier à partir de rotation, etc.

== Wearables

Donc vêtements ou accessoire avec éléments informatiques et éléctroniques (dans IoT). Toujours disponible et fonctionnalités en tout temps.

3 catégories :
- *Tracking, Measuring, Sensing* = capteurs corporels, interface limitée, faible consommation, données analysée et affichées.
- *Réalité améliorée* = aide vie courante, navigation, rappels, etc.
- *Second écran* = extension du natel pour tâche simples

Beacoup d'application possibles : médical (suivi taux de glucose, ...), fitness (montres, ceinture, ...), etc.

Ils sont en général reliés au travers de leur propre réseau *BAN* (Body Area Network) et en *BLE*.

Ils sont très peu interopérable (application propriétaire). Dans le domaine médical il existe la norme *Continua* pour essayer de promouvoir l'interopérabilité.

Pour le médical, depuis 2021 on a la législation suisse *ODim* pour préciser et renforcer les procédures nécessaire à la mise sur le marché d'une application de ce type.

Les montres connéctées sont la catégorie la plus répendue de wearable (Android Wear, Apple Watch).

=== Wear OS (anciennement Android Wear)

Une montre Wear OS est appairée en BLE avec un natel.

En 1.0 si la montre devait passer par la connexion du natel pour accéder à internet (proxy BLE) mais depuis 2.0 elle peut y accéder directement en Wi-Fi ou LTE (mais privilégie le proxy BLE pour l'économie d'énérgie, utilisation Wi-Fi/LTE si accès internet haut débit demandé ou en absence de natel).

On a plusieur approche de développement : *Notifications*, *Complications*, *Tuiles*, *Application*.

On pourra choisir la surface suivant la priorité des fonctionnalités/informations auxquelles on donne accès.

#image("../images/WearOS-meteo.png")

Le *développement est similaire que pour Android* : Activités, ViewModels, Librairies Jetpack, etc.

Attention toutefois à la réalisation de l'interface graphique qui est primordial (défilement vertical à privilégier).

Pour synchroniser les données entre une application montre et natel -> _Wearable Data Layer API_.

Cet API permet :
- *_Message Client_ d'envoyer des messages* = appel RPC avec payload limités.
- *_Channel Client_ transférer des donées* = streaming audio ou vidéo.
- D'annoncer des fonctionnalités prises en charges.
- *_Data Client_ synchroniser les données* = espace de stockage privé, chaque noeud (natel, montre, cloud) peut lire et écrire les données et on notifie les autre noeuds des changements, la synchro est automatique.

#image("../images/wearableDataLayerApi.png")