import 'dart:convert';

class Utilisateur {
  final int id;
  final String uuid;
  final String nom;
  final String prenom;
  final String? nomComplet;
  final String telephone;
  final String email;
  final String role;
  final bool actif;
  final String? photoUrl;
  final String? qrCodeUrl;
  final String? langue;
  final DateTime createdAt;
  final DateTime updatedAt;

  Utilisateur({
    required this.id,
    required this.uuid,
    required this.nom,
    required this.prenom,
    this.nomComplet,
    required this.telephone,
    required this.email,
    required this.role,
    required this.actif,
    this.photoUrl,
    this.qrCodeUrl,
    this.langue,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'],
      uuid: json['uuid'],
      nom: json['nom'],
      prenom: json['prenom'],
      nomComplet: json['nom_complet'],
      telephone: json['telephone'],
      email: json['email'],
      role: json['role'],
      actif: json['actif'] ?? false,
      photoUrl: json['photo_url'],
      qrCodeUrl: json['qr_code_url'],
      langue: json['langue'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  String get displayName => nomComplet ?? "$prenom $nom";
}

class Dossier {
  final int id;
  final String reference;
  final String statut;
  final String? description;
  final DateTime dateSoumission;
  final DateTime? dateEcheance;
  final TypeDemarche typeDemarche;
  final String? priorite;
  final List<dynamic>? documents;

  Dossier({
    required this.id,
    required this.reference,
    required this.statut,
    this.description,
    required this.dateSoumission,
    this.dateEcheance,
    required this.typeDemarche,
    this.priorite,
    this.documents,
  });

  factory Dossier.fromJson(Map<String, dynamic> json) {
    return Dossier(
      id: json['id'],
      reference: json['reference'] ?? json['numero'] ?? '',
      statut: json['statut'],
      description: json['description'],
      dateSoumission: json['date_soumission'] != null 
          ? DateTime.parse(json['date_soumission']) 
          : (json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now()),
      dateEcheance: json['date_echeance'] != null 
          ? DateTime.parse(json['date_echeance']) 
          : null,
      typeDemarche: json['type_demarche'] is String 
          ? TypeDemarche.fromJson(jsonDecode(json['type_demarche']))
          : TypeDemarche.fromJson(json['type_demarche']),
      priorite: json['priorite'],
      documents: json['documents'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'statut': statut,
      'description': description,
      'date_soumission': dateSoumission.toIso8601String(),
      'date_echeance': dateEcheance?.toIso8601String(),
      'type_demarche': typeDemarche.toJson(),
      'priorite': priorite,
    };
  }
}

class TypeDemarche {
  final int id;
  final String nom;
  final String categorie;

  TypeDemarche({
    required this.id,
    required this.nom,
    required this.categorie,
  });

  factory TypeDemarche.fromJson(Map<String, dynamic> json) {
    return TypeDemarche(
      id: json['id'],
      nom: json['nom'],
      categorie: json['categorie'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'categorie': categorie,
    };
  }
}
