/// Représente une pièce justificative ajoutée par l'utilisateur.
class PieceJustificative {
  final String nom;
  final double tailleMo;
  const PieceJustificative({required this.nom, required this.tailleMo});
}

/// Contient toutes les données saisies au fil des 4 étapes du formulaire.
class DemandeModel {
  // Étape 1 — Type de demande
  String? categorie;
  String? document;
  String? objectif;

  // Étape 2 — Informations personnelles
  String nomComplet = '';
  DateTime? dateNaissance;
  String lieuNaissance = '';
  String? sexe;
  String numeroIdentification = '';
  String email = '';
  String telephone = '';
  String adressePostale = '';

  // Étape 3 — Détails de la demande
  String? motif;
  String description = '';
  String autorite = '';
  String? urgence;
  final List<PieceJustificative> pieces = [];

  // Étape 4 — Vérification et envoi
  bool certifie = false;
}

/// Catégories de documents et leurs documents associés (étape 1).
const Map<String, List<String>> categories = {
  'État civil': [
    'Extrait de naissance',
    'Extrait de mariage',
    'Extrait de décès',
    'Certificat de vie',
  ],
  'Identité': [
    "Carte nationale d'identité",
    'Passeport',
    'Certificat de nationalité',
  ],
  'Famille': [
    'Livret de famille',
    'Certificat de filiation',
    'Acte de reconnaissance',
  ],
  'Éducation': [
    'Relevé de notes',
    'Diplôme',
    'Certificat de scolarité',
  ],
  'Social / Santé': [
    'Carnet de santé',
    "Attestation d'assurance",
    'Certificat médical',
  ],
  'Logement': [
    "Certificat d'hébergement",
    'Permis de construire',
    'Attestation de domicile',
  ],
  'Fiscalité': [
    "Avis d'imposition",
    'Quitus fiscal',
    'Attestation fiscale',
  ],
  'Justice': [
    'Extrait de casier judiciaire',
    'Certificat de non-condamnation',
  ],
  'Autre': [
    'Autre document',
  ],
};

const List<String> objectifs = [
  'Usage administratif',
  'Usage personnel',
  "Voyage à l'étranger",
  'Démarche bancaire',
  'Emploi',
  'Autre',
];

const List<String> motifs = [
  "Demande d'emploi",
  'Inscription scolaire',
  'Démarche bancaire',
  'Renouvellement de document',
  "Voyage à l'étranger",
  'Autre',
];

const List<String> niveauxUrgence = [
  'Normale',
  'Urgente',
  'Très urgente',
];
