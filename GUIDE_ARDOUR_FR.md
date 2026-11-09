# Bien démarrer avec Ardour et Hub Studio

## 1. Lancer Ardour sous Windows

Depuis PowerShell, lancer le build local avec :

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\run-ardour-msvc.ps1"
```

`-ExecutionPolicy Bypass` ne s'applique qu'à ce processus PowerShell; la stratégie
de sécurité Windows n'est pas modifiée. Le script configure les DLL, les backends
audio et les ressources d'Ardour.

## 2. Régler l'audio

Dans la fenêtre **Audio/MIDI Setup** :

1. Choisir **PortAudio** comme système audio et **Windows WASAPI** comme pilote.
2. Dans **Input Device**, choisir le vrai microphone ou l'entrée de l'interface.
   Ne pas choisir une entrée qui porte la mention `[Loopback]` : elle capture le
   son de sortie du PC et ne correspond pas au micro.
3. Dans **Output Device**, choisir le casque ou les haut-parleurs à utiliser.
4. Utiliser **48 kHz** pour commencer. Un buffer de **512** ou **1024 samples** est
   un réglage de départ stable; augmenter le buffer si le son craque.
5. Cliquer sur **Start**. Le statut doit passer à **Running**.

Si le micro n'apparaît pas, vérifier qu'il est sélectionné dans **Paramètres
Windows → Système → Son → Entrée** et que l'interface est reliée au PC par la
connexion qui transporte son entrée audio.

## 3. Créer une session

1. Dans la fenêtre de démarrage, choisir **New Session**.
2. Donner un nom simple au projet et choisir un dossier facile à retrouver.
3. Choisir le format stéréo par défaut pour une chanson destinée à l'écoute au
   casque, puis créer la session.
4. Enregistrer régulièrement avec **Ctrl+S**.

Une session Ardour contient les pistes, les régions audio/MIDI, le mixage,
l'automation et les réglages du projet. Garder les fichiers audio importés dans
le dossier de session permet de déplacer ou sauvegarder le projet plus facilement.

## 4. Enregistrer une voix ou un instrument

1. Dans le menu **Track**, choisir **Add Track, Bus or VCA**.
2. Ajouter une piste **Audio** mono pour un micro ou un instrument mono.
3. Sur la piste, ouvrir le sélecteur d'entrée et choisir le port du bon micro ou
   de la bonne entrée de l'interface.
4. Activer l'armement d'enregistrement de la piste; vérifier que son vumètre
   réagit quand on parle ou joue.
5. Activer le bouton d'enregistrement du transport, puis **Play** pour enregistrer.
6. Désarmer la piste après la prise et écouter le résultat au casque.

Pour plusieurs prises, enregistrer une piste à la fois et conserver les versions
réussies avant de supprimer quoi que ce soit.

## 5. Importer, mixer et exporter

- **Importer un fichier audio** : utiliser la commande d'import du menu **Session**
  et choisir de créer une nouvelle piste si nécessaire.
- **Éditer** : dans l'éditeur, déplacer et découper les régions; les modifications
  restent non destructives.
- **Mixer** : ouvrir la fenêtre **Mixer** depuis le menu **Window**. Régler le
  volume, le panoramique, les effets et les départs de chaque piste.
- **Exporter** : utiliser la commande d'export audio du menu **Session**, choisir
  la plage, le format et le dossier, puis vérifier le fichier exporté au casque.

## 6. Démarrer un mixage 8D

Dans **New Session**, choisir **Hub: 8D Spatial Mix**. Ce modèle prépare les pistes
mono de sources, les retours d'effets, la piste de référence et une piste stéréo
de destination. Il ne crée pas automatiquement un effet 8D.

Pour produire le mouvement spatial, activer un **Surround Master**, router les
sources vers ce master, utiliser leur panner surround 3D et automatiser leur
position dans le temps. Activer le rendu binaural pour les sources qui doivent
bouger, puis contrôler le résultat stéréo exporté avec un casque. Garder une
piste de référence non traitée pour comparer.

Un simple panoramique gauche/droite n'est pas un rendu binaural 8D. Confirmer les
réglages du master surround et du rendu binaural avant de présenter l'export comme
un mixage 8D.

Les quatre autres modèles Hub disponibles sont **Vocal Recording**, **Podcast**,
**Live Band** et **Stem Mixing**. Ils préparent des pistes nommées; il faut ensuite
choisir les entrées de l'interface et armer les pistes voulues.
