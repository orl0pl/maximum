import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geocoding/geocoding.dart';
import 'package:maximum/data/database_helper.dart';
import 'package:maximum/data/models/place.dart';
import 'package:maximum/screens/add_place.dart';

class ManagePlacesScreen extends StatefulWidget {
  const ManagePlacesScreen({super.key});

  @override
  State<ManagePlacesScreen> createState() => _ManagePlacesScreenState();
}

class _ManagePlacesScreenState extends State<ManagePlacesScreen> {
  final DatabaseHelper _dh = DatabaseHelper();
  List<Place>? places;

  @override
  void initState() {
    super.initState();
    _dh.getPlaces().then((value) => setState(() {
          places = value;
        }));
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.manage_places),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return const AddOrEditPlaceScreen();
          }));
        },
        child: const Icon(Icons.add),
      ),
      body: places == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemBuilder: (itemBuilder, index) {
                return ListTile(
                  title: Text(places![index].name),
                  subtitle: FutureBuilder(
                    future: placemarkFromCoordinates(
                        places![index].lat, places![index].lng),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<Placemark> placemarks = snapshot.data!;
                        return Text(
                            "${placemarks[0].country}${placemarks[0].subLocality}, ${placemarks[0].locality}, ${placemarks[0].street}");
                      } else {
                        return Text("Loading...");
                      }
                    },
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return AddOrEditPlaceScreen(
                        place: places![index],
                      );
                    }));
                  },
                );
              },
              itemCount: places?.length ?? 0),
    );
  }
}
