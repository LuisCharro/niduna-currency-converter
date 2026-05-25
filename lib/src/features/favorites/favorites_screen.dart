import 'package:flutter/material.dart';

import '../../shared/widgets/bottom_tab_frame.dart';
import '../../shared/widgets/canvas_background.dart';
import '../convert/presentation/convert_controller.dart';
import 'data/favorites_store.dart';
import 'domain/favorite_pair.dart';
import 'widgets/favorites_tab_body.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    required this.favoritesStore,
    required this.controller,
    required this.onNavigateToConvert,
    super.key,
  });

  final FavoritesStore favoritesStore;
  final ConvertController controller;
  final void Function(String base, String quote) onNavigateToConvert;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: CanvasBackground(
        child: ListenableBuilder(
          listenable: Listenable.merge([favoritesStore, controller]),
          builder: (context, _) => BottomTabFrame(
            body: FavoritesTabBody(
              pairs: favoritesStore.pairs,
              isFull: favoritesStore.isFull,
              snapshot: controller.snapshot,
              onOpen: _openPair,
              onRemove: controller.removeFavoritePair,
              onAdd: () => onNavigateToConvert('', ''),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openPair(FavoritePair pair) async {
    await controller.openFavoritePair(pair);
    onNavigateToConvert(pair.base, pair.quote);
  }
}
