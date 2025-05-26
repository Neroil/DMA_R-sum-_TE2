= NDK
Le NDK permet d'utiliser du code C/C++ dans une application Android. Le code est compilé pour différente architecture sous forme de librairie partagée (.so). Le NDK ne remplace pas Kotlin, mais est utilisé dans des cas particuliers où les performances sont critiques.

 == Contenu 
 - CLANG pour compilation et LLD pour linkgage
- La STL (C++14 par défaut, C++17 ou partiellemnet C++20)
- APIs android(log, sensor, asset_manager, etc.)

== Architectures
Le code du NDK est compilé pour 4 architectures de processeur. Cela permet de pouvoir faire tourner l'application sur un maximum de téléphones.
#figure(image("../images/architecture.png"))

== Integration
Deux approches:
- JNI (Java Native Interface) : appelle des méthode c++ depuis Kotlin
- native-activity: Application entièrement en C++ et utilise OpenGL ES pour l'UI.

Utilisation d'un makefile Android pour lister les fichiers source mais l'utilisation de CMake est recommendée.

== Types 
Le NDK propose des types équivalents aux types primitifs de Java/Kotlin. 
#figure(image("../images/type_primitif.png"))

La gestion de types plus complexes comme les objets demande plus de précaution et sont généralement transformé en type c++
#figure(image("../images/type_complexe.png"))

== Exemple
=== CMake
Ajout dans le fichier gradle:
```gradle
android {
    ...
    externalNativeBuild {
        cmake {
            path "src/main/cpp/CMakeLists.txt"
            version "3.31.16"
        }
    }
}
```
Contenu CMakeLists.txt:
```cmake
cmake_minimum_required(VERSION 3.22.1)

# Options de compilation
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_FLAGS_ RELEASE "${CMAKE_CXX_FLAGS_ RELEASE} -O3")

add_library(
  native-lib  # Nom de notre bibliothèque

  SHARED

  native-lib.cpp) # Fichier(s) source

# Pour trouver une autre bibliothèque, on utilise un autre find_library
find_library( 
  log-lib # Nom variable pour lier la bibliothèque
  log) # Nom de la bibliothèque à lier

target_link_libraries( 
  native-lib # Link les différents composants

  ${log-lib})
```

=== C++
```cpp
#include <jni.h>
extern "C"
JNIEXPORT jint JNICALL
Java_ch_heigvd_iict_dma_mynativeapplication_MainActivity_nativeSum(
  JNIEnv *env,
  jobject thiz,
  jint v1,
  jint v2) {
    return v1 + v2;
}
```

=== Kotlin
```kotlin
class MainActivity : AppCompatActivity() {
  companion object {
    init {
      System.loadLibrary("native-lib")
    }
  }

  private external fun nativeSum(v1: Int, v2: Int) : Int

  override fun onCreate(savedInstanceState: Bundle?) {
    val un = 1
    val deux = 2
    val resultat = nativeSum(un, deux)
  }
}
```

== Remarques
- Il est plutôt conseiller de ne pas utiliser appeler les méthodes c++ depuis l'UI thread
- Niveau d'optimisation, -0z est conseillé (taille + vitesse)
- Il y a une copie de notre libaririe partagée pour chaque architecture, donc la taille de l'application augmente.

= Instant App et App Clips

Les Instant Apps et App Clips sont des applications Android qui peuvent être utilisées sans installation complète. Elles permettent aux utilisateurs d'accéder rapidement à des fonctionnalités spécifiques d'une application sans avoir à la télécharger entièrement.
- Instant App -> Android, depuis octobre 2017
- App Clip -> iOS, depuis septembre 2020 (iOS 14)

Offre des fonction avancées car natives mais plus restrainte qu'une app normale; limité à 15Mo; Peux proposer de télécharger l'application complète et transférer les données de l'Instant App vers l'application complète.

== Utilisation
- Permettre de tester une application avant de l'installer
- Apperçu de jeux mobile