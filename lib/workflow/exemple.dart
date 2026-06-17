import 'package:sunudekk_mobile/workflow/status.dart';

final exampleDossier = DossierTracking(
  numeroDossier: "D2026-001245",
  statutGlobal: "En cours",
  typeDocument: "Extrait de naissance",
  dateDepot: "10/06/2026 à 14:30",
  steps: [
    TrackingStep(title: "Dépôt", subtitle: "10/06/2026 14:30", status: StepStatus.done),
    TrackingStep(title: "Enregistrement", subtitle: "10/06/2026 14:42", status: StepStatus.done),
    TrackingStep(title: "Instruction", subtitle: "En cours", status: StepStatus.active),
    TrackingStep(title: "Avis partenaires", subtitle: "En attente", status: StepStatus.pending),
    TrackingStep(title: "Validation", subtitle: "En attente", status: StepStatus.pending),
    TrackingStep(title: "Décision & signature", subtitle: "En attente", status: StepStatus.pending),
    TrackingStep(title: "Délivrance", subtitle: "En attente", status: StepStatus.pending),
  ],
);