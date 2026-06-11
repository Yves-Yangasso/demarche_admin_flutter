import 'dart:convert';

class Utilisateur {
  final int id;
  final String nom;
  final String prenom;
  final String telephone;
  final String? email;
  final String role;
  final String? uuid;

  Utilisateur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    this.email,
    required this.role,
    this.uuid,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      telephone: json['telephone'],
      email: json['email'],
      role: json['role'],
      uuid: json['uuid'],
    );
  }

  String get nomComplet => "$prenom $nom";
}

class Dossier {
  final int id;
  final String reference;
  final String statut;
  final String? description;
  final DateTime dateSoumission;
  final DateTime? dateEcheance;
  final TypeDemarche typeDemarche;

  Dossier({
    required this.id,
    required this.reference,
    required this.statut,
    this.description,
    required this.dateSoumission,
    this.dateEcheance,
    required this.typeDemarche,
  });

  factory Dossier.fromJson(Map<String, dynamic> json) {
    return Dossier(
      id: json['id'],
      reference: json['reference'] ?? json['numero'] ?? '',
      statut: json['statut'],
      description: json['description'],
      dateSoumission: DateTime.parse(json['date_soumission']),
      dateEcheance: json['date_echeance'] != null 
          ? DateTime.parse(json['date_echeance']) 
          : null,
      typeDemarche: json['type_demarche'] is String 
          ? TypeDemarche.fromJson(jsonDecode(json['type_demarche']))
          : TypeDemarche.fromJson(json['type_demarche']),
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
      'type_demarche': jsonEncode(typeDemarche.toJson()),
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
