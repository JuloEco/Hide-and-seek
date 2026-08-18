# 🎮 Hide and Seek - Jeu Roblox

Un jeu **Hide and Seek** (cache-cache) complet pour **Roblox Studio** développé en **LuaU**.

## 🌟 Fonctionnalités

✅ **Personnages en BLANC** - Tous les joueurs apparaissent en blanc comme demandé
✅ **Système de camouflage avancé** :
   - Changement de couleur (20+ couleurs disponibles)
   - Changement de pose (Debout, Assis, Allongé, Accroupi)
   - Transformation en objet de la pièce
   - Création de formes géométriques

✅ **3 salles personnalisables** :
   - Salle par défaut (inclus)
   - Possibilité d'ajouter des salles supplémentaires

✅ **Phases de jeu** :
   - **Préparation** (3 minutes) : Cacheurs se camouflent, chercheur jouent au mini-jeu
   - **Cache** (30 secondes) : Cacheurs se placent
   - **Recherche** (5 minutes) : Chercheur doivent trouver les cacheurs

✅ **Mini-jeu pour les chercheur** pendant la phase de préparation
✅ **6 modificateurs de salle** (no_stay, color_change, invisibility, etc.)
✅ **Interface utilisateur complète** avec menu, timer, scores
✅ **Système de détection** à 5 studs
✅ **Multijoueur** géré automatiquement

## 📥 Installation

### Méthode 1 : Utiliser l'Installer (RECOMMANDÉ)

1. **Ouvrez Roblox Studio**
2. **Créez un nouveau jeu** (File > New > Baseplate)
3. **Dans l'Explorateur** :
   - Cliquez droit sur `ServerScriptService` → **Insert Object** → **Script**
   - Nommez-le `Installer`
   - **Copiez le contenu** du fichier `Installer.lua` de ce dépôt
4. **Cliquez sur ▶️ Play** (une seule fois)
5. **Le jeu s'installe automatiquement**
6. **Supprimez le script Installer** (il ne sert plus à rien)
7. **Re-cliquez sur ▶️ Play** pour jouer

### Méthode 2 : Installation manuelle

1. **Ouvrez Roblox Studio**
2. **Créez un nouveau jeu**
3. **Copiez les fichiers** dans les dossiers correspondants :
   
   | Fichier | Dossier de destination | Type |
   |---------|------------------------|------|
   | `MainGameServer.lua` | `ServerScriptService` | Script |
   | `GameModule.lua` | `ReplicatedStorage` | ModuleScript |
   | `RoomModule.lua` | `ReplicatedStorage` | ModuleScript |
   | `CamouflageModule.lua` | `ReplicatedStorage` | ModuleScript |
   | `ModifiersModule.lua` | `ReplicatedStorage` | ModuleScript |
   | `GameClient.lua` | `StarterPlayerScripts` | Script |
   | `DefaultRoom.lua` | `ServerStorage/Rooms` | ModuleScript |

4. **Cliquez sur ▶️ Play** pour démarrer le jeu

## 🎮 Comment jouer

### Menu principal
- Sélectionnez une salle dans la liste
- Cliquez sur **"Jouer"** pour commencer

### En jeu
- **WASD / Flèches** : Se déplacer
- **Échap** : Fermer les panneaux
- **Bouton "Retour au menu"** : Quitter la partie

### Pour les cacheurs
- **Ouvrez le panneau de camouflage** (bouton en bas)
- Sélectionnez une **couleur**, une **pose**, ou transformez-vous en **objet/formes**
- **Restez immobile** pendant la phase de recherche

### Pour les chercheur
- **Trouvez tous les cacheurs** en vous approchant à moins de 5 studs
- **Les cacheurs mal camouflés** seront détectés automatiquement

## 📁 Structure du projet

