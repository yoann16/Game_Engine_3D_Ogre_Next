# Engine Ogre-Next

## Prérequis
- CMake 3.5.1+
- Visual Studio 2022
- Ogre-Next installé localement

## Installation
* Suivre le tutoriel : [lien vers le tuto Notion](https://www.notion.so/OGRE-Instalation-2b97d6bb0368806090d1e2015e3994af)

* Vous devez Installer Visual Studio C++

* Vous devez Installer CMake

* Vous devez Installer Python 3

* Vous devez Installer Ogre-Next

* Puis liez Game_Engine_3D_Ogre_Next\Dependencies à votre installation Ogre

### 1. Installer Ogre-Next

* Installer dans `C:\Ogre_Next\` (ou autre emplacement)

### 2. Créer le lien symbolique
Ouvrez l'invite de commande en tant qu'administrateur
Puis ensuite aller dans votre repo git 
```cmd
cd Game_Engine_3D_Ogre_Next\Dependencies
mklink /D Ogre C:\Ogre_Next\Ogre\ogre-next
```
(mklink /D Ogre <l'emplacement de votre dossier ogre-next>)

### 3. Compiler
```cmd
build.bat
```

### 4. Ouvrir dans Visual Studio
```
build\Engine_Ogre_Next.sln
```

### 5. Pour Plus d'information

#### Voici le Git d'Ogre-Next : 
[Git Ogre-Next](https://github.com/OGRECave/ogre-next)
Vous trouverez toute la documentation que vous avez besoin