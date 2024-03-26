import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter TP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> villes = [];
  List<String> pays = [];
  List<String> departements = List.generate(95, (i) => '${i + 1}'.padLeft(2, '0'));
  List<dynamic> entreprises = [];
  int nombreDeResultats = 0;

  String? selectedVille;
  String? selectedDepartement;
  String? selectedPays;

  @override
  void initState() {
    super.initState();
    fetchVilles();
    fetchPays();
  }

  fetchVilles() async {
    final response = await http.get(Uri.parse('https://dptinfo.iutmetz.univ-lorraine.fr/applis/flutter_api_s4/api/getVilles.php'));
    final List<dynamic> data = jsonDecode(response.body);
    setState(() {
      villes = data.map((e) => e['ville'] as String).toList();
    });
  }

  fetchPays() async {
    final response = await http.get(Uri.parse('https://dptinfo.iutmetz.univ-lorraine.fr/applis/flutter_api_s4/api/getPays.php'));
    final List<dynamic> data = jsonDecode(response.body);
    setState(() {
      pays = data.map((e) => e['pays'] as String).toList();
    });
  }

  fetchEntreprises() async {
    final response = await http.get(Uri.parse('https://dptinfo.iutmetz.univ-lorraine.fr/applis/flutter_api_s4/api/getByVDP.php?ville=$selectedVille&dpt=$selectedDepartement&pays=$selectedPays'));
    final data = jsonDecode(response.body);
    setState(() {
      nombreDeResultats = data['nb_results'];
      entreprises = data['liste'];
    });
  }

  @override
Widget build(BuildContext context) {
  var width = MediaQuery.of(context).size.width;
  var crossAxisCount = width ~/ 200;
  crossAxisCount = crossAxisCount > 0 ? crossAxisCount : 1;

  return Scaffold(
    appBar: AppBar(
      title: Text('Flutter TP'),
    ),
    body: Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text("Choix de la ville", style: TextStyle(color: Colors.red)),
                  style: TextStyle(color: Colors.red),
                  value: selectedVille,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedVille = newValue;
                    });
                  },
                  items: villes.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text("Choix du département", style: TextStyle(color: Colors.red)),
                  style: TextStyle(color: Colors.red),
                  value: selectedDepartement,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDepartement = newValue;
                    });
                  },
                  items: departements.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text("Choix du pays", style: TextStyle(color: Colors.red)),
                  style: TextStyle(color: Colors.red),
                  value: selectedPays,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedPays = newValue;
                    });
                  },
                  items: pays.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              ElevatedButton(
                onPressed: fetchEntreprises,
                child: Text('Actualiser'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Nombre de résultats: $nombreDeResultats'),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: (1 / 1),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: entreprises.length,
            itemBuilder: (context, index) {
              var e = entreprises[index];
              return Card(
                color: Color(0xFFFF982B), // Couleur de fond de la carte
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Color(0xFFA7402F), width: 2), // Bordure de la carte
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(8.0),
                      color: Color(0xFFA7402F), // Fond du titre
                      child: Text(
                        e['noment1'],
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 10.0), // Ajustez selon vos besoins
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Color(0xFFFF982B), // Couleur de fond à l'intérieur de l'encadré
                            border: Border.all(color: Color(0xFFD5CEBD), width: 1), // Bordure grise
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            '${e['adr1']}\n${e['cpent']} ${e['ville']}',
                            style: TextStyle(
                              color: Color(0xFF6B4316), // Couleur du texte
                            ),
                            textAlign: TextAlign.center, // Texte centré horizontalement
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}}