import 'package:flutter/material.dart';

import '../models/local.dart';
import '../services/local_repository.dart';
import 'place_art.dart';
import 'shared.dart';

class LocalCard extends StatelessWidget {
  final double height;
  final Local local;
  final LocalRepository repository;
  final VoidCallback onTap;
  final void Function(String)? onMenu;
  final VoidCallback? onLongPress;
  const LocalCard({
    super.key,
    required this.local,
    required this.repository,
    required this.onTap,
    this.height = 106,
    this.onMenu,
    this.onLongPress,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    label:
        '${local.nome}, ${local.categoria}, ${decimal(local.distancia)} km, avaliação ${decimal(local.avaliacao)}',
    button: true,
    child: SizedBox(
      height: height,
      child: Material(
        color: papel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
          side: const BorderSide(color: linha, width: .7),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: SizedBox(
                    width: 84,
                    height: 90,
                    child: PlaceArt(categoria: local.categoria),
                  ),
                ),
                const SizedBox(width: 17),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        local.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          height: 1.2,
                          color: tinta,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        local.categoria,
                        style: const TextStyle(color: cinza, fontSize: 11),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: cinza,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${decimal(local.distancia)} km',
                            style: const TextStyle(color: verde, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: tinta),
                          const SizedBox(width: 3),
                          Text(
                            decimal(local.avaliacao),
                            style: const TextStyle(color: verde, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 7),
                const Icon(Icons.chevron_right, size: 20, color: cinza),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
