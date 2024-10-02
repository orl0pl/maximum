import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:maximum/data/database_helper.dart';
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
  int? tempMaxDistance = 50;

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

  get canSubmit {
    if (placeDraft.name.isEmpty) {
      return false;
    }
    if (placeDraft.maxDistance < 0) {
      return false;
    }
    if (tempMaxDistance == null) {
      return false;
    }
    if (tempMaxDistance! < 0) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: widget.place == null ? Text(l.add_place) : Text(l.edit_place),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child:
                  NormalMap(controller: _controller, placeDraft: placeDraft)),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 60,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      initialValue: placeDraft.maxDistance.toString(),
                      onChanged: (value) {
                        setState(() {
                          final int? maxDistance = int.tryParse(value);
                          tempMaxDistance = maxDistance;
                          if (maxDistance == null || maxDistance < 0) {
                            return;
                          }
                          placeDraft.maxDistance = maxDistance;
                        });
                      },
                      validator: (value) {
                        final int? radius = int.tryParse(value ?? '');
                        if (radius == null || radius < 0) {
                          return l.invalid_radius;
                        }

                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: l.max_distance,
                        counterText: l.meters(placeDraft.maxDistance),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: placeDraft.name,
                      onChanged: (value) {
                        setState(() {
                          if (value.trim().isEmpty) {
                            return;
                          }
                          placeDraft.name = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l.invalid_place_name;
                        }

                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: l.place_name,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  FilledButton(
                      onPressed: canSubmit ? submit : null, child: Text(l.save))
                ],
              ))
        ],
      ),
    );
  }

  submit() async {
    DatabaseHelper dh = DatabaseHelper();

    if (widget.place == null) {
      int newId = await dh.insertPlace(placeDraft);
      // ignore: use_build_context_synchronously
      if (context.mounted) Navigator.pop(context, newId);
    } else {
      dh.updatePlace(placeDraft);
    }
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

  void _goToCurrentLocation() async {
    Position? position = await determinePositionWithSnackBar(context, mounted);
    if (position != null && mounted) {
      setState(() {
        widget._controller
            .move(LatLng(position.latitude, position.longitude), 14.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context)!;
    var colorScheme = Theme.of(context).colorScheme;
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
                useRadiusInMeter: true,
                color:
                    Theme.of(context).colorScheme.inversePrimary.withAlpha(127),
                borderColor: Theme.of(context).colorScheme.inversePrimary,
                borderStrokeWidth: 2,
                radius: widget.placeDraft.maxDistance.toDouble())
          ]),
          // TODO: location marker
          // CurrentLocationLayer(
          //   positionStream: _positionStream,
          // ),

          // MarkerLayer(markers: [
          //   Marker(
          //       point: widget.placeDraft.latlng,
          //       alignment: Alignment.center,
          //       child: Row(
          //         mainAxisSize: MainAxisSize.min,
          //         mainAxisAlignment: MainAxisAlignment.start,
          //         crossAxisAlignment: CrossAxisAlignment.center,
          //         children: [
          //           Container(
          //               decoration: BoxDecoration(
          //                 color: colorScheme.primary,
          //                 borderRadius: BorderRadius.circular(24),
          //               ),
          //               child: Icon(Icons.location_on,
          //                   size: 24, color: colorScheme.onPrimary)),
          //           // Container(
          //           //   padding: EdgeInsets.all(8),
          //           //   decoration: BoxDecoration(
          //           //     color: colorScheme.primaryContainer,
          //           //     borderRadius: BorderRadius.circular(10),
          //           //   ),
          //           //   child: Text(
          //           //     widget.placeDraft.name,
          //           //     style: TextStyle(color: colorScheme.onPrimaryContainer),
          //           //   ),
          //           // ),
          //         ],
          //       )),
          // ]),
          MarkerLayer(markers: [
            Marker(
                point: widget.placeDraft.latlng,
                height: 45,
                width: 100,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 24,
                      color: colorScheme.onInverseSurface,
                    ),
                    Text(
                      widget.placeDraft.name,
                      style: TextStyle(
                        color: colorScheme.onInverseSurface,
                        fontSize: 14,
                      ),
                    ),
                  ],
                )),
          ]),

          Positioned(
            bottom: 30,
            right: 30,
            child: FloatingActionButton(
              onPressed: _goToCurrentLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
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
            Text(l.no_internet),
            FilledButton.icon(
                onPressed: () {
                  setState(() {
                    _mapState = MapState.normal;
                  });
                },
                label: Text(l.try_again),
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