```
HideAndSeek_Roblox_Git/
├── Installer.lua              # Script d'installation automatique
├── ServerScriptService/
│   └── MainGameServer.lua     # Logique principale du serveur
├── ReplicatedStorage/
│   ├── GameModule.lua         # Configuration et utilitaires
│   ├── RoomModule.lua         # Gestion des salles
│   ├── CamouflageModule.lua   # Mécaniques de camouflage
│   └── ModifiersModule.lua    # Modificateurs de salle
├── StarterPlayerScripts/
│   └── GameClient.lua         # Logique côté client
└── ServerStorage/
    └── Rooms/
        └── DefaultRoom.lua    # Salle par défaut
```

## 🛠️ Personnalisation

### Ajouter une nouvelle salle

1. **Créez un nouveau ModuleScript** dans `ServerStorage/Rooms/`
2. **Nommez-le** (ex: `ForestRoom.lua`)
3. **Utilisez ce modèle** :

```lua
local ServerStorage = game:GetService("ServerStorage")

local roomsFolder = ServerStorage:FindFirstChild("Rooms") or Instance.new("Folder")
roomsFolder.Name = "Rooms"
roomsFolder.Parent = ServerStorage

local myRoom = Instance.new("Model")
myRoom.Name = "MaSalle"

-- Ajoutez des parts (murs, sol, objets)
local floor = Instance.new("Part")
floor.Name = "Floor"
floor.Size = Vector3.new(100, 1, 100)
floor.Position = Vector3.new(0, -0.5, 0)
floor.Anchored = true
floor.Color = Color3.new(0.2, 0.4, 0.2)  -- Vert
floor.Material = Enum.Material.Grass
floor.Parent = myRoom

-- Ajoutez des spawn points
local spawn1 = Instance.new("SpawnLocation")
spawn1.Position = Vector3.new(-30, 1, -30)
spawn1.Size = Vector3.new(4, 1, 4)
spawn1.Parent = myRoom

myRoom.Parent = roomsFolder
```

4. **La salle apparaîtra automatiquement** dans le menu

### Modifier les couleurs disponibles

Éditez `ReplicatedStorage/GameModule.lua` et modifiez la table `Config.Colors` :

```lua
Colors = {
    White = Color3.new(1, 1, 1),
    Red = Color3.new(1, 0, 0),
    -- Ajoutez vos couleurs ici
    MyColor = Color3.new(0.5, 0.3, 0.8)
}
```

### Ajouter des modificateurs

Éditez `ReplicatedStorage/ModifiersModule.lua` et ajoutez de nouveaux modificateurs :

```lua
{
    id = "mon_modificateur",
    name = "Mon Modificateur",
    description = "Description du modificateur",
    duration = 20,
    category = "mouvement",
    apply = function(player)
        -- Code à exécuter quand le modificateur est activé
    end,
    remove = function(player)
        -- Code à exécuter quand le modificateur est désactivé
    end
}
```

## 🎯 Règles du jeu

1. **Phase de préparation (3 min)** :
   - Les cacheurs se déplacent et se camouflent
   - Les chercheur jouent à un mini-jeu (à implémenter)

2. **Phase de cache (30 sec)** :
   - Les cacheurs doivent rester immobiles
   - Les chercheur ne peuvent pas encore chercher

3. **Phase de recherche (5 min)** :
   - Les chercheur doivent trouver tous les cacheurs
   - Un cacheur est détecté si un chercheur s'approche à moins de 5 studs
   - Un cacheur bien camouflé (couleur similaire aux objets) ne sera pas détecté

4. **Fin de partie** :
   - Tous les cacheurs sont trouvés OU le temps est écoulé
   - Affichage des scores

## 🏆 Système de score

- **Chercheur** : +100 points par cacheur trouvé
- **Cacheur** : +1 point par seconde non détecté (à implémenter)

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :
- Signaler des bugs
- Proposer de nouvelles fonctionnalités
- Créer de nouvelles salles
- Améliorer l'interface utilisateur

## 📄 Licence

Ce projet est sous licence **MIT**. Vous êtes libre de l'utiliser, le modifier et le distribuer.

---

**Créé avec ❤️ par Vibe Code (Mistral AI)**
**Version : 1.0.0**
**Date : Août 2024**
