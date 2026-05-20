import 'package:flutter/material.dart';

import '../../../core/monetization/monetization_controller.dart';
import '../../../core/rates/provider_usage_info.dart';
import 'dev_ads_status_card.dart';
import 'dev_entitlements_panel.dart';
import 'provider_flow_cards.dart';
import 'provider_matrix.dart';
import 'provider_profile_card.dart';

class DevSandboxSection extends StatelessWidget {
  const DevSandboxSection({required this.monetization, super.key});

  final MonetizationController monetization;

  @override
  Widget build(BuildContext context) {
    final usage = ProviderUsageInfo.fromBuildConfig();
    return Column(
      children: <Widget>[
        ProviderProfileCard(info: usage),
        const SizedBox(height: 8),
        ProviderFlowCards(roles: usage.roles),
        ProviderMatrix(rows: usage.matrix),
        const SizedBox(height: 8),
        DevEntitlementsPanel(monetization: monetization),
        const SizedBox(height: 8),
        DevAdsStatusCard(adsEnabled: monetization.adsEnabled),
      ],
    );
  }
}
