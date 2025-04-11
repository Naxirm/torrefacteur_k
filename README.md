# Le Torréfacteur K

[Lien vers le Github](https://github.com/Naxirm/torrefacteur_k/)

<div align="center">
  <img src="lib/assets/torrefacteur_logo.png" alt="logo_torrefacteur" title="logo_torrefacteur" width="400" height="400" />
</div>

## Sujet d'examen
[Lien vers le sujet d'examen](sujet.pdf)

## Prérequis

- Flutter SDK
- Un émulateur Android/iOS ou un appareil connecté

## Lancement du projet

Commencez par cloner le projet:
- `git clone https://github.com/Naxirm/torrefacteur_k.git`

A la racine du projet, installez les dépendances:
- `flutter pub get`

Lancez un émulateur ou utilisez votre mobile en mode dev pour pouvoir lancer l'application sur celui-ci.

Lancez l'application:
- `flutter run`

## Maquettes du projet

[Lien vers les maquettes du projet](maquettes.pdf)

## Fonctionnalités du projet
- Connexion / Inscription
- Plantation des différentes graines de kafé et sélection du champ sur lequel planter (chaque champ a une spécificité, rendementx2, temps/2 ou neutre).
- Récolte des grains plantés (avec décompte de temps et malus appliqué sur le rendement en fonction du temps écoulé).
- Quand un grain est récolté, il rapporte deux fois la somme qu'il a coûté.
- Possibilité de créer des assemblages de kafé (minimum 1kg)

## Script SQL pour ajout en BDD

`
CREATE TABLE Farm (
    id VARCHAR(255) PRIMARY KEY,
    farmName VARCHAR(255) NOT NULL
);

CREATE TABLE AppUser (
    id VARCHAR(255) PRIMARY KEY,
    firstName VARCHAR(255) NOT NULL,
    lastName VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    deeVee INT DEFAULT 0,
    goldGrains INT DEFAULT 0,
    farmId VARCHAR(255),
    FOREIGN KEY (farmId) REFERENCES Farm(id) ON DELETE SET NULL
);

CREATE TABLE Field (
    id VARCHAR(255) PRIMARY KEY,
    capacity INT DEFAULT 4,
    farmId VARCHAR(255),
    specialty VARCHAR(255) DEFAULT 'Neutre',
    FOREIGN KEY (farmId) REFERENCES Farm(id) ON DELETE CASCADE
);

CREATE TABLE CoffeeType (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    growthTime INT DEFAULT 0,
    cost INT DEFAULT 0,
    weight DOUBLE DEFAULT 0,
    taste INT DEFAULT 0,
    bitterness INT DEFAULT 0,
    content INT DEFAULT 0,
    smell INT DEFAULT 0,
    avatarUrl VARCHAR(255) DEFAULT ''
);

CREATE TABLE CoffeePlant (
    id VARCHAR(255) PRIMARY KEY,
    typeId VARCHAR(255),
    plantingTime DATETIME,
    harvestTime DATETIME,
    fieldId VARCHAR(255),
    userId VARCHAR(255),
    FOREIGN KEY (typeId) REFERENCES CoffeeType(id) ON DELETE CASCADE,
    FOREIGN KEY (fieldId) REFERENCES Field(id) ON DELETE CASCADE,
    FOREIGN KEY (userId) REFERENCES AppUser(id) ON DELETE CASCADE
);

CREATE TABLE DriedCoffee (
    id VARCHAR(255) PRIMARY KEY,
    typeId VARCHAR(255),
    weight DOUBLE DEFAULT 0,
    userId VARCHAR(255),
    FOREIGN KEY (typeId) REFERENCES CoffeeType(id) ON DELETE CASCADE,
    FOREIGN KEY (userId) REFERENCES AppUser(id) ON DELETE CASCADE
);

CREATE TABLE Blend (
    id VARCHAR(255) PRIMARY KEY,
    userId VARCHAR(255),
    totalWeight DOUBLE DEFAULT 0,
    taste DOUBLE DEFAULT 0,
    bitterness DOUBLE DEFAULT 0,
    content DOUBLE DEFAULT 0,
    smell DOUBLE DEFAULT 0,
    submitted BOOLEAN DEFAULT FALSE,
    submissionDate DATETIME,
    FOREIGN KEY (userId) REFERENCES AppUser(id) ON DELETE CASCADE
);

CREATE TABLE BlendComponents (
    blendId VARCHAR(255),
    coffeeTypeId VARCHAR(255),
    weight DOUBLE DEFAULT 0,
    PRIMARY KEY (blendId, coffeeTypeId),
    FOREIGN KEY (blendId) REFERENCES Blend(id) ON DELETE CASCADE,
    FOREIGN KEY (coffeeTypeId) REFERENCES CoffeeType(id) ON DELETE CASCADE
);

`

## MCD

[Lien vers le MCD](mcd.png)
