= Boussole 3D
== Objectif
Utiliser les capteurs du téléphone doonc accéléromètre et magnétomètre pour faire une boussole en 3D

== Manip 1

On va utiliser les résultats des deux capteurs pour générer la matrice de rotations que l'on pourra donner au renderer 3D OpenGL afin de faire bouger notre flèche 3D.

Donc on va utiliser enregister les 2 capteur sur notre activité puis on va récupérer les données de ceux-ci appeler `getRotationMatrix()` pour avoir notre matrice de rotation et la donner en appelant `openGLRenderer.swapRotMatrix()`.
```kt
override fun onCreate(savedInstanceState: Bundle?) {
  // [...]
  sensorManager = getSystemService(SENSOR_SERVICE) as SensorManager
  accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
  magnetometer  = sensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)
}

override fun onResume() {
  super.onResume()
  SensorManager.registerListener(this, accelerometer, sensorManager.SENSOR_DELAY_GAME) 
  SensorManager.registerListener(this, magnetometer, sensorManager.SENSOR_DELAY_GAME) // pareil que plus haut 
}

// Ne pas oublier
override fun onPause() {
  super.onPause()
  sensorManager.unregisterListener(this)
}
```

== Manip 2

On applique un low-pass filter sur les données de l'accéléromètre et du magnétomètre pour les rendre moins bruyantes car sans cela la flèche est tremblante même si on ne bouge pas.