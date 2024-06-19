import 'package:flutter/material.dart';
import 'package:flutter_challenge/assets.dart';
import 'package:flutter_challenge/companyService.dart';
import 'package:flutter_challenge/locations.dart';

class CompanyAssetsPage extends StatefulWidget {
  final String companyId;

  const CompanyAssetsPage({Key? key, required this.companyId}) : super(key: key);

  @override
  _CompanyAssetsPageState createState() => _CompanyAssetsPageState();
}

class _CompanyAssetsPageState extends State<CompanyAssetsPage> {
  late Future<List<Location>> _locationsFuture;
  late Future<List<Asset>> _assetsFuture;
  bool _showEnergySensorsOnly = false;
  bool _showAlertStatusOnly = false;
  List<Location> _locations = [];
  List<Asset> _assets = [];
  List<Location> _filteredLocations = [];
  List<Asset> _filteredAssets = [];
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _locationsFuture = CompanyService.fetchLocations(widget.companyId);
    _assetsFuture = CompanyService.fetchAssetsByCompanyId(widget.companyId);
    _loadData();
  }

  void _loadData() async {
    _locations = await _locationsFuture;
    _assets = await _assetsFuture;
    _applyFilters();
  }

  void _toggleEnergySensorFilter() {
    setState(() {
      _showEnergySensorsOnly = !_showEnergySensorsOnly;
    });
  }

  void _toggleAlertStatusFilter() {
    setState(() {
      _showAlertStatusOnly = !_showAlertStatusOnly;
    });
  }


  void _applyFilters() {
    setState(() {
      _filteredAssets = _assets.where((asset) {
        bool matchesSearchText = asset.name.toLowerCase().contains(_searchText.toLowerCase());
        bool matchesEnergyFilter = !_showEnergySensorsOnly || (asset.sensorType == 'energy');
        bool matchesAlertFilter = !_showAlertStatusOnly || (asset.status == 'alert');
        return matchesSearchText && matchesEnergyFilter && matchesAlertFilter;
      }).toList();

      _filteredLocations = _locations.where((location) {
        bool matchesSearchText = location.name.toLowerCase().contains(_searchText.toLowerCase());
        return matchesSearchText;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assets',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 1, 27, 48),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: _toggleEnergySensorFilter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showEnergySensorsOnly ? Colors.red : Colors.blue,
                    foregroundColor: Colors.white, 
                    side: BorderSide(
                      color: _showEnergySensorsOnly ? Colors.red : Colors.blue,
                      width: 2.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  ),
                  label: Text(_showEnergySensorsOnly ? 'Show All' : 'Sensor de Energia'),
                  icon: const Icon(Icons.bolt),
                ),
                const SizedBox(width: 15), 
                ElevatedButton.icon(
                  onPressed: _toggleAlertStatusFilter,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: _showAlertStatusOnly ? Colors.red : Colors.blue, 
                    side: BorderSide(
                      color: _showAlertStatusOnly ? Colors.red : Colors.blue,
                      width: 2.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  ),
                  icon: const Icon(Icons.warning_rounded),
                  label: Text(_showAlertStatusOnly ? 'Show All' : 'Crítico'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15), 
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              height: 36, 
              child: TextField(
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0), 
                  fillColor: Colors.grey[200],
                  filled: true,
                  hintText: 'Buscar Ativo ou Local',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  _searchText = value;
                    _applyFilters();
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder(
              future: Future.wait([_locationsFuture, _assetsFuture]),
              builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data available'));
                } else {


                  return ListView(
                    children: _buildTree(_filteredLocations, _filteredAssets),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Asset> _applyFilter(List<Asset> assets) {
    return assets.where((asset) {
      bool showAsset = true;

      if (_showAlertStatusOnly && asset.status == 'alert' && asset.sensorType == null) {
        showAsset = false;
      }

      return showAsset;
    }).toList();
  }

  List<Widget> _buildTree(List<Location> locations, List<Asset> assets) {
    List<Widget> treeWidgets = [];

    List<Location> mainLocations = locations.where((loc) => loc.parentId == null).toList();

    for (Location location in mainLocations) {
      treeWidgets.add(_buildLocationTile(location, assets, locations));
    }

    List<Asset> unlinkedAssets = assets.where((asset) => asset.locationId == null && asset.parentId == null).toList();
    if (unlinkedAssets.isNotEmpty) {
      treeWidgets.addAll(_buildUnlinkedAssetTiles(unlinkedAssets));
    }

    return treeWidgets;
  }

  Widget _buildLocationTile(Location location, List<Asset> assets, List<Location> subLocations) {
    List<Location> childLocations = subLocations.where((subLoc) => subLoc.parentId == location.id).toList();
    List<Asset> locationAssets = assets.where((asset) => asset.locationId == location.id).toList();

    return ExpansionTile(
      key: PageStorageKey<String>(location.id!),
      leading: Image.asset(
        'images/location.png',
        width: 40,
        height: 40,
      ),
      title: Text(location.name),
      children: [
        ...childLocations.map((subLocation) => _buildSubLocationTile(subLocation, assets)).toList(),
        ..._buildAssetTiles(locationAssets, assets),
      ],
    );
  }

  Widget _buildSubLocationTile(Location location, List<Asset> assets) {
    List<Asset> locationAssets = assets.where((asset) => asset.locationId == location.id).toList();

    return ExpansionTile(
      key: PageStorageKey<String>(location.id!),
      leading: Padding(
        padding: const EdgeInsets.only(left: 24.0),
        child: Image.asset(
          'images/location.png',
          width: 40,
          height: 40,
        ),
      ),
      title: Text(location.name),
      children: _buildAssetTiles(locationAssets, assets),
    );
  }

  List<Widget> _buildAssetTiles(List<Asset> assets, List<Asset> allAssets) {
    List<Widget> assetTiles = [];

    for (Asset asset in assets) {
      bool isComponent = asset.sensorType != null;
      bool isSubAsset = asset.parentId != null && !isComponent;
      bool isAsset = asset.locationId != null && asset.parentId == null && !isComponent && !isSubAsset;

      bool isComponentWithAlert = asset.status == 'alert' && isComponent;

      Widget leadingImage = Padding(
        padding: EdgeInsets.only(
          left: isSubAsset ? 72.0 : isComponent ? 96.0 : isAsset ? 48.0 : 0.0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_showEnergySensorsOnly && asset.sensorType == 'energy')
              const Icon(
                Icons.flash_on,
                color: Colors.green,
                size: 20,
              ),
            Image.asset(
              'images/${isComponent ? 'component.png' : isSubAsset ? 'asset.png' : 'asset.png'}',
              width: 40,
              height: 40,
            ),
          ],
        ),
      );

      if (_showAlertStatusOnly && isComponentWithAlert) {
        leadingImage = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            leadingImage,
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Icon(Icons.warning, color: Colors.red, size: 20),
            ),
          ],
        );
      }

      Widget assetTile = ListTile(
        leading: leadingImage,
        title: Text(asset.name),
        
      ); const SizedBox(width: 8.0);

      List<Asset> subAssets = allAssets.where((subAsset) => subAsset.parentId == asset.id).toList();
      if (subAssets.isNotEmpty) {
        assetTile = ExpansionTile(
          key: PageStorageKey<String>(asset.id!),
          leading: leadingImage,
          title: Text(asset.name),
          children: _buildAssetTiles(subAssets, allAssets),
        );
      }

      assetTiles.add(assetTile);
    }

    return assetTiles;
  }

  List<Widget> _buildUnlinkedAssetTiles(List<Asset> assets) {
    List<Widget> assetTiles = [];

    for (Asset asset in assets) {
       Widget leadingImage = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showEnergySensorsOnly && asset.sensorType == 'energy')
          const Icon(
            Icons.bolt,
            color: Colors.green,
            size: 20,
          ),
        if (_showAlertStatusOnly && asset.status == 'alert')
          const Icon(
            Icons.warning,
            color: Colors.red,
            size: 20,
          ),
        Image.asset(
          'images/component.png',
          width: 40,
          height: 40,
        ),
      ],
    );

      assetTiles.add(ListTile(
        leading: leadingImage,
        title: Text(asset.name),
      ));
    }

    return assetTiles;
  }
}


class AssetLocationSearchDelegate extends SearchDelegate<List<dynamic>> {
  final Future<List<Asset>> assetsFuture;
  final Future<List<Location>> locationsFuture;

  AssetLocationSearchDelegate(this.assetsFuture, this.locationsFuture);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, []);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([assetsFuture, locationsFuture]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No results found'));
        } else {
          List<Asset> assets = snapshot.data![0];
          List<Location> locations = snapshot.data![1];

          List<dynamic> filteredResults = [
            ...assets.where((asset) => asset.name.toLowerCase().contains(query.toLowerCase())),
            ...locations.where((location) => location.name.toLowerCase().contains(query.toLowerCase())),
          ];

          return ListView(
            children: filteredResults.map((result) {
              if (result is Asset) {
                return ListTile(
                  leading: const Icon(Icons.memory),
                  title: Text(result.name),
                  onTap: () {
                    close(context, [result]);
                  },
                );
              } else if (result is Location) {
                return ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(result.name),
                  onTap: () {
                    close(context, [result]);
                  },
                );
              }
              return const SizedBox.shrink();
            }).toList(),
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}