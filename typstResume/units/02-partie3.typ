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
Java_ch_heigvd_iict_dma_mynativeapplication
_MainActivity_nativeSum(
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

Offre des fonctions avancées car natives mais plus restraintes qu'une app normale; limitées à 15Mo; Peux proposer de télécharger l'application complète et transférer les données de l'Instant App vers l'application complète.

== Utilisation
- Permettre de tester une application avant de l'installer
- Apperçu de jeux mobile

= Cross-platefrormes
== Porquoi?
Outils différents entre Android et iOS, philosophie différente, besoin de deux équipes de développement, etc.

Pour répondre à ce besoins, différente approches ont émergées, allant de la simple webview à des solutions plus complexes. Les prmières solutions était proches des technologies web afin de permettre aux dev. web de facilement les utiliser, mais les dernières solutions sont plus proches des applications natives afin d'avoir accès à plus de fonctionnalités spécifiques des mobiles.

#figure(image("../images/cross_plateform.png"))

== App web
Les applications web sont des sites web qui se comportent comme des applications. Elles sont accessibles via un navigateur et peuvent être installées sur l'écran d'accueil du téléphone. Elles utilisent des technologies web standard (HTML, CSS, JavaScript) et sont exécutées dans un navigateur. Malheuresement, pas tous les navigateurs supportent toutes les librairies JavaScript.
#figure(image("../images/app_web.png"))

== Progressive Web App (PWA)
Application web pouvant être "installée" sur le téléphone. Une web app est considérée comme une PWA si elle peut fonctionner en l'absence de réseau et qu'un raccourci peut être ajouté à l'écran d'accueil. Pour cela, elles doivent avoir un fichier manifest.json décrivant l'application et un service worker pour gérer le cache et les notifications push.

Sur iOS, les PWA sont limitées par le navigateur Safari et ne peuvent pas accéder à toutes les fonctionnalités du téléphone.

== Apache Cordova
Apache Cordova est un framework qui permet de créer des applications mobiles en utilisant des technologies web (HTML, CSS, JavaScript). La web app est empaquetée dans une application native qui utilise une webview pour afficher le contenu. Cordova fournit des plugins pour accéder aux fonctionnalités natives du téléphone (caméra, GPS, etc.). 
#figure(image("../images/cordova.png", height: 120pt))

== Solutions basée sur une VM
Application contenant une vm executant le code de l'application, avec un moteur de rendu graphique ainsi que des modules permettant d'accéder aux fonctionnalités natives du téléphone. Permt d'avoir un seul code pour android et iOS mais également d'autre plateforme (Windows, Mac, etc.).
#figure(image("../images/vm.png"))

Il existe principalement trois solutions:
- React Native, Google, Dart, Liscence BSD
- Flutter, Meta (Facebook), JavaScript, License MIT
- .NET MAUI (successeur de Xamarin), Microsoft, C\#, License MIT
Les moteurs de jeux comme unity permettent également des applications cross-plateforme.

=== React Native
React Native permet de créer une UI qui sera ensuite mappée vers les widgets natifs de la plateforme. Le code JavaScript sera interprété par une VM JavaScript. 
#figure(image("../images/react.png"))

La VM est stockée sous forme de librairies partagées (fichiers .so), ce qui a pour conséquence d'avoir une VM pour chaque architecture. Il existe des packages pour accéder aux fonctionnalités natives du téléphone de manière unifiée.

Comme le code JS est interprété, il est possible de mettre à jour l'application sans passer par le store, mais il est interdit d'ajouter des fonctionnalités ou de changer significativement l'app.

=== Flutter
Initialement déveoppé pour les mobiles, aujourd'hui il permet également le développment pour d'autres plateformes comme Linux, MacOS, Windows, Fuchsia ou le web. Principaux composants:
- Dart: langage à la Java, compilation just-in-time (JIT) pour le développement et sur Desktop, et compilation ahead-of-time (AOT) pour la production.

- Foundation Library: Ensemble d'API pour construire app
- Skia: Moteur graphique
- Widgets: 2 collections (Material et Cupertino) pour ressembler aux applications Android et iOS.
- Development Tools: Outils pour le développement, le débogage et la compilation des applications.

Il existe 4 manières d'exécuter du code Dart:
- Natif (code compilé pour une plateforme spécifique)
- Autonome (utilisation de la VM Dart)
- Compilation AOT (approche utilisée par Flutter pour Android et iOS)
- Transpilation en JS (utilisée pour le web)

Mise à disposition par la commmunauté de package pour accéder aux fonctionnalités natives du téléphone.
#figure(image("../images/flutter1.png"))
#figure(image("../images/flutter2.png"))

== Kotlin Multiplatform Mobile (KMM)
Nouvelle approche en beta proposée par JetBrains. Permet de partager du code entre Android et iOS en utilisant Kotlin. Le code partagé est compilé en code natif pour chaque plateforme. KMM permet de partager la logique métier, les modèles de données et les tests, tout en permettant d'utiliser les API natives de chaque plateforme.

Possibilité de développer qu'une partie des composants en kmm et le reste en taif pour Android et iOS selon les besoins. Est actuellement en train d'être complété par Compose Multiplateforme qui permettra de mettre en commun également l'UI.
#figure(image("../images/kmm.png"))
