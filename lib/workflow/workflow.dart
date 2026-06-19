import 'package:flutter/material.dart';
import 'package:sunudekk_mobile/workflow/status.dart';

class SuiviDossierScreen extends StatelessWidget {
 final DossierTracking dossier;

  const SuiviDossierScreen({super.key, required this.dossier});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const BackButton(color: Colors.black),
        title: const Text("Suivi de dossier",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 17)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDossierCard(),
                  const SizedBox(height: 20),
                  Text(dossier.typeDocument,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text("Déposé le ${dossier.dateDepot}",
                      style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  const SizedBox(height: 20),
                  _buildTimeline(),
                ],
              ),
            ),
          ),
        //  _buildBottomButton(context),
        ],
      ),
    );
  }

  Widget _buildDossierCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF176848), Color(0xFF176848)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("N° Dossier",
                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(dossier.numeroDossier,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(dossier.statutGlobal,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.sync, color: Colors.white.withOpacity(0.9), size: 16),
              const SizedBox(width: 6),
              Text("En cours d'instruction",
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: List.generate(dossier.steps.length, (i) {
        final step = dossier.steps[i];
        final isLast = i == dossier.steps.length - 1;
        return _buildTimelineItem(step, isLast);
      }),
    );
  }

  Widget _buildTimelineItem(TrackingStep step, bool isLast) {
    Color circleColor;
    Widget icon;

    switch (step.status) {
      case StepStatus.done:
        circleColor = const Color(0xFF176848);
        icon = const Icon(Icons.check, color: Colors.white, size: 14);
        break;
      case StepStatus.active:
        circleColor = const Color(0xFF1565C0);
        icon = Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        );
        break;
      case StepStatus.pending:
        circleColor = Colors.grey[300]!;
        icon = const SizedBox.shrink();
        break;
    }

    final isActive = step.status == StepStatus.active;
    final isPending = step.status == StepStatus.pending;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: icon,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: step.status == StepStatus.done ? const Color(0xFF176848) : Colors.grey[300],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isPending ? Colors.grey[500] : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isActive
                          ? const Color(0xFF1565C0)
                          : isPending
                              ? Colors.grey[500]
                              : Colors.grey[600],
                      fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}