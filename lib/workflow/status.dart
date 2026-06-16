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

  DossierTracking({
    required this.numeroDossier,
    required this.statutGlobal,
    required this.typeDocument,
    required this.dateDepot,
    required this.steps,
  });
}