= Exercice 8 : NDK (Native Development Kit) Android

== Objectif
Comparer les performances entre *Kotlin* et *C++* pour le tri d'un million d'entiers via le NDK Android.

== Architecture
- *MainActivity* : Interface avec boutons "Tri Kotlin" et "Tri C++"
- *IntListViewModel* : Logique métier avec `updateList()` (Kotlin) et `updateListNDK()` (C++)
- *native-lib.cpp* : Implémentation native du tri

== Implémentation clé

=== Côté Kotlin
```kotlin
// Tri Kotlin standard
fun updateList(nbr: Int = defaultNbrOfInt) {
    val time = measureTimeMillis {
        val sortedArray = rawArray.sorted()
    }
}

// Tri natif C++
fun updateListNDK(nbr: Int = defaultNbrOfInt) {
    val time = measureTimeMillis {
        val sortedArray = nativeSort(rawArray)
    }
}

private external fun nativeSort(numbers: IntArray): IntArray
```

=== Côté C++
```cpp
extern "C"
JNIEXPORT jintArray
Java_..._nativeSort(JNIEnv *env, jobject thiz, jintArray numbers) {
    // 1. Conversion JNI → std::vector
    std::vector<int> v = convert(env, numbers);
    
    // 2. Tri natif
    std::sort(v.begin(), v.end());
    
    // 3. Conversion std::vector → JNI
    return convert(env, v);
}
```

== Mesures de performance

L'implémentation mesure *3 opérations* :
1. *Conversion JNI → C++* : Marshalling des données
2. *Tri natif* : `std::sort()` pur
3. *Conversion C++ → JNI* : Marshalling de retour

== Points clés

=== Optimisations CMake
```cmake
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -O3")
```

=== Structure APK
```
lib/
├── arm64-v8a/libnative-lib.so    # ARM 64-bit
├── armeabi-v7a/libnative-lib.so  # ARM 32-bit
└── x86_64/libnative-lib.so       # Intel/Émulateurs
```

== Avantages vs Inconvénients

=== ✅ Avantages
- Performance pour calculs intensifs
- Réutilisation de code C++ existant

=== ❌ Inconvénients  
- Complexité JNI
- Overhead des conversions
- Debugging plus difficile

== Résultats attendus
1. Tri C++ plus rapide que Kotlin
2. Conversions JNI ajoutent un overhead
3. Gain global dépend du ratio calcul/conversion
4. Optimisation compiler cruciale pour les performances