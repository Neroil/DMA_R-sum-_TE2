= Lecture de tags NFC

== Exercice 1 : Lecture avec activité active

=== Décodage NDEF - Format RTD_URI
*Byte 0* : Préfixe URI
- `0x01` = `http://www.`
- `0x02` = `https://www.` 
- `0x03` = `http://`
- `0x04` = `https://`

*Bytes suivants* : Reste URI en UTF-8

Donc ce qu'il fallait faire :

Pattern match le premier byte pour déterminer le préfixe, puis concatène le reste de l'URI en décodant en UTF-8.
```kotlin
private fun decodeUriRecord(record: NdefRecord): String {
    val payload = record.payload
    val prefix = when (payload[0]) {
        0x01.toByte() -> "http://www."
        0x02.toByte() -> "https://www."
        0x03.toByte() -> "http://"
        0x04.toByte() -> "https://"
        else -> ""
    }
    return prefix + String(payload, 1, payload.size - 1, Charsets.UTF_8)
}
```

=== Décodage NDEF - Format RTD_TEXT
*Byte 0* : Flags
- Bit 7 : Encodage (0=UTF-8, 1=UTF-16)
- Bits 5-0 : Longueur code langue

*Code langue* : ASCII (ex: "fr", "fr-CH")
*Contenu* : Texte en UTF-8/UTF-16 selon flag


== Exercice 2 : Lecture app inactive
Modifier pour ouverture automatique activité lors scan NFC. *Éviter instances multiples*.

_Ce qu'il fallait faire :_

Inidiquer dans le manifest l'activité à ouvrir lors du scan NFC, et gérer l'intent dans l'activité pour afficher le contenu.
```xml
 <activity
            <...>
            <intent-filter>
                <action android:name="android.nfc.action.NDEF_DISCOVERED" />
                <category android:name="android.intent.category.DEFAULT" />
                <data android:mimeType="text/plain" />
            </intent-filter>
        </activity>
```

*Et dans MainActivity.kt* :
```kotlin
class MainActivity : AppCompatActivity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // ... setup UI
        
        // Traiter le tag si app lancée par NFC
        handleNfcIntent(intent)
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // Nouveau tag scanné (app déjà active)
        handleNfcIntent(intent)
    }
    
    private fun handleNfcIntent(intent: Intent) {
        if (intent.action == NfcAdapter.ACTION_NDEF_DISCOVERED) {
            val rawMessages = intent.
                getParcelableArrayExtra(NfcAdapter.EXTRA_NDEF_MESSAGES)
            rawMessages?.let { messages ->
                val ndefMessages = messages.map { it as NdefMessage }
                // Traiter les messages NDEF...
                processNdefMessages(ndefMessages)
            }}}}
```






