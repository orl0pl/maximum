import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:maximum/data/models/place.dart';
import 'package:maximum/utils/location.dart';

class AddOrEditPlaceScreen extends StatefulWidget {
  final Place? place;

  const AddOrEditPlaceScreen({super.key, this.place});
  @override
  AddOrEditPlaceState createState() => AddOrEditPlaceState();
}

class AddOrEditPlaceState extends State<AddOrEditPlaceScreen> {
  final MapController _controller = MapController();
  Place placeDraft = Place(
    name: "",
    lat: 0.0,
    lng: 0.0,
  );

  @override
  void initState() {
    super.initState();

    if (widget.place != null) {
      placeDraft = widget.place!;
    } else {
      determinePositionWithSnackBar(context, mounted).then((position) {
        setState(() {
          placeDraft = Place(
            name: "",
            lat: position?.latitude ?? 0.0,
            lng: position?.longitude ?? 0.0,
          );
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.place == null
            ? const Text("l.add_place")
            : const Text("l.edit_place"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child:
                    NormalMap(controller: _controller, placeDraft: placeDraft)),
            Row(
              children: [],
            )
          ],
        ),
      ),
    );
  }
}

class NormalMap extends StatefulWidget {
  const NormalMap({
    super.key,
    required MapController controller,
    required this.placeDraft,
  }) : _controller = controller;

  final MapController _controller;
  final Place placeDraft;

  @override
  State<NormalMap> createState() => _NormalMapState();
}

enum MapState { normal, noInternet, unknownError }

class _NormalMapState extends State<NormalMap> {
  MapState _mapState = MapState.normal;
  @override
  Widget build(BuildContext context) {
    if (MapState.normal == _mapState) {
      return FlutterMap(
        mapController: widget._controller,
        options: MapOptions(
          initialZoom: 10,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
          initialCenter: LatLng(widget.placeDraft.lat, widget.placeDraft.lng),
          onTap: (tapPosition, point) {
            widget.placeDraft.lat = point.latitude;
            widget.placeDraft.lng = point.longitude;
            setState(() {});
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            errorTileCallback: (tile, error, stackTrace) {
              if (error is SocketException) {
                setState(() {
                  _mapState = MapState.noInternet;
                });
              } else {
                setState(() {
                  _mapState = MapState.unknownError;
                });
              }
            },
            minZoom: 1,
            maxZoom: 18,
          ),
          // MarkerLayer(markers: [
          //   Marker(
          //       width: 80,
          //       height: 80,
          //       point: LatLng(widget.placeDraft.lat, widget.placeDraft.lng),
          //       child: Container(
          //         decoration: const BoxDecoration(
          //           color: Colors.blue,
          //           shape: BoxShape.circle,
          //         ),
          //         child: const Icon(Icons.location_on, color: Colors.white),
          //       )),
          // ]),
          CircleLayer(circles: [
            CircleMarker(
                point: widget.placeDraft.latlng,
                radius: widget.placeDraft.maxDistance.toDouble())
          ])
        ],
      );
    } else if (MapState.noInternet == _mapState) {
      return Center(
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off,
              size: 64,
            ),
            const Text("l.no_internet"),
            FilledButton.icon(
                onPressed: () {
                  setState(() {
                    _mapState = MapState.normal;
                  });
                },
                label: const Text("l.try_again"),
                icon: const Icon(Icons.refresh))
          ],
        ),
      );
    }
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
