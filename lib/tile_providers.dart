import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

TileLayer get landscapeTileLayer => TileLayer(
      urlTemplate:
          'https://api.maptiler.com/maps/landscape/{z}/{x}/{y}.png?key=6gKs6cpriD286xFIr1Ml',
      userAgentPackageName: 'dev.cnhtrackme.testing',
      // Use the recommended flutter_map_cancellable_tile_provider package to
      // support the cancellation of loading tiles.
      tileProvider: CancellableNetworkTileProvider(),
    );
