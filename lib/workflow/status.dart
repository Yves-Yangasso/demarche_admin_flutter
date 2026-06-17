import '../models/models.dart';

enum StepStatus { done, active, pending }

class TrackingStep {
  final String title;
  final String subtitle;
  final StepStatus status;

  TrackingStep({required this.title, required this.subtitle, required this.status});
}

class DossierTracking {
  final String numeroDossier;
  final String statutGlobal;
  final String typeDocument;
  final String dateDepot;
  final List<TrackingStep> steps;
  final Dossier? originalDossier;

  DossierTracking({
    required this.numeroDossier,
    required this.statutGlobal,
    required this.typeDocument,
    required this.dateDepot,
    required this.steps,
    this.originalDossier,
  });

  factory DossierTracking.fromDossier(Dossier dossier) {
    return DossierTracking(
      numeroDossier: dossier.reference,
      statutGlobal: dossier.statut,
      typeDocument: dossier.typeDemarche.nom,
      dateDepot: "${dossier.dateSoumission.day}/${dossier.dateSoumission.month}/${dossier.dateSoumission.year}",
      steps: [
        TrackingStep(
          title: "Soumission",
          subtitle: "Dossier reçu le ${dossier.dateSoumission.day}/${dossier.dateSoumission.month}",
          status: StepStatus.done,
        ),
        TrackingStep(
          title: "Instruction",
          subtitle: "Analyse technique en cours",
          status: dossier.statut.toLowerCase() == 'en_cours' ? StepStatus.active : StepStatus.done,
        ),
        TrackingStep(
          title: "Finalisation",
          subtitle: "Décision finale",
          status: dossier.statut.toLowerCase() == 'cloture' || dossier.statut.toLowerCase() == 'validé' ? StepStatus.done : StepStatus.pending,
        ),
      ],
      originalDossier: dossier,
    );
  }
}